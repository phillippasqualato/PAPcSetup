---
name: ui-sources
description: "Where the parts of a UI come from and how to put them into the product: shadcn/ui (base components, blocks, charts), Motion (animations, transitions, gestures), Kokonut UI (animated cards, buttons, text effects), Bklit (advanced charts), 21st.dev (2,000+ UI components and blocks: AI chats, navigation, sign-ins, cards, heroes), Magic UI and Aceternity (animated app components and effects). Picks the right source for a need, shows real examples before choosing, installs through the shadcn CLI or the source's own MCP, and restyles to the product's tokens. Works in Cowork and the Code tab. Use when the user mentions any of these sites, asks how something could be built or animated (\"kan vi lave en animeret graf\", \"en fed hero\", \"kortene skal bevæge sig\", \"hvilken komponent\", \"brug kokonut\", \"find en komponent\"), or when a ticket adds or changes a UI component, chart or animation."
---

# UI sources

impeccable decides **how the product looks** (DESIGN.md). This skill decides **where each part comes from** and gets it into the code the right way. It never changes the look on its own: a new component is restyled to the existing tokens, and a change to the look goes through `grill-design` / impeccable. Danish to the user, English in files.

Read first: `../define-design/references/design-sources.md` (the sources, what each is for, install commands, licences, pitfalls, and "Which source for what"), then the project's `components.json`, `DESIGN.md` and `docs/design/component-states.md` (its "chosen source per component family" wins over any new idea). Full evidence with source links: `../define-toolchain/references/design-sources.md`. Verify an install command on the source's docs (Context7 or the site's `llms.txt`) before running it.

## 1. Pick the source (one winner per need)

Every source is broad: search all of them for the need, not only the one it's best known for (e.g. Aceternity has sidebars, tabs, modals, file upload, timelines and loaders; Magic UI has number tickers, animated lists, file trees, progress rings and bento grids; 21st.dev has AI chats, navigation, sign-ins and cards; Kokonut has AI inputs and buttons). The "Which source for what" table is a starting point, not a limit. Choose by fit: how well it serves the task, quality and accessibility, how easily it takes the product's tokens, performance, and licence. Rules:
- The project's recorded choice wins: if component-states.md says "charts: shadcn chart (Recharts)", don't add Bklit next to it. A second chart stack, a second animation library (`framer-motion` next to `motion`) or a second icon set needs the user's explicit OK and a note in component-states.md.
- Simple hover and enter states are Tailwind transitions, not Motion.
- Judge an effect by where it sits, not by which site it's from. On a screen people work in every day, motion must support the task (show a change, guide attention, confirm an action), stay calm and fast, and respect reduced motion. Continuous canvas/WebGL effects (globes, beams, shaders, 3D) belong where they don't slow down daily work; say the performance cost to the user when you suggest one.

## 2. Show before choosing

When the user asks "how could this look" or "find something", don't describe it: show 2-3 real candidates from the source (link plus a screenshot, or a small rendered artifact page using the product's tokens), each with one plain-Danish line on what it does and what it costs (free / Pro). Let the user pick or say "du bestemmer" (log the choice in `docs/design/decisions.md` like grill-design does). A choice that changes the look → `grill-design` pass C first.

## 3. Put it into the product (Code tab)

1. **Project setup, once per repo** (as a setup ticket if missing):
   - `.mcp.json`: `"shadcn": { "command": "npx", "args": ["shadcn@latest", "mcp"] }`.
   - `components.json` → `registries`: `"@kokonutui": "https://kokonutui.com/r/{name}.json"`, `"@bklit": "https://ui.bklit.com/r/{name}.json"` (and `@magicui`, `@aceternity` only if the project uses them). Namespaces listed in the shadcn directory also work without this entry; writing it makes the source explicit.
   - Motion: `npx motion-ai` (project install, Claude Code) adds Motion's MCP and skills; doc search is free, Motion+ features need the user's own sign-in.
   - 21st.dev: only if the user wants it; its MCP needs the user's API key from 21st.dev, stored as an env variable, never in a file.
2. **Install**: `npx shadcn@latest add @<source>/<item> --dry-run` (or `--diff`) first; never let an item overwrite `components/ui/*` or `lib/utils.ts` silently. Then install.
3. **Restyle and finish** (the "Rules after every add" in design-sources.md): literal colours, sizes, radii and shadows → the product's tokens; add hover, focus-visible, disabled, loading and reduced-motion behaviour if missing; remove duplicate dependencies.
4. **Record** the source and licence in `docs/design/sources.md`. Premium (Pro/Motion+) code never goes into a public repo.
5. Verify in the running app (`next-dev-loop` or `visual-qa`); the PR goes through `/harden` like any other change.

## In Cowork

Cowork plans and shows; the Code tab installs. Pick and show candidates here, write the choice into the ticket ("cards: @kokonutui/<item>, restyled to tokens, hover as component-states.md"), and hand it to the Code tab via `build-handoff` / `build-ticket`.
