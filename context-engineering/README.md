# context-engineering

Context engineering for AI agents — AI-optimized second-brain skills, durable pipeline state for multi-agent handoffs, and expert prompt building.

## Skills

- [`build-brain`](skills/build-brain) — turn a skill or raw data into an AI-optimized "second brain": a lean SKILL.md map backed by atomized, tagged references and JSON navigation maps, with a before/after improvement report.
- [`pipeline-state`](skills/pipeline-state) — durable, file-backed handoff bus for multi-agent pipelines. Persists per-run variables, per-phase outputs, and evidence-path references to a per-session JSON file that survives context compression.
- [`prompt-expert`](skills/prompt-expert) — expert prompt engineer that interviews the user first, then builds high-quality prompts and system prompts for any AI (Claude, Gemini, Copilot, ChatGPT).

## Components

- `skills/` — one folder per skill, each containing `SKILL.md` plus optional `references/`
- `agents/` — agent definition markdown files
- `commands/` — slash command markdown files (e.g. `context-audit.md` → `/context-engineering:context-audit`)

## Install

```
/plugin install context-engineering@hasbrains-agent-kit
```
