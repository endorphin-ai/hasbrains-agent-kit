TASKLANG
TYPE WORKFLOW

IDENTITY "MODE storyboard — one persona, one scenario, one path"
  > Someone wants to show how a user experiences a flow: "sketch a user flow", "storyboard this",
  > "show how a user would use X", "present these findings visually". Output is a panel sequence with
  > an action, a context, and an EMOTION per step.
  > Knowledge: `references/storyboard-craft.md`.

!!! A storyboard is a STORYLINE, not a flowchart. One persona · one scenario · one path. A branching scenario becomes SEPARATE storyboards (the 1:1 rule) — never a decision tree with panels.
!!! One step = one panel. Never cram two actions into a frame.
!!! Ideation storyboards (no research behind them) ship LABELLED speculative `[PROTO]` — conversation starters, not prioritization evidence.
!!! Emotions FIRST when stuck. Mapping the emotional state per step tells you what each visual must convey — and which pain point to fix first.

---

## Steps

1. **Gather input** — the persona (from `docs/ux/personas/`; if none exists, run `MODE personas` or say
   the storyboard is speculative), the scenario/user story to illustrate (from `docs/user_stories/`),
   and the available data: interview notes, usability findings, analytics. No data → ideation artifact,
   labelled as such.

2. **Determine fidelity from the audience** (`references/storyboard-craft.md` table):
   internal brainstorm → low (text outline / stick figures) · usability-test debrief → medium
   (stills + verbatim quotes) · stakeholder presentation → high (polished panels). Ask if unclear.
   Default here is the **text/ASCII panel outline** — cheap to iterate, and it lives in `docs/`.

3. **Fix the basics** — one persona, one specific path. Name the scenario in one sentence that stands
   alone before anyone sees a visual ("Free-tier reader Maya hits a gated lesson mid-course").

4. **Plan the steps in plain text first** — list each step, connect with arrows to confirm the sequence,
   then label each step with an emotional marker (😊 😐 😟 😤). Do this BEFORE writing panels; it
   surfaces which moments matter.

5. **Write the panels** — per step: a visual description (what the user does, where they are, what is on
   screen, relevant body language) and ≤2 caption bullets (action + emotional/contextual note), plus the
   emotion marker. Use real verbatim quotes in speech bubbles when the source is usability data.

6. **Cover the seam the product actually has** — where the scenario crosses an access-state boundary
   (free → gated, anonymous → registered, entitled → expired), that transition gets its OWN panel. The
   emotional low usually lives exactly there, and it is the panel the team needs to see.

7. **Write the file** — `docs/ux/storyboards/<scenario-slug>.md` with frontmatter (`status:`
   transitioned at both ends, the authoring agent) and `## Linked Documents` → the persona, the user
   story, the epic, and the `docs/design/` page docs for the screens involved. Note the fidelity level
   and whether it is evidence-backed or speculative.

8. **Run the quality checklist** (`references/storyboard-craft.md`), bookend the work report + the
   `status:` transitions, record the outputs where the run hands off (paths, never blobs), and name the
   next step + owner — often the design owner (design the panel that carries the emotional low) or the
   product owner (the panel reveals a scope gap).

---

## Where a storyboard is the right artifact

TABLE fit
  COLUMNS: Situation, Use a storyboard?, Instead
  ROW: Team needs to feel a specific flow's friction                    | Yes                  | —
  ROW: Debriefing a usability test with quotes                          | Yes (medium fidelity) | —
  ROW: Prioritizing which pain point to fix first                       | Yes (emotion per step) | —
  ROW: End-to-end, cross-department, all touchpoints                    | No                    | Journey map (`references/journey-empathy-and-prioritization.md`)
  ROW: Every branch and error path of a flow                            | No                    | Flow diagram / the user story's acceptance criteria
  ROW: What the screen should LOOK like                                 | No                    | the design owner's wireframe → mockup

> Storyboards work *within* or *alongside* journey maps — never instead of them.

---

## Anti-patterns

RULES never
  - A storyboard covering two personas, or two paths, in one artifact.
  - Panels without an emotion marker (the emotion is the point).
  - Captions longer than 2 bullets, or captions that duplicate the visual description.
  - Over-investing in art before the story is validated — stick figures are fine.
  - Presenting an ideation storyboard as evidence for a prioritization decision.
