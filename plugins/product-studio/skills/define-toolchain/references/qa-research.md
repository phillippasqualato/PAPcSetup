# QA / "brutal E2E" research: skills, subagents, plugins and tools for a Next.js + Supabase + Vercel app

Research date: 2026-09-23. Repos were cloned with `git clone --depth 1` into a research workspace (`<owner>_<repo>`). Everything below was read from those clones unless it is marked **[web]**, meaning it was checked on the web only, or **[UNVERIFIED]**, meaning it was not confirmed at all. Dates in brackets are the last commit date in each clone.

Verdict key:
- **VENDOR**: copy the files into the product repo (`.claude/…`).
- **INSTALL**: add as a plugin, MCP server, npm dev dependency or CI action. Do not copy the files.
- **REFERENCE**: read it and borrow ideas or prompts.
- **SKIP**: not worth it for this stack.

---

## 1. Browser-driving and E2E layer

### 1.1 Playwright Test Agents (planner / generator / healer). Verdict: **INSTALL (generate in repo)**, core
- Repo: https://github.com/microsoft/playwright (Apache-2.0) [2026-09-22, main = 1.64.0-next; latest release notes are for 1.63]. Docs: `docs/src/test-agents-js.md`, published at https://playwright.dev/docs/test-agents.
- Command: `npx playwright init-agents --loop=claude`. It is defined in `packages/playwright/src/program.ts:161`. Choices: `claude|codex|copilot|opencode|vscode|vscode-legacy`. Flags: `-c/--config`, `--project <name>` (the project the seed test runs in) and `--prompts`.
- Files it writes for `--loop=claude` (from `packages/playwright/src/agents/generateAgents.ts:37-60`, `initRepo` at ~l.404):
  - `.claude/agents/playwright-test-planner.md`, `playwright-test-generator.md` and `playwright-test-healer.md`, generated from `*.agent.md` in the same folder.
  - `.mcp.json` → `{"mcpServers":{"playwright-test":{"command":"npx","args":["playwright","run-test-mcp-server"]}}}`.
  - `specs/README.md`, which creates the folder where Markdown test plans go.
  - `<testDir>/seed.spec.ts`, written only if no seed exists. Source: `packages/playwright/src/mcp/test/seed.ts:40,55`.
  - With `--prompts`: `.claude/prompts/playwright-test-{coverage,generate,heal,plan}.md`. `playwright-test-coverage.prompt.md` chains planner → generator (one test case at a time, never in parallel) → healer.
- Agent tools. **Planner:** `planner_setup_page`, `planner_save_plan`, `browser_*` and `browser_run_code_unsafe`; it writes `specs/<name>.md`. **Generator:** `generator_setup_page`, `generator_read_log`, `generator_write_test`, plus the **verify tools** `browser_verify_element_visible`, `browser_verify_list_visible`, `browser_verify_text_visible` and `browser_verify_value`; it writes `tests/<suite>/<case>.spec.ts`. **Healer:** `test_run`, `test_debug`, `test_list`, `browser_generate_locator` and `edit`. All three default to `model: sonnet`.
- There is no standalone `playwright verify` CLI command. "Verify" means the `browser_verify_*` MCP tools that the generator uses to emit assertions **[verified in agent spec; no `verify` subcommand found in program.ts]**.
- Related 1.59+ agent affordances (release-notes-js.md ~l.539-640): `npx playwright test --debug=cli` with `playwright-cli attach <session>`, `npx playwright trace open|actions|action N|snapshot`, and `PLAYWRIGHT_DASHBOARD=1`.
- What it catches: broken happy paths and scenario coverage from a plan. It produces a durable regression suite, which is the only output here that keeps running in CI. The weakness is that the planner explores politely. You must tell it to probe edge cases (see §3).
- Gotcha: regenerate after every Playwright upgrade (the docs say so). The seed test must log in and run global setup, so put Supabase test-user auth into fixtures and `storageState`.

