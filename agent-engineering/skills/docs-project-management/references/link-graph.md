---
id: link-graph
title: The Link Graph (relative-markdown links)
summary: Every work-item relationship as a labelled, bidirectional relative-markdown link; Test Case is-tested-by User Story, Bug blocks its story, PRD↔TRD.
tags: [docs-pm/links, docs-pm/model]
load_when: When linking two work items, or checking which relationship semantic and direction to write.
links: [[work-item-taxonomy]], [[test-case-template]], [[status-lifecycle]]
---

# The Link Graph (relative-markdown links)

> Express EVERY relationship as a relative-markdown link in a "Linked Documents" / "Links" section of
> the file. There are no tracker link-type names or IDs — the SEMANTIC below is carried by a labelled
> relative link. Links are bidirectional by CONVENTION: when you link A→B, add the reciprocal B→A.

TABLE links
  COLUMNS: From, Semantic, To, How it is written
  ROW: User Story | is **part of**        | Epic       | `**Epic**: [Membership & Billing](../epics/membership-billing.md)`
  ROW: Epic       | **realized by**       | User Story | `**User Stories**: [001 …](../user_stories/001-….md)`
  ROW: Test Case  | **is tested by**      | User Story | Story file: `**is tested by**: [TC-001](../test_cases/tc-001-….md)`
  ROW: User Story | **tests** (inverse)   | Test Case  | TC file: `**Linked User Story**: [001 …](../user_stories/001-….md)`
  ROW: Bug        | **blocks**            | User Story | Bug file: `**Blocks**: [001 …](../user_stories/001-….md)`
  ROW: Test Case  | **found by**          | Bug        | `**Bugs**: [paywall-leak](../bugs/paywall-leak.md)`
  ROW: PRD        | **specified by**      | TRD        | `**TRD**: [feature-trd](../trd/feature-trd.md)`
  ROW: User Story | **derived from**      | PRD        | `**PRD**: [feature-prd](../prd/feature-prd.md)`

  !!! OVERRIDE: a Test Case ↔ User Story link is ALWAYS **"is tested by"** — NEVER "relates to" or
      "part of". The User Story `is tested by` the Test Case; the Test Case `tests` the story.
  !!! A Bug ALWAYS `blocks` the User Story it breaks.

> The items being linked live where [[work-item-taxonomy]] says. Test Cases carry the mandatory
> shape in [[test-case-template]].
