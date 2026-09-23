# Advanced Copilot Agent Patterns

See also: `advanced-subagents.md` — handoffs, runSubagent, parallel, return format

---

## Reference Syntax in Agent Body

The agent body NEVER embeds knowledge or decision logic inline — it references files.

| When to use          | Syntax                                                    | Example                 |
| -------------------- | --------------------------------------------------------- | ----------------------- |
| Making a decision    | `**Apply tree:** .copilot_utils/{agent}/trees/{file}.md`  | Choosing project path   |
| Using reference info | `**Reference:** .copilot_utils/{agent}/context/{file}.md` | Anti-patterns, patterns |

### Single reference

```markdown
**Apply tree:** `.copilot_utils/{agent_name}/trees/project-selection.md`
```

### Multiple references

```markdown
**Reference:**

- `.copilot_utils/{agent_name}/context/anti-patterns.md`
- `.copilot_utils/{agent_name}/context/setup-patterns.md`
```

### Conditional reference mapping

```markdown
**Reference mapping:**

inputType → Knowledge File:
├─ type_a → .copilot_utils/{agent_name}/context/guide-a.md
└─ type_b → .copilot_utils/{agent_name}/context/guide-b.md
```

---

## Decision Tree File Format

Decision trees live in `.copilot_utils/{agent_name}/trees/`. Use this syntax:

```markdown
## Decision Tree Name

Input condition:
├─ "pattern-a", "keyword-a"
│ → result_a/
├─ "pattern-b", "keyword-b"
│ → result_b/
└─ Unknown
→ Use semantic_search() to determine

**Output:** `VARIABLE_NAME`
```

### With knowledge mapping

```markdown
## Selection Decision Tree

Input contains:
├─ "keyword_a" → path/option_a/
└─ Unknown → Use default or ask user

**Knowledge mapping:**
option_a → .copilot_utils/{agent_name}/context/guide-a.md
```

---

## Dynamic Parameters Section

Add at top of agent body, after Role:

```markdown
## Dynamic Parameters

- **VARIABLE_NAME**: Description
    - **Type:** string | boolean | list
    - **Pattern:** `regex or format hint`
    - **Example:** `example/value.ext`
    - **Required:** Yes | No
    - **Constraints:** Must exist on filesystem / must match pattern X
```

### Variable Extraction Strategy (follows Dynamic Parameters)

```markdown
## Variable Extraction Strategy

Extract variables from user input using these patterns:

1. **VARIABLE_NAME**: Look for [description]
2. **OTHER_VAR**: If user says "move to integration", infer integration path

**Error Handling:**

- If file doesn't exist: "Error: Source file not found at ${SOURCE_FILE}"
```

---

## Variable Flow Between Phases

For agents with 3+ phases and data flowing between them:

```markdown
| Phase   | Input Variables          | Output Variables              |
| ------- | ------------------------ | ----------------------------- |
| PHASE 1 | `sourceFile` (from user) | `targetFile`, `sessionId`     |
| PHASE 2 | `targetFile`             | `testCategory`, `needsFix`    |
| PHASE 3 | `targetFile`, `category` | `finalFilePath`, `testPassed` |
```

Variable syntax in prompts: `${variableName}` (camelCase).

---

## Execution Strategy with Flow Diagram

For agents with conditional branching or retry loops:

```markdown
## Execution Strategy

**Type:** Sequential with conditional branching

**Flow:**

PHASE 1: Initial action
↓
PHASE 2: Classification
↓
├─ Condition A? ──────────────► PHASE 4: Direct path
│
├─ Condition B? ──────────────► PHASE 3: Transform
│ ↓
│ PHASE 4: Continue
└─ Condition C? ──────────────► PHASE 3: Alternative
```
