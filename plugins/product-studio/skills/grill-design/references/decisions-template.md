# Design decisions (log)

DESIGN.md and component-states.md win on conflict; this file records why and who. Append-only: never edit an old row, add a new one with status `revisited`.

Status: `user` (the user chose) · `delegated` (the user said "du bestemmer"; the agent chose) · `pinned` (a must) · `leaning` (a preference fed to impeccable as evidence) · `revisited` (changed later) · `n/a`.

| id | question | answer | status | by | alternatives rejected | lands in | revisit trigger | date |
|---|---|---|---|---|---|---|---|---|
