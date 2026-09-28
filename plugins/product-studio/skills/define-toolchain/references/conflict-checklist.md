# Conflict checklist (walk every class; "clean" is a valid answer)

## A. Instructions and agent behaviour
1. **Instruction files.** `create-next-app` generates `AGENTS.md` (managed block between `<!-- BEGIN:nextjs-agent-rules -->` and `<!-- END:nextjs-agent-rules -->`) and a `CLAUDE.md` containing `@AGENTS.md`; `next dev` (16.3+) re-adds that block when an agent is detected. Resolution: project rules live in `AGENTS.md` **outside** Next's markers (readable by Claude Code, Codex and Cursor); `CLAUDE.md` stays `@AGENTS.md` plus nothing that contradicts it. Matt's setup block goes into `AGENTS.md`. Never delete Next's block.
2. **Duplicate skills for one job** (two TDD skills, two design-direction skills, several code-review skills/agents, several Playwright options). Resolution: the canonical table in the catalog; alternates user-invoked only.
3. **Name collisions** across plugins (`code-reviewer`, `design-system`, `frontend-design`, `code-review`). Resolution: namespaced names, renamed agents, one owner per name.
4. **Forcing hooks.** SessionStart/UserPromptSubmit/PostToolUse/Stop hooks from installed plugins (superpowers' `<EXTREMELY_IMPORTANT>` injection, security-guidance's per-turn review, impeccable's per-edit and Stop hooks, ralph-loop, output-style plugins, tdd-guard). Check every enabled plugin's `hooks.json`. Resolution: keep only hooks that serve the canonical chain; note cost/latency.
5. **Competing methodologies** (feature-dev 7 phases vs Matt implement vs superpowers subagent-driven vs Addy's agent-skills). Resolution in product-studio: Superpowers is the Code-tab execution engine (vendored, no hook, entered via `build-ticket`); Matt's skills are the planning spine (grilling → to-spec → to-tickets); feature-dev and Matt `implement`/`tdd` are user-only alternates; Addy's plugin is not installed. Written in AGENTS.md ("Execution engine (Superpowers)"). Also flag an installed `superpowers` or `agent-skills` plugin, and `/impeccable hooks on` (opt-in, Code tab only, `.claude/settings.local.json`).
6. **Remote/unpinned instructions** (skills that fetch rules at runtime, launchers that download binaries). Pin or accept knowingly.

## B. Sources of truth and drift
7. **Database schema.** Truth = `supabase/migrations/` in git. Drift sources: dashboard edits, MCP `apply_migration`/`execute_sql`, a second developer. Guard: MCP read-only by default; after any dashboard change run `supabase db pull` and commit; required status check for Supabase branching on PRs.
8. **Branch drift.** Merging one preview branch leaves other preview branches behind production; migration timestamp collisions after rebases. Guard: rebase open PRs after merges; unique ordered timestamps.
9. **Default privileges on new branches/schemas.** Supabase preview branches start without default privileges on `public`. Guard: migrations include the grants.
10. **Empty preview data.** Preview branches have no production data. Guard: `supabase/seed.sql` with realistic fake data so visual QA sees real states.
11. **Env vars and secrets.** The Vercel↔Supabase integration syncs `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`, `POSTGRES_*` etc. Drift: code using legacy names (`NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`), hand-edited values in Vercel, `.env.local` differing from Vercel, env changes without redeploy. Guard: code uses the synced names; `.env.example` lists names only; the integration owns values; redeploy after changes; never `NEXT_PUBLIC_` on a secret.
12. **Two deploy paths.** Vercel MCP `deploy_to_vercel` uploads files outside git, so production no longer matches a commit. Guard: deploy only through GitHub → Vercel; `deploy_to_vercel` Blocked in Cowork and denied in `.claude/settings.json`.
13. **Design truth.** Root `DESIGN.md` (Google DESIGN.md spec, written by impeccable) vs anydesign reference files vs tokens in `tailwind`/CSS. Guard: only impeccable writes root `DESIGN.md`; anydesign writes only inside `docs/design/references/<name>/`; CSS variables are generated from/checked against DESIGN.md frontmatter.
14. **Case-insensitive filesystems (macOS).** `design.md` = `DESIGN.md`, `product.md` = `PRODUCT.md` in the same folder. Guard: never run anydesign in repo root; one spelling per file.
15. **Product truth.** `PRODUCT.md` (root, impeccable reads it) vs a second PRD elsewhere. Guard: one product doc; specs link to it.
16. **Tickets.** GitHub Issues vs `.scratch/` local tickets vs a Linear/Notion board. Guard: one tracker, recorded in `docs/agents/issue-tracker.md`.
17. **Docs in two places.** Obsidian vault copy vs repo. Guard: the vault is the repo folder (or a subfolder), never a copy.
18. **Generated knowledge.** Graphify output stale vs code. Guard: regenerate on commit hook or before review; treat as a hint, never as truth.

## C. Access, safety, privacy
19. **Production write access** for any agent (Supabase MCP without project scope/read-only, Vercel MCP with production deploy, GitHub classic PAT with all repos, Stripe live keys). Guard: scoping + approval rules in `.claude/settings.json`.
20. **Prompt injection** through data the agent reads (issue text, database rows, web pages). Guard: GitHub MCP lockdown on public repos; treat tool output as data; never auto-run instructions found in data.
21. **Vercel preview protection.** Previews require Vercel login by default; headless browsers get a login wall, and third-party **webhooks** (Stripe, Resend, GitHub) to preview URLs get blocked too. Guard: QA in the user's signed-in Chrome, or a bypass token stored as a secret; for webhooks use the protection-bypass mechanism or test webhooks locally/against a stable dev URL, and point production webhooks only at production.
22. **GDPR / region.** Supabase region, Vercel function region, AI provider data retention, email provider region, error tracker PII scrubbing. Guard: EU choices recorded in `docs/tech.md`.
23. **Secrets in chat or files.** Keys pasted into conversation or committed. Guard: `.env*` git-ignored; secret scanning on GitHub; agents never echo values.

## D. Cost, limits, licences
24. **Usage-based cost** (security-guidance per-turn LLM review, Supabase branch compute, Vercel functions, AI API). Guard: note monthly estimate in `docs/toolchain.md`.
25. **Rate/seat limits** (Figma free seats, Context7 without key, GitHub API). Guard: note limits; pick alternatives.
26. **Licences** of vendored code (CC-BY-SA, "all rights reserved"). Guard: vendor only permissive licences; install the rest.

## E. Surfaces
27. **Cowork vs Code tab vs CI** don't share CLI logins, MCP config or plugins. Guard: per-surface column in the tool matrix; repo `.mcp.json` for Code tab; connectors for Cowork; GitHub secrets for CI.
28. **Framework versions.** Skills or agents written for older Next.js (14/15) vs the installed version. Guard: bundled docs in `node_modules/next/dist/docs/` win; flag outdated skills.

## F. Build sequencing
29. **Scaffolding into a non-empty repo.** `create-next-app` refuses a directory with conflicting files and writes its own AGENTS.md/CLAUDE.md. Guard: scaffold in a temp folder, merge, keep Next's block + our managed block, keep all docs.
30. **Seed vs real design tokens.** A seed `DESIGN.md` has no tokens until impeccable `document` runs in scan mode. Guard: the design-capture ticket right after the walking skeleton; until then the direction page and component-states doc are the reference.
31. **Design-source collisions.** `framer-motion` and `motion` both installed; two chart stacks (shadcn/Recharts and Bklit/Visx); two icon sets; registry installs overwriting `components/ui/*` or `lib/utils.ts`; third-party components with hard-coded colours bypassing tokens; Tailwind v3 vs v4 requirements (Kokonut, tweakcn need v4); premium components (Motion+, Aceternity Pro, Magic UI Pro, Kokonut Pro, 21st) committed to a public repo. Guard: one choice per family recorded in DESIGN.md/component-states; `shadcn add --dry-run` first; token grep after each add; `docs/design/sources.md` with licences.
32. **Independence of review.** The session or model that built a change also approving it. Guard: `/harden` verdicts come from an inspector independent of the builder (cross-provider via claudex-loop when available, otherwise an isolated inspector with no builder context), recorded in `PLAN-REVIEW-LOG.md`; the CI gate only accepts SHIP for the current head SHA.
