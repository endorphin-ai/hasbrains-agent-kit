---
name: pipeline-state
description: Durable, file-backed pipeline handoff BUS for the WHOLE squad (all worker agents + el-capitan). Persists per-run variables, per-phase outputs, and `.ai_log/` evidence-PATH references to a PER-SESSION, git-ignored JSON file under `.ai_log/` (`.ai_log/session-<id>-<name>.json`, one per run) that survives context compression; cleans stale `.ai_log/` artifacts on init. On phase START, READ it to pull this phase's inputs (key fields + evidence paths); on phase COMPLETION, WRITE this phase's outputs (key result fields + `.ai_log/` paths — never large inlined blobs). The standing pattern (R17): evidence -> `.ai_log/`; references + key fields -> pipeline-state; handoffs = state lookups, not inlined dumps. Coexists with the docs/ reports (R7/R8, the human record) + the `.ai_log/` offload (R15). Originally built for the e2e-test-healer; now squad-wide. Use for ANY cross-phase handoff.
---

# pipeline-state — the squad-wide handoff bus

Durable, file-backed state for the ENTIRE pipeline. **One JSON file** persists the run's variables +
per-phase outputs + `.ai_log/` evidence-path references across phases, so a downstream agent (or
el-capitan) recovers exactly what it needs by LOOKUP instead of receiving a large inlined dump — and
nothing is lost to context compression on long runs.

**The standing pattern (rule R17):** evidence -> `.ai_log/`; references + key fields ->
pipeline-state; handoffs = **state lookups, not inlined dumps**.

- **el-capitan** INITIALIZES the state at session start (alongside creating the session folder),
  passes its path (`state_file`) to every dispatched agent, and after each phase READS that phase's
  output fields + `.ai_log/` evidence paths FROM the state to validate the gate and to build the NEXT
  phase's prompt — passing state keys + paths, never re-dumping large content.
- **every agent**, on START, READS the state to pull the inputs this phase needs (key fields +
  `.ai_log/` evidence paths) — it does NOT expect large inlined content; on COMPLETION, WRITES its
  outputs — key result fields + PATHS to evidence offloaded in `.ai_log/` (never the blobs).
- It **COEXISTS** with the docs/-native reports (R7/R8 — the human-readable record) and the
  `.ai_log/` path-handoff (R15). The state REFERENCES the docs/ + `.ai_log/` artifacts; it does not
  replace them.

## State file (PER-SESSION, `.ai_log/`, git-ignored)

```
.ai_log/session-<session-id>-<name>.json
```

**ONE file per run**, living under `.ai_log/` — e.g. `.ai_log/session-2026-06-30-member-blog-gating.json`.

**Naming convention.** `<session-id>` (`<xxxxx>`) is the run's disambiguating id — in this squad the
session date `<YYYY-MM-DD>` (distinguishes repeat/concurrent runs); `<name>` is the epic-slug. Together
`<session-id>-<name>` is the session LABEL `<YYYY-MM-DD>-<epic-slug>` (the same slug as `session_dir`).
The script DERIVES the path from that label (`session-<label>.json`).

**el-capitan derives + creates it at `init` and passes its exact PATH as `state_file` to every dispatched
agent.** Agents read/write the path el-capitan gave them (via `state_file`) — they do NOT reconstruct or
hardcode a constant path (the path now varies per session). This one convention is used consistently by
the skill, the `el-capitan-ror` command, the workflow YAML, and CLAUDE.md.

**Git behavior.** Because it lives under `.ai_log/`, it is **git-IGNORED (never committed)** by the
`/.ai_log/*` + `!/.ai_log/.gitkeep` rule — no `.gitignore` change needed. It is the ONE structured
handoff JSON in `.ai_log/`; ordinary evidence there stays throwaway (R15). It is **ephemeral, per-run,
and regenerated fresh each session** — NOT a durable record. Durable records still live in `docs/`
(R7/R8), which the state only references (R15/R17 stay coherent: the state is a machine handoff bus, not
durable content parked in `.ai_log/`).

