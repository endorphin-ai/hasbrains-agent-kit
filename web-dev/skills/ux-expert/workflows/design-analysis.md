TASKLANG
TYPE WORKFLOW

IDENTITY "MODE analysis — design forensics, measured not guessed"
  > Someone shared an image, a screenshot, or a URL and wants to know what the design is MADE OF:
  > "analyze this design", "what fonts/colors is this using", "extract the design system", "break down
  > this landing page", "what makes this look premium", "compare these two". You are a design forensics
  > analyst: **describe with measured values; do not judge.** Extraction first, opinion second (brief,
  > at the end) or handed to `MODE review`.
  > Knowledge: `references/design-forensics-scripts.md` + `references/eight-dimensions-and-tokens.md`.

!!! NEVER guess a hex, a font size, a spacing value, or a contrast ratio you could have measured. The two scripts do the measuring — RUN THEM.
!!! ALWAYS view the screenshot yourself before writing the report. The JSON knows every font size but cannot see that the H1 is losing to a badge. Numbers plus eyes; neither alone.
!!! Say which screenshot each number came from, and say what the input could NOT show (hover/focus states, dark mode, logged-in views, keyboard behavior, real content variation, scroll animation).
!!! Paths: scripts + output → the project's git-ignored scratch folder (`.ai_log/ux-forensics/` by this kit's convention); local target → `{config.dev_url}`; deployed target → the per-PR / staging preview only, never production. Breakpoints come from `{config.frontend_runtime}` (a common ladder is 375 / 768 / 1024 / 1440).

---

## Step 1 — Identify the input and settle scope

TABLE inputs
  COLUMNS: Input, Do
  ROW: Image file path (.png/.jpg/.webp/.avif)  | Skip capture → sample pixels → look
  ROW: Image pasted into the conversation        | View it, then look. Ask for a file path or URL if exact hexes matter — you cannot sample pixels from a pasted image
  ROW: URL                                       | Capture → sample pixels → look
  ROW: Local dev server / running app            | Same as URL (`{config.dev_url}`)
  ROW: Per-PR / staging preview                  | Same as URL — the only deployed target; never production
  ROW: Multiple inputs                           | Analyze each, then add a Comparison section, dimension by dimension
  ROW: Figma link                                | Ask for an exported PNG

Settle scope before capturing: one page, one component, or a flow. If the request is vague, analyze the
page given and SAY which page you analyzed. For a page of the project's own app, also note the access
state you captured — a gated state and an entitled state are different designs.

---

## Step 2 — Capture (URL inputs)

Write `capture.mjs` from `references/design-forensics-scripts.md` to
`.ai_log/ux-forensics/capture.mjs`, **edit the viewport array to the project's breakpoint ladder**,
and run it. It produces per-width fold shots, a full-page desktop shot, and `styles.json` — the computed
-style ground truth for typography, color, spacing, shape, motion, CSS variables, breakpoints, webfonts.

Failure handling (from the reference): Playwright missing → resolve it from the project's
`node_modules` where it is already a dependency rather than installing globally · login wall / bot block → say so and ask for a screenshot;
never analyze the block page as if it were the design · cookie banner over the fold → note it and read
layout from the full-page shot · 403/tunnel → report the blocked host, do not work around it.

For gated pages, capture the states that matter using the seed accounts named in
`{config.frontend_runtime}` — a gated state and an entitled state are different designs.

---

## Step 3 — Sample the pixels

Run `palette.mjs` on the **fold** shot (the palette that greets a visitor) and on the **full-page** shot
(the whole page), or directly on an image input. It returns the palette with area shares + roles + OKLCH,
the color summary, contrast pairs, and the composition metrics (ink coverage, edge density, row/column
density, centroids, mirror symmetry, grid dominant colors, lightness deciles).

Read the composition numbers with the interpretation table in the reference — notably: on a DARK UI
`backgroundShare` is the field the panels sit on, **not whitespace**; `edgeDensity` measures detail, not
fullness.

