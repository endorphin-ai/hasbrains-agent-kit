TASKLANG
TYPE WORKFLOW

IDENTITY "MODE review — the compact combined lens"
  > The default entry for "review this", "is this good UX?", "thoughts on this design?", "why isn't this
  > converting?". ONE review that picks the strongest lens for the problem instead of running every
  > framework. Output: a verdict, 3-5 findings with consequences, concrete changes, ≤3 priority actions,
  > one next step.
  > Knowledge: all `references/`, led by whichever lens the first pass selects.

!!! Prefer JUDGMENT over completeness. Skip lenses that do not apply — and say which you skipped, so silence never reads as "checked and fine".
!!! Measure before you judge. If the design's actual properties (hexes, type scale, spacing, contrast) have not been measured, run `MODE analysis` first or measure inline (`references/design-forensics-scripts.md`). Numbers plus eyes; neither alone.
!!! Do not remove all friction. Keep friction that prevents irreversible, costly, or harmful mistakes — a confirmation on account deletion is a feature.
!!! Every deployed check runs on `{config.dev_url}` or the project's per-PR / staging preview — never production.

---

## Step 1 — First pass: what kind of problem is this?

Pick the LEAD lens from the request (source table, `general-design-review`):

TABLE lead_lens
  COLUMNS: Situation, Lead lens, Reference
  ROW: Existing UI / screen / product flow                        | Usability, cognitive load, conversion | nielsen-heuristics · cognitive-load-and-conversion
  ROW: Polished UI code, styling, "looks generic"                 | Visual craft                          | visual-craft-rules
  ROW: Contrast / keyboard / screen-reader / WCAG concern          | Accessibility                         | (a11y lens below)
  ROW: New product or ambiguous design challenge                  | Double Diamond, research, problem framing | journey-empathy-and-prioritization · research-method-matrix
  ROW: User segments or raw research notes                         | Personas, empathy maps, journey maps   | persona-craft · journey-empathy-and-prioritization
  ROW: Backlog / roadmap / which-feature-first                     | Prioritization                        | journey-empathy-and-prioritization
  ROW: AI feature or agentic workflow                              | AI inputs, trust, governance, wayfinding | ai-product-ux
  ROW: Users don't know how to start                               | Wayfinding, onboarding, examples      | ai-product-ux (wayfinding) · nielsen-heuristics (H6/H10)
  ROW: Users don't trust the system                                | Trust builders, disclosure, governors | ai-product-ux
  ROW: Design measured but not converting                          | Cognitive load + conversion           | cognitive-load-and-conversion

> When several apply, lead with the one closest to the user's immediate goal. Name it in the report.

---

## Step 2 — Ground the review in evidence

1. Read the intent: the spec / user story acceptance criteria (`docs/user_stories/`), the approved
   oracle (`docs/design/design-system.md`, `oracle-manifest.json`), and `{config.out_of_scope}`.
   **The spec is the oracle** — "this is wrong" means wrong against the spec or against a named
   principle with a consequence, not against personal taste.
2. Drive the running target in a real browser (the `agent-browser` CLI, Playwright, or a browser MCP):
   every access state, every control clicked, console + network read, screenshots to `.ai_log/`.
3. Measure what you will make a claim about (`references/design-forensics-scripts.md`) — contrast ratios,
   type scale, spacing ladder, accent share, composition. Mark anything you did not measure `(inferred)`.
4. **Enumerate the target's state space before claiming coverage** — not just routes/pages, but the states
   reached by query parameters or view switches, every content TYPE (types diverge; do not sample one),
   the not-found branch, and each list's empty state. Say what you covered and what you sampled.
5. **Validate every instrument before its output counts** (`references/verification-instruments.md`) — a
   probe that has only ever returned "clean" has not been tested. Prove it can report the failure it hunts.

---

## Step 3 — Run the lenses that apply

