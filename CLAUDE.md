# PAPcSetup (repo instructions)

This repo is a Claude Code plugin marketplace (`papcsetup`) with two plugins. Talk to Phillip in Danish; files in English.

## Layout
- `.claude-plugin/marketplace.json` - lists `papc-core` and `product-studio` (bump versions here and in each `plugin.json` together).
- `plugins/papc-core/core/CORE.md` - always-loaded rules. Keep it under ~3.5 KB; every byte loads in every session.
- `plugins/papc-core/core/LESSONS.md` - global lessons, max 25 lines, edited only via `/papc-learn`.
- `plugins/papc-core/hooks/` - bash only, no model calls, no network, always `exit 0` unless denying. Test with the commands below after any change.
- `plugins/papc-core/skills/` - `papc`, `papc-doctor`, `papc-learn`.
- `plugins/product-studio/` - product engine; its own README/catalog is the source of truth for product workflows.
- `docs/DEDUP.md`, `docs/ECC-HARVEST.md` - decisions; update when a plugin is added/removed or something is harvested.

## Commands
- Test hooks: `bash tests/run.sh`
- Audit a setup: `bash plugins/papc-core/scripts/doctor.sh <project-dir>`
- Build Cowork upload zips: `bash scripts/package.sh` (writes `dist/`, git-ignored)

## Rules
- One owner per job (see `docs/DEDUP.md`). Never add a skill that duplicates a product-studio skill.
- New hooks must be cheap: no `matcher: ".*"` on tool events, no `claude -p`, no network.
- Harvested code keeps its license file in `plugins/papc-core/licenses/` and a row in `docs/ECC-HARVEST.md`.
- Before commit: run `bash tests/run.sh` and review the diff for silent failures.
