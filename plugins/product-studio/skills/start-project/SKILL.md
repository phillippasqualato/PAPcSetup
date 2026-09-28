---
name: start-project
description: Start a brand-new product or app project from a raw idea. Orchestrates the professional skills and agents in order - product grilling and domain language, agent-led architecture, a behind-the-scenes toolchain and conflict audit (which plugins/MCPs/agents, how data moves between GitHub, Vercel, Supabase and the agents), visual design direction, and a build-ready handoff to the Code tab - before any code is written. Use when the user says "start project", "/start-project", "nyt projekt", "jeg har en idé til en app". For an existing product use askmatt.
---

# Start Project

A conductor, not a soloist. Every phase is done by the best professional skill or agent for that job (see the catalog at `../askmatt/references/catalog.md`); this skill decides the **order**, the **gates** and **what gets written where**. The user is a no-coder product owner: they decide product, feel and money; you and the agents own everything technical, and you are knife-sharp about it.

**Start by showing the map** in `references/workflow-map.md` (one short table, in Danish), then create one task per phase.

## Ground rules

- **Danish in conversation, English in files.** One canonical English term per domain concept; the Danish UI word is noted next to it in `CONTEXT.md`.
- **Facts are the agent's job, decisions are the user's.** Never ask what you can look up. Every question carries a recommended answer.
- **Gate every user-facing phase** with a ≤10-bullet summary and "godkendt". Approval of one phase never approves the next. Technical phases don't need the user's approval unless they cost money, touch production, or change privacy.
- **Show, don't describe** anything visual.
- **Write as you go** into the repo (layout: `references/docs-layout.md`). Nothing important lives only in the chat.
- **Track progress** with a task list: one task per phase, sub-tasks for the current phase.
- **Call, don't copy.** Invoke skills with the Skill tool (`product-studio:<name>`; other plugins by their own names, e.g. `design:accessibility-review`, `engineering:system-design`). If a skill is user-only and refused, read `../<name>/SKILL.md` and follow it. Dispatch agents with the Agent tool; if a named agent type doesn't exist on this surface, spawn a general-purpose subagent with the body of `../../agents/<name>.md` as instructions. Always tell a subagent where the repo is: in Cowork that is the connected folder on the user's computer, reachable with the device shell tool at `$HOME/mnt/<folder>`; if the subagent can't use that tool, stage the files it needs into the sandbox first and pass the staged paths. Never skip a step because a tool is missing: say what's missing, use the documented fallback, and note it in `docs/log.md`.
- **Context hygiene** (Matt Pocock): keep phases 1-5 in one unbroken conversation so the grilling, architecture, design and spec build on the same reasoning. Send self-contained work (research, scouting, audits) to subagents so the main thread stays in the smart zone.

## Phase 0: Place and inventory

