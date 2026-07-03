# Output Format — designer-frontend-contract

Three report shapes, one per side of the contract. All evidence images offload to
`.ai_log/` and are handed on as PATHS (key fields + paths recorded in pipeline-state, R17).
Stack values (app-under-test URL, preview scheme, seed accounts) resolve from
`docs/project_config/info.md` `{config.frontend_runtime}` — shown below as examples.

## A. PRODUCER — the handoff manifest (designer → frontend)

Emitted at design-phase completion (paths, not blobs):

```markdown
## Design handoff — <feature>
- Canonical oracle: docs/design/<page-oracle>.html   (FROZEN <date>, registered in oracle-manifest.json)
- Baseline renders: docs/design/baseline/<page>-{375,768,1024,1440}.png
- Region/element inventory: docs/design/<page>-inventory.md   (N regions, M interactive elements, data-test hooks named)
- Token parity: <the declared token source, e.g. app stylesheet :root custom properties> — mirrored by docs/design/design-tokens
- Visual acceptance contract: docs/design/<feature>-design-spec.md § Visual Acceptance Contract
  (PORT RULE · census · threshold <X% per breakpoint> + exclusions · tool + DOM check)
- Access states designed: <the project's access states>   · Required component states: <loading/empty/error/locked/…>
```

## B. CONSUMER — the port-evidence report (frontend → gate)

Emitted at build-phase completion, per page:

```markdown
## Port evidence — <page>
| Breakpoint | Census | DOM check | Pixel diff | Waived |
|------------|--------|-----------|------------|--------|
| 375  | 24/24 | pass | 0.04% | — |
| 768  | 24/24 | pass | 0.06% | — |
| 1024 | 24/24 | pass | 0.03% | chart region (contract exclusion) |
| 1440 | 24/24 | pass | 0.05% | — |
- Assembled-page re-gate: pass in each access state (incl. locked/paywall variants)
- Interaction proof: every control clicked + hit-tested per state — matrix in .ai_log/<...>.md
- KB write-back: docs/frontend/components/<new-components>.md · page-component-map updated
- Deviations ledger: <none | N entries in docs/frontend/design-system-in-use.md — raised to the designer>
```

## C. VERIFIER — the design-diff report

### C1. Oracle resolution (state it up front)

```markdown
- Canonical oracle: docs/design/<page-oracle>.html (resolved via docs/design/oracle-manifest.json) + design-tokens + design-system.md
- Region/element inventory: docs/design/<page>-inventory.md (else DERIVED-LIVE from the oracle DOM)
- Baseline status: FROZEN (design-phase approved) | ESTABLISHED-THIS-RUN (captured + acknowledged) | REFRESHED (design legitimately changed) | NO-ORACLE (blocking)
- App under test: <dev-server URL per {config.frontend_runtime}>  |  <per-PR preview URL>
- Breakpoints: <pinned widths, default 375 / 768 / 1024 / 1440>
- Access states covered: <the project's access states>
- Per-breakpoint pixel-diff threshold: <X%  (from the design spec's visual acceptance contract)>
```

### C2. Completeness census (FIRST — before the pixel matrix)

```markdown
Census source: <inventory file | DERIVED-LIVE>   ·   Census: 21/24 regions present — FAIL

| Oracle region / element        | data-test          | Present? | Order OK? | Verdict |
|--------------------------------|--------------------|----------|-----------|---------|
| page-header (eyebrow+h1+sub)   | blog-page-header   | ❌       | —         | Blocker — whole region missing |
| featured card → tier badge     | article-tier-badge | ❌       | —         | Major — sub-part dropped |
| sidebar → membership CTA       | go-member-card     | ❌       | —         | Blocker — whole region missing |
| article grid                   | blog-article-list  | ✅       | ✅        | pass |
```

- A page not 100% on the census is already `DESIGN-DIFF: reject` — the pixel matrix below
  refines a census-complete page; it never overrides a census miss. Detail:
  `references/region-census.md`.

### C3. Per-page × state × breakpoint matrix (the core result)

```markdown
| Page | Access state | 375 | 768 | 1024 | 1440 | Verdict | Diff image |
|------|--------------|-----|-----|------|------|---------|------------|
| Home | anonymous | PASS | PASS | PASS | PASS | PASS | — |
| Reader | entitled | PASS | PASS | 0.9% FAIL | PASS | FAIL | .ai_log/phase-5-design-diff-reader-entitled-1024.png |
```

- One row per page × access state; one cell per breakpoint (PASS or the diff % on FAIL).
- FAIL cells link the diff image (`.ai_log/…png`) — the baseline / actual / diff triptych.

### C4. Fidelity findings (what drifted)

```markdown
| Finding | Page/State/BP | Category | Severity | Oracle says | Built shows | Evidence |
|---------|---------------|----------|----------|-------------|-------------|----------|
| [DESIGN-DIFF-CENSUS] page-header region absent | blog/anon/all | completeness | Blocker | header (eyebrow+h1+subtitle) | nothing rendered | .ai_log/…png |
| [DESIGN-DIFF-SPACING] card gap 12px vs 16px (off the 8pt grid) | reader/entitled/1024 | spacing | Major | 16px (--space-4) | 12px | .ai_log/…png |
| [DESIGN-DIFF-COLOR] CTA uses raw hex not the token | pricing/anon/375 | color/token | Major | var(--cta) | #2563EB | .ai_log/…png |
| [DESIGN-DIFF-INTERACTION] avatar menu never opens (obscured) | any/entitled/1440 | interaction | Blocker | menu opens on click | overlay intercepts click | .ai_log/…png |
```

- Categories: `completeness` (census) · `layout` · `spacing` (8pt grid) · `color` (palette +
  60/30/10) · `type` (scale/weight/line-height) · `token` (raw value vs a named token in the
  declared token source) · `dom` (structure/hook drift) · `interaction` (broken/obscured —
  the e2e test-conventions hit-test).
- Severity: `Blocker` (broken interaction / gated-content-adjacent / whole region missing) ·
  `Major` (visible drift over threshold, sub-part missing, DOM delta) · `Minor`
  (sub-threshold nit / missing hook — noted, not gated).

### C5. Gate verdict

```markdown
DESIGN-DIFF: pass    — census 100% AND DOM preserved AND every page × state × breakpoint under threshold; no Blocker/Major finding
DESIGN-DIFF: reject  — <N> page(s) with a census miss, DOM delta, over-threshold drift, or a broken/obscured interaction; see findings
```

- On the pipeline verify path, `DESIGN-DIFF: reject` contributes a `GATE: reject` with the
  failing pages named (same weight as a functional invariant violation).
- Every finding is a ROUTED action: → frontend dev (fix the build) or → designer (refresh
  the oracle). Report-only.

### C6. Diff-image manifest (evidence, offloaded to `.ai_log/`)

```markdown
- .ai_log/phase-<N>-design-diff-<page>-<state>-<bp>.png   (baseline | actual | diff triptych)
```

Durable design decisions (a refreshed baseline, an accepted deviation) are PROMOTED to
`docs/design/` per R15 — never left only in `.ai_log/`.
