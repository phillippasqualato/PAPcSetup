# Harden tooling (install once per repo, in the Code tab)

Research and sources: `../../define-toolchain/references/qa-research.md`. Put these steps into a "harden tooling" ticket when they're missing.

## Dev dependencies
```bash
npm i -D @playwright/test @axe-core/playwright fast-check
npx playwright install --with-deps chromium
npx playwright init-agents --loop=claude --prompts   # writes .claude/agents/playwright-test-{planner,generator,healer}.md, .mcp.json entry "playwright-test", specs/, seed.spec.ts
```
- Merge the `playwright-test` entry into the existing `.mcp.json` (don't overwrite it) and add it to `docs/toolchain.md`.
- Put Supabase test-user login in the seed test's fixtures and save `storageState` per role: `tests/.auth/userA.json`, `userB.json` (git-ignored).
- Add to the planner prompt: "For every feature include: empty/max-length/unicode/emoji/RTL inputs, back-button and refresh mid-flow, two tabs, logged-out access by URL, another tenant's ID in the URL, slow/failed network, and double submit."
- Seed fixture runs `new AxeBuilder({ page }).withTags(['wcag2a','wcag2aa','wcag21aa','wcag22aa']).analyze()` and `expect(page).toHaveScreenshot()` on key pages; generate baselines in CI (Linux), not on the Mac.
- Regenerate the Playwright agents after every Playwright upgrade.

## Browser bug-bash
```bash
npm i -g agent-browser && agent-browser install
```
The vendored `dogfood` skill drives it (named sessions per role, `a11y`, `network route --abort`, `diff screenshot`). For protected Vercel previews: `agent-browser skills get protected-vercel-deployments`.

Optional: Chrome DevTools MCP for performance and Lighthouse: `claude mcp add chrome-devtools --scope project npx chrome-devtools-mcp@latest --isolated`. Pick it **or** Playwright MCP for ad-hoc exploration, not both.

## Database
- Tests: `supabase test db` always needs a Docker-compatible runtime (it runs pg_prove in a container, even with `--db-url`). Default: the `db-tests` CI job (`supabase/setup-cli@v1` → `supabase start -x studio,imgproxy,vector,logflare,mailpit` → `supabase test db`) on GitHub's runner; no Docker on the Mac. Optional local: Docker Desktop, OrbStack, Rancher, Podman or colima with ≥7 GB RAM free, then `supabase start` + `supabase db reset` (never `--linked`). Source: https://supabase.com/docs/reference/cli/supabase-test-db
- Supabase CLI linked to the **dev** project read-only for advisors.
- Copy `../assets/00000-supabase_test_helpers.sql` to `supabase/tests/00000-supabase_test_helpers.sql` (basejump helpers, MIT).
- RLS tests from `pgtap-rls-template.sql`, one file per table group.
- Advisors: Supabase MCP `get_advisors` (read-only) or `supabase db advisors`.

## Security and secrets (binaries, not vendored)
```bash
brew install gitleaks osv-scanner trufflehog semgrep   # macOS
```
Semgrep CE (LGPL-2.1, free, no account): `semgrep scan --config p/default --error --metrics=off` locally and in CI (container `semgrep/semgrep`, `if: (github.actor != 'dependabot[bot]')`). Not `semgrep ci`: without a token it prints "run semgrep login" and exits 0. Not `--config auto`: it requires metrics. Verified 2026-09-23 (Semgrep 1.177.0). `scripts/floor-guard.mjs` comes from `constraint-driven-development/references/floor-guard.md` (written by build-handoff ticket 01).
Code-tab plugins: `/plugin install claude-security@claude-plugins-official` (deep scan before launch), `security-guidance@claude-plugins-official` (always-on); Trail of Bits: `/plugin marketplace add trailofbits/skills` → `insecure-defaults`, `supply-chain-risk-auditor`, `fp-check`, `property-based-testing` (CC-BY-SA: install, don't copy).

## Cross-provider inspection (L3)
Codex CLI and Claude Code CLI both installed and authenticated on the Mac (`codex --version`, `codex login status`, `claude --version`, `claude auth status`), Python 3.10+. The vendored `claudex-loop` runner lives at `../../claudex-loop/scripts/runner.py`; read `../../claudex-loop/references/runtime.md` before first use. Keep claudex diagnostics outside the repo.

## CI (optional, recommended before launch)
- `ci-gate.yml` (this folder) as a required check: blocks merges to `main` without a SHIP entry for the head SHA.
- OWASP ZAP baseline against the preview URL only: `zaproxy/action-baseline`.
- Typecheck/lint/test/build, `semgrep scan --config p/default --error --metrics=off`, the `db-tests` job (setup-cli → `supabase start -x …` → `supabase test db`), `node scripts/floor-guard.mjs --base origin/${{ github.base_ref }}` (checkout with `fetch-depth: 0`, or it can't find the merge base) and `npx playwright test` on every PR; upload the Playwright report as an artifact on failure; `dependabot.yml` for npm and GitHub Actions (one package per PR, read the changelog).
- Optional: `npx impeccable detect --json src/` (free, deterministic design detector).

## Repo hygiene
- Add to `.gitignore`: `harden/**/*.png`, `harden/**/*.webm`, `harden/**/videos/`, `dogfood-output/`, `tests/.auth/`. Do this in the tooling ticket, never during a harden run (the log commit must touch only `PLAN-REVIEW-LOG.md` and `harden/`).

## Guardrails
- Tests never get the secret/service-role key except in setup code that creates test users.
- Supabase MCP stays `read_only=true`; never point harden at production data with writes.
- ZAP active scans only against previews.
- `.env*` never read into agent conversations.
