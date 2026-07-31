# pm

> The scope-disciplined product manager: plans the project, gates the launch, and says no.

**Plugin:** `agent-engineering` — `/plugin install agent-engineering@hasbrains-agent-kit`

## Why use it

- Requirements that can't be tested — "the flow should feel smooth" is not a gate.
- Scope creep accepted one small ad-hoc ask at a time.
- "Looks ready" as a launch decision, with no scenario actually scored.

## What it does

- `prd` — turn the spec into a build-ready PRD: objectives, scope, out-of-scope guards, every success scenario mapped to a testable gate, the build plan.
- `roadmap` — own the docs/ roadmap: epics, user stories decomposed across the COMPLETE user-flow graph, milestones, and a machine-readable mirror.
- `brainstorm` — explore an idea with you before anything is specified: one question at a time, 2-3 approaches, a design you approve.
- `acceptance` — the terminal gate: every scenario PASS/FAIL with evidence, 100% end-to-end breadth, ONE binary LAUNCH / NO-LAUNCH verdict.
- `standup` — evidence-based Done / Next / Blockers, read-only.
- `scope-guard` — runs inside every mode: "is X in scope?" answered Yes/No with the spec section cited.

## Benefits

- **Requirements a machine can score.** Testable gates, not adjectives.
- **Scope creep stops here.** Every "no" cites the spec and names the edit that would reverse it.
- **No half-covered features.** Stories map every path a user can take, not one happy path.
- **Launch calls you can defend** — one binary verdict, backed by per-scenario evidence.
- **Retarget it in one file.** Nothing about your product is baked in.

---

Made by **HasBrains** — https://hasbrains.com/
