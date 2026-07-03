---
id: session-reporting
title: Team Work-Reporting / Session Work Folder (docs/sessions/) + Feature Log
summary: The per-session work folder, the start/finish report bookend, build-brain organization of folder+memory, the report schema, role-specific sections, and the per-feature work-log (feature-log.md = lean index → docs/reports/feature-log/<feature-slug>.md).
tags: [docs-pm/reporting, docs-pm/sessions, docs-pm/model]
load_when: When bookending your run as a report, organizing a session folder or agent-memory, or filling the feature log.
links: [[status-lifecycle]], [[conventions-recap]], [[work-item-taxonomy]]
---

# Team Work-Reporting / SESSION WORK FOLDER (docs/sessions/) + Feature Log

> The core requirement: **the whole team reports its work in `docs/`, so anyone can see — in one
> committed, human-readable place — all work that was done**: who did what, when, with which
> evidence (PRs, coverage reports, deploy status, findings). All per-run commentary lives in a
> **per-SESSION work folder** in `docs/sessions/` — one folder per orchestrated run (a feature,
> an Epic, or part of one). Every agent bookends its work (start + finish) as a file IN that
> session folder. (`.ai_log/` is git-ignored and stays the place for raw evidence blobs; reports
> LINK to it.)

## 5a — The Session Work Folder (created by the orchestrator at session start)
LOCATION session
  - Folder: `docs/sessions/<YYYY-MM-DD>-<feature-slug>/` (committed) — e.g.
    `docs/sessions/2026-06-27-member-blog-gating/`. **The ORCHESTRATOR (or the first agent of a
    run) CREATES it when a run starts** and passes its PATH (`session_dir`) to EVERY dispatched agent.
  - Session manifest: `<session_dir>/README.md` — the build-brain "MAP" of the session: the Epic link,
    the originating request, the milestone, the phase plan, the PR(s), and a STATUS TABLE
    (phase → agent → status `todo|in_progress|done` → link to that agent's report file). The
    orchestrator seeds it; each agent flips its own row.
  - Per-agent report: `<session_dir>/<phase-N>-<agent>.md` (e.g. `phase-6-qa.md`). One file per
    agent run, bookended (below). These REPLACE any old flat `docs/reports/<date>-<agent>.md` location.
  - QA mirror: QA ALSO writes `manual-test-instructions.md` + `coverage-report.md` into the session
    folder (the content it posts as its two distinct PR comments) — the committed copy of the
    review-time commentary. The PR comments are still posted (unchanged); the docs files persist them.
  - Feature-split work-log: the team work-log is **SPLIT BY FEATURE** (build-brain map → atomized files,
    for token efficiency — never one giant flat table). `docs/reports/feature-log.md` is a **LEAN INDEX**
    — one row per feature linking to its per-feature file `docs/reports/feature-log/<feature-slug>.md`; each
    per-feature file holds that feature's per-run rows (newest at the bottom), each linking INTO a
    session-folder report. An agent appends its run-row to its feature's
    `docs/reports/feature-log/<feature-slug>.md` (creating it if absent) AND ensures the `feature-log.md`
    index has a row linking to it. (Legacy flat reports under `docs/reports/` remain as history; new
    per-run reports go in the session folder.)

RULE bookend_report (mirrors the status bookend — bookend BOTH ends, IN the session folder)
  1. ON START — when an agent BEGINS work, it CREATES `<session_dir>/<phase-N>-<agent>.md` with a
     STARTING entry (status: started, what it is about to do, the work items it will touch), flips its
     row in `<session_dir>/README.md` to in_progress, AND appends a row to its feature's per-feature log
     `docs/reports/feature-log/<feature-slug>.md` (creating it if absent) + ensures the
     `docs/reports/feature-log.md` index links that feature file.
  2. ON COMPLETION — it UPDATES the SAME report file with the completion entry (status: completed,
     what was done, evidence links), flips its README row + its `docs/reports/feature-log/<feature-slug>.md`
     row to completed.
  3. Every report links to the work items it touched (user stories / test cases / bugs / PRD / TRD)
     via relative-markdown links, and is signed with the passport line ([[status-lifecycle]]). (Relative
     links from `docs/sessions/<session>/` reach `docs/user_stories/x.md` as `../../user_stories/x.md`.)

## 5b — Organize with build-brain (folder + memory)
> EVERY agent applies the **build-brain** skill twice: (a) keep the SESSION FOLDER itself organized —
> a lean `README.md` map + atomized per-phase report files + a small nav index, never one giant dump;
> (b) keep its OWN `.claude/agent-memory/<agent>/` organized — a lean `MEMORY.md` map + atomized,
> tagged memory files + a nav map, re-anchoring/retiring stale learnings as the project evolves.

REPORT SCHEMA (per-agent report file, lives at `<session_dir>/<phase-N>-<agent>.md`)
```markdown
---
date: 2026-06-27
agent: qa
phase: 6 (qa)            # or the work-item ref, e.g. TICKET-162
session: 2026-06-27-member-blog-gating
status: completed        # started | completed
work_items:              # relative links to every item touched (../../ out of the session folder)
  - ../../user_stories/001-user-registration.md
  - ../../test_cases/tc-001-registration-flow.md
---

# 2026-06-27 · qa · phase 6 (qa)

## What
<one-paragraph summary of the work — what was built/tested/reviewed/deployed>

## Work items touched
- [001 User Registration](../../user_stories/001-user-registration.md) — status → qa
- [TC-001 Registration flow](../../test_cases/tc-001-registration-flow.md) — created

## Evidence
- PR: <link>
- .ai_log/ artifacts: `.ai_log/phase-6-qa-coverage.md`
- Screenshots / report: <raw URL or path>

## <role-specific section>   # see below

— <agent-name> v<version> (<passport-id>)
```

ROLE-SPECIFIC SECTIONS (include the one(s) for your role)
  - **QA** → a COVERAGE REPORT: baseline % → final %, gaps closed / gaps remaining, scenario→test
    traceability summary, the exact test-run commands (unit suite + e2e suite).
  - **Security** → a FINDINGS SUMMARY: counts by severity, the verdict
    (approved | changes-requested | blocked), each Critical with its file:line.
  - **DevOps** → DEPLOY / CI STATUS: build-gate result, CI job results, the deployed/preview URL,
    migration + backup/restore + rollback status.
  - **Architect** → the design summary (design mode) OR the GATE verdict + per-item evidence
    (verify mode).
  - **PM** → the PRD/roadmap summary OR the acceptance verdict LAUNCH | NO-LAUNCH with
    per-scenario PASS/FAIL OR the standup.
  - **Designer** → the design deliverables + which approval gates passed.
  - **Frontend / backend dev** → files built + dev-test result (test suite green).
  - **Test healer** → the RCA verdict + the burn result + routing.

FEATURE-LOG ROW (append to the per-feature file `docs/reports/feature-log/<feature-slug>.md`)
  Per-feature-log columns: | Date | Agent | Phase / Ref | Summary | Status | Report | Work items |
  > The work-log is SPLIT BY FEATURE (one file per feature = Epic / milestone). The `<feature-slug>`
  > MUST match the session-folder slug minus the date prefix — e.g. session
  > `docs/sessions/2026-06-27-m1-foundation-auth/` → `docs/reports/feature-log/m1-foundation-auth.md`;
  > fall back to the Epic / milestone slug if there is no session folder. Append your row to your
  > feature's file `docs/reports/feature-log/<feature-slug>.md` (create it — short frontmatter
  > `feature:`/`status:`/`span:` + an H1 + the column header — if absent) on start (status: started),
  > flip it to completed on finish; newest at the bottom.
  > Then ensure the LEAN INDEX `docs/reports/feature-log.md` carries EXACTLY ONE row for your feature,
  > with columns | Feature | Epic / Milestone | Status | Span (first → last date) | Log | linking to
  > your feature file (newest feature at the top). Add the index row only when you CREATE a new
  > per-feature log; do NOT append every work row to the index. Never rebuild one giant flat table —
  > map (the index) → atomized per-feature files.

> This report bookend pairs with the work-item status bookend in [[status-lifecycle]]; the
> non-negotiables are recapped in [[conventions-recap]].
