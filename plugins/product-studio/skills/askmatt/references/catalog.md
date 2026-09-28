# product-studio catalog: every skill, agent, plugin and MCP, and which one wins

This is the routing brain shared by `start-project`, `askmatt`, `define-toolchain` and the scout/auditor agents. Research date 2026-09-23; re-verify anything version-sensitive against primary sources before relying on it.

Surfaces: **CW** = Cowork (planning, browser, artifacts, connectors), **CT** = Code tab / Claude Code (builds in the repo), **CI** = GitHub Actions.

## 1. Canonical chain per job (the conflict register for skills)

One tool wins per job. Alternates stay available but are user-invoked only (`disable-model-invocation`) or only used when the canonical one can't run. Some canonical skills are user-invoked too, so they fire only when a master or `build-ticket` conducts them (the Skill tool refuses them; the conductor reads the file): the Superpowers execution chain and the Addy support skills.

| Job | Canonical | Alternates (not auto-triggered) | Why |
|---|---|---|---|
| Interview / stress-test an idea | `grilling` (+ `domain-modeling`) | superpowers `brainstorming`, `idea-refine` (Addy; raw idea → divergent variations first), KW `product-management:product-brainstorming` | Design-tree rounds with recommended answers suit a no-coder; leaves CONTEXT.md |
| Product brief | `define-product` → `PRODUCT.md` | KW `product-management:write-spec` for a PRD-style doc if the user wants one | impeccable and Next tooling read root `PRODUCT.md` |
| Architecture decisions | `define-tech` + `domain-modeling` ADRs | KW `engineering:architecture`, `engineering:system-design` | ADR rules from Matt (hard to reverse + surprising + tradeoff) |
| Tool / MCP / plugin selection + conflicts | `define-toolchain` + agents `integration-scout`, `toolchain-auditor` | `claude-automation-recommender` (once code exists) | Behind-the-scenes, evidence-based |
| Design interview (taste by picking, "du bestemmer" allowed) | `grill-design` (log in `docs/design/decisions.md`; feeds impeccable, never writes DESIGN.md) | `grilling` for non-visual facts | People can't describe a look but can pick between two |
| Component, chart and animation sources (shadcn, Motion, Kokonut UI, Bklit, 21st.dev, Magic UI, Aceternity) | `ui-sources` (reads `define-design/references/design-sources.md`) | the source's own MCP (shadcn, Motion AI Kit, 21st) | Parts only; the look stays impeccable's |
| Visual direction & design system | `impeccable` (shape, init, document, critique, audit, polish…) | user's own design skills (`frontend-design`, anti-slop, fintech, apple, design-tokens, frontend-polish) as flavour only when named | Strongest design skill; writes Google-spec `DESIGN.md` |
| Reverse-engineer a reference design | `anydesign` (runs only inside `docs/design/references/<name>/`) | — | Structured design.md per reference |
| Palette / font / UX-rule lookup | `ui-ux-pro-max` (explicit call) | — | Searchable data, no opinions forced |
| Component implementation rules | `shadcn`, `vercel-composition-patterns`, `vercel-react-best-practices` | user's `best-practice-code-by-vercel` (same content) | Official vendor skills |
| UI review against rules | `web-design-guidelines` (pinned) + `design:accessibility-review` | `design:design-critique`, impeccable `critique`/`audit` | Pinned rules, no remote instructions |
| Continuous multi-area quality loop | `audit-loop` (judges: `e2e-explorer`, `web-performance-auditor`, `leak-hunter`, `supabase-security-reviewer`, impeccable critique/audit, `code-review`, `silent-failure-hunter`, `type-design-analyzer`; `finding-verifier`) | — | Measure → judge → fix → re-measure with hard stop rules; harden stays the merge gate |
| Full product test + independent verdict | `harden` (agents `e2e-explorer`, `corner-case-hunter`, `leak-hunter`, `supabase-security-reviewer`, `adversarial-inspector`, `finding-verifier`; `claudex-loop` for cross-provider inspection) | `claude-security` scan (CT) as an extra stage | Builder never approves; append-only `PLAN-REVIEW-LOG.md` |
| Finish and launch a product | `ship` (agents `launch-readiness-auditor`, `technical-doc-writer`; skills `placeholder-scan`, `harden`, `retro`) | KW `engineering:deploy-checklist` | One go-live checklist, handover docs, tagged release |
| Unfinished-code sweep | `placeholder-scan` | — | 64 patterns, 10 languages |
| Exploratory bug-bash | `dogfood` (agent-browser) inside harden stage 5 | Playwright test agents (planner/generator/healer) for permanent tests | Evidence per bug |
| Cross-model second opinion | `claudex-route` (recommend/one handoff), `claudex-loop` (plan review → build → inspection), `codex-review`, `codex-build` | — | Different provider = real independence |
| Live visual QA | `visual-qa` using Claude in Chrome (CW) | `playwright-skill` (files, CI-like runs), `webapp-testing` (Python) | Real signed-in browser sees Vercel previews |
| Runtime verify during build | `next-dev-loop` (CT, needs `next dev`) | Next.js MCP `/_next/mcp` directly | Official Next.js |
| Spec | `to-spec` | KW `write-spec` | Feeds `to-tickets` |
| Tickets | `to-tickets` (GitHub Issues) | — | Tracer bullets + blocking edges |
| Plan a ticket (CT) | superpowers `writing-plans` → `docs/plans/YYYY-MM-DD-<n>-<slug>.md`, approved by a Danish summary | — | Exact paths and code, derived from the current repo at build time; tickets stay path-free |
| Build a ticket | `build-ticket` (CT) → superpowers `using-git-worktrees` → `writing-plans` → `subagent-driven-development` (≥4 tasks, interfaces, schema/RLS/auth) or `executing-plans` → `test-driven-development` + `verification-before-completion` → `requesting-code-review` → `finishing-a-development-branch` (option 2: PR) | Matt `implement` + `tdd`, `feature-dev` | Superpowers is the strongest execution engine: fresh subagent per task, review per task, rulings ledger; Matt's skills stay the planning spine |
| Test discipline | superpowers `test-driven-development` (iron law, at the seams the spec agreed) | Matt `tdd` (reference: tests.md, mocking.md) | Pre-approved exceptions in AGENTS.md: generated code, config, pure styling, spikes |
| Code review | builder-side: superpowers `requesting-code-review` inside build-ticket (evidence, never a verdict). Independent: `harden` stage 6 with Matt `code-review` (standards + spec) + agents `pr-code-reviewer`, `silent-failure-hunter`, `type-design-analyzer`, `pr-test-analyzer`; `supabase-security-reviewer` for data | `feature-code-reviewer`, KW `engineering:code-review`, CodeRabbit (CI, optional) | The builder never approves |
| Receiving review findings | superpowers `receiving-code-review` (verify before fixing; pushback goes to the next inspector) | — | No performative agreement |
| Security | `supabase-security-reviewer` (every data PR); CT plugins `security-guidance` (always-on) and `claude-security` (pre-release) | Trail of Bits skills (install, CC-BY-SA) | Official + stack-specific |
| Ordinary bug | superpowers `systematic-debugging` | — | Root cause before fixes |
| Hard, intermittent or regression bug | `diagnosing-bugs` | — | Feedback loop first |
| Background jobs / durable AI runs | `define-tech` + `references/background-jobs.md` (Vercel Workflow default) | Supabase Queues + Cron, Vercel Queues direct, Inngest/Trigger.dev (ADR) | Current limits, one run model, budget in code, tenant from the run row |
| Agent/AI output quality | golden-set evals + scores as pure functions (background-jobs.md §6) | — | The model never computes a score |
| Performance investigation | `performance-optimization` (Addy) + agent `web-performance-auditor` | `diagnosing-bugs` for a regression hunt; impeccable `optimize` for UI-only work | Measure → fix → verify; never invent Core Web Vitals |
| Instrumentation (logs, errors, alerts) | `observability-and-instrumentation` (Addy, toned down to Vercel + Sentry) | — | On-call questions first; test-fire telemetry |
| App-level security design (threat model, SSRF, supply chain, AI input) | `security-and-hardening` (Addy) + `harden/references/security-checklist.md` | `supabase-security-reviewer` stays canonical for data/RLS | Beyond RLS |
| Written quality bar + anti-weakening guard | `constraint-driven-development` (Addy): `CONSTRAINTS.md` + `floor-guard` in harden stage 1 | — | Stops agents from skipping tests or lowering thresholds |
| Schema/feature migration or removal | `deprecation-and-migration` (Addy) | `to-tickets` expand–contract for code-only refactors | Expand → migrate → contract, down path |
| API contracts, webhooks, idempotency | `api-and-interface-design` (Addy) | `codebase-design` for internal module interfaces | Idempotency keys, one error shape |
| Doc-verified framework code | `source-driven-development` (Addy) via Context7 | `next-dev-loop` for runtime checks | Cite the doc; mark UNVERIFIED |
| Static security analysis (SAST) | Semgrep CE in CI (`semgrep scan --config p/default --error --metrics=off`, harden stage 1; never `semgrep ci` or `--config auto`) | CodeQL (public repos), Bearer CLI (PII flows) | Deterministic, no model cost |
| Write or test a skill | superpowers `writing-skills` (user-invoked) | Matt `writing-for-agents`; agnix (`npx agnix --target claude-code .`, deterministic lint, run before each plugin release) | Pressure-test with subagents |
| Diagnose a build run that went wrong | superpowers `diagnosing-superpowers` (CT, user-invoked) | `retro` | Reads the session transcript |
| Done-ness | `verification-before-completion` | — | Evidence before claims |
| Big foggy effort | `wayfinder` | — | Decision tickets |
| Human-only setup | checklist in `build-handoff`; `wizard` only if the user runs a script locally | — | Cowork shell is non-interactive |
| Instruction file upkeep | `claude-md-improver` | — | Keeps AGENTS.md/CLAUDE.md sharp |
| Understand a big codebase | subagent `code-explorer`; Graphify report if present | — | Token-cheap |
| Architecture upkeep | `improve-codebase-architecture` + `codebase-design` | — | Deepening opportunities |
| Raw incoming issues | `triage` | — | Five roles |
| Moving work between tools | `handoff` | — | Portable file |
| Message didn't land | `wait-what` | — | Plain re-pitch |

