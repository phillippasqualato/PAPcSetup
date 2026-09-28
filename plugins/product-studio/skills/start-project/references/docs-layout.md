# Project files (the single source of truth)

Every skill, agent and surface reads and writes the same repo. Cowork, the Code tab, Codex, Cursor and an Obsidian vault opened on the repo folder all see the same truth.

```
/
├── AGENTS.md                  ← project rules for every coding agent (ours outside Next.js's managed block)
├── CLAUDE.md                  ← "@AGENTS.md" (Next.js convention); nothing that contradicts AGENTS.md
├── PRODUCT.md                 ← product truth, impeccable schema (define-product)
├── CONTEXT.md                 ← domain glossary only (domain-modeling)
├── DESIGN.md                  ← design system, Google DESIGN.md spec (impeccable via define-design)
├── .impeccable/design.json    ← impeccable sidecar, created by the scan-mode run after the walking skeleton
├── .mcp.json                  ← Code-tab MCP servers, scoped, no secrets (define-toolchain)
├── .claude/settings.json      ← permission rules: risky tools always ask (define-toolchain)
├── .env.example               ← env var NAMES only
├── CONSTRAINTS.md             ← the quality bar + floor, never weakened to pass (constraint-driven-development via build-handoff)
├── .worktrees/, .superpowers/ ← build workspaces (git-ignored; build-ticket)
├── docs/
│   ├── tech.md                ← architecture, data model, permissions, environments (define-tech)
│   ├── toolchain.md           ← tool matrix, data flow, conflict register, golden rules (define-toolchain)
│   ├── adr/0001-*.md          ← hard-to-reverse decisions
│   ├── design/direction.html  ← the approved direction page (define-design)
│   ├── design/component-states.md ← component states + token→CSS-variable map until DESIGN.md gets its Components section
│   ├── design/a11y.md         ← contrast table
│   ├── design/references/<name>/   ← anydesign analyses (never in root)
│   ├── specs/YYYY-MM-DD-<feature>.md
│   ├── plans/YYYY-MM-DD-<n>-<slug>.md ← one plan per ticket (writing-plans via build-ticket; historical, never edited after merge)
│   ├── agents/                ← issue-tracker.md, triage-labels.md, domain.md (setup)
│   ├── qa/YYYY-MM-DD-<topic>.md (+ folder of screenshots)
│   └── log.md                 ← one short entry per session
├── supabase/migrations/       ← schema truth
├── supabase/seed.sql          ← realistic fake data for previews
└── .scratch/                  ← throwaway, never relied on
```

## Rules

- One owner per file (in brackets above). Other skills link, never restate.
- `CONTEXT.md` has no implementation details. `PRODUCT.md` has no technology beyond "Stack: delegated, see docs/tech.md".
- macOS is case-insensitive: never create `design.md`/`product.md` next to `DESIGN.md`/`PRODUCT.md`.
- `docs/log.md`: date, what was decided or built, what's next; ≤8 lines per entry.

## PRODUCT.md (impeccable schema + our product sections)

```markdown
# Product

<!-- impeccable:product-schema 1 -->

## Platform
web

## Stack
delegated: Next.js on Vercel + Supabase + GitHub, see docs/tech.md

## Users
## Product Purpose
## Positioning
## Operating Context
## Capabilities and Constraints
## MVP Scope
## Non-goals
## Success Criteria
## Business Model
## Brand Commitments
## Evidence on Hand
## Product Principles
## Accessibility & Inclusion
## Open Questions
```
Omit sections with nothing confirmed. Copy the schema comment verbatim.

## docs/tech.md template

```markdown
# Technical architecture
## Stack            (layer | choice | why)
## System sketch    (mermaid flowchart)
## Data model       (mermaid erDiagram + one line per table: purpose, owner, RLS in plain words)
## Auth and permissions (role × action table)
## Integrations     (service | purpose | how connected | secret names)
## Environments     (local, preview per PR (login-protected), production URL, Vercel project, Supabase projects/branches, env var names)
## Quality gates
## Background work (where long jobs run, run model, concurrency, budget, failure modes; see define-tech/references/background-jobs.md)
## Failure modes     (component | what breaks | who is hurt | how we notice | automatic recovery)
## Risks and unknowns
## Sources          (URL per non-obvious claim)

Closing check: every requirement in PRODUCT.md maps to a component; every non-default choice says why not the simpler option.
```
