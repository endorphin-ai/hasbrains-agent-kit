---
id: fidelity-checks
title: Fidelity checks + thresholds — completeness, layout, spacing (8pt), color (60/30/10 + tokens), type, DOM, interactions
summary: The measurable checks both the frontend self-gate and the verifier run — completeness census (first), layout/position, spacing on the 8pt grid, color against the palette + 60/30/10 balance + token conformance (against the project's declared token source), type scale/weight/line-height, DOM-structure preservation, and broken/obscured-interaction detection — plus the severity model and the PASS/FAIL rule.
tags: [contract/checks, contract/thresholds, contract/tokens]
aliases: [8pt grid, 60/30/10, token conformance, type scale, pixel threshold, severity, layout drift, dom check]
load_when: Deciding what to measure on a page; classifying a diff as PASS/FAIL; setting/holding the drift threshold; explaining a failing diff.
links: [[design-diff]], [[region-census]], [[baseline-and-oracle]], [[frontend-port]]
---

# Fidelity checks + thresholds

A pixel diff tells you a page CHANGED; these checks tell you WHAT drifted and whether it
gates. Run them alongside the pixel diff ([[design-diff]] steps 5–7; [[frontend-port]] §4)
so every FAIL is explained, not just flagged.

## The checks

**Run `completeness (census)` FIRST — before any pixel diff.** A pixel diff needs a
correctly cropped, correctly aligned baseline to be trustworthy; when the baseline is
missing, mis-scaled, or the page scrolls differently, a whole missing section can hide
inside an "acceptable" diff %. The census does not depend on a pixel baseline at all — it
asks a binary question per region, so it catches exactly the failure a soft pixel pass
misses (a real build shipped with NO page header, NO marquee band, and NO membership CTA
card — every one a whole region the oracle had and the build simply didn't render). See
[[region-census]] for the mechanics.

| Category | What to measure | Oracle source | Typical FAIL |
|----------|-----------------|---------------|--------------|
| **completeness (census)** | EVERY region + EVERY interactive element in the oracle's inventory is PRESENT in the build, in the same order, none extra | oracle inventory (designer-emitted; else censused live from the frozen oracle) | a whole region absent (page header / marquee / CTA card); a card sub-part dropped; an element the oracle has that the build lacks |
| **layout** | position + order + responsive stacking of the regions that ARE present, at each breakpoint | frozen mockup | a present section moved/reordered; wrong column count at a breakpoint |
| **spacing** | padding/margin/gap land on the **8pt grid** (4/8/16/24/32…); rhythm matches | tokens + mockup | 12px gap where the grid + mockup say 16px; off-grid ad-hoc spacing |
| **color** | each color is a **named token** (no raw value where a token exists); overall **60/30/10** dominant/secondary/accent balance holds; contrast ≥ WCAG AA | design-tokens + design-system | CTA uses a raw hex not `color.accent`; accent over-used (breaks 60/30/10) |
| **type** | font family, the **type scale** step, weight, line-height, letter-spacing | design-tokens (type scale) | heading one step off the scale; wrong weight; line-height drift |
| **token** | every applied value traces to a named token (color/space/radius/shadow/z) in the project's DECLARED token source | design-tokens + `{config.frontend_runtime}` | a raw value that should be a token; a value with no token at all; a second styling source introduced |
| **DOM structure** | the built page's tag/class/`data-test` skeleton matches the frozen oracle, in order | frozen mockup | markup rewritten "but looks the same"; containers merged; hooks dropped |
| **interaction** | controls captured are actually clickable — not covered by an overlay/z-index/pointer-events | the project's e2e test-conventions hit-test | menu obscured; CTA behind a fixed banner |

## How to measure (mechanics)

- **Completeness census (FIRST):** build the region/element list from the oracle — the
  designer's inventory (`docs/design/<page>-inventory.md`) if it exists, else derive it
  live by walking the frozen oracle's DOM. Then walk the BUILT page's DOM (`agent-browser`
  snapshot) and check each oracle entry off by its `data-test` hook (or, absent a hook, by
  region role + text). ANY oracle region/element missing, reordered, or an extra region the
  oracle doesn't have = a census FAIL — independent of the pixel %. Detail: [[region-census]].
- **Pixel diff (AFTER the census):** Playwright `toHaveScreenshot` / pixelmatch / odiff
  against the baseline at each pinned breakpoint; the threshold comes from the design
  spec's visual acceptance contract (e.g. <0.1%). Settle fonts + the UI framework's settle
  signal (per `{config.frontend_runtime}`) first to avoid FOUT/animation false-diffs. The
  pixel diff refines a page that already PASSED the census; it never substitutes for it.
- **Spacing / type / color:** read COMPUTED styles via `agent-browser` (or the a11y/DOM
  snapshot) and compare the computed px/hex against the token values — don't eyeball. The
  token source is the project's DECLARED one (`{config.frontend_runtime}` — e.g. CSS custom
  properties in the app stylesheet `:root`, mirrored by `docs/design/design-tokens`) —
  never assume a utility-framework pipeline exists. 8pt grid: assert spacing values are
  multiples of the grid unit.
- **60/30/10:** sample the rendered surface's dominant regions; confirm the neutral/base
  dominates (~60%), the secondary supports (~30%), the accent is sparing (~10%). A page
  washed in accent color FAILs even if each color is a valid token.
- **DOM structure:** snapshot the normalized DOM outline (tag + class list + `data-test`
  per node) of built vs oracle; assert every baseline hook + tag/class is present and in
  order. Catches a rewritten port a pixel diff alone could miss.
- **Interaction:** `elementFromPoint(cx,cy)` at the control centre must resolve to the
  control (not an overlay) — the same hit-test the project's e2e test-conventions skill
  enforces.

## Severity + PASS/FAIL rule

- **Blocker** — a broken/obscured interaction, a gated-content-adjacent visual leak, OR a
  MISSING whole region / interactive element the oracle has (an entire section, CTA card,
  nav, or control the build never renders). A census miss of a whole region is a Blocker,
  not a nit — it is the exact class of defect this contract exists to stop. Always gates.
- **Major** — a census miss of a region SUB-PART (a dropped badge, meta row, thumbnail), a
  region reordered / an extra region, visible drift OVER the per-breakpoint threshold, an
  unexplained DOM-structure delta, or a clear token/8pt/60-30-10 violation. Gates.
- **Minor** — a sub-threshold nit on a region that IS present and complete; a missing
  `data-test` hook on a present element. NOTED in the report, does not gate (avoid
  threshold-noise churn).

**A page = PASS** only when the completeness census is 100% (every oracle region + element
present, in order, none extra) AND the DOM-structure check passes AND every breakpoint cell
is under threshold AND it carries no Blocker/Major finding. A page can never PASS on a
green pixel diff alone while the census is short — census FIRST, then pixels. Any
Blocker/Major → the page FAILs → `DESIGN-DIFF: reject` → contributes a `GATE: reject` on
the pipeline verify path (same weight as a functional invariant violation). On the verifier
path this is report-only: findings route to the frontend dev (fix the build) or the
designer (refresh the oracle) — never edit application source there.
