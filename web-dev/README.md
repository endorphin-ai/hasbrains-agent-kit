# web-dev

Multi-agent web dev pipeline — the designer ↔ frontend contract: freeze approved mockups into a canonical oracle, port them 1:1 on any stack, verify with screenshot-based design-diff gates.

## Skills

- [`designer-frontend-contract`](skills/designer-frontend-contract) — the tech-agnostic contract between designer and frontend dev. The designer freezes an approved mockup into a canonical oracle (manifest, baseline renders, region inventory, token parity); the frontend dev ports it 1:1 — transcribe, never redesign — self-gating census → DOM → pixel; the design-diff verifier independently screenshots every page × state × breakpoint against the frozen baseline and reports per-page PASS/FAIL. Works on any stack: stack facts are read at runtime from project config, never baked in. Includes three workflows: designer-handoff, frontend-port, design-diff.

## Components

- `skills/` — one folder per skill, each containing `SKILL.md` plus optional `references/`, `workflows/`, and `maps/`
- `agents/` — e.g. design agent, conversion agent definitions
- `commands/` — slash command markdown files

## Install

```
/plugin install web-dev@hasbrains-agent-kit
```
