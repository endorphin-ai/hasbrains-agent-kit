---
id: standup
title: On-Demand Standup Playbook
summary: Produce a concise evidence-based Done/Next/Blockers standup — roadmap mirror first, then evidence logs, roadmap docs, build state, git; read-only.
tags: [pm/standup, pm/workflow]
load_when: Mode standup / "give me a standup" / "where are we" — an on-demand status read at any time.
links: [[standup-data-sources]], [[roadmap-json]]
---
TASKLANG
TYPE WORKFLOW

> Related: sources + recency rules in [[standup-data-sources]] · reads [[roadmap-json]] first

IDENTITY "On-Demand Standup Playbook"
  > A concise, evidence-based classic standup, produced any time the user asks. It reads state and
  >   reports; it does not consume or advance a build, and it does not mutate work items.
  > The output is three parts: Done/Last · Next/Plan · Blockers — each item linking its work-item file.

!!! EVIDENCE-BASED. Every Done/Next/Blocker line traces to a source — never narrate status from memory.
!!! READ-ONLY. Do NOT mutate work items or advance any phase. The ONLY write allowed is posting the
    standup itself as a signed note, and ONLY when the user explicitly asks.
!!! READ THE ROADMAP MIRROR FIRST — it is the cheap machine-readable snapshot of every work item's
    status plus the past/current/next milestones. A full docs/ folder scan is the FALLBACK, used only
    when the mirror is MISSING or STALE. This is the token-saving rule: do not re-scan every file on
    every standup when the mirror is fresh.
!!! RECENCY-RECONCILE every test/CI status — MOST-RECENT-WINS. A test status has several candidate
    sources: a CI/PR comment, git (latest commit + time), a stored evidence snapshot, and the docs/
    files. Compare them by the provenance triplet — timestamp · environment · commit — and report the
    NEWEST. Never report an older snapshot as current when a newer source supersedes it. Carry the
    environment and commit with every number, and FLAG conflicts when sources disagree. This is an
    ADDITION to mirror-first; it applies to test/CI NUMBERS only, not to work-item status.

---

GUARD
  - At least one evidence source exists: the roadmap mirror, the docs/ work items, the roadmap/milestone docs, an evidence log, or build state + git.
  ON_FAIL: FAIL("Cannot produce a standup: no evidence source available.")

---

FLOW
  1. Read the roadmap mirror + decide freshness -- if it exists and is FRESH (generated at or after the
     most recently accepted milestone, and the user did not ask for a live scan), it is the PRIMARY
     source: do NOT re-scan the work-item files. Otherwise plan a live scan in step 2.
  2. Gather evidence in priority order -- (a) the roadmap mirror; (b) the recent evidence logs from the
     latest runs; (c) the roadmap / milestone docs; (d) build state + recent git commits; (e) the live
     work-item files, ONLY when the mirror is stale. If the work items are absent entirely, note in the
     summary that the standup is from fallback evidence, not the live docs/ state.
  3. Recency-reconcile the test/CI status -- before composing, resolve the CURRENT status across its
     candidate sources by timestamp · environment · commit, most-recent-wins. Carry the winner's
     environment and commit into the standup; if sources disagree, report the newer AND flag the
     conflict.
  4. Compose Done / Last -- what was completed most recently: the last finished phase/milestone and the
     done work items, each linking its file.
  5. Compose Next / Plan -- the upcoming milestone, the in-progress items, and the next build phase,
     each linking its file.
  6. Compose Blockers -- anything blocked or awaiting a decision: a failed gate, a deploy blocked on an
     unset credential or an unauthenticated integration, a pending human approval. Each names what is
     awaited. If there are none, say "None" explicitly.
  7. Emit the standup -- in the `standup` format from FORMAT.md, ending with the signature line. Every
     reported test number carries its timestamp, environment and commit.
  8. (OPTIONAL — only if explicitly asked) Post it -- record the three-part standup as a signed note in
     the active epic/milestone file. This is the ONLY write this mode performs.

---

CHECKLIST completion
  [ ] The roadmap mirror was read FIRST; the work-item files scanned only when it was missing/stale; fallback noted in the summary if neither was available
  [ ] Evidence gathered in priority order
  [ ] Test/CI status recency-reconciled (most-recent-wins); no stale snapshot reported as current; every number carries timestamp · environment · commit; conflicts flagged
  [ ] All three sections present: Done/Last, Next/Plan, Blockers (Blockers says "None" when empty)
  [ ] Each item links its work-item file where known; the output is short and skimmable
  [ ] No work item mutated and no phase advanced
  [ ] Ends with the signature line
  [ ] Output matches FORMAT.md (`standup` format)
