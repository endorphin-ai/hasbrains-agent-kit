# Honest Rendering — a page must not claim more than its data supports

> **Load when**: reviewing or designing any page that presents generated/derived content — a
> dashboard, a document renderer, a list view, a report, a chart. Also load before writing a review
> finding about "polish", to check whether the real defect is an integrity one.
> **Companion**: [verification-instruments.md](verification-instruments.md) — that file is about not
> lying to YOURSELF; this one is about the page not lying to the USER.

---

## The principle

Every affordance on a page is a CLAIM. A count claims it counted everything. A breadcrumb claims a
path exists. A filter claims it can filter. A "complete" badge claims something was checked. A URL
claims it names the state on screen.

**When the claim outruns the data, the user's model of the system breaks — and unlike a visual flaw,
they cannot see that it happened.** A cramped margin is noticed and forgiven. A count that is quietly
wrong is trusted and acted on. So: an integrity defect outranks a cosmetic one, always, even when the
cosmetic one is uglier.

This is the UX-facing companion to the renderer law (*the site is a renderer, never a source*): if a
page shows something wrong, either the source document is wrong — fix the source — or the renderer is
claiming something the source never said. Never quiet a check by writing placeholder content into the
source.

---

## The violation catalogue

Nine shapes, all found on ONE documentation site in one review session. Use it as a checklist.

### 1. A status badge with nothing behind it

A "template complete ✓" pill rendered for document types that had **no template defined** — the check
compared against an empty spec and passed vacuously. Every such document displayed a green tick that
meant nothing.

> **Test**: for every pass/complete/verified indicator, name the rule it evaluated. If there is no
> rule, the indicator must not render — absence of a check is not a pass.

### 2. Authored content counted as documentation

Fields explicitly authored `n/a` / `none` / `TBD` were counted as "documented", inflating a
completeness figure. The author said *there is nothing here*; the page reported *this is filled in*.

> **Test**: does the completeness metric distinguish "answered" from "answered with nothing"? Treat a
> placeholder value as absent, and say so in the UI ("3 fields not documented"), not silently.

### 3. A headline that counts a subset of what is below it

A landing page's own summary number omitted one whole group that was rendered directly beneath it —
so the page contradicted itself within a single fold.

> **Test**: recompute every headline number from the groups actually rendered on that page, in the
> same pass that renders them. A number computed from a different query than the list it heads WILL
> drift.

### 4. A breadcrumb rooted where the document never was

Detail pages inherited a "Sprints ›" root from a shared template, for document types that belong to no
sprint. The trail offered a parent that was not the parent.

> **Test**: a breadcrumb crumb must be derivable from THIS record's own relationships. If the parent is
> conditional, render the crumb conditionally.

### 5. A control that cannot do what it offers

A five-control filter bar over a three-item collection, where three of the selects had exactly one
option. The chrome promised slicing that the data could not deliver, and cost a screenful of space to
say nothing.

> **Test**: a filter renders only when it has **≥ 2 real choices**. Same for sort, pagination, view
> switchers, and tabs. Scale the chrome to the data, not to the template.

### 6. A URL that names a state the page is not in

`?view=<x>` survived navigation onto types that have no such view, so the address bar described a
layout the user was not looking at — and sharing the link reproduced the wrong thing.

> **Test**: on every route change, strip query parameters the destination does not honour. The URL is a
> claim about the current state; keep it true, and it stays shareable.

### 7. Authored relationships silently dropped

The generator stripped a `## Linked Documents` section on the assumption that page chrome would render
those links — true for six document types, false for the two newest. The links vanished from both.

> **Test**: when chrome replaces authored content, gate the strip on the chrome ACTUALLY EXISTING for
> that type — an allowlist, never a blanket assumption. Adding a type must not silently delete content.

### 8. Derived labels that break on new data

Introducing a new document type produced an undefined entry in a label map, which threw inside a
counting helper and blanked an **unrelated** page. A content addition became a site outage.

> **Test**: every derived map (labels, icons, plurals, colours, hues) needs a defined fallback. Then add
> the smallest new content item of each kind and load the pages that do not mention it.

### 9. Meaning encoded twice, differently

A donut coloured its segments by POSITION while the same statuses were coloured semantically by pills
everywhere else — so "done" was green in one place and whichever hue slot 3 held in another.

> **Test**: status→colour is ONE map, imported by every consumer. If a chart colours by index, it is
> decorating, not encoding — and it must not sit next to something that encodes.

---

## Presenting derived data honestly

Beyond the catalogue, four rules that came out of the same session:

- **A metric may not be more precise than its source.** If only 6 of 39 records carry the field a
  cost-per-item chart needs, the chart says *6 of 39* on its face — or it does not ship. Report the
  denominator with the number.
- **Structured data deserves structure.** A raw JSON dump on a user-facing page is an admission that
  nobody decided what it meant. The same object became four charts, a ten-column table with a totals
  row, and the JSON folded away underneath — the fold is fine, the dump as the PRIMARY presentation is
  not.
- **Units in the reader's terms.** 1_284_991 tokens is not readable; `1.28M` is. `$0.4127` is not
  comparable at a glance; `$0.41` is. Format at the point of display, keep full precision underneath.
- **Labels come from the canonical source, not from the render order.** Phases labelled a/b/c/d because
  a chart enumerated them alphabetically, when the pipeline defines 0/1/2/…/4.5. Read the identifier
  from where it is DEFINED; a label invented by the renderer is a claim the system never made.

---

## Where this sits against visual craft

Both matter, and this file does not license ugly work — the same session's air pass (gutter ladder,
monotonic bottom room, label→title breathing) is real UX and was the owner's first complaint.

The ordering rule is only about which to fix FIRST when both are open, and about what counts as
"done": a page can be beautiful and dishonest, and it is not finished. When reporting, separate them
explicitly — *integrity findings* and *craft findings* — so the reader can act on the dangerous ones
without wading through spacing notes.