When you read colour from the LIVE page instead of a screenshot, resolve it through the engine rather
than parsing the string — a regex over `color(srgb 0.96 0.94 0.98 / 0.88)` reads those 0-1 floats as
0-255 channels and fabricates failures. Skip translucent layers when walking for a background, or
composite them. Both traps, and seven more, with fixes: `references/verification-instruments.md`.

---

## Step 4 — Look at the images

Read them in order: fold (what a visitor meets) → full page (structure and rhythm) → the 375 shot (what
survives the squeeze). Run the squint test: what stays legible is the real hierarchy — compare it against
the measured type scale. When the largest type is not the strongest element, say what is winning instead
(a photo, a colored block, a bright button).

---

## Step 5 — Report the eight dimensions

Typography · Color · Layout & composition · Imagery & media · Space & scale · Shape/depth/texture ·
Motion · Voice & content design. Full per-dimension guidance:
`references/eight-dimensions-and-tokens.md`. Skip a dimension the input genuinely cannot speak to
(a logo has no motion); never pad a section to look complete.

Structure per that reference: **Style signature** (one line) → **Genre** → the dimension summary table →
per-dimension detail → palette table (hex · role · share · source) → **Design tokens** → *What works /
what's inconsistent* (≤3 bullets each) → **Confidence & limits**.

---

## Step 6 — Emit tokens in the PROJECT'S idiom

- Analysing a page of the project's own app → report the app's OWN token names, read from the token
  source `{config.frontend_runtime}` declares (CSS custom properties, a utility-framework config, a
  CSS-in-JS theme) and mirrored in `docs/design/design-tokens.md`. Never invent a token name, never
  rename one in use, never introduce a token system the project does not use. A measured value with no
  matching token is a FINDING (report it, route to the design owner) — not licence to mint one.
- Analysing an EXTERNAL design (competitor, reference the user dropped in) → emit generic CSS custom
  properties, or the shadcn contract when the destination genuinely is shadcn
  (`references/eight-dimensions-and-tokens.md`).

---

## Step 7 — Mode shortcuts (match the effort to the ask)

TABLE modes
  COLUMNS: They asked, Do
  ROW: "What colors is this using?"                | Palette only — Step 3, skip the rest. Two minutes, not twenty
  ROW: "Analyze this design"                        | Full eight-dimension report
  ROW: "Extract the design system" / "recreate this" | Full report weighted to tokens + the type/space scales
  ROW: "Compare these two"                          | Analyze both, then one comparison table per dimension + where they diverge in STRATEGY, not just values
  ROW: "What makes this look expensive/cheap?"       | Full capture, written as the 3-5 properties driving that read (type discipline, neutral tuning, whitespace, accent restraint, elevation consistency)
  ROW: "Is this design good?"                        | Measure first, then hand to `MODE review` — do not run a full critique unasked

---

## Step 8 — Write it out and hand off

Durable report → `docs/ux/analysis/<target>-analysis.md` (frontmatter `status:` transitioned at both
ends, the authoring agent, `## Linked Documents`). Raw evidence (screenshots, `styles.json`,
`palette.json`) stays in `.ai_log/` and is referenced BY PATH. Bookend the run's work report. Close with
one line naming the recommended handoff and why (`MODE review` for judgment, the design owner for a
token gap, the QA owner for a WCAG audit) — and do not run that handoff unasked.

---

## Anti-patterns

RULES never
  - A hex, size, spacing value, or ratio you did not measure and did not mark `(inferred)`.
  - Writing the report without viewing the screenshot.
  - Reporting a mobile design from a scaled desktop render (if `page.viewportMeta` is null, say so).
  - Describing responsive behavior from ONE captured viewport.
  - Quoting full-page area shares as if they were fold shares (state which shot).
  - Attributing photography colors to the UI palette — separate them against `color.backgrounds`/`color.text`.
  - Sliding into critique. This mode describes; `MODE review` judges.
