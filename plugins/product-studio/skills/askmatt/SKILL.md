---
name: askmatt
description: "The one command to remember after start-project: describe what you want and it finds and runs the right skills, flows, agents and plugins - including starting build-ticket, harden or ship when that's what you asked for. Works in Cowork and in the Code tab. Matt Pocock's ask-matt router extended to everything available (this plugin's skills and agents, other installed plugins, connectors and MCP servers, and ones worth installing). Loads the project's truth, looks at the live app when anything visible is involved, routes to the right flow, runs it with approval gates and hands changes to the Code tab. Use when the user says \"askmatt\", \"/askmatt\", \"ask matt\", \"/iterate\", \"iterate\", \"hvad skal jeg bruge til\", \"jeg vil ændre\", \"det ser forkert ud\", \"tilføj en funktion\", \"review det vi har bygget\", \"tjek preview\", or shares a screenshot of their app."
---

# askmatt (ask-matt, for the whole toolbox)

The user remembers two commands: `/start-project` for a new idea and `/askmatt` for everything else. The others (`/build-ticket`, `/harden`, `/ship`, `/grill-design`, `/audit-loop`) are shortcuts; when the user's words ask for them, start them yourself and say so in one line:
- "byg", "byg ticket #n", "tag næste" (Code tab) → `product-studio:build-ticket` (in Cowork: write the Code-tab prompt instead)
- "er PR'en klar", "test PR'en", "tjek PR'en", "gennemgå PR'en", "må det merges" → `product-studio:harden` (one verdict for one change)
- "gennemgå alt", "audit alt", "test alt", "kør et loop", "kvalitetstavle", "hver uge" → `product-studio:audit-loop` (every area of the product, round by round)
- "grill mig på designet", "hjælp mig med at vælge designet" → `product-studio:grill-design`
- a named UI site (shadcn, Motion, Kokonut, Bklit, 21st.dev, Magic UI, Aceternity), "find en komponent", "hvordan kan vi animere", "en anden graf" → `product-studio:ui-sources`
- "lancér", "go live", "afslut projektet" → `product-studio:ship`
- a brand-new product idea → `product-studio:start-project`

You don't remember every tool, so look it up: every run starts from a fresh inventory and the catalog. A **flow** is a path through the tools. Most work runs along one **main flow**; **on-ramps** merge onto it; the rest is standalone or a vocabulary layer underneath. Danish to the user, English in files. Say which route you picked in one line so the user can override it.

When the user asks what askmatt does, or on the first run in a project, show `references/workflow-map.md`. On every run, name the route you picked and the skills/agents it will use in one line.

## Surfaces: Cowork and the Code tab

The same skill runs in both; it adapts, it doesn't change its judgement.

- **Cowork** (planning, browser, connectors): routes, decides with the user, updates the docs, and hands work to the Code tab through `build-handoff`. No product code.
- **Code tab** (Claude Code in the repo, with this plugin installed there): the same routing, but after "godkendt" it builds right here: `product-studio:build-ticket` per ticket (Superpowers: worktree → `writing-plans` → `subagent-driven-development`/`executing-plans` with `test-driven-development` and verification → PR via `finishing-a-development-branch`), then `/harden` for an independent verdict. The builder never judges its own work: the verdict comes from harden's inspector.
- **No arguments** (`/askmatt` alone), on either surface: give a status briefing first, in ≤10 Danish lines, from the project truth below: what the product is (one line from `PRODUCT.md`), what's built, what's in progress (open PRs/tickets), the last `PLAN-REVIEW-LOG.md` verdict, known risks, and the 3 most valuable next steps. Then ask which one.

## Batch requests ("ret det her, det her og det her, og kig designet, leaks og visualiseringerne igennem")

Split the message into numbered items and classify each with the routes below in one short table (item → route → surface). Order them: blockers and broken things first, then changes, then reviews. Review items ("kig det igennem", "grundig gennemgang", "leaks", "visualiseringer") route to `/harden` (scoped to the area if one is named); change items go through the main flow. Confirm the table with the user once, then work through it, reporting per item.

## 0. Load and look (every run)

