# Dedup: one owner per job

Audit of Phillip's installed plugins, 28 Sep 2026. Rule: **product-studio owns product work, papc-core owns rules/guards/learning, business plugins own their domain.** Anything that does the same job twice is switched off.

## Switch off (overlaps an owner)

| Plugin | Why it goes | Owner instead |
|---|---|---|
| superpowers | 15 skills already bundled in product-studio (same names) + SessionStart hook injects `<EXTREMELY_IMPORTANT>` using-superpowers into every session, Cowork included | product-studio (Superpowers is its Code-tab engine, no hook) |
| pr-review-toolkit | its 6 agents exist in product-studio (`pr-code-reviewer`, `silent-failure-hunter`, `pr-test-analyzer`, `type-design-analyzer`, `comment-analyzer`, `code-simplifier`) | product-studio agents |
| feature-dev | its 3 agents + 7-phase flow exist in product-studio (`code-architect`, `code-explorer`, `feature-code-reviewer`, `feature-dev` skill) | product-studio |
| code-review | second `/code-review`; competes with product-studio `code-review` + `/harden` | product-studio `code-review`, `/harden` |
| claude-md-management | `claude-md-improver` exists in product-studio; `revise-claude-md` is a second learning path | product-studio `claude-md-improver`; learning via `/papc-learn` |
| claude-memory | second learning system (diary/reflect + PreCompact hook) | `/papc-learn` (bounded) + claude.ai memory for facts |
| security-guidance | Stop + UserPromptSubmit + PostToolUse hooks; Stop runs a model review of the diff = credits on every turn | `/harden` (leak-hunter, supabase-security-reviewer) at PR time |
| frontend-design | competes with product-studio's design chain (`define-design`, `impeccable`, `grill-design`, `ui-sources`) | product-studio |
| engineering (knowledge-work) | `code-review`, `debug`, `testing-strategy`, `architecture`, `deploy-checklist` duplicate product-studio skills | product-studio (`/ship`, `systematic-debugging`, ...) |
| productivity (knowledge-work) | `memory-management` is a third memory system that writes CLAUDE.md + `memory/` on its own | claude.ai memory + `/papc-learn`; tasks via Linear/Notion connectors |

## Keep

| Plugin | Why |
|---|---|
| papc-core | the always-on core |
| product-studio | the product engine |
| graphify | knowledge-graph-first search (Phillip's rule); its hooks are cheap guards |
| commit-commands | `/commit`, `/commit-push-pr`, `/clean_gone` - no overlap, no hooks |
| plugin-dev | building/validating plugins (used to maintain PAPcSetup) |
| design (knowledge-work) | used by product-studio `define-design` / `visual-qa` |
| canva, data, sales, enterprise-search, sp-global, pendo-*, zapier, sanity, amazon, vibe-prospecting, cowork-plugin-management | own domains, no overlap. Switch off any you don't use: every model-invocable skill description costs context in every session |

## Don't install (checked)
- **ECC** as a plugin: 292 skills / 68 agents / 94 commands + hooks on every tool call (`matcher: ".*"`), Stop-hook `claude -p` summaries and a background Haiku observer for learning. Harvested instead: see `ECC-HARVEST.md`.
- `mattpocock-skills`, `agent-skills` (addyosmani), `ralph-loop`, `tdd-guard`, output-style plugins: bundled or conflicting (product-studio catalog).

## Minor
- Context7 is both a claude.ai connector and bundled in product-studio `.mcp.json`. Harmless (tools load on demand); if you see Context7 tools twice in Code, remove the connector there.
- product-studio keeps some reference-only alternates internally (`ask-matt`, `tdd`, `webapp-testing`, `grill-me`, `grill-with-docs`, `using-superpowers`). They are `disable-model-invocation: true`, so they never compete for routing and cost no context. Left as is on purpose.

## One install channel per plugin
Install each plugin from ONE place: either the PAPcSetup marketplace (Claude Code) or a claude.ai upload (Cowork + synced). Two channels = two copies of every skill. `/papc-doctor` flags this.
