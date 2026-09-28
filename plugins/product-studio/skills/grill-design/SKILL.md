---
name: grill-design
description: "Design interview that makes sure the look ends up exactly as the user wants: facts are asked in words, taste is decided by clicking between small rendered side-by-side examples (buttons, cards, hover, navigation, charts, empty and error states), and the user can say \"du bestemmer\" or \"jeg er ligeglad\" to any question, section or the rest, and the agent decides and logs that it did. Feeds impeccable as evidence; never writes DESIGN.md itself. Called by define-design and askmatt. Use when the user says \"grill mig på designet\", \"grill-design\", \"/grill-design\", \"hjælp mig med at vælge designet\", \"designet er kedeligt\", \"designet er grimt\", \"det ligner AI\", or \"revisit designet\". For the look, use this instead of grilling; grilling stays for non-visual plans and facts."
---

# Grill design

A design interview in the spirit of Matt Pocock's `grilling`, adapted to taste: **people can't describe a look, but they can pick between two.** So facts are asked in words and taste is asked with rendered this-or-that examples. Danish to the user, English in files.

**Ownership (never break this).** This skill asks, records and hands evidence on. `impeccable` stays the only author of `DESIGN.md`; `define-design` writes `docs/design/component-states.md`; `define-product`/impeccable init write `PRODUCT.md`. This skill writes only `docs/design/decisions.md` (the log) and the comparison pages.

Read first: `PRODUCT.md`, `CONTEXT.md`, existing `DESIGN.md`, `docs/design/decisions.md` (if any), `../define-design/references/design-checklist.md`, and `references/decision-tree.md` (the questions, which are visual, the default when delegated, where each answer lands).

## The rules of the interview

1. **Don't ask what the files already answer.** Skip anything settled in PRODUCT.md, DESIGN.md, the references or decisions.md.
2. **Facts in words, taste in pictures.** Facts (surface type, most important screen, existing brand assets, UI language, accessibility needs, chart library) are plain questions with a recommended answer (`➡️`), like grilling. Taste (density, softness, contrast, buttons, cards, hover, nav, motion, charts, states) is **never** asked in words: render 2–3 small candidates side by side and let the user pick (see "The comparison page"; the question tool holds at most 4 options, and one is always "Du bestemmer").
3. **No anchoring on taste.** For visual questions don't show your recommendation until the user has picked or delegated; then say in one line what you would have picked and why. For facts, show the recommendation up front.
4. **"Du bestemmer" is always an option.** Every question offers it. The phrases *du bestemmer, jeg er ligeglad, ved ikke, det må du vælge, whatever, gør bare noget godt* count too. Scope:
   - one question → that question;
   - "du bestemmer resten af <sektion>" → the remaining questions in that section;
   - "du bestemmer resten" → everything left; jump to the recap.
   A delegated question takes the default from `references/decision-tree.md` (adapted to the surface type and never against a pin or brand commitment), is marked `delegated` with a one-line reason, and counts as settled so later questions unlock.
5. **Must vs leaning.** In pass A an answer is a `leaning` (evidence for impeccable), unless the user says it's a must ("det SKAL være mørkt") → `pinned`. Leanings steer impeccable's directions without killing its variety; pins are hard constraints.
6. **Small rounds.** At most 4 comparisons per page, at most 3 pages per pass. Stop a section when it's settled.
7. **Every question ends in one state:** `user`, `delegated`, `pinned`, `leaning` or `n/a`. The interview is done when none is open. Then recap and wait for "godkendt".

## Three passes (each tied to a step of define-design)

