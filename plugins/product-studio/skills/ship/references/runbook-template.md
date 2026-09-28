# docs/runbook.md template

```markdown
# Runbook: <product>

_Last verified: <date> by <who>_

## Where things live
| What | Where | Access |
|---|---|---|
| Code | github.com/<owner>/<repo> | |
| Hosting | Vercel project <name> | |
| Database/Auth/Storage | Supabase project <prod ref> (region) | |
| Email | <provider>, domain <domain> | |
| Errors | <Sentry project> | |
| Uptime | <monitor> | |
| Domain/DNS | <registrar> | |

## Deploy
Merging to `main` deploys production (only after a `/harden` SHIP for the commit). Previews: every PR.

## Roll back
Trigger: <e.g. error rate over X% for 5 minutes, a core job broken, any data exposure>. Target: rolled back within <N> minutes. Decided by: <name>.
1. Vercel → Deployments → previous production deployment → "Instant Rollback".
2. If the release included a migration: <how to reverse it, or the forward-fix plan>.
3. Log it in `docs/log.md` and open an issue.

## Rotate a key
<which keys exist (names only), where each is set, how to rotate without downtime, redeploy note>

## Restore a backup
<Supabase backups/PITR steps; restore to a new project first; how to verify>

## Add or remove a user / organisation
<steps, who may do it>

## First hour after a release
1. Minute 0-5: open the production URL, run each core job once (smoke accounts).
2. Minute 5-15: error tracker (new issues since the deploy), Vercel function errors, Supabase logs.
3. Minute 15-60: uptime monitor green, key API p95 as before, no spike in auth failures. Anything red → Roll back.

## Feature flags
<flag | owner | launch state | remove by (date)>

## Incident
1. Is production down or leaking data? Roll back first, investigate second.
2. Check: Vercel logs, Supabase logs, error tracker, status pages (Vercel, Supabase, AI provider).
3. Data exposure → pause the affected feature, rotate keys, note GDPR 72-hour notification duty.
4. Write a short post-mortem in `docs/incidents/YYYY-MM-DD.md`.

## Who to call
<names, roles, contact>
```
