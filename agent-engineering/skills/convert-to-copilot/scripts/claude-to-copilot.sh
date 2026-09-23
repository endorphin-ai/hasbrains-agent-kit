#!/usr/bin/env bash
# claude-to-copilot.sh — scaffold Claude Code agent → Copilot structure
# Sourced by convert-agents.sh. Requires lib-extract.sh to be sourced first.
#
# Creates:
#   .github/agents/{name}.agent.md       ← placeholder (Claude transforms content)
#   .copilot_utils/{name}/context/        ← skill knowledge files
#   .copilot_utils/{name}/trees/          ← skill decision tree files
#   .copilot_utils/{name}/scripts/        ← scripts from skills
#   .copilot_utils/{name}/memory/         ← agent memory files

claude_to_copilot() {
  local agent_file="$AGENT_FILE"
  local cmd_file="${CMD_FILE:-}"
  local agent_name
  agent_name=$(extract_fm "$agent_file" "name")
  [[ -z "$agent_name" ]] && agent_name=$(norm "$(basename "$agent_file" .md)")

  echo -e "${B}=== Claude → Copilot: ${agent_name} ===${NC}\n"

  local agent_dir=".copilot_utils/${agent_name}"
  mkdir -p ".github/agents" \
           "${agent_dir}/context" \
           "${agent_dir}/trees" \
           "${agent_dir}/scripts" \
           "${agent_dir}/memory"

  # --- Copy agent as placeholder ---
  cp "$agent_file" ".github/agents/${agent_name}.agent.md"
  echo -e "  ${G}✅${NC} → .github/agents/${agent_name}.agent.md  (scaffold — /convert-to-copilot to finish)"

  # --- Note command to absorb ---
  if [[ -n "$cmd_file" && -f "$cmd_file" ]]; then
    local cmd_name; cmd_name=$(extract_fm "$cmd_file" "name")
    local arg_hint; arg_hint=$(extract_fm "$cmd_file" "argument-hint")
    echo -e "  ${Y}🔗${NC} /${cmd_name} (${arg_hint:-no argument-hint}) → merge into agent description"
  fi

  # --- Process skills ---
  local skills=()
  while IFS= read -r skill; do
    [[ -n "$skill" ]] && skills+=("$skill")
  done < <(extract_skills "$agent_file")

  if [[ ${#skills[@]} -eq 0 ]]; then
    echo -e "  ${Y}⚠️${NC}  No skills: in frontmatter — provide skill paths manually"
  fi

  local dst="${CLAUDE_DIR:-$HOME/.claude}"
  for skill in "${skills[@]}"; do
    local sd=""
    for sp in "$dst/skills/$skill" ".claude/skills/$skill"; do
      [[ -d "$sp" ]] && sd="$sp" && break
    done
    if [[ -z "$sd" ]]; then
      echo -e "  ${R}❌${NC} Skill '$skill' not found"; continue
    fi

    echo -e "  ${G}📦${NC} Skill: $skill"

    # SKILL.md → classify as context or trees
    if [[ -f "$sd/SKILL.md" ]]; then
      local dest_type; dest_type=$(classify_skill "$sd/SKILL.md")
      cp "$sd/SKILL.md" "${agent_dir}/${dest_type}/${skill}.md"
      echo -e "     ${G}$([ "$dest_type" = "trees" ] && echo "🌳" || echo "📄")${NC} SKILL.md → ${dest_type}/${skill}.md"
    fi

    # references/ → flatten into context/ (appended)
    if [[ -d "$sd/references" ]]; then
      for f in "$sd/references"/*.md; do
        [[ -f "$f" ]] || continue
        local bn; bn=$(basename "$f")
        if echo "$bn" | grep -qiE 'template|schema|format'; then
          cat "$f" >> "${agent_dir}/context/${skill}-templates.md"
          echo -e "     ${G}📎${NC} references/${bn} → context/${skill}-templates.md"
        else
          cat "$f" >> "${agent_dir}/context/${skill}.md"
          echo -e "     ${G}📎${NC} references/${bn} → appended to context/${skill}.md"
        fi
      done
    fi

    # assets/ → context/*-templates.md
    if [[ -d "$sd/assets" ]]; then
      for f in "$sd/assets"/*.md; do
        [[ -f "$f" ]] || continue
        local bn; bn=$(basename "$f")
        cat "$f" >> "${agent_dir}/context/${skill}-templates.md"
        echo -e "     ${G}📄${NC} assets/${bn} → context/${skill}-templates.md"
      done
    fi

    # trees/ subdirectory
    if [[ -d "$sd/trees" ]]; then
      for f in "$sd/trees"/*.md; do
        [[ -f "$f" ]] || continue
        cp "$f" "${agent_dir}/trees/"
        echo -e "     ${G}🌳${NC} trees/$(basename "$f") → trees/"
      done
    fi

    # scripts/
    if [[ -d "$sd/scripts" ]]; then
      for f in "$sd/scripts"/*; do
        [[ -f "$f" ]] || continue
        cp "$f" "${agent_dir}/scripts/"
        echo -e "     ${G}🔧${NC} scripts/$(basename "$f") → scripts/"
      done
    fi
  done

  # --- Memory ---
  local mem_dir="${CLAUDE_DIR:-$HOME/.claude}/agent-memory/${agent_name}"
  if [[ -d "$mem_dir" ]]; then
    cp "$mem_dir"/*.md "${agent_dir}/memory/" 2>/dev/null || true
    echo -e "  ${G}📝${NC} agent-memory → .copilot_utils/${agent_name}/memory/"
  fi

  echo -e "\n${B}Scaffold complete.${NC}"
  echo -e "Created:"
  echo -e "  .github/agents/${agent_name}.agent.md"
  find "${agent_dir}" -type f | sort | while read -r f; do
    echo -e "    ${f#.copilot_utils/${agent_name}/}"
  done
  echo ""
  echo -e "${Y}Next: /convert-to-copilot ${agent_file}${NC}  in Claude Code to finish.\n"
}
