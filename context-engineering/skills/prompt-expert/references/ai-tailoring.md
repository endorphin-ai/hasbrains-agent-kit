# AI-Specific Prompt Tailoring

Platform quirks, syntax preferences, and concrete examples for each major AI.

---

## Claude (Anthropic)

**Best for:** Complex reasoning, long documents, structured analysis, code, writing.

**What works well:**

- XML tags to separate sections — Claude parses these reliably
- `<thinking>` tag to force reasoning before answer
- Long, detailed system prompts — Claude handles them well
- Negative constraints ("never", "do not") — high compliance

**Syntax pattern:**

```
<role>
You are [ROLE]. [1-2 sentences describing behavior.]
</role>

<instructions>
TASK: [What to do]

RULES:
- ALWAYS [behavior]
- NEVER [behavior]
</instructions>

<format>
- Structure: [list / paragraph / JSON]
- Length: [short / medium / exact word count]
- Tone: [formal / casual]
</format>

<context>
[PLACEHOLDER: paste your content here]
</context>
```

**Tips:**

- Put the most important instruction last — Claude has recency bias
- Use `<thinking>` for math, logic, multi-step analysis
- Explicit "do not apologize", "do not add disclaimers" reduces hedging

---

## Gemini (Google)

**Best for:** Factual research, summarization, multimodal (text + image), Google Workspace integration.

**What works well:**

- Markdown headers (##, ###) to structure prompts
- Explicit numbered steps
- Clear "Output format:" section
- Concrete examples

**Syntax pattern:**

```
## Role
You are [ROLE]. [Purpose.]

## Task
[Imperative description of what to do.]

## Input
[PLACEHOLDER: user will provide X]

## Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Output format
- Structure: [format]
- Length: [length]
- Tone: [tone]

## Constraints
- Never [rule 1]
- Always [rule 2]
```

**Tips:**

- Gemini responds well to "think step by step" for reasoning tasks
- For Google Workspace: reference specific apps ("in Google Docs format")
- Shorter prompts often work better than very long ones

---

## ChatGPT / GPT-4 (OpenAI)

**Best for:** Conversational tasks, coding, creative writing, general-purpose assistance.

**What works well:**

- Strong role assignment in system prompt
- Few-shot examples (2-3 input/output pairs) — very effective
- Numbered constraint lists
- "Respond only with..." to control output format

**System prompt pattern:**

```
You are [ROLE], a [description].

Your job: [core task in 1 sentence].

Rules:
1. Always [rule]
2. Never [rule]
3. [rule]

Output format: [explicit format description]
```

**User prompt pattern:**

```
[TASK INSTRUCTION]

Input: [PLACEHOLDER]

Respond only with [format]. Do not include [unwanted element].
```

**Few-shot example pattern:**

```
Examples of correct output:

Input: [example 1]
Output: [expected output 1]

Input: [example 2]
Output: [expected output 2]

Now do the same for:
Input: [PLACEHOLDER]
```

**Tips:**

- Few-shot examples are the single highest-ROI technique for GPT models
- "Respond only with X" is very effective for format control
- Temperature guidance: mention "be precise" for factual, "be creative" for generative

---

## Copilot — GitHub (Microsoft)

**Best for:** Code generation, code review, refactoring, documentation, test writing.

**What works well:**

- Explicit language and framework context
- Acceptance criteria style output spec
- Reference to file structure or existing patterns
- Concrete input (paste the code directly in the prompt)

**Syntax pattern:**

```
TASK: [What to do with the code]

LANGUAGE: [Python / TypeScript / Go / etc.]
FRAMEWORK: [React / FastAPI / etc.]
STYLE: [PEP8 / Airbnb / project conventions]

INPUT:
[PLACEHOLDER: paste code here]

REQUIREMENTS:
- [Requirement 1]
- [Requirement 2]

OUTPUT:
- Return: [what to produce]
- Format: [inline comments / full file / diff]
- Include: [tests / docstrings / types]
- Do NOT change: [what to preserve]
```

**Tips:**

- Always specify what NOT to change — prevents over-editing
- Include test requirements explicitly or it will skip them
- "Explain your changes" produces better-reasoned output

---

## Copilot — Microsoft 365 (Microsoft)

**Best for:** Email drafting, document summarization, meeting notes, Excel formulas, PowerPoint outlines.

**What works well:**

- Action-oriented, short prompts
- Reference to specific M365 app context
- Explicit output length ("3 bullet points", "1 paragraph")
- Tone specification for business context

**Syntax pattern:**

```
[ACTION VERB] [OBJECT] for [PURPOSE].

Context: [PLACEHOLDER: paste email / document / data]

Output:
- Format: [bullet list / email / table / summary]
- Length: [short / 3 bullets / 1 paragraph / under 100 words]
- Tone: [professional / friendly / executive]

Constraints:
- Do not include [unwanted element]
- Focus only on [specific aspect]
```

**Tips:**

- Keep prompts short — M365 Copilot has a limited effective context window
- Always specify tone — business context varies widely
- For emails: specify recipient role ("to a client", "to my team")

---

## Universal / AI-Agnostic

Use when the target AI is unknown or the prompt must work across multiple platforms.

**Rules:**

- Plain imperative English only — no platform-specific syntax
- No XML tags, no markdown headers (some platforms don't parse them)
- Numbered lists for steps and rules — universally readable
- Keep it short — optimize for the most constrained platform

**Pattern:**

```
You are [ROLE]. [1 sentence purpose.]

Your task: [What to do — imperative]

Input: [PLACEHOLDER]

Always:
1. [Required behavior]
2. [Required behavior]

Never:
1. [Prohibited behavior]
2. [Prohibited behavior]

Output: [format] of [length] in [tone] tone.
```
