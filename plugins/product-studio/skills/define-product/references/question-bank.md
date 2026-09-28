# Product question bank (seeds for the design tree)

Not a script. Use it to make sure no branch is forgotten; ask only what the idea hasn't already answered, in dependency order. Always attach a recommended answer.

## Root: purpose
- Why does this need to exist now? What happens today without it (the workaround)?
- Internal tool for one company, or a product sold to many companies? (Decides multi-tenancy, billing, onboarding.)
- What is the one outcome that would make the first customer say "det her er pengene værd"?

## Users and roles
- Who are the distinct roles (e.g. admin, case worker, viewer, external client)? What does each need?
- How many users per customer, and how often do they use it (daily/weekly/monthly)?
- Desktop, mobile, or both? At a desk or in the field?
- Technical comfort of the least technical user?
- Language(s) of the UI? Danish only, English, both?

## Core jobs (the MVP)
- List the jobs users hire the product to do. Which 1-3 are the MVP?
- For each job: trigger → steps → result. What does "done" look like?
- What data does the user create, see, change, export? What is the most important object ("the noun")?
- What must be searchable/filterable/sortable?
- Notifications: what should the user be told, where (email, in-app, Slack)?

## Boundaries
- Non-goals: what is explicitly not in v1?
- What would be tempting to add but should wait?

## Data and trust
- Personal data involved? (GDPR: legal basis, retention, deletion, EU hosting.)
- Who owns the data? Can a customer export or delete everything?
- Import from existing systems (Excel, CSV, another SaaS)? One-time or ongoing?
- Audit needs: who changed what, when?

## AI features (if any)
- What should AI do that a normal feature can't? What is the input, what is the output?
- Human in the loop: does a person approve AI output before it matters?
- What is an unacceptable AI mistake here?

## Integrations
- Which external systems must it talk to (e-conomic, Dinero, Microsoft 365, Google, Slack, HubSpot, Stripe, MitID…)? Read, write, or both?

## Business
- Who pays, how (per seat, per company, usage)? Free trial?
- How does a new customer get started (self-signup vs invited by you)?
- Competitors or alternatives the customer compares against?

## Success
- How will we know it works: 2-4 observable success criteria for v1.
- Deadline or event driving the timeline? (demo, pilot customer, sales meeting)

## Pilot
- Is there a real first customer/user who can test? What will they judge it on?
