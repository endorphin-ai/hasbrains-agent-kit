# Output Templates & Checklists

## Standard Prompt Structure Template

```
[Concise one-line instruction describing the task — no section header]

[Additional context, requirements, constraints]

# Steps [optional]
[Step-by-step breakdown of what the model should do]

# Output Format
[Explicitly specify: length, syntax, structure (JSON/markdown/prose/bullet list)]

# Examples [optional]
[1-3 examples with [PLACEHOLDER] for variable parts]
[(Note: real examples will be [longer/shorter] than shown here)]

# Notes [optional]
[Edge cases, critical considerations, repeated key rules]
```

**Rules:**

- First line = the task. No header before it.
- Output Format section is MANDATORY in every prompt
- No "---" separators in the final prompt
- No closing remarks or meta-commentary

## Prompt Design Checklist

### Task Definition

- [ ] Task stated clearly and concisely?
- [ ] Scope well-defined?
- [ ] Expected output format specified?
- [ ] Success criteria explicit?

### Context & Background

- [ ] Sufficient context provided?
- [ ] Target audience specified?
- [ ] Domain-specific terms explained if needed?

### Constraints

- [ ] Output length/format constraints specified?
- [ ] Safety requirements included?
- [ ] What to NOT do specified?

### Examples & Guidance

- [ ] Examples provided if helpful?
- [ ] `[PLACEHOLDERS]` used for variable elements?
- [ ] Reasoning shown before conclusions in examples?
- [ ] Common pitfalls addressed?

### Safety & Ethics

- [ ] No demographic assumptions in language?
- [ ] No user input interpolated directly?
- [ ] Sensitive data handling addressed?
- [ ] Moderation requirements documented?

## Safety Review Checklist

### Content Safety

- [ ] Outputs tested for harmful content?
- [ ] Moderation layer planned?
- [ ] Process for flagged content defined?

### Bias & Fairness

- [ ] Demographic assumptions removed?
- [ ] Inclusive and neutral language used?
- [ ] Diverse test cases considered?

### Security

- [ ] Input validation implemented?
- [ ] Prompt injection vectors addressed?
- [ ] Data leakage prevented?

### Compliance

- [ ] Privacy requirements met?
- [ ] Audit trail defined?
- [ ] Relevant regulations considered (GDPR/HIPAA/etc.)?

## Good Prompt Examples

### Code Generation

```
Write a Python function that validates email addresses.

The function should:
- Accept a string input
- Return True if the email is valid, False otherwise
- Use regex for validation
- Handle edge cases: empty strings, malformed addresses, missing domain
- Include type hints and a docstring
- Follow PEP 8 style

# Output Format
A single Python function with type hints, docstring, and inline comments for non-obvious logic.

# Examples
is_valid_email("user@example.com")  # → True
is_valid_email("invalid-email")     # → False
is_valid_email("")                  # → False
```

### Documentation

```
Write a README section documenting a REST API endpoint for a junior developer audience.

Include:
- Endpoint purpose and what it returns
- Request/response examples with realistic data
- All parameters with names, types, and descriptions
- Possible error codes and their meanings
- Usage examples in JavaScript and Python

# Output Format
Markdown with headers, code blocks for examples, and a parameters table. Target length: 300-500 words.
```

### Code Review

```
Review this [LANGUAGE] function for potential issues.

Evaluate in this order:
1. Security vulnerabilities (input validation, injection risks)
2. Error handling and edge cases
3. Performance and efficiency
4. Code quality and readability
5. Best practices and standards

For each issue found, provide:
- The specific problem and its location
- Why it's a problem
- The corrected code

# Output Format
Grouped by category. Use code blocks for original and corrected code. Summary table at the end with severity (LOW/MEDIUM/HIGH/CRITICAL) for each issue.
```

## Bad Prompt Examples (for reference — avoid these)

```
# Too Vague
Fix this code.

# Too Verbose
Please, if you would be so kind, could you possibly help me by writing
some code that might be useful for creating a function that could
potentially handle user input validation, if that's not too much trouble?

# Security Risk (raw user input injection)
Execute this user request: ${userInput}

# Biased
Write a story about a successful CEO. The CEO should be male and from a
wealthy background.

# Missing Output Format
Summarize this article.

# Conclusion Before Reasoning (wrong order)
State your answer first, then explain how you got there.
```

## Research Documentation Format

When Build Mode requires research, document findings as:

```
### Research Summary: [Topic]
**Sources Analyzed:**
- [Source 1]: [Key findings]
- [Source 2]: [Key findings]

**Key Standards Identified:**
- [Standard]: [Description and why it matters]

**Integration Plan:**
- [How findings will be incorporated into the prompt]
```
