# Tool & Model Mapping Reference

Source: https://github.com/endorphin-ai/vs-code-copilot-agents/blob/main/COPILOT_AGENTS_GUIDE.md

---

## Claude → Copilot Tool Mapping

### Standard tool aliases

| Claude tool                 | Copilot `tools[]` value | Notes                                         |
| --------------------------- | ----------------------- | --------------------------------------------- |
| `Read`                      | `"read"`                | file reading                                  |
| `Write` / `Edit`            | `"edit"`                | file creation and editing                     |
| `Bash` / `Bash(*:*)`        | `"execute"`             | shell commands                                |
| `Grep` / `Glob`             | `"search"`              | content and file search                       |
| `WebFetch` / `WebSearch`    | `"web"`                 | ⚠️ NOT `"fetch"` — use `"web"`                |
| `TaskCreate` / `TaskUpdate` | `"todo"`                | converted to manage_todo_list (VS Code only)  |
| `Agent` (sub-agent spawn)   | `"agent"`               | for handoffs / runSubagent delegation         |
| `AskUserQuestion`           | —                       | not available; ask inline in response         |
| `Skill`                     | —                       | not applicable; replace with `**Reference:**` |

**Complete alias list from guide:** `['read', 'edit', 'search', 'execute', 'agent', 'web', 'todo']`

### Execute tool variants

| Copilot tool                  | When to use                                        |
| ----------------------------- | -------------------------------------------------- |
| `"execute"`                   | Generic shell — maps from all `Bash(*:*)` variants |
| `"execute/runInTerminal"`     | Run command in VS Code integrated terminal         |
| `"execute/getTerminalOutput"` | Read terminal output without running a new command |

### Wildcard MCP patterns

```yaml
tools: ['github/*']       # all GitHub operations
tools: ['atlassian/*']    # all Atlassian/Jira operations
tools: ['playwright/*']   # browser automation
tools: ['my-mcp/tool']    # specific tool from custom server
```

Use wildcards when agent needs broad service access.
Use explicit `mcp__*` IDs for least-privilege (small set of known operations).

### MCP tools (explicit)

```yaml
tools:
    - 'read'
    - 'execute'
    - 'mcp__atlassian__getJiraIssue'
```

`tools` is optional — omitting it grants all tools. Always list tools explicitly for least privilege.

---

## Model Expansion

| Claude `model:` | Copilot `model:`                         |
| --------------- | ---------------------------------------- |
| `opus`          | `"Claude Opus 4.5"`                      |
| `sonnet`        | `"Claude Sonnet 4.5"`                    |
| `haiku`         | `"Claude Haiku 4.5"`                     |
| `inherit`       | omit field or use most capable available |
| Full model ID   | keep as-is                               |

`model` is **Recommended** (not required). Omitting it lets Copilot choose.

**Selection guide:**

- Complex orchestrators with multi-phase reasoning → `"Claude Opus 4.5"`
- Standard agents → `"Claude Sonnet 4.5"`
- Lightweight / fast tasks → `"Claude Haiku 4.5"`

---

## Frontmatter Fields Reference

| Field           | Required?   | Values                           | Notes                    |
| --------------- | ----------- | -------------------------------- | ------------------------ |
| `description`   | **Yes**     | `'single-quoted string'`         | 50–150 chars             |
| `tools`         | Optional    | `['read', 'edit', ...]`          | Omit = all tools         |
| `model`         | Recommended | `'Claude Sonnet 4.5'`            | Full name required       |
| `name`          | Optional    | String                           | Defaults to filename     |
| `target`        | Optional    | `'vscode'` or `'github-copilot'` | See below                |
| `infer`         | Optional    | `true` / `false`                 | Auto-invoke from context |
| `argument-hint` | Optional    | String                           | VS Code only             |
| `handoffs`      | Optional    | List of delegations              | VS Code only             |

### `target` values

| Value              | When to use                                     |
| ------------------ | ----------------------------------------------- |
| `'vscode'`         | VS Code Copilot Chat agent (default)            |
| `'github-copilot'` | GitHub.com Copilot — PR review, issue workflows |

### `handoffs` (VS Code only)

```yaml
handoffs:
    - label: 'Validate File'
      agent: 'Validator-Agent'
      prompt: 'Analyze this file for anti-patterns and return violations'
```

### Fields to DROP from Claude frontmatter

| Claude field    | Action                                                |
| --------------- | ----------------------------------------------------- |
| `color`         | omit                                                  |
| `memory`        | omit                                                  |
| `isolation`     | omit                                                  |
| `skills`        | omit (content goes to `.copilot_utils/{agent_name}/`) |
| `allowed-tools` | omit (replaced by `tools` array)                      |

---

## Skill Classification Rules

### → `trees/{skill}.md` (decision/diagnosis logic)

Use when SKILL.md is primarily branching logic, classification flows, diagnosis trees, routing rules.
**Signal words:** "decision tree", "classification", "diagnosis", "when you see", "if.\*then"
Reference in body: `**Apply tree:** .copilot_utils/{agent_name}/trees/{skill}.md`

### → `context/{skill}.md` (reference knowledge)

Use when SKILL.md is primarily how-to guides, naming patterns, API patterns, workflow knowledge.
**Signal words:** "conventions", "patterns", "how to", "reference", "guide", "standards"
Reference in body: `**Reference:** .copilot_utils/{agent_name}/context/{skill}.md`

### Split when skill has both types

1. Copy full SKILL.md to `context/{skill}.md`
2. Extract only decision/branching sections to `trees/{skill}.md`
3. In `trees/{skill}.md`, add: `For full context see context/{skill}.md`
