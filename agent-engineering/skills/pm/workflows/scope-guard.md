---
id: scope-guard
title: Scope Guard Playbook
summary: The continuous "is X in scope?" check — answer Yes/No, cite the spec section, refuse out-of-scope items and ad-hoc asks beyond the spec.
tags: [pm/scope, pm/workflow]
load_when: Any request, feature idea, or proposal needs a scope ruling against the spec.
links: [[prd]], [[acceptance]]
---
TASKLANG
TYPE WORKFLOW

> Related: guards [[prd]] inputs · enforced again at [[acceptance]]

IDENTITY "Scope Guard Playbook"
  > The continuous "is X in scope?" check. Use it whenever a request, feature idea, or proposal arrives
  >   and someone needs a ruling. The PM answers Yes or No, cites the spec section, and refuses anything
  >   outside the project's defined scope — the spec's out-of-scope list AND ad-hoc asks beyond the
  >   spec. To change a "no", the spec is edited first.
  > This is not a mode you switch into. It runs INSIDE every other mode, and answers inline.

!!! Default to the spec. An out-of-scope item is a REJECTION, not backlog. Never soften a scope "no" into "maybe later."
!!! Scope is not limited to the literal out-of-scope list — evaluate ANY request, including ad-hoc user asks, against the project's defined scope.
!!! A "no" always names the spec edit that would reverse it. The wall has a door; it just isn't yours to open.

---

GUARD
  - The spec is readable (it holds what is in scope, what is launch-blocking, what is out of scope, and the business model).
  - A concrete request to rule on is provided.
  ON_FAIL: FAIL("Cannot rule on scope: no concrete request provided, or the spec is unreadable.")

---

FLOW
  1. Restate the request -- one line, in product terms: what capability is being asked for.
  2. Check the out-of-scope list -- if it matches, the ruling is NO. Tag `[SCOPE]`, cite the item, STOP.
  3. Check the business model -- if the request implies a different model than the spec declares (e.g.
     selling items individually when the spec declares a subscription that unlocks everything), the
     ruling is NO until the spec is changed. Tag `[SCOPE]`.
  4. Check the in-scope requirements + the launch-blocking list -- if the request IS a functional
     requirement or a launch-blocking item, the ruling is YES; cite the section. If it is a
     lower-priority proposal, the ruling is YES-but-deprioritized (note the priority); it is not
     launch-blocking.
  5. Emit the ruling -- format: `"<Yes | No | Yes (deprioritized)> — <spec section>."` then one line of
     reason. If NO, state exactly what spec edit would reverse it.
  6. Record it -- if the ruling is recurring or non-obvious, capture it in `references/` so the next
     answer is consistent.

---

CHECKLIST completion
  [ ] Request restated in one product-terms line
  [ ] Checked against the full out-of-scope list AND against the declared business model
  [ ] Ruling is Yes / No / Yes (deprioritized), each citing a spec section
  [ ] If No, the spec edit required to reverse it is named
  [ ] Recurring rulings captured in `references/`
  [ ] Output matches VOICE.md ("<Yes|No> — <spec section>." then one line)