### 1.2 Playwright MCP. Verdict: **INSTALL**, interactive exploration
- Repo: https://github.com/microsoft/playwright-mcp (Apache-2.0) [2026-09-18, `@playwright/mcp` 0.0.82].
- `claude mcp add playwright npx @playwright/mcp@latest` (README l.101). It is also in the official marketplace as `playwright` (`anthropics/claude-plugins-official/external_plugins/playwright/.mcp.json`).
- Useful flags (README l.415-520): `--isolated`, `--storage-state=<file>` (log in as user A or user B), `--headless`, `--output-dir` and `--caps=network,storage,devtools,testing,vision,pdf`. Running parallel clients requires `--isolated` or a distinct `--user-data-dir` (l.485). That is what makes two-user tests possible: run two MCP instances with two storage states.
- Catches: console errors, failed network calls and broken flows during agent-driven exploration.
- Overlaps with §1.1, whose `playwright-test` MCP is a superset aimed at tests. Keep this one for ad-hoc exploration.

### 1.3 Chrome DevTools MCP (+ skills). Verdict: **INSTALL**, perf, a11y and debugging
- Repo: https://github.com/ChromeDevTools/chrome-devtools-mcp (Apache-2.0) [2026-09-23, v1.10.1].
- `claude mcp add chrome-devtools --scope user npx chrome-devtools-mcp@latest`, or use the plugin with skills: `/plugin marketplace add ChromeDevTools/chrome-devtools-mcp` (`docs/client-configurations.md` l.64-91).
- Tools (`docs/tool-reference.md`) include performance traces (3 tools), network (2), debugging (9, including **`lighthouse_audit`**), memory (14), emulation and PWA. Skills in `skills/` are `a11y-debugging`, `debug-optimize-lcp`, `memory-leak-debugging`, `cookie-debugging`, `troubleshooting`, `chrome-devtools` and `chrome-devtools-cli`. `--slim`, `--headless` and `--isolated` are available.
- Catches: LCP/CLS regressions, memory leaks from repeated navigation, cookie and auth-cookie problems, and a11y tree issues. `lighthouse_audit` largely replaces a separate Lighthouse run for ad-hoc checks.

### 1.4 agent-browser (+ `dogfood` skill). Verdict: **INSTALL** CLI + skill; use `dogfood` as the exploratory bug-bash engine
- Repo: https://github.com/vercel-labs/agent-browser (Apache-2.0) [2026-09-22, v0.38.1]. It is a Rust CLI and talks CDP directly.
- Install: `npm i -g agent-browser && agent-browser install`. Skill: `npx skills add vercel-labs/agent-browser` (README l.1735). The installed `skills/agent-browser/SKILL.md` is only a stub. Real content is served by the version-matched CLI: `agent-browser skills get core|dogfood|protected-vercel-deployments …`. The source files are in `skill-data/*/SKILL.md`.
- **`skill-data/dogfood/SKILL.md`** triggers on "dogfood / QA / exploratory test / bug hunt". Workflow: Initialize → Authenticate (save state) → Orient → Explore → Document (screenshot + video per issue) → Wrap up. Output goes to `./dogfood-output/report.md` plus `screenshots/` and `videos/`. It ships `references/issue-taxonomy.md` and `templates/dogfood-report-template.md`. This is the best ready-made "no-coder bug bash" found.
- Built-in brutal-testing primitives (README):
  - `a11y` runs axe-core embedded in the binary, with `--tags wcag2a,wcag2aa` and `--json` (l.518).
  - `console`, `errors` (l.453-457).
  - `network route <url> --abort|--body <json>` for fault injection (l.360).
  - `network har start/stop`.
  - `diff snapshot`, `diff screenshot --baseline` and `diff url v1 v2 --screenshot` for a preview-vs-prod visual diff (l.428-436).
  - Named `--session`s and tabs, which make two-user and multi-tab state-interference tests easy.
  - `react … --enable react-devtools` and `vitals`.
  - `skills get protected-vercel-deployments` for reaching Vercel preview URLs behind protection.
