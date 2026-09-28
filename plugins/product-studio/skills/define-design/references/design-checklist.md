# Design checklist: everything DESIGN.md (and component-states.md) must settle

Walk every section. Answer from the user's feel round, the references, the lookups and impeccable's direction; write "not applicable" rather than skipping silently.

## 0. Surface type first (it changes every answer below)

| Surface | Mode (impeccable) | Priorities | Typical defaults |
|---|---|---|---|
| **Marketing website / landing** | Persuade | first impression, story, conversion, performance | larger type scale, generous spacing, expressive hero/background, scroll motion, 1-2 CTAs per view |
| **Web app / SaaS tool** | Operate | task speed, clarity, consistency, states | compact scale, 4/8px spacing rhythm, restrained colour (one accent), quiet motion (120-200ms), keyboard paths |
| **Dashboard / data-heavy** (e.g. scoring, analytics, admin) | Operate | scanability, comparison, trust in numbers | tabular numerals, dense tables, chart system with `--chart-*` tokens, semantic colours for good/bad/neutral, filters that never lose state |
| **Docs / content** | Read | legibility, wayfinding | 65-75ch measure, strong heading hierarchy, TOC, code/blockquote styles |
| **Mixed** (site + app) | per surface | one shared token set, two surface briefs | same colours/type families; website scale larger, app scale compact |

## 1. Feel and brand
- 3 "should feel" and 3 "must not feel" words; personality level (sober ↔ playful)
- References (liked/disliked) and what specifically to take from each
- Existing assets: logo, colours, fonts, imagery, tone of voice
- Light / dark / both; which is primary; system preference respected

## 2. Colour
- Roles: background, surface, surface-elevated, overlay, border, border-strong, text-primary, text-secondary, text-muted, primary (+hover/active), accent, focus ring, success, warning, error, info; chart-1…chart-N
- Scale per hue (Radix-style steps) and dark-mode counterparts
- Contrast AA for every text/surface pair; colour never the only signal
- Where colour is **not** used (restraint rules)

## 3. Typography
- Families (display, body, mono); source and licence; fallbacks
- Scale: size / line-height / weight / tracking per step (display, h1-h4, body-lg, body, small, caption, label)
- Numerals: tabular for data; da-DK formats (`1.234,56 kr.`, `23. sep. 2026`)
- Measure (max line length), truncation and wrapping rules

## 4. Space, layout, grid
- Spacing scale (e.g. 4/8/12/16/24/32/48/64) and where each step is used
- Padding inside components (buttons, inputs, cards, table cells, dialogs)
- Page widths, gutters, grid columns per breakpoint (390 / 768 / 1024 / 1280 / 1440)
- App shell: sidebar vs top nav, header height, content max width
- Section rhythm for websites (vertical spacing between sections)

## 5. Shape and depth
- Radius scale (none / sm / md / lg / full) and which component uses which
- Borders: widths, when a border vs a shadow separates surfaces
- Elevation levels (shadow values or layered surfaces), blur/backdrop use
- Backgrounds: flat, gradient, noise/texture, pattern, image; where allowed

## 6. Components (each with all states)
Buttons (primary, secondary, ghost, outline, destructive, icon-only, link), inputs, textarea, select, combobox, checkbox, radio, switch, slider, date picker, file upload, cards (default, interactive, selected), tables/data grids (sort, filter, empty, loading, row hover, selection), tabs, navigation (sidebar, top bar, breadcrumbs, mobile menu, active states), dialogs, sheets/drawers, popovers, tooltips, toasts, badges/status pills, avatars, progress, skeletons, empty states, error pages, charts (see 8).

States for every interactive component: default, hover, focus-visible, active/pressed, selected, disabled, loading, empty, error, success. Specify what changes (colour, elevation, border, scale, cursor) and the transition.

## 7. Motion
- Durations (e.g. 120 / 200 / 320ms) and easing curves or springs; what animates (opacity, transform) and what never does (layout-shifting properties)
- Enter/exit, page transitions, list reordering, hover micro-interactions, loading
- Reduced-motion behaviour; one library (Motion **or** CSS), not both on one element

## 8. Data visualisation
- Chart library (shadcn/Recharts **or** Bklit, recorded once); chart types per question
- Colour order `--chart-1…N`, semantic colours (positive/negative/neutral), dark-mode variants
- Axes, gridlines, labels, legends, tooltips (content, format, position), annotations
- Empty, loading, single-point, huge/negative values, long labels; responsive behaviour
- Number and date formatting in the UI language

## 9. Iconography and imagery
- Icon set (one), stroke width, sizes, alignment with text
- Illustrations/photos: style, sourcing, alt text rules

## 10. Content and microcopy
- Voice (formal/informal "du"), button verbs, error message pattern (what happened + what to do), empty-state pattern (why empty + next action), confirmation dialogs
- UI language(s) and where translations live

## 11. Accessibility
- WCAG 2.2 AA; visible focus ring spec; keyboard paths for core jobs; touch targets ≥ 44px; labels on inputs; aria for icon buttons; motion and flashing limits

## 12. Anti-patterns to avoid (generic AI look)
Same grey card with the same border everywhere; default purple/blue gradient hero; uniform radius and shadow on everything; everything centred with no hierarchy; emoji as icons; hover states that barely change; three near-identical card grids; decorative motion without purpose; hard-coded colours from third-party components.
