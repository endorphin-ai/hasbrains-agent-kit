# web-dev

Multi-agent web dev pipeline — UX research and design critique before and after the build, plus the designer ↔ frontend contract: freeze approved mockups into a canonical oracle, port them 1:1 on any stack, verify with screenshot-based design-diff gates.

## Skills

- [`ux-expert`](skills/ux-expert) — UX research, definition and evaluation: the reasoning BEFORE a wireframe and the critique AFTER a build. Six modes, one workflow each — `research` (pick the method that fits the question × product stage), `personas` (2-4 relevance-tested personas, each carrying provenance: grounded or clearly labelled proto), `storyboard` (one persona · one scenario · one path, an emotion per panel), `heuristics` (Nielsen H1-H10 applied selectively — critique or design guidance), `review` (the combined lens: usability · cognitive load/conversion · visual craft · a11y · AI-product · process), `analysis` (design forensics — measure a screenshot or live URL for exact hexes, type scale, spacing ladder, contrast pairs, composition metrics, tokens). Two hard rules: **measure or drive, never guess**, and **judgment over completeness** — a verdict, 3-5 findings each with its consequence, max 3 priority actions. Never produces the visual design; routes drift to `designer-frontend-contract`.
- [`designer-frontend-contract`](skills/designer-frontend-contract) — the tech-agnostic contract between designer and frontend dev. The designer freezes an approved mockup into a canonical oracle (manifest, baseline renders, region inventory, token parity); the frontend dev ports it 1:1 — transcribe, never redesign — self-gating census → DOM → pixel; the design-diff verifier independently screenshots every page × state × breakpoint against the frozen baseline and reports per-page PASS/FAIL. Works on any stack: stack facts are read at runtime from project config, never baked in. Includes three workflows: designer-handoff, frontend-port, design-diff.

## Components

- `skills/` — one folder per skill, each containing `SKILL.md` plus optional `references/`, `workflows/`, and `maps/`
- `agents/` — e.g. design agent, conversion agent definitions
- `commands/` — slash command markdown files

## Install

```
/plugin install web-dev@hasbrains-agent-kit
```
