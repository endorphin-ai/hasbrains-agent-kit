---
id: conventions-recap
title: Conventions Recap (the non-negotiables) + Knowledge Strategy
summary: The single checklist of docs/-native non-negotiables, plus the knowledge-capture and update-permission strategy for this skill.
tags: [docs-pm/checklist, docs-pm/strategy, docs-pm/model]
load_when: When you want a one-glance checklist of the docs/-native rules, or the rules for updating this skill.
links: [[work-item-taxonomy]], [[link-graph]], [[status-lifecycle]], [[test-case-template]], [[session-reporting]]
---

# Conventions Recap (the non-negotiables)

CHECKLIST conventions
  [ ] Every work item is a committed markdown file in its [[work-item-taxonomy]] subfolder, kebab-named, with [[status-lifecycle]] frontmatter
  [ ] Relationships are relative-markdown links per [[link-graph]] (Test Case "is tested by" User Story; Bug "blocks" story), written reciprocally in both files
  [ ] Status bookended at BOTH ends by editing frontmatter `status:` — never left stale
  [ ] Test Cases follow the [[test-case-template]] AND carry the "is tested by" link
  [ ] Bugs are ONE Bug+RCA file ([[bug-rca-report]]): detection sections at filing, fix sections completed by the fixer in the SAME file
  [ ] Every file update + report entry signed with the passport line ([[status-lifecycle]])
  [ ] On start AND on completion: a bookended report in the SESSION folder `docs/sessions/<session>/`
      (+ its README row flipped) + a row in its per-feature log `docs/reports/feature-log/<feature-slug>.md`
      (linked from the `docs/reports/feature-log.md` lean index) — see [[session-reporting]]
  [ ] Reports link the work items touched + role-specific section (QA coverage, security findings, devops deploy)
  [ ] Session folder + agent memory kept organized with build-brain (lean map + atomized files)
  [ ] Durable content lives committed in `docs/`; `.ai_log/` holds ONLY temporary git-ignored evidence — promote anything durable that lands there
  [ ] No external-tracker mechanics — docs/-native only: every work item is a local markdown file, every relationship a relative link, every status a frontmatter edit

---

## Knowledge Strategy
- Patterns to capture: recurring item shapes, link-graph edge cases, report sections that proved useful.
- Update permission: agents may freely add/update files in `references/`; changes to the SKILL.md map
  require user approval.
