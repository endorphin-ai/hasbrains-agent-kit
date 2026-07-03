---
id: region-census
title: The region/element completeness census — the FIRST check (catches whole-missing sections)
summary: How to census a built page against the oracle's region/element inventory BEFORE any pixel diff — build the oracle list (designer inventory or derive live), walk the built DOM, tick each region/element off by data-test hook, and FAIL on any missing/reordered/extra region. Run by BOTH the frontend self-gate and the verifier. Needs no pixel baseline; catches whole-missing sections a soft/mis-baselined pixel diff hides.
tags: [contract/census, contract/checks, contract/completeness]
aliases: [completeness census, region census, presence check, missing section, element inventory, what's missing]
load_when: Gating a built page against the oracle; deciding PASS/FAIL; a whole section may be missing; the pixel diff "looks fine" but the page feels incomplete.
links: [[fidelity-checks]], [[design-diff]], [[frontend-port]], [[baseline-and-oracle]], [[contract-and-communication]], [[designer-handoff]]
---

# The region/element completeness census

> A pixel diff answers "did the pixels that ARE there move?" The census answers the prior,
> more important question: **"is everything that should be there, there?"** These are
> different failures. A real build once passed as "close enough" while missing an ENTIRE
> page header, an ENTIRE marquee band, and an ENTIRE CTA sidebar card — because there was
> no baseline PNG to pixel-diff against, so the pixel step silently no-op'd and nothing
> else asked "what's missing?" The census asks it, mechanically, every run — and it needs
> NO pixel baseline to run. It runs TWICE by design: the frontend passes it in its
> self-gate ([[frontend-port]] §4) BEFORE handoff; the verifier re-runs it independently.

## Why census FIRST (before pixel diff)

- A pixel diff is only trustworthy with a correctly-aligned, correctly-scaled baseline.
  Absent one, or when the built page scrolls to a different height, a whole missing section
  can hide inside an "acceptable" diff %, or the diff step is skipped entirely.
- The census depends on NO pixel baseline — only on the oracle's structure. So it works
  even in the migration / no-baseline case, and it localizes the defect to a NAMED region
  ("`marquee-band` absent") instead of an unhelpful "3.2% of pixels changed."
- A page that fails the census is already a reject — do not spend a pixel diff on an
  incomplete page.

## The census, step by step

1. **Build the ORACLE list.** Prefer the designer's emitted inventory
   (`docs/design/<page>-inventory.md`, per [[designer-handoff]] step 4): an ordered list of
   every REGION (header, hero/featured block, section headers, content grid + each card's
   sub-parts, pagination, sidebar widgets, banners, footer) and every INTERACTIVE element
   (links, buttons, menus, forms, toggles), each with its `data-test` hook and key measured
   props. If no inventory file exists, DERIVE it live: open the frozen canonical oracle
   (resolved via the manifest — [[baseline-and-oracle]]) in `agent-browser`, snapshot its
   DOM, and emit the ordered region/element list yourself. Record which source you used.

2. **Walk the BUILT page's DOM.** Snapshot the running build (`agent-browser`) in the
   matching access state. Match each oracle entry to a built node by its `data-test` hook
   first; fall back to region role + heading/label text only when no hook exists (and file
   that missing hook as a `[DESIGN-DIFF-CENSUS]` Minor so the frontend adds it — per the
   three-way hook contract, [[contract-and-communication]] §5).

3. **Emit the census table** — one row per oracle entry:

   | Oracle region / element | data-test | Present? | Order OK? | Verdict |
   |-------------------------|-----------|----------|-----------|---------|
   | page-header (eyebrow+h1+subtitle) | `blog-page-header` | ❌ | — | **Blocker — whole region missing** |
   | featured card → badge-on-image | `article-tier-badge` | ❌ | — | Major — sub-part dropped |
   | marquee band | `tag-marquee` | ❌ | — | **Blocker — whole region missing** |
   | sidebar → membership CTA | `go-member-card` | ❌ | — | **Blocker — whole region missing** |
   | article grid | `blog-article-list` | ✅ | ✅ | pass |

4. **Also flag EXTRAS.** A region in the build that the oracle does NOT have (a stray
   widget, a duplicated block) is a census FAIL too — Major — because it is drift from the
   approved design.

## Classify (feeds the severity model in [[fidelity-checks]])

- **Whole region / whole interactive element missing** → **Blocker** (page header, marquee,
  a CTA card, a nav, a control the oracle has).
- **Region present but a SUB-PART missing** (badge, meta row, avatar, thumbnail), a region
  **reordered**, or an **extra** region → **Major**.
- **Missing `data-test` hook on an otherwise-present element** → **Minor** (file it; it
  blocks a reliable future census).

Any Blocker/Major from the census → the page FAILs → `DESIGN-DIFF: reject`. Report-only on
the verifier path: route the missing regions to the frontend dev (build them by porting the
oracle — [[frontend-port]]), never edit application source here.

## Guardrail

Do NOT "pass" a page because the regions that ARE present look pixel-perfect. Pixel-perfect
on 60% of the page is still a reject if 40% of the oracle's regions are absent.
Completeness is a gate condition equal to pixel fidelity, checked first.