- Community clone: https://github.com/alexanderop/dogfood-qa (2 stars, license not stated) **[web]**. It is a copy of the same idea. **SKIP**; use the upstream.

### 1.5 Other Playwright skills. Verdict: **REFERENCE / pick at most one**
- `anthropics/skills/skills/webapp-testing` (Python, `scripts/with_server.py`). Small and official. Useful when there is no Playwright suite yet.
- `lackeyjb/playwright-skill` (MIT) [2026-08-14]. A Node runner that writes throwaway scripts.
- `Jeffallan/claude-skills/skills/playwright-expert` (MIT). A persona with references. REFERENCE.
- All three are redundant once §1.1–1.4 are installed.

---

## 2. Test libraries the agents should write against

### 2.1 fast-check. Verdict: **INSTALL** (`npm i -D fast-check`, plus `@fast-check/vitest` if Vitest is used)
- https://github.com/dubzzz/fast-check (MIT) [2026-09-23, fast-check 4.10.2]. Packages: `fast-check`, `vitest`, `jest`, `ava`, `worker`, `poisoning`.
- Docs in repo: `website/docs/advanced/{race-conditions,model-based-testing,fuzzing,fake-data}.md`.
- **Race conditions:** `fc.scheduler()` → `s.schedule(promise)` / `s.scheduleFunction(fn)` reorders promise resolution to expose "user choice X breaks Y" async bugs (`race-conditions.md` l.17-24).
- **Model-based testing:** `fc.commands` + `fc.modelRun`/`asyncModelRun` generates random sequences of user actions against a model. This is the right tool for state-interference bugs in reducers, server actions and cart/checkout logic.
- Catches: validator edge cases (unicode, empty, huge, negative, NaN), serialization round-trips and ordering bugs.

### 2.2 Trail of Bits `property-based-testing` skill. Verdict: **INSTALL** (plugin)
- https://github.com/trailofbits/skills `plugins/property-based-testing/skills/property-based-testing/SKILL.md` (+ `references/{generating,interpreting-failures,libraries}.md`). The description names fast-check explicitly.
- License: **CC-BY-SA-4.0**. The ShareAlike clause is the reason to install it rather than vendor it into a proprietary repo.
- `/plugin marketplace add trailofbits/skills`.

### 2.3 @axe-core/playwright. Verdict: **INSTALL** (`npm i -D @axe-core/playwright`)
- https://github.com/dequelabs/axe-core-npm `packages/playwright` (**MPL-2.0**, v4.13.0) [2026-09-02].
- `await new AxeBuilder({ page }).withTags(['wcag2a','wcag2aa','wcag21aa']).analyze()`, then assert `violations` equals `[]` (README l.22-50). Add it to the seed fixture so every generated test also runs a11y checks.
- MPL is file-level copyleft. Using it as a dev dependency is fine.

### 2.4 Playwright visual regression (built in). Verdict: **INSTALL (config only)**
- `await expect(page).toHaveScreenshot()`, then `npx playwright test --update-snapshots` to accept baselines. Mask dynamic regions (`mask: [locator]`, `animations: 'disabled'`). Baselines are OS/browser specific, so generate them in CI (Docker `mcr.microsoft.com/playwright`) rather than on a Mac. This is standard Playwright documentation **[not re-read in clone]**.
- Cheaper ad-hoc alternative: `agent-browser diff url <preview> <prod> --screenshot`.

---

## 3. State-interference, multi-tenant and concurrency: how to get "brutal"

