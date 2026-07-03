# Video Scripting: Pacing, Structure & the Retention Engine

Short-form scripts live or die on pacing and retention. This file covers the math that caps script length, the two-column scenario format, the narrative spines that distribute value across the runtime, and the retention beat engine.

## Contents

- Word-budget math (the hard cap)
- Visual cut cadence by duration
- The two-column scenario format
- Narrative spines: HHVCTA, ABT/ABYT, Pixar Story Spine
- The Quips / Tips / Clips funnel
- The retention beat engine (every-N-second re-hooks)

---

## Word-budget math (the hard cap)

Industry speaking pace is **140–160 words per minute**. To prevent rushed delivery, scripts follow:

```
Word Budget  ≤  Target Duration (seconds) × 2.5
```

| Duration | Word cap      | Structural objective                                           |
| -------- | ------------- | -------------------------------------------------------------- |
| 15s      | 35–38 words   | Single "quip": one insight with an immediate punchline/outcome |
| 30s      | 70–75 words   | 3-step practical walkthrough with high-contrast text overlays  |
| 60s      | 140–150 words | Full narrative arc: setup, conflict, proof, recap              |

Enforce the cap. If the draft runs over, cut — do not speed up the read. Count the words in the DIALOGUE output and state the count.

---

## Visual cut cadence by duration

The visual must refresh constantly to hold attention. Cadence scales with length:

| Duration | Visual cut frequency |
| -------- | -------------------- |
| 15s      | every 1.0–1.5s       |
| 30s      | every 2.0–3.0s       |
| 60s      | every 3.0–4.0s       |

A "cut" = any visual edit trigger: hard cut, subtle zoom, b-roll insert, graphic pop-up, text-overlay change, or SFX. Mark each one in the scenario.

---

## The two-column scenario format

Professional creators separate spoken audio from visual cues so overlays, b-roll, angle changes, and SFX are timed precisely against the script. Always output the scenario as a timed table:

| Time     | VISUAL (shot / b-roll / on-screen text / cut) | AUDIO (spoken line + SFX) |
| -------- | --------------------------------------------- | ------------------------- |
| 0.0–1.0s | Pattern interrupt + bold overlay headline     | Hook line                 |
| 1.0–3.0s | Cut to demo / face; overlay confirms value    | Hint: what they'll get    |
| ...      | mark every cut and every retention beat       | spoken line               |

Flag beats inline:

- `⟳` = visual refresh (a cut per the cadence above)
- `★` = retention checkpoint / re-hook (see engine below)

Keep all on-screen text inside the platform safe zone (`platform-rules.md`).

---

## Narrative spines (distribute value — never back-load it)

Most viewers never reach the end, so value must be spread across the runtime. Map the script to one spine:

### HHVCTA — Hook, Hint, Value, Takeaway, Action

A how-to / educational flow that prevents drop-off:

- **Hook** (0–2s) — grab attention.
- **Hint** (2–5s) — preview what they'll learn (the open loop).
- **Value** (5–45s) — the main points, delivered.
- **Takeaway** (45–55s) — a quick summary of the lesson.
- **Action** (55–60s) — one clear CTA.

### ABT — And, But, Therefore (Randy Olson)

Turns a flat list of facts into a story by introducing tension. Cures "And-And-And" scripting (consecutive facts, no conflict).

- **And** — connect two relatable facts (the setup).
- **But** — introduce the problem/obstacle (the conflict).
- **Therefore** — resolve with a clear action/solution.

### ABYT — And, But, Yet, Therefore (expanded ABT)

Adds **Yet** — a compelling piece of evidence or a paradox — before the resolution, making the final "Therefore" more persuasive:

```
[Fact A] AND [Fact B]            → setup
        ↓
BUT [unexpected problem]          → conflict
        ↓
YET [compelling evidence/paradox] → nuance
        ↓
THEREFORE [solution / next step]  → resolution
```

