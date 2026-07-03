---
id: bug-rca-report
title: The RCA Bug Report (the docs/bugs/ Bug format)
summary: The canonical, RCA-rich format for a docs/bugs/ Bug file — full metadata + Symptom/Reproduction + Fix(GitHub) + Files-touched diff + 5-Whys Root Cause Analysis. The finder (reviewer/gate) authors it at detection; the dev completes the fix sections. One file, bidirectionally linked to the story it blocks.
tags: [docs-pm/bugs, docs-pm/model, docs-pm/rca]
load_when: Authoring or completing a docs/bugs/ Bug file — the detection-time write-up, or a dev recording its fix.
links: [[work-item-taxonomy]], [[link-graph]], [[status-lifecycle]], [[conventions-recap]]
---

# The RCA Bug Report (the `docs/bugs/` Bug format)

> Every `docs/bugs/<kebab-summary>.md` Bug is ALSO an RCA report. The "ticket" and the
> root-cause write-up are ONE file that travels together — the docs/-native form of a rich
> issue+RCA record with no external tracker: the "issue key" IS the Bug ID, "view the issue"
> IS a relative link to this file, and status IS frontmatter ([[status-lifecycle]]), not a
> tracker transition.

## Who fills what (two-stage authoring — one file)

- **FINDER (the reviewer / verification gate / QA — whoever detects the bug) authors at DETECTION:**
  the header, the Metadata table (Status = `open`/`in_progress`, Has-usable-fix as known),
  **Symptom / Reproduction**, the full **Root Cause Analysis** (5 Whys + Categorization +
  Preventative Action), and the `Blocks` link to the user story (reciprocal `**Bugs**:` link added
  on the story per [[link-graph]]). Leaves the **Fix (GitHub)**, **Files touched** / diff /
  "Code after", **Confirmed root cause**, and `Resolved` / `Days to resolve` as `<placeholder>`
  for the dev.
- **DEV (whoever fixes it) completes the fix — in the SAME file:** fills **Fix (GitHub)**
  (PR URL/title/merge-commit/base/link-confidence), **Files touched** + unified diff +
  "Code after", **Confirmed root cause**, stamps `Resolved` + `Days to resolve`, and transitions
  frontmatter `status:` forward per [[status-lifecycle]] (`in_progress → fixed → verified → closed`).
  NEVER open a second report — update this one.

## Frontmatter (required)

```yaml
---
id: BUG-<NNN>                      # the Bug ID; carries an external ref in `ref:` when one exists
title: "<short title of the issue>"
type: bug
status: open                       # open → in_progress → fixed → verified → closed
severity: high                     # low | medium | high | critical  (mirrors Priority)
ref: TICKET-<n>                    # external work-item ref when one exists, else n/a
assignee: <dev-agent-or-person>    # who will fix (set by the finder at detection)
ai_agent: <finding-agent>          # the creating agent
created: 2026-06-29
updated: 2026-06-29
links:
  blocks: ../user_stories/NNN-<kebab-title>.md
---
```

## Body template (keep every section; mark `n/a` only where genuinely inapplicable)

```markdown
# <BUG-ID> — <short title of the issue>

**View in docs:** [this Bug](./<kebab-summary>.md) · **Blocks:** [<NNN> <story>](../user_stories/NNN-<kebab-title>.md)

## Metadata

| Field | Value |
|-------|-------|
| Issue key (Bug ID) | <BUG-ID> |
| Type | Bug / Task / Story |
| Priority | Low / Medium / High / Critical |
| Status | open / in_progress / fixed / verified / closed |
| Resolution | Unresolved / Done / Won't Fix |
| Has usable fix | Yes / No |
| Fix version | <x.y.z> |
| Created | <YYYY-MM-DD> |
| Resolved | <YYYY-MM-DD or — (dev fills)> |
| Days to resolve | <N or — (dev fills)> |
| Labels | <label; label> |
| Detection method | Internal (review/verification gate) / Automated monitoring / Customer |
| Feature flags | <flag name or —> |
| Error signal | Error shown / Silent failure / Performance |
| Root cause category (inferred) | Coding Error / Config Error / Design Gap / Data Issue |

## Symptom / Reproduction

1. <Precondition>
2. <Trigger step>
3. <Observed incorrect behavior>
- Optional workaround that incidentally fixes the symptom: <… or n/a>

## Fix (GitHub)   <!-- DEV fills on the fix -->

- Fix PR: <PR URL>
- PR title: <PR title>
- Merge commit: <sha>
- Base branch: <branch>
- Link confidence: <high / medium / low> (<reason>)
- Confirmed root cause: <one sentence: the fix and where it landed>

### Files touched (<N>)   <!-- DEV fills -->

- <path/to/file>

#### Unified diff

```diff
<paste the unified diff here>
```

#### Code after (fix)

```
<relevant snippet after the fix>
```

## Root Cause Analysis   <!-- FINDER authors at detection -->

### Problem Statement & Impact
- What happened? <plain description of the defect>
- What was expected? <correct behavior>
- Impact: <who was affected, severity, escalation notes>

### RCA Investigation (the 5 Whys)
- Why 1 — Immediate technical cause: <…>
- Why 2 — System / environment condition: <…>
- Why 3 — Process / procedure failure: <…>
- Why 4 — Management / systemic oversight: <…>
- Why 5 — Ultimate root cause: <…>

### Categorization
- Type: <Coding Error / Config Error / Design Gap / Data Issue>
- Pattern: <short reusable pattern name>
- Failure modes: <mode-a + mode-b>

### Preventative Action (long-term)
- <concrete change to prevent recurrence>
- <test or guardrail to add (generic, no customer-specific data)>

— <agent-name> v<version> (<passport-id>)
```

> The Bug lives where [[work-item-taxonomy]] says (`docs/bugs/`), `blocks` its story per
> [[link-graph]] (reciprocal link both ways), and walks the Bug status lifecycle in
> [[status-lifecycle]]. The finder files ONE report per bug found; the dev the bug is routed to
> fixes it AND updates this same file's fix sections + status — never a second report.