No off-the-shelf skill does this well. It has to be written into the `/harden` prompt, using these building blocks:
- **Two users, one test:** `browser.newContext({ storageState: 'userA.json' })` and a second context for userB. Have A create, rename, delete or share objects, then assert that B cannot see or change them. Repeat for anon (no session).
- **Direct API bypass:** use `supabase-js` with the **anon key + user B's JWT** to `select/update/delete` user A's rows by ID. This tests RLS for real, independent of the UI. Never use the service-role key in these tests except for setup.
- **Races:** `Promise.all` double-submits in Playwright (double-click "Pay", two tabs submitting the same form). Use `fc.scheduler()` for server-action/unit level. Use `page.clock` (Playwright Clock API, release notes 1.45) for expiry and timeout logic.
- **Fault injection:** `page.route('**/rest/v1/**', r => r.abort())` or `agent-browser network route … --abort` checks that error states render and no half-writes are left behind.
- **Planner prompt addendum** (for §1.1): "For every feature include: empty/max-length/unicode/emoji/RTL inputs, back-button and refresh mid-flow, two tabs, logged-out access by URL, another tenant's ID in the URL, slow/failed network, and double submit."

---

## 4. Supabase-specific security

### 4.1 pgTAP via Supabase CLI. Verdict: **INSTALL (CLI)**, core
- `supabase test db` "Tests local database with pgTAP". Tests live in `supabase/tests/*.sql`. `supabase db lint [--level warning|error] [--linked] [-s schema]` runs plpgsql_check. **[web]** https://github.com/supabase/supabase/blob/master/apps/docs/content/guides/local-development/cli/testing-and-linting.mdx
- `supabase test new <name>` scaffolds a test **[UNVERIFIED in docs fetched]**.

### 4.2 basejump supabase-test-helpers. Verdict: **VENDOR** (one SQL file) or install via dbdev
- https://github.com/usebasejump/supabase-test-helpers (MIT-style, `LICENSE.md`) [2024-04-13; old but stable].
- `select dbdev.install('basejump-supabase_test_helpers');` then `CREATE EXTENSION "basejump-supabase_test_helpers";` inside the test transaction. Alternatively, copy `supabase_test_helpers--0.0.6.sql` into `supabase/tests/00000-supabase_test_helpers.sql`.
- Helpers: `tests.create_supabase_user`, `tests.authenticate_as(identifier)`, `tests.authenticate_as_service_role()`, `tests.clear_authentication()`, `tests.rls_enabled(schema[, table])`, `tests.freeze_time()`. Example: `supabase/tests/99-blog-example.sql`.
- Catches: RLS disabled, cross-user reads and writes, anon access. This is the most important security test for the stack.
- Alternative: launchql/supabase-test-suite (MIT, Jest, ephemeral rollback DBs, 23 stars) **[web]** https://github.com/launchql/supabase-test-suite. REFERENCE.

