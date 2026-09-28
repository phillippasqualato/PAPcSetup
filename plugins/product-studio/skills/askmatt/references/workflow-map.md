# Workflow-kort: /askmatt (ask-matt for hele værktøjskassen; vis kort ved start)

| Trin | Hvad sker der | Skills og agenter |
|---|---|---|
| 0 Indlæs og kig | Læser projektets filer og værktøjer, kigger på den live app | catalog, agent `code-explorer`, `visual-qa` |
| 1 Opdel og sortér | Deler din besked op i punkter, finder vejen for hvert og siger om det er et forsøg, en lille eller en stor ændring | routing-tabellen i SKILL.md |
| 2 Skærp | Spørger ind, når noget er uklart | `grilling`, `domain-modeling`, `prototype`, `research` |
| 3 Opdatér sandheden | Retter produkt-, teknik-, design- eller værktøjsfiler | `define-product`, `define-tech`, `define-design` (`impeccable`, `anydesign`), `define-toolchain` |
| 4 Byg | Cowork: tickets + prompt. Code-fanen: bygger efter dit "godkendt" | `build-handoff` → `to-spec`, `to-tickets`; `build-ticket` → `using-git-worktrees`, `writing-plans`, `subagent-driven-development`/`executing-plans`, `test-driven-development`, `requesting-code-review`, `finishing-a-development-branch` |
| 5 Dom | Uafhængig test og dom før merge | `harden` |

Typiske veje: design → `impeccable critique` + ticket · fejl → `diagnosing-bugs`/`systematic-debugging` · stor tåget opgave → `wayfinder` · ny service → fuld hovedvej + `integration-scout` · anden models mening → `claudex-route`/`claudex-loop` · mange indkomne fejl → `triage` · designet er kedeligt → `grill-design` · gennemgå alt / hver uge → `audit-loop` · langsomt → `performance-optimization` · omdøb/fjern kolonne → `deprecation-and-migration`