## 2. Skills in this plugin (name → job → surface)

Master workflows (ours): `start-project`, `askmatt`, `harden`, `ship`; cheat sheet: `studio`. Phases (ours): `define-product`, `define-tech`, `define-toolchain`, `define-design`, `build-handoff`, `visual-qa` (CW).

Matt Pocock (MIT): `grilling`, `grill-me`, `grill-with-docs`, `domain-modeling`, `research`, `prototype`, `to-spec`, `to-tickets`, `implement` (alternate), `tdd` (reference), `code-review` (harden stage 6), `diagnosing-bugs`, `wayfinder`, `codebase-design`, `improve-codebase-architecture`, `triage`, `wizard`, `handoff`, `wait-what`, `to-questionnaire`, `teach`, `setup-matt-pocock-skills`, `ask-matt`, `resolving-merge-conflicts`, `writing-for-agents` (CW+CT).

Superpowers 6.4.1 (MIT, no SessionStart hook), the Code-tab execution engine behind `build-ticket`. Conducted by build-ticket (user-invoked so they never fire outside it): `writing-plans`, `subagent-driven-development`, `executing-plans`, `requesting-code-review`, `finishing-a-development-branch`. Model-invocable: `test-driven-development`, `receiving-code-review`, `verification-before-completion`, `systematic-debugging`, `dispatching-parallel-agents`, `using-git-worktrees`. User-invoked: `brainstorming`, `writing-skills`, `diagnosing-superpowers`. Reference only: `using-superpowers`. Each carries a short "product-studio note" with the overrides (plan path, no local merge, ledger kept until the PR body is written, no native worktree tool).

