---
id: status-lifecycle
title: Status Lifecycle + the Bookend Rule (docs/-native)
summary: The frontmatter status lifecycle, the bookend rule (transition forward before + after work), required frontmatter fields, and the passport signature.
tags: [docs-pm/status, docs-pm/frontmatter, docs-pm/model]
load_when: When starting or finishing work on a work item, setting its status, or filling required frontmatter fields.
links: [[work-item-taxonomy]], [[link-graph]], [[session-reporting]], [[conventions-recap]]
---

# Status Lifecycle + the Bookend Rule (docs/-native)

> Status lives in the file's YAML frontmatter `status:` field. There is no tracker transition —
> changing status = EDITING that field. Bookend BOTH ends of work: forward before starting, again
> when done.

LIFECYCLE status
  VALUES: backlog → ready → in_progress → in_review → qa → done   (blocked is an orthogonal flag)
  > Pick the closest value for the item type; not every item walks every step. A Bug uses
  > open → in_progress → fixed → verified → closed. A Test Case uses draft → ready → automated.

BOOKEND both-ends
  - ON START — set `status: in_progress` (forward) on the work item(s) you are about to touch, BEFORE
    doing the work; record the date in `updated:`.
  - ON COMPLETION — set `status:` to the next appropriate state for your role (e.g. `in_review`,
    `qa`, `done`), and stamp `updated:`.
  - NEVER leave the status unchanged across a phase — a file you worked that still reads its old
    status is an incomplete bookend.

REQUIRED FRONTMATTER (per item type — fill all; mark n/a only where genuinely inapplicable)
```yaml
---
title: "001 User Registration"        # human title; carry the external ref when one exists
type: user_story                       # epic | prd | trd | user_story | bug | test_case
status: in_progress                    # per the lifecycle above
ref: TICKET-15                         # external work-item ref when one exists, else n/a
assignee: <agent-or-person>            # who is currently responsible
created: 2026-06-27
updated: 2026-06-27
links:                                 # relative-markdown links per the link graph (epic / prd / trd / tests / blocks …)
  epic: ../epics/membership-billing.md
  is_tested_by: ../test_cases/tc-001-registration-flow.md
---
```

SIGNATURE (every update)
  - Sign every file update / report entry with the passport line:
    `— <agent-name> v<version> (<passport-id>)`   e.g. `— qa v2.0 (qa-agent-001)`.

> The `links:` field follows the [[link-graph]] semantics; the items themselves live per
> [[work-item-taxonomy]]. The status bookend pairs with the per-run report bookend in
> [[session-reporting]].
