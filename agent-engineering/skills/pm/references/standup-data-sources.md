---
id: standup-data-sources
title: Standup — parts, data sources, and recency reconciliation
summary: The three standup parts, the priority-ordered data sources, and the most-recent-wins rule for test/CI status numbers.
tags: [pm/standup, pm/state]
aliases: [standup sources, recency reconciliation, done next blockers]
load_when: Producing a standup, or deciding which test/CI status is current across CI comments, git, evidence snapshots, and docs/.
links: [[standup]], [[roadmap-json]]
---

# Standup — parts, data sources, recency

> An ON-DEMAND read the user triggers at any time. It does not consume or advance a build.
> The workflow lives in [[standup]]; the cached source it reads first is [[roadmap-json]].

!!! EVIDENCE-BASED. Every item traces to a source — never narrate status from memory or assumption.
!!! READ-ONLY. It reads state; it does not mutate work items or advance any phase. The only write it may
    perform is posting the standup itself as a signed note, and only when explicitly asked.
!!! RECENCY-RECONCILE the test/CI status — MOST-RECENT-WINS. Compare candidate sources by the
    provenance triplet timestamp · environment · commit, and report the newest. Never report an older
    evidence snapshot as current when a newer CI comment / commit / docs update supersedes it. Surface
    the environment and commit with any number, and FLAG conflicts when sources disagree. This is an
    ADDITION to mirror-first, scoped to test/CI NUMBERS — it does not undo reading the roadmap mirror
    first for work-item and milestone status.

### The three parts

TABLE standup_parts
  COLUMNS: Section, What it answers, Pulls from
  ROW: Done / Last | What was completed most recently — the last finished phase/milestone/items. | The roadmap mirror (past milestones + done items) FIRST, then recent evidence logs, build state, recent commits, accepted milestones in the roadmap doc
  ROW: Next / Plan | What is planned or in progress next — the upcoming milestone, in-progress items, the next build phase. | The roadmap mirror (current/next milestones + in-progress items) FIRST, then the next milestone/sprint doc
  ROW: Blockers    | Anything blocked or awaiting a decision. | Failed gates, deploy blocks (an unset credential, an unauthenticated integration), pending human approvals

### Data sources — priority order

KNOWLEDGE
  - 1. **The roadmap mirror** (`docs/roadmap.json`) — PRIMARY. Every work item's current status plus the
       past/current/next milestone plan. Read it FIRST so a standup does not re-scan every file. See
       [[roadmap-json]].
  - 2. **Recent run evidence** (the project's git-ignored evidence folder) — what the last runs recorded.
  - 3. **The roadmap / milestone docs** — which milestone is accepted, which is next.
  - 4. **Build state + git history** — the concrete record of what actually shipped.
  - 5. **The live work-item files** — the FALLBACK, scanned only when the mirror is stale (its
       `generated_at` predates the last accepted milestone, or the user asks for the live state). This is
       the expensive path the mirror exists to avoid.
  - **Recency reconciliation (test/CI numbers only):** the current status is resolved MOST-RECENT-WINS
    across its candidate sources — a CI or PR comment, git (latest commit + time), a stored evidence
    snapshot, and the docs/ files — each compared by timestamp · environment · commit. Report the
    newest; carry the environment and commit with the number; flag conflicts explicitly, e.g. *"the
    stored snapshot shows 8/11 @ sha abc (preview, 2d ago) but the latest CI comment shows 11/11 @ sha
    def (preview, today) — reporting the newer."*
  - Each item links its work-item file. End with the signature line the project uses.
  - If neither the mirror nor the work-item files are available, fall back to the roadmap docs, the
    evidence logs and git — and SAY SO in the summary.
