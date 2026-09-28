# AGENTS.md template

Fill every `<...>`. Keep the managed block under ~150 lines; link to docs instead of copying them. Next.js's own block (`<!-- BEGIN:nextjs-agent-rules -->` … `<!-- END:nextjs-agent-rules -->`) stays above ours, untouched, once create-next-app or `next dev` has written it; before the app is scaffolded, write only our block (never fake Next's markers). Content outside both blocks belongs to the user.

```markdown
(Next.js's block goes here once the app is scaffolded, exactly as Next.js writes it)

<!-- product-studio:managed:start -->
# <Product name>

<one-liner from PRODUCT.md>

## Read before any task
1. `CONTEXT.md`: domain language. English terms in code, tables and commits; in the UI use the Danish word recorded next to each term (UI language: <da/en>).
2. `PRODUCT.md`: what and why. Build nothing that isn't traced to it or a ticket.
3. `docs/tech.md` + `docs/adr/`: architecture. Don't contradict an ADR; propose a new one.
4. `DESIGN.md` (+ `.impeccable/design.json` once captured): the design system. While DESIGN.md is still a seed, use the palette/type values in its prose, `docs/design/direction.html` and `docs/design/component-states.md`; once tokens exist, use tokens only. No ad-hoc colours, sizes, radii or shadows.
5. `docs/toolchain.md`: which tool for which job, MCP scopes, golden rules.
6. If `graphify-out/GRAPH_REPORT.md` exists, read it before opening many files.
7. The ticket you're working on.

## Stack
<layer | choice, from docs/tech.md>. Supabase region: <region>. Vercel project: <name>. Production branch: `main`.

## How to work
- One ticket at a time, via `/build-ticket #<n>` (the Superpowers execution engine, see below), on `feat/<n>-<slug>`, ending in a PR with `Closes #<n>`.
- Vertical slices: schema → server → UI → test for one behaviour, then the next.
- Test-first at the seams the spec agreed (red → green → refactor); exceptions below.
- Framework-specific code (Next.js, Supabase, shadcn): check the current docs via Context7 or the official site, cite the URL in the PR, mark anything unchecked `UNVERIFIED`.
- Read `CONSTRAINTS.md` before writing code. Do not weaken it to make a change pass.
- Verify at runtime with `next dev` (and the `next-dev-loop` skill / `/_next/mcp` if available), not only with the type checker.
- Database changes only as migrations in `supabase/migrations/`; RLS on every new table, policies matching docs/tech.md; include default-privilege grants. Never edit schema in the dashboard.
- Env vars: use the names the Vercel↔Supabase integration syncs (`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`); never a secret with `NEXT_PUBLIC_`; never read or print `.env*` values.
- Never deploy directly (no Vercel MCP deploys, no `vercel --prod`); GitHub → Vercel does it.
- Simplicity first: the minimum code that solves the ticket; no speculative features, abstractions or configuration nobody asked for. Surgical changes: every changed line traces to the ticket; match the existing style; remove only what your change made unused.
- Scores, weights and gates are pure functions with unit and property tests; the model never computes a score.
- Background jobs and AI fan-out follow the *Background work* section of `docs/tech.md` (tenant from the run row, never the payload; budget checked before the run).
- New packages: check they exist and are the intended one before installing (`npm view <pkg> name repository time.created`); a package younger than 30 days or without a repository needs the user's OK (agents invent plausible names).
- Small commits, clear messages (`feat:`, `fix:`, `chore:`, `docs:`, `test:`). No refactors outside the ticket; list them in the PR under "Noticed but not touching".
- Before plan approval: ask. After plan approval: rule and write it in the ledger, stopping only at the five stops below. For `size:bounded` tickets the acceptance criteria are the approved plan: rule, and ledger in `.superpowers/sdd/bounded-<n>/progress.md`.
- Database tests (pgTAP) need a Docker-compatible runtime even with `--db-url`, so the default is the PR's `db-tests` CI job (`supabase start` + `supabase test db` on GitHub's runner; read it with `gh pr checks`). Optional local loop when a runtime (Docker Desktop, OrbStack, Rancher, Podman or colima) is installed: `supabase start`, `supabase db reset` (never `--linked`), `supabase test db`. Never `supabase db push`.

