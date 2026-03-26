# Repo → Course Generator

> A reusable prompt system for turning any codebase into a structured tutorial course.
> Supports 3 output formats: **Markdown**, **GitHub Pages**, and **Interactive HTML**.

---

## How to Use

1. **Feed the repo** — Paste your repo tree + key files, or point Claude Code at the directory
2. **Run Phase 1** — Analyze the repo (same for all formats)
3. **Run Phase 2** — Generate course outline (same for all formats)
4. **Run Phase 3** — Write tutorials with your chosen output format
5. **Run Phase 4** (optional) — Quality check

### Choose Your Output

Add this line to the START of Phase 3 to control the format:

```
## Output Format: [markdown | github-pages | html-interactive]
```

| Format             | Best For                        | What You Get                                     |
| ------------------ | ------------------------------- | ------------------------------------------------ |
| `markdown`         | READMEs, wikis, Notion, docs    | One `.md` file per tutorial + index              |
| `github-pages`     | Hosted course site              | Full Jekyll site with nav, progress, themes      |
| `html-interactive` | Standalone sharing, offline use | Single HTML file with sidebar, search, dark mode |

---

## Phase 1: Repo Analysis

```
You are a senior developer educator preparing to build a tutorial course from a codebase.

Analyze this repository thoroughly and produce a structured knowledge map.

## Step 1 — File Inventory

List every file and directory. Classify each as:
- **Core**: Essential to understanding what the project does (main logic, models, routes, services)
- **Supporting**: Helpers, utilities, middleware, config, types
- **Peripheral**: Tests, CI/CD, docs, scripts, lockfiles

## Step 2 — Architecture Map

- Identify the entry point(s) (e.g., main.go, index.ts, app.py)
- Trace the request/data flow from entry to output
- Map which files import/depend on which (dependency graph)
- Identify layers (e.g., HTTP → service → repository → database)

## Step 3 — Concept Extraction

Identify every distinct concept, pattern, or technique used in this codebase.
For each concept:
- Name it clearly (e.g., "middleware chain", "repository pattern", "JWT authentication")
- Rate complexity: 1 (beginner) → 5 (advanced)
- List which files demonstrate it
- List prerequisite concepts (what must be understood first)

## Step 4 — Learning Path

Determine the optimal order to teach these concepts so that:
- No concept is introduced before its prerequisites
- The learner can run something as early as possible
- Complexity increases gradually
- Related concepts are grouped into natural "tutorial-sized" chunks (15-45 min each)

## Output Format

Respond with this exact JSON structure:

{
  "project_name": "...",
  "summary": "One paragraph describing what this project does and why",
  "tech_stack": ["language", "framework", "database", "..."],
  "entry_points": ["path/to/main/file"],
  "architecture_layers": [
    { "name": "HTTP/API", "files": ["..."], "purpose": "..." }
  ],
  "concepts": [
    {
      "id": "c01",
      "name": "Project Setup & Configuration",
      "complexity": 1,
      "prerequisites": [],
      "files": ["path/to/file"],
      "description": "What this concept covers",
      "key_patterns": ["specific pattern or technique used"]
    }
  ],
  "learning_order": ["c01", "c02", "..."],
  "tutorial_groups": [
    {
      "tutorial_number": 1,
      "title": "Suggested tutorial title",
      "concepts": ["c01", "c02"],
      "estimated_minutes": 30,
      "milestone": "What the learner can do/run after this tutorial"
    }
  ]
}
```

---

## Phase 2: Course Outline

