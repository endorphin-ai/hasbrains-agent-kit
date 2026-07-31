# The Eight Design Dimensions, Report Shape & Token Emission

> **Source**: adapted from [tommyjepsen/awesome-ux-skills](https://github.com/tommyjepsen/awesome-ux-skills) (`design-analysis.md`).
> **Load when**: Writing a design-analysis report — the eight dimensions, the report skeleton, the palette table, paste-ready token emission, the accuracy rules and the critique handoffs.

---

## Step 4 — Look at the image

**Always view the screenshot yourself before writing the report.** The JSON knows every font size on the page but cannot see that the H1 is competing with a badge, that the eye lands on the illustration first, or that the layout is a two-column split. Numbers plus eyes; neither alone.

Read the images in this order: `desktop-fold.png` (what a visitor meets), `desktop-full.png` (structure and rhythm), `mobile-fold.png` (what survives the squeeze).

Squint test: blur the page in your mind's eye. What is still legible is the real hierarchy — compare it against the type scale in the JSON. When the largest type is not the strongest visual element, say what is winning instead (a photo, a colored block, a bright button).

---

## The eight dimensions

Report on these. Skip a dimension when the input genuinely has nothing to say about it (a logo has no motion), and never pad a section to look complete.

### 1. Typography

- **Families and roles**: which face for display, body, UI, mono. Classify each: geometric sans, grotesque, humanist sans, transitional/old-style serif, didone, slab, mono, script, display. Name the actual family from `typography.families` and `webfonts` — and flag when the rendered family is a system fallback rather than the intended webfont (a `(unloaded)` status or a bare `Arial`/`Helvetica` on a designed page is the tell).
- **Scale**: list the sizes actually used, largest to smallest, and the ratio between steps (`64 / 40 / 24 / 16` ≈ 1.5–1.6, a major-third-ish scale). Say whether it is a tight scale (3–5 steps, disciplined) or sprawling (12 near-duplicate sizes, no system).
- **Weights**: how many, and how hierarchy is carried — by weight, size, color, or case.
- **Line height and measure**: line-height ratios per level (display ~1.0–1.2, body ~1.4–1.6) and the body measure from `runs[].measureCh` (~45–75ch is comfortable; over ~90ch is a wall). `measureCh` comes from the widest rendered line box, so a short label in a wide container reads short and a wrapped paragraph reads its true column; it assumes a 0.5em average advance, so treat it as ±10%. `runs[].lines` tells you how many line boxes a run occupies — a display headline wrapping to three lines is a layout fact worth reporting.
- **Tracking and case**: negative tracking on display type, positive tracking on small caps/eyebrows, `text-transform: uppercase` usage.
- **Pairing logic**: does the pairing contrast on classification (serif display + sans UI) or vary within one family? Is it a single-family system?

### 2. Color

- **Palette with roles**, using measured hexes: page background, surface/card, ink (primary text), muted text, border/hairline, primary accent, secondary accent, semantic (success/warning/danger). Every measured color carries an `oklch` value too, so the palette can be emitted as design tokens without hand conversion — see [Aligning to shadcn/ui tokens](#aligning-to-shadcnui-tokens). If `styles.json` reports `shadcn.detected`, name the system and read its tokens rather than inferring roles.
- **Area shares** from `palette[].share` — this is what separates "a green brand" from "a white page with a green button." Report the accent share explicitly.
- **Key and temperature**: light / mid / dark, warm / cool / neutral, and whether the neutrals are tinted (a warm off-white and warm grays is a deliberate choice worth naming).
- **Harmony**: monochrome, analogous, complementary, split-complementary, triadic, or neutral-plus-one-accent (the most common product-design answer).
- **Saturation strategy**: `averageChroma` plus whether accents are vivid or desaturated.
- **Contrast**: use `contrastPairs` for the real ratios of the dominant pairings, and name any body-text pairing under 4.5:1 or large-text pairing under 3:1. Keep it to a flag, not a full audit — hand off to the `accessibility` skill for that.
- **Gradients**: whether present, and whether they are brand-level or applied decoratively to buttons and cards.

### 3. Layout and composition

- **Container and grid**: content width from `space.commonWidths`, column structure from `space.gridTemplates` (computed styles resolve `repeat(4, 1fr)` to real px widths, so this gives both the count and the ratio — a `216px 1128px` template is a sidebar shell, `4 cols: 273px 273px 273px 273px` is a KPI row), gutters from `space.gaps`.
- **Structure**: the fold's anatomy (nav / eyebrow / headline / support / CTA / media) and the page's section sequence from `rowDensity`.
- **Alignment and balance**: left-aligned vs centered, `horizontalCentroid`, `mirrorSymmetry`, and whether asymmetry looks intentional.
- **Density and rhythm**: `inkCoverage`, section padding values, whether the vertical rhythm alternates (dense/airy) or repeats identically.
- **Focal path**: the order a viewer's eye takes, and what earns first fixation. Say what creates it — scale, isolation, color, or a face/direction in the imagery.
- **Fold economics**: what is above 900px, `page.folds` for total scroll depth.
- **Responsive behavior**: what changes between desktop and mobile — reflow, hidden elements, type scaling — and the `breakpoints` list. If `page.viewportMeta` is null, the mobile screenshot is a scaled desktop layout, not a mobile design; say so.

### 4. Imagery and media

- **Type**: photography, 3D render, vector illustration, product screenshot, screenshot-in-device-frame, abstract gradient/mesh, iconography, video, or none.
- **Treatment**: crop and aspect ratios from `media.images[].ratio`, corner radius, `object-fit`, duotone or color grading, cutout vs full-bleed vs contained, drop shadows, masks.
- **Subject and role**: does the imagery show the product, the user, a metaphor, or decoration? Does it carry information or fill space?
- **Text/image balance**: image count vs text volume; whether images anchor sections or interrupt them.
- **Iconography**: `svgCount`, stroke vs filled, corner and stroke weight consistency, whether icons share the type's weight.
- **Alt text**: how many images have real alt text (`media.images[].alt`) — a content-quality signal even in a design read.

### 5. Space and scale

- **Base unit**: infer from `space.gaps` and `space.paddings` — a clean 4/8px system shows up as clustered multiples; one-off values like `13px` and `27px` mean it was eyeballed.
- **Scale in use**: the actual ladder (`8 / 16 / 24 / 32 / 48 / 64 / 96`).
- **Inner vs outer**: component padding against section spacing. Grouping only reads when the gap inside a group is visibly smaller than the gap between groups.
- **Section rhythm**: vertical padding per section and whether it is consistent.

### 6. Shape, depth, and texture

- **Radii**: the values from `shape.radii` and whether they form a scale (`6 / 12 / 999`) or a scatter. Sharp, soft, or pill.
- **Elevation language**: hairline borders, shadows, both, or flat. Read `shape.shadows` — soft low-alpha layered shadows read as craft; a single `0 4px 20px rgba(0,0,0,0.5)` reads as a default.
- **Borders**: widths, colors, whether hairlines come from one neutral ramp.
- **Texture**: noise, grain, paper, blur/glass (`backdrop-filter`), patterns, or completely flat.

### 7. Motion (URL inputs)

From `motion`: which properties transition, durations, easings, and any keyframe animations with iteration counts. Note whether durations cluster in the 120–250ms UI range, whether `transition: all` appears (an intent smell), whether anything loops infinitely, and whether transitions animate `transform`/`opacity` or layout properties.

### 8. Voice and content design

Brief, from the text you can see: headline length and whether it makes a claim or a category statement, reading level, CTA label specificity ("Start a trial" vs "Submit"), sentence case vs Title Case, use of numbers and proof, and any placeholder text still in place. Design and copy set the tone together; a typography read that ignores the words is half a read.

---

## Output format

Structure the report like this. Lead with the signature so the user gets the gist in one line.

```markdown
## Design analysis — [what was analyzed]

**Style signature**: [one sentence — e.g. "Editorial serif display over a warm off-white,
neutral-plus-one-green palette, generous 12-column whitespace, no decoration."]

**Genre**: [e.g. Swiss/editorial · brutalist · neo-brutalist · glassmorphic · corporate SaaS ·
consumer playful · luxury minimal · developer/technical · retro/nostalgic · maximalist]

| Dimension | Reading |
|---|---|
| Typography | Georgia display + Helvetica UI · 8-step scale · 400/600 only |
| Color | Light key, warm neutrals, one green accent at 11% area |
| Layout | 1120px container · 3-col cards · centered · 83% whitespace |
| Imagery | One vector illustration, 16px radius, contained |
| Space | 8px base · 24/32/48/64/96 ladder |
| Shape/depth | 12px radius, hairline borders, one 1px shadow |
| Motion | 160ms ease on background-color and transform |

### Typography
[measured detail — sizes, weights, line heights, measure, classification]

### Color
[palette table: hex · role · share · contrast notes]

### Layout & composition
[grid, focal path, rhythm, responsive behavior]

### Imagery & media
### Space & scale
### Shape, depth & texture
### Motion
### Voice & content design

### Design tokens
[JSON or CSS custom properties — see below]

### What makes it work / what's inconsistent
[Max 3 bullets each. Observations, not a full critique.]

### Confidence & limits
[What was measured vs inferred; what the input couldn't show]
```

**Palette tables** should carry the hex, a swatch-friendly role name, the area share, and the source (sampled vs computed style):

| Hex | Role | Share | Source |
|---|---|---|---|
| `#fbfaf7` | Page background (warm off-white) | 69.5% | sampled |
| `#16211c` | Ink (green-tinted near-black) | 0.5% | computed |
| `#2f6f4e` | Primary accent | 10.1% | both |

### Design tokens

Close with a paste-ready token block when the user is likely to rebuild something — always for "extract the design system", "give me the tokens", or "recreate this". Only include values you measured.

```css
:root {
  --color-bg: #fbfaf7;
  --color-surface: #ffffff;
  --color-ink: #16211c;
  --color-muted: #6b7a72;
  --color-border: #e4e2dc;
  --color-accent: #2f6f4e;

  --font-display: Georgia, serif;
  --font-ui: Helvetica, Arial, sans-serif;
  --text-display: 64px/1.05;
  --text-h2: 40px/1.15;
  --text-lede: 20px/1.6;
  --text-body: 15px/1.6;
  --text-meta: 13px/1.4;

  --space-1: 8px;  --space-2: 16px; --space-3: 24px;
  --space-4: 32px; --space-6: 48px; --space-8: 64px;

  --radius-md: 12px;
  --radius-lg: 16px;
  --shadow-sm: 0 1px 2px rgb(22 33 28 / 0.12);
  --container: 1120px;
  --ease-ui: 160ms ease;
}
```

If the page exposes its own `cssVariables`, report those instead of inventing names — the author's token names are better evidence than yours.

---

## Aligning to shadcn/ui tokens

shadcn/ui is the most common destination for extracted color data, so when the user's project uses it — or they ask for shadcn tokens, Tailwind theme values, or "drop this into my app" — emit its token contract rather than invented names.

**First, check whether you're already looking at shadcn.** `styles.json` carries a `shadcn` block: `detected` (six or more of its distinctive variable names present), `matchedTokens`, `missingTokens`, `valueFormat`, `radius`, and `darkModeStrategy`. When it reports `detected: true`, the page's own values are the answer — read them out of `cssVariables` instead of inferring anything. `valueFormat` tells you which era you're in:

| `valueFormat` | Era | Values look like | Consumed as |
|---|---|---|---|
| `oklch (Tailwind v4 era)` | Current | `--primary: oklch(0.205 0 0)` | `bg-primary` via `@theme inline` |
| `hsl channel triplets (Tailwind v3 era)` | Legacy | `--primary: 0 0% 9%` | `hsl(var(--primary))` in `tailwind.config` |

**Inside a repo, read the project's own setup before generating anything**: `components.json` (style, baseColor, `cssVariables` true/false), and the CSS file it points at (`app/globals.css` or `src/index.css`). Match the format and the exact token set already there. Never introduce a token the project doesn't use, and never rename one it does.

### Role → token mapping

| Measured role | shadcn token |
|---|---|
| Page background | `--background` |
| Primary text / ink | `--foreground` |
| Card and panel surface | `--card` + `--card-foreground` |
| Menu, dialog, tooltip surface | `--popover` + `--popover-foreground` |
| Primary action fill — **the brand color** | `--primary` + `--primary-foreground` |
| Low-emphasis button fill | `--secondary` + `--secondary-foreground` |
| Subtle fill (badges, wells) / secondary text | `--muted` / `--muted-foreground` |
| Hover and active tint on rows and items | `--accent` + `--accent-foreground` |
| Error, delete, danger | `--destructive` |
| Hairlines and dividers | `--border` |
| Form control border | `--input` |
| Focus ring | `--ring` |
| Data-viz series | `--chart-1` … `--chart-5` |
| Nav or sidebar shell | `--sidebar`, `--sidebar-foreground`, `--sidebar-primary`, `--sidebar-accent`, `--sidebar-border`, `--sidebar-ring` |
| Corner radius base | `--radius` |

**The trap worth naming: `--accent` is not the brand accent.** In shadcn's defaults it is a neutral hover tint — the same near-grey as `--muted` and `--secondary`. A design's brand color belongs in `--primary`. Mapping a vivid brand hue to `--accent` turns every hover state into a flood of brand color. When you report a "primary accent" from the palette, say explicitly that it maps to `--primary`.

Since shadcn's stock `--primary` is near-black, any brand-colored design must override both `--primary` and `--primary-foreground`, and check the pair's contrast.

### Emitting the theme

Give both blocks, using measured values. Light mode from the design as captured; dark mode only if you actually captured a dark variant — otherwise say the dark block is derived, not measured, and mark it as a starting point.

```css
:root {
  --radius: 0.625rem;

  --background: oklch(0.985 0.004 91.4);   /* #fbfaf7 measured */
  --foreground: oklch(0.235 0.018 165.2);  /* #16211c */
  --card: oklch(1 0 0);
  --card-foreground: oklch(0.235 0.018 165.2);
  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.235 0.018 165.2);
  --primary: oklch(0.49 0.085 158.4);      /* #2f6f4e — the brand green */
  --primary-foreground: oklch(0.985 0.004 91.4);
  --secondary: oklch(0.97 0 0);
  --secondary-foreground: oklch(0.235 0.018 165.2);
  --muted: oklch(0.97 0 0);
  --muted-foreground: oklch(0.565 0.022 162.4); /* #6b7a72 */
  --accent: oklch(0.97 0 0);               /* neutral hover tint, not the brand */
  --accent-foreground: oklch(0.235 0.018 165.2);
  --destructive: oklch(0.577 0.245 27.325);
  --border: oklch(0.913 0.008 91.5);       /* #e4e2dc */
  --input: oklch(0.913 0.008 91.5);
  --ring: oklch(0.49 0.085 158.4);
  --chart-1: oklch(0.49 0.085 158.4);
  --chart-2: oklch(0.712 0.124 61.6);      /* #d98f4a */
}

.dark {
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);
  --card: oklch(0.205 0 0);
  --primary: oklch(0.62 0.11 158);         /* lifted for contrast on dark */
  --primary-foreground: oklch(0.205 0 0);
  --border: oklch(1 0 0 / 10%);            /* shadcn's dark convention */
  --input: oklch(1 0 0 / 15%);
}
```

Four conventions to respect, all taken from shadcn's own theme rather than guessed:

1. **Radius derives by multiplication.** The CLI writes `--radius-sm: calc(var(--radius) * 0.6)`, `md: * 0.8`, `lg: var(--radius)`, `xl: * 1.4`, then `2xl: * 1.8`, `3xl: * 2.2`, `4xl: * 2.6`. So pick `--radius` from the measured radius the design uses most for cards, and check the multipliers reproduce the smaller ones. Worked example: measured radii of `10px` and `8px` are exactly `--radius: 0.625rem` (10px) with `md` at 8px — one base value reproduces both.
2. **Dark borders are translucent white**, `oklch(1 0 0 / 10%)` for `--border` and `/ 15%` for `--input`, not a solid grey. The harvest reports these as `#ffffff @ 0.1`.
3. **Every `*-foreground` is a contrast promise.** Check each pair against its surface with `contrastPairs` and state the ratio for `--primary-foreground` on `--primary` at minimum. Below 4.5:1 for body text, adjust the foreground rather than shipping the pair.
4. **`--chart-1` … `--chart-5` are a categorical ramp**, not five shades of one hue. Feed them from the design's distinct accents, and if the design has fewer than five, say so rather than inventing three more.

For a legacy v3 project, the same values become bare HSL channel triplets — `--primary: 149 41% 31%;` for `#2f6f4e` — consumed as `hsl(var(--primary))`, with radius derived as `calc(var(--radius) - 2px)` and `- 4px`. Use the `hsl` field in the palette output, dropping the `hsl(` wrapper.

### The gamut caveat

Authored OKLCH can sit outside sRGB: shadcn's own `--destructive: oklch(0.577 0.245 27.325)` has a negative green channel and rasterizes to `#e7000b`. The harvest flags these with `outOfGamut: true` and keeps the authored string verbatim in the `oklch` field, because re-deriving it from the clamped hex would shift the token.

So the two sources answer different questions, and you should say which you used:

- **`styles.json` colors** are the authored tokens — correct for reproducing a theme.
- **`palette.json` colors** are sampled pixels, already clamped to sRGB — correct for what users actually see, and the only option for image inputs.

---

## Modes

| User asks | Do this |
|---|---|
| "What colors is this using?" | Palette only. Run Step 3, skip the rest. Two minutes, not twenty |
| "Analyze this design" | Full eight-dimension report |
| "Extract the design system" / "recreate this" | Full report, weighted to tokens and the type/space scales |
| "Give me shadcn tokens" / project uses shadcn | Measure, then map roles to the shadcn contract and emit `:root` + `.dark` in the project's existing format |
| "Compare these two" | Analyze both, then one comparison table per dimension and a note on where they diverge in strategy, not just values |
| "What makes this look expensive/cheap?" | Full capture, but write it as the 3–5 properties driving that read: type discipline, neutral tuning, whitespace, restraint in accent share, elevation consistency |
| "Is this design good?" | Measure first, then hand off to a critique skill — see Handoffs |

## Accuracy rules

1. **Measured beats eyeballed.** If a script produced the value, use the script's value. If you inferred it, mark it `(inferred)`.
2. **Never fabricate a hex.** For pasted images you cannot sample, describe the color in words ("desaturated forest green") and say an exact value needs a file or URL.
3. **Computed font ≠ intended font.** `typography.families` shows the first family in the stack, which may not be what rendered. Cross-check `webfonts` for load status.
4. **Counts are element counts, not visual weight.** A color used on one element can dominate the page; area share is the honest measure.
5. **Pixel palettes include photography.** A photo's colors show up in the palette alongside UI colors. Separate them: compare palette hexes against `color.backgrounds`/`color.text` from the DOM, and attribute the leftovers to imagery.
6. **Full-page shots skew shares** toward the longest section. Report which screenshot each number came from.
7. **One viewport is not responsive behavior.** Do not describe how a design adapts unless you captured both viewports.
8. **Authored is not always rendered.** Wide-gamut tokens (`oklch`, `lab`, `display-p3`) can fall outside sRGB; the harvest marks these `outOfGamut: true`. Quote the authored value when reproducing a theme and the sampled value when describing what users see — and say which one you used.
9. **Say what you could not see**: hover and focus states, dark mode, logged-in views, keyboard behavior, real content variation, animation on scroll. Screenshots are a still of one state.

## Handoffs

This skill describes. When the user wants judgment, continue into the right lens:

- `craft` — pixel- and CSS-level polish: gradients, glow, `transition: all`, elevation discipline
- `accessibility` — real WCAG audit of contrast, focus, targets, semantics
- `general-design-review` — combined UX, product, and AI review
- `cognitive-load-conversion` — the design is measured but the page is not converting
- `dieter-rams-principles`, `ux-heuristics-review`, `persuasive-ux` — specific critique frameworks

Say which handoff you recommend and why, in one line. Do not run a full critique unasked.

---

## Project adaptation — token idiom

The "Aligning to shadcn/ui tokens" section above is a **target-system example, not automatically the
project's target**. Resolve the real one at runtime:

- **Read the declared token source** from `{config.frontend_runtime}` before emitting anything — it may be CSS custom properties in `:root`, a utility-framework config, a CSS-in-JS theme, or a design-token JSON. Never assume which kind it is.
- The canonical token mirror is **`docs/design/design-tokens.md`** (+ any `design-tokens.json`), owned by the design owner. `docs/design/design-system.md` wins on any conflict.
- So when emitting tokens: **report the project's own names**, read from that source. Never invent a name, never rename one in use, and never introduce a second token system the project does not use. The accuracy rule "if the page exposes its own `cssVariables`, report those instead of inventing names" is the operative one whenever the project styles from custom properties.
- Keep the shadcn mapping table for **external** analyses (a competitor site, a reference design the user drops in) where the destination genuinely is shadcn.

### Handoff targets (replaces the source's skill names)

| Source handoff | Here |
|---|---|
| `craft` | `references/visual-craft-rules.md` (this skill) |
| `accessibility` | the QA owner's a11y pass · the design library's accessibility checklist |
| `general-design-review` | `workflows/design-review.md` (this skill) |
| `cognitive-load-conversion` | `references/cognitive-load-and-conversion.md` (this skill) |
| `ux-heuristics-review` | `workflows/heuristics-review.md` (this skill) |
| pixel/visual-regression verdict | `designer-frontend-contract` (owned by the design owner) — the design-diff gate |
