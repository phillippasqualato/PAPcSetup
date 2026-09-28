# Workflow-kort: /ship (afslut og gør klar; vis kort ved start)

Alt arbejde sker på en release-gren `release/vX.Y.Z` med én PR. Faser markeret **CT** kører i Code-fanen.

| Fase | Hvad sker der | Skills og agenter | Du får |
|---|---|---|---|
| 0 Status | Hvad er bygget vs. MVP, hvad er åbent, versionsnummer | projektfiler, GitHub | Et klart billede |
| 1 Luk scope | Hvert åbent punkt: nu, efter lancering, eller droppes. Release-gren oprettes | `grilling`, `build-handoff` | En låst lanceringsliste |
| 2 Oprydning (CT) | Halvfærdig kode, død kode, tekster, design | skills `placeholder-scan`, `improve-codebase-architecture`, `impeccable audit`, `design:ux-copy`; agenter `code-simplifier`, `comment-analyzer` | Rettelser på release-grenen via `build-ticket` |
| 3 Klar til drift | Domæne, e-mail, backups, overvågning, sikkerhed, SEO, GDPR, jura | agenter `launch-readiness-auditor`, `web-performance-auditor`; `performance-optimization`, launch-checklist | Agent-rettelser + din kliks-liste |
| 4 Overdragelse (CT) | README, runbook, changelog, opdaterede docs | agent `technical-doc-writer`, `claude-md-improver`, agent `toolchain-auditor` | Dokumentation |
| 5 Sidste harden (CT) | Hele test- og dom-flowet på den endelige kandidat, L2/L3, alle trin | `harden` (+ `claude-security`) | SHIP |
| 6 Release (CT) | Go/no-go, merge, tag, røgtest i produktion, rollback klar | `visual-qa`, GitHub release | Produktet er live |
| 7 Afslutning (CT) | Log-PR, retro, backlog efter lancering | `retro`, `askmatt` | Plan for uge 1 |
