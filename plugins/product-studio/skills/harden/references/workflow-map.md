# Workflow-kort: /harden (den der bygger, godkender aldrig; vis kort ved start)

| Trin | Hvad sker der | Skills og agenter | Stopper ved |
|---|---|---|---|
| 0 Opsætning | Mål, ren snapshot, vælg uafhængighedsniveau | `claudex-loop` (L3) eller agent `adversarial-inspector` (L2) | Uncommittede ændringer |
| 1 Statiske tjek | Build, typer, tests, lækkede nøgler, sårbare pakker, usikker kode, halvfærdig kode, svækkede tests | gitleaks, trufflehog, osv-scanner, Semgrep, `placeholder-scan`, floor-guard (`constraint-driven-development`) | Build fejler, bekræftet nøgle |
| 2 Database | RLS bevist med tests: A, B og udlogget | agent `supabase-security-reviewer`, `supabase`, pgTAP-skabelon | Data kan ses på tværs |
| 3 Leaks | Nøgler, bundles, over-fetching, persondata, headers | agent `leak-hunter`, `claude-security` (Code-fanen) | Lækage |
| 4 Corner cases | "Valg X ødelægger Y", samtidighed, grænser | agent `corner-case-hunter` | — |
| 5 Klik-test og design | Alle knapper, hovers, formularer, roller; grafer og kort mod DESIGN.md | agent `e2e-explorer`, `dogfood`, `ui-design-fundamentals` | Kerne-flow virker ikke |
| 6 Uvildig inspektion | En anden model/isoleret agent dømmer koden | `claudex-loop` eller `adversarial-inspector` + `code-review` + review-agenter; dømmer også byggerens "Rulings I made" | REVISE |
| 7 Dom og log | Hvert fund prøves, dom i loggen, PR blokeres ved fejl | agent `finding-verifier`, `PLAN-REVIEW-LOG.md`, CI-gate | FIX-FIRST / BLOCKED |
| 8 Rettelser | Fejl-tickets og prompt til Code-fanen, højst 2 runder | `build-handoff` → Code-fanen: `receiving-code-review` + `build-ticket` | 3. FIX-FIRST går til dig |