Ours, conductors: `build-ticket` (CT), `grill-design`, `audit-loop`.

Addy Osmani agent-skills (MIT): canonical `performance-optimization`; user-invoked support skills called by the masters: `constraint-driven-development`, `security-and-hardening`, `observability-and-instrumentation`, `deprecation-and-migration`, `api-and-interface-design`, `source-driven-development`, `idea-refine`.

Design (Apache/MIT): `impeccable` (+ agents), `anydesign`, `ui-ux-pro-max`, `web-design-guidelines`.

Stack (MIT): `supabase`, `supabase-postgres-best-practices`, `vercel-react-best-practices`, `vercel-composition-patterns`, `shadcn`, `next-dev-loop`.

Testing and review: `harden`, `dogfood` (agent-browser, Apache-2.0), `playwright-skill`, `webapp-testing` (alternate). Cross-model: `claudex-loop`, `claudex-route`, `codex-review`, `codex-build` (MIT, chaseai-yt/claudex-loop).

Claude setup (Apache): `claude-automation-recommender`, `claude-md-improver`, `feature-dev` (alternate flow).

Finishing and craft: `placeholder-scan` (MIT, ribatshepo/auto-orchestrate), `retro` (Matt Pocock, MIT), `ui-design-fundamentals` (MIT, aaddrick/claude-pipeline).

