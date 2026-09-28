# Brugsguide: situation → hvad du skriver → hvad der sker → hvad du gør

Written in Danish on purpose: it is shown to the user as is.

## Husk kun to: `/start-project` (ny idé) og `/askmatt` (alt andet)

De andre er genveje. Skriver du bare hvad du vil til `/askmatt`, starter den dem selv.

| Kommando | Hvad den er | Hvor |
|---|---|---|
| `/start-project` | Fra idé til byggeklar plan: produkt, teknik, værktøjer, design, tickets | Cowork |
| `/askmatt` | Din rådgiver: finder det rigtige værktøj til det, du vil ændre, og laver tickets | Cowork eller Code-fanen |
| `/build-ticket` | Bygger én ticket: egen arbejdskopi, plan du godkender, test først, PR | Code-fanen |
| `/harden` | Uafhængig brutal test og dom (SHIP / FIX-FIRST / BLOCKED) | Code-fanen (Cowork kan lave en del) |
| `/ship` | Afslut og lancér: scope, oprydning, drift, dokumentation, release | Starter i Cowork, slutter i Code-fanen |

## Situationer

| Situation | Du skriver | Hvad der sker | Hvad du gør |
|---|---|---|---|
| Du har en ny idé | Cowork: `/start-project <idéen i én sætning>` | Du bliver spurgt ind med anbefalede svar, så laves teknik, værktøjer, design og tickets | Svar på spørgsmålene, skriv "godkendt" ved hver port, klik de højst 5 opsætningstrin |
| Idéen er stadig tåget | Cowork: `/start-project` og sig "idéen er rå" | Først variationer og en "det gør vi ikke"-liste (`idea-refine`), så grilling | Vælg retningen |
| Planen er klar, der skal bygges | Code-fanen: indsæt prompten fra `/start-project`, eller `/build-ticket #1` | Arbejdskopi, en plan på dansk til dig, bygning med test først, PR med "Rulings I made" | Læs det korte resumé, skriv "godkendt", se preview-linket |
| Du vil bygge næste ticket | Code-fanen: `/build-ticket` (uden nummer = næste klar ticket) | Den finder næste ticket der ikke er blokeret | Godkend planen |
| Du vil ændre noget lille | `/askmatt <hvad du vil>` | Den klassificerer (forsøg / lille / stor), laver én ticket mærket `size:bounded` | Godkend, byg med `/build-ticket` (ingen plan-dokument, går hurtigt) |
| Du vil have en stor ny funktion | `/askmatt <funktionen>` | Grilling, evt. prototype, spec og flere tickets | Godkend spec, byg én ticket ad gangen |
| Du vil bestemme designet grundigt | `/askmatt grill mig på designet` (eller `/grill-design`) | Faktaspørgsmål i ord, smag som små eksempler side om side du klikker imellem | Vælg A/B, eller sig "du bestemmer" til et spørgsmål, en sektion eller resten |
| Du vil have en bestemt komponent, graf eller animation (fx fra Kokonut, Bklit, Motion, shadcn, 21st) | `/askmatt find en animeret graf til overblikket` | Viser 2-3 rigtige eksempler fra sitet, du vælger, Code-fanen installerer og tilpasser dem til dine farver | Vælg A/B/C eller sig "du bestemmer" |
| Noget ser forkert eller billigt ud | `/askmatt` + et skærmbillede | Den kigger på den live side, laver en design-kritik og en mock | Godkend mocken; Code-fanen kører impeccable-kommandoen |
| Noget er i stykker | `/askmatt <hvad der sker>` | Genskaber fejlen, finder årsagen, ticket med en test der beviser fejlen | Godkend, byg |
| Det er langsomt | `/askmatt det er langsomt på <side>` | Måler først (rigtige tal), retter, måler igen | Godkend ticket |
| En kolonne eller funktion skal omdøbes/fjernes | `/askmatt omdøb <x> til <y>` | Plan i tre trin (udvid → flyt → fjern), så intet går i stykker undervejs | Godkend tickets |
| Ny service (betaling, e-mail, AI) | `/askmatt vi skal have <service>` | Fuld vej: produktspørgsmål, teknik, sikkerhed, værktøjer, tickets | Svar på forretningsvalg (pris, moms, test-nøgler) |
| En PR er klar | Code-fanen: `/harden #<PR-nummer>` | 8 trin: tjek, database, leaks, corner cases, klik-test, uafhængig dom, log | SHIP: merge. FIX-FIRST: indsæt fix-prompten (`/build-ticket --fix`). BLOCKED: læs hvorfor |
| Du vil have alt gennemgået | `/askmatt gennemgå alt` (eller `/audit-loop`) | Måler 10 områder med faste værktøjer, en uafhængig dommer finder fejl, højst 3 tickets pr. område, retter, måler igen | Læs kvalitetstavlen, sig "kør fix-runderne" |
| Det skal tjekkes hver uge | `/askmatt tjek det hver uge` | Ugentlig måling i GitHub og en planlagt opgave, der opdaterer kvalitetstavlen | Læs mandagens resumé |
| Du har glemt hvor I er | `/askmatt` alene | Statusbriefing og de 3 bedste næste skridt | Vælg ét |
| Mange ting på én gang | `/askmatt ret A, B og C, og kig designet igennem` | En tabel: punkt → vej → hvor | Godkend tabellen én gang |
| Du vil lancere | Cowork: `/ship vi lancerer v1.0` | Scope låses, oprydning, drifttjek, docs, sidste harden, release | Klik din tjekliste, skriv "godkendt" til go/no-go |
| En bygning gik skævt (looper, dyrt) | Code-fanen: `/diagnosing-superpowers` | Den læser sessionen og forklarer hvad der gik galt | Beslut ændringen |
| Du vil have en anden models mening | `/askmatt få Codex til at kigge` | Anbefaling eller en krydstjek med Codex | Kræver Codex logget ind på din Mac |
| Du har glemt kommandoerne | `/studio` | Dette kort | — |

## Det du skal huske om porte

- **"godkendt"** er dit ord. Intet går videre uden det: produkt, teknik, design, spec, plan, go-live.
- **Før** planen er godkendt spørger AI'en dig. **Efter** tager den selv de små beslutninger og skriver dem i PR'en under "Rulings I made". Den stopper kun ved fem ting: noget der ikke kan fortrydes, ny sikkerhed, noget uden for arbejdskopien (deploy, database-skriv), rent gætteri, eller noget der strider mod dine produkt- og designfiler.
- **Den der bygger, godkender aldrig.** `/harden` kører i en anden kontekst eller med en anden model.
- **Sandheden bor i GitHub-repoet.** Samtaler forsvinder, filerne bliver.
