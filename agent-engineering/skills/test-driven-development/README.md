# test-driven-development

> Write the failing test first, watch it fail, then write the minimum code that makes it pass.

**Plugin:** `agent-engineering` — `/plugin install agent-engineering@hasbrains-agent-kit`

## Why use it

- Tests written after the code test what the code does — not what it should do.
- A bug with no reproducing test comes back.
- Agents rationalize skipping the test ("it's too simple to break"); this counters that.

## What it does

- The red → green → refactor loop, stated as a hard sequence.
- Test-quality principles: one behavior per test, no logic in tests, names that describe the behavior.
- Rationalization counters for the usual excuses to skip a test.
- Test-layer selection — which level (unit / integration / end-to-end) actually proves this behavior.

## Benefits

- **Bugs stop coming back** — every fix ships with the test that catches it next time.
- **Better design, for free.** Testable code is decoupled code, and you get it early.
- **No more skipped tests** — the usual excuses are answered in advance.
- **Any language, any framework.** The loop is the same everywhere.

---

Made by **HasBrains** — https://hasbrains.com/
