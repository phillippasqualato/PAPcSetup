# ECC harvest (affaan-m/ECC, MIT)

Read 28 Sep 2026 from a local clone. Goal: take the pieces that fill real gaps in Phillip's setup, skip everything product-studio already owns, and never import ECC's cost/latency.

## Taken (rewritten small, in papc-core)

| ECC piece | What it does in ECC | PAPc version | Changed because |
|---|---|---|---|
| `session-start.js` context injection with caps (8000 chars, max 6 instincts, confidence ≥0.7) | Loads last session summary + instincts at start | `hooks/session-start.sh`: CORE.md + LESSONS.md, hard cap 6000 chars | No session summaries (git + product-studio handoff already hold state); caps kept |
| `block-no-verify.js` | Blocks `--no-verify`, `core.hooksPath=` | `hooks/guard-bash.sh` + force-push to main + `rm -rf /,~` | 580 lines of Node → ~40 lines bash; ignores quoted text |
| `config-protection.js` | Blocks edits to lint/format configs | `hooks/protect-config.sh` | **asks** instead of blocks; adds test/type/git-hook configs |
| `suggest-compact.js` + `strategic-compact` skill | Suggests `/compact` from real context size in transcript `usage` | `hooks/context-check.sh` on UserPromptSubmit (once per prompt, not per edit) | 200k default, re-nudge every 100k, one line, never mid-task |
| `continuous-learning-v2` ideas: atomic lessons, project scope by default, promotion to global only when seen in 2+ projects, retention | Instincts with confidence, background Haiku observer | `skills/papc-learn`: max 3 per run, human approval, project-first, 25-line global cap, 90-day review | **No automatic observation, no background model**, one store per scope |
| `context-budget` + `security-scan` (AgentShield) ideas | Audit context bloat and config security | `skills/papc-doctor` + `scripts/doctor.sh` | Plain bash, read-only, adds duplicate/channel/hook-cost checks |
| `search-first` principle | Look for existing tools before building | One line in CORE.md | Already partly in product-studio `integration-scout` |

## Deliberately not taken

| ECC piece | Why not |
|---|---|
| 292 skills, 68 agents, 94 commands | product-studio owns planning, TDD, debugging, review, security, browser QA, shipping. Adding them = routing conflicts + context cost |
| Hooks with `matcher: ".*"` on PreToolUse/PostToolUse (observe, governance-capture, mcp-health-check, posttooluse-dispatcher) | Spawns Node several times on every tool call |
| `session-end.js` / `llm-summary.js` (`claude -p --model haiku` on Stop) | Model call after every response = credits |
| Background observer (continuous-learning-v2) | Background model + unbounded observations.jsonl; the exact "learning becomes a problem" risk |
| `rules/common/*` (coding style, testing, git, security, performance, agents) | Overlaps product-studio skills and AGENTS.md per project; performance.md model advice is dated |
| `unified-memory` vault, `ecc2`, dashboard, cost-tracker, statusline, tmux helpers | Separate infrastructure; claude.ai memory + git already cover it |
| Language rule packs (python, go, rust, ...) | Stack is Next.js + Supabase + Vercel; revisit per project via `integration-scout` |

## How to harvest more later
1. `git clone --depth 1 https://github.com/affaan-m/ECC /tmp/ecc` (read, never install).
2. Ask: which gap does it fill, and who owns that job today? (`docs/DEDUP.md`)
3. Rewrite small into papc-core (or product-studio if it is product work), keep `licenses/ECC-MIT.txt`, add a row above.
4. Run `/papc-doctor`.