## Script

```
.claude/skills/pipeline-state/scripts/pipeline-state.sh
```

## Commands

```bash
# Start a new run — writes .ai_log/session-<session_id>.json AND cleans stale .ai_log/ artifacts (R15)
pipeline-state.sh init   <session_id>

# Store a string/scalar field
pipeline-state.sh set    <session_id> <field> <value>

# Append a value to a list field (creates the list if absent) — e.g. an .ai_log/ evidence path
pipeline-state.sh append <session_id> <field> <value>

# Read a single field (or the full JSON if field is omitted) — the recovery / handoff lookup
pipeline-state.sh get    <session_id> [field]

# Delete the state file
pipeline-state.sh clear  <session_id>
```

`<session_id>` is the run label on `init` (convention: `<YYYY-MM-DD>-<epic-slug>`, the same slug as
`session_dir`); the state file PATH is DERIVED from it (`.ai_log/session-<session_id>.json`), so every
later command passes the SAME `<session_id>` and resolves the SAME per-session file. el-capitan captures
the path `init` prints and passes it as `state_file`; agents use that exact path.

## State schema + read/write protocol

See **`references/state-schema.md`** — the per-phase entry shape (agent, status, key output fields,
`.ai_log/` evidence paths, work-item links) + the read-on-START / write-on-COMPLETION protocol and
the field conventions (scalar via `set`, list via `append`).

## `init` cleanup

On `init` the script clears stale `.ai_log/` artifacts from prior runs — everything under `.ai_log/`
**except the tracked `.ai_log/.gitkeep`** — so a fresh run starts clean. This is consistent with R15
(`.ai_log/` is temporary-only; contents are git-ignored) and with the folder-tracked/contents-ignored
convention (`/.ai_log/*` + `!/.ai_log/.gitkeep`).

## Usage

```bash
# --- el-capitan, at SESSION START (alongside creating docs/sessions/<session>/) ---
SESSION="2026-06-30-member-blog-gating"          # = the session_dir slug
bash .claude/skills/pipeline-state/scripts/pipeline-state.sh init "$SESSION"
bash .claude/skills/pipeline-state/scripts/pipeline-state.sh set "$SESSION" session_dir "docs/sessions/$SESSION/"
bash .claude/skills/pipeline-state/scripts/pipeline-state.sh set "$SESSION" user_request "$USER_REQUEST"
# init derived .ai_log/session-$SESSION.json — el-capitan passes state_file=.ai_log/session-$SESSION.json to EVERY dispatched agent

# --- any phase, on COMPLETION: write outputs = key fields + .ai_log/ evidence PATHS (never blobs) ---
bash .claude/skills/pipeline-state/scripts/pipeline-state.sh set    "$SESSION" prd_document "docs/prd/member-blog-gating.md"
bash .claude/skills/pipeline-state/scripts/pipeline-state.sh append "$SESSION" phase-0-evidence ".ai_log/phase-0-pm-ror-prd.md"

# --- next phase, on START: read the inputs it needs (fields + .ai_log/ paths), not a big dump ---
PRD=$(bash .claude/skills/pipeline-state/scripts/pipeline-state.sh get "$SESSION" prd_document)

# --- el-capitan, at the GATE: read the phase's outputs + evidence paths to validate + build next prompt ---
bash .claude/skills/pipeline-state/scripts/pipeline-state.sh get "$SESSION"        # full state (recovery)
```

**e2e-test-healer note:** the healer (its own out-of-pipeline flow) uses the SAME script and file —
`init` at the start of a heal run, `set`/`append` for its per-phase variables (test id, spec file,
RCA report path, burn-evidence paths, PR number), and `get` to restore state after context
compression. It is one consumer of the now squad-wide bus; the schema in `references/state-schema.md`
covers both the pipeline phases and the healer's fields.

---

VERSION 2.0.0
