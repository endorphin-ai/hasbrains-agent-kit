# agent-engineering

Engineering discipline for AI agent systems — always-on principles, TDD, verification gates, architecture playbooks, and docs/-native project management.

## Skills

- [`four-principles`](skills/four-principles) — always-on engineering principles for every task: think before coding, simplicity first, surgical changes, goal-driven execution.
- [`test-driven-development`](skills/test-driven-development) — write the test first, watch it fail, write minimal code to pass. Red-green-refactor loop, test-quality principles, test-layer selection.
- [`verification-before-completion`](skills/verification-before-completion) — evidence before assertions: run verification commands and confirm output before claiming anything is complete, fixed, or passing.
- [`system-architecture`](skills/system-architecture) — architecture pattern selection, system-design workflows, capacity planning, and technology-choice frameworks (SQL vs NoSQL, REST vs GraphQL, and more).
- [`docs-project-management`](skills/docs-project-management) — run an entire project from the repo's `docs/` folder: work-item taxonomy (roadmap → PRD → TRD → epics → stories → test cases → bugs), cross-document link graph, status lifecycle, and per-session team reports. No external issue tracker.

## Components

- `skills/` — one folder per skill, each containing `SKILL.md` plus optional `references/`
- `agents/` — agent definition markdown files
- `commands/` — slash command markdown files (e.g. `agent-decouple.md` → `/agent-engineering:agent-decouple`)

## Install

```
/plugin install agent-engineering@hasbrains-agent-kit
```