1. Take the raw idea in the user's own words. Don't question yet.
2. **Where it lives.** A connected folder from the user's computer (in Cowork's shell: `$HOME/mnt/<folder>`), never the shell's scratch directory. No folder → ask the user to connect their projects folder. Existing repo? Check `git remote -v`; never assume an unrelated repo is the project.
3. **What this session can reach.** Skills and plugins (session list, `ListPlugins`), connectors (`ListConnectors`), CLIs (`git`, `gh auth status`, `node`, `pnpm`, `supabase`, `vercel`). Cowork's shell doesn't share the Mac's logins; the Code tab does. Keep the inventory for Phase 3.
4. **Missing core plugins.** If Anthropic's `engineering` or `product-management` plugins aren't enabled, offer them once with an install card (`SearchPlugins` → `SuggestPluginInstall`); they supply alternates the flow can use. Don't block on them.
5. **Size.** Say out loud: normal project, or foggy mega-effort (several products or too many unknowns for one session). Foggy → after Phase 1, route to `product-studio:wayfinder` and resume at Phase 5 when the map clears.
6. **GitHub reach.** Decide once how this session talks to GitHub, in this order: a GitHub connector/MCP in this chat (search the registry and offer it if missing); an already-authenticated `gh` in the device shell; otherwise **none**. With "none", everything still works: files are written and committed locally in the connected folder (`git init`/`git commit` need no login), and the Code tab (which has the Mac's GitHub login) does the remote parts as step 0 of its prompt (create the repo, push, publish issues). Never walk the user through an interactive login in Cowork's shell.
7. **Repo.** If none: propose a kebab-case name and ask before creating anything. With GitHub reach: create a private repo and clone it into the connected folder. Without: `git init` a folder with that name in the connected folder; build-handoff hands repo creation to the Code tab.

## Phase 1: Product — what and why

Invoke `product-studio:define-product`. It runs `grilling` + `domain-modeling` (Matt Pocock), pulls in `research` for outside facts, `product-management:competitive-brief` when competitors matter, `prototype` (logic) when a rule can't be settled on paper, and `to-questionnaire` when an answer sits with someone else. Output: `PRODUCT.md` (impeccable-compatible), `CONTEXT.md`, product ADRs. **Gate.**

## Phase 2: Technique — how it's built

Invoke `product-studio:define-tech`. The agent designs the architecture itself on the stack defaults, grounded in the vendored `supabase`, `supabase-postgres-best-practices` and Next.js bundled docs, and only puts business-shaped choices to the user. Output: `docs/tech.md`, ADRs. **Gate** on the plain-language summary.

## Phase 3: Toolchain — which tools, how data moves, what can collide (background)

Immediately after Phase 2's approval, invoke `product-studio:define-toolchain` and let its `integration-scout` and `toolchain-auditor` agents run **in the background** while Phase 4 happens with the user. It writes `docs/toolchain.md`, the repo `.mcp.json`, `.claude/settings.json` permission rules, and collects ≤5 user actions. Don't interrupt the design conversation with its details; surface only blockers (anything that could leak data, touch production, or break the build) the moment they're confirmed.

## Phase 4: Design — how it looks and feels

Invoke `product-studio:define-design`. It orchestrates `impeccable` (context → new-work visual world → document in seed mode → seed `DESIGN.md`), `anydesign` on the user's references, `ui-ux-pro-max` for palette/type lookup, shows directions as clickable artifacts, and checks with `web-design-guidelines`, `design:accessibility-review` and `design:ux-copy`. Output: seed `DESIGN.md` with the chosen palette and type values in prose, `docs/design/direction.html` (the approved direction page), `docs/design/component-states.md`, reference analyses. Real tokens land when impeccable `document` runs in scan mode after the walking skeleton (a ticket build-handoff adds). **Gate** on a direction the user has seen.

## Phase 5: Handoff — ready to build

Invoke `product-studio:build-handoff`. It writes `AGENTS.md` (project rules; Next.js adds its managed block when the app is scaffolded) and `CLAUDE.md` (`@AGENTS.md`), runs `setup-matt-pocock-skills` with pre-filled answers, turns everything into a spec (`to-spec`) and tracer-bullet tickets (`to-tickets`) on GitHub Issues, adds the setup checklist for human-only steps, gets the docs onto `main`, and produces the Code-tab prompt plus the Code-tab plugin/MCP setup lines from Phase 3. **Gate** on the spec summary and ticket breakdown.

## Phase 6: Final audit

1. Collect Phase 3's results. Re-run `toolchain-auditor` against the now-populated repo (instruction files, `.mcp.json`, settings, docs) and fix what it finds in files.
2. Run `product-studio:claude-md-improver`, pointed at `AGENTS.md` (it searches for CLAUDE.md by default: tell it the project's rules live in AGENTS.md, `CLAUDE.md` must stay `@AGENTS.md`, and Next's block and our managed block are not to be rewritten; improvements go outside or inside our block only).
3. Append the session to `docs/log.md`.

## Completion

Tell the user in Danish, briefly:

- the repo (name + URL) and the files that now hold the truth,
- what's still open and where it's tracked,
- their ≤5 setup actions (connectors, integrations, one-line Code-tab installs),
- the next step: paste the prompt into the Code tab, where `/build-ticket` builds one ticket at a time (worktree, plan for their approval, test-first, PR); each PR gets an independent `/harden` verdict before it merges; `/askmatt` (in Cowork or the Code tab) for everything after that.

Don't build. Building happens in the Code tab.
