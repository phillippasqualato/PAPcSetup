# Background jobs and AI fan-out on Vercel + Supabase

Owner: `define-tech`. Read this when a job can run longer than ~60 s, fans out several AI calls, or must survive retries (e.g. an "analyse" button that runs several specialist AI agents over one record). Record the choice in the "where AI runs" ADR and a *Background work* section in `docs/tech.md`.

Facts verified 2026-09-23; limits change, so re-check the linked pages before relying on a number.

## 1. Where long work runs

| Option | Use for | Limits (2026) | Source |
|---|---|---|---|
| `after()` in a route/Server Action | a few seconds of fire-and-forget after the response (log, notify) | bounded by the function's duration; no retry | https://vercel.com/kb/guide/how-to-run-background-jobs-in-nextjs-on-vercel |
| **Vercel Workflow** (`workflow` npm, `'use workflow'` / `'use step'`) — **default for multi-step or AI fan-out** | durable runs with steps, retries, fan-out/fan-in, sleep | each step ≤ the function max duration (Hobby 300 s, Pro 800 s; 30 min is beta); run has no time limit; steps retry 3× by default; 10,000 steps/run; runs pinned to one region for their lifetime; the `region` option on `start()` needs `workflow` ≥ 5.0.0-beta.33 (4.x, npm `latest` in Sept 2026, always stores runs in `iad1`, US): pin the version in `package.json` and record it in the ADR; `region` sets where run data lives, so also set `regions: ["fra1"]` (or your EU region) in `vercel.json`; strict residency during failover isn't guaranteed yet; run inputs/outputs readable by team owners (treat Vercel as a data processor) | https://vercel.com/docs/workflows , https://vercel.com/docs/functions/configuring-functions/duration , https://vercel.com/docs/workflows/pricing |
| Vercel Queues | low-level control: per-consumer-group concurrency caps, fairness between tenants | public beta; at-least-once; idempotency key per message; `maxDeliveries` unlimited by default (**always set it**: each timed-out retry is billed the full duration); no DLQ; messages pinned to the deployment that sent them | https://vercel.com/docs/queues , https://vercel.com/docs/queues/concepts |
| Supabase Queues (pgmq) + Supabase Cron + Edge Function worker | simple DB-native jobs under 150 s (Free) / ~6.5 min (paid; respond within 150 s and finish in `EdgeRuntime.waitUntil()`) | Edge Function wall clock 150 s free / 400 s paid, 2 s CPU per request; `EdgeRuntime.waitUntil()` has the same limits; orchestration and fan-in are hand-rolled | https://supabase.com/docs/guides/queues , https://supabase.com/docs/guides/functions/limits |
| Inngest / Trigger.dev | when per-tenant concurrency and a job dashboard matter more than one fewer vendor | extra vendor = extra data processor (DPA, EU region) | https://www.inngest.com/docs/guides/concurrency |

Rule: start with Vercel Workflow. Add Queues only for a concurrency cap Workflow can't express. Supabase Queues when the job lives entirely in the database. A third-party runner only through an ADR.

## 2. The fan-out pattern (one run per request)

