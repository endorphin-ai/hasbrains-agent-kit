# Conversion Phase 4: Convert Agent Body

See also: `conversion-phases.md` (phases 1–3) · `conversion-output.md` (phases 5–7)

Convert the agent body section by section. Write result to `{output_folder}/4-body.md`.
Preserve all logic — only update references and tracking.

---

## 4.1 Role / Identity section

Keep as-is. Copy directly.

---

## 4.2 Skill usage table

Update from skill names to `.copilot_utils/{agent_name}/` paths:

**Before (Claude):**

```markdown
| Skill              | What it knows        | When you use it |
| ------------------ | -------------------- | --------------- |
| `review-triage`    | Risk classification  | Phase 2         |
```

**After (Copilot):**

```markdown
| Context file                                         | What it knows       | When you use it |
| ---------------------------------------------------- | ------------------- | --------------- |
| `.copilot_utils/{agent_name}/trees/review-triage.md` | Risk classification | Phase 2         |
```

---

## 4.3 Task tracking (MANDATORY conversion)

Replace every `TaskCreate`/`TaskUpdate` block with `manage_todo_list`.

**⚠️ CRITICAL: A bare JSON array `[{...}]` is NOT correct and will fail. Always use `"operation": "write"`.**

**Before:**

```python
task1_id = TaskCreate(subject="Phase 1: Identify input", activeForm="Identifying")
TaskUpdate(taskId=task1_id, status="in_progress")
# ... work ...
TaskUpdate(taskId=task1_id, status="completed")
```

**After — initial setup (one call before any work starts):**

```json
{
	"operation": "write",
	"todoList": [
		{ "id": 1, "title": "Phase 1: Identify input and locate test", "status": "not-started" },
		{ "id": 2, "title": "Phase 2: Create branch", "status": "not-started" }
	]
}
```

**After — mark in-progress (before each phase):**

```json
{ "operation": "update", "updates": [{ "id": 1, "status": "in-progress" }] }
```

**After — mark completed (immediately after finishing):**

```json
{ "operation": "update", "updates": [{ "id": 1, "status": "completed" }] }
```

**Rules:**

- Always call `operation: write` with ALL todos BEFORE starting any work
- Update ONE task at a time — in-progress when starting, completed when done
- Sequential `addBlockedBy` chains → simple ascending ID order (1 before 2 before 3)

**Embed this PROGRESS TRACKING section in the agent body:**

````markdown
## PROGRESS TRACKING

**CRITICAL:** Use `manage_todo_list` tool to track progress.

**Initial Setup (before starting work):**

```json
{
	"operation": "write",
	"todoList": [
		{ "id": 1, "title": "Phase 1: ...", "status": "not-started" },
		{ "id": 2, "title": "Phase 2: ...", "status": "not-started" }
	]
}
```

**During Execution:** Mark in-progress when starting, completed when done.

```json
{ "operation": "update", "updates": [{ "id": 1, "status": "in-progress" }] }
{ "operation": "update", "updates": [{ "id": 1, "status": "completed" }] }
```

Update ONE task at a time. Never batch multiple status changes.
````

---

## 4.4 Skill references in phase bodies

Replace Claude skill references with file paths:

| Before (Claude)                                    | After (Copilot)                                                               |
| -------------------------------------------------- | ----------------------------------------------------------------------------- |
| `**Skill used:** \`review-triage\``                | `**Apply tree:** \`.copilot_utils/{agent_name}/trees/review-triage.md\``      |
| `"Follow the triage from \`review-triage\`"`       | `"Read and follow \`.copilot_utils/{agent_name}/trees/review-triage.md\`"`    |
| `"Using knowledge from the \`code-conventions\` skill"` | `"Read \`.copilot_utils/{agent_name}/context/code-conventions.md\`"`   |

---

## 4.5 Script references

```
bash tests/.claude/skills/{name}/scripts/{script}.sh
→ bash .copilot_utils/{agent_name}/scripts/{script}.sh (if script was copied)
→ or inline the bash command directly

Skill("skill-name") calls → remove; replace with "Read `.copilot_utils/{agent_name}/context/{skill}.md`"
```

---

## 4.6 Memory section

```
Before: .claude/agent-memory/{agent-name}/MEMORY.md
After:  .copilot_utils/{agent-name}/memory/MEMORY.md
```

---

## 4.7 Keep as-is

- Bash commands and git workflow
- MCP tool calls (already use full IDs)
- ALWAYS_DO / NEVER_DO rules
- Error handling blocks
- Return format / final report
- Phase numbering and structure
- Variable definitions and state tracking
