# Example: pr-reviewer Conversion

Full worked example of converting a Claude Code agent to a Copilot agent.

---

## Input

| Item    | Path                                                                                          |
| ------- | --------------------------------------------------------------------------------------------- |
| Agent   | `~/.claude/agents/pr-reviewer.md`                                                             |
| Command | `~/.claude/commands/review-pr.md`                                                             |
| Skills  | `review-triage`, `code-conventions`, `issue-lookup`, `review-report`, `pipeline-state`        |

---

## Variable Setup

```
{agent_name}    = pr-reviewer
{output_dir}    = .copilot_utils/pr-reviewer
{output_agent}  = .github/agents/pr-reviewer.agent.md
{output_folder} = .copilot-convert-results
```

---

## Output Structure

```
.github/
└── agents/
    └── pr-reviewer.agent.md

.copilot_utils/
└── pr-reviewer/
    ├── context/
    │   ├── code-conventions.md          ← naming, error handling, test rules
    │   ├── issue-lookup.md              ← issue-tracker MCP commands, linked-issue format
    │   ├── review-report.md             ← guidance and severity mapping
    │   └── review-report-templates.md   ← PR comment format, JSON schemas
    └── trees/
        └── review-triage.md             ← risk classification tree
```

---

## Skill Classification Decisions

| Skill              | Classification                        | Reason                                                       |
| ------------------ | ------------------------------------- | ------------------------------------------------------------ |
| `review-triage`    | `trees/`                              | Primarily "if a change touches X → check Y" decision logic   |
| `code-conventions` | `context/`                            | Naming, error-handling and test conventions — knowledge only |
| `issue-lookup`     | `context/`                            | Issue-tracker MCP commands and linked-issue format reference |
| `review-report`    | `context/` + `context/*-templates.md` | Mix of guidance + report format templates                    |
| `pipeline-state`   | `context/` + scripts                  | Usage guide + shell scripts                                  |

---

## Frontmatter Conversion

**Before (Claude agent):**

```yaml
---
name: pr-reviewer
model: opus
color: blue
memory: project
isolation: worktree
skills:
    - review-triage
    - code-conventions
allowed-tools:
    - Bash(git:*)
    - Bash(gh:*)
    - mcp__atlassian__getJiraIssue
---
```

**After (Copilot agent):**

```yaml
---
name: 'pr-reviewer'
description: "Reviews a GitHub pull request end to end — triages the changed files by risk,
    checks them against the project's conventions, and posts one review report.
    Use when someone says 'review PR 123', 'review this PR', 'check my pull request',
    or pastes a GitHub PR URL."
tools:
    - 'execute'
    - 'read'
    - 'edit'
    - 'search'
    - 'todo'
    - 'mcp__atlassian__getJiraIssue'
model: 'Claude Opus 4.5'
target: 'vscode'
argument-hint: 'PR number or GitHub PR URL'
---
```

Fields removed: `color`, `memory`, `isolation`, `skills`, `allowed-tools`

---

## Task Tracking Conversion

**Before (Claude):**

```python
task1_id = TaskCreate(subject="Phase 1: Fetch the PR and its diff")
TaskUpdate(taskId=task1_id, status="in_progress")
# ... work ...
TaskUpdate(taskId=task1_id, status="completed")
```

**After (Copilot) — initial setup:**

```json
{
	"operation": "write",
	"todoList": [
		{ "id": 1, "title": "Phase 1: Fetch the PR and its diff", "status": "not-started" },
		{ "id": 2, "title": "Phase 2: Triage changed files by risk", "status": "not-started" },
		{ "id": 3, "title": "Phase 3: Review against conventions", "status": "not-started" }
	]
}
```

**Per-phase updates:**

```json
{ "operation": "update", "updates": [{ "id": 1, "status": "in-progress" }] }
{ "operation": "update", "updates": [{ "id": 1, "status": "completed" }] }
```

---

## Skill Reference Conversion

**Skill usage table (before):**

```markdown
| Skill              | What it knows                    | When you use it   |
| ------------------ | -------------------------------- | ----------------- |
| `review-triage`    | Risk classification trees        | Phase 2: Triage   |
| `code-conventions` | Naming, error handling, tests    | Phase 3: Review   |
```

**Skill usage table (after):**

```markdown
| Context file                                             | What it knows             | When you use it |
| -------------------------------------------------------- | ------------------------- | --------------- |
| `.copilot_utils/pr-reviewer/trees/review-triage.md`      | Risk classification trees | Phase 2: Triage |
| `.copilot_utils/pr-reviewer/context/code-conventions.md` | Naming, errors, tests     | Phase 3: Review |
```

**Inline reference (before):**

```markdown
**Skill used:** `review-triage`
```

**Inline reference (after):**

```markdown
**Apply tree:** `.copilot_utils/pr-reviewer/trees/review-triage.md`
```

---

## Memory Path Conversion

```
Before: .claude/agent-memory/pr-reviewer/MEMORY.md
After:  .copilot_utils/pr-reviewer/memory/MEMORY.md
```