1. **Start** (Server Action or `POST /api/runs`): check auth and membership → insert `ai_runs(id, subject_id` (the record being analysed), organisation_id, status='queued', budget_tokens, input_hash, created_by)` → `start(runAgents, [runId], { region: '<EU>' })` (requires `workflow` ≥ 5.0.0-beta.33, see §1) → return 202 with `runId`; if `start()` throws, set the row to `failed` before returning the error, or the unique index locks the record.
2. **Double-click safe:** a partial unique index `on ai_runs(subject_id) where status in ('queued','running')`; the second insert fails and the UI shows the running one.
3. **Steps:** `loadInputs` → the specialist steps → `synthesise` → `finalise`. Each specialist step calls the model through the AI SDK, validates the output with Zod, and **upserts** `ai_run_steps(run_id, agent, status, output, tokens_in, tokens_out)` with `on conflict (run_id, agent) do update`, so a retried step never duplicates.
4. **Concurrency:** run the specialists in waves (`Promise.all` over chunks of 3–4), sized from the AI provider's rate limits (requests, input and output tokens per minute). Put shared system prompts behind prompt caching (cached input doesn't count toward the input-token limit on Claude).
5. **Budget, enforced in code:** `loadInputs` estimates tokens and reserves them atomically (insert an `ai_usage` reservation in the same transaction as the ceiling check, e.g. `select … for update` on the organisation's budget row), so two runs started at once can't both pass. Every step records actual usage. Budget breach or the provider's spend-cap error (Claude: HTTP 429, `error.type = "rate_limit_error"` with `error.details.error_code = "enforced_spend_limit_reached"`, no `retry-after`) → `throw new FatalError(...)`. A 429 **with** `retry-after` → `throw new RetryableError(msg, { retryAfter })`; set `maxRetries` on AI steps deliberately. Source: https://platform.claude.com/docs/en/api/rate-limits
6. **Duration:** every step must finish inside the plan's function limit. Split long documents into per-section steps.
7. **Progress and control:** the UI reads `ai_run_steps` via Supabase Realtime (or polling). Cancel = `status='cancelled'`, checked at the start of every step. A later change to the record's inputs marks results stale via `input_hash`.
8. **Partial results:** one agent failing permanently ends the run as `partial`, with that agent named in the UI. Never show a score computed from missing parts as complete.

## 3. Database load

- Workers talk to Supabase over supabase-js (HTTP/PostgREST) or the transaction pooler (port 6543). Never a `pg.Pool` per step. Short writes, no long transactions.
- Nano/Micro allow 200 pooler clients; a few concurrent runs writing one or two rows per step are negligible. Source: https://supabase.com/docs/guides/platform/compute-and-disk
- See `supabase-postgres-best-practices` rules `conn-*` and `lock-*` (e.g. `SKIP LOCKED` for queue-style tables).
- Enqueueing with `pgmq.send()` inside the same transaction as the business write is a free "outbox": the job exists if and only if the write committed.

## 4. Security (the worker bypasses RLS)

- Workers use `SUPABASE_SECRET_KEY`, so RLS doesn't protect them. Every query filters by the `organisation_id` read from the `ai_runs` row, **never from the step payload or the model's output**.
- No table or column names from user input or model output.
- Wrap `next.config.ts` with `withWorkflow()`, and exclude `.well-known/workflow/` from the Supabase auth proxy/middleware matcher (e.g. `/((?!_next/static|_next/image|favicon.ico|.well-known/workflow/).*)`); never put auth in front of those routes. Vercel Queues push consumers have no public URL. The route that calls `start()` authenticates and authorizes before starting.
- Uploaded documents (PDFs, spreadsheets, anything a user or third party supplies) are untrusted input: they enter the model inside an untrusted-content fence (`<document>` … `</document>` with an instruction that its content is data). A forged closing fence inside a document is neutralised and logged as a finding on that document. Agents get read-only context and no write tools. Their output is data, rendered escaped.
- `supabase-security-reviewer` checks this on every PR that adds a worker.

## 5. Job envelope

Every message or run input carries `{ run_id, idempotency_key, schema_version }`. Consumers ignore a key they've already completed and reject an unknown schema version loudly.

## 6. Quality gate for agent output (before launch, and on every prompt or model change)

- A golden set of 10–20 real, anonymised cases with known good assessments, stored as fixtures.
- Every agent output is schema-valid and cites the source passage it relies on; an uncited claim is a failed check.
- Scores and weights (e.g. a 1–5 rating or a weighted total) are computed by **pure functions in code**, not by the model, with unit tests and property tests (`fast-check`): monotonic in each input, bounded, same input → same score.
- A human reviews at least 20 outputs before launch; more than 15% rejected means not ready.
- Re-run the golden set when prompts or models change; compare against the last run.

## 7. Observability

- Workflow run traces in the Vercel dashboard; a Queues retry-depth alert; `maxDeliveries` always set.
- Per run: duration, tokens, cost, agents failed. Alert on a run stuck in `queued` or `running` longer than the expected maximum, and let an operator mark it `failed` so the record unlocks.
- Runs stay on the deployment that started them; a rollback doesn't stop them. After a bad deploy, cancel old runs from Observability → Workflows (or the CLI); a deleted deployment's runs never finish on their own.