1. **Project truth**, cheaply and in this order, only what exists: `AGENTS.md`, `docs/log.md` (last entries), `CONTEXT.md`, `PRODUCT.md`, `docs/tech.md`, `docs/toolchain.md`, `DESIGN.md`, ADR titles, `graphify-out/GRAPH_REPORT.md`. Then recent commits, open PRs and issues (GitHub connector, or `gh` if signed in). Delegate code reading to the `code-explorer` agent; don't read source wholesale. No such docs? Offer `start-project` (new product) or `build-handoff` steps 1-3 (existing code without docs).
2. **Toolbox inventory.** The skills listed in this session, `ListPlugins`/`ListSkills`/`ListConnectors` when present, and the catalog `references/catalog.md` (canonical tool per job, alternates, agents, plugins, MCPs). Anything the route needs that isn't available → section 5.
3. **Look before talking.** If anything visible is involved, run a short `product-studio:visual-qa` pass first (PR preview, else production). Compare a user screenshot with the live page and `DESIGN.md`. Talk about what you saw.

## 1. The main flow: idea → ship

0. **Classify the change** (Superpowers brainstorming's rules; say it aloud; when in doubt, the heavier path; the ratchet only goes up): **spike** (we need to see or try something before deciding) → `prototype`, throwaway; **bounded** (an existing flow, one seam, no schema/RLS/auth change) → steps 1-3 light, then one ticket labelled `size:bounded`; **architectural** (new area, schema, several seams) → the full flow with to-spec + to-tickets. Approving the scope is not approving a plan that doesn't exist yet.
1. **Sharpen by interview.** `product-studio:grilling` + `product-studio:domain-modeling` (Matt's `grill-with-docs` pair): stateful, keeps `CONTEXT.md` and ADRs. No repo? `grill-me` (same interview, stateless).
2. **Branch: can every question be settled in conversation?** If one needs a runnable answer (state, business logic, a UI you have to see), detour through `product-studio:prototype`: logic → a clickable HTML artifact; UI → structurally different variants on one page with a switcher (an artifact while planning; real `?variant=` routes only in the Code tab). Bridge with `handoff` only if the prototype lives in another directory or tool.
3. **Update the truth** the change touches: `PRODUCT.md` (define-product), `docs/tech.md` + ADR (define-tech, with a `supabase-security-reviewer` pass on any data or permission change), `DESIGN.md` (define-design → impeccable), `docs/toolchain.md` (define-toolchain, whenever a service, plugin or MCP is added or removed).
4. **Branch: multi-session build?** Yes → `to-spec` → `to-tickets` (tracer bullets with blocking edges) via `product-studio:build-handoff`. No → one ticket via build-handoff. Either way the Code tab runs `build-ticket` per ticket (worktree, plan + approval, test-first build with builder-side reviews, PR with its rulings), clearing context between tickets.
5. **Close the loop.** PR preview → `/harden` (independent verdict; light changes may use `visual-qa` + review agents) → FIX-FIRST: fix tickets back to step 4, at most 2 rounds → SHIP: merge go-ahead to the user → `docs/log.md`.

**Context hygiene.** Keep steps 1-4 in one unbroken context so the interview, spec and tickets share the same thinking. Near the smart-zone limit (~150k tokens), compact at the nearest phase boundary, never mid-phase. Push self-contained work (research, reviews, audits, scouting) to subagents.

## 2. On-ramps (situations that generate work, then merge onto the main flow)

| Situation | Route |
|---|---|
| **Look & feel** ("det ser billigt ud", "kedeligt", "grimt", "ligner AI", hover, cards, fonts, layout) | (step-0 visual-qa findings) → impeccable `critique` (read-only, fine on either surface) → **local** problem: `grill-design` pass C for just those parts (rendered this-or-that, "du bestemmer" allowed), **whole look**: `grill-design` redesign mode → define-design step 6 → pass C; then pick the matching impeccable command (`polish`, `bolder`, `quieter`, `typeset`, `layout`, `colorize`, `animate`, `delight`, impeccable's own `harden` for UI edge cases (not our `/harden`), `onboard`); `anydesign` element mode on a reference and `ui-ux-pro-max` lookup when a new look is needed; show the proposed change as an artifact mock → "godkendt" → `DESIGN.md`/component-states update if the system changes → one ticket that tells the Code tab which impeccable command to run on which component. Impeccable's editing commands run only in the Code tab, after "godkendt", and the result goes through `/harden`. |
| **New feature, one session** | main flow 1 → short design in chat → "godkendt" → one ticket |
| **Big feature / new area** | main flow 1-4 with to-spec + to-tickets; `code-architect` agent for an implementation blueprint when the codebase is large |
| **Huge, foggy effort** | `wayfinder` (decision tickets, one resolved per session) → `to-spec` when the fog clears. Never for a well-scoped feature. |
| **"Det er langsomt"** (slow page, slow query, Lighthouse/CWV red) | `performance-optimization` (measure → fix → verify, keep or revert) + `web-performance-auditor` agent (real numbers only) → ticket with the measured before/after. A slowdown that started with a change is a regression → `diagnosing-bugs`. |
| **Rename, remove or migrate** a column, table or feature | `deprecation-and-migration` (expand → migrate → contract, a down path, batched backfill) + `define-tech` (ADR) + `supabase-security-reviewer` → expand/contract tickets; the schema change and the code that depends on it never ship in the same deploy |
| **Something's broken** | reproduce in the browser (visual-qa: console, network) → ordinary bug: `systematic-debugging`; hard, intermittent or regression: `diagnosing-bugs` (red feedback loop first) → ticket with a regression test. Post-mortem finds no seam → `improve-codebase-architecture`. |
| **Continuous quality** ("gennemgå alt", "audit alt", "kvalitetstavle", "loop", "hver uge") | `/audit-loop`: measure every area with a fixed tool → independent judge → verified findings → at most 3 tickets per area → `build-ticket` → `/harden` → measure again; hard stop rules; Danish scoreboard; optional weekly run |
| **One change's verdict** ("er PR'en klar?", "leaks i den her PR?", pre-merge or pre-launch) | `/harden` (`product-studio:harden`): static gates, RLS proofs, leak sweep, corner cases, E2E + design conformance, independent inspection, verdict in `PLAN-REVIEW-LOG.md`, fix tickets + Code-tab prompt on FIX-FIRST |
| **Second opinion from another model** ("få Codex til at kigge") | `claudex-route` for a recommendation or one scoped handoff; `claudex-loop` for plan review → build → cross-provider inspection (needs both CLIs, Code tab) |
| **Preview check before merge** (light, one screen) | visual-qa on the preview + parallel review agents: `pr-code-reviewer`, `silent-failure-hunter`, `pr-test-analyzer`, `type-design-analyzer` (TS-heavy diffs), `supabase-security-reviewer` (data diffs), and `code-review` (standards + spec) → one merged verdict as a PR comment |
| **"Hvordan er det bygget / er det godt?"** | subagents in parallel: `code-explorer` (how it works), `code-review` against the first commit or a tag, `improve-codebase-architecture`, `supabase-security-reviewer`, `toolchain-auditor` (drift), impeccable `audit` on key screens → one plain-Danish report with the top 5 actions, each routable back onto the main flow |
| **Bugs and requests piling up** (arrived raw, not from to-tickets) | `triage` → agent-ready issues |
| **New capability with a new service** ("vi skal have betaling", "send e-mails", "AI-opsummering") | full main flow, not a shortcut: grilling on the product side (for payments: pricing, trial, VAT/moms, invoices, what happens on failed payment) → `define-tech` (tables, webhooks, RLS, `supabase-security-reviewer` pass; `api-and-interface-design` for idempotent webhooks and retries; `security-and-hardening` for SSRF, AI input and abuse) → `integration-scout` + `define-toolchain` re-audit (sandbox/test keys only, webhook endpoints vs Vercel preview protection) → to-spec + to-tickets |
| **Just a tool** ("installer X", a new MCP or plugin, no product change) | `integration-scout` → `define-toolchain` re-audit → user clicks |
| **Tool weirdness** ("Code-fanen opfører sig mærkeligt efter …") | `toolchain-auditor` on hooks, skill collisions, MCP overlaps, instruction files; a build-ticket run that looped, ignored its plan or cost too much → `/diagnosing-superpowers` (Code tab) |
| **Instruction files feel stale** | `claude-md-improver`, pointed at `AGENTS.md` (it looks for CLAUDE.md by default; `CLAUDE.md` stays `@AGENTS.md`; Next's block and our managed block are not rewritten) |
| **Finish the product / go live** ("afslut", "gør klar til lancering") | `/ship` (`product-studio:ship`) |
| **Pre-launch check only** (no release yet, just "how far are we?") | `/harden` full scope with `claude-security` Scan codebase + `engineering:deploy-checklist` (if installed) + define-toolchain re-run + the CI gate from harden turned on |
| **Mid-merge or rebase conflict** (Code tab) | `resolving-merge-conflicts`: resolve by intent, hunk by hunk, never `--abort` |
| **A step only a human can do** | checklist with links and exact clicks; `wizard` only if the user runs a script in their own terminal |

## 3. Codebase health (upkeep, not features)

`improve-codebase-architecture` surveys for deepening opportunities; picking one generates an idea for main flow step 1. `codebase-design` is the bench for the chosen module (deep modules, seams, adapters). `code-simplifier` and `comment-analyzer` agents after a feature lands.

## 4. Vocabulary underneath and standalone

- `domain-modeling`: when the words are the problem (an overloaded "sag" or "kunde"), or to record an ADR.
- `codebase-design`: module-shape vocabulary shared by `tdd` and `improve-codebase-architecture`.
- `research`: outside facts from primary sources, in the background, as a cited file in the repo; feeds main flow step 1. Context7 for library docs.
- `to-questionnaire`: the answer is in someone else's head.
- `wait-what`: a message didn't land; re-pitch simply with `CONTEXT.md` terms.
- `teach`: the user wants to understand a concept properly ("hvad er RLS?") over several sessions.
- `handoff`: work travels to another tool (Codex), folder or person.
- `writing-for-agents`: when writing skills, AGENTS.md sections or docs agents will consume.
- `writing-skills` (Superpowers, user-invoked): write or pressure-test a skill with subagents before trusting it.
- `idea-refine` (user-invoked): the idea is still raw; diverge first, then grill.
- `source-driven-development` (user-invoked): framework code must follow the current official docs (via Context7), cited.

## 5. When the toolbox is missing something (discovery)

1. Check the catalog for the canonical pick for that job.
2. If it isn't available here: search the org catalogs (`SearchPlugins`, `SearchSkills`, `SearchMcpRegistry`) and, if needed, dispatch `integration-scout` for the best official option with a safe config.
3. Offer it with an install card (`SuggestPluginInstall` / `SuggestConnectors`) or exact steps (Code-tab `/plugin install …`, a custom connector URL). Adding a tool always routes through `define-toolchain` so the conflict register stays true.
4. Meanwhile use the documented fallback; never pretend a missing tool ran.

Agents named here that aren't available as subagent types on this surface: spawn a general-purpose subagent with the body of `../../agents/<name>.md`.

## 6. Agree, then hand off

Every route ends the same way: a short summary (what, why, how it will look, how we'll know it works), "godkendt", docs updated where the truth changed, then `product-studio:build-handoff` for the ticket(s) and the Code-tab prompt. Don't write product code in Cowork unless the user explicitly asks.

## 7. Phase boundaries

At the end of a phase, in order (first yes wins): **continue** if the next phase needs this reasoning or there's room; **clear/start fresh** if nothing here matters next; **handoff** only for a new tool, directory or person; **subagent** if the task can run AFK (reviews, research, QA); otherwise **compact** with an instruction naming what the next phase needs. Details: `../ask-matt/PHASE-BOUNDARIES.md`.

## Precondition

The repo is configured once by `build-handoff` (which runs `setup-matt-pocock-skills`). If `docs/agents/issue-tracker.md` is missing, run build-handoff steps 1-2 first.