### Pixar Story Spine (popularized by Brian McDonald, used at Pixar)

For longer narrative videos, case studies, and transformation arcs — converts a dull timeline into a story:

1. **Once upon a time** — the character and their world.
2. **Every day** — the status-quo routine.
3. **But one day** — the catalyst that disrupts the balance.
4. **Because of that** — the initial reaction and consequence.
5. **Because of that** — the next compounding challenge.
6. **Because of that** — tension building to the climax.
7. **Until finally** — the resolution of the climax.
8. **And ever since then** — the new normal + the core lesson.

Use it to reframe project updates or case studies as transformation stories.

---

## The Quips / Tips / Clips funnel

Match the scripting style to the viewer's relationship with the brand:

- **Quips (TOFU)** — fast, high-engagement, broad-reach; entertainment, surprising facts, relatable moments; no technical depth; built for shareability.
- **Tips (MOFU)** — deep, actionable, educational; step-by-step solutions that build trust and pull viewers into the community.
- **Clips (BOFU)** — behind-the-scenes, personal stories, struggles; build long-term loyalty among existing fans.

---

## Scene & Sequel: the micro-engine for narrative momentum

_Developed by Dwight Swain; popularized by Jim Butcher._ This is the structural reason some videos feel propulsive and others meander — the chain of cause and effect that makes each beat demand the next.

**Every segment of a video operates as either a Scene or a Sequel:**

### The Scene (action phase)

A real-time conflict beat with three required elements:

1. **Goal** — the POV subject enters with a clear, immediate objective (build this thing, prove this claim, fix this bug).
2. **Conflict** — an antagonistic force (an error, a misconception, a hard constraint) actively prevents easy success.
3. **Disaster/Outcome** — the segment must end on a complication, not a clean win. The three valid outcomes:
    - `"No"` — failure, requires a new plan (strongest cliffhanger)
    - `"Yes, but"` — success with a costly complication
    - `"No, and furthermore"` — failure plus a new crisis (escalation)

A `"Yes"` ending kills momentum. Use Disasters as chapter-end cliffhangers and mid-video re-hooks.

### The Sequel (reaction phase)

The decompression beat after a Disaster — the psychological connective tissue that makes the character's next move believable:

1. **Emotion** — visceral, immediate reaction (shock, frustration, dread).
2. **Review** — assess the new degraded state; inventory what's left.
3. **Dilemma** — two equally uncomfortable options.
4. **Choice** — the decision that sets the Goal for the next Scene.

### Pacing via Scene-to-Sequel ratio

This is the primary lever for _genre feel_ and _narrative velocity_:

- **High-velocity (action, launch, tech demos)** → drastically shorten or cut Sequels entirely. Jump from Disaster directly to a new Goal. The viewer feels breathless and urgent.
- **Reflective / transformation (Total 66 journey, case studies)** → expand Sequels. Lean into the emotional review and dilemma beats. Creates gravity and resonance.
- **Short-form default (≤60s)** → abbreviate Sequels to a single line or a visual beat (a pause, a cut to face, a text overlay with the reaction). The brain still needs the emotional moment; it just doesn't need 30 seconds of it.

---

## The Ticking Clock: sustained tension without external conflict

When there is no antagonist, a temporal deadline does the same structural work. A ticking clock forces characters to bypass rational deliberation and make impulsive, high-stakes decisions — which makes for inherently more compelling viewing.

Forms for social content:

- **Literal deadline** — "I had 48 hours to ship this before the demo." (forces urgency into the narrative)
- **Decay deadline** — a situation that gets worse with every second of inaction (a failing test suite, a body adaptation window closing on Day 66)
- **Countdown structure** — explicitly numbered segments ("Step 1 of 3") create artificial pressure and promise a finite payoff

The clock eliminates the "saggy middle" in longer videos: every action carries a measurable stake against the clock. Name the clock in the hook; close it in the payoff.

---

