# PAPcSetup

Phillips eget Claude-operativsystem. To lag, ét repo:

| Lag | Hvad | Hvornår |
|---|---|---|
| **papc-core** | Regler, navigation, sikkerhedsvagter, kontekst-nudge og styret læring | Kører altid, i Claude Code og Cowork. Du starter den ikke |
| **product-studio** | Hele produktforløbet: `/start-project` → `/askmatt` → `/build-ticket` → `/harden` → `/ship` | Når du bygger et produkt |

**Husk tre kommandoer:** `/papc` (kortet), `/askmatt` (alt i et produkt), `/papc-learn` (efter en større opgave).

## Installation (én gang)

**1. Slå dubletterne fra.** Se [docs/DEDUP.md](docs/DEDUP.md). Kort: superpowers, pr-review-toolkit, feature-dev, code-review, claude-md-management, claude-memory, security-guidance, frontend-design, engineering, productivity.

**2. Claude Code** (terminal eller Code-fanen):
```
/plugin marketplace add phillippasqualato/PAPcSetup
/plugin install papc-core@papcsetup
/plugin install product-studio@papcsetup
```
Genstart sessionen. Opdatér senere med `/plugin marketplace update papcsetup`.

**3. Cowork / claude.ai:** kør `scripts/package.sh` og upload `dist/papc-core.zip` (og `dist/product-studio.zip`, der erstatter din nuværende upload) i Claudes plugin-indstillinger.

**Kun én kanal pr. plugin.** Hvis product-studio både er uploadet og installeret fra marketplace i samme app, har du alt to gange. `/papc-doctor` fanger det.

**4. Tjek:** skriv `/papc-doctor`. Målet er "Result: clean".

## Hvad papc-core gør

| Del | Effekt | Koster |
|---|---|---|
| SessionStart: `CORE.md` + `LESSONS.md` | Hver session kender prioritet, navigation og dine arbejdsregler | ~3 KB kontekst, max 6 KB |
| Guard (Bash) | Blokerer `--no-verify`, force-push til main, `rm -rf /` eller `~` | 0 credits (bash) |
| Config-vagt | Spørger dig før lint/test/type-config ændres | 0 credits |
| Kontekst-nudge | Én linje ved ~200k tokens: komprimér ved næste fase-skifte | 0 credits |
| `/papc` | Kortet: hvilket værktøj til hvad | kun når brugt |
| `/papc-doctor` | Finder dubletter, dyre hooks, kollisioner, for stor kontekst, secrets | kun når brugt |
| `/papc-learn` | Refleksion + max 3 læringer, du godkender | kun når brugt |

Ingen hooks kalder en model. Ingen baggrundsagenter.

## Læring uden at det løber løbsk
- Intet læres automatisk. Kun `/papc-learn`, og kun med dit ja.
- Projektlæring → projektets `AGENTS.md`/`CLAUDE.md` (max 15 linjer).
- Global læring → `plugins/papc-core/core/LESSONS.md` her i repoet (max 25 linjer, versioneret i git, så du kan se og fortryde alt).
- Fakta om dig → claude.ai memory. Arbejdsregler → lessons. Aldrig begge.
- `/papc-learn review` rydder op i gamle eller engangs-læringer.

## Hvem bestemmer
Din besked nu → papc-core → projektets AGENTS.md/CLAUDE.md → product-studio → andre plugins.

## Struktur
```
.claude-plugin/marketplace.json   marketplace "papcsetup"
plugins/papc-core/                kernen (core/, hooks/, skills/, scripts/doctor.sh)
plugins/product-studio/           produktmotoren (v0.8.1)
docs/DEDUP.md                     hvad der er slået fra og hvorfor
docs/ECC-HARVEST.md               hvad vi tog fra ECC og hvad vi lod ligge
scripts/package.sh                zip til Cowork-upload
```

## Udvide systemet
Ny skill/plugin/"AI OS"? Spørg først: hvilket hul fylder det, og hvem ejer jobbet i dag? Høst det ene stykke ind i papc-core eller product-studio i stedet for at installere hele pakken. Kør `/papc-doctor` bagefter.

Licens: MIT. Dele er omskrevet fra [affaan-m/ECC](https://github.com/affaan-m/ECC) (MIT, se `plugins/papc-core/licenses/`). product-studio har sine egne licenser i `plugins/product-studio/licenses/`.