LIST lenses
  - **Core UX** — clarity · language · control · consistency · error prevention · recognition ·
    efficiency · focus · recovery · help. Mention ONLY the ones revealing a real issue
    (`references/nielsen-heuristics.md`).
  - **Cognitive load & conversion** — clutter, mental-model mismatch, unnecessary decisions, memory
    burden, manual work; run the squint / three-second / subtraction / memory tests and report which one
    failed (`references/cognitive-load-and-conversion.md`).
  - **Visual craft** — the 12 rules, judged against THIS project's approved system (void-violet + the
    single iris→cyan CTA gradient + glow depth are ON-system; flag only off-system violations). Report
    violations with concrete replacement values. SKIP for wireframes and early concepts
    (`references/visual-craft-rules.md`).
  - **Accessibility** — a focused WCAG 2.1 A/AA pass: perceivable (contrast, size, color-only meaning,
    labels) · operable (focus visibility, target size, keyboard, no gesture-only) · understandable
    (labels, instructions, errors, predictability) · robust (accessible names, semantics, status
    announcements, modal focus). State the limit: a screenshot cannot prove keyboard access, screen-reader
    behavior, semantics, alt text, or conformance — drive it or mark it needing verification.
  - **Information integrity** — for any page showing generated or derived content: does every count,
    badge, breadcrumb, filter, label and URL claim only what the data supports? Users see a cramped
    margin and forgive it; they trust a wrong count and act on it, so these findings rank ABOVE craft
    ones and are reported in their own group (`references/honest-rendering.md`).
  - **Persuasive UX** — reduction · tunneling · tailoring · suggestion · self-monitoring · social
    visibility · reinforcement. Recommend only patterns that fit the behavior the product wants, and
    never a dark pattern (`references/cognitive-load-and-conversion.md`).
  - **Research & strategy** — if the problem is not understood, do NOT jump to UI recommendations; name
    what must be learned and the method (`references/research-method-matrix.md`, or hand to `MODE research`).
  - **AI product** — for any AI/agentic surface, start with: what is the AI acting on · what can it
    change/send/delete/spend/remember/reveal · worst case if wrong · can the user understand, steer,
    stop, undo, verify · is it disclosed as AI. Then the input/wayfinding/tuner/governor/trust/identifier
    checks and friction calibration (`references/ai-product-ux.md`).
  - **Process** — a Double Diamond check (Discover / Define / Develop / Deliver): which phase is the team
    actually in, and what is the next useful artifact
    (`references/journey-empathy-and-prioritization.md`).

---

## Step 4 — Write it

1. **Verdict** — `Solid` / `Needs work` / `High risk`, one line.
2. **Top issues** — 3-5, severity-ordered, each with its user/business/trust consequence + evidence.
3. **Recommended changes** — one concrete design action per issue, same order.
4. **Open questions** — only where missing context materially changes the recommendation.
5. **Priority actions** — max 3, impact-ordered.
6. **A11y risks** / **AI-specific risks** blocks when those lenses ran.
7. **Next step** — the single most useful artifact, test, or decision, with its owner.

Then: write `docs/ux/reviews/<YYYY-MM-DD>-<target>.md`; file a `docs/bugs/` bug + RCA file per
confirmed defect that `blocks` its story; post the PR comment when a PR exists; transition the touched
work item's `status:` at both ends and record the outputs where the run hands off (paths, never blobs).

---

## Routing table — who owns each finding

TABLE routing
  COLUMNS: Finding, Owner
  ROW: Broken/dead/obscured control, missing CRUD path          | the frontend owner (via a docs/bugs/ bug + RCA file)
  ROW: Rendered UI drifted from the frozen oracle               | the design owner (`designer-frontend-contract`) — do not re-adjudicate
  ROW: Missing design state / new visual pattern needed          | the design owner
  ROW: Entitlement leak, authorization in a template, webhook hole | the security / architecture owner (Critical → blocks)
  ROW: Missing e2e coverage for a reviewed path                  | the QA owner
  ROW: Spec silent / scope change / new requirement              | the product owner (`[SPEC-GAP]`)
  ROW: Prod-only surface (assets 404, socket reconnect loop)     | the platform owner (on the per-PR preview)

---

## Anti-patterns

RULES never
  - A checklist dump — the frameworks are scaffolding; the output is senior design judgment.
  - Judging visual choices against personal taste instead of `docs/design/` + a named consequence.
  - A verdict with no evidence, or a measurement claim that was eyeballed.
  - Trusting a sweep that came back clean without having proven the probe can fail.
  - "All pages reviewed" when only the route list was walked and the `?view=` / `?item=` / per-type
    states were never driven.
  - Reporting a fix as applied without re-running the measurement and watching the number move.
  - Recommending research when the answer is already measurable, or recommending UI changes when the
    problem is not yet understood.
  - Removing protective friction in the name of conversion.
  - More than 3 priority actions.
