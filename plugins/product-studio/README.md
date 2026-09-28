# product-studio 0.8

**Husk kun to kommandoer:**

| Kommando | Hvornår |
|---|---|
| `/start-project` | Du har en ny idé. Definerer produkt, teknik, værktøjer og design, og gør det klar til at bygge |
| `/askmatt` | Alt andet. Skriv hvad du vil, så finder den selv de rigtige skills, flows, agenter og plugins og starter dem |

**Genveje**, som `/askmatt` starter for dig, når du beder om det:

| Genvej | Hvad den gør |
|---|---|
| `/build-ticket` | Bygger én ticket i Code-fanen: egen arbejdskopi, en plan du godkender, test først, PR med alle beslutninger |
| `/harden` | Brutal test med en uafhængig dom. Den der bygger, godkender aldrig |
| `/ship` | Lukker scope, rydder op, tjekker drift, skriver overdragelse og releaser |
| `/grill-design` | Design-interview: du klikker mellem små eksempler side om side, eller siger "du bestemmer" |
| `/audit-loop` | Gennemgår alle områder (tilgængelighed, hastighed, sikkerhed, data, design, flows, tekst, SEO, kode) i runder, retter og måler igen. Kvalitetstavle og ugentlig kørsel |

Genvejene er egne skills af tre grunde: AI'en følger korte faste opskrifter bedre end én stor; `/harden` skal køre adskilt fra den der byggede, ellers dømmer den sit eget arbejde; og `/build-ticket` og `/ship` kører i Code-fanen og gør ting, der ikke kan fortrydes.

Du taler dansk med den, og filerne skrives på engelsk. Glemt noget? Skriv `/studio`. `/askmatt` alene giver en statusbriefing.

## Hvorfor et plugin?

Et plugin er én pakke med alle skills, agenter og indstillinger. Det giver tre ting:

1. **Ét klik at installere og opdatere.** Du slipper for 80+ skills hver for sig.
2. **De kan kalde hinanden.** En master-skill kan starte underskills og agenter, fordi de ligger i samme pakke (`product-studio:<navn>`).
3. **Samme opsætning overalt.** Installer det i både Cowork og Code-fanen, så arbejder begge ens.

## Hvad ligger under hver master

