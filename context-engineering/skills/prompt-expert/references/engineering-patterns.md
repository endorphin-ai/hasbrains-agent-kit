# Prompt Engineering Patterns

## Prompting Patterns

### Zero-Shot

Ask without examples. Best for simple, well-understood tasks.

```
Convert this temperature from Celsius to Fahrenheit: 25°C
```

### Few-Shot

Provide 2-3 input/output examples. Best for complex or domain-specific tasks.

```
Convert temperatures from Celsius to Fahrenheit:

Input: 0°C → Output: 32°F
Input: 100°C → Output: 212°F

Now convert: 37°C
```

### Chain-of-Thought (CoT)

Ask the model to reason step-by-step before concluding. Reasoning ALWAYS comes before conclusion.

```
Solve this step by step:
Problem: [X]
1. Identify what's being asked
2. Break into sub-problems
3. Solve each sub-problem
4. State the conclusion
```

### Role Prompting

Assign expertise context. Sets expected knowledge level and perspective.

```
You are a senior security architect with 15 years of experience in cybersecurity. Review this authentication design and identify vulnerabilities.
```

### When to Use Each

| Pattern          | Use When                               |
| ---------------- | -------------------------------------- |
| Zero-Shot        | Simple task, clear expectations        |
| Few-Shot         | Format matters, domain-specific output |
| Chain-of-Thought | Complex reasoning, multi-step problems |
| Role Prompting   | Specialized knowledge needed           |

## Anti-Patterns

### Ambiguity

```
BAD:  Fix this code.
GOOD: Review this JavaScript function for error handling, input validation, and memory leaks. Provide specific fixes with explanations.
```

### Verbosity

```
BAD:  Please, if you would be so kind, could you possibly help me...
GOOD: Write a function to validate user email addresses. Return true if valid, false otherwise.
```

### Missing Output Format

```
BAD:  Summarize this article.
GOOD: Summarize this article in 3 bullet points, focusing on key insights and actionable takeaways. Each bullet: max 20 words.
```

### Conclusion Before Reasoning

```
BAD:  Answer first, then explain your reasoning.
GOOD: Think through the problem step by step, then state your conclusion.
```

### Overfitting

```
BAD:  Write code exactly like this: [specific example]
GOOD: Write a function following these principles: [general principles]
```

## Iterative Development

### A/B Testing Process

1. Create two prompt variations
2. Test with representative inputs
3. Evaluate outputs for quality, safety, relevance
4. Choose best performing version
5. Document results and reasoning

### Evaluation Metrics

- **Accuracy** — output matches expectations
- **Relevance** — output addresses the input
- **Safety** — no harmful or biased content
- **Consistency** — similar inputs → similar outputs
- **Efficiency** — concise without losing quality

### Versioning

- Track prompt versions and changes
- Document reasoning behind changes
- Maintain backward compatibility when possible

## Quality Standards

| Issue               | Weak                           | Strong                                                             |
| ------------------- | ------------------------------ | ------------------------------------------------------------------ |
| Vague task          | "Write good code"              | "Create REST API with GET/POST using Flask, PEP 8 style"           |
| No format           | (none)                         | "Output JSON with keys: title, summary, steps[]"                   |
| No success criteria | "Make it good"                 | "Complete when all 5 criteria addressed, output validates as JSON" |
| Conflicting rules   | Two contradicting instructions | One clear rule, sourced from authority                             |

## Output Format Guidance

- Always explicitly specify output format
- For classification/structured data → JSON (no ``` wrapping unless requested)
- Specify length: "1-2 sentences", "bullet list of 3-5 items", "under 200 words"
- Use markdown for readability in prose outputs
- Do NOT use ``` code blocks in prompts unless specifically requested

## High-ROI Techniques (often missed)

### Output Anchoring

Force format compliance from the first token:

```
Start your response with: "Analysis:"
End your response with: "Confidence: [HIGH/MEDIUM/LOW]"
```

### Negative Constraints

Among the highest-ROI prompt additions. Prevents the most common failures:

```
NEVER apologize or add disclaimers
NEVER repeat the question back to the user
NEVER say "Great question!" or similar filler
NEVER produce more than [N] items unless asked
```

### Grounding Instructions (for RAG / document tasks)

```
Answer ONLY using the provided context below.
If the answer is not in the context, say: "I don't have that information."
Do not use any outside knowledge.
```

### Multi-turn vs Single-shot Design

- **Single-shot**: all context in one prompt, one response. Use for: transformations, analysis, generation.
- **Multi-turn**: system prompt sets persona; each user message is a new request. Use for: assistants, chatbots, ongoing tasks.
- Key difference: single-shot needs complete context every time; multi-turn relies on conversation history.

### Persona Calibration

Strong persona → use for: customer-facing bots, specialized experts, consistent voice.
No persona → use for: internal tools, data processing, format conversion.
Rule of thumb: if the user will have a _relationship_ with the AI, give it a persona.
