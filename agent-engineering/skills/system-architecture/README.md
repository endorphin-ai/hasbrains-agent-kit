# system-architecture

> Technology-agnostic system design — pick the pattern and the tech BEFORE touching framework mechanics.

**Plugin:** `agent-engineering` — `/plugin install agent-engineering@hasbrains-agent-kit`

## Why use it

- Jumping straight to schemas and modules bakes in an architecture nobody chose.
- "Which database / queue / API style?" answered by habit rather than by the actual constraints.
- Migrations and scale limits discovered after the build, not before it.

## What it does

- Architecture-pattern selection with trade-offs — monolith → modular monolith → microservices → event-driven → CQRS → event sourcing → hexagonal → clean → API gateway.
- System-design workflows: capacity planning, API design, schema design, scalability assessment, migration planning.
- Technology-decision frameworks: database, cache, message queue, auth, frontend, cloud, API style.
- A lean map over three references — read the map, open the one that matches the question.

## Benefits

- **Make the expensive call once.** Pattern and tech chosen deliberately, and written down.
- **No accidental architecture.** You stop inheriting a shape nobody picked.
- **Scale problems surface on paper**, while they still cost nothing to fix.
- **Stack-agnostic.** Pairs with whatever framework skill you already run.

---

Made by **HasBrains** — https://hasbrains.com/