## Execution engine (Superpowers)
- Worktrees: yes, `git worktree add .worktrees/feat-<n>-<slug> -b feat/<n>-<slug> origin/main` (no native worktree tool); harden fix rounds reuse the PR's worktree (`/build-ticket --fix #<pr>`). Setup: `npm ci`, copy `.env.local` from the main checkout (never print it), baseline `npm test`.
- Plans: `docs/plans/YYYY-MM-DD-<n>-<slug>.md` (historical, never edited after merge). Specs: `docs/specs/`. Never `docs/superpowers/`.
- Every plan: `**Spec:**` = the parent spec + the issue URL; Global Constraints = the ticket's acceptance criteria + the "How to work" rules above, verbatim; Review Focus seeded from harden's test matrix (other tenant, logged out, empty/loading/error, concurrent edits, long and unicode input) and the DESIGN.md states.
- Plan approval: a Danish summary of 10 lines or fewer + the user's "godkendt". Approving a ticket is not approving a plan.
- Execution method: subagent-driven when the plan has 4+ tasks, cross-task interfaces or any schema/RLS/auth change; otherwise inline (executing-plans). Bounded tickets (`size:bounded`) skip the plan document.
- Pre-approved TDD exceptions: generated code (`shadcn add`, `supabase gen types`, create-next-app), config files, pure styling verified at runtime against DESIGN.md, throwaway spikes. Migrations are not an exception: RLS goes test-first with pgTAP.
- Finishing a branch: always option 2, push and create a pull request against `main`. Never merge locally. Keep the worktree until the merge.
- The PR body carries `## Rulings I made`, `## Deferred minors`, `## Noticed but not touching` and `## Builder-side review (not a verdict)`.
- The five stops (ask, don't rule): (1) irreversible or destructive: a migration that drops or rewrites data, force-push, `supabase db reset` on a linked project; (2) security beyond the plan: a new RLS policy, grant, auth or key handling; (3) side effects outside the worktree: Supabase MCP writes, `supabase db push`, any deploy, editing or closing issues; (4) every path forward is a guess; (5) anything contradicting an ADR, `PRODUCT.md` or `DESIGN.md`.
- Builder-side reviewers (task reviewers, the final whole-branch review) are evidence, not a verdict. Only `/harden`, run in another context, gives the verdict.

## Tools for this repo
<from docs/toolchain.md: the canonical skill/agent/MCP per job, e.g. "Supabase questions: supabase skill; reviews: code-review + supabase-security-reviewer; browser checks: Playwright MCP">

## Definition of done (evidence, not claims)
- [ ] Typecheck, lint, tests pass (output pasted in the PR)
- [ ] `next build` succeeds
- [ ] Migrations apply on a fresh database; seed data updated if the UI needs it; config, flags and env vars accounted for
- [ ] A change to an existing column or table that deployed code reads never ships with its dependent code (expand → migrate → contract); new tables may ship with their first code; destructive changes have reverse SQL in `supabase/rollbacks/`
- [ ] Planned tickets: plan executed (subagent-driven or inline) with a clean final whole-branch review; bounded tickets: one builder-side review; Rulings and Deferred minors in the PR body; for data changes, `supabase-security-reviewer` clean
- [ ] `floor-guard` clean: no skipped tests, removed assertions, new suppressions or lowered thresholds
- [ ] Vercel preview loads; changed flow clicked through at desktop and mobile width; screenshots in the PR
- [ ] UI matches DESIGN.md including hover, focus, empty, loading and error states
- [ ] Acceptance criteria ticked one by one
- [ ] `docs/log.md` entry (3 lines: what changed, surprises, next)
- [ ] `/harden` verdict **SHIP** for the PR's head commit in `PLAN-REVIEW-LOG.md`, from an inspector that isn't you. Never write or edit a verdict by hand: only a `/harden` run writes it, from the independent inspector's result; on FIX-FIRST fix the tickets it creates (failing test first) and run `/harden` again, at most 2 rounds, then stop and ask.

## Agent skills
<!-- setup-matt-pocock-skills writes Issue tracker / Triage labels / Domain docs here -->
<!-- product-studio:managed:end -->
```

CLAUDE.md:

```markdown
@AGENTS.md
```
