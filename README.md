# HasBrains Agent Kit — Production Claude Code Skills, Agents & Commands

The battle-tested Claude Code kit behind [HasBrainsAI](https://www.youtube.com/@HasBrainsAI) — agent skills, subagents, and slash commands for building **production multi-agent systems**. Every piece of this kit is used daily to ship real agent pipelines, not generated in bulk.

Works with **Claude Code**, and skills follow the portable [Agent Skills standard](https://code.claude.com/docs/en/skills) used by Codex, Cursor, and Gemini CLI.

## Install (one command)

```
/plugin marketplace add endorphin-ai/hasbrains-agent-kit
```

Then install only what you need:

```
/plugin install agent-engineering@hasbrains-agent-kit
/plugin install context-engineering@hasbrains-agent-kit
/plugin install content-creation@hasbrains-agent-kit
/plugin install teaching@hasbrains-agent-kit
/plugin install web-dev@hasbrains-agent-kit
```

## Install a single skill

Don't need a whole plugin? Every skill is a self-contained folder following the portable Agent Skills standard, so you can cherry-pick one with the [`skills` CLI](https://github.com/vercel-labs/skills):

```
npx skills add endorphin-ai/hasbrains-agent-kit --full-depth
```

It lists every skill in the kit and lets you pick the ones you want. To skip the picker, name the skill directly:

```
npx skills add endorphin-ai/hasbrains-agent-kit --full-depth --skill <skill-name>
```

Skills install into the current project's `.claude/skills/` by default; add `-g` to install globally to `~/.claude/skills/`. This also works for Cursor, Codex, and other agents that support the skills standard.

Or skip tooling entirely — a skill is just a folder:

```
cp -r teaching/skills/<skill-name> ~/.claude/skills/
```

## What's inside

| Plugin | What it does |
|---|---|
| [`agent-engineering`](agent-engineering) | Engineering discipline for AI agent systems. Four always-on principles, test-driven development, verification-before-completion, system-architecture playbooks, docs/-native project management. |
| [`context-engineering`](context-engineering) | Context engineering for AI agents. AI-optimized second-brain skills, durable pipeline state for multi-agent handoffs, expert prompt building. |
| [`content-creation`](content-creation) | Content engine for technical creators. Social posts and video scripts engineered around named copywriting frameworks, scroll-stopping hooks, and retention mechanics. |
| [`teaching`](teaching) | Interactive AI teacher. `/repo-to-course` turns any codebase into a structured tutorial course — markdown, GitHub Pages site, or interactive HTML. |
| [`web-dev`](web-dev) | Multi-agent web dev pipeline. The designer ↔ frontend contract: freeze approved mockups into a canonical oracle, port them 1:1 on any stack, verify with screenshot-based design-diff gates. |

## Using the prompts

Raw prompt library lives in [`prompts/`](prompts) — standalone prompts that don't map to a skill or command. Prompts aren't installed, they're plain markdown; two ways to use one:

- **Paste it** — copy the file's content straight into your conversation.
- **Make it a slash command** — copy the file into `~/.claude/commands/` (or your project's `.claude/commands/`) and it becomes invocable by filename, e.g. `my-prompt.md` → `/my-prompt`.

## Design principles

This kit follows a strict separation of concerns:

- **Agents** encode behavior and procedure only
- **Skills** hold reusable know-how
- **Project-specific facts** (stack, paths, commands, naming) stay in your project's own config — never baked into agents or skills

That's why these plugins drop into any codebase without modification.

## Why trust this

Skills execute code in your environment — you should only install from sources you trust. This kit is maintained by [Andrew Novykov](https://github.com/andrewnovykov), builder behind HasBrainsAI. Every skill and agent here is used in production on real projects, and most have a walkthrough video on the channel showing exactly how they work and what's inside.

## Watch it in action

Deep dives on the architecture behind this kit — multi-agent orchestration, spec-driven development, agentic engineering for senior engineers:

**[youtube.com/@HasBrainsAI](https://www.youtube.com/@HasBrainsAI)**

## License

MIT — see [LICENSE](LICENSE).
