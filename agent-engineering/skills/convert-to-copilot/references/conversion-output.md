# Conversion Phases 5–7: Write, Validate, Report

See also: `conversion-phases.md` (phases 1–3) · `conversion-body.md` (phase 4)

---

## Phase 5: Write Output Files

Write all files in this order:

1. `.github/agents/{agent_name}.agent.md`
    - Frontmatter from Phase 3
    - PROGRESS TRACKING section (from Phase 4.3) at top of body
    - Converted body from Phase 4

2. All `.copilot_utils/{agent_name}/context/*.md` — knowledge files
3. All `.copilot_utils/{agent_name}/trees/*.md` — decision tree files
4. Any `.copilot_utils/{agent_name}/scripts/*` — script files
5. `.copilot_utils/{agent_name}/memory/` — copy memory files found in Phase 1

---

## Phase 6: Validate → `{output_folder}/6-validation.md`

Run the full checklist. Write PASS/FAIL for each item:

```markdown
# Validation Results

| Check                                              | Status | Notes         |
| -------------------------------------------------- | ------ | ------------- |
| {output_agent} exists                              | ✅/❌  |               |
| Frontmatter: description with triggers             | ✅/❌  |               |
| Frontmatter: tools array (no "fetch")              | ✅/❌  |               |
| Frontmatter: model (expanded)                      | ✅/❌  |               |
| No separate command file created                   | ✅/❌  |               |
| No .prompt.md or .instructions.md                  | ✅/❌  |               |
| Task tracking uses manage_todo_list with operation | ✅/❌  |               |
| All .copilot_utils/ refs resolve to real files     | ✅/❌  |               |
| Scripts executable + paths correct                 | ✅/❌  |               |
| Memory paths updated                               | ✅/❌  |               |
| MCP calls preserved                                | ✅/❌  |               |
| Agent body ≤ 30,000 chars                          | ✅/❌  | {count} chars |
```

If any check FAILS, fix before proceeding to Phase 7.

---

## Phase 7: Conversion Report (console output)

```markdown
## Conversion Report

### Agent Created

- ✅ .github/agents/{name}.agent.md — {N} phases, tools: [{tools}], model: {model}

### Command Absorbed

- 🔗 /{command-name} → merged into agent description + argument-hint

### Skill Context Created (.copilot_utils/{agent-name}/)

| File                         | Type          | Source skill        |
| ---------------------------- | ------------- | ------------------- |
| context/{skill}.md           | knowledge     | {skill} SKILL.md    |
| trees/{skill}.md             | decision tree | {skill} SKILL.md    |
| context/{skill}-templates.md | templates     | {skill} references/ |

### Memory

- 📝 .copilot_utils/{agent-name}/memory/ — {N files copied / none}

### Task Tracking

- 🔄 TaskCreate/TaskUpdate → manage_todo_list ({N} todos)

### Preserved As-Is

- ✅ MCP tool calls
- ✅ Bash commands and git workflow
- ✅ Phase structure and numbering
- ✅ Error handling
- ✅ ALWAYS_DO / NEVER_DO rules
- ✅ Final report format

### Not Created (by design)

- ❌ No .prompt.md (command absorbed into agent)
- ❌ No .instructions.md
- ❌ No .github/skills/
```
