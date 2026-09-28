# Launch checklist (Next.js + Supabase + Vercel, EU/Danish product)

Mark each item PASS / FAIL / NOT CHECKED / N/A with evidence. Items marked ★ are launch blockers when they FAIL.

## 1. Scope and completeness
- ★ Every MVP job in `PRODUCT.md` works end to end on the release preview (phase 3) and in production after release (phase 6 smoke)
- ★ No blocker/critical `placeholder-scan` hits on production paths; no mock data, lorem ipsum, test emails or debug flags in the UI
- Open tickets triaged: must-have (done) / post-launch (labelled `post-launch`) / dropped (closed with reason)
- Feature flags: every flag has a decided launch state

## 2. Quality gate
- ★ Latest `/harden` verdict for the release PR's head is **SHIP**, independence L2 or L3, all six stages ran, run after every fix and doc commit
- ★ CI green on `main`: typecheck, lint, tests, build, Playwright
- harden CI gate enabled as a required check on `main`

## 3. Environments and data
- ★ Production and preview/dev use different Supabase projects (or branching) and different secret keys
- ★ All env var names in `.env.example` exist in Vercel Production; no secret has a `NEXT_PUBLIC_` prefix
- ★ Production database: migrations applied, RLS on every exposed table, advisors clean (security)
- Backups: daily backups on; point-in-time recovery if the plan allows; a restore has been tried once on a copy
- Region: Supabase and Vercel functions in the EU region recorded in `docs/tech.md`
- Seed/test data not present in production (named internal smoke accounts are the only exception, flagged and excluded from analytics, or deleted after the smoke test)

## 4. Domain, auth and email
- ★ Custom domain on Vercel with valid SSL; `www`/apex redirect decided
- ★ Supabase Auth: Site URL = production domain; redirect URLs include production (and only intended previews)
- ★ Transactional email from our own domain with SPF, DKIM and DMARC; magic-link/invite emails tested to Gmail and Outlook
- OAuth apps (Google/Microsoft) in production mode with the production redirect URL

## 5. Security and abuse
- Security headers: CSP, HSTS, frame-ancestors, Referrer-Policy (checked on the production URL)
- Rate limiting on auth, public forms, AI endpoints and webhooks; CAPTCHA/bot protection where there's public signup
- Webhooks verify signatures; production webhooks point at production only
- Dependabot/osv alerts on; `security-guidance` on in the Code tab; Semgrep clean in CI
- Vercel deployment protection on previews; production not protected by accident

## 6. Observability and operations
- ★ Error tracking (e.g. Sentry) receives a test error from production, with PII scrubbing
- Uptime monitor on the production URL and the key API route; alerts go to a person
- Logs: Vercel and Supabase log retention known; where to look is in the runbook
- Spend limits/alerts on Vercel, Supabase and the AI provider
- Structured server logs with a request/correlation id on every API route and server action; no PII or secrets in logs
- Every alert names a symptom users feel and links to a runbook step
- ★ Rollback path documented in the runbook: Vercel instant rollback to the previous production deployment (tested once when a previous deployment exists), a first-launch fallback (e.g. maintenance page), and a migration rollback or forward-fix plan for this release

## 7. Performance and accessibility
- Lighthouse on the top 3 routes (mobile): performance, accessibility, best practices ≥ 90, or deviations accepted
- Images optimised (`next/image`), fonts self-hosted/optimised, no huge client bundles
- Core Web Vitals on the top 3 routes (field data if available, else lab): LCP ≤ 2.5 s, INP ≤ 200 ms, CLS ≤ 0.1, measured by `web-performance-auditor`, never estimated
- ★ Accessibility: no axe WCAG 2 AA violations on core flows; keyboard path for each core job

## 8. Websites only: discoverability
- Page titles and meta descriptions; Open Graph/Twitter images; favicon and app icons
- `sitemap.xml`, `robots.txt` (previews `noindex`); canonical URLs
- Analytics (privacy-friendly or with consent), conversion events defined

## 9. Legal and GDPR (EU/Denmark)
- ★ Privacy policy and terms reachable from every page footer and from signup
- Cookie consent only if non-essential cookies/trackers exist; otherwise none (and say so in the policy)
- ★ Data processing agreements with processors (Supabase, Vercel, AI provider, email, error tracking); processors listed in the policy
- Data map in `docs/tech.md`: what personal data, why, where, how long
- ★ Users can export and delete their data (or a documented manual process with a response time)
- AI features: what data is sent to the AI provider, retention settings, disclosed to users

## 10. Content and polish
- 404 and 500 pages designed; empty states for every list; error messages human and in the UI language
- Copy reviewed (`design:ux-copy`); da-DK number/date/currency formats
- Design conformance: impeccable `audit` + harden stage 5 clean on key screens

## 11. Handover
- `README.md` for humans: what it is, how to run locally, how to deploy
- `docs/runbook.md`: deploy, rollback, rotate a key, restore a backup, add a user, who to call
- `CHANGELOG.md` and release notes for this version; git tag `vX.Y.Z`
- `PRODUCT.md`, `docs/tech.md`, `docs/toolchain.md`, `DESIGN.md` up to date with what shipped
- Support: where users report problems; how those become GitHub issues (`triage`)
