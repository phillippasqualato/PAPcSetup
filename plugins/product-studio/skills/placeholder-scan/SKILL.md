---
name: placeholder-scan
description: "Scan a codebase for unfinished work that must not ship - TODO/FIXME/HACK comments, not-implemented errors, empty bodies and stub returns (64 script patterns across 10 languages), plus a grep pass for mock data, lorem ipsum and debug logging - and report by severity. Used by the ship skill's completion sweep and harden's static gates. Scripts from ribatshepo/auto-orchestrate production-code-workflow (MIT)."
---

# Placeholder scan

Finds code that looks finished but isn't. Read-only.

## Run

```bash
python3 <this skill's base dir>/scripts/detect_placeholders.py -o table <repo>          # one path per run: the repo root
python3 <this skill's base dir>/scripts/detect_placeholders.py -o json -s major <repo>   # machine-readable, major and up
```

Needs Python 3.9+. It skips `node_modules`, `.next`, `.vercel`, `dist`, `coverage` and similar build folders.

## Then

1. The script's patterns vary by language and can miss things; always add this grep pass: `console.log(` / `debugger` in app code, `lorem ipsum`, `example.com`/`test@` in UI copy, hard-coded ids or emails, `NEXT_PUBLIC_` flags left on for debugging, mock data imported by production routes, `.only(`/`.skip(` in tests, commented-out code blocks, and a case-insensitive search for `not implemented`, `lorem`, `TODO`, `FIXME`, `XXX` in `*.ts, *.tsx, *.sql`.
2. Check each hit in context: a TODO in a test fixture or a documented post-launch item is fine if it's ticketed; anything on a production path is not.
3. Report: `| Severity | File:line | Pattern | Why it matters | Fix or ticket |`. Blocker/critical hits on production paths fail the ship skill's completion gate.

Language-specific review points: `references/review-checklist.md`.
