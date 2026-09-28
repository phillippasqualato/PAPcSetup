# Design sources for AI coding agents (Next.js + Tailwind + shadcn/ui)

Researched 2026-09-23. Every claim has a source URL. **UNVERIFIED** means the claim comes from memory or a secondary source and was not confirmed on the vendor's own page during this research.

---

## TL;DR: recommended agent setup

1. **Base layer:** shadcn skill + shadcn MCP. Every registry below installs through the shadcn CLI, so this one setup covers all of them.
   - `npx skills add shadcn/ui` ([source](https://ui.shadcn.com/docs/skills))
   - `npx shadcn@latest mcp init --client claude` ([source](https://ui.shadcn.com/docs/mcp))
2. **Motion:** `npx motion-ai`. Doc search is free. Premium examples and audits need Motion+ ([source](https://motion.dev/docs/ai-kit-install)).
3. **Install components by namespace:** `npx shadcn@latest add @<registry>/<item>`. Namespaces confirmed in this research: `@kokonutui`, `@bklit`, `@magicui`, `@aceternity`. Directory registries need no config ([source](https://ui.shadcn.com/docs/directory)).
4. **Theme first, components second.** Use tweakcn or shadcn/create presets to set the tokens, then add components. Components from these registries use the shadcn CSS variables, so they inherit the theme.
5. **Always preview before writing:** `shadcn add <item> --dry-run` / `--diff` ([source](https://ui.shadcn.com/docs/changelog/2026-03-cli-v4)).

---

## 1. shadcn/ui: https://ui.shadcn.com

**What it offers**
- Copy-in components built on Radix or Base UI: forms, layout, overlays, data display, feedback ([source](https://ui.shadcn.com/llms.txt)).
- Blocks, charts, theming and dark mode.
- A registry system for distributing your own components ([source](https://ui.shadcn.com/docs/registry)).

**Cost/license:** free, open source (MIT, UNVERIFIED on the license page itself).

**Agent integration**
- **llms.txt:** https://ui.shadcn.com/llms.txt ([source](https://ui.shadcn.com/llms.txt))
- **Skill:** `pnpm dlx skills add shadcn/ui` ([source](https://ui.shadcn.com/docs/skills))
  - Runs `shadcn info --json` to read `components.json` (framework, Tailwind version, aliases, base library, icon library, installed components).
  - Uses `shadcn docs` and `shadcn search` before it generates code.
  - Covers theming (OKLCH, dark mode, Tailwind v3 and v4), registry authoring and the MCP server.
- **MCP:** `pnpm dlx shadcn@latest mcp init --client claude`, or add this to `.mcp.json` ([source](https://ui.shadcn.com/docs/mcp)):
  ```json
  { "mcpServers": { "shadcn": { "command": "npx", "args": ["shadcn@latest", "mcp"] } } }
  ```
- **Custom or private registries** go in `components.json` ([source](https://ui.shadcn.com/docs/mcp)):
  ```json
  { "registries": {
      "@acme": "https://registry.acme.com/{name}.json",
      "@internal": { "url": "https://internal.company.com/{name}.json",
                     "headers": { "Authorization": "Bearer ${REGISTRY_TOKEN}" } } } }
  ```
- **CLI v4 (March 2026)** added several agent-relevant features ([source](https://ui.shadcn.com/docs/changelog/2026-03-cli-v4)):
  - `--dry-run`, `--diff` and `--view` to preview changes.
  - `shadcn info` for project context.
  - `shadcn docs <component>` for docs in the terminal.
  - Presets: `shadcn init --preset <code>`, built at https://ui.shadcn.com/create.
  - `registry:base` and `registry:font`, so a whole design system or a font can ship as one registry item.
- **Registry directory:** built-in namespaces work with `npx shadcn add @<registry>/<component>` and need no config ([source](https://ui.shadcn.com/docs/directory)).
- **Charts:** Recharts v3. Install with `shadcn add chart`. Colours come from `--chart-1`…`--chart-N` CSS variables, with `.dark` overrides ([source](https://ui.shadcn.com/docs/components/chart)).

**When to use it:** always, as the base for apps, dashboards and marketing sites.

**Pitfalls**
- Every site built on the defaults looks the same. Set a theme or preset first.
- Check `components.json` for the base library (Radix or Base UI) before copying examples, because the APIs differ ([source](https://ui.shadcn.com/docs/skills)).

---

## 2. Motion (Motion for React): https://motion.dev

**What it offers**
- An animation library for React, JS and Vue. React imports from `motion/react` (it used to be `framer-motion`). MIT license, about 33.7k GitHub stars ([source](https://github.com/motiondivision/motion)).
- **Motion+** is a one-time payment for personal use with lifetime updates, or an annual per-seat Business plan ([source](https://motion.dev/plus)). It includes:
  - 450+ examples
  - premium components (Carousel, AnimateNumber, Ticker, Cursor, Typewriter, ScrambleText, Curtains)
  - **Motion UI**: 30 animated sections that install through shadcn
  - the AI Kit, a visual transition editor and 110+ tutorials
  - Motion+ code is MIT once it is in your project. Reselling Motion+ capabilities needs a "Builder's Licence" ([source](https://motion.dev/plus)).
  - Price not captured in this research (UNVERIFIED).

**Agent integration: the Motion AI Kit** ([source](https://motion.dev/docs/ai-kit))
- **Install:** `npx motion-ai`. It asks whether to install for the project or globally, then which agent (Claude Code is supported) ([source](https://motion.dev/docs/ai-kit-install)).
- **Free:** documentation search. No token, account or configuration needed ([source](https://motion.dev/docs/ai-kit-install)).
- **Motion+ only** ([source](https://motion.dev/docs/ai-kit); [source](https://motion.dev/docs/ai-kit-context)):
  - MotionScore audits, which grade Motion, CSS and GSAP animations by render cost and suggest fixes
  - CSS `linear()` spring generation, so you get springs with no runtime
  - the transition editor
  - agent access to 450+ premium example sources and your saved transitions
  - a `/motion` best-practices skill
  - Sign-in happens in the agent's MCP settings, not with a local API key ([source](https://motion.dev/docs/ai-kit-install)).
- **llms.txt:** https://motion.dev/llms.txt. It indexes the React, JS, Vue and AI Kit docs, plus examples and changelog RSS ([source](https://motion.dev/llms.txt)).
- **Unofficial community MCPs exist**, for example `Abhishekrajpurohit/motion-dev-mcp` ([source](https://github.com/Abhishekrajpurohit/motion-dev-mcp)). Prefer the official AI Kit.

**When to use it**
- Layout and shared-element transitions, `AnimatePresence` exits, scroll-linked effects, gestures, springs.
- Hero and section reveals on marketing sites.
- Micro-interactions in apps.

**Pitfalls**
- `motion` is client-only. Wrap animated pieces in `"use client"` leaf components so pages can stay Server Components (general Next.js practice, UNVERIFIED).
- Bundle weight: use `LazyMotion` + `m` components, or CSS `linear()` springs, for simple cases (UNVERIFIED on the motion.dev page).
- Don't mix Motion and Tailwind `transition-*`/`animate-*` on the same property of one element; they fight each other. Use Tailwind or `tw-animate-css` for simple hover and enter states, and Motion for orchestration, exits and layout animation.
- Respect `prefers-reduced-motion` (`useReducedMotion`).
- Older registry components still import `framer-motion`. Normalise them to `motion/react` so you don't ship two copies.

---

## 3. Kokonut UI: https://kokonutui.com

**What it offers**
- Open-source animated components for Next.js, built on Tailwind, shadcn and Motion. MIT license, about 2.1k stars, Vercel OSS 2025 sponsor ([source](https://github.com/kokonut-labs/kokonutui)).
- **Kokonut UI Pro** is paid, with 100+ components. Pricing and licence terms not captured (UNVERIFIED) ([source](https://kokonutui.com/docs)).

**Agent integration** ([source](https://kokonutui.com/docs))
- Registry URL pattern: `https://kokonutui.com/r/{name}.json`
- Install:
  ```
  npx shadcn@latest add https://kokonutui.com/r/utils.json
  npx shadcn@latest add @kokonutui/particle-button
  ```
- The docs say it works through the shadcn MCP in Claude Code, Cursor, VS Code and Codex.
- **Requires Tailwind v4.**

**When to use it:** marketing sites and landing pages (flashy buttons, cards, text effects, hero accents). Use it sparingly in dashboards.

**Pitfalls**
- Tailwind v4 only.
- Some components list extra dependencies at the bottom of their page, so check before installing ([source](https://kokonutui.com/docs)).
- Pro components are not in the free registry.

---

## 4. Bklit UI: https://bklit.com (registry at ui.bklit.com)

**What it is**
- A chart and data-visualisation component library built on shadcn/ui, **not** an analytics product ([source](https://bklit.com/)).
- It has 15+ chart types: area, bar, candlestick, choropleth, composed, funnel, gauge, line, live line, pie, radar, ring, scatter, sankey ([source](https://github.com/bklit/bklit-ui)).
- Built on **Visx + D3 + Motion** ([source](https://github.com/bklit/bklit-ui)).
- Part of the Vercel OSS program ([source](https://bklit.com/)). Sponsored by OpenPanel, an analytics company ([source](https://github.com/bklit/bklit-ui)).

**License:** the components are MIT. **Bklit Studio** (ui.bklit.com/studio, a visual chart customiser that generates code) is proprietary: "may not reuse, resell, or redistribute Studio without written permission" ([source](https://github.com/bklit/bklit-ui)).

**Agent integration** ([source](https://bklit.com/docs/installation))
- Namespace `@bklit`. Registry URL pattern: `https://ui.bklit.com/r/{name}.json`
- Install:
  ```
  npx shadcn@latest init
  npx shadcn@latest add @bklit/area-chart
  ```
- Some charts pull in `@bklit/shimmering-text` automatically.
- A community `bklit-ui` skill listing exists ([source](https://baaderagency.com/skills/s/bklit/bklit-ui/bklit-ui); UNVERIFIED whether it is official).

**When to use it:** dashboards and analytics pages that need richer or animated charts than shadcn/Recharts (sankey, candlestick, choropleth, live line, gauge).

**Pitfalls**
- It uses Visx/D3, while shadcn charts use Recharts. Mixing both in one app ships two charting stacks, so pick one per project.
- Check that the chart colours map to your `--chart-*` tokens (UNVERIFIED).

---

## 5. 21st.dev: https://21st.dev

**What it offers**
- A community marketplace and registry with 12,000+ React/Tailwind components, templates, shadcn themes and icons ([source](https://21st.dev/)).
- Code is copied in, not imported as a dependency.
- Each component can be copied either as an AI prompt or as a shadcn CLI install command ([source](https://21st.dev/)).

**Cost**
- Free browsing, with **2 free component copies per day** ([source](https://21st.dev/)).
- Membership gives unlimited copies and exclusive templates.
- "21st AI" is an add-on for generation.
- Template authors can sell their templates.

**License:** varies per component or author. The Magic MCP repository declares no license ([source](https://github.com/21st-dev/magic-mcp)). Check each item.

**Agent integration: Magic MCP is now the "21st MCP"** ([source](https://github.com/21st-dev/magic-mcp))
- Install for Claude Code: `npx @21st-dev/cli@latest init --client claude`
- Or configure it manually:
  ```json
  { "mcpServers": { "21st": { "url": "https://21st.dev/api/mcp",
      "headers": { "x-api-key": "YOUR_21ST_API_KEY" } } } }
  ```
- An API key is required (from https://21st.dev/mcp). **Old Magic keys no longer work.**
- Tools: `generate`, `get_inspiration`, `search_logo`, catalog search, code retrieval, bookmarks, team libraries.
- Registry install pattern: `npx shadcn@latest add https://21st.dev/r/<author>/<component>` (UNVERIFIED; not confirmed on a live component page).

**When to use it:** finding inspiration for a hero, pricing, testimonials or other one-off marketing section; logos (`search_logo`).

**Pitfalls**
- Quality and licensing are uneven because it is community content.
- Generated or duplicated code often hard-codes colours instead of using tokens. Refactor it to your CSS variables.
- The daily copy limit applies.
- It needs an API key, so keep the key out of committed `.mcp.json` (use env vars).

---

## 6. Manus Agent Skills: https://manus.im/features/agent-skills

**What it is**
- Manus's implementation of the **Agent Skills Open Standard** (the `SKILL.md` format that Anthropic's Claude skills also use), so skills are described as portable across platforms ([source](https://manus.im/features/agent-skills)).
- Manus runs skills end-to-end in its own sandboxed VM. It offers one-click import and team skill libraries.
- Pricing is on https://manus.im/pricing (not captured).

**Relevance:** it is not a design resource. It confirms that SKILL.md skills written for Claude Code (for example `shadcn/ui`, `motion`, or your own design-system skill) can be reused in Manus and vice versa. The format compatibility is claimed by Manus and was not tested here (UNVERIFIED in practice).

---

## 7. Other design sources worth knowing

| Source | What it is | Agent integration | Notes |
|---|---|---|---|
| **Magic UI** (magicui.design) | 150+ animated marketing components (globe, marquee, terminal…), about 22k stars. Magic UI Pro: 50+ components and templates, paid ([source](https://magicui.design/docs/installation)) | `npx shadcn@latest add @magicui/globe` ([source](https://magicui.design/docs/installation)). MCP: `npx @magicuidesign/cli@latest install claude`, or `npx -y @magicuidesign/mcp@latest` ([source](https://github.com/magicuidesign/mcp)) | MIT ([source](https://github.com/magicuidesign/mcp)). For landing pages. |
| **Aceternity UI** (ui.aceternity.com) | Flashy Motion-based effects: backgrounds, beams, spotlight, 3D cards | `npx shadcn@latest add @aceternity/signup-form-demo` ([source](https://ui.aceternity.com/components/signup-form)) | Free tier. Pro is $169/yr or $199 lifetime, with a Team plan ([source](https://ui.aceternity.com/pricing)). Check the licence page for client and redistribution rules ([link](https://ui.aceternity.com/licence)). Heavy effects: use on heroes, not on every section. |
| **Origin UI / coss ui** | Origin UI: a large set of copy-paste app components ([source](https://github.com/shadcn/originui)). coss ui: a Base UI-first component library from the same lineage ([source](https://coss.com/ui/docs)) | shadcn CLI. `@coss` is listed in the directory ([source](https://github.com/shadcn-ui/ui/issues/8586); namespace UNVERIFIED) | Good for dense **app** UIs such as inputs, selects and tables. coss uses Base UI, not Radix ([source](https://coss.com/ui/docs)). |
| **tweakcn** (tweakcn.com) | Visual theme editor for shadcn (Tailwind v4), about 10k stars ([source](https://github.com/jnsahaj/tweakcn); [source](https://tweakcn.com/)) | Exports CSS variables. `npx shadcn@latest add https://tweakcn.com/r/themes/<id>` (UNVERIFIED) | Use it **first**, to avoid the "every shadcn site looks the same" problem ([source](https://github.com/jnsahaj/tweakcn)). |
| **shadcn/create presets** | Design-system presets | `shadcn init --preset <code>` ([source](https://ui.shadcn.com/docs/changelog/2026-03-cli-v4)) | An official alternative to tweakcn. |
| **Radix Colors** | 12-step accessible scales with alpha and P3 variants and automatic dark mode ([source](https://www.radix-ui.com/colors)) | `npm i @radix-ui/colors` (UNVERIFIED) | Use it to derive consistent token ramps (steps 1–2 backgrounds, 3–5 components, 6–8 borders, 9–10 solid, 11–12 text). |
| **registry.directory** | Explorer across all public shadcn registries: Shadcn Blocks, ReUI, Animate UI, React Bits, SmoothUI, assistant-ui, AI Elements… ([source](https://registry.directory/)) | Copy install commands | Use it for discovery. Animate UI is animation-first; AI Elements and assistant-ui are for chat UIs; ReUI and Shadcn Dashboard are for dashboards ([source](https://registry.directory/)). |

---

## Which source to use for what

| Need | First choice | Alternatives |
|---|---|---|
| App/dashboard shell, forms, tables | shadcn core + blocks | Origin UI / coss, ReUI |
| Standard dashboard charts | shadcn `chart` (Recharts) | — |
| Advanced/animated charts (sankey, candlestick, geo, live) | Bklit (`@bklit/*`) | — |
| Marketing hero / backgrounds | Aceternity, Magic UI | Motion UI (Motion+), 21st |
| Cards, buttons, text effects | Kokonut UI, Magic UI | Animate UI |
| Page and layout transitions, gestures | Motion (`motion/react`) + AI Kit | — |
| Simple hover and enter states | Tailwind transitions / `tw-animate-css` | — |
| Theme and brand tokens | tweakcn or shadcn/create preset | Radix Colors |

## Cross-cutting pitfalls

- **Token drift.** Third-party components sometimes hard-code colours (`bg-neutral-900`, hex values). After each `add`, grep for literal colours and map them to `bg-background`, `text-muted-foreground`, `--chart-*` and similar tokens.
- **Tailwind version.** Kokonut requires Tailwind v4 ([source](https://kokonutui.com/docs)) and tweakcn targets v4 ([source](https://tweakcn.com/)). Confirm with `shadcn info` before installing.
- **Overwrites.** Registry items can overwrite `components/ui/*` or `lib/utils.ts`. Use `--dry-run` / `--diff` first ([source](https://ui.shadcn.com/docs/changelog/2026-03-cli-v4)).
- **Duplicate animation runtimes.** `framer-motion` and `motion` can end up installed together. Standardise on `motion`.
- **Premium licensing.** Aceternity Pro, Magic UI Pro, Kokonut Pro, Motion+ and 21st membership are paid. Don't commit premium source into public repos, and check reseller or template-resale clauses (Motion+ needs a Builder's Licence for resale, [source](https://motion.dev/plus)).
- **Performance.** Canvas and WebGL effects (globe, particles, beams) are heavy. Lazy-load them with `next/dynamic` (`ssr:false`), keep them above the fold only, and honour reduced motion (general practice, UNVERIFIED).
- **Secrets.** The 21st MCP needs an API key and private registries need tokens. Use `${ENV}` substitution, which `components.json` supports ([source](https://ui.shadcn.com/docs/mcp)).
