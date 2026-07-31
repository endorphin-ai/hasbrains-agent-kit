---
id: prd
title: PRD Authoring Playbook
summary: Turn the spec or a user request into a build-ready PRD — objectives, scope, out-of-scope guards, testable acceptance gates, build plan.
tags: [pm/prd, pm/workflow]
load_when: Any request to author or update the PRD from the spec, or at the start of a build.
links: [[roadmap]], [[scope-guard]], [[acceptance]], [[brainstorm]]
---
TASKLANG
TYPE WORKFLOW

> Related: [[roadmap]] · [[scope-guard]] · [[acceptance]] · seeded by [[brainstorm]]

IDENTITY "PRD Authoring Playbook"
  > Turn the project's spec (OR a user request) into a build-ready PRD. Universal — the project facts
  >   (success scenarios, out-of-scope list, launch-blockers, build phases, business model) come from
  >   the project's config + spec; read them first.
  > Use this at the START of a build, or whenever the requirements must be (re)derived. The PM does
  >   this before any code exists: it converts the spec into objectives, scope guards, an
  >   acceptance-criteria table mapping every success scenario to a testable gate, the launch-blockers,
  >   and the build plan.

!!! Read the project config FIRST for the facts; the spec is the source of truth and wins over everything else.
!!! Copy gates 1:1 — never paraphrase a gate into something un-checkable.
!!! A feature is never an island — the functional requirements and acceptance gates must cover the
    COMPLETE user-flow graph: the prerequisite/dependency chain (register → log in → act) AND the full
    entity lifecycle (create → read/view → edit/update → delete → list/navigate-to-find) × every access
    state. Every reachable flow gets a gate, not just each feature's happy path.
!!! State the business/monetization model explicitly, in the spec's own terms.
!!! File locations, frontmatter and link directions come from `docs-project-management` — do not invent them.

---

GUARD
  - The spec exists and is readable.
  - It contains the success scenarios, the out-of-scope list, and the build plan (or the config points at them).
  ON_FAIL: FAIL("Cannot author the PRD: the spec is missing or incomplete — need the success scenarios, the out-of-scope list, and the build plan.")

---

FLOW
  1. Read the spec end to end -- plus the project config. Pull: objectives, the success scenarios, the
     constraints, the launch-blocking items, the edge cases, the out-of-scope list, the business model,
     and the build phases + their gates.
  2. Write the objectives + scope-in -- summarize what the product is for and what this version builds.
     State the business model explicitly, in the spec's own terms.
  3. Write the out-of-scope table -- reproduce the FULL out-of-scope list as a table of "no" rulings.
     This is the wall the PRD commits to.
  4. Build the acceptance-criteria table -- map EACH success scenario to a testable gate (copied 1:1
     from the spec) and the build phase that delivers it. This is the core deliverable. Verify every
     scenario has a row, and that the gates span the complete flow graph — not one gate per feature.
  5. List the launch-blockers -- every item on the project's launch-blocking list, each marked
     launch-blocking and tied to its phase and scenario. Never deferred.
  6. Write the build plan -- one row per phase, with deliverables and the gates that must pass before
     the next phase begins. Attribute each edge case to the phase that handles it.
  7. Run the scope-guard pass -- for every feature in the draft, confirm it sits inside the project's
     defined scope; cut or flag `[SCOPE]` anything outside it (the out-of-scope list AND ad-hoc asks
     beyond the spec). Confirm no orphan features: every feature traces to a phase AND a scenario.
  8. Emit the PRD -- in the `prd` format from FORMAT.md.
  9. Write the work items IN ORDER -- per `docs-project-management`: create the epic → create the PRD
     file and link it to the epic → create the user story files and link each to the epic → then the
     bookend note + the `status:` transitions at both ends. Order is mandatory; links are reciprocal.
 10. Hand off LAST -- only once the files exist, are linked and are bookended: hand the PRD to the
     technical-design owner and record the hand-off note in the PRD body.

---

CHECKLIST completion
  [ ] Every success scenario appears in the acceptance-criteria table with a testable gate and a build phase
  [ ] The full out-of-scope list is reproduced as commitments
  [ ] The business model is stated explicitly
  [ ] Every launch-blocking item is marked launch-blocking
  [ ] All build phases present with per-phase gates; edge cases attributed to a phase
  [ ] Gates cover the complete flow graph (dependency chain + full lifecycle × every access state), not one per feature
  [ ] No feature outside scope; no orphan features
  [ ] Work items created IN ORDER, linked reciprocally, with frontmatter + `status:` bookended at both ends
  [ ] Hand-off is the FINAL step, done only after the files exist + are linked + bookended
  [ ] Output matches FORMAT.md (`prd` format)
