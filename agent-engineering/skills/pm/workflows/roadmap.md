---
id: roadmap
title: docs/ Roadmap Playbook
summary: Own the docs/ roadmap — epics, linked user stories across the full flow graph, the PRD, milestones; refresh the roadmap mirror.
tags: [pm/roadmap, pm/workflow]
load_when: Mode roadmap — creating or refreshing the docs/ roadmap and its machine-readable mirror.
links: [[prd]], [[roadmap-json]], [[acceptance]]
---
TASKLANG
TYPE WORKFLOW

> Related: derives from [[prd]] · refreshes [[roadmap-json]] · audited at [[acceptance]]

IDENTITY "docs/ Roadmap Playbook"
  > Own the project's roadmap as committed markdown. The PM plans in the docs/ folder: it creates and
  >   maintains the epic(s) for the milestone/feature, the user stories LINKED to their epic, the PRD,
  >   and the milestone set — then regenerates the machine-readable roadmap mirror and commits it.
  > On-demand: run it whenever the roadmap must be created or refreshed.

!!! The work-item MODEL is not defined here. Folders, filenames, frontmatter fields, link directions
    and the status lifecycle all come from `docs-project-management` —
    https://github.com/endorphin-ai/hasbrains-agent-kit/tree/main/agent-engineering/skills/docs-project-management
!!! Read the project config FIRST for the docs layout + the milestone/scenario context.
!!! A feature is never an island — enumerate user stories across the COMPLETE user-flow graph: the
    prerequisite/dependency chain (register → log in → act) AND the full entity lifecycle (create →
    read/view → edit/update → delete → list/navigate-to-find-and-see-it) × every access state. One
    story per flow PATH, not one per feature.
!!! Record the authoring agent in every file's frontmatter and sign every note.

---

GUARD
  - The project config is readable and the docs/ folder is writable.
  - A milestone/feature scope to plan is provided, or a PRD exists to derive stories from.
  ON_FAIL: FAIL("Cannot build the roadmap: missing project config, no writable docs/ folder, or no milestone/feature scope to plan.")

---

FLOW
  1. Read the config + spec + any PRD, and scan what exists -- the current epics, user stories, test
     cases, bugs and the roadmap. Extend and correct; never plan onto a blank slate.
  2. Create / maintain the epic(s) -- one epic file per milestone or feature. Set the frontmatter,
     add the signed "starting roadmap" note, transition `status:` forward.
  3. Create the user stories -- DECOMPOSE THE COMPLETE FLOW GRAPH, not one story per feature. For each
     entity enumerate stories for (a) the prerequisite/dependency chain that must hold before the
     action is reachable AND (b) the full lifecycle — create → read/view → edit/update → delete →
     list/navigate-to-find-and-see-it — across EVERY access state. One file per flow PATH, each LINKED
     to its epic, each carrying acceptance criteria derived from the success scenarios.
  4. Ensure the PRD -- the PRD file exists, carries the requirements, and is linked to the epic. If a
     PRD was authored this run, place it here.
  5. Break stories into tasks -- the concrete work beneath each story (checklist items inside the story
     file, or separate files if the project's model says so).
  6. Own the milestones -- record the milestone set in the roadmap and associate each milestone's work
     items with it.
  7. Verify the link graph -- every work item linked per the canonical graph, reciprocally, with no
     orphan files.
  8. Regenerate the roadmap mirror -- rebuild it from the CURRENT docs/ state per the schema in
     [[roadmap-json]]: every work item with its current status + key fields, the milestones marked
     past | current | next, and the summary counts. If a work item is missing, build from fallback
     evidence and mark the source accordingly.
  9. Commit the mirror -- stage it, commit with a clear message, and push if the project's flow expects it.
 10. Emit the roadmap summary -- in the `roadmap` format from FORMAT.md, closing each touched file's
     bookend note + `status:` transition.

---

CHECKLIST completion
  [ ] Epic(s) created for the milestone/feature
  [ ] User stories created and LINKED to their epic, reciprocally
  [ ] Stories cover the COMPLETE flow graph — dependency chain AND full create/view/edit/delete/navigate lifecycle × every access state (not one story per feature)
  [ ] The PRD is present and linked to the epic
  [ ] Tasks broken out; everything linked per the canonical graph (no orphans)
  [ ] Milestones recorded and their work items associated
  [ ] Frontmatter set on every file created; every note signed; `status:` bookended
  [ ] The roadmap mirror regenerated from the current docs/ state and committed
  [ ] Output matches FORMAT.md (`roadmap` format)
