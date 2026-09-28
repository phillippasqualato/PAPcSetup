# MCP Servers for a No-Coder Stack: Next.js + Vercel + Supabase + GitHub + Claude (Cowork / Claude Code)

Researched 2026-09-23. Each claim has a source URL. **UNVERIFIED** means I could not confirm it from an official source in this session (GitHub API was unavailable, so star counts are not given).

General note: in Claude Code, remote servers are added with `claude mcp add --transport http <name> <url>` and authenticated with `/mcp`. Add `--scope project` to write to a shared `.mcp.json` in the repo. In Claude Desktop/Cowork, remote OAuth servers go under Settings > Connectors > Add custom connector (source: https://vercel.com/docs/agent-resources/vercel-mcp).

---

## Quick-pick table

| Server | Official? | Transport | Auth | Safety knobs | License |
|---|---|---|---|---|---|
| Supabase | Yes (supabase-community) | Remote HTTP `https://mcp.supabase.com/mcp` | OAuth 2.1 | `read_only`, `project_ref`, `features` | Apache-2.0 |
| Vercel | Yes | Remote HTTP `https://mcp.vercel.com` (Beta) | OAuth | project URL `/<org>/<project>`; no read-only flag | n/a (hosted) |
| GitHub | Yes | Remote HTTP `https://api.githubcopilot.com/mcp/` or Docker stdio | OAuth (some hosts) / PAT | `/readonly`, `/x/{toolset}`, headers, lockdown | MIT |
| Playwright | Yes (Microsoft) | Local stdio `npx @playwright/mcp@latest` | none | `--isolated`, `--allowed-origins`, `--blocked-origins` | Apache-2.0 |
| Chrome DevTools | Yes (Google Chrome DevTools team) | Local stdio `npx -y chrome-devtools-mcp@latest` | none | `--isolated`, `--slim`, `--headless` | Apache-2.0 |
| shadcn | Yes | Local stdio `npx shadcn@latest mcp` | none (registry tokens optional) | n/a | MIT (UNVERIFIED) |
| Context7 | Yes (Upstash) | Remote HTTP `https://mcp.context7.com/mcp` | API key (free) | read-only by nature | MIT |
| Next.js DevTools | Yes (Vercel) | Local stdio `npx next-devtools-mcp@latest` | none | telemetry opt-out | MIT |
| Figma | Yes | Remote `https://mcp.figma.com/mcp` or Desktop `http://127.0.0.1:3845/mcp` | OAuth | plan rate limits | n/a (hosted) |
| Sentry | Yes | Remote `https://mcp.sentry.dev/mcp[/org/project]` or `npx @sentry/mcp-server` | OAuth / token | org/project URL scoping, `--skills` | UNVERIFIED |
| Stripe | Yes | Remote `https://mcp.stripe.com` | OAuth / Agent API key | sandbox-only OAuth grant, human confirmation | n/a (hosted) |
| Resend | Yes | Remote `https://mcp.resend.com/mcp` or `npx -y resend-mcp` | API key | none documented | MIT |
| Graphify | Third party | Local stdio (Python) | none | local-only | UNVERIFIED (conflicting) |
| Obsidian | Community | Local HTTP (plugin) or stdio | API key | `OBSIDIAN_READ_ONLY`, path allowlists (cyanheads) | MIT / Apache-2.0 |

---

## 1. Supabase MCP

- **Repo:** https://github.com/supabase-community/supabase-mcp (docs: https://supabase.com/docs/guides/getting-started/mcp, URL builder: https://supabase.com/mcp)
- **Transport:** Remote Streamable HTTP at `https://mcp.supabase.com/mcp`, OAuth 2.1; during login you pick the org that holds the project. A local CLI version runs at `http://localhost:54321/mcp` with "a limited subset of tools and no OAuth 2.1" (source: https://github.com/supabase-community/supabase-mcp).
- **Install (Claude Code, from official docs):**
  ```bash
  claude mcp add --scope project --transport http supabase "https://mcp.supabase.com/mcp?features=docs%2Caccount%2Cdatabase%2Cdebugging%2Cdevelopment%2Cfunctions%2Cbranching"
  ```
  (source: https://supabase.com/docs/guides/getting-started/mcp)
- **Recommended safe config for a no-coder (`.mcp.json`):**
  ```json
  {
    "mcpServers": {
      "supabase": {
        "type": "http",
        "url": "https://mcp.supabase.com/mcp?project_ref=<DEV_PROJECT_REF>&read_only=true&features=database,docs,debugging,development"
      }
    }
  }
  ```
  The params `read_only=true`, `project_ref=<ref>` and `features=database,docs` are documented (source: https://github.com/supabase-community/supabase-mcp). The README quotes all three together: `?project_ref=<project-ref>&read_only=true&features=database,docs`.
- **Safety options:**
  - `read_only=true`: runs "all queries as a read-only Postgres user" (source: https://supabase.com/docs/guides/getting-started/mcp) and "excludes mutating tools" (source: https://github.com/supabase-community/supabase-mcp).
  - `project_ref=<id>`: limits access to one project, "omits `project_id` from tool input schemas and excludes account-level tools" (source: https://github.com/supabase-community/supabase-mcp).
  - `features=`: groups are account, docs, database, debugging, development, functions, branching, storage, notebooks (list_notebooks, get_notebook). Storage and notebooks are off by default; the rest are on (source: https://supabase.com/mcp).
- **Tools by group (source: https://supabase.com/mcp):**
  - database: `list_tables`, `list_extensions`, `list_migrations`, `apply_migration`, `execute_sql`
  - debugging: `query_logs` (replaces `get_logs`, which stays hidden where query_logs exists), `get_advisors`
  - development: `get_project_url`, `get_publishable_keys`, `generate_typescript_types`
  - functions: `list_edge_functions`, `get_edge_function`, `deploy_edge_function`
  - account: `list_projects`, `get_project`, `create_project`, `pause_project`, `restore_project`, `list_organizations`, `get_organization`, `get_cost`, `confirm_cost`
  - docs: `search_docs`
  - branching (experimental, needs a paid plan): `create_branch`, `list_branches`, `delete_branch`, `merge_branch`, `reset_branch`, `rebase_branch`
  - storage: `list_storage_buckets`, `get_storage_config`, `update_storage_config`
- **Official security guidance** (source: https://supabase.com/docs/guides/getting-started/mcp): watch for prompt injection from data stored in the database; don't connect to production (use scoping and read-only if you must); never expose the server to end users; use read-only for unattended runs; test on branches; limit feature groups; keep manual tool approval on.
- **Pitfalls:**
  - `apply_migration` creates a migration on the remote project. If your repo is linked through the GitHub integration, that migration is not in `supabase/migrations/` until you run `supabase db pull`, so the repo and the database drift apart (the pull workflow is at https://supabase.com/docs/guides/deployment/branching/working-with-branches).
  - `execute_sql` with writes allowed bypasses migrations completely.
  - Local stdio package `npx -y @supabase/mcp-server-supabase@latest --read-only --project-ref=<ref>` with `SUPABASE_ACCESS_TOKEN`: verified in src/cli.ts (0.13.0: --project-ref, --read-only, --features, --access-token); not needed, the remote server is simpler.
  - **Claude directory connector** (Feb 2026) is read-write and unscoped; use a custom connector with the scoped URL instead. 0.13.0 adds destructive-SQL confirmation and wraps results in untrusted-data boundaries.
- **License:** Apache-2.0 (source: https://github.com/supabase-community/supabase-mcp)

## 2. Vercel MCP

- **Docs:** https://vercel.com/docs/agent-resources/vercel-mcp and tools at https://vercel.com/docs/agent-resources/vercel-mcp/tools. Status: **Public Beta**.
- **Transport:** Remote Streamable HTTP with OAuth at `https://mcp.vercel.com`. Only Vercel-approved clients can connect, and Claude Code and Claude.ai/Desktop are on the list (source: https://vercel.com/docs/agent-resources/vercel-mcp).
- **Install:**
  ```bash
  claude mcp add --transport http vercel https://mcp.vercel.com
  # then in Claude: /mcp  → authenticate
  ```
  Desktop/Cowork: Settings > Connectors > Add custom connector, name `Vercel`, URL `https://mcp.vercel.com` (source: https://vercel.com/docs/agent-resources/vercel-mcp). You can also run `npx add-mcp https://mcp.vercel.com` or `vercel mcp --clients "Claude Code"`.
- **Project scoping:** `vercel mcp --project` points clients at `https://mcp.vercel.com/<org>/<project>` "so the MCP session is scoped to the linked Vercel Project" (source: https://vercel.com/docs/cli/mcp).
- **Key tools** (source: https://vercel.com/docs/agent-resources/vercel-mcp/tools): `search_vercel_documentation`, `list_teams`, `list_projects`, `get_project`, `list_deployments`, `get_deployment`, `get_deployment_build_logs`, `get_runtime_logs`, `get_runtime_errors`, **`deploy_to_vercel`** (preview or production), `get_web_analytics`, Agent Runs tools, `check_domain_availability_and_price`, **purchase tools** (`get_purchase_quote`, `buy_pro`, `buy_credits`, `buy_addon`, `buy_domain`), `get_access_to_vercel_url` (creates shareable bypass links for protected deployments), `web_fetch_vercel_url`, `import-claude-design-from-url`, `get_domain_order`, Toolbar comment tools (`list_toolbar_threads`, `get_toolbar_thread`, `change_toolbar_thread_resolve_status`, `reply_to_toolbar_thread`, `edit_toolbar_message`, `add_toolbar_reaction`), `use_vercel_cli`.
- **Safety:** there is no read-only mode. Vercel says "Connecting to Vercel MCP grants the AI system ... the same access as your Vercel user account" and recommends enabling human confirmation (source: https://vercel.com/docs/agent-resources/vercel-mcp). Purchases take two steps: a quote returns an `idempotencyKey`, then `buy_*` runs with `confirm: true` (source: https://vercel.com/docs/agent-resources/vercel-mcp/tools).
- **Pitfalls:**
  - Block `deploy_to_vercel` (even previews bypass Git and may create a new project), all `buy_*` and `import-claude-design-from-url` client-side, as Vercel's own read-only recipe does (https://vercel.com/kb/guide/software-factory-vercel-mcp). An official Claude directory connector exists (https://claude.com/connectors/vercel).
  - `deploy_to_vercel` uploads a file tree directly, which bypasses the GitHub-based deploy flow. The deployment won't match a Git commit.
  - I found no environment variable tools in the tools list, so manage env vars in the dashboard or through the Supabase integration.

## 3. GitHub MCP

- **Repo:** https://github.com/github/github-mcp-server. **License:** MIT (source: same).
- **Transport:** Remote HTTP at `https://api.githubcopilot.com/mcp/`, or local Docker at `ghcr.io/github/github-mcp-server` (source: https://github.com/github/github-mcp-server).
- **Install, Claude Code with a PAT** (source: https://github.com/github/github-mcp-server/blob/main/docs/installation-guides/install-claude.md):
  ```bash
  claude mcp add-json github '{"type":"http","url":"https://api.githubcopilot.com/mcp","headers":{"Authorization":"Bearer YOUR_GITHUB_PAT"}}'
  # Claude Code <=2.1.0 legacy:
  claude mcp add --transport http github https://api.githubcopilot.com/mcp -H "Authorization: Bearer YOUR_GITHUB_PAT"
  ```
  Local Docker with OAuth login in the browser:
  ```bash
  claude mcp add github -e GITHUB_OAUTH_CALLBACK_PORT=8085 -- docker run -i --rm -p 127.0.0.1:8085:8085 -e GITHUB_OAUTH_CALLBACK_PORT ghcr.io/github/github-mcp-server
  ```
  Remote OAuth needs the host app to register a GitHub App or OAuth App. The README lists Claude Desktop as compatible (source: https://github.com/github/github-mcp-server), but the Claude install guide says remote OAuth for Claude Desktop "is not currently supported" (source: install-claude.md above). **These two sources conflict.** Use a fine-grained PAT to be safe.
- **Toolsets:** the defaults are `context, repos, issues, pull_requests, users`. Others include actions, code_quality, code_security, copilot, dependabot, discussions, gists, git, labels, notifications, orgs, projects, and more. The special keywords are `all` and `default` (e.g. `default,actions`) (source: https://github.com/github/github-mcp-server).
- **Remote scoping by URL or header** (source: https://github.com/github/github-mcp-server/blob/main/docs/remote-server.md):
  - `https://api.githubcopilot.com/mcp/x/{toolset}` (e.g. `/x/repos`) or `/x/all`
  - Add `/readonly` to any path, e.g. `https://api.githubcopilot.com/mcp/x/repos/readonly`
  - Headers: `X-MCP-Toolsets: repos,issues`, `X-MCP-Readonly: true`, `X-MCP-Lockdown: true` (hides public issue content from users without push access, which defends against prompt injection)
  - Experimental features: `/insiders` or `X-MCP-Insiders: true`
- **Local flags:** `--read-only` / `GITHUB_READ_ONLY` take priority over requested write tools. `--toolsets` / `GITHUB_TOOLSETS` pick toolsets (source: https://github.com/github/github-mcp-server).
- **Pitfalls:**
  - A classic PAT gives broad access. Use a fine-grained PAT limited to the repos you need.
  - Issue and PR text from strangers can carry prompt injection, so turn on lockdown for public repos.
  - Claude Code already has the `gh` CLI and git, so this server partly duplicates them.

## 4. Playwright MCP

- **Repo:** https://github.com/microsoft/playwright-mcp. **License:** Apache-2.0.
- **Install:** `claude mcp add playwright npx @playwright/mcp@latest` (source: same).
  ```json
  { "mcpServers": { "playwright": { "command": "npx", "args": ["@playwright/mcp@latest", "--isolated"] } } }
  ```
- **Flags:** `--headless` (the browser is headed by default), `--isolated` (profile kept in memory), `--browser chrome|firefox|webkit|msedge`, `--caps vision,pdf,devtools`, `--allowed-origins`, `--blocked-origins`, `--user-data-dir`, `--extension` (connects to your running browser).
- **Tools:** navigate, click, type, accessibility-tree snapshot, screenshot, tabs, network mocking, storage/cookies, PDF, locator generation.
- **Pitfalls:**
  - "Playwright MCP is not a security boundary."
  - The Playwright CLI + skills is recommended as the more token-efficient option for coding agents.
  - Playwright MCP overlaps with Chrome DevTools MCP and with Claude's built-in Chrome extension, so pick one browser tool to avoid confusing the model. (All from https://github.com/microsoft/playwright-mcp. The overlap advice is my own assessment.)

## 5. Chrome DevTools MCP

- **Repo:** https://github.com/ChromeDevTools/chrome-devtools-mcp. **License:** Apache-2.0.
- **Install:** `npx -y chrome-devtools-mcp@latest`, or as a Claude Code plugin with `/plugin install chrome-devtools-mcp@chrome-devtools-plugins` (source: same). The standard form `claude mcp add chrome-devtools npx chrome-devtools-mcp@latest` is also expected to work (**UNVERIFIED** exact wording).
- **Flags:** `--isolated` (temporary profile), `--headless`, `--browserUrl http://127.0.0.1:9222`, `--autoConnect` (to a running Chrome 144+), `--slim` (3 tools only), `--channel canary|dev|beta|stable`.
- **Tools:** input automation, navigation, emulation, **performance traces/insights (LCP, CLS)**, network, console, memory, extensions, PWA. Best for debugging "why is my page slow or broken".
- **Pitfall:** it exposes browser content to the client, so don't use it on a profile with sensitive logins. Use `--isolated` (source: same).

## 6. shadcn MCP

- **Docs:** https://ui.shadcn.com/docs/mcp
- **Install:** `pnpm dlx shadcn@latest mcp init --client claude` (or `npx`). This writes:
  ```json
  { "mcpServers": { "shadcn": { "command": "npx", "args": ["shadcn@latest", "mcp"] } } }
  ```
- **Tools:** browse, search and install components, blocks and templates from any registry listed in `components.json` (`registries` with `{name}` URL templates, and optional auth headers from `.env.local`).
- **Requirements:** a valid `components.json`. Run `npx shadcn init` first.
- **License:** MIT (**UNVERIFIED** in this session, though the shadcn/ui repo is widely known to be MIT).

## 7. Context7 (Upstash)

- **Repo:** https://github.com/upstash/context7. **License:** MIT.
- **Transport:** Remote `https://mcp.context7.com/mcp`. An API key is optional but raises rate limits, and it is passed as `Authorization: Bearer <key>` (free key at https://context7.com/dashboard) (source: https://github.com/upstash/context7).
- **Install:** `npx ctx7 setup --claude` (does OAuth and creates the key). You can also choose a "CLI + Skills" mode that uses no MCP. A manual form such as `claude mcp add --transport http context7 https://mcp.context7.com/mcp --header "Authorization: Bearer <key>"` follows standard Claude Code syntax (**UNVERIFIED** as quoted in the README).
- **Tools:** `resolve-library-id`, `query-docs`.
- **Pitfalls:**
  - The docs are community-contributed, so accuracy isn't guaranteed.
  - Pin library IDs such as `/vercel/next.js` and mention versions.
  - For Next.js 16, `next-devtools-mcp`'s `nextjs_docs` reads version-matched docs from `node_modules`, which may be more accurate.

## 8. Next.js DevTools MCP (exists)

- **Repo:** https://github.com/vercel/next-devtools-mcp. **License:** MIT.
- **Install:** `claude mcp add next-devtools npx next-devtools-mcp@latest` (or `npx add-mcp next-devtools-mcp@latest`).
- **Tools:**
  - `nextjs_index`: finds running dev servers
  - `nextjs_call`: calls runtime tools through Next 16's built-in `/_next/mcp` endpoint, e.g. errors, routes, logs
  - `nextjs_docs`: version-matched docs from `node_modules/next/dist/docs/`
  - `browser_eval`: now points the agent to the `agent-browser` CLI
- **Requirements:** Next.js 16+ with `npm run dev` running. The error "No server info found" means the dev server isn't running.
- **Privacy:** it sends telemetry about tool usage. Opt out with `NEXT_TELEMETRY_DISABLED=1`. (All from https://github.com/vercel/next-devtools-mcp.)

## 9. Figma MCP (formerly Dev Mode MCP)

- **Docs:** https://developers.figma.com/docs/figma-mcp-server/
- **Transport:** Remote `https://mcp.figma.com/mcp` (recommended), or the Desktop app server at `http://127.0.0.1:3845/mcp`. Only clients in the Figma MCP Catalog can connect.
- **Install** (source: https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/):
  ```bash
  claude mcp add --transport http figma https://mcp.figma.com/mcp
  # or (recommended; includes skills):
  claude plugin install figma@claude-plugins-official
  ```
- **Tools** (the connected Figma server in this environment exposes these): `get_design_context`, `get_screenshot`, `get_metadata`, `get_variable_defs`, `get_code_connect_map`, `add_code_connect_map`, `create_design_system_rules`. The docs also mention writing native content to the canvas and "Make" resources.
- **Plan limits** (source: https://developers.figma.com/docs/figma-mcp-server/rate-limits-access/):
  - Starter plan: up to 20 calls per month.
  - View and Collab seats on paid plans: 6 calls per month.
  - Dev or Full seats: 200 per day and 10 per minute on Professional; 200 per day and 15 per minute on Organization; 600 per day and 20 per minute on Enterprise.
  - **For a no-coder on a free or View seat, this is effectively unusable.**
- **Pitfalls:**
  - Large frames degrade output.
  - It returns design context, not finished code.

## 10. Sentry MCP

- **Docs/site:** https://mcp.sentry.dev/ (https://docs.sentry.io/product/sentry-mcp/ redirects there). **Repo:** https://github.com/getsentry/sentry-mcp
- **Remote:** OAuth at `https://mcp.sentry.dev/mcp`. Scope it by path, which the docs recommend:
  ```bash
  claude mcp add --transport http sentry https://mcp.sentry.dev/mcp/{organizationSlug}/{projectSlug}
  ```
  Add `?experimental=1` for experimental tools (source: https://mcp.sentry.dev/).
- **Local stdio:** `npx @sentry/mcp-server@latest --access-token=<token>` (add `--host` for self-hosted).
  - The token needs the scopes `org:read, project:read, project:write, team:read, team:write, event:write`.
  - The AI-powered search tools (`search_events`, `search_issues`) need `EMBEDDED_AGENT_PROVIDER` plus an OpenAI, Anthropic or OpenRouter key.
  - Narrow the tool set with `--skills=inspect,triage` or `--disable-skills=seer`.
  - (Source: https://github.com/getsentry/sentry-mcp)
- **License:** the repo has a LICENSE.md, but I did not confirm its type (**UNVERIFIED**, likely FSL/Apache).

## 11. Stripe MCP

- **Docs:** https://docs.stripe.com/mcp
- **Remote:** `https://mcp.stripe.com`
  ```bash
  claude mcp add --transport http stripe https://mcp.stripe.com/
  # then /mcp to OAuth
  ```
  or run `npm i -g @stripe/cli@latest && stripe agent setup`, which installs the plugin and skills. For Claude.ai/Desktop there is an official connector in the Claude directory.
- **Auth:** OAuth lets you grant access **per account or sandbox**, so you can grant only a sandbox. Autonomous clients use an Agent API key.
  - **From Oct 31, 2026, full secret keys and restricted keys without the Agent tag will be rejected.**
  - Admins can turn MCP access on or off separately for live and sandbox, and can revoke OAuth sessions.
- **Tools:** `stripe_api_search`, `stripe_api_details`, `stripe_api_read` (any GET), `stripe_api_write` (any POST, PATCH, PUT or DELETE), `get_stripe_account_info`, `stripe_analytics`, `get_balance_summary`, `search_stripe_documentation`, `stripe_implementation_planner`, `send_stripe_feedback`.
- **Safety:** Stripe requires human confirmation through a URL for certain writes such as refunds and outbound payments. It also advises turning on client confirmation and taking care with prompt injection when other servers are connected.
- **The old local `npx @stripe/mcp --tools=all --api-key=...`** is no longer shown on the docs page (**UNVERIFIED** whether it is deprecated).
- (All from https://docs.stripe.com/mcp.)

## 12. Resend MCP

- **Repo:** https://github.com/resend/resend-mcp. **License:** MIT.
- **Options:**
  - Hosted remote: `https://mcp.resend.com/mcp`
  - Local stdio: `claude mcp add resend -e RESEND_API_KEY=re_xxx -- npx -y resend-mcp`
  - Local HTTP: `--http --port 3000`
- **Env vars:** `RESEND_API_KEY`, `SENDER_EMAIL_ADDRESS`, `REPLY_TO_EMAIL_ADDRESSES`.
- **Tools:** emails, templates, contacts, broadcasts, automations, domains, segments, suppressions, topics, API keys, webhooks, logs.
- **Pitfalls:**
  - You need a verified domain before sending.
  - The server can send real email and broadcasts, and manage API keys. Use a sending-only or restricted key where you can (**UNVERIFIED** whether Resend's key permissions cover every tool).
  - The auth method for the remote server wasn't detailed (**UNVERIFIED**, likely a Bearer API key).

## 13. Graphify (Graphify-Labs/graphify)

- **Repo:** https://github.com/Graphify-Labs/graphify
- **What it is:** a Claude Code **skill** and CLI that turns a folder (code, docs, SQL, PDFs, images) into a knowledge graph. Code is parsed locally with tree-sitter. It exports HTML, JSON, a Markdown wiki, an **Obsidian vault** (`--obsidian --obsidian-dir ~/vault`), GraphML and Neo4j.
- **Install:** `pip install graphifyy && graphify install` (or `uv tool install graphifyy`). The PyPI package name is `graphifyy` with a double y. Then run `/graphify .` in Claude Code. Optional PreToolUse hooks nudge the agent to query the graph before reading raw files.
- **MCP:** a stdio server exists. The README I fetched gives `/graphify ./raw --mcp` and another render gives `python -m graphify.serve graphify-out/graph.json`. **The exact command is UNVERIFIED (two sources conflict).**
- **Privacy:** images and PDFs are sent to an LLM (Claude vision) for extraction.
- **UNVERIFIED:** the license (one fetch said Apache-2.0 and MIT, the other said none), the star count, the "YC S26" claim and the benchmark figures. All came from a model summary of the repo page, not from primary sources.
- **Verdict:** optional. It's useful for understanding a large codebase, but a no-coder building a small app doesn't need it.

## 14. Obsidian MCP options (no official Obsidian server found)

- **A. Local REST API plugin with built-in MCP** (https://github.com/coddingtonbear/obsidian-local-rest-api, MIT). The plugin serves Streamable HTTP at `https://127.0.0.1:27124/mcp/` with a self-signed cert and a Bearer API key. It has 14 tools: list, read, write, patch, delete, move and copy notes, search, tags, and running commands.
  ```bash
  claude mcp add --transport http obsidian https://127.0.0.1:27124/mcp/ --header "Authorization: Bearer <api-key>"
  ```
  - **Pitfall:** Claude Code may reject the self-signed cert. Trust the cert from `https://127.0.0.1:27124/obsidian-local-rest-api.crt`, or turn on HTTP on port 27123.
  - **Pitfall:** this only works on the machine where Obsidian is running. Cowork's cloud side can't reach it (my inference).
- **B. cyanheads/obsidian-mcp-server** (https://github.com/cyanheads/obsidian-mcp-server, Apache-2.0).
  - Run with `npx -y obsidian-mcp-server@latest` and `OBSIDIAN_API_KEY` (it needs the Local REST API plugin v4–5, default URL `http://127.0.0.1:27123`).
  - Safety options: `OBSIDIAN_READ_ONLY=true`, `OBSIDIAN_READ_PATHS` / `OBSIDIAN_WRITE_PATHS` folder allowlists, and command running is opt-in (`OBSIDIAN_ENABLE_COMMANDS=true`).
  - **This is the safest option.**
- **C. MarkusPfundstein/mcp-obsidian** (https://github.com/MarkusPfundstein/mcp-obsidian). An older Python server built on the same plugin. I did not check its details (**UNVERIFIED**).
- **Simplest alternative:** point Claude Code at the vault folder directly. A vault is just Markdown files.

---

## 15. Vercel ↔ Supabase Marketplace integration (env var sync)

- **Sources:** https://supabase.com/docs/guides/integrations/vercel-marketplace, https://vercel.com/marketplace/supabase
- **How data moves:** the integration pushes Supabase credentials into your Vercel project's environment variables. The synced variables are:
  - `POSTGRES_URL`, `POSTGRES_PRISMA_URL`, `POSTGRES_URL_NON_POOLING`, `POSTGRES_USER`, `POSTGRES_HOST`, `POSTGRES_PASSWORD`, `POSTGRES_DATABASE`
  - `SUPABASE_URL`, `SUPABASE_SECRET_KEY`, `SUPABASE_JWT_SECRET`, `SUPABASE_PUBLISHABLE_KEY`
  - `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`
  - (Source: https://supabase.com/docs/guides/integrations/vercel-marketplace.) You can customize the framework prefixes in the Supabase dashboard. You can create a new project as Vercel Storage or connect an existing one. CLI install: `vc i supabase` (source: https://vercel.com/marketplace/supabase).
- **Billing and ownership:**
  - Supabase organizations map one-to-one to Vercel teams, and invoices go through Vercel.
  - You can't remove the org manually; it's removed only when you uninstall the integration.
  - Custom domains aren't supported, so the base `SUPABASE_URL` is always used.
  - (Source: https://supabase.com/docs/guides/integrations/vercel-marketplace.)
- **Preview branches:** "Supabase automatically updates your Vercel project with the correct environment variables for the corresponding preview branches."
  - The sync happens **when a PR opens**, not when the branch is created.
  - Setting env vars can race with Vercel starting a build, so Supabase "automatically redeploys the most recent deployment for that pull request".
  - It needs both the Vercel Marketplace integration and the Vercel GitHub integration.
  - (Source: https://supabase.com/docs/guides/deployment/branching/integrations.) It also auto-creates redirect URLs in preview branches (source: https://vercel.com/marketplace/supabase).
- **Known conflicts and pitfalls:**
  - **Env var drift:**
    - If you hand-edit a synced variable in Vercel, or keep old names like `NEXT_PUBLIC_SUPABASE_ANON_KEY` or `SUPABASE_SERVICE_ROLE_KEY` while the integration now syncs `*_PUBLISHABLE_KEY` / `SUPABASE_SECRET_KEY`, your code and the synced values can drift apart. The naming change is shown in the variable list above; that drift follows from it is my inference.
    - Env var changes on Vercel only apply to **new** deployments, so you must redeploy (standard Vercel behavior; **UNVERIFIED** in this session).
  - **Wrong DB on previews:** if the integration isn't installed on the Supabase side, preview deploys fall back to another database, such as a persistent `dev` branch, and fail on schema mismatches. The fix is to reinstall and turn on preview-branch env sync (real-world report: https://github.com/TropTix/troptix/issues/584).
  - **Persistent git branches** (e.g. `staging`) may not get branch-specific env vars. Supabase has a troubleshooting article on this (https://supabase.com/docs/guides/troubleshooting/vercel-integration-environment-variables-not-syncing-for-persistent-git-branches-b9191e), but my fetch didn't return its body (**UNVERIFIED** details).
  - `SUPABASE_SECRET_KEY` and `POSTGRES_PASSWORD` are server-only. Never give them a `NEXT_PUBLIC_` prefix. Vercel's page warns about care with secret env vars (https://vercel.com/marketplace/supabase).

## 16. Supabase GitHub integration and branching

- **Sources:** https://supabase.com/docs/guides/deployment/branching, https://supabase.com/docs/guides/deployment/branching/github-integration, https://supabase.com/docs/guides/deployment/branching/troubleshooting, https://supabase.com/docs/guides/deployment/branching/working-with-branches
- **How data moves:**
  - Supabase watches the repo. You set the path to the `supabase/` directory (`.` if it's at the root).
  - Each Git branch or PR gets a preview branch that clones the project's config and Edge Functions and **builds its schema from committed migrations** in `supabase/migrations/`. Later commits apply only the new migrations.
  - `seed.sql` seeds the preview branch only and is never merged to production.
  - `config.toml` settings are applied on top of the clone.
  - With "Deploy to production" on, merging to the production branch applies new migrations, deploys the Edge Functions and creates the storage buckets declared in `config.toml`.
  - Supabase recommends GitHub required status checks so a PR can't merge when migration checks fail.
  - (Source: https://supabase.com/docs/guides/deployment/branching/github-integration.)
- **Branch types:**
  - Preview branches are deleted when the PR merges or closes. Persistent branches are for staging and QA.
  - "By default, new branches do not start with any data or storage objects from your main project."
  - Each branch is billed for its own compute.
  - (Source: https://supabase.com/docs/guides/deployment/branching.) The Supabase MCP branching tools need a paid plan (source: https://supabase.com/mcp).
- **Conflicts:**
  - **Migrations vs dashboard edits:** production is changed by migrations from Git. If you or an MCP `apply_migration` / `execute_sql` call edits the schema in the dashboard, the repo no longer reflects the database.
    - Supabase's remote workflow is: make the dashboard change, then run `supabase db pull` to create a migration file and commit it. The local workflow uses `supabase db diff`.
    - (Source: https://supabase.com/docs/guides/deployment/branching/working-with-branches.)
    - If you skip the pull, the next branch built from migrations won't have your dashboard change (my inference from the "schema built from migrations" rule).
  - **Drift between branches:** "When a preview branch is merged into the production branch, it creates a schema drift between the production branch and the preview branches that haven't been merged yet." Fix it by rebasing the branch or regenerating migrations with new timestamps (source: https://supabase.com/docs/guides/deployment/branching/troubleshooting).
  - **Migration timestamp collisions** after Git rebases: filenames must have unique, correctly ordered timestamps (same source).
  - **Permissions on new branches:** "New branches are created without default privileges on the `public` schema." Migrations must include `alter default privileges ... grant` statements, or API calls fail (sources: working-with-branches and troubleshooting).
  - **Rollback on a preview branch:** push the fix, delete the Supabase branch and reopen it (source: troubleshooting).
  - **Empty preview data:** previews have no production data, so the app will look empty unless `seed.sql` provides data (source: branching overview).

---

## Recommendations for a no-coder (my synthesis)

1. **Core (install these):**
   - Supabase: scoped to a **dev** project with `read_only=true` at first. Remove read-only only for supervised migration sessions.
   - Vercel.
   - GitHub remote: `/x/repos,issues,pull_requests` via header, or `/readonly` at first.
   - Next.js DevTools.
   - shadcn.
   - Context7.
2. **Pick one browser tool:**
   - In Cowork, Claude in Chrome is already built in.
   - In Claude Code, use Chrome DevTools MCP with `--isolated` to debug and check performance, or Playwright MCP to run end-to-end flows. Don't install all three.
3. **Only when needed:**
   - Stripe: grant a sandbox only through OAuth.
   - Resend.
   - Sentry: use the project-scoped URL.
   - Figma: only if you have a Dev or Full seat.
4. **Optional:** Graphify and Obsidian, for knowledge management.
5. **Golden rules:**
   - Schema changes go through committed migrations only; if you edit in the dashboard, run `supabase db pull` right after.
   - Never point any MCP at production with writes on.
   - Block `deploy_to_vercel`, every `buy_*` and `import-claude-design-from-url` (Cowork: Blocked; Code tab: settings.json deny). Keep tool-approval prompts on for `apply_migration`, `execute_sql`, `stripe_api_write` and email sends.
   - Let the Vercel↔Supabase integration own Supabase env vars; don't hand-edit them.
