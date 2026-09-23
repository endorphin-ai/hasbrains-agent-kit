# convert-to-copilot

> Port a Claude Code agent — with its command and skills — to one GitHub Copilot agent that works the same way.

**Plugin:** `agent-engineering` — `/plugin install agent-engineering@hasbrains-agent-kit`

## Why use it

- Your team uses both Claude Code and GitHub Copilot, and every agent has to be written twice.
- Copilot has no skills or commands: a straight copy loses the knowledge and the triggers the agent depends on.
- Hand-ported agents drift — wrong tool aliases (`fetch` instead of `web`), dead file paths, task tracking that fails silently.

## What it does

- Merges the **agent + its launch command** into one `.github/agents/{name}.agent.md`, with the command's trigger phrases in the `description`.
- Splits every **skill** into `.copilot_utils/{name}/context/` (what to use) and `trees/` (how to decide), and rewrites each skill reference to a file path.
- Maps **tools, models and frontmatter**: `WebFetch` → `web`, `TaskCreate` → `manage_todo_list`, `opus` → `Claude Opus 4.5`, drops `color` / `memory` / `isolation` / `skills` / `allowed-tools`.
- Converts **sub-agent calls** to `handoffs` (VS Code) or `runSubagent()` (GitHub Copilot).
- **Validates** the result — every referenced path exists, aliases are correct, body under 30,000 characters — and prints a conversion report.
- Ships **scaffold scripts** for both directions (`claude-to-copilot`, `copilot-to-claude`) and a full worked example.

## Benefits

- **Write the agent once.** Claude Code stays the source; Copilot gets a faithful port.
- **No lost knowledge.** Skills become referenced context files, not a pasted wall of text.
- **Correct on the first run.** The tool and model tables catch the aliases that break Copilot agents.
- **Reviewable.** Each phase writes its output to `.copilot-convert-results/`, so you can see every decision.

---

Made by **HasBrains** — https://hasbrains.com/
