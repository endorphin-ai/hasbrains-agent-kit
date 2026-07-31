# pipeline-state

> A durable, file-backed handoff bus so multi-agent runs pass references — not giant inlined dumps.

**Plugin:** `context-engineering` — `/plugin install context-engineering@hasbrains-agent-kit`

## Why use it

- Phase 4 re-pastes everything phase 3 produced, and the context window pays for it twice.
- A long run gets compressed and the earlier phases' outputs are simply gone.
- "What did the last phase actually produce?" has no machine-readable answer.

## What it does

- One per-run, git-ignored JSON file holding the run's variables, each phase's outputs, and paths to its evidence.
- Read-on-START / write-on-COMPLETION protocol: pull your inputs by lookup, record your outputs as fields + PATHS.
- A small shell script — `init` / `set` / `append` / `get` / `clear` — plus the state schema.
- Coexists with your committed reports: it references them, it never replaces them.

## Benefits

- **Small prompts, long runs.** Handoffs become lookups instead of re-pasted dumps.
- **Survives context compression** — nothing from phase 2 is lost by phase 8.
- **Gates you can trust.** The orchestrator validates from evidence, not from a summary.
- **One script, any pipeline.** No service, no database, no dependencies.

---

Made by **HasBrains** — https://hasbrains.com/
