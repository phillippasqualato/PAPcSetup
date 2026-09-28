# Scoreboard format (`docs/audit/SCOREBOARD.md`)

Overwritten each run. Danish, plain words, one row per area. Status words: **GRØN** (bar met), **GUL** (improving, rounds left), **RØD** (blocker: go to /harden), **STOPPET** (+ reason: maks runder / ingen fremgang / svinger / kræver beslutning), **IKKE MÅLT** (tool not set up). In the weekly board, an area only measured in manual runs keeps its last status with "(sidst målt <dato>)" in the Nu column.

```
# Kvalitetstavle — 2026-09-28 (main @ a1b2c3d, prod)
| Område           | Status       | Nu                  | Sidst   | Mål        | Runder | Næste skridt              |
|------------------|--------------|---------------------|---------|------------|--------|---------------------------|
| Tilgængelighed   | GUL          | 3 alvorlige fejl    | 7       | 0          | 1/3    | Ticket #41 (kontrast)     |
| Performance      | GRØN         | LCP 2,1 s           | 2,4 s   | ≤ 2,5 s    | 1/3    | –                         |
| Data og RLS      | RØD          | 1 tabel uden test   | 1       | 0          | 0/2    | Kør /harden (blokerende)  |
| Tekst og sprog   | STOPPET      | 12 ukendte ord      | 12      | 0          | 2/2    | Du skal beslutte ordliste |
| SEO              | IKKE MÅLT    | –                   | –       | –          | –      | Installér Lighthouse CI   |
Skjulte/undertrykte fund: 0 (steg ikke)   ·   Budget brugt: 2 af 3 runder
```

`docs/audit/history.jsonl`, one line per area per run:

```json
{"run_id":"20260928-0717-a1b2c3d","sha":"a1b2c3d","env":"prod","area":"a11y","metric":"axe_serious_critical","value":3,"previous":7,"target":0,"suppressed":0,"status":"GUL","round":"1/3"}
```
