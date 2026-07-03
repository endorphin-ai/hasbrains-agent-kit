# Testing Anti-Patterns

**Load this reference when:** writing or changing tests, adding mocks/stubs, or tempted to add test-only methods to production code.

## Overview

Tests must verify real behavior, not mock behavior. Mocks and stubs are a means to isolate, not the thing being tested.

**Core principle:** Test what the code does, not what the mocks do.

**Following strict TDD prevents these anti-patterns.**

Examples below are pseudocode — translate to your language and test framework.

## The Iron Laws

```
1. NEVER test mock/stub behavior
2. NEVER add test-only methods to production code
3. NEVER stub without understanding dependencies
```

## Anti-Pattern 1: Testing Mock Behavior

**The violation:**

```
// ❌ BAD: asserting a call was made when a state assertion suffices
test "publishes the article":
    article = create_draft_article()
    publisher = mock(Publisher)
    inject(publisher)

    POST /articles/{article.id}/publish

    assert publisher.was_called_with("publish")   // only proves the mock was called
```

**Why this is wrong:**

- You're verifying the mock was called, not that the article actually got published
- The test passes when the call is made, regardless of the real outcome
- Tells you nothing about real behavior (state after the action)

**The question to ask:** "Are we testing the behavior of a mock?"

**The fix:**

```
// ✅ GOOD: assert observable STATE, use the real collaborator
test "publishes the article":
    article = create_draft_article()

    POST /articles/{article.id}/publish

    assert reload(article).status == "published"
```

### Gate Function

```
BEFORE writing an "assert X was called" expectation:
  Ask: "Am I testing real behavior (state after the action) or just that a call was made?"

  IF a state assertion (reload the record, read the response, check the output)
  would prove it:
    STOP - use the state assertion instead of the call expectation

  Reserve "was called" assertions for boundaries where the SIDE EFFECT is the
  behavior (e.g. a payment provider was called with the right arguments) and no
  observable state exists.
```

## Anti-Pattern 2: Test-Only Methods in Production

**The violation:**

```
// ❌ BAD: reset_for_tests only used by tests, living in production code
class Subscription:
    function reset_for_tests():
        // Looks like production API!
        this.status = "canceled"
        this.period_end = null
        payment_provider.cancel(this.external_id)

// In a test
after_each: subscription.reset_for_tests()
```

**Why this is wrong:**

- Production code polluted with test-only methods
- Dangerous if accidentally called in production
- Violates YAGNI and separation of concerns
- Confuses test lifecycle with entity lifecycle

**The fix:**

```
// ✅ GOOD: test setup/teardown lives in test helpers, not production classes
// Subscription has no reset_for_tests — test isolation (transactions,
// truncation, fresh fixtures) restores state between tests.

// test/helpers/subscription_helpers
function cancel_subscription(subscription):
    subscription.update(status: "canceled", period_end: null)

// In a test — state is reset automatically; only cancel when the SCENARIO needs it
before: cancel_subscription(subscription)
```

### Gate Function

```
BEFORE adding any method to a production class/module:
  Ask: "Is this only used by tests?"

  IF yes:
    STOP - Don't add it
    Put it in a test helper / support module / factory instead

  Ask: "Does this class own this resource's lifecycle?"

  IF no:
    STOP - Wrong class for this method
```

## Anti-Pattern 3: Stubbing Without Understanding

**The violation:**

```
// ❌ BAD: stub removes a side effect the test depends on
test "duplicate webhook is a no-op":
    // This stub prevents the row-write the idempotency check reads!
    stub(Order.create).to_return(fake_order)

    handle_webhook(event)
    handle_webhook(event)   // should be a no-op — but the check can't see the first row

    assert count(Order) == 1   // fails / passes for the wrong reason
```

**Why this is wrong:**

- The stubbed method had a side effect the test depended on (persisting the row)
- Over-stubbing to "be safe" breaks actual behavior
- Test passes for the wrong reason or fails mysteriously

**The fix:**