## 3. Agents in this plugin

| Agent | Use for | Source |
|---|---|---|
| `adversarial-inspector` | independent verdict on a plan or diff (APPROVED/REVISE/BLOCKED) | ours |
| `corner-case-hunter` | state-interference matrix, corner cases, test sketches | ours |
| `e2e-explorer` | full browser bug-bash per role + design conformance | ours |
| `leak-hunter` | secrets, bundles, over-fetching, PII, advisors, headers | ours |
| `finding-verifier` | refute-before-report on every finding | ours |
| `launch-readiness-auditor` | go-live checklist with evidence | ours |
| `technical-doc-writer` | README, runbook, architecture docs | aaddrick/claude-pipeline (MIT) |
| `toolchain-auditor` | conflict register before build and after any tool change | ours |
| `integration-scout` | best plugin/MCP per capability, safe config | ours |
| `supabase-security-reviewer` | RLS, tenancy, keys, action auth | ours |
| `code-explorer` | trace how a feature works in the codebase | feature-dev (Apache) |
| `code-architect` | implementation blueprint for a feature | feature-dev |
| `feature-code-reviewer` | bugs/conventions with confidence scores | feature-dev (renamed) |
| `pr-code-reviewer` | AGENTS.md/CLAUDE.md compliance + bugs on a PR | pr-review-toolkit (renamed) |
| `silent-failure-hunter` | swallowed errors, bad fallbacks | pr-review-toolkit |
| `type-design-analyzer` | TypeScript type design | pr-review-toolkit |
| `pr-test-analyzer` | test coverage gaps | pr-review-toolkit |
| `code-simplifier` | simplify after a feature | pr-review-toolkit |
| `comment-analyzer` | stale/wrong comments | pr-review-toolkit |
| `web-performance-auditor` | Core Web Vitals / Lighthouse audit, Quick or Deep mode, real numbers only | addyosmani/agent-skills (MIT) |
| `impeccable-finish-reviewer`, `impeccable-documenter`, `impeccable-asset-producer`, `impeccable-manual-edit-applier` | impeccable's own handoffs | impeccable (Apache) |

