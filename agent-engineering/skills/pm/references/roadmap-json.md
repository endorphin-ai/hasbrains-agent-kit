---
id: roadmap-json
title: The Roadmap Mirror — docs/roadmap.json (PM-owned)
summary: The machine-readable mirror of the docs/ roadmap — what it holds, the concrete schema, the refresh moment, and the staleness rule.
tags: [pm/roadmap, pm/state]
aliases: [roadmap.json, roadmap mirror, roadmap state]
load_when: Reading or rebuilding the roadmap mirror, or deciding whether the cached snapshot is stale.
links: [[standup]], [[standup-data-sources]], [[roadmap]], [[acceptance]]
---

# The Roadmap Mirror — `docs/roadmap.json` (PM-owned)

> One persistent JSON the PM owns: a machine-readable mirror of the project's docs/ roadmap, so any
> agent needing status reads ONE file instead of re-scanning every work item on every interaction.
> It is a DURABLE, committed artifact living beside the human-readable roadmap. It is refreshed as the
> closing step of every `acceptance` sign-off, and in `roadmap` mode.
> See [[standup]] (its primary reader) and [[roadmap]] (the mode that rebuilds it).

!!! READ IT FIRST. Any agent needing roadmap/work-item status — a standup above all — reads this file
    before scanning the docs/ folder. A live scan is the FALLBACK, only when the file is missing or STALE.
!!! REFRESH AT THE GATE. The PM regenerates it from the current docs/ state and COMMITS it as the
    CLOSING step of every acceptance sign-off. That is the one defined refresh moment (plus `roadmap` mode).
!!! It MIRRORS, it does not decide. Every value is read from the docs/ files — statuses, paths, links,
    the milestone plan. The markdown is the source of truth; this file is a cache of it.

### What it holds

KNOWLEDGE
  - **Every work item** — epic, user story, PRD, TRD, test case, bug — with its current frontmatter
    status and key fields (path, type, title, status, milestone, parent, links, authoring agent).
  - **Past, current and next** — `milestones[]` marks each milestone `past` (accepted), `current` (in
    flight) or `next` (upcoming), so the file shows BOTH history and the forward plan.
  - **Summary counts** — items by status and by type, plus milestone counts, for a quick skim.

### Schema (concrete)

```json
{
  "generated_at": "2026-07-31T18:00:00Z",
  "generated_by": "<agent-name> v<version> (<passport-id>)",
  "source": "docs",
  "project": { "name": "<project>", "docs_root": "docs/" },
  "release": { "name": "M1", "status": "released", "verdict": "LAUNCH" },
  "milestones": [
    { "id": "M1", "name": "foundation", "status": "past", "epic": "docs/epics/m1-foundation.md", "verdict": "LAUNCH", "accepted_at": "2026-07-24" },
    { "id": "M2", "name": "content",    "status": "next", "epic": null, "verdict": null }
  ],
  "items": [
    { "path": "docs/epics/m1-foundation.md",            "type": "Epic",       "title": "M1 Foundation", "status": "done", "milestone": "M1", "parent": null, "links": [], "ai_agent": "pm" },
    { "path": "docs/user_stories/001-registration.md",  "type": "User Story", "title": "Register an account", "status": "done", "milestone": "M1", "parent": "docs/epics/m1-foundation.md", "links": [{ "type": "is tested by", "to": "docs/test_cases/tc-001-registration.md" }], "ai_agent": "pm" }
  ],
  "summary": {
    "milestones": { "past": 1, "current": 0, "next": 4 },
    "items_by_status": { "done": 27, "in_progress": 0, "in_qa": 0, "todo": 0 },
    "items_by_type":   { "Epic": 1, "PRD": 1, "TRD": 1, "User Story": 4, "Test Case": 11, "Bug": 0 }
  }
}
```

> `milestone.status` ∈ {past, current, next}. `item.status` is the file's frontmatter status string,
> from the project's lifecycle. `links[]` follows the `docs-project-management` link graph (user story
> `part of` its epic; test case `is tested by` its user story; bug `blocks` its story; PRD↔TRD).
> `source: "fallback-evidence"` means the snapshot was built without a full docs/ scan — say so.

### Staleness rule

KNOWLEDGE
  - Treat the mirror as STALE (and prefer a live docs/ scan) when: the file is absent; `generated_at`
    predates the most recently accepted milestone; or the user explicitly asks for the live state.
  - Otherwise the mirror is authoritative for a status read — use it, do not re-scan.
  - A stale mirror is worse than none: it reports confidently and wrongly. Regenerate at the gate, every time.