```
// ✅ GOOD: stub only the external boundary; let internal code behave for real
test "duplicate webhook is a no-op":
    // Stub only the payment provider's HTTP API — rows still get written for real
    stub_http(POST, "payment-provider.example/*").to_return(200, "{}")

    handle_webhook(event)
    handle_webhook(event)   // idempotency check reads the real first row

    assert count(Order) == 1
```

### Gate Function

```
BEFORE stubbing any method:
  STOP - Don't stub yet

  1. Ask: "What side effects does the real method have?"
  2. Ask: "Does this test depend on any of those side effects (a written row, a set attribute)?"
  3. Ask: "Do I fully understand what this test needs?"

  IF it depends on side effects:
    Stub at the lower level (the actual external HTTP call / network boundary)
    OR use a real object that preserves the necessary behavior
    NOT the high-level method the test depends on

  IF unsure what the test depends on:
    Run the test with the real implementation FIRST
    Observe what actually needs to happen
    THEN add minimal stubbing at the right level (the external-service boundary)

  Red flags:
    - "I'll stub this to be safe"
    - "This might be slow, better stub it"
    - Stubs scattered across the whole test ("stub everything")
    - Stubbing without understanding the dependency chain
```

## Anti-Pattern 4: Incomplete Stubbed Responses

**The violation:**

```
// ❌ BAD: partial stub — only the fields you think you need
stub_http(POST, "payment-provider.example/*").to_return(200,
    { id: "cs_123", status: "complete" }
    // Missing: customer, subscription, metadata that the handler reads
)

// Later: null/undefined error when the handler reads event.customer
```

**Why this is wrong:**

- **Partial stubs hide structural assumptions** — you only mocked fields you know about
- **Downstream code may depend on fields you didn't include** — silent failures
- **Tests pass but integration fails** — stub incomplete, real payload complete
- **False confidence** — the test proves nothing about real behavior

**The Iron Rule:** Stub the COMPLETE payload as it exists in reality (mirror a real response from the external service), not just the fields your immediate test reads. Prefer a **recorded real response** (record/replay tooling, or a fixture captured once from the real sandbox/test-mode API) over a hand-rolled partial object.

**The fix:**

```
// ✅ GOOD: mirror the real payload completely (recorded fixture)
stub_http(POST, "payment-provider.example/*").to_return(200,
    read_fixture("payment_provider/checkout_completed.json")
    // A recorded, complete event body — every field the handler may consume
)
```

### Gate Function

```
BEFORE creating a stubbed response body:
  Check: "What fields does the real external response contain?"

  Actions:
    1. Examine an actual response (provider docs / a recorded response / sandbox call)
    2. Include ALL fields the system might consume downstream
    3. Verify the stub matches the real response schema completely
       (prefer a recorded response / shared complete fixture)

  Critical:
    If you're creating a stub, you must understand the ENTIRE structure.
    Partial stubs fail silently when code depends on omitted fields.

  If uncertain: record a real response / use the full documented payload.
```

## Anti-Pattern 5: Tests as Afterthought

**The violation:**

```
✅ Implementation complete
❌ No tests written
"Ready for testing"
```

**Why this is wrong:**

- Testing is part of implementation, not an optional follow-up
- TDD would have caught this
- Can't claim complete without tests (and the full suite green)

**The fix:**

```
TDD cycle:
1. Write failing test
2. Implement to pass
3. Refactor
4. THEN claim complete (full suite green)
```

## Anti-Pattern 6: Brittle UI Selectors

**The violation:**

```
// ❌ BAD: select on visible copy / DOM position — breaks on any wording or markup change
click("Read the full article now →")
assert page.has_element("div.article > div:nth-child(3) > p.body-copy")
```

**Why this is wrong:**

- Selecting on human-visible text or DOM position couples the test to copywriting and layout, not behavior
- A wording tweak or a markup refactor turns the test red with no real regression
- Access-control negatives asserted on text ("it looks hidden") are not real coverage

**The fix:**

```
// ✅ GOOD: target a stable test identifier the frontend emits
click(element('[data-test="read-full-article"]'))
assert page.has_element('[data-test="paid-body"]')
// access-control negative — prove the paid body is ABSENT for an unpaid user
assert NOT page.has_element('[data-test="paid-body"]')
```

### Gate Function

