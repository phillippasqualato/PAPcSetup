# PLAN-REVIEW-LOG.md entry format

Append-only file at the repo root, shared with claudex-loop (its plan-review and inspection entries use its own format in the same file). Newest entry at the bottom. Never rewrite history; a correction is a new entry that references the old one.

```markdown
---

## HARDEN <run-id> — VERDICT: <SHIP | FIX-FIRST | BLOCKED>   (write exactly one word, e.g. "— VERDICT: SHIP")

- **Date:** YYYY-MM-DD HH:MM (Europe/Copenhagen)
- **Target:** PR #<n> `<branch>` @ `<head-sha>` · preview <url> | main @ `<sha>` · <prod url>
- **Base for diff:** `<base-sha>`
- **Scope:** full | <area>
- **Builder:** <Claude Code (model if known) / Codex / human>
- **Inspector:** <L3 Codex via claudex-loop (model) | L2 adversarial-inspector (isolated) | L1 separate session> — never the builder
- **Surface:** Code tab | Cowork
- **Evidence files:** `harden/<run-id>/verdict.json`, `harden/<run-id>/inspector-result.json`, stage reports

### Stages
| # | Stage | Status (PASS / FAIL / NOT RUN) | Evidence (report path / command) |
|---|---|---|---|
| 1 | Static gates | | |
| 2 | Database & RLS | | |
| 3 | Leak sweep | | |
| 4 | Corner cases | | |
| 5 | E2E & design conformance | | |
| 6 | Adversarial inspection (verdict: APPROVED/REVISE/BLOCKED) | | |

### Confirmed findings
| ID | Severity | Where | Finding | Evidence | Ticket |
|---|---|---|---|---|---|

### Needs a human decision
- <question> → <recommended answer>

### Rejected (false positives)
- <id>: <why, with counter-evidence>

### Accepted risks (only with the user's explicit words)
- <risk> — accepted by <user> on <date>: "<quote>"

### Next
<fix round n of 2 / merge approved / escalated to user>
```

## Verdict rules

- SHIP requires: no confirmed blocker/major, inspector APPROVED, stages 1, 2 and 6 actually ran, any other NOT RUN stage accepted by the user in writing. Stage 1 or 2 NOT RUN means BLOCKED.
- A SHIP entry applies to exactly one head SHA. Any later commit needs a new harden run (the CI gate enforces this).
- Severity: **blocker** = data leak, security hole, data loss, core job broken, build/deploy broken; **major** = wrong behaviour or clear design deviation users will notice; **minor** = edge case or cosmetic; **polish** = taste.
