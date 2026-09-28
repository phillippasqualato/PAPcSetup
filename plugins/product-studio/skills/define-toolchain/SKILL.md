---
name: define-toolchain
description: Decide, behind the scenes, how the project's tools fit together - which plugins, skills, subagents and MCP servers each surface (Cowork, Code tab, CI) uses, how every artifact and piece of data moves between GitHub, Vercel, Supabase, the repo docs and the agents, and every conflict that could make them disagree - then write docs/toolchain.md, the repo's .mcp.json and permission settings, and a short list of connect-clicks for the user. Toolchain phase called by start-project or askmatt, or when the user explicitly asks to audit the tools.
---

# Define Toolchain

The user can't judge this, so be ruthless on their behalf. Output is evidence-based decisions, not options. Speak Danish to the user only about the few actions they must take; everything else goes in `docs/toolchain.md` (English).

Inputs: `PRODUCT.md`, `docs/tech.md`, ADRs, the catalog `../askmatt/references/catalog.md`, the conflict checklist `references/conflict-checklist.md`, the MCP evidence file `references/mcp-research.md`.

## Steps

1. **Inventory what exists right now** (don't guess):
   - Skills and plugins available in this session (the skill list, and `ListPlugins`/`ListSkills` if those tools exist).
   - Connectors/MCPs connected and enabled in this chat (`ListConnectors` if present), and which of their tools are loaded.
   - CLIs in the shell that can reach the repo (`git`, `gh auth status`, `node -v`, `pnpm -v`, `supabase --version`, `vercel --version`), and whether that shell shares the Mac's logins (Cowork's doesn't; the Code tab does).
   - Repo files that configure agents: `AGENTS.md`, `CLAUDE.md`, `.mcp.json`, `.claude/settings.json`, `.claude/agents`, `.claude/skills`, `hooks`, `next.config.*`, `supabase/config.toml`, `.env.example`, `.github/workflows`.
2. **Capability map.** From `docs/tech.md` list the capabilities the project needs (repo, issues, CI, hosting/preview, database, migrations, auth, storage, email, payments, AI provider, background jobs, error tracking, analytics, design analysis, browser QA, docs lookup, knowledge/memory).
3. **Scout** (run in parallel, in the background, while the user continues with design):
   - Dispatch the `integration-scout` agent with the capability map, the inventory and the catalog. If that agent type isn't available, spawn a general-purpose subagent with the body of `../../agents/integration-scout.md` as its instructions.
   - For candidates in the org's catalogs, use `SearchPlugins` / `SearchMcpRegistry` when available.
4. **Design the data flow.** Using `references/data-flow-template.md`, write for every artifact: source of truth, who writes it, who reads it, how it moves, what triggers the sync, and the guard that stops drift. Draw it as a mermaid diagram. Cover at least: product/tech/design docs, domain terms, tickets and specs, code, database schema (migrations), env vars and secrets, design tokens, preview URLs, QA reports and screenshots, decisions log, and (if used) Graphify output and the Obsidian vault.
5. **Audit conflicts.** Dispatch the `toolchain-auditor` agent (same fallback as above) with the inventory, the planned toolchain, the data-flow draft and the checklist. Read its register critically: verify every blocker yourself before accepting it; drop anything without evidence.
6. **Resolve.** For each finding pick one resolution and apply what you can in files (never in production systems):
   - `docs/toolchain.md` (template in `references/toolchain-doc-template.md`): tool matrix, data flow, conflict register with resolutions, permissions, and "how to add a tool" rules.
   - Repo `.mcp.json` for the Code tab: only the servers chosen, scoped as in the catalog (Supabase dev project + read-only, GitHub toolsets, Vercel project-scoped). Secrets never in the file: use `${ENV_VAR}` placeholders.
   - `.claude/settings.json`: permission rules: deny `mcp__vercel__deploy_to_vercel`, every `mcp__vercel__buy_*` tool by full name and `mcp__vercel__import-claude-design-from-url`; always ask for `execute_sql`, `apply_migration` (if ever enabled), email sends, `git push --force`, `supabase db push` to production. Deny reading `.env*` values into the conversation where the surface supports it.
   - The toolchain section of `AGENTS.md` (via build-handoff's template): which tool to use for what, and the golden rules.
6b. **Opt-ins to ask about once** (yes/no, default no, recorded in `docs/toolchain.md`): impeccable's design hooks in the Code tab (`/impeccable hooks on`: a local detector check after each UI edit and a deeper pass at the end of each turn; no model cost, a few seconds of latency; lives in the git-ignored `.claude/settings.local.json`; never in Cowork). Recommend yes only for design-heavy builds.
7. **User actions.** Reduce everything the user must do to ≤5 plain-Danish steps with exact clicks (add the Supabase custom connector with the scoped dev read-only URL (not the directory connector), connect the Vercel connector and set its deploy/buy tools to Blocked, install the Vercel↔Supabase integration, create a fine-grained GitHub token for one repo, install a Code-tab plugin with one command). Offer install cards (`SuggestPluginInstall` / `SuggestConnectors`) when the tools exist.
8. **Report** in ≤6 Danish bullets: what was chosen, what was blocked and why, what they must click. No approval gate is needed for purely technical choices; ask only if a choice costs money, touches production, or changes privacy.

## Re-running

Run again whenever a service, plugin, MCP or connector is added or removed (askmatt routes here), and before the first production launch. Update the conflict register; never delete resolved rows, mark them resolved with the date.
