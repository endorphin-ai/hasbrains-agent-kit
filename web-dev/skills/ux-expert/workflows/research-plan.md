TASKLANG
TYPE WORKFLOW

IDENTITY "MODE research — choose the method, write the plan"
  > Someone asked "what research should we do?", "how do I learn more about our users?", or described
  > a question and wants a recommendation. Output is a RUNNABLE PLAN, not a lecture on methods.
  > Knowledge: `references/research-method-matrix.md`.

!!! The method follows the QUESTION, never the fashion. Pick from the matrix; justify against the dimension + the product phase; name what the method will NOT answer.
!!! One method is almost never enough — pair a generative qual method with a validating quant one, and say which comes first.
!!! This mode does not run studies with real participants. It plans them. If the "research" available is analytics, logs, support tickets, or session data the team already has, MINE THAT FIRST — it is free and behavioral.

---

## Steps

1. **Clarify the situation** (ask only what you cannot infer from `{config.spec_path}`,
   `{config.acceptance_scenarios}`, and the spec/user stories):
   a. What question are they trying to answer? → why/how-to-fix = qualitative; how-many = quantitative;
      what users *say* = attitudinal; what users *do* = behavioral.
   b. Product stage → Strategize (finding direction) · Design (improving a flow) · Launch & Assess
      (measuring/comparing).
   c. Do participants need to interact with the product? → natural use · scripted use ·
      limited/abstracted · no product.
   d. Constraints: timeline, budget, participant access, remote vs in-person.
   > Ask ONE question at a time when clarification is needed. Never batch an interrogation.

2. **Inventory the evidence that already exists** before proposing new research — analytics segments,
   telemetry / background-job events, support/contact-form volume, existing `docs/ux/personas/`, prior
   `docs/ux/research/findings/`, QA e2e failure patterns, and any prior review in `docs/ux/reviews/`.
   Free behavioral evidence beats a new attitudinal study. Record what you found and what it already answers.

3. **Apply the three-dimension framework** (`references/research-method-matrix.md`): place the question
   on attitudinal↔behavioral, qual↔quant, and context-of-use. Then intersect with the product phase.

4. **Shortlist 1-3 methods** from the 20-method table. For each, be able to state: the dimension fit,
   the phase fit, what it answers, its key limitation, and what it costs.

5. **Sequence them** — which runs first and why (generative before validating; qual to form the
   hypothesis, quant to size it). If only one method fits the constraints, say what is being given up.

6. **Write the plan** to `docs/ux/research/<question-slug>-plan.md` with frontmatter
   (`status: todo`, the authoring agent) and `## Linked Documents` links to the spec / epic / user
   stories the question serves. Per method use the FORMAT `research_plan` five-part shape:
   recommended method → why it fits → what you'll learn → watch out for → also consider.
   Close with: participants + screening criteria (use persona traits where personas exist),
   timeline/budget fit, and **what this plan will NOT answer**.

7. **Check the traps** before delivering (`references/research-method-matrix.md` "Common Traps"):
   single-method plan · attitudinal/behavioral confusion · qual method asked for a quantitative
   answer · survey asked to diagnose *why* · benchmarking before the product is stable.

8. **Bookend + hand off** — transition the touched work items' `status:` at both ends, update the
   run's work report, record the outputs where the run hands off (the plan PATH + the chosen methods,
   never a blob), then name the next step + its owner.

---

## Decision shortcuts

TABLE shortcuts
  COLUMNS: They said, Lead method, Why
  ROW: "Why are subscribers churning after month one?"    | Interviews (+ diary study)          | Why → qualitative; attitudinal+behavioral; Strategize
  ROW: "How many users hit the gate and stop?"             | Analytics / clickstream             | How many → quantitative behavioral; Launch & Assess
  ROW: "Does the upgrade flow work?"                       | Moderated usability test (5 users)  | Scripted use, Design phase; tells you WHY it fails
  ROW: "Which pricing page converts better?"               | A/B test (stable product only)      | Behavioral quant; Launch & Assess
  ROW: "Does our nav/IA make sense?"                       | Tree testing (+ card sorting)       | Limited/abstracted; Design phase
  ROW: "Is anyone even interested in this feature?"         | Concept testing (+ survey)          | Attitudinal, Strategize — before any build
  ROW: "We have no idea who our users are"                 | Analytics segmentation → interviews | Mine free behavioral evidence, then go deep

---

## Anti-patterns

RULES never
  - Recommending a method without naming its limitation.
  - Proposing a study when the answer already sits in analytics or support volume.
  - A 5-participant test quoted as a percentage.
  - A survey commissioned to explain *why*.
  - Benchmarking a flow that is still being redesigned.
  - Inventing users to skip the research step — that is a `[PROTO]` persona at best.
