# pipeline-state — STATE SCHEMA + READ/WRITE protocol

The state file is **per-session and git-ignored**: **`.ai_log/session-<session-id>-<name>.json`** (one
per run; el-capitan `init`s it at session start and passes its PATH as `state_file`). This note documents
its shape and the handoff protocol. Load it only when you need the
exact field/entry layout; the lean map is `SKILL.md`.

## Top-level shape

```json
{
  "session": "2026-06-30-member-blog-gating",
  "session_dir": "docs/sessions/2026-06-30-member-blog-gating/",
  "user_request": "Gate the member blog behind an active subscription.",

  "prd_document": "docs/prd/member-blog-gating.md",
  "design_spec": "docs/design/member-blog-gating-design-spec.md",
  "backend_code": ".ai_log/phase-3-backend-ror-manifest.md",
  "view_code": ".ai_log/phase-4-frontend-ror-manifest.md",

  "phases": {
    "0-requirements": {
      "agent": "pm-ror",
      "status": "done",
      "outputs":    { "prd_document": "docs/prd/member-blog-gating.md" },
      "evidence":   [".ai_log/phase-0-pm-ror-prd.md"],
      "work_items": ["docs/epics/member-blog-gating.md", "docs/prd/member-blog-gating.md"]
    },
    "5-verification": {
      "agent": "architect-ror",
      "status": "done",
      "outputs":    { "gate": "pass", "verification_report": ".ai_log/phase-5-architect-ror-verification-report.md" },
      "evidence":   [".ai_log/phase-5-architect-verify-server.log", ".ai_log/phase-5-architect-verify-reader-1440.png"],
      "work_items": ["docs/user_stories/001-member-blog-gating.md"]
    }
  }
}
```

## Field conventions (map to the script commands)

| Kind | How | Example |
|------|-----|---------|
| **Run vars** (scalars) | `set <session> <field> <value>` | `set S prd_document docs/prd/x.md` |
| **Output field** (a value OR a docs/ / `.ai_log/` PATH) | `set` | `set S design_spec docs/design/x-design-spec.md` |
| **Evidence-path list** (`.ai_log/` artifacts, screenshots, logs) | `append <session> <field> <path>` | `append S phase-6-evidence .ai_log/phase-6-qa-ror-coverage.json` |
| **Nested `phases.<n-name>` entry** | el-capitan writes it with `jq` directly (the script's `set`/`append` operate on flat top-level keys) | see the top-level shape above |

- A **per-phase entry** (`phases.<phase-number>-<phase-name>`) holds: `agent`, `status`
  (`todo -> in_progress -> done`, mirroring the R3 lifecycle), `outputs` (each contract field ->
  its value or a docs/ / `.ai_log/` PATH), `evidence` (a list of `.ai_log/` paths), and `work_items`
  (relative-markdown links to the docs/ files touched).
- **Never store a large blob** (full code dumps, full reports) as a value — store a PATH to the
  `.ai_log/` (evidence) or `docs/` (durable) artifact, per R15.
- The output-field NAMES match the workflow YAML `context_schema` / `context_contracts` keys
  (`prd_document`, `design_spec`, `context_design`, `backend_code`, `view_code`, `audit_findings`,
  `verification_report`, `test_results`, `review_report`, `deploy_report`, `acceptance_signoff`, …),
  so a consumer resolves a contract field by reading that key from the state.

## READ/WRITE protocol

**el-capitan (orchestrator)**
1. `init <session>` at session start (also clears stale `.ai_log/`); `set` `session_dir` +
   `user_request`; pass `state_file = .ai_log/session-<session-id>-<name>.json` (the path `init` created)
   to every dispatched agent.
2. After each phase: `get` that phase's `outputs` + `evidence` paths to validate the gate
   (evidence-based, not trust-based) and to build the NEXT phase's prompt — hand off state keys +
   `.ai_log/` PATHS, never re-dumped content.

**every phase agent**
1. **On START:** `get` the inputs this phase needs (the fields its YAML `input:` lists + their
   `.ai_log/` evidence paths). Do NOT expect large inlined content in the prompt.
2. **On COMPLETION:** `set`/`append` this phase's outputs — key result fields + PATHS to evidence
   offloaded in `.ai_log/` — and record the `phases.<n-name>` entry (agent, status, outputs,
   evidence, work_items). Keep writing the docs/-native report (R7/R8) as the human record; the state
   is the machine handoff bus and REFERENCES those docs/ + `.ai_log/` artifacts.

## Coexistence (do not conflate)

| Layer | Home | Purpose |
|-------|------|---------|
| **pipeline-state** | `.ai_log/session-<id>-<name>.json` (per-session, git-ignored) | MACHINE handoff bus — key fields + reference PATHS across phases (R17) |
| **`.ai_log/`** | `.ai_log/<phase-N>-<agent>-<artifact>.<ext>` | TEMPORARY evidence blobs, git-ignored (R15) |
| **docs/ reports** | `docs/sessions/<session>/`, `docs/reports/feature-log/` | HUMAN-readable committed work record (R7/R8) |

The state points at the other two; it never duplicates their content.
