# docs-project-management

> Run an entire project from the repo's `docs/` folder — no external issue tracker, no ticket system.

**Plugin:** `agent-engineering` — `/plugin install agent-engineering@hasbrains-agent-kit`

## Why use it

- Project state lives in a tracker the code doesn't know about, and the two drift apart the day after kickoff.
- Agents invent their own folders, link wording and status values, so nothing cross-references.
- "What was actually done?" has no answer that a reviewer can read in the diff.

## What it does

- The work-item **taxonomy**: roadmap → PRD → TRD → epics → user stories → test cases → bugs, each in its own `docs/` folder.
- The **link graph** as relative markdown links — user story `part of` epic, test case `is tested by` story, bug `blocks` story, PRD↔TRD.
- The YAML-frontmatter **status lifecycle** + the bookend rule: move `status:` forward when you start, again when you finish.
- The mandatory **test-case template** and the **bug + RCA report** format.
- The **team work-reporting** convention: one session folder per run, every agent bookends a start/completion report there.

## Benefits

- **Your tracker ships with your code.** Work item = markdown file. Status = a diff. History = git.
- **Nothing drifts.** Requirements, tests and bugs live next to what they describe.
- **Reviewable progress.** "What got done?" is answered by the PR itself.
- **Still navigable at 300 files**, because every agent writes to the same model.
- **Zero tooling cost.** No tracker, no license, no sync job — day one of a new project.

---

Made by **HasBrains** — https://hasbrains.com/