### 4.3 Supabase advisors (splinter). Verdict: **INSTALL** (via MCP or CLI), core, zero-effort
- https://github.com/supabase/splinter [2026-09-08]. No LICENSE file in the clone, so **[license UNVERIFIED]**. `splinter.sql` in the repo root runs all lints. `lints/0001…0030`, including `0002_auth_users_exposed`, `0007_policy_exists_rls_disabled`, `0008_rls_enabled_no_policy`, `0010_security_definer_view`, `0011_function_search_path_mutable`, `0013_rls_disabled_in_public`, `0015_rls_references_user_metadata`, `0023_sensitive_columns_exposed`, `0024_rls_policy_always_true`, `0025_public_bucket_allows_listing`, `0026/0027_pg_graphql_*_exposed` and `0028/0029_*_security_definer_function_executable`. Note: set `pgrst.db_schemas` when running it via plain psql (README).
- **Supabase MCP `get_advisors`** (`supabase-community/supabase-mcp`, Apache-2.0 [2026-09-22], `packages/mcp-server-supabase/src/tools/debugging-tools.ts:244`): `type: 'security'|'performance'`, read-only. Recommended URL form: `https://mcp.supabase.com/mcp?project_ref=<ref>&read_only=true&features=database,docs` (README l.95). Always use `read_only=true` against prod.
- CLI: `supabase db advisors --db-url …` exists (issue #4965, Mar 2026, bug on local custom ports) **[web]** https://github.com/supabase/cli/issues/4965. `--linked`/`--local` flags are **[UNVERIFIED]**.
- `supabase/agent-skills` → `supabase-postgres-best-practices/references/security-rls-*.md` (MIT). REFERENCE for writing policies.

---

## 5. Code, secrets and dependency security

| Tool | Repo / license | Command | Catches | Verdict |
|---|---|---|---|---|
| **claude-security plugin** | `anthropics/claude-plugins-official/plugins/claude-security` v0.11.0, **proprietary** ("All rights reserved") [2026-09-22] | `/plugin install claude-security@claude-plugins-official` → `/claude-security` (Scan codebase / Scan changes / Suggest patches). Needs Python ≥3.9. | Multi-agent threat model → hunt → independent verifiers try to disprove each finding. Writes `CLAUDE-SECURITY-<ts>/CLAUDE-SECURITY-RESULTS.{md,jsonl,sarif}`; patches go to `patches/F<n>.patch` and are never auto-applied. Includes a dedicated secrets pass. | **INSTALL** (best LLM security scan found; cannot vendor) |
| **security-guidance plugin** | same marketplace, v2.0.7 | `/plugin install security-guidance@claude-plugins-official` | Pattern warnings on edits + LLM diff review on Stop + commit reviewer (injection, XSS, SSRF, secrets, 25+ classes) | **INSTALL** (preventive, runs while building) |
| **claude-code-security-review** GH Action | https://github.com/anthropics/claude-code-security-review MIT [2026-02-11] | `uses: anthropics/claude-code-security-review@main` with `claude-api-key`; inputs `exclude-directories`, `claude-model` (default `claude-opus-4-1-20250805`, outdated), `false-positive-filtering-instructions`, `custom-security-scan-instructions`. `/security-review` ships built into Claude Code; a customizable copy is at `.claude/commands/security-review.md`. | PR-diff security review | **INSTALL (CI)**, set `claude-model` to a current model. The README warns it is "not hardened against prompt injection", so use it only for trusted PRs. |
| **gitleaks** | https://github.com/gitleaks/gitleaks MIT [2026-07-22] | `gitleaks git -v .` (history), `gitleaks dir -v .` (files) | Committed keys (Supabase service_role, Stripe, etc.) | **INSTALL** the CLI. The gitleaks-action needs a free `GITLEAKS_LICENSE` for **organization** repos **[web]** https://github.com/gitleaks/gitleaks-action |
| **trufflehog** | https://github.com/trufflesecurity/trufflehog **AGPL-3.0** [2026-09-23] | `trufflehog git file://. --results=verified`, `trufflehog filesystem .` | *Verified* live secrets | **INSTALL** (run as a binary; never vendor, because AGPL) |
| **osv-scanner** | https://github.com/google/osv-scanner Apache-2.0 [2026-09-23] | `osv-scanner scan source -r .` | Known-vuln deps across the full lockfile | **INSTALL** (better than `npm audit`; run both, `npm audit --omit=dev` is free) |
| **OWASP ZAP baseline** | https://github.com/zaproxy/action-baseline Apache-2.0 [2026-09-06] | `uses: zaproxy/action-baseline@v0.15.0` `with: target: <preview URL>`, optional `rules_file_name: .zap/rules.tsv`, `cmd_options: '-a'`, `fail_action`. Docker equivalent: `ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t <url>` | Passive scan: missing CSP/HSTS/X-Frame headers, cookie flags, info leaks | **INSTALL (CI, against Vercel preview only)**. It is passive and safe. Do not run the full/active scan against prod. |
| **Trail of Bits skills** | https://github.com/trailofbits/skills CC-BY-SA-4.0 [2026-09-21] | `/plugin marketplace add trailofbits/skills`. Relevant: `insecure-defaults` (`commands/audit.md`, fail-open defaults with a refuting verifier), `sharp-edges`, `static-analysis` (semgrep/codeql/sarif-parsing), `supply-chain-risk-auditor` (npm install scripts, abandoned deps), `fp-check` (true/false-positive verdicts), `differential-review`, `variant-analysis`, `property-based-testing`, `mutation-testing` | Deep manual-style audits | **INSTALL** a subset (`insecure-defaults`, `supply-chain-risk-auditor`, `fp-check`, `property-based-testing`). Do not vendor (ShareAlike). `entry-point-analyzer` covers smart contracts only, so SKIP it. |
| semgrep plugin | official marketplace (`semgrep/mcp-marketplace`) | `/plugin install semgrep@claude-plugins-official` | SAST | Optional; overlaps with claude-security |

---

## 6. Performance: Lighthouse CI. Verdict: **INSTALL (CI) optional**
- https://github.com/GoogleChrome/lighthouse-ci (Apache-2.0) [**2025-06-25**, slow-moving]. `npm install -g @lhci/cli@0.15.x && lhci autorun` with `lighthouserc` assertions (`docs/getting-started.md` l.71-145). Default `temporary-public-storage` uploads reports publicly, so avoid it for private apps.
- For a no-coder, Chrome DevTools MCP `lighthouse_audit` together with `debug-optimize-lcp` is enough locally. Add LHCI only if you want perf budgets gating PRs.

---

## 7. Generic "QA / tester" subagents

| Source | Path | Verdict | Why |
|---|---|---|---|
| wshobson/agents (MIT) [2026-09-13] | `plugins/ship-mate/agents/qa.md` (tests acceptance criteria + edge cases, writes `qa-report.md`, loops back max 2×; "NO production code editing") and `plugins/ship-mate/agents/playwright.md` | **REFERENCE** | Good *boundaries* pattern (tester never fixes), but tied to the ship-mate pipeline files (`.claude/pipeline/*.md`, `AGENTS.md`). |
| wshobson/agents | `plugins/accessibility-compliance/{commands/accessibility-audit.md,skills/wcag-audit-patterns,skills/screen-reader-testing}`, `plugins/frontend-mobile-security/commands/xss-scan.md`, `plugins/security-scanning/commands/security-hardening.md`, `plugins/developer-essentials/skills/e2e-testing-patterns` | REFERENCE | Checklists. Mine them for the `/harden` prompt. |
| VoltAgent/awesome-claude-code-subagents (MIT) [2026-09-21] | `categories/04-quality-security/{ui-ux-tester,qa-expert,accessibility-tester,penetration-tester,chaos-engineer,test-automator}.md`; `claude plugin marketplace add VoltAgent/awesome-claude-code-subagents` | **REFERENCE** (`ui-ux-tester` has the best persona: "frustrated end-user… messy interactions instead of idealized happy paths") | Generic keyword checklists that reference a "context manager" and a nonexistent `chrome-mcp` tool name. Borrow the persona text only. |
| Jeffallan/claude-skills (MIT) [2026-08-07] | `skills/{test-master,playwright-expert,security-reviewer,secure-code-guardian,chaos-engineer,the-fool}` | REFERENCE (`the-fool` for a pre-mortem of the test plan) | Persona skills; Next.js content pinned to v14. |
| obra/superpowers (MIT) | `skills/verification-before-completion`, `systematic-debugging` | REFERENCE / optional install | Stops "it works" claims made without evidence. |
| qaskills.sh blog lists **[web]** | https://qaskills.sh/blog/best-claude-code-skills-for-testing-2026 | SKIP | Aggregator; not verified. |

---

## 8. Recommended `/harden` stack for a no-coder

**Install once (all INSTALL, nothing vendored except one SQL file):**
1. `npx playwright init-agents --loop=claude --prompts` (planner/generator/healer + `playwright-test` MCP) + `npm i -D @playwright/test @axe-core/playwright fast-check`
2. `npm i -g agent-browser && agent-browser install` + `npx skills add vercel-labs/agent-browser` (for `dogfood`)
3. `claude mcp add chrome-devtools --scope user npx chrome-devtools-mcp@latest`
4. Supabase MCP with `read_only=true` (for `get_advisors`); Supabase CLI (`supabase test db`); vendor basejump `supabase_test_helpers--0.0.6.sql` into `supabase/tests/00000-…sql`
5. `/plugin install claude-security@claude-plugins-official`, `security-guidance@claude-plugins-official`; `/plugin marketplace add trailofbits/skills` → `insecure-defaults`, `supply-chain-risk-auditor`, `property-based-testing`, `fp-check`
6. Binaries: `gitleaks`, `trufflehog`, `osv-scanner`. CI: `zaproxy/action-baseline` against the Vercel preview, `anthropics/claude-code-security-review` (current model)

**`/harden` pipeline (in order, each step writes into `harden-report/`):**
1. **Static gates, fast and deterministic:**
   - `gitleaks git -v .`
   - `trufflehog git file://. --results=verified`
   - `osv-scanner scan source -r .`
   - `npm audit --omit=dev`
   - `npx tsc --noEmit`
   - `next build`
2. **DB gates:**
   - `get_advisors(type:'security')` and `get_advisors(type:'performance')`
   - `supabase db lint --level error`
   - `supabase test db`, with generated pgTAP RLS tests that use `tests.authenticate_as` for owner, other-tenant and anon on every public table
3. **Security LLM scan:** `/claude-security` → Scan changes (or codebase at release), then `fp-check` on anything unclear.
4. **Exploratory bug bash:** `agent-browser skills get dogfood` against `localhost:3000` or the preview URL, with two named sessions (user A and user B) plus anon. The prompt mandates the §3 addendum.
5. **Turn bugs into regression tests:** planner (edge-case addendum) → `specs/*.md` → generator → healer. The seed fixture runs AxeBuilder and a `toHaveScreenshot` for key pages. Add a two-context tenant-isolation spec and double-submit specs. Add fast-check `scheduler`/`commands` tests for server actions.
6. **Perf and a11y pass:** Chrome DevTools MCP `lighthouse_audit` + `performance_*` on the top 3 routes, and `agent-browser a11y --tags wcag2a,wcag2aa`.
7. **Report:** a single `harden-report/SUMMARY.md` with severity and repro steps. Findings are re-verified by a separate subagent (the refute-then-report pattern from claude-security and ToB) before they reach the user.

**Guardrails:**
- Never give browser tests the `service_role` key.
- Run Supabase MCP `read_only=true` against prod.
- Run the ZAP active scan only against preview.
- Keep `.env*` out of agent reads.
- The tester agent does not edit production code; fixes happen in a separate step.

## Sources
- Clones (research workspace): `{microsoft_playwright,microsoft_playwright-mcp,ChromeDevTools_chrome-devtools-mcp,vercel-labs_agent-browser,dubzzz_fast-check,dequelabs_axe-core-npm,anthropics_claude-code-security-review,anthropics_claude-plugins-official,usebasejump_supabase-test-helpers,supabase_splinter,supabase-community_supabase-mcp,supabase_agent-skills,gitleaks_gitleaks,trufflesecurity_trufflehog,google_osv-scanner,GoogleChrome_lighthouse-ci,zaproxy_action-baseline,trailofbits_skills,wshobson_agents,VoltAgent_awesome-claude-code-subagents,Jeffallan_claude-skills,obra_superpowers,anthropics_skills,lackeyjb_playwright-skill}`
- [web] https://playwright.dev/docs/test-agents
- [web] https://github.com/supabase/supabase/blob/master/apps/docs/content/guides/local-development/cli/testing-and-linting.mdx
- [web] https://github.com/supabase/cli/issues/4965
- [web] https://github.com/gitleaks/gitleaks-action
- [web] https://github.com/launchql/supabase-test-suite
- [web] https://github.com/alexanderop/dogfood-qa
- [web] https://qaskills.sh/blog/best-claude-code-skills-for-testing-2026
