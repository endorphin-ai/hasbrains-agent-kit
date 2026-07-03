---
name: system-architecture
description: "Use when designing a system, choosing an architecture pattern, making a technology decision, or doing capacity/scalability planning — BEFORE drilling into framework-specific mechanics. A lean MAP over three reference docs: pattern selection (monolith → modular monolith → microservices → event-driven → CQRS → event sourcing → hexagonal → clean → API gateway, with trade-offs), the how-to system-design workflows (system-design-interview approach, capacity planning, API design, DB schema design, scalability assessment, migration planning), and the technology-choice frameworks (database, caching, message queue, auth, frontend framework, cloud provider, API style). Trigger on: 'design the system', 'choose an architecture pattern', 'which pattern fits', 'tech decision', 'SQL or NoSQL', 'REST vs GraphQL vs gRPC', 'capacity/scalability planning', 'plan the migration'. This is general system-design knowledge; for Phoenix bounded-context/Ecto/authz/Oban specifics use the architecture-phx skill."
---

TASKLANG
TYPE SKILL

IDENTITY "System Architecture"
  > General-purpose system-design knowledge for the planning step that comes
  > BEFORE technology-specific mechanics: pick the right architecture PATTERN,
  > make the load-bearing TECHNOLOGY decisions, and run the system-design
  > WORKFLOWS (capacity, API, schema, scalability, migration). This skill is a
  > lean MAP — the substance lives in three reference docs under references/.
  > Read the map, then open the one reference that matches the question.

!!! References FIRST — this SKILL.md only routes; the answers live in references/.
!!! This is technology-AGNOSTIC system design. For Phoenix/Ecto/Oban/can?/3
!!! specifics (bounded contexts, schema tables, the verify gate), use the
!!! architecture-phx skill — system-architecture supports the PLANNING that
!!! precedes those mechanics.

---

## When to use this skill

KNOWLEDGE
  USE_WHEN
    - "Choosing an architecture pattern for a new system or a milestone (and weighing its trade-offs)."
    - "Making a technology decision — database, cache, message queue, auth, frontend framework, cloud provider, API style."
    - "Running a system-design workflow — capacity planning, API design, schema design, scalability assessment, migration planning."
    - "Doing the PLAN-FIRST step of a design: settle pattern + data/access model + boundaries before drilling into framework mechanics."
  NOT_FOR
    - "Phoenix-specific bounded-context / Ecto schema / Oban / can?/3 policy design — that is the architecture-phx skill."
    - "Writing or verifying implementation code — this skill informs design decisions, it does not produce code."

---

## Core knowledge (the map)

KNOWLEDGE
  METHOD
    - "PLAN before mechanics: a design starts by choosing a PATTERN, settling the DATA + ACCESS model, and naming the BOUNDARIES — then drills into technology-specific implementation."
    - "Every pattern and technology choice is a TRADE-OFF, not a default. Start simple (a monolith / modular monolith) and adopt complexity (microservices, CQRS, event sourcing) only when a concrete force — scale, team autonomy, independent deploy, audit/replay — demands it."
    - "Right-size the decision to the requirements you actually have: estimate scale FIRST (capacity-planning workflow), then let the numbers drive the pattern and the technology choices."
    - "Make decisions with a framework, not a hunch: each technology choice in tech_decision_guide.md carries a decision matrix + a 'when to use each' so the choice is defensible."

---

## References (open the one that matches the question)

> Three reference docs. Read the map above, then open exactly one.

MAP references
  "references/architecture_patterns.md"     -> PATTERN SELECTION. Open when choosing/comparing an architecture pattern. Monolith, Modular Monolith, Microservices, Event-Driven, CQRS, Event Sourcing, Hexagonal, Clean Architecture, API Gateway — each with its forces, trade-offs, and a pattern-selection quick reference.
  "references/system_design_workflows.md"   -> HOW-TO WORKFLOWS. Open when you need a step-by-step design procedure: the system-design-interview approach, capacity planning, API design, database schema design, scalability assessment, and migration planning.
  "references/tech_decision_guide.md"        -> TECHNOLOGY CHOICE. Open when picking a specific technology: database (SQL vs NoSQL + type), caching strategy, message queue, authentication strategy (JWT vs sessions, OAuth flows), frontend framework (SSR vs SPA vs SSG), cloud provider, and API style (REST vs GraphQL vs gRPC).

---

## How it fits the squad

KNOWLEDGE
  FITS
    - "Supporting knowledge for the architect-phx agent's DESIGN mode (phase 2): consulted during the PLAN-FIRST step (pattern selection + tech decisions + the system-design workflows) BEFORE the Phoenix-specific technical sub-steps."
    - "Does NOT replace architecture-phx: that skill owns the Phoenix bounded-context/Ecto/Oban/can?/3 policy mechanics and the verify gate; this skill informs the architectural choices that feed them."
