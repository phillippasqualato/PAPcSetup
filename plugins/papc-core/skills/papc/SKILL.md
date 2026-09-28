---
name: papc
description: Show Phillip's PAPcSetup map - which single command or plugin to use for the situation, in Danish. Use when the user types "/papc", asks "hvad skal jeg bruge", "hvilket værktøj", "hvordan virker mit setup", "hjælp til mit setup", or is unsure which command to start with. Not for ordinary requests that merely contain "hjælp". For product-specific commands product-studio's /studio goes deeper.
---

# PAPc (kortet)

Show this in Danish, then ask one question: "Hvad vil du lave?" If the user already said what they want, skip the question and name the one command that fits.

```
PAPcSetup: to lag

  papc-core      kører altid (regler, vagter, læring). Du skal ikke starte den.
  product-studio når du bygger et produkt

  Ny produktidé            → /start-project       (Cowork)
  Alt i et produkt         → /askmatt             (finder selv den rigtige vej)
  Byg én ticket            → /build-ticket        (Code-fanen)
  Er det godt nok?         → /harden              (uafhængig dom)
  Vi skal i luften         → /ship
  Designvalg               → /grill-design
  Ikke-produkt             → salg, data, Canva, Figma, Notion: bare sig det
  Setuppet driller/er tungt→ /papc-doctor
  Efter en større opgave   → /papc-learn          (gem højst 3 læringer, du godkender)

  Husk: /papc = dette kort · /studio = product-studios eget kort
```

Pick the 2-3 examples closest to what the user just said:
- `/start-project Jeg vil bygge en app hvor golfspillere får råd til næste slag`
- `/askmatt knappen virker ikke på mobil`
- `/papc-doctor det føles langsomt og dyrt`
- `/papc-learn` efter en færdig feature

Rules: one command per answer. If the request is ordinary (a question, a text, a quick fix), just do it without routing.
