# Conversion Phases 1–3: Source Reading, Scaffold, Frontmatter

See also: `conversion-body.md` (phase 4) · `conversion-output.md` (phases 5–7)

---

## Phase 1: Read All Source Files → `{output_folder}/1-source-context.md`

### 1.1 Read the agent

Read `{agent_file}`. Extract:

- `name` → set `{agent_name}`
- `description`, `model`, `skills:` list, `memory:`, `isolation:`
- Full body: phases, error handling, return format, ALWAYS_DO/NEVER_DO rules

### 1.2 Read the command

Read `{command_file}`. Extract:

- `name` — the `/command-name` trigger
- `description` — trigger phrases and usage examples
- `argument-hint` — what `$ARGUMENTS` the user passes
- The `Task()` call — what prompt it sends to the agent

If `{command_file}` was not provided, ask the user for it before continuing.

### 1.3 Read each skill

For each skill name in the agent's `skills:` frontmatter list:

```bash
ls ~/.claude/skills/{skill-name}/SKILL.md
ls .claude/skills/{skill-name}/SKILL.md
find ~/.claude/skills/{skill-name} -type f | sort
```

For each skill: read `SKILL.md` fully; list all files in `references/`, `examples/`, `scripts/`, `trees/`.

### 1.4 Read agent memory (if any)

```bash
ls ~/.claude/agent-memory/{agent_name}/ 2>/dev/null || ls .claude/agent-memory/{agent_name}/ 2>/dev/null
```

### 1.5 Write source context

Write `{output_folder}/1-source-context.md`:

```markdown
# Source Context

## Agent: {agent_file}

- Name: {agent_name} | Model: {model} | Skills: {skill list} | Memory: yes/no

## Command: {command_file}

- Trigger: /{command_name} | Argument-hint: {value}
- Key trigger phrases: [list from description]

## Skills

| Skill  | Location | Classification | Files  |
| ------ | -------- | -------------- | ------ |
| {name} | {path}   | context/trees  | {list} |

## Memory files

{list or "none"}
```

---

## Phase 2: Scaffold Output Directories

```bash
mkdir -p .github/agents
mkdir -p .copilot_utils/{agent_name}/context
mkdir -p .copilot_utils/{agent_name}/trees
mkdir -p {output_folder}
```

Copy skill content to correct subdirectory:

```bash
# Decision trees (if/else logic):
cp ~/.claude/skills/{skill}/SKILL.md .copilot_utils/{agent_name}/trees/{skill}.md

# Knowledge/reference:
cp ~/.claude/skills/{skill}/SKILL.md .copilot_utils/{agent_name}/context/{skill}.md

# Templates from skill references/:
cp ~/.claude/skills/{skill}/references/*template*.md .copilot_utils/{agent_name}/context/{skill}-templates.md

# Examples:
cp ~/.claude/skills/{skill}/examples/*.md .copilot_utils/{agent_name}/context/{skill}-examples.md

# Trees subdirectory in skill:
cp ~/.claude/skills/{skill}/trees/*.md .copilot_utils/{agent_name}/trees/
```

**When a skill has both types:** copy full SKILL.md to `context/`, extract decision sections to `trees/`.

**Scripts:** copy to project `scripts/` dir or keep as inline bash in the agent body.

**Large skill:** break into many small focused files in a subdirectory:

```bash
mkdir -p .copilot_utils/{agent_name}/context/{skill}
cp ~/.claude/skills/{skill}/references/*.md .copilot_utils/{agent_name}/context/{skill}/
```

---

## Phase 3: Build Agent Frontmatter → `{output_folder}/3-frontmatter.md`

```yaml
---
name: '{agent_name}'
description: '{MERGED description — see below}'
tools: ['{mapped tools — see tool-mapping.md}']
model: '{expanded model — see SKILL.md § Model Expansion}'
target: 'vscode'
argument-hint: "{from command's argument-hint}"
---
```

### Merging the description

1. Start with the agent's `description` field
2. Append "Use when someone says..." with trigger phrases from the command's `description`
3. Append the `argument-hint` context if helpful

**Example:**

```yaml
description: "Reviews a GitHub pull request end to end — triages the changed files by risk,
    checks them against the project's conventions, and posts one review report.
    Use when someone says 'review PR 123', 'review this PR', 'check my pull request',
    or pastes a GitHub PR URL."
argument-hint: 'PR number or GitHub PR URL'
```

### Tool mapping

| Claude                              | Copilot                  |
| ----------------------------------- | ------------------------ |
| Read                                | `"read"`                 |
| Write / Edit                        | `"edit"`                 |
| Bash(git:_) / Bash(gh:_) / Bash(\*) | `"execute"`              |
| Grep / Glob / ListFiles             | `"search"`               |
| TaskCreate / TaskUpdate / TaskGet   | `"todo"`                 |
| WebSearch / WebFetch                | `"web"` ⚠️ NOT `"fetch"` |
| mcp\_\_\* tools                     | list by full name as-is  |

Write the intermediate frontmatter block to `{output_folder}/3-frontmatter.md`.
