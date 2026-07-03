# teaching

Interactive AI teaching pipeline — adaptive lessons, student model, quiz mode, course generation.

## Commands

- `/teaching:repo-to-course [markdown | github-pages | html-interactive] [repo-path]` — turn any codebase into a structured tutorial course. Analyzes the repo, builds a prerequisite-ordered outline, writes 15-45 min tutorials with runnable milestones, then runs a quality check. Three output formats: plain markdown files, a deployable Jekyll (GitHub Pages) site, or a single self-contained interactive HTML file.

## Components

Drop your files here:

- `skills/` — e.g. `skills/teach-me/SKILL.md` plus its reference files
- `agents/` — agent definition markdown files
- `commands/` — slash command markdown files (e.g. `teach-me.md` → `/teaching:teach-me`)

## Install

```
/plugin install teaching@hasbrains-agent-kit
```
