#!/usr/bin/env bash
# copilot-to-claude.sh — scaffold Copilot agent → Claude Code structure
# Sourced by convert-agents.sh. Requires lib-extract.sh to be sourced first.
# After scaffolding, run /convert-from-copilot in Claude Code for content transformation.

copilot_to_claude() {
  local agent_file="$AGENT_FILE"
  local dst="${CLAUDE_DIR:-$HOME/.claude}"
  local name; name=$(basename "$agent_file"); name="${name%.agent.md}"; name="${name%.md}"
  local utils_dir=".copilot_utils/${name}"

  echo -e "${B}=== Copilot → Claude: ${name} ===${NC}\n"

  [[ ! -f "$agent_file" ]] && echo -e "${R}❌ Not found: $agent_file${NC}" && exit 1
  if [[ ! -d "$utils_dir" ]]; then
    echo -e "${Y}⚠️  No ${utils_dir}/ found — scaffolding agent + command only${NC}"
  fi

  # --- Agent placeholder ---
  mkdir -p "$dst/agents"
  local agent_out="$dst/agents/${name}.md"
  if [[ -f "$agent_out" ]]; then
    echo -e "${Y}⚠️  $agent_out exists — skipped (delete to regenerate)${NC}"
  else
    {
      echo "---"
      echo "name: ${name}"
      echo "description: \"$(extract_fm "$agent_file" "description")\""
      echo "model: inherit"
      echo "color: blue"
      echo "memory: project"
      echo "isolation: worktree"
      echo "---"
      echo ""
      echo "<!-- SCAFFOLD: Body needs content transformation."
      echo "     Run /convert-from-copilot ${agent_file} in Claude Code to complete. -->"
      echo ""
      cat "$agent_file"
    } > "$agent_out"
    echo -e "  ${G}✅${NC} → agents/${name}.md  (scaffold — /convert-from-copilot to finish)"
  fi

  # --- Command ---
  mkdir -p "$dst/commands"
  local sname; sname=$(short_name "$name")
  local arg_hint; arg_hint=$(extract_fm "$agent_file" "argument-hint")
  cat > "$dst/commands/${sname}.md" << CMDEOF
---
description: "Launch ${name}. Usage: /${sname} ${arg_hint:-<input>}"
argument-hint: "${arg_hint:-<input>}"
allowed-tools: ["Bash(git:*)", "Bash(gh:*)"]
---

Run ${name} on \$ARGUMENTS.

Input: \$ARGUMENTS

Task(
  description="${name}: \$ARGUMENTS",
  subagent_type="${name}",
  isolation="worktree",
  prompt="Execute the full workflow for: \$ARGUMENTS"
)
CMDEOF
  echo -e "  ${G}🔗${NC} → commands/${sname}.md"

  # --- Context/trees → skills ---
  if [[ -d "$utils_dir" ]]; then
    declare -A skill_map
    for f in "$utils_dir/context"/*.md "$utils_dir/trees"/*.md; do
      [[ -f "$f" ]] || continue
      local bn; bn=$(basename "$f" .md)
      # Skip template files — they go to assets/
      [[ "$bn" == *-templates ]] && continue
      # Strip known suffixes to get skill name
      local key; key=$(echo "$bn" | sed 's/-examples$//' | sed 's/-reference$//')
      skill_map["$key"]="$f"
    done

    for skill in "${!skill_map[@]}"; do
      local src="${skill_map[$skill]}"
      local sd="$dst/skills/$skill"
      mkdir -p "$sd/references" "$sd/assets" "$sd/trees" "$sd/scripts"

      if [[ ! -f "$sd/SKILL.md" ]]; then
        local lc=0; [[ -f "$src" ]] && lc=$(wc -l < "$src")
        {
          echo "---"
          echo "name: ${skill}"
          echo "description: \"This skill provides knowledge about ${skill} for the ${name} agent. Load when the agent needs ${skill} capabilities.\""
          echo "---"
          echo ""
          echo "# ${skill}"
          echo ""
          if [[ $lc -le 100 && -f "$src" ]]; then
            cat "$src"
          elif [[ -f "$src" ]]; then
            echo "See \`references/detail.md\` for full content."
          fi
        } > "$sd/SKILL.md"

        if [[ $lc -gt 100 && -f "$src" ]]; then
          cp "$src" "$sd/references/detail.md"
          echo -e "     ${B}📁${NC} ${lc} lines → references/detail.md"
        fi
        echo -e "  ${G}📄${NC} → skills/${skill}/SKILL.md  [${lc} lines]"
      else
        echo -e "  ${Y}⚠️${NC}  skills/${skill}/SKILL.md exists — skipped"
      fi

      # Templates → assets/
      local tmpl="$utils_dir/context/${skill}-templates.md"
      if [[ -f "$tmpl" ]]; then
        cp "$tmpl" "$sd/assets/${skill}-template.md"
        echo -e "     ${G}📦${NC} → assets/${skill}-template.md"
      fi

      # Trees file → trees/
      local tree="$utils_dir/trees/${skill}.md"
      if [[ -f "$tree" && ! -f "$sd/trees/${skill}.md" ]]; then
        cp "$tree" "$sd/trees/"
        echo -e "     ${G}🌳${NC} → trees/${skill}.md"
      fi
    done

    # Scripts → match to skill by filename similarity, fallback to agent-memory
    if [[ -d "$utils_dir/scripts" ]]; then
      for f in "$utils_dir/scripts"/*; do
        [[ -f "$f" ]] || continue
        local sn; sn=$(basename "$f" | sed 's/\.[^.]*$//')
        local placed=false
        for skill in "${!skill_map[@]}"; do
          if echo "$sn" | grep -qi "$skill" || echo "$skill" | grep -qi "$sn"; then
            cp "$f" "$dst/skills/$skill/scripts/"
            echo -e "  ${G}🔧${NC} $(basename "$f") → skills/${skill}/scripts/"
            placed=true; break
          fi
        done
        if ! $placed; then
          mkdir -p ".claude/agent-memory/${name}/scripts"
          cp "$f" ".claude/agent-memory/${name}/scripts/"
          echo -e "  ${Y}⚠️${NC}  $(basename "$f") → agent-memory/${name}/scripts/ (no skill match)"
        fi
      done
    fi

    # Memory → agent-memory/
    if [[ -d "$utils_dir/memory" ]]; then
      mkdir -p ".claude/agent-memory/${name}"
      cp "$utils_dir/memory"/*.md ".claude/agent-memory/${name}/" 2>/dev/null || true
      echo -e "  ${G}📝${NC} → .claude/agent-memory/${name}/"
    fi
  fi

  echo -e "\n${B}Scaffold complete.${NC}"
  echo -e "${Y}Next: /convert-from-copilot ${agent_file}${NC}  in Claude Code to finish.\n"
}
