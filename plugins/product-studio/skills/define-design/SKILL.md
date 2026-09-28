---
name: define-design
description: Design phase called by start-project or askmatt (or when the user explicitly asks to define the design). Finds and locks a product's visual direction with the user by orchestrating the professional design skills - impeccable for the visual world and DESIGN.md, anydesign to reverse-engineer reference sites and screenshots, ui-ux-pro-max for palette and type lookup, web-design-guidelines and the design plugin for review - showing directions as clickable pages instead of describing them.
---

# Define Design

`impeccable` owns the method and the root `DESIGN.md`. This skill sequences it with the other specialists and adapts it to Cowork. Danish to the user, English in files.

Read first: `PRODUCT.md` (impeccable needs it), `docs/tech.md` (Tailwind + shadcn by default), existing `DESIGN.md`, `references/design-checklist.md` (everything the design must settle, per surface type) and `references/design-sources.md` (shadcn, Motion, Kokonut UI, Bklit, 21st.dev, Magic UI, Aceternity, tweakcn and when to use which). For the craft rules per component family (8-point grid, colour, type, buttons, cards, forms, navigation, modals, hero, shadows) read the relevant files of `../ui-design-fundamentals/` when filling component-states.

**Surface type first.** Decide with the user whether this is a marketing website, a web app, a data-heavy dashboard, docs, or a mix (checklist section 0). It sets impeccable's mode, the type scale, spacing density, motion level and which sources fit. A mix gets one shared token set and one surface brief per surface. This is question 0.1 of grill-design's pass A; ask it there, once.

## Order of play

