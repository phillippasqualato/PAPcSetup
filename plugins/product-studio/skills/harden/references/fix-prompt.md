# Code-tab fix prompt (after FIX-FIRST)

Fill it and give it in one fenced block. Keep the detail in the tickets and the log.

```
/harden fandt fejl i PR #<n> (run <run-id>, se PLAN-REVIEW-LOG.md og harden/<run-id>/).
Læs AGENTS.md og følg den.

Brug receiving-code-review på fundene: verificér hvert fund mod koden før du retter. Er du uenig, så skriv beviset som en PR-kommentar til næste inspektør; drop aldrig et fund selv.
Kør derefter /build-ticket --fix #<n> på hver fix-ticket: samme worktree og branch som PR #<n>, git pull først, ingen ny PR, test først.

Ret disse tickets i rækkefølge:
1. #<a> <title> (blocker)
2. #<b> <title> (major)
...
For hver: skriv først en test der fejler og beviser fejlen (Playwright, pgTAP eller unit som ticket'en angiver), ret så koden, og kør testen grøn.
<If NOT RUN stages:> Kør også de trin som ikke kunne køre i Cowork: <commands>.
Kør typecheck, lint, tests og build. Push til PR'en.
Kør derefter /harden igen på det nye commit (fix-runde <k> af 2). Du må ikke selv skrive SHIP: dommen kommer fra den uafhængige inspektør.
Hvis en ticket kræver en produktbeslutning, så stop og spørg mig.
```
