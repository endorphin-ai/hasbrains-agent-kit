---
id: test-case-template
title: The Test Case Template (mandatory)
summary: The mandatory field-by-field shape every docs/test_cases/ file must follow, plus its required is-tested-by link to the User Story.
tags: [docs-pm/test-case, docs-pm/model]
load_when: When authoring or reviewing a Test Case file in docs/test_cases/.
links: [[link-graph]], [[work-item-taxonomy]], [[status-lifecycle]], [[conventions-recap]]
---

# The Test Case Template (mandatory)

> Every Test Case in docs/test_cases/ MUST carry an "is tested by" link to its User Story
> (see [[link-graph]]) AND be authored to this template. All fields required; mark `n/a` only where
> genuinely inapplicable.

TABLE test_case_template
  COLUMNS: Field, What it holds
  ROW: Test Case ID/Key      | The tc-NNN filename key; carries an external work-item ref in frontmatter if one exists
  ROW: Title                 | Concise behavior under test — e.g. `TC-042: Paid article body is absent for an unpaid user`
  ROW: Linked User Story     | Parent User Story, linked via **"is tested by"** ([[link-graph]])
  ROW: Preconditions         | State/fixtures/access-state required before the steps
  ROW: Test Steps            | NUMBERED navigate → action → expected steps
  ROW: Test Data             | Concrete inputs/fixtures/event ids used by the steps
  ROW: Expected Result       | The single pass condition for the whole case
  ROW: Priority              | High / Medium / Low
  ROW: Type                  | manual or automated
  ROW: Linked automated test | The automated test name that covers this case — unit/integration/e2e (e.g. a Playwright spec) — or n/a if manual-only

> Test Cases live in docs/test_cases/ ([[work-item-taxonomy]]) and track their own status per
> [[status-lifecycle]] (draft → ready → automated).