```
/start-project
├─ define-product    (idea-refine) · grilling · domain-modeling · research · prototype · to-questionnaire
├─ define-tech       supabase · supabase-postgres-best-practices · research · [supabase-security-reviewer]
│                    security-and-hardening · observability-and-instrumentation · api-and-interface-design · source-driven-development
├─ define-toolchain  [integration-scout] · [toolchain-auditor]   (kører i baggrunden)
├─ define-design     grill-design · ui-sources · impeccable · anydesign · ui-ux-pro-max · ui-design-fundamentals · web-design-guidelines · design:*
├─ build-handoff     setup-matt-pocock-skills · to-spec · to-tickets · constraint-driven-development
└─ slut-audit        [toolchain-auditor] · claude-md-improver

/askmatt
├─ indlæs og kig     [code-explorer] · visual-qa
├─ skærp             grilling · domain-modeling · prototype · research · wayfinder
├─ opdatér sandhed   define-product · define-tech · define-design · define-toolchain
├─ byg               build-handoff → /build-ticket
├─ særlige veje      diagnosing-bugs · systematic-debugging · performance-optimization · deprecation-and-migration
│                    triage · claudex-route · claudex-loop · handoff · wait-what
└─ dom               /harden

/build-ticket   (Code-fanen; Superpowers er motoren)
├─ 0 læs og klassificér   lille (bounded) eller planlagt
├─ 1 arbejdskopi          using-git-worktrees
├─ 2 plan + dit godkendt  writing-plans
├─ 3 byg, test først      subagent-driven-development / executing-plans · test-driven-development · verification-before-completion
├─ 4 PR                   requesting-code-review · finishing-a-development-branch  ("Rulings I made" i PR'en)
└─ 5 dom og rettelser     /harden · receiving-code-review

/harden
├─ 1 statiske tjek   gitleaks · trufflehog · osv-scanner · Semgrep · placeholder-scan · floor-guard · build/tests
├─ 2 database/RLS    [supabase-security-reviewer] · pgTAP-tests (A, B, udlogget)
├─ 3 leaks           [leak-hunter] + security-checklist · claude-security
├─ 4 corner cases    [corner-case-hunter]
├─ 5 klik og design  [e2e-explorer] · dogfood · ui-design-fundamentals
├─ 6 uvildig dom     claudex-loop (Codex) eller [adversarial-inspector] + code-review + [pr-code-reviewer] m.fl.
├─ 7 dom og log      [finding-verifier] · PLAN-REVIEW-LOG.md · CI-gate
└─ 8 rettelser       build-handoff → fejl-tickets → receiving-code-review + /build-ticket (højst 2 runder)

/audit-loop   (løbende kvalitet; /harden er stadig eneste port til merge)
├─ mål        faste værktøjer: axe, Lighthouse, Semgrep, impeccable detect, pgTAP, knip, cspell …
├─ døm        uafhængige agenter pr. område · [finding-verifier]
├─ ret        højst 3 tickets pr. område → /build-ticket → /harden
├─ mål igen   stop ved: bestået, maks runder, ingen fremgang, svinger, svækket test
└─ tavle      docs/audit/SCOREBOARD.md · ugentlig kørsel (GitHub + planlagt opgave)

/ship   (på en release-gren med én PR)
├─ 0-1 status/scope  grilling · build-handoff
├─ 2 oprydning       placeholder-scan · improve-codebase-architecture · impeccable audit · [code-simplifier] · [comment-analyzer]
├─ 3 klar til drift  [launch-readiness-auditor] · [web-performance-auditor] · launch-checklist (domæne, e-mail, backups, overvågning, GDPR …)
├─ 4 overdragelse    [technical-doc-writer] · claude-md-improver · CHANGELOG · runbook
├─ 5 sidste harden   /harden (go-live, L2/L3, alle trin) på den endelige kandidat
├─ 6 release         merge → tag → deploy · visual-qa på produktion · rollback klar
└─ 7 afslutning      log-PR · retro · backlog efter lancering

/studio   husk-kortet: de 5 kommandoer, hvornår og eksempler · /studio guide: hvad du skriver i hver situation
```
`[navn]` er en agent (en specialist, der arbejder i sin egen kontekst). Resten er skills.

## Kilder (licenser i `licenses/`)

- Matt Pocock (MIT)
- Superpowers 6.4.1 (MIT, uden den tvingende hook): motoren i Code-fanen
- Addy Osmani agent-skills (MIT): performance, sikkerhed, overvågning, migrering, API-design, kvalitetsbar
- claudex-loop (MIT)
- Anthropic officielle agenter og skills (Apache-2.0)
- Supabase, Vercel, shadcn og Next.js (MIT)
- impeccable (Apache-2.0, uden hooks)
- anydesign (MIT)
- ui-ux-pro-max (MIT)
- agent-browser dogfood (Apache-2.0)
- playwright-skill (MIT)
- claude-pipeline (MIT): ui-design-fundamentals og technical-doc-writer
- auto-orchestrate (MIT): placeholder-scan
- basejump supabase-test-helpers (MIT)

Det fulde katalog står i `skills/askmatt/references/catalog.md`: hvilket værktøj der vinder, når to kan det samme, samt agenter, plugins og MCP'er.

## Installér i Code-fanen også

1. Læg plugin-mappen i et privat GitHub-repo, eller pak `.plugin`-filen ud på din Mac.
2. Kør i Code-fanen: `/plugin marketplace add <dig>/product-studio` (eller stien til mappen) og derefter `/plugin install product-studio@product-studio`.
3. Installer ikke `mattpocock-skills`, `superpowers`-pluginnet (dets hook tvinger sin metode på hver session), Addys `agent-skills` eller vendor-pluginnene `supabase` og `vercel` ved siden af. Deres skills er allerede med.
4. Valgfrit til design-tunge projekter: `/impeccable hooks on` i Code-fanen (tjekker design efter hver UI-ændring; slås fra med `hooks off`).

