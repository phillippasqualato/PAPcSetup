---
name: define-tech
description: Design the technical architecture for an approved product on Vercel + Supabase + GitHub, agent-led - the agent decides the technical choices from stack defaults, the official Supabase and Next.js knowledge and researched facts, and only brings business-consequential decisions to the no-coder user; writes docs/tech.md, the data model and ADRs. Tech phase called by start-project or askmatt, or when the user explicitly asks for the architecture.
---

# Define Tech

You are the architect; the user judges consequences, not code. Danish to the user, English in files.

Read first: `PRODUCT.md`, `CONTEXT.md`, ADRs, `references/stack-defaults.md`.

## Order of play

1. **Requirements from the product.** Roles × actions, core nouns, volumes, integrations, AI features, privacy. Don't re-ask anything `PRODUCT.md` says.
2. **Ground truth, not memory.**
   - Supabase: invoke `product-studio:supabase` and `product-studio:supabase-postgres-best-practices` for auth, `@supabase/ssr`, RLS, storage, schema and index rules.
   - Next.js: the version-matched docs (bundled in `node_modules/next/dist/docs/` once the app exists; `nextjs.org/docs/*.md` before). Don't trust older-version skills.
   - Anything else that matters (pricing, limits, an API) → `product-studio:research` in the background, or Context7 for library docs. Cite sources in `docs/tech.md`.
   - If `engineering:system-design` is installed, use it as a second structured pass on the system sketch.
3. **Draft the architecture** from the stack defaults, deviating only with a reason: data model (tables named with `CONTEXT.md` terms), RLS in plain words per table, auth and roles, tenancy (ADR), where server logic runs, integrations and secret names, environments, quality gates.
4. **Business-shaped decisions only.** Run one `product-studio:grilling` round for the few choices with consequences the user can feel: EU hosting, self-signup vs invite, login methods, payments now or later, AI provider and monthly ceiling (the ceiling is enforced in code, see `references/background-jobs.md` §2). Numbered, each with `➡️` recommendation and plain consequences.
5. **Prototype when paper fails.** A permissions matrix or state model that feels wrong → `product-studio:prototype` (logic branch) as a clickable HTML artifact.
6. **Security, reliability and truth by design.** Before the gate:
   - dispatch the `supabase-security-reviewer` agent on the *design* (tables, policies in words, tenancy, keys) and fold its findings in (fallback: general-purpose subagent with `../../agents/supabase-security-reviewer.md`);
   - a 5-minute threat model with `product-studio:security-and-hardening` (user-only: read `../security-and-hardening/SKILL.md`): who could abuse what (other tenants, anonymous visitors, AI input, webhooks, file uploads, SSRF), written as a short section in `docs/tech.md`;
   - webhooks, payments or a public API → `product-studio:api-and-interface-design` for one error shape, validation at the boundary and idempotency keys (unique constraint, retries, duplicates);
   - an instrumentation plan with `product-studio:observability-and-instrumentation`, toned down to our stack: Sentry for errors, structured logs with a request id, the 3-5 questions on-call must be able to answer, where to look;
   - any job that can run longer than ~60 s, fans out AI calls or retries → read `references/background-jobs.md` and write a *Background work* section in `docs/tech.md` (where it runs, run model, concurrency, budget, failure modes) plus the "where AI runs" ADR;
   - document ingestion (uploaded PDFs, spreadsheets, third-party files): extraction runs server-side; check the extraction library's licence (AGPL, e.g. PyMuPDF, doesn't fit a closed SaaS); no third-party extraction API without a DPA and EU region; extracted text is untrusted input (fence it, see `background-jobs.md` §4);
   - check stack patterns against today's docs (`product-studio:source-driven-development`, via Context7), and cite them in `docs/tech.md`.
7. **Write `docs/tech.md`** (template in `../start-project/references/docs-layout.md`) with a mermaid system sketch and `erDiagram`; ADRs via domain-modeling's format for the hard-to-reverse choices (tenancy, auth provider, where AI runs, EU residency).
8. **Gate.** ≤10 plain-Danish bullets ("Når en bruger gemmer X, sker der dette…", with the product's own terms from CONTEXT.md) plus the monthly cost at expected size. "godkendt?"

## Done when

`docs/tech.md` and ADRs exist, the security pass is folded in, and the user approved the plain summary. The start-project conductor then launches the toolchain phase in the background.