```
You are a technical course designer. Using the repo analysis below,
generate a detailed course outline.

<repo_analysis>
{{PASTE PHASE 1 JSON OUTPUT HERE}}
</repo_analysis>

## Rules

1. Each tutorial must:
   - Take 15-45 minutes to complete
   - Focus on ONE primary concept (can touch supporting concepts)
   - End with a working, runnable milestone the learner can verify
   - Build on previous tutorials (never reference something not yet taught)

2. Follow this progression arc:
   - Tutorial 1: "What are we building?" — Project overview, goals, architecture bird's eye view
   - Tutorial 2: Setup, dependencies, first run (learner gets it running locally)
   - Tutorials 3-N: Build understanding layer by layer, from simple to complex
   - Final tutorial: Full system walkthrough connecting everything together

3. For each tutorial in the outline, specify:
   - Title
   - Primary concept(s) covered
   - Prerequisites (which prior tutorials)
   - Estimated time
   - Files the learner will explore
   - Milestone (what they can do/run/verify at the end)
   - Challenge (a stretch exercise)

## Output

# Course: [Course Title]

## Target Audience
Who is this for? What should they already know?

## By the End of This Course
What will the learner understand and be able to do?

## Tutorial Outline

### Tutorial 1: [Title]
- **Time**: X minutes
- **Difficulty**: Beginner
- **Concepts**: concept_id_1, concept_id_2
- **Prerequisites**: None
- **Key Files**: `path/to/file1`, `path/to/file2`
- **Milestone**: "Learner can ___"
- **Challenge**: "Try ___"

### Tutorial 2: [Title]
...

## Checkpoint Branches
- `tutorial-01-start`, `tutorial-01-complete`
- `tutorial-02-start`, `tutorial-02-complete`
```

---

## Phase 3: Write Tutorials

Pick ONE of the three options below based on your desired output format.

---

### Option A — `markdown`

```
You are a technical writer creating hands-on tutorials.

## Output Format: markdown

Generate ONE .md file per tutorial, named:
`01-tutorial-title.md`, `02-tutorial-title.md`, etc.

Also generate an `INDEX.md` that links all tutorials with a progress overview.

<course_outline>
{{PASTE PHASE 2 OUTPUT HERE}}
</course_outline>

<repo_analysis>
{{PASTE PHASE 1 JSON OUTPUT HERE}}
</repo_analysis>

## Per-Tutorial File Structure

# Tutorial N: [Title]

> **Time**: X min | **Difficulty**: Beginner/Intermediate/Advanced
> **Prerequisites**: [Tutorial 1](./01-tutorial-title.md)

## What You'll Learn
- 3-5 skills/concepts

## Context
WHY this matters. WHERE it fits. WHAT problem it solves.

## Walkthrough

### Step 1: [Action Verb]
Point to exact file. Show code. Explain AFTER showing.

### Step 2: [Action Verb]
...

## Try It Yourself
Hands-on challenge with hints.

## Key Takeaways
- 3-5 transferable bullets

## What's Next
Bridge sentence to next tutorial.

---

## INDEX.md Structure

# [Course Title]

[Summary paragraph]

| # | Title | Time | Difficulty |
|---|-------|------|------------|
| 1 | [Title](./01-title.md) | 20 min | Beginner |
| 2 | [Title](./02-title.md) | 30 min | Intermediate |

## Writing Rules
1. Reference REAL files and code. Never fabricate.
2. Explain WHY, not just WHAT.
3. Show code first, then explain.
4. One concept at a time.
5. End each tutorial with a runnable verification step.
```

---

### Option B — `github-pages`

```
You are a technical writer creating a tutorial course as a GitHub Pages site.

## Output Format: github-pages

Generate a complete Jekyll site structure ready for `gh-pages` deployment.

<course_outline>
{{PASTE PHASE 2 OUTPUT HERE}}
</course_outline>

<repo_analysis>
{{PASTE PHASE 1 JSON OUTPUT HERE}}
</repo_analysis>

## File Structure

docs/
├── _config.yml
├── index.md
├── _tutorials/
│   ├── 01-getting-started.md
│   ├── 02-first-feature.md
│   └── ...
├── _layouts/
│   ├── default.html
│   └── tutorial.html
├── _includes/
│   ├── nav.html
│   └── progress.html
├── assets/css/
│   └── style.scss
└── _data/
    └── tutorials.yml

## _config.yml

title: "[Course Title]"
description: "[One-line description]"
baseurl: "/repo-name"
theme: null
plugins:
  - jekyll-seo-tag
collections:
  tutorials:
    output: true
    permalink: /tutorials/:slug/
defaults:
  - scope:
      path: ""
      type: tutorials
    values:
      layout: tutorial

## _data/tutorials.yml

For each tutorial:
- number: N
  title: "Title"
  slug: "NN-slug"
  time: minutes
  difficulty: beginner|intermediate|advanced
  concepts: ["concept1", "concept2"]
  prerequisites: [prior tutorial numbers]

## Tutorial Front Matter

---
layout: tutorial
title: "Tutorial Title"
number: 1
time: 20
difficulty: beginner
concepts: ["setup"]
prerequisites: []
milestone: "Learner can run the project locally"
---

## _layouts/tutorial.html Requirements

- Sidebar navigation: all tutorials listed, current one highlighted
- Progress bar at top (Tutorial X of N)
- Previous / Next buttons at bottom
- Time + difficulty badges
- Auto-generated table of contents from H2/H3
- Syntax highlighting via Rouge
- Mobile-responsive (sidebar collapses)

## _layouts/default.html Requirements

- Course title header with GitHub repo link
- Dark/light mode toggle (CSS prefers-color-scheme)
- Clean, professional typography

## index.md (Landing Page)

- Course title + description
- Visual tutorial roadmap
- "Start Course" CTA button → Tutorial 1
- Tech stack badges
- Target audience
- Total time estimate

## assets/css/style.scss Requirements

- Professional color scheme (not default Jekyll)
- Code block styling with line numbers
- Responsive sidebar
- Progress bar styling
- Difficulty badge colors (green/yellow/red)
- Smooth transitions
- Print-friendly @media rules

## Writing Rules
1. Reference REAL files and code. Never fabricate.
2. Explain WHY, not just WHAT.
3. Show code first, then explain.
4. Use Jekyll code fences with language tags.
5. End each tutorial with a runnable verification step.
6. Use relative links between tutorials.
```

