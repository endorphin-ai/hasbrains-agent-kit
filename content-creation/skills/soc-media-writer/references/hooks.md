# Hooks: Scroll Disruption Mechanics

The hook is the single highest-leverage element in any piece. On a fast-scrolling feed you have roughly **1.7 seconds** to convince a viewer to stay. For video, the verbal hook and the visual hook fire in sequence and must reinforce each other.

## Contents

- The 1.7-second decision window
- Visual pattern interrupts (the first frame)
- Verbal hook categories + copy-paste formulas
- Pairing visual + verbal
- How many hooks to produce

---

## The 1.7-second decision window

The brain processes visual information faster than spoken or written words, so the order of operations is fixed:

```
0.0–1.0s  → Eye processes the visual (fastest channel) — the frame must already be disruptive
1.0–3.0s  → Ear registers the verbal hook — the spoken line lands
3.0–5.0s  → On-screen captions confirm value — for the ~70% watching with sound OFF
```

Two consequences that must shape every video opener:

- **The first frame cannot be a "warm-up."** No slow intros, no logo sting, no "hey guys." Start mid-value.
- **Always write the opening on-screen text**, not just the spoken line. ~70% of social video is watched muted; silent viewers decide on text alone.

---

## Visual pattern interrupts (the first frame)

A pattern interrupt breaks the visual rhythm of the feed. Use at least one in frame one:

- **Dynamic physical motion** — start mid-action (tossing an object toward camera, walking briskly, already doing the thing). Skips the warm-up and drops the viewer into the scene.
- **Proximity / framing alteration** — an unexpected close-up, dramatic zoom, or unusual angle signals "something is happening here."
- **Immediate text-on-screen** — bold, high-contrast overlay in frame one acts as a headline. Essential for muted viewing.
- **Visual transition / comparison** — a side-by-side or before/after creates instant curiosity.

After the open, **refresh the visual every 3–5 seconds** with an edit trigger (cut, subtle zoom, graphic pop-up, b-roll insert, SFX) to keep attention from decaying. (Cadence tightens for shorter videos — see `video-scripting.md`.)

---

## Verbal hook categories + formulas

Match the category to the niche and the viewer avatar. The most effective hooks use behavioral triggers — curiosity gaps and loss aversion — to make the viewer need the rest of the video.

### Curiosity Gap

Open an incomplete or surprising loop the brain wants to close.

- `"I tried [X] so you don't have to."`
- `"The secret [authority figure] uses to achieve [desired result]."`
- `"The reason [common paradigm] is actually [shocking reality]."`

### Loss Aversion ("negative" hooks)

Surface a mistake, risk, or wasted effort — viewers act harder to avoid loss than to chase gain.

- `"Stop doing [common activity] if you want [desired outcome]."`
- `"You're wasting your money on [activity]."`
- `"The biggest mistake most [role]s make with [topic]:"`

### Contrarian

Challenge accepted advice to spark debate and comments (comments feed the algorithm).

- `"[Popular notion] is a lie. Here's what actually works:"`
- `"Unpopular opinion: [contrarian take]. Here's why:"`
- `"I'm going to get hate for this, but [contrarian observation]."`

Contrarian hooks historically drove outsized engagement by attacking industry norms — e.g. Rand Fishkin's "Why Good Unique Content Needs to Die," Matt Cutts' "The Decay and Fall of Guest Blogging," and Gary Vaynerchuk's "Numbers Don't Matter, Influence Does." The mechanism: a strong, well-reasoned stand against common advice builds instant authority and triggers debate. Only use contrarian when you can actually back the claim — an indefensible contrarian hook destroys trust.

### "The Why" Hook (narrative incongruity)

Present an immediate, glaring incongruity or an unexplained phenomenon. The brain enters active problem-solving mode to close the cognitive gap.

- `"[Bizarre outcome]. Here's what actually happened."`
- `"[Expected thing] didn't work. [Unexpected thing] did. Why?"`
- `"I [did counterintuitive action]. [Surprising result]."`

Mechanism: unlike Curiosity Gap (which opens a loop), the Why hook presents an apparent _impossibility_ or contradiction — a logical violation the brain needs to resolve. Strong for HasBrainsAI where counterintuitive technical outcomes are the content.

### In Medias Res / Action Hook

Drop the viewer directly into a scene already in motion — high-stakes, no preamble. Bypasses setup entirely and establishes stakes through action rather than explanation.

- `"Three seconds ago, the entire prod database went read-only."`
- `"I'm mid-deploy and the test suite just lit up red."`
- Visual: hands already in motion, something already breaking or succeeding.

Mechanism: works because the human brain experiences narrative tension before it understands context. The viewer is inside the story before they've decided whether to care — they resolve their confusion by watching forward. Pairs powerfully with the In Medias Res structure (see `video-scripting.md`).

### Contradicting Emotions Hook

Juxtapose two conflicting psychological states in the opening line — signals deep characterization and hidden complexity, creating immediate intrigue.

- `"I finally got everything I was chasing. And I wanted to quit."`
- `"This PR got merged. I've never felt worse about shipping code."`
- `"Day 66. My PR max went up 40%. I'm starting over from Day 1."`

Mechanism: emotional contradiction signals there is a _story_ here — not just information. The viewer stays to resolve the contradiction. Best for transformation arcs, Total 66 content, and any "lessons learned" format.

---

## Chekhov's Gun: seeding payoffs at the hook level

A hook is not just a scroll stopper — it is a **narrative contract**. If the hook introduces a specific element (a claim, a number, an object, a person), the video must pay it off. This is Chekhov's Gun applied to short-form: _if you mention a pistol in frame one, it must fire by frame sixty._

Practical rule: every specific detail named in the hook (e.g. "the one config change," "the 3-minute fix," "what my coach told me") must appear explicitly in the content as a named payoff. Failing this creates "clickbait trust decay" — viewers finish the video feeling cheated rather than satisfied, which tanks completion rate and send-to-friend behavior. The hook seeds the loop; the body closes it, deliberately and on-screen.

---

## Pairing visual + verbal

Every video hook is a pair. Write both:

| Element              | Example                                     |
| -------------------- | ------------------------------------------- |
| **Visual (frame 1)** | Close-up, mid-motion, bold overlay text     |
| **On-screen text**   | The headline a muted viewer reads           |
| **Spoken line**      | The verbal hook (one of the formulas above) |

**Worked pair (Loss Aversion, dev-tools niche):**

- Visual: hands already typing, hard cut to a red ❌ over a config file
- On-screen text: `STOP writing agents like this`
- Spoken: `"Stop hand-wiring your agents if you want them to scale — here's the pattern that replaced it."`

---

## How many hooks to produce

- **User asks for hooks / a hook bank** → produce 3–5 across different categories, labeled by category, so they can A/B test.
- **High-stakes lead** (paid post, launch, pillar video) → offer 3, recommend one.
- **Inside a full script** → commit to the single strongest hook and justify it in the EXPLANATION, but you may note one alternate.

When testing, the hook is the first thing to swap if a video underperforms its retention target — packaging (hook + first frame) explains most of the variance, not the body.
