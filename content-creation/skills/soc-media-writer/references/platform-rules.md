# Platform Rules: Algorithms, Retention Targets & Safe Zones

Each network ranks content on a distinct set of signals. Optimize for the platform you're writing for — a script tuned for TikTok loop rate is not tuned for X reply weight.

## Contents

- Per-platform algorithm rules
- Retention / engagement targets (the numbers to hit)
- Realistic benchmarks for new accounts
- Video safe zones (pixel-exact)

---

## Per-platform algorithm rules

### YouTube Shorts

- Three-phase seeding pipeline: tests on a small group, then matches high performers to broader topic clusters.
- **Absolute watch time and completed views** are now the primary ranking signals (they replaced simple swipe-away rate).
- Autoplay previews play the first **1–2 seconds without sound** on hover → the opening _visual_ hook is what earns the click.
- Longer Shorts generate more total watch time, so **30–45s videos are favored over 15s clips**, provided they clear ~50–65% average percentage viewed.

### TikTok

- Pure interest graph: every video is tested on a small audience by metadata, visual signals, and audio. **Follower count barely affects initial distribution.**
- Prioritizes **completion rate, direct shares, and loop rate.**
- Creator Rewards Program enforces a **60-second minimum** — structure those scripts carefully to hold retention over the longer runtime.

### Instagram Reels

- Integrated with Meta's social graph; prioritizes **DM shares and saves over likes.**
- Rewards content that sparks private conversations (DM forwards), the existing creator–viewer relationship, and **trending audio** for new-audience reach.

### Twitter / X

- Open-source recommendation algorithm using weighted scores in the "For You" feed; rewards **interactive conversation** over passive views.
- Groups users into **SimClusters** (shared-interest communities) and amplifies posts with deep engagement inside a cluster before expanding to adjacent ones.

---

## Retention / engagement targets

| Metric                  | How it's measured         | Viral-reach target          | Primary distribution trigger   |
| ----------------------- | ------------------------- | --------------------------- | ------------------------------ |
| Shorts retention (<30s) | Average % viewed          | **≥ 65%** avg view duration | high-retention watch-time gate |
| Shorts retention (>30s) | Average % viewed          | **≥ 50%** avg view duration | high-retention watch-time gate |
| TikTok loop rate        | Complete-rewatch rate     | **35–50%** completion       | completion rate & watch time   |
| Reels engagement        | Saves + DM shares ÷ views | **30–40%** completion       | DM shares & saves              |
| X reply                 | 9.0× training weight      | high reply-to-view ratio    | conversation & thread depth    |
| X retweet               | 1.0× training weight      | stable share-to-like ratio  | standalone value               |
| X like                  | 1.0× training weight      | broad endorsement           | emotional resonance            |

**Implication for X:** a reply is worth ~9× a like in the ranking model — write posts that _invite a response_ (a question, a take to argue with), not just a nod.

---

## Realistic benchmarks for new accounts

Measure against platform averages, not viral outliers. Per a Metricool analysis of ~82,000 accounts, the global average across all YouTube videos (Shorts + long-form) is ~**687 views.**

Expected-view bands by subscriber tier:

```
< 1,000 subs          →  50–500 views
1,000–10,000 subs     →  200–2,000 views
10,000–100,000 subs   →  1,000–10,000 views
```

Short-form distribution is meritocratic: each video is judged on its own retention, so a new channel can outperform an established one by delivering exceptional retention on a single video. Set expectations here — don't promise virality.

---

## Video safe zones (1080 × 1920 vertical canvas)

Keep all text overlays, logos, faces, and CTAs inside the safe container so native UI doesn't cover them. Specify placement in the scenario.

| Platform            | Top unsafe                 | Bottom unsafe              | Side unsafe      | Safe container                                     |
| ------------------- | -------------------------- | -------------------------- | ---------------- | -------------------------------------------------- |
| **Instagram Reels** | 108 px (profile/feed crop) | 320 px (captions/comments) | L 60 / R 120 px  | central **840 × 1350** box                         |
| **YouTube Shorts**  | 380 px (search bar/UI)     | 380 px (interaction bar)   | L 60 / R 120 px  | central **840 × 1160** box (slightly left-shifted) |
| **TikTok**          | 160 px (search/tabs)       | 480 px (description/icons) | L 120 / R 120 px | central **840 × 1280** box                         |

Rule of thumb: TikTok has the most aggressive bottom UI (480 px) — keep captions higher; Reels' bottom 320 px eats lower-thirds; Shorts crops both ends hard. When in doubt, keep critical text vertically centered.