```
BEFORE writing a UI/end-to-end selector:
  Ask: "Am I selecting on a stable test identifier, or on visible text / DOM position?"

  IF text / CSS / DOM position:
    STOP - switch to a dedicated test identifier (e.g. data-test attribute),
    and use the SAME identifier across all UI test layers
    IF the element has no identifier: flag it as a gap for the frontend owner —
    do NOT work around it with a brittle selector chain.
```

## When Mocks/Stubs Become Too Complex

**Warning signs:**

- Stub/mock setup longer than the test logic
- Stubbing everything to make the test pass
- Mocks missing methods the real collaborators have (use verified/strict mocks so this fails loudly, if your framework supports them)
- Test breaks when a stub changes

**The question to ask:** "Do we need to be using a mock here?"

**Consider:** Tests with real objects and real data (stubbing ONLY the external network boundary) are often simpler than complex mock webs.

## Anti-Pattern 7: Leaky Shared State

**The violation:**

```
// ❌ BAD: state created in one test leaks into the next (order-dependent flakiness)
test "lists published articles":
    insert Article(title: "A", status: "published")   // never cleaned up
    assert count(published_articles()) == 1            // passes alone, fails after another test
```

**Why this is wrong:**

- Persisted state survives across tests → order-dependent, mysteriously flaky suites
- Absolute-count assertions (`== 1`) break as soon as another test leaves data behind
- Hides real behavior behind test-harness noise

**The fix:**

```
// ✅ GOOD: isolate each test — transactions rolled back, truncation between tests,
// or fresh in-memory state. Build data inside the test with factories.
test "lists published articles":
    create_article(status: "published")
    create_article(status: "draft")
    assert count(published_articles()) == 1   // deterministic — clean state each test
```

### Gate Function

```
BEFORE asserting on shared state (database, files, globals, caches):
  Ask: "Is each test starting from a clean slate?"

  Ensure:
    - test isolation is configured (per-test transactions, truncation,
      fresh instances, or teardown hooks)
    - tests that cross an isolation boundary (browser tests, background
      workers, threads) use a stronger cleanup strategy
    - state is built with factories/builders inside the test, never assumed
      to pre-exist

  Prefer relative assertions where shared seed data exists:
    assert delta(count(Order)) == +1     // not count(Order) == 1
```

## TDD Prevents These Anti-Patterns

**Why TDD helps:**

1. **Write test first** → Forces you to think about what you're actually testing
2. **Watch it fail** → Confirms the test tests real behavior, not mocks
3. **Minimal implementation** → No test-only methods creep in
4. **Real dependencies** → You see what the test actually needs before stubbing

**If you're testing mock behavior, you violated TDD** — you added mocks without watching the test fail against real code first.

## Quick Reference

| Anti-Pattern                     | Fix                                                              |
| -------------------------------- | ---------------------------------------------------------------- |
| Assert a call was made           | Assert observable state; use the real collaborator               |
| Test-only methods in production  | Move to test helpers / support modules / factories               |
| Stub without understanding       | Understand dependencies first; stub only the external boundary   |
| Incomplete stubbed response      | Mirror the real payload completely (recorded response / fixture) |
| Tests as afterthought            | TDD — tests first, full suite green                              |
| Brittle text/position selectors  | Target stable test identifiers (same identifier in every layer)  |
| Over-complex mocks               | Use real objects + factories; stub only the boundary             |
| Leaky shared state               | Per-test isolation + cleanup; relative assertions                |

## Red Flags

- "Assert X was called" where a state assertion would prove it
- Stubs scattered across the whole test ("stub everything")
- Methods only called from test files, living in production code
- Stub/mock setup is >50% of the test
- Test fails when you remove a stub
- Can't explain why a stub is needed
- Stubbing "just to be safe"
- Selecting on visible text / DOM position instead of stable test identifiers
- Absolute count assertions with no per-test state cleanup

## The Bottom Line

**Mocks and stubs are tools to isolate, not things to test.**

If TDD reveals you're testing mock behavior, you've gone wrong.

Fix: Test real behavior (state), or question why you're stubbing at all. Stub ONLY the external-service boundary — payment providers, storage, third-party APIs — and let your own code and data behave for real.
