---
id: contract-and-communication
title: The designer ↔ frontend contract — artifacts, storage, communication, and the data-test three-way
summary: The contract itself — what the designer owes the frontend and vice versa, the shared artifact/link graph, where every piece of data lives (docs/design/ library, docs/frontend/ KB, .ai_log/ evidence, pipeline-state paths), the communication protocol (handoff timing, ask-don't-guess, findings routing, deviations ledger, refresh loop), and the three-way data-test hook contract with QE. Tech-agnostic; stack facts resolve via {config.frontend_runtime}.
tags: [contract/roles, contract/storage, contract/communication, contract/handoff]
aliases: [the contract, handoff protocol, storage layout, who owes what, designer frontend collaboration, deviations ledger, data-test contract]
load_when: Deciding where an artifact lives, how the two roles hand off, who to ask or route a finding to, or what each side owes the other.
links: [[designer-handoff]], [[frontend-port]], [[design-diff]], [[baseline-and-oracle]]
---

# The designer ↔ frontend contract

> The collaboration is a CONTRACT between two producers of committed artifacts — never a
> verbal agreement, never "the mockup looked right". The designer turns an approved design
> into a measurable build target; the frontend turns that target into a running page and
> PROVES the match; an independent verifier re-proves it. Every obligation below is
> mechanical: it either exists as a committed file/check, or it is a `[CONTRACT-GAP]`.

## 1. What each side OWES the other

**The DESIGNER owes the frontend** (produced by [[designer-handoff]]):

1. **One canonical frozen oracle per page** — a self-contained, offline-renderable mockup,
   marked frozen, never edited in place after approval.
2. **The manifest entry** — `docs/design/oracle-manifest.json`: route → oracle file,
   baseline dir, inventory file, access states + required component states, frozen date.
   The frontend must never guess which of several candidate files is authoritative.
3. **Baseline renders** — static captures of the frozen oracle at each pinned breakpoint
   (`docs/design/baseline/<page>-<width>.png`) — the pixel target.
4. **The region/element inventory** — `docs/design/<page>-inventory.md`: an ORDERED list of
   every region and every interactive element, each with its `data-test` hook + key
   measured props. This is what makes "did the build render EVERYTHING?" mechanical.
5. **Token parity declaration** — the oracle is authored in the app's OWN styling idiom
   (the project's single declared token source, per `{config.frontend_runtime}`), so the
   frontend can copy literal styles instead of re-deriving them.
6. **The four-part visual acceptance contract** — written into the per-feature design spec:
   (a) PORT RULE, (b) completeness census, (c) per-breakpoint pixel threshold + named
   exclusions, (d) named diff tool + DOM-structure-preservation check.

**The FRONTEND owes the designer** (produced by [[frontend-port]]):

1. **A 1:1 port** — the oracle's DOM tree, order, styles, and `data-test` hooks preserved;
   only the stack's dynamic bindings injected. Never a reinterpretation.
2. **Self-gate evidence before handoff** — per page per breakpoint: census result, DOM-check
   pass, final pixel-diff %, waived diffs + reasons. Drift is a build defect to fix, not a
   redesign opportunity.
3. **The `docs/frontend/` KB write-back** — component inventory, page→component map, and a
   design-system-in-use POINTER back to `docs/design/` (never a copy/fork).
4. **A DEVIATIONS LEDGER** — every departure from the design library (a token that had to
   change, a spacing compromise, a state the design didn't cover) recorded in
   `docs/frontend/design-system-in-use.md` and raised back to the designer — never silently
   shipped.
5. **Preserved hooks** — every `data-test` hook the inventory names, unrenamed, unduplicated.
6. **Questions, not guesses** — a missing contract input is ASKED about (see §4), never
   guessed around.

**Symmetric obligations (both sides):**

- Consume the other side's artifacts by PATH from the committed tree; never work from a
  pasted blob or memory of a design.
- Keep your own library navigable (build-brain shape: lean map + atomized files) — the other
  side loads only what it needs.
- Neither side edits the other's artifacts: the frontend never edits `docs/design/`; the
  designer never edits application source. Requests cross the boundary as findings/asks.

## 2. STORAGE — where every piece of data lives

| Artifact | Path | Owner | Consumed by |
|----------|------|-------|-------------|
| Design system (palette/type/effects/AVOID/checklist) | `docs/design/design-system.md` | designer | frontend, verifier |
| Machine-readable tokens (mirror of the app's token source) | `docs/design/design-tokens.*` | designer | frontend (directly), verifier |
| Element/topic references | `docs/design/references/` | designer | frontend, future specs |
| Per-feature design spec (+ `## Visual Acceptance Contract`) | `docs/design/<feature>-design-spec.md` | designer | frontend, verifier, QE |
| Canonical frozen oracles (mockups) | `docs/design/<page-oracle>.html` | designer | frontend (ports), verifier (diffs) |
| Oracle manifest (route → oracle/baseline/inventory) | `docs/design/oracle-manifest.json` | designer | everyone — the resolver |
| Baseline renders per breakpoint | `docs/design/baseline/<page>-<width>.png` | designer | frontend self-gate, verifier |
| Region/element inventory | `docs/design/<page>-inventory.md` | designer | frontend census, verifier census |
| Frontend component KB (map + one file per component) | `docs/frontend/README.md` + `components/` | frontend | frontend (read-first), designer |
| Page → component map | `docs/frontend/page-component-map.md` | frontend | frontend, verifier |
| Design-system-in-use pointer + DEVIATIONS ledger | `docs/frontend/design-system-in-use.md` | frontend | designer (reviews deviations) |
| Diff images / screenshots / run evidence (throwaway) | `.ai_log/…` (git-ignored) | whoever ran | handed on as PATHS |
| Handoff keys + evidence paths | pipeline-state file | each phase | downstream phases |

Rules of the layout:

- **Durable → committed docs; throwaway → `.ai_log/`** (R15). The baseline is durable and
  lives in `docs/design/`; diff triptychs are evidence and live in `.ai_log/`, referenced by
  path. Anything durable that lands in `.ai_log/` gets PROMOTED.
- **Single source, pointers elsewhere** — tokens live ONCE (the app's declared token source,
  mirrored by `docs/design/design-tokens`); the frontend KB points back, never forks. A copy
  that can drift is a future contract violation.
- **Handoffs are lookups** (R17): each side records key fields + artifact paths in
  pipeline-state; the other side reads them from there — no giant inlined dumps between
  phases.

## 3. The LINK GRAPH (how artifacts reference each other)

```
design spec ──cites──▶ design-system.md + design-tokens + references/
     │ ── contains ──▶ ## Visual Acceptance Contract (thresholds, tool, exclusions)
     │
oracle-manifest.json ──resolves──▶ route → { oracle.html, baseline/, inventory.md, states }
     │
inventory.md ──enumerates──▶ regions + interactive elements, each ──carries──▶ data-test hook
     │
built page ──preserves──▶ the same DOM/styles/hooks ◀──asserts── DOM check + census
     │
docs/frontend/ KB ──points-back──▶ docs/design/ (design-system-in-use; deviations ledger)
```

Every reference is a relative path in a committed file. If the verifier (or QE, or a future
session) cannot navigate from a route to its oracle, inventory, and thresholds by following
committed links, the handoff is incomplete.

## 4. COMMUNICATION protocol

**Handoff timing.** The designer hands the freeze deliverables (oracle + manifest entry +
baselines + inventory + spec section) as PATHS at design-phase completion — recorded in
pipeline-state and the session report. The frontend's evidence report + KB write-back land
at build-phase completion. The verifier's report feeds the verify gate.

**Ask, don't guess.** If ANY of the six binding inputs ([[frontend-port]] §0) is missing —
no manifest entry, no inventory, no threshold, no pinned widths — the frontend STOPS and
asks the designer (via the orchestrator when in-pipeline), filing a `[CONTRACT-GAP]`. It
never guesses a threshold, invents styling, or picks an oracle among candidates. Same rule
for the verifier: an unresolvable oracle is `[NO-ORACLE]`, a blocking finding.

**Findings routing (the verifier never fixes):**

| Finding | Routes to | Action |
|---------|-----------|--------|
| Build drift / missing region / broken interaction | frontend dev | fix by porting the oracle; complete the linked Bug file |
| Legitimate design change (build is "wrong" on purpose) | designer | REFRESH the oracle: update mockup + tokens, re-freeze, re-run the approval gate ([[baseline-and-oracle]]) |
| Missing/ambiguous contract input | designer | declare it (manifest entry, inventory, threshold) |
| Design didn't cover a needed state (empty/error/locked…) | designer | extend the spec/oracle; frontend notes it in the deviations ledger meanwhile |
| PR review comment on visual fidelity | designer owns the answer; the code fix lands via the frontend dev | |

**The deviations ledger is the frontend's voice back.** When reality forces a departure
(a token that had to change, an impossible layout at a breakpoint, an uncovered state), the
frontend records it in `docs/frontend/design-system-in-use.md` — what deviated, why, where —
and the designer reviews it: either the design library absorbs the change (tokens/spec
updated, baseline refreshed) or the deviation is rejected and the build is corrected. A
silent deviation is a contract violation even when it looks better.

**Design changes flow forward, never sideways.** A frozen oracle is never edited in place;
a change starts a new approval loop and lands as a REFRESH. The frontend never "improves"
the design in code; the designer never patches application source.

## 5. The `data-test` three-way (designer · frontend · QE)

The stable `data-test` hook is the shared coordinate system of the whole contract:

1. **The designer NAMES the hooks** — the inventory records a stable kebab-case `data-test`
   for every region + interactive element (and the mockup carries them where practical).
2. **The frontend PRESERVES them** — the port keeps every hook; components pass `data-test`
   through their pass-through/global attrs so callers can attach markers; hooks are never
   renamed and never reused across two elements.
3. **QE (and the verifier's census/DOM check) SELECT on them** — `[data-test=…]`, never
   brittle text/CSS/position chains (per the project's e2e test-conventions skill).

A missing hook on a present element is a census **Minor** — filed so the frontend adds it;
it blocks reliable future censuses. The census matches oracle entries to built nodes by
hook FIRST, falling back to region role + text only where no hook exists.

## 6. Reusing this contract on another project/stack

Everything above is stack-free. The stack binds at exactly one point:
`docs/project_config/info.md` → `{config.frontend_runtime}` — dev server command + URL,
per-PR preview scheme, template language + its dynamic-binding whitelist, the UI settle
signal, the declared token source path, the seed accounts per access state, and the access
states themselves. Swap that config note (and the project's design library) to retarget;
this skill does not change. If a needed stack fact is missing from the config, ADD it there
(R14) — never hard-code it here or in an agent.