If a named agent isn't available as a subagent type in the current surface, spawn a general-purpose subagent and pass it the agent file's body as instructions.

## 4. Plugins to install (not vendored)

| Plugin | Where | Why | Note |
|---|---|---|---|
| `engineering` (Anthropic knowledge-work) | CW catalog | architecture, system-design, testing-strategy, deploy-checklist, tech-debt | alternates, not canonical; bundles a GitHub MCP definition |
| `product-management` (Anthropic knowledge-work) | CW catalog | write-spec, competitive-brief, metrics-review | alternates |
| `design` (Anthropic knowledge-work) | CW, already enabled | critique, accessibility-review, ux-copy, design-system, handoff | used by define-design/visual-qa |
| `security-guidance` | CT, official marketplace | always-on security warnings + commit-time review | hooks every turn, extra model cost |
| `claude-security` | CT | deep multi-agent scan before release | heavy; run on demand |
| `vercel` (vercel/vercel-plugin) | CT, only without product-studio there | Vercel skills + MCP | otherwise use the repo `.mcp.json` Vercel entry; deny `deploy_to_vercel`, `buy_*` and `import-claude-design-from-url` in settings.json (deploys only via GitHub → Vercel) |
| `supabase` (supabase-community/supabase-plugin) | CT, only without product-studio there | Supabase MCP + skills | name overlaps our vendored `supabase` skill; otherwise use the repo `.mcp.json` entry; dev project, read-only default |
| `typescript-lsp` | CT | type-aware navigation | low risk |
| **`product-studio` (this plugin)** | CT, preferred | same skills + agents in the Code tab | then skip `mattpocock-skills`, `superpowers`, and vendor plugins whose skills we bundle; keep their MCPs via the repo `.mcp.json` |
| `mattpocock-skills` | CT only if product-studio can't be installed there | Matt's skills | duplicates ours if both are installed |
| `superpowers` | avoid **installing the plugin** | — | its SessionStart hook forces `<EXTREMELY_IMPORTANT>` on every session, Cowork included; its skills are bundled here and canonical for execution |
| `agent-skills` (addyosmani) | avoid installing | — | its commands collide with `/ship`, its session-start hook and meta-router compete with askmatt; the useful skills are bundled |
| Trail of Bits skills | CT (their marketplace) | differential-review, insecure-defaults, supply-chain audit | CC-BY-SA: install, don't copy |
| `impeccable` full plugin | don't install | — | instead, opt in per project in the Code tab: `/impeccable hooks on` writes the hooks to the git-ignored `.claude/settings.local.json` (suggest `hook.quiet: true`; `hooks off` undoes it; re-run after a product-studio update). Never in Cowork |

Don't install alongside ours: `ralph-loop` (Stop-hook loops), `explanatory-output-style`/`learning-output-style` (global output hooks), `tdd-guard` (blocks non-TDD edits), a second full design plugin.

## 5. MCP servers and connectors (safe defaults)

