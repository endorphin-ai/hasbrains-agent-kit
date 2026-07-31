---
name: pipeline-state
description: Durable, file-backed pipeline handoff BUS for a whole multi-agent run (the orchestrator + every worker agent). Persists per-run variables, per-phase outputs, and `.ai_log/` evidence-PATH references to a PER-SESSION, git-ignored JSON file under `.ai_log/` (`.ai_log/session-<id>-<name>.json`, one per run) that survives context compression; cleans stale `.ai_log/` artifacts on init. On phase START, READ it to pull this phase's inputs (key fields + evidence paths); on phase COMPLETION, WRITE this phase's outputs (key result fields + `.ai_log/` paths — never large inlined blobs). The standing pattern: evidence -> the git-ignored scratch folder; references + key fields -> pipeline-state; handoffs = state lookups, not inlined dumps. Coexists with the committed docs/ reports (the human record) — it references them, it never replaces them. Use for ANY cross-phase handoff.
---

# pipeline-state — the run-wide handoff bus

Durable, file-backed state for the ENTIRE pipeline. **One JSON file** persists the run's variables +
per-phase outputs + `.ai_log/` evidence-path references across phases, so a downstream agent (or the
orchestrator) recovers exactly what it needs by LOOKUP instead of receiving a large inlined dump — and
nothing is lost to context compression on long runs.

**The standing pattern:** evidence -> `.ai_log/`; references + key fields ->
pipeline-state; handoffs = **state lookups, not inlined dumps**.

- **the orchestrator** INITIALIZES the state at session start (alongside creating the session folder),
  passes its path (`state_file`) to every dispatched agent, and after each phase READS that phase's
  output fields + `.ai_log/` evidence paths FROM the state to validate the gate and to build the NEXT
  phase's prompt — passing state keys + paths, never re-dumping large content.
- **every agent**, on START, READS the state to pull the inputs this phase needs (key fields +
  `.ai_log/` evidence paths) — it does NOT expect large inlined content; on COMPLETION, WRITES its
  outputs — key result fields + PATHS to evidence offloaded in `.ai_log/` (never the blobs).
- It **COEXISTS** with the docs/-native reports (the human-readable record) and the `.ai_log/`
  path-handoff. The state REFERENCES the docs/ + `.ai_log/` artifacts; it does not replace them.

## State file (PER-SESSION, `.ai_log/`, git-ignored)

```
.ai_log/session-<session-id>-<name>.json
```

**ONE file per run**, living under `.ai_log/` — e.g. `.ai_log/session-2026-06-30-member-blog-gating.json`.

**Naming convention.** `<session-id>` is the run's disambiguating id — commonly the session date
`<YYYY-MM-DD>` (it separates repeat/concurrent runs); `<name>` is the epic slug. Together
`<session-id>-<name>` is the session LABEL `<YYYY-MM-DD>-<epic-slug>` (the same slug as `session_dir`).
The script DERIVES the path from that label (`session-<label>.json`).

**The orchestrator derives + creates it at `init` and passes its exact PATH as `state_file` to every
dispatched agent.** Agents read/write the path they were given — they do NOT reconstruct or hardcode a
constant path, because it varies per session. Use the one convention consistently across the skill, the
orchestrating command, and any workflow definition.

**Git behavior.** Because it lives under `.ai_log/`, it is **git-IGNORED (never committed)** by the
`/.ai_log/*` + `!/.ai_log/.gitkeep` rule — no `.gitignore` change needed. It is the ONE structured
handoff JSON in `.ai_log/`; ordinary evidence there stays throwaway. It is **ephemeral, per-run, and
regenerated fresh each session** — NOT a durable record. Durable records still live in committed
`docs/`, which the state only references: the state is a machine handoff bus, never durable content
parked in a git-ignored folder.

## Script

```
scripts/pipeline-state.sh          # ships with this skill; call it from wherever the skill is installed
```

## Commands

```bash
# Start a new run — writes .ai_log/session-<session_id>.json AND cleans stale .ai_log/ artifacts
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
later command passes the SAME `<session_id>` and resolves the SAME per-session file. The orchestrator
captures the path `init` prints and passes it as `state_file`; agents use that exact path.

## State schema + read/write protocol

See **`references/state-schema.md`** — the per-phase entry shape (agent, status, key output fields,
`.ai_log/` evidence paths, work-item links) + the read-on-START / write-on-COMPLETION protocol and
the field conventions (scalar via `set`, list via `append`).

## `init` cleanup

On `init` the script clears stale `.ai_log/` artifacts from prior runs — everything under `.ai_log/`
**except the tracked `.ai_log/.gitkeep`** — so a fresh run starts clean. This matches the
temporary-only rule for that folder and the folder-tracked / contents-ignored convention
(`/.ai_log/*` + `!/.ai_log/.gitkeep`).

## Usage

```bash
# --- the orchestrator, at SESSION START (alongside creating docs/sessions/<session>/) ---
SESSION="2026-06-30-member-blog-gating"          # = the session_dir slug
bash scripts/pipeline-state.sh init "$SESSION"
bash scripts/pipeline-state.sh set "$SESSION" session_dir "docs/sessions/$SESSION/"
bash scripts/pipeline-state.sh set "$SESSION" user_request "$USER_REQUEST"
# init derived .ai_log/session-$SESSION.json — the orchestrator passes state_file=.ai_log/session-$SESSION.json to EVERY dispatched agent

# --- any phase, on COMPLETION: write outputs = key fields + .ai_log/ evidence PATHS (never blobs) ---
bash scripts/pipeline-state.sh set    "$SESSION" prd_document "docs/prd/member-blog-gating.md"
bash scripts/pipeline-state.sh append "$SESSION" phase-0-evidence ".ai_log/phase-0-pm-prd.md"

# --- next phase, on START: read the inputs it needs (fields + .ai_log/ paths), not a big dump ---
PRD=$(bash scripts/pipeline-state.sh get "$SESSION" prd_document)

# --- the orchestrator, at the GATE: read the phase's outputs + evidence paths to validate + build next prompt ---
bash scripts/pipeline-state.sh get "$SESSION"        # full state (recovery)
```

**Out-of-pipeline flows use it too.** Any standalone multi-step run (a test-healing pass, a migration
sweep) uses the SAME script and file — `init` at the start, `set`/`append` for its per-step variables
(the item under work, file paths, evidence paths, a PR number), and `get` to restore state after context
compression. The schema in `references/state-schema.md` covers both shapes.

---

VERSION 2.0.0

---

Made by **HasBrains** — https://hasbrains.com/
