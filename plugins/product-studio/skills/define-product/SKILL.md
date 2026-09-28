---
name: define-product
description: Define what a product is and why it exists, by orchestrating Matt Pocock's grilling and domain-modeling skills (plus research, competitive briefs, logic prototypes and stakeholder questionnaires when needed), and record the result in an impeccable-compatible PRODUCT.md and CONTEXT.md. Product phase called by start-project or askmatt, or when the user explicitly asks to define the product.
---

# Define Product

Orchestrate; don't improvise the method. The interview engine is `product-studio:grilling`, the language discipline is `product-studio:domain-modeling`. This skill adds the no-coder framing, the order, and the outputs. Danish in conversation, English in files.

## Order of play

1. **Load the engines.** Invoke `product-studio:grilling` and `product-studio:domain-modeling` (Matt's `grill-with-docs` pairing). If refused as user-only, read their SKILL.md files and follow them. From here on their rules govern: design tree, frontier rounds, numbered questions each with `➡️` a recommended answer, facts are yours and decisions are the user's, CONTEXT.md updated the moment a term settles, ADRs only when hard to reverse + surprising + a real tradeoff.
2. **Write back the idea** (brainstorming principle): 3-6 bullets on outcome, audience, success; "what you said" vs "what I assume". Correct before going on. This is the tree's root.
   - **Raw idea?** If the user can't yet say who it's for or what problem it solves, first run `product-studio:idea-refine` (user-only: read `../idea-refine/SKILL.md`): variations (inversion, 10x simpler, another audience), painkiller vs vitamin, and a Not Doing list. Its output seeds the tree; it is not saved to `docs/ideas/`.
3. **Scope check.** Several independent products hiding in one idea? Say so, pick the first. Too foggy for one session? Hand to `product-studio:wayfinder` (the start-project conductor resumes after).
4. **Grill.** Seed the design tree from `references/question-bank.md`. Ask the full frontier each round; cap at ~7 questions, holding the rest for the next round. Plain Danish, concrete scenarios ("Mette fra økonomi logger ind mandag og ser 40 ubetalte fakturaer…"). Challenge fuzzy words on the spot ("kunde", "bruger", "ordre", "konto"). Three extra habits: add a confidence line to your recommendation when you're guessing ("➡️ B, ~60% sikker, fordi…"); ask once per product "hvis du ikke skulle forsvare det over for nogen, hvad ville du så bygge?" to separate want from should-want; and treat "lyder godt", "hvad du synes" or silence as not yet a decision: restate and ask for the explicit choice.
5. **Pull in specialists only when the tree needs them** (run them without blocking the rest of the round):
   - Outside facts (regulation, competitors' pricing, an API's limits) → `product-studio:research` in the background.
   - Competitive landscape matters to positioning → `product-management:competitive-brief` if installed; otherwise `research`.
   - A business rule can't be settled in words (states, approvals, calculations) → `product-studio:prototype` (logic branch): a single clickable HTML file the user can drive, published as an artifact.
   - The answer sits with someone else (a customer, an accountant) → `product-studio:to-questionnaire`.
6. **MVP cuts.** When jobs and users are clear, offer 2-3 MVP cuts (smallest useful / sellable v1 / demo that wins the meeting) with your recommendation. YAGNI.
7. **Write `PRODUCT.md`** (with an explicit Out of scope / Non-goals list, including idea-refine's Not Doing items) in the impeccable schema from `../start-project/references/docs-layout.md` (root of the repo; update rather than replace an existing one). Keep it readable for a non-developer; no technology.
8. **Gate.** ≤10-bullet summary + file list: "Er det her produktet? Skriv godkendt, eller ret mig." The frontier must be empty: every branch visited, nothing silently assumed.

## Done when

`PRODUCT.md` and `CONTEXT.md` reflect the approved understanding, open questions name where they'll be resolved, and the user said "godkendt".
