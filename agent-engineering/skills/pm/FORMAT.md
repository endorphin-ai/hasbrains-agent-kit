TASKLANG
TYPE FORMAT

> Output format spec for the `pm` skill. Five modes, five formats, plus one persistent artifact.
> Whatever consumes this output parses it — match the schema exactly.
> Mode `prd` → PRD format · `roadmap` → roadmap format · `brainstorm` → brainstorm format ·
> `acceptance` → sign-off format · `standup` → standup format.
> Project-specific facts (the success-scenario list, the out-of-scope list, the launch-blockers) come
> from the project's config + spec — never from this file.

---

## MODE: prd — PRD output format

SECTION summary
  FORMAT: prose
  REQUIRED: true
  > 1-3 sentences: the product in scope, the business model the spec declares, and that EVERY success
  > scenario is mapped to a gate.

SECTION objectives
  FORMAT: list
  REQUIRED: true
  > The product objectives, taken from the spec's objectives section — what this product is FOR.

SECTION scope_in
  FORMAT: list
  REQUIRED: true
  > What this version builds. State the business/monetization model explicitly, in the spec's own terms.

SECTION scope_out
  FORMAT: table
  REQUIRED: true
  COLUMNS: Out-of-scope item, Rule
  > The FULL out-of-scope list from the spec. Every row is a "no" the PRD commits to.
  EXAMPLE
    ROW: Native mobile apps | Responsive web only — no native clients at v1.
    ROW: Third-party sign-in | Email + password only at v1.

SECTION acceptance_criteria
  FORMAT: table
  REQUIRED: true
  COLUMNS: #, Scenario, Testable gate, Build phase
  > The CORE of the PRD. Map EACH success scenario to a testable gate and the phase that delivers it.
  > Gates are copied 1:1 from the spec — never softened into something un-checkable. Verify every
  > scenario has a row, and that the gates cover the complete flow graph (dependency chain + full
  > entity lifecycle × every access state), not just each feature's happy path.
  EXAMPLE
    ROW: 1 | Registration & confirmation | Register → confirm email → authenticated account exists with no active subscription | Phase 1
    ROW: 4 | Purchase unlocks access | Checkout → provider event received → entitlement unlocks all paid content within one background-job retry window | Phase 4

SECTION launch_blockers
  FORMAT: table
  REQUIRED: true
  COLUMNS: Item, Requirement, Launch-blocking
  > The project's launch-blocking compliance/priority list, each marked launch-blocking and tied to the
  > phase and scenario that delivers it. Never deferred in the PRD.
  EXAMPLE
    ROW: Tax collection | Enable tax calculation + collection for the applicable regions | yes

SECTION build_plan
  FORMAT: table
  REQUIRED: true
  COLUMNS: Phase, Name, Deliverables, Gates
  > The spec's sequential build phases, one row each, with the gates that must pass before the next
  > phase begins. Attribute the spec's edge cases to the phase that handles them.

SECTION quality_checklist
  FORMAT: checklist
  REQUIRED: true
  EXAMPLE
    [x] Every success scenario mapped to a testable gate and a build phase
    [x] Full out-of-scope list reproduced as commitments
    [x] Every launch-blocking item marked launch-blocking
    [ ] Edge cases attributed to the phase that handles them
    [ ] Business model stated explicitly

SECTION issues
  FORMAT: list
  REQUIRED: false
  > Only if the spec has gaps or contradictions. Tag per VOICE.md.
  EXAMPLE
    - [SCOPE] Request for per-item sales conflicts with the declared business model. Rejected — the spec changes first.
    - [GAP] The spec does not say what an expired link should show. Needs a ruling before the gate can score it.

---

## MODE: roadmap — roadmap output format

> The PM owns the docs/ roadmap and reports what it created or maintained. Files, folders, link
> directions and frontmatter follow `docs-project-management`. The roadmap mirror is regenerated and
> committed as part of this mode (artifact below).

