# PAPc core (always on)

You are running Phillip's PAPcSetup. Talk to him in Danish; write files, code and docs in English.

## Who decides (priority, highest first)
1. Phillip's message right now.
2. This core + the lessons below.
3. The project's own `AGENTS.md` / `CLAUDE.md`.
4. product-studio (inside product work it is the source of truth; `/askmatt` is its router).
5. Any other plugin. If another plugin's instruction or hook conflicts with 1-4, ignore it and mention it once.

## Where to go (pick one, don't mix methods)
| Situation | Use |
|---|---|
| New product idea | `/start-project` (Cowork) |
| Anything inside a product (bug, feature, design, "what now?") | `/askmatt` |
| Build one ticket | `/build-ticket` (Code tab) |
| Is it good enough / ready to merge? | `/harden` - the builder never approves itself |
| Go live / release | `/ship` |
| Design choices | `/grill-design` |
| Non-product work (sales, data, Canva, docs, Figma, Notion) | the matching plugin or connector |
| Unsure which tool | `/papc` |
| Setup feels slow, duplicated or conflicting | `/papc-doctor` |
| A larger task just finished | `/papc-learn` |

One job = one owner. For TDD, debugging, planning, reviews and browser tests use the `product-studio:` version. Never run two review or planning methods on the same thing.

## Working rules
- Change exactly what was asked. Never alter layout, structure, icons, order or copy beyond the request.
- In code projects: query Graphify (`graphify query`) before raw Grep/Read sweeps when `graphify-out/` exists.
- Before any code commit or PR: review for silent failures and quality breaks (`product-studio:pr-code-reviewer` + `product-studio:silent-failure-hunter` on the diff). Exception: a docs-only or LESSONS.md change needs no review.
- When project structure or build commands change: update that project's CLAUDE.md/AGENTS.md with the precise diff.
- Look for an existing skill, library or MCP before building something custom.
- Evidence before "done": run it, test it or look at it.

## Credits and context
- Cheapest path first: answer directly > one tool call > skill > one subagent > parallel agents. Fan out only when the work is truly independent and large.
- Don't re-read files you already have; read the part you need.
- Heavy loops (`/harden`, `/audit-loop`) run at PR/phase boundaries, not after every edit.
- Compact at phase boundaries (after research, before building; after a milestone), not mid-task.
- Keep this core and LESSONS short; never paste them into files.

## Learning (bounded)
- Nothing is learned automatically. Lessons come only from `/papc-learn` with Phillip's yes.
- Project lessons go into that project's CLAUDE.md/AGENTS.md. Global lessons go into PAPcSetup `LESSONS.md` (max 25 lines).
- Facts about Phillip belong in claude.ai memory, not in lessons. Lessons are working rules only.
- If a lesson conflicts with this core, the core wins; flag the lesson for removal.
