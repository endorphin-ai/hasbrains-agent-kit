---
id: frontend-port
title: CONSUMER — consume the acceptance contract, port the oracle 1:1, self-gate census→DOM→pixel
summary: The frontend dev's playbook — read the six binding inputs from the design spec + oracle-manifest.json, verify token parity on the project's single styling source, transcribe the oracle in two passes (static 1:1, then interactivity without DOM change), self-gate every component AND assembled page/state with census→DOM→pixel until census 100% + under threshold, report evidence, write back the docs/frontend/ KB + deviations ledger. What the frontend owes the designer, made mechanical.
tags: [contract/consumer, contract/port, contract/self-gate]
aliases: [port the oracle, consume the contract, two-pass port, visual regression port, port rule]
load_when: Building or fixing a page that has a frozen oracle + a visual acceptance contract.
links: [[contract-and-communication]], [[region-census]], [[fidelity-checks]], [[designer-handoff]]
---

<!-- Related notes: [[contract-and-communication]] · [[region-census]] · [[fidelity-checks]] -->

TASKLANG
TYPE WORKFLOW

IDENTITY "Frontend Port Playbook (consumer side of the contract)"
  > The consumer side: how the frontend dev builds to the frozen baseline and PROVES the
  > match before handing off. PORT, don't re-derive — authoring a page fresh from memory
  > is what drops whole regions. Order: consume → parity → PASS A → PASS B → gate →
  > assemble → re-gate → report + KB write-back. Stack facts (template language, binding
  > whitelist, token source, settle signal) resolve from `{config.frontend_runtime}`.

---

## Steps

0. **CONSUME the contract first.** From the design spec + `docs/design/oracle-manifest.json`,
   read and record the SIX binding inputs:
   1. the **canonical oracle file** (resolved via the manifest — never pick among candidates),
   2. the **baseline renders** dir,
   3. the **region/element inventory** (`docs/design/<page>-inventory.md`),
   4. the **pinned breakpoint widths**,
   5. the **pixel-diff threshold** per breakpoint (+ named exclusions),
   6. the **PORT RULE** (the template-language binding whitelist).
   If ANY is missing → `[CONTRACT-GAP]`: ask the designer / the orchestrator
   ([[contract-and-communication]] §4). Do not guess a threshold, invent styling, or pick
   an oracle yourself.

1. **VERIFY TOKEN PARITY before porting.** The oracle and the build must render from the
   project's ONE declared token source per `{config.frontend_runtime}` (e.g. CSS custom
   properties in `:root`, a utility-framework config, a CSS-in-JS theme — read the
   declaration, never assume which kind). Render one ported region and confirm a token
   (e.g. `var(--cta)`) resolves to the SAME computed value the oracle shows. If a token is undefined or diverges, fix the token source FIRST —
   porting onto a divergent token source guarantees a failed diff everywhere. Load the SAME
   fonts (`@font-face` + `font-display`) the frozen oracle self-hosts. Copy the oracle's
   literal styles verbatim; reference token NAMES, never raw values where a token exists;
   never introduce a second styling source.

2. **PASS A — static 1:1 port (no logic).** Open the canonical oracle and TRANSCRIBE it
   element-by-element into the project's template language (typically a near-superset of
   HTML — copy the markup, then apply only the mechanical escaping/attribute mapping the
   language requires, e.g. JSX's `class`→`className`):
   - Preserve **every tag, style, class, attribute** exactly; same DOM tree, same order,
     same `data-test` hooks.
   - **No** dynamic values, **no** event bindings, **no** component extraction, **no**
     cleanup, **no** "simplify".
   - **NEVER** redesign, swap classes, collapse/merge containers, reorder regions, or
     substitute markup-changing components.
   - Gate PASS A at the static level before adding logic (cheap to diff, easy to localize).