| Capability | CW (connector) | CT (`.mcp.json` in repo, or plugin) | Safe default |
|---|---|---|---|
| Database / auth / storage | custom connector "Supabase (dev, read-only)" with the CT URL (not the directory Supabase connector: it is unscoped and read-write) | `https://mcp.supabase.com/mcp?project_ref=<DEV_REF>&read_only=true&features=database,docs,debugging,development` | dev project only, read-only (hides apply_migration and all deploy/branch/storage writes; keeps execute_sql as SELECT-only, generate_typescript_types, query_logs, get_advisors); execute_sql = ask; writes only via migrations committed to git; no second local-stack MCP (use the CLI) |
| Deploy / logs | Vercel directory connector (or custom connector `https://mcp.vercel.com`), tool permissions set as in Safe default | `claude mcp add --transport http vercel https://mcp.vercel.com` (project-scoped URL `https://mcp.vercel.com/<team>/<project>`) | no server-side read-only mode: block `deploy_to_vercel` (bypasses Git, can create projects), all `buy_*` and `import-claude-design-from-url` (Cowork: Blocked; CT: settings.json deny); approve `get_access_to_vercel_url` and toolbar replies/edits/resolves |
| Repo / issues / PRs | GitHub connector, or `gh` | `https://api.githubcopilot.com/mcp/` with a fine-grained PAT (only this repo), header `X-MCP-Toolsets: repos,issues,pull_requests` | lockdown on public repos; `gh` CLI already covers most needs in CT |
| Docs lookup | Context7 (bundled in this plugin) | same | read-only by nature |
| Next.js runtime | — | built-in `/_next/mcp` of `next dev` (Next 16+); `next-dev-loop` skill | local only |
| Components | — | shadcn MCP (`npx shadcn@latest mcp`); 21st MCP (API key); Magic UI MCP | read-only registries; restyle every add to tokens |
| Motion docs | — | Motion AI Kit (`npx motion-ai`; docs free, audits Motion+) | — |
| Test runner | — | `playwright-test` MCP from `npx playwright init-agents --loop=claude` | local |
| Browser | Claude in Chrome (built in) | one of Playwright MCP (`npx @playwright/mcp@latest --isolated`) or Chrome DevTools MCP | never both |
| Design files | Figma connector (if Dev/Full seat) | Figma plugin | free seats have tiny call limits |
| Errors | Sentry connector (when live) | Sentry plugin, project-scoped | — |
| Payments | Stripe connector (sandbox only via OAuth) | Stripe plugin | never live keys to an agent |
| Email | Resend MCP | — | approve sends |
| Knowledge | repo folder opened as Obsidian vault (no MCP needed) | `cyanheads/obsidian-mcp-server` read-only if ever needed | — |
| Code graph | Graphify skill/CLI (`pip install graphifyy`) optional | same | sends images/PDFs to an LLM |

## 6. The user's already-installed skills that overlap

`anthropic-skills:frontend-design`, `dataviz` (chart method input to `component-states.md`, never a DESIGN.md author), `anti-ai-slop-design-architect`, `fintech-design-architect`, `design-tokens`, `frontend-polish`, `apple-design`, `best-practice-code-by-vercel`, `design:*`. Rule: in product-studio flows, impeccable owns direction and DESIGN.md; the user's design skills are used only as an explicit "flavour" when the chosen direction calls for it (e.g. fintech feel → `fintech-design-architect` principles fed into impeccable `shape`). Never let two design skills write DESIGN.md.

## 7. impeccable: which command runs where

| Command | Surface | Why |
|---|---|---|
| `shape`, `critique` | CW | planning and review of preview screenshots, no code |
| `audit` | CW (report) + CT (authoritative, and inside harden stage 5) | reads code; the detector engine may not be reachable from Cowork |
| `polish`, `bolder`, `typeset`, … (editing) | CT only, after "godkendt" | they edit source |
| `live` | CT only, local `next dev` | needs HMR, the `localhost:8400` helper and your own browser; never previews or production |

Optional: the impeccable Chrome DevTools extension for overlays on previews and production; `npx impeccable detect --json src/` as a free CI step.

## 8. Looked at and not adopted (2026-09-23)