1. **impeccable context.** Invoke `product-studio:impeccable`. Its launcher (`<impeccable base dir>/scripts/impeccable`) fetches its engine on first run and must see the project files. The user's device shell can't see the plugin folder, so run it in the cloud workspace against a working copy: copy `PRODUCT.md`, `DESIGN.md` (if any) and `CONTEXT.md` from the repo into a scratch project folder there, run `impeccable context` with that folder as cwd, and copy anything impeccable writes back into the repo. If the launcher can't run at all, see "Without the launcher" below.
2. **Feel round.** Run `product-studio:grill-design` **pass A** (facts in words, taste as rendered this-or-that pairs, "du bestemmer" allowed everywhere); its leanings and pins become evidence for impeccable. Let impeccable's new-work step 2 drive the remaining questions (mode: usually **Operate** for app UI, **Persuade** for a landing page). PRODUCT.md from define-product already holds the product record, so impeccable must not re-run its init interview; only fill a genuinely missing PRODUCT.md field. Top up from `references/design-checklist.md` only what grill-design and impeccable left open (check `docs/design/decisions.md` first; never ask twice): 3 "should feel"/3 "must not feel" words, light/dark, density, existing brand assets, the one screen that matters most, mobile importance.
3. **References.** Ask for 2-4 sites/screenshots/Figma links the user likes (and one they dislike); suggest fitting ones if they have none. For each, run `product-studio:anydesign` (full mode, or element mode for "just that card/hover") **inside** `docs/design/references/<name>/` only. Tell the user in plain Danish what concretely makes each work. If the user names a component or chart kit, read its docs and note which pieces fit.
4. **Sources that fit the surface.** Follow `product-studio:ui-sources` steps 1-2 with `references/design-sources.md`: shortlist per component family (shell, cards, buttons, charts, hero/backgrounds, motion) and show the user live examples from those sites next to the directions. Decide the chart library once (shadcn charts or Bklit) and the motion approach once (Motion or CSS), and record both.
5. **Data, not guesses.** Run `ui-ux-pro-max`'s search (`python <ui-ux-pro-max base dir>/scripts/search.py "<product type> <industry> <keywords>" --design-system -p "<name>"`, plus `--domain typography` / `--domain color`). Candidates, never a verdict.
6. **Directions.** Run impeccable's **Create or replace the visual world** flow for the most important screen, with the reference analyses and lookups as evidence: `concept-seed`, the dealt directions, the pick card, the canon card, re-roll with safer/bolder. Its decision page runs on a local port the user can't open from Cowork, so present the same cards as one self-contained HTML page with a switcher (real content from `PRODUCT.md`, concrete hex values and font names per direction, live hover/focus states), publish it as an artifact, and collect the choice with the structured question tool (impeccable's documented fallback channel). Iterate ("headeren fra B, kortene fra A") until the user locks one. "Du bestemmer" here = take the direction impeccable dealt (grill-design pass B, logged `delegated`). Save the final page as `docs/design/direction.html`.
7. **Commit the world.** First run `product-studio:grill-design` **pass C**: component this-or-that rendered in the chosen colours and fonts (buttons, cards and hover, nav, forms, charts, empty/loading/error, motion, dark mode); its answers fill component-states.md below. Then run impeccable `document` in **seed mode**: it writes root `DESIGN.md` with the `<!-- SEED -->` marker, minimal frontmatter (name, description), the Overview-to-Shapes sections and Do's and Don'ts, no Components section and no sidecar yet. Because the direction was chosen with concrete values, write those values (palette hexes with roles, font families, radius/spacing character) into the Colors and Typography prose as seed mode allows. Write `docs/design/component-states.md` covering every section of the checklist that DESIGN.md's seed can't hold yet: spacing and padding per component, radius and elevation per component, every component with default, hover, focus-visible, active, selected, disabled, loading, empty, error and success behaviour, motion durations/easing, chart rules, microcopy patterns, the chosen source per component family (e.g. "cards: Kokonut UI card restyled to tokens"), and a token → Tailwind/shadcn CSS-variable mapping. Record every third-party component source and licence in `docs/design/sources.md`. Tell build-handoff to add a ticket right after the walking skeleton: "run impeccable `document` in scan mode to capture real tokens, the Components section and `.impeccable/design.json`".
8. **Check before the gate** (subagents in parallel where possible):
   - `product-studio:web-design-guidelines` on `docs/design/direction.html`.
   - `design:accessibility-review` (if installed), and anydesign's `check_contrast.py --pair "FG,BG:label" … --output docs/design/a11y.md` for every text/surface pair of the chosen direction. Fix AA failures before the gate.
   - `design:ux-copy` (if installed) for the key screen's buttons, empty states and errors, in the UI language from `CONTEXT.md`.
9. **Gate.** Show the direction page and the file list. "godkendt?"

## Without the launcher

If impeccable's launcher can't run anywhere: say so in one line, read `PRODUCT.md`/`DESIGN.md` directly, and follow `impeccable/reference/new-work.md` by hand: author 5-7 structurally different directions grounded in the evidence, show three plus your own pick and the category-standard "canon" option, offer re-roll safer/bolder, and write the seed `DESIGN.md` by following `impeccable/reference/document.md` seed mode. Never skip the direction round.

## Running anydesign safely

- Never run anydesign or its scripts in the repo root: it writes `design.md` there, and on macOS that *is* `DESIGN.md`. Only inside `docs/design/references/<name>/`.
- Its scripts live in `scripts/` next to anydesign's SKILL.md. Run them with a shell that can see that folder and has network (usually the cloud workspace, where Chromium for Playwright is often preinstalled; `pip install -r requirements.txt` and `playwright install chromium` if needed), then copy the outputs into the repo folder.
- If a dependency can't be installed: view screenshots directly, use web fetch for structure, mark measured values ⚠️, say so.

## Other design skills the user has

Use the user's own design skills (frontend-design, anti-slop, fintech, apple, design-tokens, frontend-polish) only as named flavour feeding impeccable's direction, never as a second author of `DESIGN.md`. See the catalog's section 6. The user's `dataviz` skill (if installed) may feed chart rules into `docs/design/component-states.md`, never DESIGN.md. Cloud design canvases (Superdesign, v0) only in a scratch folder with fake content for throwaway exploration; never run their repo init or keep their design-system files in the repo; their drafts count as references for anydesign/impeccable.

## Done when

`docs/design/decisions.md` lists every question with its state (user / delegated / pinned / leaning / n/a), and every "lands in" target exists.

Seed `DESIGN.md`, `docs/design/direction.html`, `docs/design/component-states.md`, `docs/design/a11y.md` and the reference analyses exist in the repo, the user has seen and approved a direction, and build-handoff knows to add the scan-mode ticket.