SECTION summary
  FORMAT: prose
  REQUIRED: true
  > 1-2 sentences: the milestone/feature planned and the headline (e.g. "M2 epic + 9 user stories +
  > the PRD created; M2 milestone recorded; roadmap mirror refreshed").

SECTION roadmap_items
  FORMAT: table
  REQUIRED: true
  COLUMNS: File, Type, Title, Status, Parent / Link
  > Every work item created or updated this run, with its path, type, frontmatter status and its
  > parent/link per the link graph.
  EXAMPLE
    ROW: docs/epics/m2-content.md | Epic | M2 Content | todo | —
    ROW: docs/user_stories/012-read-gated-article.md | User Story | Read a gated article | todo | part of ../epics/m2-content.md

SECTION milestones
  FORMAT: list
  REQUIRED: true
  > The milestone(s) created or updated and the work items associated with each. Say "None" when clear.

SECTION handoff
  FORMAT: note
  REQUIRED: false
  > If a PRD was (re)authored, note the hand-off to the technical-design owner (which file, where the
  > note was posted).

SECTION quality_checklist
  FORMAT: checklist
  REQUIRED: true
  EXAMPLE
    [x] Epic(s) created; user stories linked to their epic; the PRD present and linked
    [x] Stories cover the complete flow graph, not one per feature
    [x] Milestones recorded and their work items associated
    [x] Roadmap mirror regenerated and committed

---

## MODE: brainstorm — brainstorm output format

> The dialogue happens turn by turn; THIS is the structured summary returned at the end — a scoped
> idea set the user can act on (e.g. seed the `prd` mode). Read/think-only: creates no work items.

SECTION summary
  FORMAT: prose
  REQUIRED: true
  > 1-3 sentences: the idea/problem explored and the headline outcome (the approved direction, or that
  > it is still open).

SECTION idea
  FORMAT: prose
  REQUIRED: true
  > The idea restated in product terms, with the purpose, constraints and success criteria surfaced
  > during the session.

SECTION options
  FORMAT: table
  REQUIRED: true
  COLUMNS: Option, Approach, Trade-offs, Recommended?
  > The 2-3 approaches explored, each with its trade-offs; mark the recommended one.

SECTION approved_direction
  FORMAT: prose
  REQUIRED: true
  > The direction the user approved, or "PENDING — awaiting user approval". Scaled to complexity.

SECTION open_questions
  FORMAT: list
  REQUIRED: false
  > Anything still unresolved that a PRD would have to settle. Say "None" when clear.

SECTION scope_flags
  FORMAT: list
  REQUIRED: false
  > Any [SCOPE] items surfaced, each citing its spec section. A brainstorm explores freely but does not
  > waive the scope wall.

SECTION next_step
  FORMAT: prose
  REQUIRED: true
  > What to do with the result — typically "feed the approved direction into the `prd` mode". This mode
  > does not author the PRD or create work items.

SECTION quality_checklist
  FORMAT: checklist
  REQUIRED: true
  EXAMPLE
    [x] Explored one question at a time; 2-3 approaches proposed with a recommendation
    [x] Design presented and approved (or marked PENDING)
    [x] Out-of-scope ideas flagged [SCOPE] with a spec citation
    [x] No work item created, no build mutated

---

## MODE: acceptance — sign-off output format

SECTION summary
  FORMAT: prose
  REQUIRED: true
  > 1-3 sentences: how many scenarios passed out of how many, and the overall verdict.

SECTION scenario_results
  FORMAT: table
  REQUIRED: true
  COLUMNS: #, Scenario, Result, Evidence / Gap
  > Score EVERY success scenario. Result is PASS or FAIL only. Evidence cites what was verified; Gap
  > names exactly what is missing.
  EXAMPLE
    ROW: 1 | Registration & confirmation | PASS | confirm flow creates the account with no subscription — verified by the registration integration test
    ROW: 6 | Protected media | FAIL | the direct asset URL streams without a token — signed playback not enforced

SECTION blocking_gaps
  FORMAT: list
  REQUIRED: true
  > Every FAIL, every missing launch-blocker and every uncovered user story restated as a concrete
  > blocker to close before re-review. Empty ONLY when everything passes.
  EXAMPLE
    - [BLOCKER] Scenario 6: enforce the signed playback token on the stream endpoint; reject token-less requests.

SECTION launch_blocker_check
  FORMAT: checklist
  REQUIRED: true
  > Confirm each launch-blocking item is present and working. A missing one is automatically a blocker.

SECTION e2e_coverage
  FORMAT: checklist
  REQUIRED: true
  > Verify the story/scenario → end-to-end traceability matrix: EVERY user story / reachable scenario
  > has a dedicated PASSING end-to-end test. Critical paths are a SUBSET — breadth is 100%. Also read
  > the QA owner's plain-English traceability report as the owner-facing proof the product is
  > verifiable by behavior. Any uncovered story is automatically a NO-LAUNCH blocker, never a soft gap.
  EXAMPLE
    [x] Sign-up → confirm → log in (every supported method) — passing
    [x] Access gate — gated body absent for an unentitled visitor, present for an entitled one
    [ ] Account deletion — NO dedicated end-to-end test → BLOCKER

SECTION verdict
  FORMAT: prose
  REQUIRED: true
  > ONE binary verdict. All scenarios PASS + all launch-blockers present + every story end-to-end
  > covered = LAUNCH. Anything else = NO-LAUNCH.
  EXAMPLE
    >> VERDICT: NO-LAUNCH — 8/9 scenarios pass; scenario 6 (protected media) fails. Close the one blocking gap and re-submit.

SECTION quality_checklist
  FORMAT: checklist
  REQUIRED: true
  EXAMPLE
    [x] Every scenario scored PASS or FAIL (no "partial")
    [x] Every FAIL restated as a blocking gap
    [x] Every launch-blocking item checked
    [x] End-to-end breadth verified at 100%; any uncovered story raised as a blocker
    [x] Exactly one binary verdict
    [x] Stale statuses corrected; follow-up items opened for every deferred piece

---

## MODE: standup — standup output format

> A short, skimmable status read in three sections. Evidence-based: every item traces to a source and
> links its work-item file. READ-ONLY.

SECTION summary
  FORMAT: prose
  REQUIRED: true
  > 1-2 sentences: the current milestone/phase position and the headline. If the work-item files were
  > unavailable, say here that the standup is from fallback evidence, not the live docs/ state.

SECTION done_last
  FORMAT: list
  REQUIRED: true
  > What was completed most recently. Each item links its work-item file. Any test/CI status is
  > recency-reconciled and carries its provenance — timestamp · environment · commit.
  EXAMPLE
    - M1 accepted — registration, confirmation, login and reset all green. [docs/epics/m1-foundation.md]
    - e2e 11/11 green — 2026-06-24T17:40Z · env=preview · sha=def4567 (supersedes the older 8/11 @ sha=abc1234 snapshot).

SECTION next_plan
  FORMAT: list
  REQUIRED: true
  > The upcoming milestone, the in-progress work items, and the next build phase. Each links its file.

SECTION blockers
  FORMAT: list
  REQUIRED: true
  > Anything blocked or awaiting a decision — a failed gate, a deploy blocked on an unset credential, a
  > pending human approval. Each names what is awaited. Say "None" explicitly when clear.
  EXAMPLE
    - [BLOCKER] Deploy gated: the deploy credential is unset, so the release step cannot run.
    - [WAIT] Awaiting the user's approval at the design gate.

SECTION signature
  FORMAT: prose
  REQUIRED: true
  > The signature line the project uses for authored updates.
  EXAMPLE
    >> — <agent-name> v<version> (<passport-id>)

---

## ARTIFACT: the roadmap mirror (`docs/roadmap.json`)

> NOT a stdout format — a persistent JSON the PM maintains: a machine-readable mirror of the docs/
> roadmap so a status read costs one file instead of a full folder scan. Regenerated from the CURRENT
> docs/ state and committed as the CLOSING step of every `acceptance` sign-off and every `roadmap`
> pass. Schema authority: `references/roadmap-json.md` — keep the two in sync.

SECTION roadmap_json
  FORMAT: json
  REQUIRED: true   # whenever the mode refreshes it
  > Top-level keys: generated_at, generated_by, source ("docs" | "fallback-evidence"),
  > project{name,docs_root}, release{name,status,verdict},
  > milestones[]{id,name,status:past|current|next,epic,verdict,accepted_at},
  > items[]{path,type,title,status,milestone,parent,links[],ai_agent},
  > summary{milestones, items_by_status, items_by_type}. Stores values read from the docs/ files only.

---

## Report Channels

> The same result is reported on THREE channels. The docs/ folder is MANDATORY; the exact file
> locations, link directions and frontmatter come from `docs-project-management`.

TABLE channels
  COLUMNS: Channel, What goes there
  ROW: docs/    | The work items themselves (PRD, epic, user stories, milestones) + the bookended start/completion notes with the `status:` transitions + the run's work report + the refreshed roadmap mirror
  ROW: GitHub   | Usually `n/a` — the PM does not open PRs. If it comments on one, the comment references its work-item files by relative markdown link
  ROW: Terminal | One concise line: the PRD authored, or the verdict + blocking-gap count

EXAMPLE "terminal line"
  >> acceptance done — VERDICT NO-LAUNCH (8/9 pass; scenario 6 blocks).

---

Made by **HasBrains** — https://hasbrains.com/
