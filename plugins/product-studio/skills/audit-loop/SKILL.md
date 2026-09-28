---
name: audit-loop
description: "Continuous quality loop over every aspect of a product - accessibility, performance, app security, data and RLS, design conformance, UX flows, copy and language, SEO, code health, and (weekly) production errors - that measures each with a fixed tool, has an independent judge find what's wrong, turns confirmed findings into a few fix tickets, lets build-ticket and harden fix them, measures again, and stops by hard rules (max rounds, no progress, regressions, loosened checks). Keeps a Danish scoreboard (kvalitetstavle) and can run weekly. harden stays the only merge gate. Use when the user says \"/audit-loop\", \"audit alt\", \"gennemgå alt\", \"test alt\", \"kør et audit-loop\", \"kvalitetstavle\", \"hvordan står det til med kvaliteten\", \"løbende forbedring\", \"tjek det hver uge\"."
---

# Audit loop

`harden` answers **"may this commit ship?"** with one verdict. `audit-loop` answers **"how good is each part of the product, and let's raise it"**, round by round. It reuses harden's agents, `finding-verifier`, severity scale, independence levels and run-folder discipline, and it never edits product code itself: fixes are tickets, built by `build-ticket`, judged by `/harden`. Danish to the user, English in files.

Invoke skills with the Skill tool (user-only and refused → read `../<name>/SKILL.md`). Agents come from `../../agents/` (not available as a type → a general-purpose subagent with the file's body). Never use a Stop-hook loop (`ralph-loop`) or an in-session `/loop` for this: rounds are counted and stopped by this skill, from files.

**Start by showing** the scoreboard from the last run (`docs/audit/SCOREBOARD.md`) if one exists, then the plan for this run in ≤6 Danish lines: which areas, how many rounds at most, roughly how many fix PRs that could mean. The user's "godkendt" to this plan is the run's budget.

## Modes

- `/audit-loop` (default): measure → judge → verify → scoreboard → at most 3 tickets per area → ask "skal jeg starte fix-runderne?"
- `/audit-loop <område…>`: only those areas (e.g. `tilgængelighed performance`).
- `/audit-loop --fix` (Code tab): runs the fix rounds.
- `/audit-loop --measure-only`: the weekly scheduled run; tickets at most the top 3 per area, never builds.

## One round per area

For each area in `references/dimensions.md`:
1. **Measure** with the pinned tool and config from `references/measure/` (never the repo's own config, which a fix could loosen), against the PR preview or production, over the same routes × roles × mobile/desktop × light/dark every time. Roles use the test users and saved logins from harden's setup (`../harden/references/stack-setup.md`: `tests/.auth/userA.json`, `userB.json`, plus logged out); no test users yet → the role-dependent areas are `IKKE MÅLT` with one setup ticket. Protected Vercel previews: the bypass header from a secret, never logged. Save `<run folder>/<area>/measure.json`: `{metric, value, unit, source, runs, suppressed_count}`. Tool missing → the area is `IKKE MÅLT` plus one install ticket; it never shows green.
2. **Judge**: the area's judge agent gets only artifacts (measurements, screenshots, `DESIGN.md`, `PRODUCT.md`, `CONSTRAINTS.md`), never the builder's reasoning.
3. **Verify** every finding with `finding-verifier`. Only CONFIRMED counts; NEEDS-HUMAN becomes one `grilling` round; FALSE-POSITIVE is logged.
4. **Ticket**: group by root cause via `build-handoff` (small-change mode), labels `audit-loop` + `area:<name>`, at most 3 per area per round. Each ticket states the measured value now and the target ("axe color-contrast på /dashboard: 7 → 0"), and its failing test (an axe, Lighthouse or Playwright assertion for UI areas).
5. **Build** (Code tab, only in `--fix`): `build-ticket` → PR → `/harden` scoped to the area. harden's SHIP is still the only way to merge.
6. **Measure again** on the PR preview. Keep the change only if the target improved beyond the noise band and no other area got worse; otherwise the PR isn't merged and the ticket gets the evidence.

A blocker (a verified secret, data visible across tenants, a broken core flow) exits the loop at once: `/harden` plus a fix ticket. Blockers are never "improved slowly".

## Stop rules (checked from files, never from the builder's claim)

| Rule | When | Result |
|---|---|---|
| Pass | the tool's bar is met and the judge has no confirmed blocker/major | `GRØN`, area done |
| Max rounds | a round = one pass over every area that isn't green; an area stops at its cap in `dimensions.md`, and a run has at most 3 rounds | `STOPPET: maks runder`; the rest goes to the user |
| Budget | more tickets or rounds than the approved plan | stop the run, report, ask before continuing |
| No progress | the target didn't improve beyond noise | `STOPPET: ingen fremgang` |
| Regression | another area got worse, or harden found something new | round rejected, ticket reopened with evidence |
| Oscillation | a finding fixed earlier comes back (same rule + route + selector/file) | `STOPPET: svinger`; both diffs to the user |
| Nothing new | two judge passes in a row with no confirmed actionable finding | the judge is done for that area (a valid "clean") |
| Loosened check | floor-guard hit, a suppression count went up, a threshold went down, or an ignore entry the user didn't write | round **FAIL**, never counted as progress |
| Impossible | the builder flags "needs a spec or design change" | NEEDS-HUMAN; no workaround |
| Taste only | the area has no tool number left open | at most 1 round, then the user decides |

Only a tool number can turn an area green. An ignore list (`.audit-ignore`) may only get rows the user wrote or approved.

## Scoreboard and history

Overwrite `docs/audit/SCOREBOARD.md` each run from `references/scoreboard-format.md` (Danish: GRØN, GUL, RØD, STOPPET, IKKE MÅLT) and append one line per area to `docs/audit/history.jsonl`. Commit both as one log-only commit that touches only those two files (harden's CI gate treats them as log-only, like `PLAN-REVIEW-LOG.md`). In Cowork, also offer the scoreboard as a private artifact with a small trend chart.

## Weekly run

Offer it after the first run. Two parts:
- `references/audit-weekly.yml` in `.github/workflows/` (and `measure/lighthouserc.json` copied to `.github/audit/`): every Monday it measures production and `main` with the tools that need no login (performance, accessibility and SEO via Lighthouse, design detector, code health, dependencies, Semgrep) and posts the numbers as a comment on one open GitHub issue (pin it once), "Kvalitetstavle (ugentlig måling)". Free, and it doesn't need the Mac. Areas that need logged-in roles or the database (UX flows, data and RLS, copy) are measured in manual runs; the weekly board marks them `sidst målt <dato>` instead of guessing.
- A **scheduled task** (create it with the scheduled-task tools, never in-session cron) with the prompt in `references/scheduled-task-prompt.md`: it reads the latest comment on that issue through the GitHub connector, runs the connector checks and judges, updates the scoreboard, opens at most 3 tickets per area, and posts a short Danish summary. It never builds, merges, deploys or changes `CONSTRAINTS.md`. Run it once with "Run now" before relying on it.

## Relation to the other commands

`ship` phase 3 may call `/audit-loop --measure-only` for its go-live scoreboard. `askmatt` routes "gennemgå alt / audit alt / loop / kvalitetstavle / hver uge" here and "er PR'en klar / test PR'en" to `/harden`.
