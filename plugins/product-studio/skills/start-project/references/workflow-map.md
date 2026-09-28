# Workflow-kort: /start-project (vis det for brugeren ved start, på dansk)

| Fase | Hvad sker der | Skills og agenter | Du får |
|---|---|---|---|
| 0 Placering | Finder mappen og repoet, ser hvilke værktøjer der er forbundet | inventory, `SearchPlugins` | Et repo og en liste over forbindelser |
| 1 Produkt | Du bliver grillet med anbefalede svar, begreberne låses fast | `define-product` → (`idea-refine` hvis idéen er rå), `grilling`, `domain-modeling`, `research`, `prototype`, `to-questionnaire` | `PRODUCT.md`, `CONTEXT.md` |
| 2 Teknik | AI'en designer arkitekturen og spørger kun om forretningsvalg | `define-tech` → `supabase`, `supabase-postgres-best-practices`, `research`, agent `supabase-security-reviewer`, `security-and-hardening`, `observability-and-instrumentation`, `api-and-interface-design`, `source-driven-development` | `docs/tech.md`, ADR'er |
| 3 Værktøjskæde (baggrund) | Finder de bedste plugins/MCP'er, tegner dataflow, jagter konflikter | `define-toolchain` → agenter `integration-scout`, `toolchain-auditor` | `docs/toolchain.md`, `.mcp.json`, højst 5 klik til dig |
| 4 Design | Overfladetype, referencer, retninger du kan klikke i, alle tilstande | `define-design` → `grill-design` (du vælger ved at klikke, eller siger "du bestemmer"), `impeccable`, `anydesign`, `ui-ux-pro-max`, `ui-design-fundamentals`, `web-design-guidelines`, `design:*` | `DESIGN.md`, retningsside, `component-states.md` |
| 5 Overdragelse | Regler til kodeagenten, spec, tickets, prompt til Code-fanen | `build-handoff` → `setup-matt-pocock-skills`, `to-spec`, `to-tickets`, `constraint-driven-development` | `AGENTS.md`, `CONSTRAINTS.md`, GitHub-issues, prompt til `/build-ticket` |
| 6 Slut-audit | Tjekker at alt hænger sammen | agent `toolchain-auditor`, `claude-md-improver` | Grønt lys til at bygge |
