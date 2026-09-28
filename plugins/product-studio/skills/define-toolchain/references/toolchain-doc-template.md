# docs/toolchain.md template

```markdown
# Toolchain

_Last audited: <date> by toolchain-auditor. Re-run define-toolchain when any tool changes._

## Tool matrix
| Capability | Cowork | Code tab | CI | Canonical | Scope / safety |

## Data flow
<mermaid diagram from data-flow-template>
<artifact table>

## Skills and agents per job
<the canonical rows from the catalog that apply to this project; alternates listed as "don't use unless asked">

## MCP servers
| Server | Surface | Config (no secrets) | Read-only? | Needs approval for |

## Permissions
<summary of .claude/settings.json allow/ask/deny rules and why>

## Conflict register
| # | Severity | Class | Collision | Resolution | Status (open/resolved <date>) |

## Golden rules
1. Schema changes only through committed migrations; dashboard change → `supabase db pull` → commit.
2. Deploy only through GitHub → Vercel. No agent deploys at all: `deploy_to_vercel` is denied/Blocked (even previews bypass Git).
3. No agent has write access to production data. Dev project + read-only MCP by default.
4. Env var values live in Vercel (synced by the Supabase integration); names in `.env.example`; never `NEXT_PUBLIC_` on a secret.
5. Only impeccable writes `DESIGN.md`; reference analyses live in `docs/design/references/`.
6. One tracker, one product doc, one instruction file (`AGENTS.md`; `CLAUDE.md` imports it).
7. Adding a tool = re-run the audit first.

## Monthly cost estimate
| Service | Plan | Est. cost | Notes |
|---|---|---|---|
| Supabase | Free (dev + prod) → Pro at launch | $0 → ~$35/month | branching extra (~$0.013/h per branch), outside the Spend Cap |
```