---

### Option C — `html-interactive`

```
You are a technical writer creating an interactive tutorial course
as a single self-contained HTML file.

## Output Format: html-interactive

Generate ONE self-contained HTML file with embedded CSS, JS, and all content.
No external dependencies except Google Fonts and optionally Prism.js CDN.

<course_outline>
{{PASTE PHASE 2 OUTPUT HERE}}
</course_outline>

<repo_analysis>
{{PASTE PHASE 1 JSON OUTPUT HERE}}
</repo_analysis>

## Required Features

### Layout
- Fixed sidebar (collapsible on mobile) with full tutorial list
- Main content area with scroll-snap between tutorials
- Sticky top bar: course title + progress bar + dark mode toggle

### Sidebar Navigation
- All tutorials listed with: number, title, time, difficulty dot (green/yellow/red)
- Checkmark icon on completed tutorials
- Current tutorial highlighted with accent color
- Search box at top — filters tutorials by title + content (client-side)
- "Reset Progress" in sidebar footer

### Progress Tracking
- Overall progress bar: "X of N completed"
- "Mark as Complete" button at end of each tutorial
- All progress persisted to localStorage
- Completion confetti or subtle animation on marking complete

### Code Blocks
- Syntax highlighted (Prism.js via CDN: https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/)
- "Copy" button top-right of each block
- File path label above block (styled as a tab: `src/auth/middleware.ts`)
- Line numbers for blocks > 5 lines

### Dark Mode
- Toggle button in top bar (sun/moon icon)
- Respects `prefers-color-scheme` on first load
- Persists choice to localStorage
- Smooth transition between modes

### Keyboard Shortcuts
- ← → : Previous / Next tutorial
- Escape : Toggle sidebar
- / : Focus search

### Tutorial Section HTML Structure

<section id="tutorial-N" class="tutorial" data-difficulty="beginner" data-time="20">
  <div class="tutorial-header">
    <span class="tutorial-number">01</span>
    <h2>Tutorial Title</h2>
    <div class="meta">
      <span class="time-badge">20 min</span>
      <span class="diff-badge beginner">Beginner</span>
    </div>
  </div>

  <div class="objectives">
    <h3>What You'll Learn</h3>
    <ul><li>...</li></ul>
  </div>

  <div class="context">
    <h3>Context</h3>
    <p>...</p>
  </div>

  <div class="walkthrough">
    <h3>Walkthrough</h3>

    <div class="step">
      <h4>Step 1: [Action]</h4>
      <div class="code-block">
        <div class="code-header">
          <span class="file-path">src/auth/middleware.ts</span>
          <button class="copy-btn" onclick="copyCode(this)">Copy</button>
        </div>
        <pre><code class="language-typescript">// real code here</code></pre>
      </div>
      <p>Explanation of the code above...</p>
    </div>
  </div>

  <div class="challenge">
    <h3>Try It Yourself</h3>
    <div class="challenge-card">
      <p>Challenge description</p>
      <details>
        <summary>Hint</summary>
        <p>Hint text</p>
      </details>
    </div>
  </div>

  <div class="takeaways">
    <h3>Key Takeaways</h3>
    <ul><li>...</li></ul>
  </div>

  <div class="tutorial-footer">
    <button class="nav-btn prev" onclick="navigateTo(N-1)">← Previous</button>
    <button class="complete-btn" onclick="markComplete(N)">Mark Complete ✓</button>
    <button class="nav-btn next" onclick="navigateTo(N+1)">Next →</button>
  </div>
</section>

## Design Requirements

- Choose a distinctive, professional palette — NOT generic Bootstrap blue
- Suggested font pairing: JetBrains Mono (code) + Plus Jakarta Sans or DM Sans (body)
- Subtle box shadows, rounded corners, layered depth
- Smooth CSS transitions (0.2-0.3s ease)
- Responsive: sidebar → hamburger menu at < 768px
- Print: @media print hides nav, shows all tutorials sequentially
- Keep total file < 500KB
- Vanilla JS only — no frameworks

## Writing Rules
1. Reference REAL files and code. Never fabricate.
2. Explain WHY, not just WHAT.
3. Show code first, then explain.
4. One concept at a time.
5. End each tutorial with a runnable verification step.
6. Active voice throughout.
```

