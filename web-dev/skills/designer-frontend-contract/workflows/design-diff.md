---
id: design-diff
title: VERIFIER — screenshot the built pages and diff against the approved oracle (report-only)
summary: End-to-end design-diff run — resolve the oracle via the manifest, start the app, screenshot every built page × access state × pinned breakpoint with agent-browser/Playwright, census FIRST, pixel-diff vs the frozen baseline, rule-check tokens/60-30-10/8pt, hit-test interactions, offload diff images to .ai_log/, emit per-page PASS/FAIL + a gate verdict. Report-only — findings route to the frontend dev or the designer.
tags: [contract/verifier, contract/design-diff, contract/gate]
aliases: [visual regression, screenshot diff, design fidelity run, baseline compare, design-diff gate]
load_when: Verifying built pages against the approved design (the pipeline verify gate, the fan-out audit's visual finder, or an ad-hoc pass).
links: [[baseline-and-oracle]], [[region-census]], [[fidelity-checks]], [[contract-and-communication]], [[frontend-port]]
---

<!-- Related notes: [[baseline-and-oracle]] · [[region-census]] · [[fidelity-checks]] -->

TASKLANG
TYPE WORKFLOW

IDENTITY "Design-Diff Run Playbook (verifier side of the contract)"
  > Diff the built, RUNNING UI against the approved design oracle and emit per-page
  > PASS/FAIL. The INDEPENDENT fidelity check — a second pair of eyes on the delivered UI,
  > owned by the designer and run again on the pipeline's verify path. It COMPLEMENTS the
  > frontend's own self-gate ([[frontend-port]] §4) — never replaces it. Report-only:
  > surface drift + broken/obscured interactions; never edit application source.

!!! Uses `agent-browser` (R13) to drive a REAL browser against the running app — plus
    Playwright `toHaveScreenshot` / pixelmatch for the pixel diff. Diff images offload to
    `.ai_log/` and hand on as PATHS (R15: promote durable design decisions to `docs/design/`).
!!! Stack facts — dev server command + URL, per-PR preview scheme, seed accounts, settle
    signal — resolve from `docs/project_config/info.md` `{config.frontend_runtime}`.

---

## Steps

1. **RESOLVE THE ORACLE.** For the pages in scope, resolve the ONE canonical frozen oracle
   per page via `docs/design/oracle-manifest.json` ([[baseline-and-oracle]]), plus
   `design-tokens` + `design-system.md` and the per-breakpoint threshold from the design
   spec's visual acceptance contract. If NO renderable oracle / baseline exists (design
   phase skipped — the migration case), STOP and establish one per [[baseline-and-oracle]];
   never silently pass (`[NO-ORACLE]`). A missing pixel BASELINE never excuses skipping the
   run — the completeness census (step 5) runs against the oracle's STRUCTURE and needs no
   baseline PNG.

2. **ENUMERATE THE MATRIX.** Every built page × every access state it is reachable in (the
   project's access states, per `{config.frontend_runtime}` / the design spec) × the pinned
   breakpoints (default 375/768/1024/1440). A page proven at one width/state is not proven.

3. **START THE APP + SIGN IN PER STATE.** Ensure the target is up (the dev server per
   `{config.frontend_runtime}`, or the per-PR preview for prod-only surfaces). Reach each
   access state with the seeded fixture accounts named in `{config.frontend_runtime}` —
   over the REAL login flow, never state injection.

4. **CAPTURE.** For each matrix cell, drive `agent-browser`: navigate, set the viewport
   width, wait for fonts + the UI framework's settle signal (per
   `{config.frontend_runtime}` — e.g. LiveView `phx-connected` + no pending patches;
   Hotwire Turbo settle; hydration complete — avoids FOUT/animation false-diffs), and
   screenshot the full page. Record console/network signals — a JS/framework error or a
   404 asset is itself a finding.

5. **COMPLETENESS CENSUS FIRST — no pixel baseline required.** Build the oracle's ordered
   region/element inventory (the designer's `docs/design/<page>-inventory.md`; else derive
   it live from the frozen oracle), walk the BUILT page's DOM, tick each region/element off
   by its `data-test` hook. Emit the census table (`region → present? → order-ok?`). ANY
   whole oracle region/interactive element MISSING = Blocker; a dropped sub-part /
   reordered / extra region = Major. A page that fails the census is already
   `DESIGN-DIFF: reject` — do NOT spend a pixel diff on an incomplete page. This is the
   step that catches whole-missing sections a soft/absent pixel diff hides. Mechanics:
   [[region-census]].

6. **PIXEL-DIFF vs the baseline (only after the census is 100%).** Compare each screenshot
   to the frozen baseline at that breakpoint (Playwright `toHaveScreenshot` / pixelmatch).
   Over the threshold → FAIL with the diff % and the triptych (baseline | actual | diff) to
   `.ai_log/phase-<N>-design-diff-<page>-<state>-<bp>.png`. The pixel diff REFINES a
   census-complete page; it never substitutes for the census.

7. **RULE-CHECK the oracle rules** (catches drift a pixel diff can miss + explains a FAIL):
   token conformance (every color/space/radius traces to a named token in the project's
   declared token source, mirrored by `docs/design/design-tokens` — no raw value where a
   token exists; never assume a utility-framework pipeline), the type scale/weight/
   line-height, the 8pt spacing grid, and the 60/30/10 color balance. Detail:
   [[fidelity-checks]].

8. **HIT-TEST interactions encountered while capturing.** If a control is present but
   covered (overlay / cookie banner / z-index / pointer-events), flag
   `[DESIGN-DIFF-INTERACTION]` (Blocker) — the same clickability hit-test the project's
   e2e test-conventions skill enforces.

9. **CLASSIFY + REPORT.** Assign each finding a category + severity ([[fidelity-checks]]),
   fill the per-page × state × breakpoint matrix (census result per cell), and emit the
   verdict per `FORMAT.md`: `DESIGN-DIFF: pass` (census 100% AND all cells under threshold,
   no Blocker/Major) or `DESIGN-DIFF: reject` (name the failing pages + missing regions).
   On the pipeline verify path this contributes a `GATE: reject` — same weight as a
   functional-invariant violation.

10. **ROUTE, don't fix.** Build drift + missing regions → the frontend dev (fix by porting
    the oracle — [[frontend-port]]); a legitimate design change → the designer (REFRESH the
    oracle — [[baseline-and-oracle]]). Promote any accepted deviation / refreshed baseline
    to `docs/design/` (R15). This playbook never edits application source.
