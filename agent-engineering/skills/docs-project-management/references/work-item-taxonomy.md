---
id: work-item-taxonomy
title: Work-Item Taxonomy (WHERE each item lives)
summary: The docs/ subfolder + filename pattern + owning role for every document type — Project brief, Project config, Roadmap, PRD, TRD, Epic, User Story, Bug, Test Case, Session reports, Feature log.
tags: [docs-pm/taxonomy, docs-pm/model]
load_when: When you need to know WHERE a work item lives, what to name its file, or which role owns it.
links: [[link-graph]], [[status-lifecycle]], [[conventions-recap]]
---

# Work-Item Taxonomy (WHERE each item lives)

TABLE taxonomy
  COLUMNS: Item, Location, Filename pattern, Owning role
  ROW: Project brief  | docs/project_brief.md | single file — the product spec, the SOURCE OF TRUTH  | PM / user
  ROW: Project config | docs/project_config/  | info.md — project facts agents read at runtime       | PM
  ROW: Epic           | docs/epics/           | <kebab-title>.md (e.g. membership-billing.md)        | PM
  ROW: Roadmap        | docs/ROADMAP.md (+ docs/roadmap.json cache) | single file + JSON mirror      | PM
  ROW: PRD            | docs/prd/             | <kebab-feature>-prd.md                               | PM
  ROW: TRD            | docs/trd/ (canonical home; + index.json registry, index.md) | <kebab-feature>-trd.md | Architect
  ROW: User Story     | docs/user_stories/    | NNN-<kebab-title>.md (e.g. 001-user-registration.md)| PM
  ROW: Bug            | docs/bugs/            | <kebab-summary>.md                                   | QA / security / reviewer (whoever finds it)
  ROW: Test Case      | docs/test_cases/      | tc-NNN-<kebab-behavior>.md                           | QA
  ROW: Session report | docs/sessions/<YYYY-MM-DD>-<slug>/ | README.md manifest + <phase-N>-<agent>.md per run | orchestrator creates; every agent reports
  ROW: Feature log    | docs/reports/         | feature-log.md (lean index) + feature-log/<slug>.md  | every agent appends its run-row

  RULES
    - Descriptive kebab-case filenames — NEVER opaque IDs. An external work-item ref (e.g.
      TICKET-<n>), when one exists, lives in frontmatter + the title line, not in the filename.
    - Every item is a committed markdown file with YAML frontmatter ([[status-lifecycle]]) + a body.
    - Each subfolder may carry a template_<type>.md seed; new items copy its shape.
    - TRD home = docs/trd/ (the single canonical TRD location — do NOT create a parallel
      docs/architecture/ folder). The architect MUST register every TRD it authors in
      docs/trd/index.json — a machine-readable registry (one entry per TRD: file, title, ref,
      milestone, status, related_prd) kept complete for future lookup — and refresh the human
      docs/trd/index.md row. index.json is the registry; index.md is the human index; both live
      alongside the TRD files.

> Relationships between these items are written as relative-markdown links — see [[link-graph]].
> Status is tracked in each file's frontmatter — see [[status-lifecycle]].