## Show vs. Tell: the Camera Test

_The diagnostic:_ if a movie camera cannot capture the detail as a visible, physical reality, it is _telling_. Telling compresses time but flattens engagement. Showing costs more words but earns attention.

**Telling (use for logistical connective tissue, transitions, and mundane exposition):**

> "The setup took three hours and the config was complicated."

**Showing (use for high-emotional-impact beats and turning points):**

> "Third hour. Fifteenth YAML edit. The service was still refusing to start."

**Camera Test rule for social scripts:** the hook and every retention checkpoint should _show_ (a specific, concrete, visualizable moment). Transitions and summaries can _tell_. Never tell a beat that is supposed to make the viewer feel something — show the detail and let them feel it themselves.

---

## Character arc compression: Want vs. Need in short-form

_From character theory (Hauge, McKee, Weiland)._ Even 60-second content is more compelling when the subject is pursuing one thing and discovering they needed something else. This is the fastest structure for transformation stories.

- **Want (external goal)** — the stated, visible objective the viewer tracks. ("I wanted to max out my snatch reps.")
- **Need (internal truth)** — what the character actually had to confront to get there, or what they found instead. ("What I needed was to stop treating rest as failure.")
- **The reveal** — the moment the Want and Need collide or converge. This is the emotional climax of any transformation video.

For Total 66: use Want/Need in every progress update and vox-pop. The Want is always the physical metric (reps, weight, day count); the Need is always the psychological or habitual truth that emerged. That contrast is what makes transformation content shareable — the viewer recognizes their own Need in yours.

For HasBrainsAI: the Want is the technical outcome (ship the feature, pass the eval); the Need is the architectural or philosophical truth that the engineer has to internalize (spec before code, trust the gate conditions). Same arc, different domain.

---

## The retention beat engine

Retention is a _placed schedule_, not a vibe. Build two layers into every script:

### Layer 1 — Visual refresh (every 3–5s; tighter for short videos)

Per the cadence table above. Prevents passive visual decay. Every refresh is a `⟳` in the scenario.

### Layer 2 — Retention checkpoint / re-hook (default every ~9s; configurable)

A _stronger_ interrupt that re-earns the decision to keep watching. Place a `★` at each checkpoint. Each one should do one of:

- **Open a new loop** — "but there's a catch I didn't see coming…"
- **Tease a payoff** — "the third one is the one that actually moved the needle…"
- **Bump the tension** — escalate the stakes or the cost of not knowing.
- **Hard turn** — "okay, forget everything I just said, because…"

**Default cadence is ~9 seconds** — honor the user's request. If the user specifies a different cadence ("re-hook every 6 seconds"), use theirs instead. The 3–5s visual refresh and the ~9s re-hook are complementary layers, not alternatives: visual cuts keep the eye busy; re-hooks keep the _story_ pulling forward.

### Building the schedule

1. Lay the spine (HHVCTA / ABT / Pixar) across the runtime.
2. Place `★` checkpoints at the chosen cadence (e.g. ~9s, 18s, 27s, …). Land each on a natural turn in the spine where possible.
3. Fill `⟳` visual cuts between them at the duration's cadence.
4. Verify the open loop from the Hint/hook isn't closed until the Takeaway — keep at least one unresolved thread alive at all times.

**Worked checkpoint map for a 30s video (re-hook ~every 9s):**

```
0–2s    HOOK (★ frame-1 pattern interrupt + open loop)
2–5s    HINT — preview the payoff
~9s     ★ tease: "the second step is where everyone gets it wrong"
~18s    ★ tension bump: "and skipping it costs you [stakes]"
~27s    ★ payoff turn into the takeaway
27–30s  TAKEAWAY + single CTA
(⟳ visual cut every ~2–3s throughout)
```

State the engineered retention target in the EXPLANATION (e.g. "built for ≥65% average view duration on Shorts under 30s" — see `platform-rules.md`).
