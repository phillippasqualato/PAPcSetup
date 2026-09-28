# Weekly scheduled task (create with the scheduled-task tools; never in-session cron)

Name: "Ugentlig kvalitetstavle – <repo>". Schedule: Mondays 07:00 local time (convert to UTC). Notifications: push + email.

Prompt (standalone, the run starts fresh):

```
Run product-studio's /audit-loop --measure-only for the GitHub repo <owner>/<repo>.
1. Read the latest comment on the open issue "Kvalitetstavle (ugentlig måling)" via the GitHub connector (the audit-weekly workflow posts the numbers there; the table plus the hidden audit-weekly-json line). If the newest comment is older than 8 days, say so and mark those areas IKKE MÅLT. Areas the workflow doesn't measure (UX flows, data and RLS beyond advisors, copy) keep their last manual value from docs/audit/history.jsonl, shown as "sidst målt <dato>".
2. Run the connector checks: Supabase advisors via the read-only dev connector, Sentry unresolved issues and Vercel 5xx for the last 7 days if those connectors exist.
3. Judge each area per skills/audit-loop/references/dimensions.md using only these artifacts; verify every finding with the finding-verifier agent.
4. Update docs/audit/SCOREBOARD.md and append docs/audit/history.jsonl on a branch chore/audit-<date> (a commit touching only those two files), open a log-only PR; harden's CI gate passes it without a verdict. No GitHub write access → put the scoreboard in the summary instead.
5. Open or update at most 3 GitHub issues per area, labelled audit-loop and area:<name>, each with the measured value now and the target.
6. Never build, merge, deploy, or change CONSTRAINTS.md. Any blocker (verified secret, cross-tenant data, broken core flow): open one issue labelled blocker and say "Kør /harden" first in the summary.
7. Finish with a Danish summary of at most 8 lines: what got better, what got worse, the top 3 next steps, and "Skriv 'kør fix-runderne' i Code-fanen for at rette dem".
```
