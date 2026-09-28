# Code-tab prompt template

Fill it and give it to the user in one fenced block. Keep it short: the repo carries the detail.

## GitHub version

If Cowork couldn't reach GitHub, put this step 0 first (only the lines that apply):

```
0. Forberedelse (kun én gang): opret GitHub-repoet privat med `gh repo create <owner>/<name> --private --source . --push` (eller push til det eksisterende remote), opret labels (`gh label create ... --force`), og udgiv tickets fra docs/specs/<feature>/tickets/ som GitHub-issues i nummerorden med deres blockers. Vis mig issue-listen.
```

Then:

```
Du arbejder i repoet <owner/repo> (lokalt: <path>).
Læs AGENTS.md (CLAUDE.md importerer den) og følg den præcist, inkl. "Read before any task" og "Definition of done".

Opgave: byg ticket #<n> "<title>" (<issue URL>).
<If a multi-ticket build:> Når den er merged, tag næste ticket hvis blockers er lukket, i rækkefølgen #<a>, #<b>, #<c>. Stop efter hver PR og vis mig preview-URL'en.

Arbejd sådan:
1. Kør /build-ticket #<n>: den laver en worktree, skriver en plan i docs/plans/, viser mig et kort resumé til godkendelse, bygger planen (Superpowers: test først, review pr. opgave) og åbner en PR med "Rulings I made".
2. Vis mig preview-URL'en.
3. Kør /harden på PR'en. Du må ikke selv godkende dit arbejde; dommen kommer fra den uafhængige inspektør. Ved FIX-FIRST: ret de tickets den laver og kør /harden igen (højst 2 runder).
Før planen er godkendt: spørg mig om det uklare. Efter godkendelse: tag beslutningen, skriv den i PR'en, og stop kun ved de fem stop i AGENTS.md.
```

## Local-ticket version (no GitHub remote yet)

```
Du arbejder i repoet i mappen <path>.
Læs AGENTS.md (CLAUDE.md importerer den) og følg den præcist, inkl. "Read before any task" og "Definition of done".

Opgave: byg ticket docs/specs/<feature>/tickets/01-<slug>.md. Tag derefter de næste i nummerorden, når deres "Blocked by" er færdige, og sæt Status til done i filen.
Brug /build-ticket på hver ticket-fil (worktree, plan til godkendelse, test først). Uden GitHub-remote: behold grenen i stedet for en PR og vis mig testoutput. Stop efter hver ticket.
Hvis noget er uklart eller strider mod docs, så stop og spørg mig.
```
