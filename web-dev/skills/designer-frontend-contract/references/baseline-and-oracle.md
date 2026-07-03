---
id: baseline-and-oracle
title: The oracle + establishing/refreshing a baseline (incl. the design-phase-skipped migration case)
summary: What the design oracle is (frozen renderable mockup = pixel oracle; design-tokens + design-system.md = rule oracle), how to resolve it per page/state via oracle-manifest.json, canvas-export de-framing, and how to ESTABLISH a baseline when none exists or REFRESH one when the design legitimately changed.
tags: [contract/oracle, contract/baseline, contract/migration]
aliases: [oracle, frozen baseline, establish baseline, refresh baseline, no oracle, design phase skipped, migration baseline, oracle manifest]
load_when: Resolving/refreshing the baseline; no oracle exists yet for a page; the design legitimately changed; a design-phase-skipped migration run.
links: [[design-diff]], [[fidelity-checks]], [[designer-handoff]], [[region-census]]
---

# The oracle + establishing/refreshing a baseline

## What the oracle is

Three layers, all owned by the DESIGNER and committed under `docs/design/`:

- **Canonical oracle — ONE frozen, renderable file per page.** Exactly one approved mockup
  file is THE oracle for a given route. `docs/design/` accumulates many candidate files per
  feature (multiple mockups, canvas exports, state variants) — so resolve the oracle via the
  **manifest** (`docs/design/oracle-manifest.json`: route → canonical oracle file +
  baseline dir + inventory file, per [[designer-handoff]]). Never guess which of several
  files is authoritative — read the manifest. A missing manifest entry is itself a
  `[NO-ORACLE]` finding: ask the designer to declare it.
- **Baseline renders — the pixel target.** Static captures of the canonical oracle at the
  pinned breakpoints under `docs/design/baseline/<page>-<width>.png`. The build's
  screenshots are pixel-diffed against THESE.
- **Rule oracle — the design system.** `docs/design/design-tokens` (mirroring the app's
  single declared token source — per `{config.frontend_runtime}`; never assume a
  utility-framework config) and `docs/design/design-system.md` — palette, type scale,
  spacing grid, radius/shadow, 60/30/10 balance, AVOID list. These catch drift a pixel diff
  misses and explain a FAIL.

Also read the per-feature `docs/design/<feature>-design-spec.md` for the **visual
acceptance contract**: the pinned breakpoint widths, the per-breakpoint pixel threshold +
exclusions, and the pointer to the region/element inventory the census ([[region-census]])
runs against.

**Canvas-export oracles.** Some oracle files are design-tool *canvas* exports — the real
page markup wrapped in an absolutely-positioned device frame (a positioned wrapper, a
bordered "screen" div, tool scaffolding attributes). The page CONTENT inside (normal
document flow) IS the oracle; the canvas wrapper is not. When censusing/diffing against a
canvas export, scope to the inner screen element and ignore the frame — or ask the designer
to emit a de-framed render for the baseline PNGs.

## Resolving the oracle per page × state

Each built page maps (via the manifest) to its canonical oracle + the access states it was
designed for. Diff each state against ITS OWN oracle — never diff an entitled render
against the anonymous baseline, or a locked/paywall state against the unlocked mockup.
Where the design system defines a state but no dedicated oracle exists, fall back to the
rule oracle (tokens/system) and note it. In every state, the completeness census runs
against the oracle's inventory regardless of whether a pixel baseline exists.

## ESTABLISH a baseline when none exists — the migration case

A migration/legacy run may have NO design-phase output for a promoted UI — nothing to diff
against. Do NOT silently pass (`[NO-ORACLE]`). Establish one:

1. **Prefer an existing mockup.** If `docs/design/` already has an approved mockup for the
   page (or a close gold-standard page), promote it as the baseline and note the mapping in
   the manifest.
2. **Otherwise capture the current approved UI as the baseline.** Screenshot the current,
   agreed-good running page at all pinned breakpoints in each access state and save the
   snapshot under `docs/design/` (a `<feature>-baseline/` snapshot + a note in the design
   spec). This must be ACKNOWLEDGED as the intended design — a baseline captured from a
   broken page just enshrines the bug — so pair establishment with a design-system rule
   check ([[fidelity-checks]]) and, where the design is user-facing-new, the designer's
   approval gate.
3. **Record baseline status** in the report as `ESTABLISHED-THIS-RUN` (vs `FROZEN`) so
   readers know the diff is against a freshly-captured, not a design-phase-approved, oracle.

Once established, every subsequent build is diffed against THAT baseline — the
drift-detection loop works even though the design phase was skipped.

## REFRESH a baseline when the design legitimately changed

If a diff FAILs because the design INTENTIONALLY changed (not a build regression), the fix
is NOT to relax the threshold — it is to refresh the oracle:

1. The **designer** updates the mockup + tokens/system and re-freezes the baseline
   (re-running the user approval gate for a user-visible change).
2. Bump/annotate the baseline in `docs/design/` + the manifest and note `REFRESHED` in the
   report.
3. Never edit application source to "make the diff pass," and never overwrite the baseline
   with a build screenshot to silence a real regression — that hides drift.

## Guardrails

- The baseline lives in `docs/design/` (committed), never only in `.ai_log/` (git-ignored)
  — R15. Diff images are throwaway evidence in `.ai_log/`; the baseline is durable.
- A page with no resolvable oracle is `[NO-ORACLE]`, an explicit blocking finding —
  establish one, don't pass by default.
