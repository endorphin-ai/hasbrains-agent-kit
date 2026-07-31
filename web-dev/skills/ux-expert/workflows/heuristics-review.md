TASKLANG
TYPE WORKFLOW

IDENTITY "MODE heuristics — the 10 Usability Heuristics, applied selectively"
  > Two jobs. **Critique mode**: given an existing UI (running page, screenshot, mockup, or written
  > description), name the heuristics violated or at risk. **Design-guidance mode**: given a new
  > feature or flow to design, surface only the heuristics that shape it and translate each into a
  > concrete design decision.
  > Knowledge: `references/nielsen-heuristics.md`.

!!! SKIP the heuristics that are clearly fine. A full H1-H10 recital is a failed review. Report only what reveals a real issue or decision.
!!! DRIVE IT, don't read it. When the target is a running page, open it with a real browser driver (the `agent-browser` CLI, Playwright, or a browser MCP) at `{config.dev_url}` (or the per-PR preview — never production) and CLICK every control in every reachable access state. HTTP 200 is not evidence a control works. A heuristic verdict from a static source read is `[UX-ASSUMPTION]`.
!!! Every finding names its consequence, and Priority Actions caps at 3.

---

## Critique mode — steps

1. **Establish the target and the states.** Which page/flow, and which access states is it reachable in
   (the project's states, per `{config.frontend_runtime}` — e.g. anonymous · registered · paying ·
   admin)? A critique of one state is a critique of one quarter of the surface.

2. **Drive it in a real browser** — per state: open the page, snapshot the accessibility tree,
   click every interactive control (link, button, menu open + items, form, toggle, modal), walk the
   UI-reachable CRUD, read console/uncaught errors and network 404s, and screenshot to
   `.ai_log/ux-review/<page>-<state>.png`. A control that is dead, obscured, or 404s is a
   `[UX-BLOCK]` regardless of what the heuristics say — a feature is EXERCISED, not loaded.

3. **Scan in the source's order** (`references/nielsen-heuristics.md` "Critique Mode"):
   a. obvious violations first — H1 (system status), H8 (clutter), H9 (error recovery) — these show up
      visually;
   b. then reason about the flow — H3 (control/freedom), H5 (error prevention), H6 (recognition vs recall);
   c. then context and users — H2 (real-world language), H4 (consistency/standards), H7 (flexibility),
      H10 (help);
   d. skip anything with genuinely nothing to flag.

4. **Weight by input type** — screenshot/mockup → H1, H4, H8, H6, H3. Written description → H5, H2, H3,
   H7, H10. Both → full pass across visual execution + flow logic.

5. **Check the product's structural seams** — the boundaries are where heuristics actually fail.
   Derive them from the project's access states and flows; the recurring shapes are:
   - the **access-state seam** (free preview ends → gate begins; anonymous → registered): is the state
     change explained (H1), is there a way back (H3), is the value proposition legible without the
     gated body (H8)?
   - **entitlement affordances**: gated action controls render disabled-with-reason, never absent
     (H1 + H6) — an invisible affordance makes the upgrade path undiscoverable.
   - **async/background work** (queued jobs, webhooks, uploads): does the UI say what the system is
     doing and what to expect (H1), and can the user recover if it fails (H9)?
   - **destructive/admin actions**: constrained, confirmed, reversible (H5 + H3).

6. **Write the findings** — per relevant heuristic, the `**H[N]: Name**` block with one bullet per
   distinct point, each carrying a consequence and evidence (measured value, `file:line`, or screenshot
   path). Then `## Priority Actions` — max 3, impact-ordered.

7. **Route what is not yours** — a confirmed defect becomes a `docs/bugs/` bug + RCA file that
   `blocks` its user story; a visual drift from the frozen oracle routes to
   `designer-frontend-contract`; a silent spec routes to the product owner as `[SPEC-GAP]`; a WCAG
   failure is `[A11Y-BLOCK]`.

8. **Write the review file** — `docs/ux/reviews/<YYYY-MM-DD>-<target>.md` (frontmatter + `## Linked
   Documents`), transition the touched work item's `status:` at both ends, record the outputs where
   the run hands off (paths, never blobs), post the PR comment when a PR exists, then the next step
   + owner.

---

## Design-guidance mode — steps

1. Identify the CORE user action in the flow (one sentence: who, doing what, to what end).
2. Surface only the heuristics that most directly shape that action.
3. Translate each into a specific, actionable design decision — directive: "Do X", never "consider
   whether X might…". Name the component, the state, the copy, or the value.
4. State what happens when it goes wrong (H5 + H9) and how the user gets out (H3) — these are the two
   that new flows forget.
5. Hand the decisions to the design owner as design INPUT (they own the wireframe); record them in
   `docs/ux/reviews/` so the later critique can check them.

---

## Anti-patterns

RULES never
  - Listing all ten heuristics because the framework has ten.
  - A finding without a consequence ("violates H4") or without evidence.
  - More than 3 priority actions.
  - Critiquing one access state and implying the page is covered.
  - Asserting a control works, or fails, without clicking it.
  - Redesigning the visual system under the cover of a heuristic — report and route to the designer.