## Ny (privat) Claude-konto: sådan sætter du op

Gør det i denne rækkefølge. Alt her er engangsarbejde.

**1. Pluginnet**
- Cowork: tilføj `product-studio.plugin` under plugins.
- Code-fanen (kræver trin 5 først, ellers kan Code-fanen ikke hente det private repo): læg plugin-mappen i et **privat** GitHub-repo, og kør `/plugin marketplace add <dig>/product-studio` og derefter `/plugin install product-studio@product-studio`.

**2. Forbindelser i Cowork**
- GitHub.
- Supabase som **custom connector** med den afgrænsede adresse (kun dev-projektet, kun læse): `https://mcp.supabase.com/mcp?project_ref=<DEV_REF>&read_only=true&features=database,docs,debugging,development`. Sæt `execute_sql` til "Needs approval". Brug ikke den almindelige Supabase-connector fra kataloget: den kan skrive i alle dine projekter.
- Vercel: sæt `deploy_to_vercel`, alle `buy_*` og `import-claude-design-from-url` til "Blocked". Deploy sker kun via GitHub.
- Claude in Chrome (til at kigge på previews).
- Senere, når du er live: Sentry. Stripe kun i sandbox.

**3. Anthropic-plugins i Cowork:** `engineering`, `product-management`, `design`.

**4. Code-fanen**
- Kør i Code-fanen: `/plugin install security-guidance@claude-plugins-official`, `/plugin install claude-security@claude-plugins-official` og `/plugin install typescript-lsp@claude-plugins-official`.
- Installer **ikke** `superpowers`, `mattpocock-skills` eller Addys `agent-skills`. Deres skills er allerede med.

**5. Programmer på din Mac** (Terminal, én gang, gør det før trin 1 i Code-fanen): har du ikke Homebrew, så installer det fra https://brew.sh. Kør så `brew install node gh supabase/tap/supabase gitleaks osv-scanner trufflehog semgrep`, `npm i -g typescript-language-server typescript`, og til sidst `gh auth login` (vælg GitHub.com → HTTPS → log ind i browseren).
- Valgfrit: Codex CLI (en anden model som dommer) og en container-motor (OrbStack eller Docker Desktop) til hurtige lokale databasetests.

**6. Dine egne skills:** har du selv lavet skills på arbejdskontoen (fx design- eller skrivestil-skills), skal de uploades igen.

**7. Workflow-siden:** bed Claude udgive `docs/product-studio-workflows.html` fra plugin-mappen som artifact på den nye konto.

## Godt at vide

- **Uafhængig dom fra en anden model:** Det kræver, at både Codex og Claude Code er logget ind på din Mac. Ellers bruges en isoleret inspektør-agent.
- **Hvad Cowork kan:** Cowork planlægger, kigger og dømmer design. Build, tests og go-live kræver Code-fanen.
- **Fravalgt med vilje:** `claude-playwright`, PeterHdd `agent-skills`, Karpathy-filen (idéerne er flettet ind i AGENTS.md), Superdesign, skill-optimizer og vibe-replay-pluginnet. Begrundelser og kandidater til senere står i kataloget §8.
- **Databasetests** kører i GitHub (`db-tests`-jobbet), så du behøver ikke Docker på din Mac.
- **Lange AI-kørsler** (fx en knap, der sender flere AI-agenter i gang på én gang) følger `define-tech/references/background-jobs.md`: Vercel Workflow, budget i koden, og scorer beregnet af koden, ikke af modellen.
- **impeccable** henter sin motor første gang, den kører. Premium-design-kilder (Motion+, Aceternity Pro m.fl.) koster penge.