| Tool | Why not |
|---|---|
| ralph-loop / snarktank/ralph / `/loop` for audits | Stop hook on every session, unlimited by default, the builder certifies itself (ralph-loop); `/loop` is session-bound and expires; `audit-loop` covers the need with counted rounds and hard stop rules |
| oiloil-ui-ux-guide, BMAD bmad-ux, spec-kit /clarify | ideas only (one topic per round, default per question, rendered side-by-side variants, recommended answer accepted with "yes", decision log) merged into `grill-design` |
| `smartlabsAT/claude-playwright` | idle since Feb 2026, registers an MCP named `playwright` (collides with Microsoft's), own replay format; Playwright MCP storage-state per role and agent-browser sessions already cover it |
| Addy `using-agent-skills`, `test-driven-development`, `spec-driven-development`, `planning-and-task-breakdown`, `incremental-implementation`, `code-review-and-quality`, `code-simplification`, `debugging-and-error-recovery`, `frontend-ui-engineering`, `git-workflow-and-versioning`, `documentation-and-adrs`, `shipping-and-launch`, `ci-cd-and-automation`, `context-engineering`, `browser-testing-with-devtools`, `interview-me`, `doubt-driven-development` | duplicates of our canonical chain; their best ideas were merged into grilling, harden, ship, visual-qa, e2e-explorer and the AGENTS template |
| Addy agents `code-reviewer`, `security-auditor`, `test-engineer`, all commands and hooks | duplicates or forcing behaviour |
| Qodo PR-Agent, Applitools/Meticulous, memory MCPs | duplicate CodeRabbit/our reviewers; paid visual regression; unaudited hidden state |
| PeterHdd/agent-skills (9 personas) | generic Kubernetes/Kafka/Redis/AWS patterns that don't fit Vercel + Supabase; broad auto-triggers; stub security references; `rapid-prototyper` uses Prisma (bypasses RLS) and Clerk. Useful ideas (job envelope, outbox via pgmq, failure-mode table, AI-output evals) merged into `define-tech/references/background-jobs.md` and the tech.md template |
| multica-ai/andrej-karpathy-skills | a CLAUDE.md of four coding habits (think first, simplicity, surgical changes, verifiable goals); our CLAUDE.md must stay `@AGENTS.md`, and "stop and ask" contradicts rule-after-approval. Simplicity and surgical-change rules merged into the AGENTS template. It does nothing for math precision: scores are pure functions with property tests instead |
| Superdesign | cloud canvas with account and credits; uploads component source and brand assets (public URLs); keeps its own `.superdesign/design-system.md` (a second design author); broad trigger. Scratch-folder exploration only |
| skill-optimizer | a prose audit rubric plus a script mining personal session logs; no security content (it does not catch missing RLS or hallucinated packages) |
| vibe-replay plugin | appends session summaries to PR bodies, "Publish to Gist" makes public gists, telemetry on by default, redaction misses Supabase/Vercel keys and business content |
| VibeSec, Design Auditor, oiloil, SkillCheck-Free, task-observer, review-claudemd, polaris-datainsight, spartan-ai-toolkit | generic or over-triggering, second design authors, freemium funnels, restrictive licences, cloud APIs |

**Worth considering later** (from BehiSecc/awesome-claude-skills): agnix (plugin lint), vibe-replay CLI as a local cost dashboard only (`DO_NOT_TRACK=1 npx vibe-replay -d`), agenttrace (local session audit), pypict (pairwise test matrices for 4+ independent inputs), bullshit-detector's untrusted-content fence as a design reference (not its AGPL PDF code).

**Worth considering later** (from ai-for-developers/awesome-ai-coding-tools; verify license and cost first): CodeQL (public repos), CodeRabbit (always-on PR comments, never the verdict), Bearer CLI (PII flows, harden stage 3), squirrelscan (go-live site audit), toprank/NotFair (post-launch SEO), repo-forensics (scan third-party skills before vendoring), AI Context Linter (AGENTS.md lint in CI), rung (CI proof that claimed checks ran), v0 (throwaway UI prototypes, re-tokenized by impeccable), prompt-to-asset (icons and OG images).

## 9. Decisions recorded

- `/ship` stays model-invocable: it can't tag or merge without the user's "godkendt" at phase 6, and askmatt routes to it by name.
- Database tests run in a `db-tests` CI job by default (no Docker on the Mac); `supabase test db` needs a Docker-compatible runtime even with `--db-url`; a local container runtime is optional.
- Semgrep runs as `semgrep scan --config p/default --error --metrics=off`, never `semgrep ci` (without a token it exits 0 without scanning) or `--config auto` (requires metrics).