- **Pass A: before the look exists** (define-design step 2, "feel round"). The pass-A facts from the decision tree (surface, key screen, mobile, brand assets, references, tone, accessibility), asked together with impeccable's new-work step 2 questions in one round so nothing is asked twice, plus up to 8 neutral this-or-that pairs on the axes impeccable doesn't ask in words: dense↔airy, quiet↔loud, soft↔sharp, warm↔cool, flat↔layered, still↔lively, plain↔ornamented, light↔dark scene. Plus one "never this" row with four rendered clichés (purple gradient, grey card grid, neon on black, cream serif). Render the pairs with neutral content from PRODUCT.md in plain greyscale-plus-one-accent, never as named styles ("brutalist", "glassmorphism", "Apple-agtigt"): impeccable forbids canned aesthetic lanes, and these pairs are evidence about feel, not a pick of a look. Output: leanings and pins, handed to impeccable as evidence before `concept-seed`. Leanings never pre-fill impeccable's "steer" line; that line is only the user's own words when they re-roll.
- **Pass B: impeccable's direction round** (define-design step 6). Unchanged: impeccable deals the directions, define-design shows them. "Du bestemmer" here means **take the direction impeccable dealt**, logged `delegated`. Never recommend the canon (category-standard) card; it is the user's door only, as impeccable requires.
- **Pass C: inside the chosen look** (define-design step 7). Component this-or-that rendered **in the chosen colours and fonts**: accent strength, status colours on real data, type pairing, table density, app shell (sidebar vs top nav), radius, surfaces (border / tint / shadow), background, button set with live hover and press, card hover, nav active state, forms and errors, motion level, chart style, empty/loading/error states, icons, imagery, dark mode. Set the page's `base` to the chosen direction's tokens so every candidate differs only in the one thing being asked. Answers go to define-design, which writes them into `component-states.md`.

## The comparison page

- Build one self-contained HTML page per round from `assets/compare-template.html`: fill its `CONFIG` block (rows, candidates as CSS-variable sets, real content from PRODUCT.md) and nothing else. The same markup renders under each candidate's variables, so the comparison is fair and hover/focus are live. Each row shows the candidates labelled A, B (C) with one short plain-Danish caption each ("Kompakt: flere rækker på skærmen"). Motion candidates loop.
- Show it to the user: publish it with the Artifact tool when available (load `artifact-design` first); otherwise send it with SendUserFile. Render pages in a subagent when many are needed; subagents return only the file path.
- **Collect the choices in the main thread** with the structured question tool (AskUserQuestion): one question per row (at most 4 per call), options `A`, `B` (`C`) and `Du bestemmer`, with a short preview per option when the tool supports previews. Sections and "resten" can be delegated in the free-text answer. More than 4 rows → the next call. No question tool → ask in plain text: "Skriv fx: 1A, 2B, 3 du bestemmer".
- Never use a cloud design canvas (Superdesign, v0, Stitch) for the interview; the page loads nothing but Google Fonts.

## The log: `docs/design/decisions.md`

Append-only. Create it from `references/decisions-template.md` if missing. One row per settled question: `id | question | answer | status | by | alternatives rejected | lands in | revisit trigger | date`. First line of the file: "DESIGN.md and component-states.md win on conflict; this file records why and who." It holds no values of its own; every "lands in" target must exist before define-design's gate. Answers that land in `PRODUCT.md` (brand commitments, voice, accessibility needs) are handed to define-design, which fills the missing field through impeccable; this skill never edits PRODUCT.md.

## Recap and gate

Show a Danish recap of 10 lines or fewer: what the user chose, what you chose for them ("Jeg valgte 6 ting for dig: …"), what's pinned, and what goes to impeccable next. Wait for "godkendt". Then return control to `define-design` (or askmatt).

## Revisit mode ("revisit designet", or askmatt after something is built)

Take every `delegated` row in decisions.md that has a built screen. Show each as a screenshot of the real UI (via `visual-qa`) next to one rendered alternative: "behold / skift / du bestemmer". A change is logged `revisited` and becomes a ticket via `build-handoff` (the matching impeccable command, run in the Code tab).

## Redesign mode ("designet er kedeligt/grimt/ligner AI")

First `visual-qa` screenshots and impeccable `critique` (read-only); askmatt usually has them already, otherwise run them now. **Local problem** (one component family, hover, spacing, a flat section) → pass C for only those sections, delegated items first → one ticket with the impeccable command (`bolder`, `colorize`, `typeset`, `layout`, `delight`, `polish`). **Whole look** (critique says generic, or the user says "helt nyt") → pass A with the current look as an anti-reference → define-design step 6 (impeccable replace flow) → pass C.
