# Decision tree for grill-design

V = visual this-or-that (rendered, never asked in words), F = verbal fact (asked with a recommended answer). Pass A = before the look exists, B = impeccable's direction round, C = inside the chosen look.

"Default when delegated" is what the agent picks on "du bestemmer"; it is logged `delegated` in `docs/design/decisions.md`. Adapt defaults to the surface type (impeccable mode: Operate for apps and dashboards, Persuade for marketing, Read for docs) and to `PRODUCT.md`; never pick a default that contradicts a pinned answer or a brand commitment.

| # | Section → question | V/F | Pass | Default when delegated | Stored in |
|---|---|---|---|---|---|
| 0.1 | Surface: website / app / dashboard / docs / mix | F | A | from PRODUCT.md jobs; app if logged-in users | decisions.md → surface brief (impeccable mode) |
| 0.2 | Most important screen | F | A | the screen the core job lives on | decisions.md → surface brief |
| 0.3 | Mobile importance (primary / secondary / desktop-only) | F | A | secondary, 390px must work | decisions.md → DESIGN.md Layout |
| 1.1 | Existing logo, colours, fonts that must stay | F | A | none; nothing gets invented as "brand" | PRODUCT.md Brand Commitments |
| 1.2 | Liked and disliked reference sites | F (+anydesign) | A | agent suggests 3 that fit; user may skip | decisions.md + docs/design/references/ |
| 1.3 | Feel: 8 neutral pairs (dense↔airy, quiet↔loud, soft↔sharp, warm↔cool, flat↔layered, still↔lively, plain↔ornamented, light↔dark scene) | V | A | no leaning; the roll decides | decisions.md (leaning) → impeccable evidence/steer |
| 1.4 | Must-not-feel (pick "never this" among 4 rendered clichés: purple gradient, grey card grid, neon-on-black, cream serif) | V | A | all four banned (craft-floor already bans most) | decisions.md → DESIGN.md Do's and Don'ts via impeccable |
| 1.5 | Visual direction (dealt cards / pick / canon / re-roll) | V | B | assigned direction | DESIGN.md (impeccable seed) + direction.html |
| 2.1 | Accent strength inside the world (restrained / committed) | V | C | impeccable's colour strategy for the mode (Restrained for Operate) | DESIGN.md Colors via impeccable |
| 2.2 | Status colours good/bad/neutral on real data | V | C | world's semantic set, AA-checked | component-states.md + a11y.md |
| 3.1 | Heading/body pairing (2-3 specimens within the world) | V | C | world's faces | DESIGN.md Typography via impeccable |
| 3.2 | Number format and tabular numerals | F | C | da-DK, tabular in tables | component-states.md |
| 4.1 | Density of tables/lists (compact / comfortable) | V | C | compact for Operate, comfortable for Persuade | DESIGN.md Layout via impeccable |
| 4.2 | App shell: sidebar vs top nav | V | C | sidebar if >5 destinations | component-states.md → DESIGN.md Layout |
| 5.1 | Radius character (sharp / soft / pill buttons) | V | C | world's shape language | DESIGN.md Shapes via impeccable |
| 5.2 | Surfaces: border vs tint vs shadow | V | C | world's elevation philosophy | DESIGN.md Elevation via impeccable |
| 5.3 | Background: flat / texture / image / gradient per surface | V | C | flat for app, world's material for marketing | DESIGN.md Overview/Do's |
| 6.1 | Primary/secondary/ghost button set (live hover, press) | V | C | world's button + press scale 0.97 | component-states.md |
| 6.2 | Card: static vs interactive (hover lift / border / none) | V | C | border-shift hover, no lift in Operate | component-states.md |
| 6.3 | Nav active state (pill / underline / bar) | V | C | the world's accent carrier | component-states.md |
| 6.4 | Forms: label position, error inline vs summary | V | C | label above, inline error + summary on submit | component-states.md |
| 7.1 | Motion level (still / subtle / expressive), shown as looping clips | V | C | subtle 150-200ms, reduced-motion respected | component-states.md (+ Motion vs CSS once) |
| 8.1 | Chart library (shadcn/Recharts vs Bklit) | F | C | shadcn charts unless sankey/funnel/gauge is needed | component-states.md + sources.md |
| 8.2 | Chart style (gridlines, labels on bars vs tooltip, colour order) | V | C | minimal gridlines, direct labels, `--chart-*` order | component-states.md |
| 8.3 | Empty/loading/single-point chart states | V | C | skeleton + "Ingen data endnu" + next action | component-states.md |
| 9.1 | Icon set and stroke | V | C | lucide (shadcn default), 1.5px | component-states.md |
| 9.2 | Imagery: photos / illustration / none | V | C | none in app; real photos on marketing if available | DESIGN.md via impeccable |
| 10.1 | Tone: du, formal/plain/playful (3 rendered microcopy samples) | V | A | du, plain and friendly | PRODUCT.md (voice) + component-states.md patterns |
| 10.2 | Empty / error / success pattern (rendered) | V | C | why empty + next action; what happened + what to do | component-states.md |
| 11.1 | Dark mode: none / follow system / toggle | F (+V preview) | C | follow system if the world supports it, else light | DESIGN.md via impeccable |
| 11.2 | Special accessibility needs | F | A | WCAG 2.2 AA | PRODUCT.md Accessibility |
| 12 | Anti-patterns check | — | C | agent runs the checklist; no question | a11y.md / critique |

Stored-in rules: `DESIGN.md` is only ever written by impeccable (`document`, seed mode now and scan mode after the walking skeleton); "via impeccable" means the answer is handed to impeccable as evidence or a pinned constraint. `component-states.md` is written by define-design step 7. `PRODUCT.md` is written by define-product / impeccable init. grill-design writes only `decisions.md`.
