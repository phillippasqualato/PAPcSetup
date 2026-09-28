# Stack defaults (Vercel + Supabase + GitHub)

Use these unless a product requirement gives a concrete reason not to. Record every deviation in `docs/tech.md` with its reason. Verify version-specific details against official docs before writing them down; conventions change.

| Layer | Default | Why |
|---|---|---|
| Framework | Next.js (App Router, current major) + TypeScript (strict) | First-class on Vercel; ships version-matched docs for agents |
| Styling | Tailwind CSS + shadcn/ui primitives, themed from `DESIGN.md` tokens | Agents are fluent in it; tokens map to CSS variables |
| Data | Supabase Postgres | One service for db, auth, storage, realtime |
| Auth | Supabase Auth (email magic link + Google/Microsoft OAuth as needed) | Integrates with RLS |
| Authorization | Row Level Security on every table, policies written in SQL migrations | Security lives in the database, not only in UI |
| Data access | `@supabase/ssr` clients (server + browser); generated TypeScript types from the schema | Type-safe queries |
| Migrations | Supabase CLI migrations in `supabase/migrations`, committed to git | Reproducible, reviewable |
| Validation | Zod at every boundary (forms, route handlers, AI output) | Safe inputs |
| Server logic | Server Components + Server Actions first; route handlers for webhooks; Supabase Edge Functions only when it must run next to the db | Simplest thing that works |
| Background jobs | Multi-step or AI fan-out → Vercel Workflow (durable steps; each step ≤ the function max duration); DB-native simple jobs → Supabase Queues (pgmq) + Cron; a few seconds after a response → `after()`; Inngest/Trigger.dev only via ADR. See `background-jobs.md` | Avoid timeouts, duplicates and runaway cost |
| AI features | Vercel AI SDK, provider key in env vars, calls server-side only, structured output validated with Zod; provider rate limits respected (waves, prompt caching); per-organisation monthly ceiling enforced in code; uploaded documents inside an untrusted-content fence; scores computed in code, not by the model; golden-set evals | No keys in the browser, no surprise bills, no injected scores |
| Files | Supabase Storage with RLS policies per bucket | Same permission model |
| Email | Resend (transactional) | Simple API |
| Payments | Stripe (Checkout + webhooks) only when the product sells seats | Standard |
| Hosting | Vercel, GitHub integration: every PR gets a preview URL, `main` deploys production | The feedback loop for visual QA |
| Region / privacy | Supabase in an EU region (e.g. Frankfurt) and Vercel functions in an EU region for EU customers; list personal data and retention in `docs/tech.md` | GDPR |
| Preview databases | Supabase GitHub integration + branching (preview DB per PR built from migrations, `seed.sql` for fake data) when the plan allows; otherwise one shared dev project | Previews test real schema changes |
| Env sync | Vercel↔Supabase Marketplace integration owns Supabase env vars in Vercel | No hand-copied keys |
| Repo / tracker | GitHub: issues as the tracker (labels from setup), PRs for every change, branch protection on `main` | One place for work |
| CI | GitHub Actions: install, typecheck, lint, unit tests, build on every PR | Catches breakage before preview |
| Unit tests | Vitest | Fast |
| E2E / visual checks | Playwright (also used by visual-qa) | Real browser |
| Observability | Vercel logs + Supabase logs; add error tracking (e.g. Sentry) before real customers | Know when it breaks |

## Multi-tenancy rule of thumb

- Internal tool for one company → single tenant, no `organisation_id`.
- Sold to several companies → `organisations` table, `memberships` (user × org × role), `organisation_id` on every tenant-owned row, RLS policies check membership. Decide this in Phase 2; it is expensive to add later (write an ADR).

## Quality gates the build agent must pass (copy into CLAUDE.md)

1. Typecheck and lint clean.
2. Tests for the behaviour in the ticket (test-first where there's a clear seam).
3. `next build` succeeds locally or in CI.
4. Migrations apply cleanly on a fresh database; RLS enabled on every new table.
5. PR opened; Vercel preview URL loads; the changed flow is clicked through (visual-qa) before merging.
6. Evidence, not claims: paste command output or the preview URL in the PR.

## Secrets and env vars

Names only in docs. Use the names the Vercel↔Supabase integration syncs (verify in the integration docs at setup time): `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (browser-safe), `SUPABASE_SECRET_KEY` (server only), `POSTGRES_*` (server only), plus provider keys. Don't use the legacy `NEXT_PUBLIC_SUPABASE_ANON_KEY` / `SUPABASE_SERVICE_ROLE_KEY` names in new code. Values live in Vercel (owned by the integration) and `.env.local` (git-ignored). A secret never gets a `NEXT_PUBLIC_` prefix and never reaches the browser.

## Next.js agent files

`create-next-app` generates `AGENTS.md` (with a managed block pointing agents at the bundled, version-matched docs) and `CLAUDE.md` = `@AGENTS.md`; `next dev` 16.3+ keeps that block up to date. Keep it. Project rules go in `AGENTS.md` outside the markers. Source: https://nextjs.org/docs/app/guides/ai-agents
