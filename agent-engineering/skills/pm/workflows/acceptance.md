---
id: acceptance
title: Final Acceptance Sign-Off Playbook
summary: The terminal gate — score every success scenario PASS/FAIL with evidence, verify e2e breadth, emit one binary LAUNCH / NO-LAUNCH verdict.
tags: [pm/acceptance, pm/workflow]
load_when: The build is delivered and needs the final pass/fail acceptance sign-off.
links: [[prd]], [[scope-guard]], [[roadmap-json]]
---
TASKLANG
TYPE WORKFLOW

> Related: scores against [[prd]] · enforces [[scope-guard]] · closing step refreshes [[roadmap-json]]

IDENTITY "Final Acceptance Sign-Off Playbook"
  > The terminal gate. The PM inspects the delivered build and scores it against the project's success
  >   scenarios — PASS or FAIL each — then gives ONE binary verdict: LAUNCH or NO-LAUNCH. A single FAIL,
  >   a missing launch-blocker, or one user story without a passing end-to-end test is NO-LAUNCH.

!!! Read the project config + the spec first — they hold the success scenarios and the launch-blocking list.
!!! Verdicts are binary. No "mostly", no "partial". Each scenario PASS or FAIL; overall LAUNCH or NO-LAUNCH.
!!! The success scenarios are the launch contract — do not invent new criteria, and do not waive any.
!!! Verify against a real running build in a non-production environment, and against the delivered
    evidence (test results, QA report, review report, deploy report). A green badge is not a scenario score.

---

GUARD
  - The spec exists (the contract to score against).
  - The build has been reported as delivered, with artifacts available to inspect.
  ON_FAIL: FAIL("Cannot run acceptance: the build is not delivered or the spec is missing — nothing to score against.")

---

FLOW
  1. Re-read the success scenarios -- plus the build-plan gates and the edge cases. These are the exact
     pass/fail criteria; nothing else is.
  2. Gather the delivered evidence -- the upstream reports (test results, QA report, security/code
     review, deploy report) plus the PRD. Map each piece of evidence to the scenario(s) it bears on.
  3. Inspect the build -- read the routes, the request/UI layer, the data layer, the migrations, the
     integration handlers and any admin surface. Exercise the running build where a scenario is about
     behavior: a scenario passes when it was EXERCISED, not when the page returned 200.
  4. Score EVERY success scenario PASS or FAIL -- with evidence for a PASS and the missing piece named
     for a FAIL. No "partial". Work in the spec's own order so nothing is skipped.
  5. Run the launch-blocker checklist -- confirm every launch-blocking item on the project's list is
     present and working. A missing one is automatically a `[BLOCKER]`.
  6. Verify end-to-end breadth -- check the story/scenario → end-to-end traceability matrix: EVERY user
     story / reachable scenario maps 1:1 to a dedicated PASSING end-to-end test. Critical paths are a
     SUBSET — breadth is 100%. Also read the QA owner's plain-English traceability report as the
     owner-facing proof the product is verifiable by behavior. ANY uncovered story is automatically a
     `[BLOCKER]` — a hard NO-LAUNCH, never a soft gap.
  7. Compile the blocking gaps -- restate every FAIL, every missing launch-blocker and every uncovered
     story as a concrete `[BLOCKER]` the team must close before re-review.
  8. Give the verdict -- all scenarios PASS + all launch-blockers present + 100% end-to-end breadth =>
     LAUNCH. Anything else => NO-LAUNCH with the gaps named. Emit in the `acceptance` format.
  9. ORGANIZE the docs/ folder -- do not just emit a verdict: audit EVERY work item for a stale status
     (shipped work must not linger in `todo`), open a FOLLOW-UP work item for every deferred piece so
     deferred ≠ forgotten and note in each file what is NOT finished, confirm test cases reflect real
     coverage, and confirm the delivery (PR / release note) carries the full work-item map.
 10. Refresh the roadmap mirror -- regenerate it from the CURRENT docs/ state per [[roadmap-json]]:
     every work item with its status, the milestones re-marked (this milestone → past with its verdict;
     the following one → next), and the summary counts. Commit it. This is the CLOSING step.

> The verdict is MILESTONE-SCOPED: a milestone LAUNCH is not a whole-product launch. Out-of-scope
> scenarios stay deferred — not waived — and remain blocking for final acceptance.

---

CHECKLIST completion
  [ ] Every success scenario scored PASS or FAIL (no "partial"), each with evidence or a named gap
  [ ] Every launch-blocking item checked; any missing one raised as a blocker
  [ ] End-to-end breadth verified at 100% (every story = a dedicated passing test; critical paths a subset); the plain-English traceability report read; any uncovered story raised as a blocker
  [ ] Every FAIL restated as a concrete blocker
  [ ] Exactly one binary verdict (LAUNCH or NO-LAUNCH) with the score
  [ ] Stale work-item statuses corrected; follow-up items opened for every deferred piece
  [ ] The roadmap mirror regenerated from the current docs/ state and committed
  [ ] Output matches FORMAT.md (`acceptance` format)
