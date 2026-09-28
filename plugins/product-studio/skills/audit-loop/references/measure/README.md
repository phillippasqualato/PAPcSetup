# Pinned measurement settings

These live in the plugin, not the product repo, so a fix can't loosen the check it's judged by. Copy them into the run folder (or the weekly workflow) as-is.

| Area | Command (pinned) |
|---|---|
| Accessibility | `@axe-core/playwright` with `.withTags(['wcag2a','wcag2aa','wcag21aa','wcag22aa'])` on each key route × role × viewport × theme; no `disableRules`. Lighthouse accessibility via `lighthouserc.json` |
| Performance | `npx @lhci/cli autorun --config=<plugin>/skills/audit-loop/references/measure/lighthouserc.json --collect.url=<url>` (median of 5); `next build` route sizes |
| App security | `semgrep scan --config p/default --error --metrics=off` · `gitleaks detect` · `trufflehog git file://. --results=verified` · `osv-scanner scan source -r .` · `npm audit --omit=dev` |
| Data and RLS | Supabase advisors (read-only MCP or `supabase db advisors`), `supabase db lint`, the `db-tests` CI job result |
| Design | `npx impeccable detect --json src/` twice: once raw (`--no-config`), once with the project config; plus the preview URL |
| UX flows | `npx playwright test` (E2E), console errors and failed requests per key route |
| Copy | `placeholder-scan`; once per repo `npm i -D cspell @cspell/dict-da-dk`, then `npx cspell --config <this folder>/cspell.json "src/**/*.{ts,tsx}"`; `npx linkinator <url> --recurse` |
| SEO | Lighthouse SEO category; per public route: `<title>`, meta description, OG image, canonical, `lang`; `sitemap.xml`, `robots.txt` |
| Code health | `tsc --noEmit`, `eslint .`, tests, `next build`, `npx knip`, floor-guard |

Growth of any ignore/suppression list (cspell words, `.semgrepignore`, `nosemgrep`, impeccable ignores, `test.fixme`) counts as a loosened check.
