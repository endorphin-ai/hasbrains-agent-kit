# Advanced: Sub-Agents, Parallel, Return Format

See also: `advanced-patterns.md` — reference syntax, dynamic params, variable flow

---

## Sub-Agent Delegation: handoffs vs runSubagent

When the Claude agent spawns other agents (`Task(subagent_type=...)`), convert based on `target`:

### VS Code: `handoffs` in frontmatter

```yaml
---
name: 'orchestrator-agent'
tools: ['read', 'edit', 'search', 'agent', 'todo']
target: 'vscode'
handoffs:
    - label: 'Analyze File'
      agent: 'Analyzer-Agent'
      prompt: 'Analyze this file for patterns and return findings'
    - label: 'Transform File'
      agent: 'Transformer-Agent'
      prompt: 'Apply fixes based on analysis results'
---
```

Reference in phase body:

```markdown
### PHASE 2: Delegate Analysis

**Delegate to:** `Analyzer-Agent` via handoff

**Input:** File: `${filePath}`

**Expected return:** `{ "status": "PASS|FAIL", "violations": [...] }`

**On PASS:** Continue to Phase 3
**On FAIL:** Stop and report violations
```

### GitHub Copilot: `runSubagent()` in body

```yaml
---
name: 'copilot-orchestrator'
tools: ['read', 'edit', 'search', 'agent']
target: 'github-copilot'
---
```

```javascript
const analysisResult = await runSubagent({
	description: 'Analyze file for patterns',
	prompt: `You are the Analyzer.
File: ${filePath}
Reference: .copilot_utils/{agent_name}/context/anti-patterns.md
Task: Check file against each pattern. Return JSON:
{ "status": "PASS | FAIL", "violations": [{ "line": N, "issue": "..." }] }`,
});
```

### Chaining sub-agent results

```javascript
const analysisResult = await runSubagent({...});
const transformResult = await runSubagent({
    description: 'Apply transformations',
    prompt: `Input from Analyzer:
- Patterns: ${analysisResult.patterns}
- Lines: ${analysisResult.lineNumbers}`
});
```

**Rules:**

- Sub-agents can't use tools the parent doesn't have
- Keep sub-agents focused — one clear task per sub-agent
- Max 5-10 sequential sub-agent calls
- Define expected return format explicitly in the prompt

---

## Parallel Operations

When a Claude agent uses parallel tool calls in one message, preserve the intent:

```markdown
### PHASE 1: Parallel Context Gathering

**Execute these operations in parallel for speed:**

1. read `.copilot_utils/{agent_name}/context/guide-1.md`
2. read `.copilot_utils/{agent_name}/context/guide-2.md`
3. search for pattern in codebase
```

---

## Phase Output Variables Pattern

Each phase should document what variables it produces:

```markdown
### PHASE 1: Extract Data

**Input:** `{inputId}` from user

**Steps:**

1. Fetch data
2. Parse response

**Output Variables:**

- `inputName` = extracted name
- `inputType` = classification result
```

---

## Return Format Section

Every agent should define its success output. Place after Dynamic Parameters:

```markdown
## Return Format

Upon completion, return:

## [Operation] Summary

- **Status**: success | failed
- **File Path**: `path/to/output`
- **Changes Made**: [list]
- **Next Steps**: [recommendations]
```

---

## Inline MCP Alternative Pattern

When an MCP tool may not be available, document a fallback:

```markdown
<!-- Primary: mcp__atlassian__getJiraIssue(issueIdOrKey={ticketNumber}) -->

Fallback: fetch the issue with the tracker's REST API or CLI (e.g. `curl` with an API token)
and read the fields you need from the JSON response.
```

---

## manage_todo_list Full Pattern

Note: `todo` tool and `manage_todo_list` are VS Code only. For `target: 'github-copilot'`, omit `"todo"` from tools and the PROGRESS TRACKING section.

````markdown
## PROGRESS TRACKING

**CRITICAL:** Use `manage_todo_list` tool to track progress.

**Initial Setup (before starting work):**

```json
{
	"operation": "write",
	"todoList": [
		{ "id": 1, "title": "PHASE 1: ...", "status": "not-started" },
		{ "id": 2, "title": "PHASE 2: ...", "status": "not-started" }
	]
}
```

**During Execution:**

```json
{ "operation": "update", "updates": [{ "id": 1, "status": "in-progress" }] }
{ "operation": "update", "updates": [{ "id": 1, "status": "completed" }] }
```

Update ONE task at a time. Never batch status changes.
````
