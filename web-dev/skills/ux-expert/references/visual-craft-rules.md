# The 12 Visual Craft Rules

> **Source**: adapted from [tommyjepsen/awesome-ux-skills](https://github.com/tommyjepsen/awesome-ux-skills) (`general-design-review.md`).
> **Load when**: Reviewing high-fidelity UI or frontend CSS — report only violations, each with a concrete replacement value. SKIP for wireframes, flows, and early concepts.

---

## Visual Craft Lens

For high-fidelity UI or frontend code, run a quick pass against the 12 craft rules (the source points at a separate `craft` skill; **this file is the full version here** — see "Repo adaptation" below):

1. **No gradients** — flat, deliberate color; a gradient is usually an unmade color decision.
2. **No glow** — emphasis from size, weight, contrast, and space; shadows are for elevation only.
3. **No `transition: all`** — transition named properties with explicit durations and easings.
4. **Kill visual monotony** — break same-width, same-weight, all-centered rhythm; hierarchy should survive the squint test.
5. **No placeholder text** — real microcopy is part of the design.
6. **Contained stacking contexts** — `isolation: isolate` per layered component, one small z-index scale, no `z-index: 9999`.
7. **No pure black or white** — tuned neutral ramps for text, backgrounds, and borders.
8. **Space on a scale** — 4/8px grid; gaps within a group smaller than gaps between groups.
9. **Type does the work** — small scale, hierarchy from weight and color, max measure for body text.
10. **One elevation language** — borders for structure or shadows for floating, not both stacked.
11. **Every state designed** — hover, focus-visible, active, disabled, loading, empty, error.
12. **Motion is physics** — 120–250ms, transform/opacity only, `prefers-reduced-motion` respected.

Report only violations, with concrete replacement values. Skip this lens for wireframes, flows, and early-stage concepts.

---

## Project adaptation

- The source points at a separate `craft` skill for the full rule bodies; there is no such skill here. **This file is the full version** — the 12 rules above, applied with a concrete replacement value per violation.
- Rule 8 ("space on a scale") is enforced as the spacing grid the project's design system declares (an **8pt grid** is the common default), plus the label→title breathing rule: an eyebrow/badge above a heading gets ≥ one grid step of clearance. A cramped label→title pair is a finding.
- Rule 11 ("every state designed") maps to the project's required page states — loaded / loading / empty / error **plus** every access state the product has (read them from `{config.frontend_runtime}`) and the gated/paywalled state. A craft pass that only saw the happy path is incomplete.
- **The project's approved design system OVERRIDES these rules where they conflict.** Rules 1, 2 and 7 ("no gradients / no glow / no pure black or white") are generic defaults; a project whose approved system is built ON a gradient, a glow-as-depth language, or a true-black canvas has not violated anything. Judge against `docs/design/design-system.md` — that is the local oracle — and flag a gradient/glow only when it is OFF-system (a second, unsanctioned gradient; a glow used as elevation where the system says drop-shadow), never merely for existing.
