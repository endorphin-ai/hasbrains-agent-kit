TASKLANG
TYPE FORMAT

> Output format for the `ux-expert` skill. Six modes, three report channels. Whatever consumes this
> output parses it — match it exactly. This skill produces UX understanding and judgment; it writes
> NO application source, NO wireframes, NO mockups, NO design tokens.

---

## Report Channels (all three, every run — `n/a` where genuinely inapplicable)

TABLE channels
  COLUMNS: Channel, What goes there
  ROW: docs/     | The durable artifact under `docs/ux/…` (+ frontmatter `status:` transitioned per the project's lifecycle, the authoring agent, `## Linked Documents`), the run's work report where the project keeps them, and a `docs/bugs/` bug + RCA file per confirmed defect
  ROW: GitHub    | A PR comment when a PR exists: the verdict + top issues + priority actions, each linking its `docs/ux/` artifact and any `docs/bugs/` file. Never a bare "looks good"
  ROW: Terminal  | The concise stdout report below (verdict-first), or `n/a`

---

SECTION summary
  FORMAT: prose
  REQUIRED: true
  > 1-3 sentences: which MODE ran, what was examined (page/flow/URL/research question), the one-line
  > verdict or deliverable count, and the `docs/ux/` paths written.

SECTION verdict
  FORMAT: prose
  REQUIRED: true   # for modes heuristics | review; `n/a` for research | personas | storyboard | analysis
  > EXACTLY one line, one of:
  >   `Solid` — mostly sound, only targeted refinements needed
  >   `Needs work` — clear issues that may affect usability, trust, or conversion
  >   `High risk` — likely to fail, confuse, mislead, or harm users without redesign
  EXAMPLE
    >> **Verdict:** Needs work — the paywall seam is discoverable but the upgrade CTA competes with two peers.

SECTION findings
  FORMAT: table
  REQUIRED: true   # for modes heuristics | review; `n/a` otherwise
  COLUMNS: #, Severity, Tag, Finding, Why it matters, Evidence
  > 3-5 rows, severity-ordered (highest first). `Tag` is one of the VOICE.md tags. `Why it matters`
  > names the USER, BUSINESS, or TRUST consequence — never a restatement of the finding.
  > `Evidence` is a measured value, a `file:line`, an `.ai_log/` screenshot path, or a heuristic id.
  EXAMPLE
    ROW: 1 | High | [UX-BLOCK] | Checkout step 3 requires the plan chosen on step 1, shown nowhere | User re-navigates or guesses; abandonment at the payment step | H6 · .ai_log/ux-review/checkout-3.png
    ROW: 2 | Med  | [A11Y]     | Focus ring removed on the primary CTA (`outline: none`, no replacement) | Keyboard users lose their place on the highest-value control | assets/css/app.css:412

SECTION recommended_changes
  FORMAT: list
  REQUIRED: true   # for modes heuristics | review; `n/a` otherwise
  > One concrete design action per finding, in the same order. Directive and specific — a value, a
  > component, a state. NOT "consider improving X".
  EXAMPLE
    - Persist the chosen plan as a sticky summary rail on steps 2-3 (`plan_summary` region, reuse the pricing card's compact variant).
    - Restore a 2px `var(--cta)` focus-visible ring on `.btn-primary`; keep `outline: none` only for `:focus:not(:focus-visible)`.

SECTION priority_actions
  FORMAT: list
  REQUIRED: true   # for modes heuristics | review; `n/a` otherwise
  > MAX 3, impact-ordered. This is the "if you only do three things" list. Never more than 3.

SECTION deliverables
  FORMAT: table
  REQUIRED: true
  COLUMNS: Path, Artifact, Status
  > Every file created or modified — `docs/ux/…` artifacts, the work report, `docs/bugs/` bug + RCA
  > files, and the `.ai_log/` evidence paths handed downstream.
  EXAMPLE
    ROW: docs/ux/personas/02-returning-learner.md | Persona (grounded — 9 interviews + analytics segment) | created
    ROW: docs/ux/README.md                        | UX library map (index row added)                      | modified
    ROW: .ai_log/ux-forensics/styles.json          | Measured computed-style harvest                       | evidence

SECTION research_plan
  FORMAT: list
  REQUIRED: true   # MODE research only; `n/a` otherwise
  > Per the source's recommendation shape, one block per recommended method:
  > (1) **Recommended method** + rationale · (2) **Why this fits** — which dimension(s) + product
  > phase · (3) **What you'll learn** — the question it answers · (4) **Watch out for** — the key
  > limitation · (5) **Also consider** — 1-2 complementary methods.
  > Close with participants, timeline/budget fit, and what this plan will NOT answer.

SECTION personas
  FORMAT: list
  REQUIRED: true   # MODE personas only; `n/a` otherwise
  > 2-4 personas, each in the `references/persona-craft.md` layout (name/age · occupation ·
  > location · quote · tag line · Goals · Frustrations · Behaviors · Context of use). Each carries a
  > **Provenance** line: the research it came from, or `proto-persona (unvalidated)` + the validation
  > step needed. A persona with neither is a format violation.

SECTION storyboard
  FORMAT: list
  REQUIRED: true   # MODE storyboard only; `n/a` otherwise
  > The `STORYBOARD: / Persona: / Scenario: / Panel N:` block from `references/storyboard-craft.md` —
  > one persona, one scenario, one path; per panel a visual description, ≤2 caption bullets, and an
  > emotion marker. Multi-branch scenarios ship as SEPARATE storyboards (1:1 rule).

SECTION analysis
  FORMAT: list
  REQUIRED: true   # MODE analysis only; `n/a` otherwise
  > The design-analysis report per `references/eight-dimensions-and-tokens.md`: **Style signature**
  > (one line), **Genre**, the dimension summary table, then the per-dimension detail with MEASURED
  > values, the palette table (hex · role · share · source), the paste-ready token block in the
  > PROJECT'S OWN variable idiom, `What works / what's inconsistent` (≤3 bullets each), and
  > **Confidence & limits** (measured vs inferred; what the input could not show).

SECTION a11y_risks
  FORMAT: list
  REQUIRED: false   # include when accessibility is materially in play
  > Highest-impact items only — contrast/label/focus/keyboard/semantics — each marked as visually
  > observed vs needing implementation verification. State the limit explicitly: a screenshot cannot
  > prove keyboard access, screen-reader behavior, semantic markup, or WCAG conformance.

SECTION ai_risks
  FORMAT: list
  REQUIRED: false   # include when reviewing an AI/agentic feature
  > Five labelled lines: `Scope:` · `Trust:` · `Control:` · `Data:` · `Cost:` — per
  > `references/ai-product-ux.md`.

SECTION open_questions
  FORMAT: list
  REQUIRED: false
  > ONLY where missing context materially changes the recommendation. Each question names what
  > would change if answered either way. Not a place to park curiosity.

SECTION next_step
  FORMAT: prose
  REQUIRED: true
  > ONE line: the single most useful artifact, test, or decision to make next — and who owns it
  > (the product owner for scope, the design owner for the visual system, the frontend owner for the build,
  > the QA owner for a test).

---

## Quality Checklist

LIST format_gate
  - Verdict line present for `heuristics` / `review`, and it is one of the three exact values.
  - Findings: 3-5, severity-ordered, every row has a consequence AND evidence.
  - Priority actions: ≤ 3.
  - No quantitative claim without a measured value or an explicit `(inferred)` mark.
  - Mode-specific section present; the non-applicable mode sections are `n/a`, not omitted silently.
  - All three channels addressed (docs/ · GitHub · Terminal).
  - Deliverables table lists every written file + evidence path.
  - `next_step` names an owner.
  - No wireframes, mockups, design-token edits, or application source in the output — those belong to the design and frontend owners.
