# verification-before-completion

> Evidence before assertions — run the check and read its output before claiming anything works.

**Plugin:** `agent-engineering` — `/plugin install agent-engineering@hasbrains-agent-kit`

## Why use it

- "Should work", "this fixes it", "tests pass" — stated without ever running the command.
- A confident wrong claim costs more than a slow right one; it gets committed, merged, and shipped.

## What it does

- Blocks any completion / fixed / passing claim until the verification command has actually run.
- Requires the real output, not a summary of what the output would presumably be.
- Forces an explicit statement of what remains UNVERIFIED when a check cannot be run.

## Benefits

- **Trust the green.** A pass means a command ran and you can read its output.
- **Catch it before the commit** — not after the deploy, at 2am.
- **Kill the confident wrong answer**, the most expensive failure an agent produces.
- **One file. Any stack.** Works with whatever test runner you already have.

---

Made by **HasBrains** — https://hasbrains.com/
