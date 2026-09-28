---
name: papc-learn
description: Bounded, human-approved learning at the end of a larger task - a short reflection in Danish (what we learned), then at most 3 candidate lessons that Phillip approves; project lessons go into that project's CLAUDE.md/AGENTS.md, global ones into PAPcSetup LESSONS.md (max 25). Use when the user types "/papc-learn", says "hvad lærte vi", "husk det her til næste gang", "gem læringen", when a larger task (feature, PR, setup, research) has just finished, or with "review" to prune old lessons.
---

# PAPc learn

Learning is useful only while it stays small, true and in one place. This skill is the ONLY way lessons are written. No hooks, no background agents, no automatic capture.

## 1. Reflect (always)
Write 2-4 lines in Danish: what worked, what went wrong, what to do differently. This is the short reflection Phillip wants after larger tasks. If nothing is worth keeping, say so and stop.

## 2. Propose at most 3 lessons
Each candidate must pass all four:
- **Actionable:** an instruction ("Do X when Y"), not a story or a fact.
- **Recurring:** would change behaviour in a future session.
- **Not already covered:** not in CORE.md, LESSONS.md, the project's CLAUDE.md/AGENTS.md, or a product-studio skill. If it is, skip it (or propose sharpening the existing line).
- **Not personal data:** facts about Phillip belong in claude.ai memory, not here. Never secrets, customer data or health/financial details.

Classify each one:
- **project** (default): only true for this repo/product → the project's `AGENTS.md` (or `CLAUDE.md` if there is no AGENTS.md), under `## Lessons`.
- **global**: true across projects - only if Phillip says "altid"/"overalt", or the same lesson already appears in another project's Lessons.

Show them as a numbered list with the target file and ask: "Hvilke skal jeg gemme? (fx 1,3 / ingen)". Save nothing without an explicit yes.

## 3. Save
Line format everywhere: `- YYYY-MM-DD | <rule> | <source> | seen 1x`

- **Project:** edit the project file directly (only the `## Lessons` section; create it at the end if missing). Keep it at max 15 lines; at the cap, merge or retire first.
- **Global:** the file is `plugins/papc-core/core/LESSONS.md` in the PAPcSetup repo. Find a local clone (`$PAPC_REPO`, `~/PAPcSetup`, `~/papcsetup`, `~/Documents/GitHub/PAPcSetup`) or attach `phillippasqualato/PAPcSetup` if this session can. Edit, then commit `lesson: <short rule>` and push. If no clone is reachable, print the exact line and tell Phillip to run `/papc-learn` in the Code tab where the repo is.
  - Hard cap **25** lessons. At the cap: propose a merge or a retirement first; never append past it.
  - Same lesson seen again: bump `seen Nx` and the date instead of adding a line.
  - A lesson that contradicts CORE.md is not saved; point out the conflict.
- Tell Phillip that global lessons reach other sessions after the plugin updates (`/plugin marketplace update papcsetup`).

## `/papc-learn review`
List global lessons older than 90 days or seen only once, and propose keep / merge / retire for each. Apply only what Phillip approves.
