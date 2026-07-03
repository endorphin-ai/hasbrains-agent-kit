---
id: designer-handoff
title: PRODUCER — freeze the approved mockup into the canonical oracle + write the acceptance contract
summary: The designer's handoff playbook — after the design approval gate passes, freeze the approved mockup (pin widths, self-host fonts, snapshot baseline renders), register it as THE canonical oracle in oracle-manifest.json, emit the region/element inventory with data-test hooks, declare token parity on the project's single styling source, write the four-part visual acceptance contract into the design spec, and hand off PATHS. What the designer owes the frontend, made mechanical.
tags: [contract/producer, contract/freeze, contract/handoff]
aliases: [freeze the baseline, designer handoff, oracle registration, visual acceptance contract, token parity declaration]
load_when: An approved mockup must become a measurable build target the frontend is held to.
links: [[contract-and-communication]], [[baseline-and-oracle]], [[frontend-port]], [[region-census]]
---

<!-- Related notes: [[contract-and-communication]] · [[baseline-and-oracle]] -->

TASKLANG
TYPE WORKFLOW

IDENTITY "Designer Handoff Playbook (producer side of the contract)"
  > Runs AFTER the design approval gate (the user approved the fully-styled mockup). The
  > mockup looking right in a browser is NOT a handoff — without these steps the build
  > silently re-styles it (different fonts, a second styling source, collapsed DOM) and
  > the delivered page drifts from what the user approved. These steps make "1:1"
  > MEASURABLE. Stack facts resolve from `{config.frontend_runtime}`.

---

## Steps

1. **FREEZE the approved mockup.** Remove every source of render drift so the same file
   renders identically everywhere:
   - **Pin the breakpoint widths** the baseline is captured at (default 375/768/1024/1440;
     record the pinned set in the design spec — it becomes the diff matrix for everyone).
   - **Self-host / inline the fonts.** No CDN font `<link>` (network-dependent, FOUT,
     version drift). Inline `@font-face` with a `data:` URI OR commit the font files and
     reference them relatively. The build must load the SAME font files with the same
     `font-display`. A wrong font = a failed diff everywhere text appears.
   - **Make it self-contained + offline.** Inline CSS, relative asset paths, renders via
     `file://` with no network; no JS that changes layout after load (or snapshot
     post-settle).
   - **Mark it frozen.** Top-of-file comment: `<!-- FROZEN BASELINE — approved <date>;
     do not edit. Build is diffed against this. -->`. A later design change starts a NEW
     approval loop ([[baseline-and-oracle]] REFRESH), never an in-place edit.

2. **SNAPSHOT the baseline renders.** Capture the frozen mockup at each pinned width
   (agent-browser / Playwright) → `docs/design/baseline/<page>-<width>.png`. These PNGs are
   the pixel target the build's screenshots are compared to.

3. **REGISTER it as THE canonical oracle.** `docs/design/` accumulates many candidate files
   per page (mockups, variants, canvas exports). Downstream MUST NOT guess. Add/update
   `docs/design/oracle-manifest.json`: `route → { oracle, baseline_dir, inventory,
   access_states, required_states, frozen: <date> }` — exactly ONE oracle file per
   route/state. A route without a manifest entry is a `[NO-ORACLE]` finding waiting to
   happen.

4. **EMIT the region/element inventory** — `docs/design/<page>-inventory.md`: an ORDERED
   list of every REGION (nav, page header, hero/featured block, section headers, content
   grid + each card's sub-parts, pagination, sidebar widgets, banners, footer, …) and every
   INTERACTIVE element (links, buttons, menus, forms, toggles, modals), each with its
   stable kebab-case `data-test` hook and key measured props (font/size/color/gap/padding).
   This is the census source of truth the frontend ports against and the verifier checks
   completeness against — its absence is how builds ship missing whole regions.

5. **DECLARE TOKEN PARITY.** The mockup and the app MUST render from ONE token source —
   whatever the project declares in `{config.frontend_runtime}` (e.g. CSS custom
   properties in the app stylesheet `:root`, a utility-framework config, a CSS-in-JS
   theme), mirrored by `docs/design/design-tokens`. Author the oracle in that SAME idiom
   (token references + literal styles; no ad-hoc raw values where a token exists; if a
   value isn't yet a token, ADD it to the source). Same fonts, same base/reset so text
   metrics match. State it as a short contract in the design spec: "the build MUST reuse
   THESE tokens + THESE fonts; it MUST NOT introduce a second styling source." Because the
   oracle is in the app's own idiom, the frontend ports by COPYING literal styles — the
   surest route to a pixel match.

6. **WRITE the four-part VISUAL ACCEPTANCE CONTRACT** into a `## Visual Acceptance
   Contract` section of `docs/design/<feature>-design-spec.md`:
   - **(a) PORT RULE** — the template language is typically a near-superset of HTML: the
     frontend TRANSCRIBES the oracle verbatim (same DOM tree, order, styles, `data-test`
     hooks), applying only the mechanical escaping/attribute mapping the language requires
     and injecting ONLY the stack's dynamic bindings (per `{config.frontend_runtime}`);
     NEVER redesign/restyle/collapse/reorder — a rendered-DOM/CSS change is a violation
     even if it "looks the same".
   - **(b) COMPLETENESS CENSUS** — bind the build to the step-4 inventory: every region +
     interactive element present, in order, none extra; a whole missing region is a
     BLOCKING defect independent of the pixel diff ([[region-census]]).
   - **(c) Per-breakpoint pixel-diff threshold** — the pass bar at each pinned width
     (e.g. `< 0.1%` changed pixels), plus explicitly EXCLUDED regions (live charts, video,
     dynamic timestamps) and why.
   - **(d) Tool + DOM preservation** — name the comparison tool (Playwright
     `toHaveScreenshot()` / pixelmatch / odiff; `maxDiffPixelRatio` = the threshold) AND
     the DOM-structure check: the built page's tag/class/`data-test` skeleton matches the
     frozen oracle, in order — catches a "looks identical but markup rewritten" port.

7. **HAND OFF PATHS.** Record in pipeline-state + the session report: the oracle path, the
   manifest entry, the baseline dir, the inventory path, the spec section — PATHS, not
   blobs (R17). The frontend reads these as its six binding inputs ([[frontend-port]] §0).

## The fidelity loop (what makes "1:1" enforceable)

approved mockup (approval gate) → FREEZE (pin widths · self-host fonts · snapshot baselines ·
register the canonical oracle in `oracle-manifest.json` · emit `<page>-inventory.md`) →
declare TOKEN PARITY (one styling source) → write the acceptance contract (PORT RULE ·
CENSUS · threshold · tool + DOM check) → build ports the oracle 1:1 → census → diff →
census 100% + under threshold + DOM preserved = accepted; a missing region or
over-threshold = a build defect, not a redesign.