---

## Phase 4: Quality Check (Optional)

```
Review this course for:

1. **Prerequisite Violations**: Does any tutorial reference something not yet taught?
2. **Coverage Gaps**: Are there repo concepts NOT covered?
3. **Scope Problems**: Any tutorial covering too much or too little?
4. **Milestone Verification**: Can the learner run something after each tutorial?
5. **Difficulty Curve**: Any sudden jumps in complexity?
6. **Missing Context**: Would a learner be confused at any point?
7. **Format-Specific Checks**:
   - markdown: Do all relative links resolve? Is INDEX.md complete?
   - github-pages: Is front matter valid? Do collection paths match _config.yml?
   - html-interactive: Do nav links work? Is localStorage logic correct? Does dark mode toggle properly?

For each issue:
- **Location**: Tutorial #, section
- **Problem**: Description
- **Fix**: Specific suggestion

Rate: Ready / Needs Minor Fixes / Needs Major Revision
```

---

## Quick-Start: One-Shot (Small Repos < 50 files)

```
You are a developer educator. Analyze this codebase and create a complete
tutorial course.

## Output Format: [markdown | github-pages | html-interactive]

1. Analyze the repo: architecture, concepts, dependencies, learning order.
2. Generate tutorials:
   - 15-45 minutes each, one primary concept each
   - Runnable milestone at each end
   - Progression: setup → fundamentals → advanced → full picture
   - Reference REAL files/code only
   - Explain WHY, not just WHAT

3. Format-specific rules:

   **If markdown**: One .md per tutorial + INDEX.md. Named: 01-title.md, 02-title.md.

   **If github-pages**: Full Jekyll site in docs/. Includes _config.yml, _layouts/,
   _data/tutorials.yml, sidebar nav, progress tracking, prev/next nav, responsive CSS.

   **If html-interactive**: Single self-contained HTML file. Sidebar nav, dark mode toggle,
   progress tracking (localStorage), syntax-highlighted code blocks with copy buttons,
   search, keyboard shortcuts (←→ navigate, / search, Esc sidebar). Vanilla JS, Google
   Fonts, Prism.js CDN. Under 500KB.

Generate the complete course now.
```

---

## Tips

| Scenario             | Format             | Why                                            |
| -------------------- | ------------------ | ---------------------------------------------- |
| Internal docs / wiki | `markdown`         | Paste into Notion, Confluence, GitHub wiki     |
| Open-source project  | `github-pages`     | Free hosting, auto-deploys, looks professional |
| Workshop / offline   | `html-interactive` | One file, works offline, share via Slack/email |
| Client deliverable   | `html-interactive` | Self-contained, impressive, no setup needed    |

### Customization Hooks (add to Phase 3)

```
- "Assume the reader knows TypeScript but not this framework."
- "Focus on transferable patterns, not project-specific details."
- "Include 'Common Mistakes' callouts for tricky sections."
- "Add 'Deep Dive' collapsible sections for advanced readers."
- "Write for a junior developer joining this team."
- "Include Mermaid diagrams for architecture sections."
- "Add a glossary of terms as the final section."
- "Include estimated reading time per section, not just per tutorial."
```
