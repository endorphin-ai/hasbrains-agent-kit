# designer-frontend-contract

> The tech-agnostic contract between designer and frontend dev — and the gate that mechanically enforces it.

**Plugin:** `web-dev` — `/plugin install web-dev@hasbrains-agent-kit`

## Why use it

- "Matches the design" asserted from a screenshot glance, while a whole page region is missing.
- The build quietly re-styles the mockup, and the drift is only noticed after launch.
- HTTP 200 and a green CI badge say nothing about whether the UI is actually right.

## What it does

- **Designer side** — freeze the approved mockup into a canonical oracle: manifest, baseline renders, a region/element inventory, token parity, a visual acceptance contract.
- **Frontend side** — port the oracle 1:1 (transcribe, never redesign) and self-gate census → DOM → pixel before handoff.
- **Verifier side** — independently screenshot every page × access state × pinned breakpoint against the frozen baseline; census FIRST, then pixel diff, then interaction hit-testing.
- Report-only verification: findings route to the dev (drift) or the designer (a legitimate design change).

## Benefits

- **Ship what was actually designed.** Fidelity becomes an enforced gate, not an assumption.
- **Catch the missing region** the pixel diff would have waved through.
- **No more launch-day drift** — every page, state and breakpoint is checked before merge.
- **Any stack.** Dev server, template language and tokens all come from your project config.

---

Made by **HasBrains** — https://hasbrains.com/