3. **PASS B — interactivity without touching layout.** Layer behavior onto the frozen
   markup WITHOUT changing the rendered DOM/CSS: inject ONLY the stack's dynamic bindings
   per the PORT RULE whitelist — dynamic values/interpolation, event/controller bindings,
   iteration for repeated regions, conditionals for stateful regions (examples per stack in
   `{config.frontend_runtime}`: LiveView `{@assigns}` + `phx-*`; Hotwire instance vars +
   Turbo/Stimulus `data-*`; React props + handlers). Extract reusable components ONLY where
   the extraction emits the IDENTICAL markup it replaced — extraction is a refactor of
   source, not of output. Gating-aware components take entitlement/locked state IN as
   props/attrs — they never read session state or call the authz layer themselves. Every
   data-bearing component renders loaded/loading/empty/error + any locked branch the spec
   defines.

4. **SELF-GATE per component/page — census FIRST, then DOM, then pixel.** Loop until green:
   1. **Completeness census** ([[region-census]]): every inventory region + interactive
      element PRESENT in the build, in order, none extra — ticked off by `data-test` hook.
      A whole missing region is a BLOCKING defect. Census must be 100% before spending a
      DOM or pixel diff. (Same census the verifier runs — pass it here first.)
   2. **DOM diff:** compare the built tag tree + per-node class/style lists against the
      oracle. Catches dropped attrs, tag swaps, reordered/missing nodes, missing hooks —
      failures a pixel diff can miss or mislocate. Any structural delta = fail; fix.
   3. **Pixel diff per pinned breakpoint:** screenshot built page vs baseline render
      (agent-browser, or Playwright `toHaveScreenshot()` / pixelmatch / odiff with
      `maxDiffPixelRatio` = the contract threshold). Feed the diff regions back, fix the
      cause (usually a parity gap or a stray class), re-render, re-diff.
   4. **Loop** until census 100% + DOM match + every breakpoint under threshold. Never
      advance with an open miss — drift compounds. Contract-EXCLUDED regions are masked and
      recorded as WAIVED diffs with reasons — never silently widen the threshold.

5. **RE-RUN the gate on ASSEMBLED pages.** A component passing in isolation can drift once
   composed into the real page (layout context, wrapper classes, live/pushed content).
   After pages are wired, re-run census→DOM→pixel on each FULL page in EACH access state
   the project defines (including any locked/paywall variant and populated dashboards), at
   all pinned breakpoints. The match must hold end-to-end.

6. **PROVE the interactions.** Before reporting done, drive a real browser (agent-browser,
   R13): for each built page × each reachable access state, CLICK every control (links,
   buttons, menu open + items, form submit, toggles, modal open/close) AND hit-test real
   clickability (`elementFromPoint` at the control's centre resolves to the control, not an
   overlay); walk the full UI-reachable entity lifecycle (create → read → edit → delete
   where the entity supports it). Never report done with an unclickable, obscured, or dead
   control (R9).

7. **REPORT the evidence + WRITE BACK the KB.** Hand back per page per breakpoint: census
   result, DOM-check pass, final pixel-diff %, waived diffs + reasons, interaction-proof
   matrix — evidence screenshots to `.ai_log/`, paths + key fields to pipeline-state (R17).
   Then update `docs/frontend/`: one atomized file per new/changed reusable component
   (path, prop/slot contract, variants, states, `data-test` hooks, where used), the
   page→component map, and the **deviations ledger** in `design-system-in-use.md` — every
   departure from the design library recorded and raised to the designer, never silently
   shipped ([[contract-and-communication]] §4). A page with a census miss, over threshold,
   or an unexplained DOM delta is NOT done — it is a build defect, not a redesign
   opportunity.

## The fidelity loop (measurable 1:1)

consume the contract + manifest → verify ONE token source → PASS A (static transcription) →
PASS B (interactivity, DOM unchanged) → census→DOM→pixel per component (loop) → assemble →
re-gate full pages × states × breakpoints → prove interactions → report evidence + KB
write-back + deviations ledger.
