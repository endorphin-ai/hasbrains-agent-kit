After adding a new skill
Nothing needs registering — Claude Code auto-discovers every skills/<name>/SKILL.md inside a plugin, and plugin.json doesn't list skills. So after dropping in e.g. teaching/skills/quiz-builder/SKILL.md, the checklist is just housekeeping:

Bump the plugin's version in teaching/.claude-plugin/plugin.json (e.g. 1.0.0 → 1.1.0) so people who already installed it see an update available.
Mention it in that plugin's README so it's discoverable when browsing.
Run claude plugin validate . — a two-second sanity check.
Commit and push. Users pick it up with /plugin marketplace update hasbrains-agent-kit and updating the plugin from the /plugin menu.
Installing just one skill
The plugin marketplace can't do that — a plugin is the smallest install unit, so /plugin install teaching@… always brings the whole category. But there are two ways people can grab a single skill, because skills follow the portable Agent Skills standard (each is a self-contained folder):

The skills CLI (same one mattpocock/skills uses) supports exactly this:

npx skills add endorphin-ai/hasbrains-agent-kit --skill quiz-builder
It copies just that skill into the user's .claude/skills/ (project) or ~/.claude/skills/ with -g, and also works for Cursor/Codex users. One caveat: the CLI scans standard layouts like a root skills/ folder; with your <category>/skills/<name>/ layout, users may need to add --full-depth for it to find them.

Plain copy — since a skill is just a folder:

cp -r teaching/skills/quiz-builder ~/.claude/skills/
So the two distribution paths complement each other: the marketplace for "give me the whole teaching toolkit," npx skills for cherry-picking. If you want, I can add an "Install a single skill" section to the README documenting the npx skills command.
