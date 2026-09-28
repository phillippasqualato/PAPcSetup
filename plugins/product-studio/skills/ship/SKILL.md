---
name: ship
description: Finish a product properly and make it ready for real users - closes the scope against PRODUCT.md, sweeps out unfinished code, checks every go-live item (production data and backups, domain, auth and email, security, monitoring, performance, SEO, GDPR and legal), writes the handover docs, runs a final full-scope harden on the exact release candidate, releases with a tag and a rollback path, smoke-tests production, and ends with a retrospective. Use when the user says "/ship", "lancere", "lancering", "afslut projektet", "gør det klar til lancering", "færdiggør produktet", "vi skal i produktion", "go live", "er det klar til at gå live".
---

# Ship

The fourth master workflow: `start-project` begins, `askmatt` changes, `harden` judges, **`ship` finishes.** It conducts the professional skills and agents in a fixed order with gates, and never skips the independent verdict. Danish to the user, English in files.

Invoke skills with the Skill tool (user-only and refused → read `../<name>/SKILL.md` and follow it). Dispatch agents from `../../agents/` with the Agent tool (not available as a type → general-purpose subagent with the agent file's body), telling them the repo location, the preview/production URL, the exact output paths you want, and a run folder outside the repo.

**Start by showing the map** in `references/workflow-map.md` (one short table) and create one task per phase.

**Surfaces.** Cowork can run phases 0, 1 and 3's review parts. Everything that touches git, builds, tests or tags (phases 2, 3's fixes, 4, 5, 6, 7) runs in the **Code tab**; from Cowork, hand those over with a prompt. The launch is never declared done from Cowork alone.

**The release branch.** All release work happens on a branch `release/vX.Y.Z` with one PR into `main`. Fixes, docs and harden's log commits land on that PR, so a protected `main` with harden's CI gate stays consistent.

## Phase 0: Where are we?

Load the truth (`AGENTS.md`, `PRODUCT.md`, `CONTEXT.md`, `docs/tech.md`, `docs/toolchain.md`, `DESIGN.md`, `docs/log.md`, recent `PLAN-REVIEW-LOG.md` entries) and the state (open PRs, open issues by label, CI on `main`, production URL, existing release tags). Tell the user in ≤8 lines: what's built vs the MVP scope, what's open, the last harden verdict, and the version this release will be (e.g. `v1.0.0`).

## Phase 1: Close the scope (with the user)

1. For each MVP job and success criterion in `PRODUCT.md`: done / partly / not done, with evidence (a ticket, a PR, a screen).
2. Every open ticket: **must-have for launch**, **post-launch** (label `post-launch`), or **drop** (close with the reason), in one `product-studio:grilling` round with recommendations. The user decides.
3. Must-haves that aren't done go through `product-studio:build-handoff` as tickets; ship pauses until they're merged with a SHIP verdict (`askmatt` → Code tab → `harden`). Then create `release/vX.Y.Z` from `main` and open the release PR.

## Phase 2: Completion sweep (Code tab, on the release branch)

In parallel, read-only passes whose findings become tickets on the release PR:
- `product-studio:placeholder-scan` on the whole repo plus its grep list (TODOs, stubs, mock data, lorem ipsum, debug logs, test emails, leftover flags).
- `code-simplifier` and `comment-analyzer` agents on the code changed since the last release tag, or since the first commit for a first release.
- `product-studio:improve-codebase-architecture` (skill) for anything that will hurt the first post-launch changes; report only, big refactors are post-launch.
- `design:ux-copy` (if installed) on the core jobs' user-facing strings; impeccable `audit` on the key screens.
Blocker/critical findings on production paths are fixed on the release branch before phase 3 ends. Every fix goes through `product-studio:build-ticket` in fix mode on the release PR (base `release/vX.Y.Z`; commits land on that PR, no new branch or PR; test first, rulings in the PR body).

## Phase 3: Production readiness

