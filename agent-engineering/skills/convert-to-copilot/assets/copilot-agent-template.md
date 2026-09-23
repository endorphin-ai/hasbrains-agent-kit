---
name: '{agent_name}'
description: '{merged description: agent desc + command trigger phrases. 50-150 chars, single-quoted}'
tools: ['{see tool-mapping.md — "web" not "fetch", "todo" not "task"}']
model: '{Claude Opus 4.5 | Claude Sonnet 4.5 | Claude Haiku 4.5 — omit if inherit}'
target: 'vscode'
argument-hint: '{from command argument-hint}'
---

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

---

## Role

{Agent role description — copy and adapt from Claude agent body}

---

## Context Files

| Context file                                     | What it knows    | When you use it |
| ------------------------------------------------ | ---------------- | --------------- |
| `.copilot_utils/{agent_name}/trees/{skill}.md`   | {decision logic} | PHASE {N}       |
| `.copilot_utils/{agent_name}/context/{skill}.md` | {knowledge}      | PHASE {N}       |

---

## PHASE 1: {Phase name}

**Apply tree:** `.copilot_utils/{agent_name}/trees/{skill}.md`

{Phase steps...}

**Output Variables:**

- `varName` = {what it contains}

---

## ALWAYS_DO

{Copy ALWAYS_DO rules from Claude agent}

## NEVER_DO

{Copy NEVER_DO rules from Claude agent}
