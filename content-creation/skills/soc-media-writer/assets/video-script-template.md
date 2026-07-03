# Video Script Template — Dialogue + Scenario + Explanation

Read this before producing your first video output. A video request always returns **all three sections** in this order. Below the template is a fully worked example so you can calibrate format and density.

---

## THE TEMPLATE

```
[Title — Platform — Duration — Word count: N / cap]

## 1. VIDEO DIALOGUE
[Spoken voiceover only. No stage directions, no overlay text — just what the
 voice says. Must be within the word budget (duration × 2.5).]

## 2. VIDEO SCENARIO
| Time | VISUAL (shot / b-roll / on-screen text / cut) | AUDIO (spoken + SFX) |
|------|----------------------------------------------|----------------------|
| 0.0–1.0s | [frame-1 pattern interrupt + overlay text] ★ | [hook line] |
| ...      | [mark ⟳ each visual cut, ★ each re-hook]      | ...                  |
Legend: ⟳ visual refresh · ★ retention checkpoint/re-hook
Safe zone: [platform container, e.g. Reels central 840×1350]

## 3. EXPLANATION
- Framework: [name + originator] — why it fits the funnel stage
- Hook: [category] — the behavioral trigger used
- Retention schedule: where ★ beats land (cadence) and why
- Platform fit: word budget used, retention target, safe-zone notes
- If it underperforms: the first levers to pull
```

---

## WORKED EXAMPLE

_Brief: 30-second Instagram Reel for HasBrainsAI on why senior engineers should spec agents before building. Re-hook every ~9s._

**Why Your AI Agents Break in Production — Reel — 30s — Word count: 72 / 75**

### 1. VIDEO DIALOGUE

Stop building agents that only work in the demo. Here's why most break the second they hit production — and the three-line fix. Most teams wire the agent first and think about failure later. That's backwards. Spec the failure modes before you write a single tool call. Step one: list every way it can fail silently. Step two: write a check for each. Step three: gate the agent behind those checks. Do that, and production stops being a surprise. Comment SPEC and I'll DM you the template.

### 2. VIDEO SCENARIO

| Time     | VISUAL                                                                                                      | AUDIO                                                                            |
| -------- | ----------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| 0.0–1.0s | Hard cut to hands already typing, then ❌ slams over a config file. Overlay: `YOUR AGENT IS LYING TO YOU` ★ | "Stop building agents that only work in the demo."                               |
| 1.0–3.0s | ⟳ Zoom to a green "demo passed" badge flipping to red in prod                                               | "Here's why most break the second they hit production — and the three-line fix." |
| 3.0–6.0s | ⟳ Screen-record: agent calling a tool; b-roll of a Slack 2am alert                                          | "Most teams wire the agent first and think about failure later."                 |
| ~9s      | ⟳ Hard cut to face, lean-in close-up. Overlay: `BACKWARDS` ★ tease                                          | "That's backwards. Spec the failure modes before you write a single tool call."  |
| 9–13s    | ⟳ Overlay list builds: `1. silent failures`                                                                 | "Step one: list every way it can fail silently."                                 |
| 13–17s   | ⟳ Overlay adds `2. a check each`                                                                            | "Step two: write a check for each."                                              |
| ~18s     | ⟳ Overlay adds `3. gate the agent` ★ tension bump                                                           | "Step three: gate the agent behind those checks."                                |
| 18–24s   | ⟳ Split-screen: chaotic logs → clean passing gate                                                           | "Do that, and production stops being a surprise."                                |
| ~27s     | ⟳ Cut to face, point at camera. Overlay: `COMMENT "SPEC"` ★ payoff turn                                     | "Comment SPEC and I'll DM you the template."                                     |
| 27–30s   | ⟳ Hold CTA card, subtle zoom                                                                                | (SFX: soft chime)                                                                |

Legend: ⟳ visual refresh · ★ retention checkpoint/re-hook
Safe zone: Instagram Reels central 840×1350 — CTA card kept above the bottom 320 px caption strip.

### 3. EXPLANATION

- **Framework:** PAS (Problem–Agitate–Solution) for the arc, with Hormozi's **Promise/Proof/Path** inside the value section (the 3 steps are the Path). MOFU fit — viewer already feels the "works in demo, breaks in prod" pain.
- **Hook:** Loss Aversion ("Stop doing [X] if you want [Y]") paired with a frame-1 motion + bold-text pattern interrupt, because Reels autoplay and ~70% muted viewing mean the _visual_ + overlay must carry the first second.
- **Retention schedule:** ★ checkpoints at ~0s (hook loop), ~9s ("that's backwards" hard turn), ~18s (step-3 tension bump), ~27s (CTA payoff) — the user's ~9s cadence. ⟳ visual cuts every ~2–3s per the 30s cadence. The "three-line fix" open loop from the hint isn't paid off until the steps land, keeping a thread alive throughout.
- **Platform fit:** 72/75 words (within `duration × 2.5`). Built for Reels' DM-share + save signals (the comment-keyword CTA drives DMs) and ≥30–40% completion. Comment-to-DM CTA instead of a link to avoid off-network penalty.
- **If it underperforms:** swap the hook first (try the Contrarian variant: "Speccing agents is a waste of time — until you see this"); if completion is low, cut the split-screen at 18–24s to tighten to 27s of content.

```

```