Optionally start with `product-studio:audit-loop --measure-only` for a go-live scoreboard. Dispatch `launch-readiness-auditor` with `references/launch-checklist.md` (plus `../observability-and-instrumentation/references/observability-checklist.md` for §6 and `../performance-optimization/references/performance-checklist.md` for §7), the release PR's preview URL, the production settings it can reach and the connectors/CLIs available. In the Code tab, also dispatch `web-performance-auditor` (Quick mode; Deep mode if a DevTools MCP is set up) on the top 3 routes of the preview. A Lighthouse/Core Web Vitals FAIL goes to `product-studio:performance-optimization` as a fix ticket. Verify every FAIL item yourself before accepting it. Split the result:
- **Agent fixes** (code/config: headers, rate limits, `sitemap.xml`, error pages, Sentry wiring) → fixed on the release branch in the Code tab.
- **User actions** (domain DNS, Supabase production project, backups/PITR and auth URLs, email DNS records, DPAs, spend limits, uptime monitor) → one numbered Danish checklist with exact links and clicks. Offer connectors (`SuggestConnectors`) where they'd let an agent verify the setting.
Every ★ item must be PASS, or explicitly accepted by the user in writing (logged), before phase 5. ★ items that can only be proven in production are checked on the release preview now and again in phase 6.

## Phase 4: Handover docs (Code tab, on the release branch)

Dispatch `technical-doc-writer` with explicit paths (they override its default layout): `README.md` (what it is, run locally, deploy), `docs/runbook.md` from `references/runbook-template.md`, and the as-built architecture section of `docs/tech.md`. Then update `PRODUCT.md` (what ships, what's post-launch), `docs/toolchain.md` (re-run `toolchain-auditor` if tools changed), `DESIGN.md` (impeccable `document` scan mode if the system drifted), add the `CHANGELOG.md` entry (Keep a Changelog groups: Added, Changed, Fixed, Removed, Security; the version comes from the tag) and release notes (plain Danish for users, English in the repo), and run `product-studio:claude-md-improver` on `AGENTS.md`. Commit everything on the release branch.

## Phase 5: Final harden on the release candidate (Code tab)

Only now, with every fix and doc committed, run `product-studio:harden` on the release PR with scope **go-live** (diff base: the last release tag, or the first commit for a first release). Ship is stricter than a normal harden: independence **L2 or L3** (L1 is not enough), **all six stages ran** (no accepted NOT RUN), and `claude-security` Scan codebase if that plugin is installed. Only **SHIP** continues. FIX-FIRST uses harden's fix rounds on the release branch and then this phase runs again; BLOCKED stops ship and goes back to the user. Any commit after this SHIP other than harden's own log commit means phase 5 runs again.

## Phase 6: Release (Code tab; the user approves the moment)

1. Go/no-go screen: harden SHIP for the release PR's head, every ★ item PASS or accepted, CI green. Wait for "godkendt".
2. Merge the release PR (Vercel deploys production from `main`). Then tag the merge commit on `main` as `vX.Y.Z` and create the GitHub release with the notes.
3. Smoke-test production with `product-studio:visual-qa` on each core job, as two named internal smoke accounts (A and B in different organisations, for isolation). Afterwards delete them, or keep them flagged as internal and excluded from analytics, and record which.
4. Check error tracking and uptime receive signals, and watch the first minutes of logs.
5. Broken in production → roll back first (Vercel instant rollback to the previous production deployment; for a first launch, the documented fallback in the runbook), then `askmatt` (bug route). Record it.

## Phase 7: Wrap-up (Code tab)

1. On a branch `chore/ship-vX.Y.Z`, append a `## SHIP vX.Y.Z` entry to `PLAN-REVIEW-LOG.md` (release commit, tag, harden run-id, launch-checklist result, accepted risks in the user's words, rollback path proven or documented) and a `docs/log.md` entry; open it as a log-only PR (the CI gate accepts commits that touch only `PLAN-REVIEW-LOG.md`, `harden/` and `docs/log.md`).
2. Run `product-studio:retro` in the Code tab on the release sessions: improvements to the agents' environment; accepted ones become `post-launch` tickets. If a build-ticket run looped, ignored its plan or cost far too much, add `/diagnosing-superpowers` on that session.
3. Order the post-launch backlog and propose the first 3 with `askmatt`.
4. Tell the user in ≤8 Danish lines: what shipped, where it lives, what to watch this week, and the first post-launch step.
