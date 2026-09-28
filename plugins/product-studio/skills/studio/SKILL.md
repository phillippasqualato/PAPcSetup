---
name: studio
description: Show the product-studio cheat sheet - the two commands to remember (start-project, askmatt) plus the shortcuts (build-ticket, harden, ship, grill-design, audit-loop), where to type them, and example sentences - plus a situation-by-situation usage guide, so the user can remember what to type. Use when the user says "/studio", "hvad hedder kommandoerne", "hvilken kommando skal jeg bruge", "hjælp", "hvad kan product-studio", "hvordan bruger jeg det", or seems unsure which workflow to start.
---

# Studio (husk-kortet)

Show exactly this, in Danish, then ask one question: "Hvor er du lige nu?" and suggest the command that fits what the user just said, if anything.

```
product-studio: husk kun to

  /start-project   Jeg har en ny idé        → definerer alt, før der kodes   (Cowork)
  /askmatt         Alt andet                → forstår hvad du vil, og starter
                                               de rigtige skills, flows og agenter  (begge steder)

  Genveje (askmatt finder dem selv, hvis du glemmer dem):
  /build-ticket    Byg den her ticket       → plan, test først, PR           (Code-fanen)
  /harden          Er det godt nok?         → brutal test + uafhængig dom
  /ship            Vi skal i luften         → afslut, tjek drift, release
  /grill-design    Hjælp mig med designet   → du klikker mellem eksempler, eller "du bestemmer"
  /audit-loop      Gennemgå alt             → måler alle områder, retter, måler igen; kvalitetstavle

  Den der bygger, godkender aldrig sig selv. /harden giver dommen.

  /askmatt alene   → statusbriefing: hvor er vi, og hvad er næste skridt
  /studio          → dette kort          /studio guide → situationsguiden
```

Examples to show underneath (pick the 3 closest to the user's situation):
- `/start-project Jeg vil bygge en app hvor små klinikker kan booke og følge op på patienter`
- `/askmatt kortene ser billige ud, og filteret nulstilles når jeg skifter side`
- `/build-ticket #4` (i Code-fanen)
- `/harden` på den PR, Code-fanen lige har lavet
- `/ship vi skal lancere v1.0`

**`/studio guide`, or when the user asks how to use it in a specific situation:** show the matching rows of `references/usage-guide.md` (all of it only if asked). It is situation → what you type → what happens → what you do.

Where to type them: `/start-project` and `/ship` start best in Cowork (planning, browser); `/askmatt` works in both; `/build-ticket` only in the Code tab (it needs git and the dev server); `/harden` gives its full verdict in the Code tab. Full picture: the "Product Studio Workflows" page, and `README.md` in the plugin.
