---
id: brainstorm
title: Brainstorm / Idea-Exploration Playbook
summary: Collaborative pre-PRD idea-generation — explore context, one question at a time, 2-3 approaches, present a design, get approval; read/think-only.
tags: [pm/brainstorm, pm/workflow]
load_when: Mode brainstorm — shaping an idea or exploring options before any PRD exists.
links: [[prd]], [[scope-guard]]
---
TASKLANG
TYPE WORKFLOW

> Related: seeds [[prd]] · bounded by [[scope-guard]]

IDENTITY "Brainstorm / Idea-Exploration Playbook"
  > Collaborative idea-generation and problem-exploration WITH the user, before a PRD exists. The PM
  >   helps shape a feature or explore options: it asks questions, proposes approaches, and presents a
  >   design to get approval — then returns a structured, scoped idea set the user can act on (e.g.
  >   feed into the `prd` mode). It does NOT author the PRD here, create work items, or advance a build.
  > This workflow APPLIES the `brainstorming` skill — load it and follow its technique. This file adds
  >   the PM's scope-disciplined posture on top.

!!! Read the project config + the spec FIRST to ground the conversation in the actual project.
!!! LOAD the `brainstorming` skill and apply its method: explore context, ONE question at a time, propose 2-3 approaches, present a design, get approval. Its hard gate holds — no jumping to implementation.
!!! Scope still applies — flag anything outside the project's defined scope. A brainstorm explores ideas; it does not waive the wall.
!!! READ/THINK-ONLY: creates NO work items, mutates NO build state, advances NO phase. It returns its result directly.

---

GUARD
  - A concrete idea / problem / feature to explore is provided.
  - The project config and the spec are readable.
  ON_FAIL: FAIL("Cannot brainstorm: no concrete idea provided, or the project config/spec is unreadable.")

---

FLOW
  1. Load the brainstorming skill + explore context -- read the project config, the spec, and the
     recent work so the conversation is grounded. If the request spans several independent subsystems,
     say so and help decompose it first.
  2. Ask clarifying questions ONE at a time -- purpose, constraints, success criteria. Prefer
     multiple-choice. One question per message; never batch an interrogation.
  3. Offer a visual just-in-time (optional) -- only when a question would genuinely be clearer shown
     than told, and as its own message. Never offer it upfront.
  4. Propose 2-3 approaches with trade-offs -- lead with the recommended option and say why. Flag any
     approach or sub-feature that falls outside the project's scope as `[SCOPE]`, citing the spec.
  5. Present the design -- in sections scaled to the complexity; ask after each section whether it
     looks right; revise until the user approves the direction.
  6. Capture open questions + scope flags -- everything still unresolved, and every `[SCOPE]` item
     surfaced, made explicit before anyone attempts a PRD.
  7. Emit the brainstorm summary -- in the `brainstorm` format from FORMAT.md. If the user approves a
     direction and wants to proceed, summarize it so it can seed the `prd` mode — but do NOT author the
     PRD here.

---

CHECKLIST completion
  [ ] The `brainstorming` skill was loaded and its technique applied (one question at a time; 2-3 approaches; design presented + approved)
  [ ] Project context grounded the conversation (config + spec read)
  [ ] 2-3 approaches proposed with trade-offs and a clear recommendation
  [ ] Anything outside scope flagged `[SCOPE]` with a spec citation
  [ ] A design presented and approved by the user (or explicitly marked PENDING)
  [ ] Open questions + scope flags captured explicitly
  [ ] NO work item created, NO build mutated, NO phase advanced
  [ ] Output matches FORMAT.md (`brainstorm` format)
