TASKLANG
TYPE WORKFLOW

IDENTITY "MODE personas — research into 2-4 design-ready characters"
  > Someone asked to define the users, build personas, or turn research into user profiles.
  > Output is 2-4 personas that each make design decisions EASIER — plus honest provenance.
  > Knowledge: `references/persona-craft.md`.

!!! A persona built without research is an ASSUMPTION DOCUMENT, not a persona. Say so, label it `[PROTO]` / `proto-persona (unvalidated)`, and name the validation step. Never launder an assumption as a finding.
!!! THE RELEVANCE TEST governs every field: "would this change a design decision?" No → cut it. Favorite coffee order is noise; preferred device and time-of-day is signal.
!!! 2-4 personas. More dilutes focus; if more are requested, deliver the tradeoff explanation with them.

---

## Steps

1. **Establish the research foundation.** Ask what evidence exists and read it:
   interview notes/transcripts · survey results · field-study observations · analytics segments ·
   existing segments/market research. In THIS repo also mine: `docs/ux/research/findings/`,
   prior `docs/ux/personas/`, `{config.acceptance_scenarios}` (the journeys the product must serve),
   support/contact volume, and behavioral analytics.
   - Evidence exists → grounded personas.
   - No evidence → say it plainly, offer to run `MODE research` for a lightweight plan, and if the user
     still wants profiles now, proceed with **clearly labelled proto-personas**.

2. **Identify user clusters** — group by shared behaviors/usage patterns, goals/motivations,
   frustrations/pain points, and context of use (when, where, how often, what device). Merge clusters
   that are too similar; drop clusters peripheral to the product. Land on 2-4.

3. **Cross-check against the product's access states** (`{config.frontend_runtime}`) — e.g. anonymous ·
   registered · paying · admin. A persona set that cannot explain who converts to the paid/entitled
   state and who stays on the free one is not doing its job. Admin/operator personas count whenever the
   product has admin surfaces.

4. **Build each persona** with the required core (name · photo description · age/location/occupation ·
   tag line · 2-3 goals · 2-3 frustrations · behaviors · context of use · a direct-voice quote) and
   only design-relevant optionals (experience level, tech comfort, key tasks, decision style).
   Every field runs the relevance test. Grounded traits cite their evidence.

5. **Add a Provenance line** per persona: the research it came from (study, sample size, date), or
   `proto-persona (unvalidated)` + the validation step needed. A persona with neither is a format
   violation (`FORMAT.md`).

6. **Differentiate** — read the set side by side. If two personas are slight variations of each other,
   merge them. Distinct characters or fewer characters.

7. **Write the files** — one persona per file, `docs/ux/personas/NN-<name>.md`, plus the index row in
   `docs/ux/personas/personas.md` (name · segment · primary goal · grounded/proto · doc link).
   Frontmatter: `status:` (transitioned at both ends), the authoring agent, dates. `## Linked
   Documents`: the epic / spec / user stories this persona serves, and back-links from those files
   where they exist.

8. **Run the quality checklist** (`references/persona-craft.md`) before delivering, then bookend the
   work report + the `status:` transitions, record the outputs where the run hands off (paths, never
   blobs), and name the next step + owner — usually the design owner (design the flow for persona X) or
   the QA owner (use persona traits as e2e/recruiting screening criteria).

---

## Using the personas after delivery (say which applies)

LIST downstream_uses
  - **Expert review** — walk a task flow as each persona to surface issues (feeds `MODE heuristics`).
  - **Test recruiting / e2e fixtures** — persona traits become screening criteria and seed-account shapes.
  - **Stakeholder vocabulary** — "would Rosa actually do this?" as a scope check with the product owner.
  - **Analytics segmentation** — map real segments onto personas to VALIDATE a proto-persona.
  - **Storyboards** — one persona per storyboard (`MODE storyboard`).

---

## Anti-patterns

RULES never
  - Demographics dressed up as a persona (age + job title + stock photo, no goals or behaviors).
  - More than 4 personas without an explicit tradeoff note.
  - Witty tag lines that carry no design information.
  - Personas that only describe the happy-path buyer — secondary personas are the real edge cases.
  - Treating personas as a one-off deliverable — revisit them when new research lands; retire stale ones.
  - Designing exclusively for the primary persona and calling the set covered.
