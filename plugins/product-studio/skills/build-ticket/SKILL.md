---
name: build-ticket
description: "Build one GitHub ticket in the Code tab with the Superpowers execution engine - classify it (bounded or planned), open a worktree, write and get approval for a plan, execute it test-first with builder-side reviews, open a PR that lists every ruling it made, then hand the PR to /harden for the independent verdict. Also works harden's fix tickets onto the existing PR. Use when the user says \"/build-ticket\", \"byg ticket\", \"byg #12\", \"tag næste ticket\", \"byg den næste\", or askmatt, harden or ship hands a ticket to the Code tab."
---

# Build ticket

The fifth command. `start-project` and `askmatt` decide **what** to build and write tickets; `build-ticket` **builds one ticket**; `harden` judges it. This skill only conducts: the method comes from the vendored Superpowers skills, invoked in order, and this skill supplies the answers they would otherwise ask the human, from `AGENTS.md` ("Execution engine (Superpowers)"). Danish to the user, English in files.

Invoke skills with the Skill tool. Most Superpowers skills here are user-only, so the Skill tool refuses them: then read `../<name>/SKILL.md` and follow it, including its "product-studio note". Agents come from `../../agents/` (not available as a type → a general-purpose subagent with the agent file's body).

**Surface: Code tab only.** It needs git, `gh`, `npm` and a local dev server. In Cowork, don't build: write the Code-tab prompt from `../build-handoff/references/code-tab-prompt.md` and stop.

**Start by showing** this map in Danish and create one task per step:

| # | Trin | Hvad sker der | Skill |
|---|---|---|---|
| 0 | Læs og klassificér | lille (bounded), planlagt eller rettelse | – |
| 1 | Arbejdskopi | egen worktree og gren | using-git-worktrees |
| 2 | Plan | kun planlagt: plan + dit "godkendt" | writing-plans |
| 3 | Byg | test først, review pr. opgave | subagent-driven-development / executing-plans · test-driven-development |
| 4 | PR | beslutninger skrevet i PR'en | requesting-code-review · finishing-a-development-branch |
| 5 | Dom | uafhængig dom, rettelser | /harden · receiving-code-review |

## Parameters

- **Ticket:** `#<n>`, an issue URL, or a local ticket file. None → the first open ticket in the frontier (open, not blocked, lowest number); say which.
- **Base:** `main` by default. When `ship` calls, the release branch `release/vX.Y.Z`.
- **Mode:** normal, or **fix mode** when the ticket came from a `/harden` FIX-FIRST (the fix prompt says `--fix #<pr>`, or the ticket is labelled `harden-fix`). Fix mode works on the existing PR: no new branch, no new PR.

## Step 0: Load and classify

1. Read `AGENTS.md`, the ticket (`gh issue view <n> --json number,title,body,labels`, or the file), the parent spec in `docs/specs/`, `CONTEXT.md`, and the `DESIGN.md` tokens if the ticket touches UI. A ticket that adds or swaps a component, chart or animation also follows `product-studio:ui-sources` (source, `--dry-run` install, restyle to tokens, `docs/design/sources.md`).
2. Classify, and say the class aloud with one reason:
   - **bounded**: an existing flow in this repo, one seam, no schema/RLS/auth change, about 3 files or fewer. Typical of `size:bounded` tickets.
   - **planned**: everything else, including every tracer bullet in a new project and every schema/RLS/auth change. "Bounded" measures the repo, not how familiar the change feels.
   - When in doubt: planned. The ratchet is one-way: complexity found mid-task upgrades bounded → planned (stop, say so, write the plan); nothing downgrades.
   - A **spike** never comes here; `askmatt` sends it to `prototype`.

## Step 1: Worktree

- **Normal:** follow `using-git-worktrees` with its product-studio note: `git fetch origin && git worktree add .worktrees/feat-<n>-<slug> -b feat/<n>-<slug> origin/<base>`, then `npm ci`, copy `.env.local` from the main checkout without printing it, baseline `npm test`. A red baseline stops and asks.
- **Fix mode:** find the PR's worktree (`git worktree list`), or `gh pr checkout <pr>` into `.worktrees/pr-<pr>`. Then `git pull --ff-only` (harden pushed its log commit), `npm ci`, baseline `npm test`.

## Step 2: Plan

**Bounded:** no plan document. The ticket's acceptance criteria are the approved plan. Create the ledger `.superpowers/sdd/bounded-<n>/progress.md` for rulings. Go to step 3.

**Planned:** follow `writing-plans` with these overrides from AGENTS.md:
- Save to `docs/plans/YYYY-MM-DD-<n>-<slug>.md`. No spec file → save the ticket body as `docs/plans/<same-basename>.ticket.md` and point to it.
- `**Spec:**` header = the parent spec path and the issue URL.
- **Global Constraints** = the ticket's acceptance criteria verbatim + AGENTS.md "How to work" rules verbatim.
- **Test seams** = the spec's "Testing Decisions". A new seam needs a ruling.
- **Review Focus** seeded from `../harden/references/test-matrix.md` (other tenant, logged out, empty/loading/error, concurrent edits, long and unicode input) plus the DESIGN.md states, so the corner cases harden hunts are pinned by tests up front.
- UI tasks: each verification step has a `next-dev-loop` check with an `Expected:` line.
- Self-review, then dispatch the skill's `plan-document-reviewer-prompt.md` as a subagent.

**Approval gate.** Show a Danish summary of 10 lines or fewer: the tasks, what the user will be able to see and click, the risky bits, the execution method and why. Link the plan file. Wait for "godkendt". Ticket approval in Cowork is not plan approval. Commit the plan on the branch.

## Step 3: Build

- **Bounded:** follow `test-driven-development` (RED → GREEN → REFACTOR at the ticket's seam), then `verification-before-completion`.
- **Scores, weights and gates** (e.g. a 1–5 rating or a weighted total): pure functions in code, never computed by the model; unit tests plus a property test (`fast-check`: bounded, monotonic where it should be, same input → same score).
- **Planned:** execute the plan with `subagent-driven-development` when it has 4 or more tasks, cross-task interfaces or any schema/RLS/auth change; otherwise `executing-plans`. Both load TDD, verify each task, keep their ledger in `.superpowers/sdd/<plan-basename>/` (git-ignored), and end with one whole-branch review. Per their product-studio note they don't delete the ledger or finish the branch: they return here.
- **Database tests (pgTAP)** need a Docker-compatible runtime even with `--db-url`, so the default is the PR's `db-tests` CI job (`supabase start` + `supabase test db` on GitHub's runner; read it with `gh pr checks`). Optional local loop when a runtime (Docker Desktop, OrbStack, Rancher, Podman or colima) is installed: `supabase start`, `supabase db reset` (never `--linked`), `supabase test db`. Never `supabase db push`. Without a local runtime, RED and GREEN for RLS tests are seen in the `db-tests` job after a push to the branch (`gh run list --branch <branch> --workflow ci.yml`, then `gh run view <id> --log-failed`); pushing the feature branch is allowed.
- **After approval, rule instead of asking.** Ambiguity becomes a ledger line: `Ruling: <what> - <why> - <cost if wrong>`. Stop and ask only at the five stops in AGENTS.md: (1) irreversible or destructive; (2) security beyond what the plan says; (3) side effects outside the worktree (Supabase MCP writes, `supabase db push`, any deploy, editing or closing issues); (4) every path forward is a guess; (5) anything contradicting an ADR, `PRODUCT.md` or `DESIGN.md`.
- Framework-specific code (Next.js, Supabase, shadcn): look it up via Context7 or the official docs, cite the URL, mark anything unverified `UNVERIFIED`.
- TDD exceptions already approved in AGENTS.md: generated code (`shadcn add`, `supabase gen types`, create-next-app), config files, pure styling verified at runtime against DESIGN.md, throwaway spikes. Migrations are not an exception: RLS goes test-first with pgTAP.

## Step 4: Review and PR

1. **Bounded only:** follow `requesting-code-review` once over `$(git merge-base origin/<base> HEAD)..HEAD`, with the ticket body as the requirements. Planned runs already had their whole-branch review. Fix Critical and Important findings test-first; defer Minor ones.
2. **Write the record before the ledger goes.** Write `.superpowers/sdd/<plan-basename or bounded-n>/pr-body.md`: a short summary, `Closes #<n>`, the DoD evidence (test, typecheck, lint and build output), and the sections `## Rulings I made`, `## Deferred minors`, `## Noticed but not touching`, `## Builder-side review (not a verdict)`, copied verbatim from the ledger and the executor's final message.
3. Add 3 lines to `docs/log.md` and commit them (`docs: log #<n>`). The working tree must be clean: harden refuses a dirty snapshot.
4. **Open or update the PR:**
   - **Normal:** follow `finishing-a-development-branch` with its product-studio note: full suite green, then Option 2 with `gh pr create --base <base> --body-file <pr-body.md>`. Never merge locally. Keep the worktree.
   - **Fix mode:** push to the existing PR's branch, and append the fix sections to its body (`gh pr view <pr> --json body -q .body`, add, `gh pr edit <pr> --body-file <file>`) with `Closes #<fix>` for each fix ticket.
   - **No GitHub remote:** keep the branch, save the body as `docs/plans/<basename>.pr.md`, commit it; harden then targets `HEAD` against `main`.
5. Delete the ledger folder (`.superpowers/sdd/<…>/`) only now. Show the user the PR link and the Vercel preview URL.

## Step 5: The verdict

1. Offer `/harden #<pr>`. It may run in this session: harden's inspector is the independent context (L3 another model, or L2 an isolated agent), and the builder never approves. The builder-side reviews above are evidence, never a verdict.
2. **FIX-FIRST:** the fix prompt starts `/build-ticket --fix #<pr>` for each fix ticket. First follow `receiving-code-review` with its product-studio note: verify each finding against the code; a finding you believe is wrong gets a PR comment with evidence for the next inspector; never drop one yourself. Then each fix runs as step 3, failing test first. Harden's confirmed findings count as the approval, so no second "godkendt" is needed. A fix spanning more than one seam, 3+ fix tickets, or any schema/RLS/auth fix → a `docs/plans/…-fix-r<k>.md` plan, method per step 3. Push, then `/harden #<pr>` again. At most 2 rounds (harden's rule).
3. **SHIP → merge on GitHub** (the user clicks, or approves the merge). Then remove only the `.worktrees/*` worktree this skill created, and take the next frontier ticket.

Parallel tickets can run in parallel Code-tab sessions, each in its own worktree. Never run two builders in one worktree.

## When something goes wrong

- The run looped, ignored the plan, or cost far too much → `/diagnosing-superpowers` on this session.
- A test is hard to write → read `../test-driven-development/writing-good-tests.md`.
- A bug appears mid-build → `product-studio:systematic-debugging`, then back to the step you were on.
