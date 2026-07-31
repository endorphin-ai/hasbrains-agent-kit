# AI Product UX — Inputs, Wayfinding, Tuners, Governors, Trust, Identifiers

> **Source**: adapted from [tommyjepsen/awesome-ux-skills](https://github.com/tommyjepsen/awesome-ux-skills) (`general-design-review.md`).
> **Load when**: Reviewing an AI/agentic feature — the scope/trust/control/accountability questions plus the input-pattern, wayfinding, tuner, governor, trust-builder and identifier checklists.

---

## AI Product Review

AI features need all normal UX checks plus additional checks for scope, trust, control, and accountability.

Start with these questions:

- What is the AI acting on?
- What can it change, send, delete, spend, remember, or reveal?
- What is the worst case if it is wrong?
- Can the user understand, steer, stop, undo, and verify the AI?
- Is the AI clearly disclosed as AI?

### AI Inputs

Pick the input pattern that fits the task:

| User need | Good pattern |
|---|---|
| Explore freely | Open input |
| Repeat a structured task | Template or madlibs |
| Fill many fields or records | Auto-fill with preview |
| Edit selected content | Inline action or inpainting |
| Try again | Regenerate with recoverable versions |
| Build from a seed | Expand |
| Change structure | Restructure |
| Change style | Restyle |
| Run a workflow | Chained action |
| Compress source material | Summary |
| Interpret across sources | Synthesis |

Universal rules:

- Make scope explicit before running.
- Preview changes before committing.
- Preserve undo/version history.
- Mark AI-generated or AI-edited content until accepted.
- Show cost for bulk, long-running, or chained work.

### AI Wayfinding

Blank AI inputs are rarely enough. Help users understand what is possible.

Use:

- **Initial CTAs** that are specific, not "ask anything."
- **Suggestions** tied to the current context.
- **Examples and galleries** that show useful outcomes.
- **Templates** for complex repeatable tasks.
- **Nudges** only when they match the user's current state.
- **Follow-ups** after generation to refine, extend, or act.
- **Prompt details** when users can learn from or remix good outputs.
- **Randomize** for creative exploration, not serious high-stakes tasks.

Prefer contextual guidance over generic onboarding.

### AI Tuners

Tuners let users shape AI behavior without becoming prompt engineers.

Useful tuner families:

- **Attachments**: ground the AI in specific files, URLs, selections, or examples.
- **Connectors**: link AI to live systems such as Drive, Slack, Notion, CRM, or code.
- **Filters**: restrict sources or exclude unwanted terms, styles, or content.
- **Model management**: expose active model and allow switching when useful.
- **Modes**: bundle behavior into understandable presets like research, creative, tutor, or agent.
- **Parameters**: expose advanced knobs only when users need them.
- **Preset styles**: curated style choices with previews.
- **Saved styles**: reusable personal or team style profiles.
- **Voice and tone**: control how generated output sounds, separate from the AI's own personality.

Review principle: active state must always be visible. Hidden model, mode, source, style, or autonomy level damages trust.

### AI Governors

Governors keep users meaningfully in control as AI becomes more autonomous.

Use stronger governors when actions are expensive, irreversible, public, security-sensitive, or hard to clean up.

Patterns to consider:

- **Action plan**: show intended steps before execution.
- **Verification**: require approval before risky actions.
- **Controls**: stop, pause, resume, queue, or cancel.
- **Cost estimates**: show credits, time, tokens, or money before committing.
- **Draft mode**: cheap lower-fidelity run before final output.
- **Sample response**: full-quality preview on a small subset.
- **Citations and references**: connect claims to source material.
- **Stream of thought**: show plan, execution state, tool calls, and evidence.
- **Memory controls**: show what is remembered and allow edit/delete/off.
- **Branches and variations**: explore without overwriting the original.
- **Shared vision**: show what the AI can currently see or access.

Calibrate friction:

- High-stakes and infrequent: strong confirmation.
- Low-stakes and frequent: passive indicators or undo.
- High-stakes and frequent: rules, preferences, and configurable approval.

### AI Trust Builders

Trust means users neither under-trust nor over-trust the system.

Review for:

- **Caveats**: clear, specific limits near the moment of decision.
- **Consent**: explicit permission for recording, analysis, training, or sharing.
- **Data ownership**: clear controls for retention, training, deletion, and export.
- **Disclosure**: label AI actors, AI actions, and AI-generated content.
- **Footprints**: visible and logged traces of prompts, sources, models, approvals, costs, and edits.
- **Incognito mode**: private sessions that do not affect memory, training, or history.
- **Watermarking/provenance**: durable origin signals for shared synthetic content.

Do not rely on disclaimers alone. Pair warnings with evidence, controls, and recoverability.

### AI Identifiers

AI identity should be coherent with the product and honest about capability.

Review:

- **Name**: Does it set the right expectation? Is AI disclosure still clear?
- **Avatar**: Does it communicate state without implying false human competence?
- **Color**: Does it distinguish AI affordances accessibly and consistently?
- **Iconography**: Are common AI actions recognizable, or are icons decorative noise?
- **Personality**: Does the tone serve the task without over-validating, misleading, or encouraging unhealthy attachment?

The identity should help users understand the AI's role, not turn it into a novelty layer.
