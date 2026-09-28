# Design sources the agents use (and how)

Everything installs through the shadcn CLI or an official MCP/skill, so it lands as code in the repo, themed by our tokens. Full evidence with sources: `../../define-toolchain/references/design-sources.md`. Verify install commands on the source's docs before relying on them; UNVERIFIED items are marked there.

## The sources

| Source | What it's for | How an agent uses it | Licence / cost | Watch out |
|---|---|---|---|---|
| **shadcn/ui** (ui.shadcn.com) | The base: primitives, blocks, charts (Recharts, `--chart-*` colours), themes | Vendored `shadcn` skill; shadcn MCP (`npx shadcn@latest mcp`, in `.mcp.json`); docs at `ui.shadcn.com/llms.txt`; `npx shadcn@latest add <item> --dry-run` first; `shadcn info` to see the setup | MIT, free | Radix vs Base UI base library: check `components.json` before copying examples |
| **Motion** (motion.dev) | Page/layout transitions, gestures, springs, scroll effects | `npm i motion`, import from `motion/react`; Motion AI Kit `npx motion-ai` (doc search free; audits/premium examples need Motion+); docs `motion.dev/llms.txt` | MIT; Motion+ paid | Never install both `framer-motion` and `motion`; don't animate the same property with Motion and Tailwind |
| **Kokonut UI** (kokonutui.com) | Animated cards, buttons, text effects, AI-style inputs | `npx shadcn@latest add @kokonutui/<name>` (registry `kokonutui.com/r/{name}.json`) | MIT; Pro paid | Requires Tailwind v4; check listed extra deps |
| **Bklit UI** (bklit.com) | Advanced charts: sankey, funnel, gauge, radar, candlestick, choropleth, live lines | `npx shadcn@latest add @bklit/<chart>` (registry `ui.bklit.com/r/{name}.json`) | MIT components; Studio proprietary | Second chart stack (Visx+D3) next to shadcn/Recharts: choose one per project, record it in DESIGN.md |
| **21st.dev** | Marketplace of 2,000+ UI components and 2,000+ blocks: AI chats, navigation, sign-ins and widgets, cards and grids, buttons, heroes, backgrounds, shaders, 3D | 21st MCP `npx @21st-dev/cli@latest init --client claude` (API key; old Magic keys invalid) or its shadcn install command per component | Varies per component; free tier limited | Check each component's licence; restyle to our tokens |
| **Magic UI** (magicui.design) | Animated app and marketing components: number ticker, animated list, file tree, dock, bento grid, circular progress, terminal, avatar circles, globe, marquee, beams | `npx shadcn@latest add @magicui/<name>`; MCP `npx -y @magicuidesign/mcp@latest` | MIT; Pro paid | Continuous canvas/WebGL effects cost performance: lazy-load them and keep them off busy working screens unless they help the task |
| **Aceternity UI** | Animated app components (sidebar, tabs, modal, file upload, timeline, loaders, stateful button, expandable/focus cards, floating dock, code block) plus backgrounds, spotlight, 3D cards | `npx shadcn@latest add @aceternity/<name>` | Free tier; Pro paid (check licence for client work) | Performance of the heavier effects; check reduced-motion and keyboard support |
| **Origin UI / coss ui** | Dense app inputs, selects, tables | shadcn CLI | MIT | coss uses Base UI |
| **tweakcn** / **shadcn/create presets** | Visual theme editor: colours, radius, fonts → CSS variables | Export the theme; `shadcn init --preset <code>` | Free | Do this first so the app doesn't look like every shadcn site |
| **Radix Colors** | 12-step accessible colour scales with dark mode | Derive token ramps (1-2 backgrounds, 3-5 components, 6-8 borders, 9-10 solid, 11-12 text) | MIT | — |
| **registry.directory** | Discovery across public shadcn registries (Animate UI, ReUI, AI Elements, assistant-ui…) | Copy install commands | — | Same token and licence checks |
| **Manus agent skills** | Not a design source: Manus's implementation of the same SKILL.md standard | Nothing to install for design | — | — |

## Which source for what

| Need | First choice | Alternatives |
|---|---|---|
| App/dashboard shell, forms, tables | shadcn core + blocks | Aceternity (sidebar, tabs, modal, file upload), 21st.dev, Origin UI / coss, ReUI |
| Standard dashboard charts | shadcn `chart` | — |
| Advanced/animated charts | Bklit | — |
| Marketing hero, backgrounds | Magic UI, Aceternity, 21st.dev | Motion+ sections |
| Cards, buttons, text effects | Kokonut UI, Magic UI, Aceternity, 21st.dev | Animate UI |
| Live numbers, KPIs, progress, activity feeds | Magic UI (number ticker, circular progress, animated list) | Kokonut UI, Motion |
| AI chat and AI input | 21st.dev (AI chats), Kokonut UI (AI inputs) | shadcn AI Elements |
| Timelines, file trees, loaders, step flows | Aceternity (timeline, loaders), Magic UI (file tree) | 21st.dev |
| Transitions, gestures, springs | Motion + AI Kit | — |
| Simple hover/enter states | Tailwind transitions | — |
| Theme and brand tokens | tweakcn or shadcn/create | Radix Colors |

## Rules after every `add`

1. `--dry-run`/`--diff` first; never let a registry item silently overwrite `components/ui/*` or `lib/utils.ts`.
2. Grep the added files for literal colours, sizes, radii and shadows; map them to our tokens (`bg-background`, `text-muted-foreground`, `--chart-*`, radius scale).
3. Remove duplicated dependencies (`framer-motion` vs `motion`, two chart stacks, two icon sets).
4. Add hover, focus-visible, disabled and reduced-motion behaviour if the component lacks them.
5. Premium code never goes into a public repo; record the source and licence of each added component in `docs/design/sources.md`.
