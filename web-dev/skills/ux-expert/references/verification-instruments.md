# Verification Instruments — how to measure a UI without lying to yourself

> **Source**: learned the hard way. Every failure catalogued below produced a CONFIDENT WRONG ANSWER
> during a single review session — six from the reviewer, three more from independent reviewers.
> **Load when**: writing or reviewing any browser probe, before trusting a number it produces, or
> when a measured result disagrees with what you can see on screen.

---

## The rule this file exists for

**A metric that cannot fail is not evidence.**

Before a probe's output is allowed to change a verdict, prove the probe can report the failure it is
looking for. The cheapest proof: run it against a case you KNOW is broken and confirm it says so. A
probe that has only ever returned "clean" has not been tested — it has been assumed.

The corollary is worse than it sounds. A broken instrument does not produce noise, it produces
CONFIDENCE: a clean sweep, a green table, a claim you then repeat to the owner. Every entry below was
reported as fact before it was caught.

---

## The catalogue

Each entry is a real failure. The shape matters more than the specific API.

### 1. A viewport test that cannot fail — mobile emulation

```js
// WRONG — under isMobile the visual viewport WIDENS to match over-wide content,
// so scrollWidth tracks innerWidth and this is always false.
document.documentElement.scrollWidth > window.innerWidth
```

```js
// RIGHT — pin the device width, isMobile OFF, compare against the literal number.
const ctx = await browser.newContext({ viewport: { width: 375, height: 812 } });
// …
document.documentElement.scrollWidth > 375
```

Reported "0 pages overflow" for three genuinely overflowing routes. **Ask of any threshold test: what
would make this fire?**

### 2. A colour parser that invents failures

Modern stylesheets compute to `color(srgb 0.968 0.960 0.984 / 0.88)`, `oklch()`, `lab()`. A regex of
`/\d+(\.\d+)?/g` reads those 0-1 floats as 0-255 channels — i.e. near-black — and fabricates contrast
failures against every light surface.

```js
// RIGHT — let the engine normalise, then read it back.
const probe = document.createElement("div");
probe.style.color = String(value);
const out = getComputedStyle(probe).color;   // now rgb() or color(srgb …), parse both
```

Produced **120 fabricated failures**, and made a token look WORSE after it was correctly darkened.

### 3. A background walk that stops at glass

Walking ancestors for "the background" and stopping at the first non-transparent value picks up a
TRANSLUCENT layer and treats it as opaque. Text on a 15% wash of its own colour then measures against
the wash instead of the composite.

- Skip any layer with alpha < 1 while walking, **or** composite it properly:
  `out = fg·α + bg·(1−α)`.
- A badge sitting on a wash of its own text colour is the classic case; compute the composite or the
  ratio is meaningless.

### 4. Inferring state from markup instead of measuring it

A closed `<details>` does **not** hide children that carry an author-origin `display` — the UA rule
loses to any author rule. Same trap for `hidden`, `aria-expanded`, and CSS classes that "mean" hidden.

```js
// WRONG
const hidden = !details.hasAttribute("open");
// RIGHT
const hidden = child.getBoundingClientRect().height === 0;
```

Hit **twice** in one session: once believing a fold worked when every body was rendering, once
believing a fix had failed when it had not.

### 5. Counting the wrong selector

A view's items are whatever the view calls them: a kanban's cards may be `.kb-card` while `.card` is
something else; a timeline's rows may be `.tl-row` while `.row` belongs to a list. Counting the
generic name reports a working view as EMPTY.

Before reporting "0 items", print the class names actually present:
```js
[...new Set([...container.children].map((e) => e.className.split(" ")[0]))]
```

### 6. A readiness check satisfied by the thing it should exclude

```js
// WRONG — an EMPTY container satisfies this, and so does the PREVIOUS route's content.
await page.waitForFunction(() => !/Loading/.test(document.querySelector("#main").textContent));
```

Worse, `.catch(() => {})` on the wait swallows the timeout, so a slow load silently proceeds and the
probe measures the loading stub — then blames the route. Wait for POSITIVE evidence of the thing you
want, with a real budget and no swallowed timeout:

```js
await page.waitForFunction(() => {
  const m = document.querySelector("#main");
  const t = (m?.textContent || "").trim();
  if (!t || /^Loading/.test(t)) return false;
  return m.querySelector("h1") !== null;   // positive proof the view rendered
}, { timeout: 30000 });                     // and let it THROW
```

This one produced a false bug report — an "intermittent async race in the view" that was the harness
all along. **A flaky test is a claim about the code; verify it in isolation before making it.**

### 7. The self-referential trap

A page that QUOTES your sentinel defeats a substring check. A review document containing the words
"Loading docs…" reads as still-loading forever. Prefer structural signals (an `h1` exists, a known
container has children) over string matching on user content.

### 8. Fighting the app for shared state

Setting `localStorage` in an init script races the app's own write, so a "light theme" pass can
silently run in dark. **Assert the state took effect before measuring anything that depends on it:**

```js
const theme = await page.evaluate(() => document.documentElement.getAttribute("data-theme"));
if (theme !== expected) throw new Error(`theme is ${theme}, not ${expected}`);
```

### 9. Scoring things that are not text

Emoji glyphs, icon fonts and decorative marks have no meaningful foreground colour. Including them in
a contrast sweep produces 1:1 ratios and drowns the real findings. Exclude them, and exclude
`aria-hidden="true"` nodes — WCAG exempts decoration.

---

## Verify the FIX, not the edit

An edit that compiles is not a fix. Two failure shapes, both seen in one session:

1. **The no-op fix.** Data was wrapped in a helper that attached a `hue` to every row — while the
   consumer never read `.hue` and coloured by position. The code changed; the output did not.
2. **The plausible-but-wrong parameter.** A "start headings at level 2" option was passed where the
   renderer already normalised h1→h2, so it pushed the document's own `##` down to `###` and produced
   **zero** sections instead of the intended split.

Both were caught only by measuring the OUTPUT again after the change. So:

- Re-run the exact measurement that produced the finding, and require the NUMBER to move.
- If the number does not move, the cause is elsewhere — **stop patching and re-diagnose.** Chasing a
  symptom produced two wrong fixes for one page before the real cause (a view switch that rendered
  its own chart *and* the other view's full content) turned up.

---

## Fix the token, not the forty selectors

When many rules share one failing value, fixing the two you happened to measure leaves the rest — and
the next one to appear. A contrast pass that changed 2 selectors left 45 more failing; retuning the
TOKEN fixed all 68 at once and could be verified with exact arithmetic.

When you retune a shared token:
- compute against **every** surface it lands on, including composited/translucent chrome;
- keep hue and saturation, move lightness only, so the palette's identity survives;
- check it still reads as a distinct STEP from its neighbours in the ramp;
- verify with a live sweep AND with hex arithmetic — two instruments that fail differently.

---

## Enumerate the full state space, not the route list

A sweep that visits paths only will miss the states a router reaches through query parameters. Real
example: `?view=timeline`, `?view=board`, `?g=<group>`, `?item=<id>`, `?kind=<x>` — three of a nine-item
complaint list landed on sub-views that no earlier pass had ever driven, because the sweep enumerated
routes and stopped.

Before claiming coverage, read the router and enumerate:
- every path branch,
- every query parameter that changes what renders,
- every document/collection TYPE (not one representative — types diverge),
- the not-found branch, and the empty/filtered-to-empty state of each list.

Then say what you covered and what you sampled. "All pages" is a claim; make it a true one.

---

## Reporting rules that follow from all of this

1. Every number cites the instrument that produced it, or is marked `(inferred)`.
2. When an instrument is corrected, RE-STATE the affected numbers — do not leave the old ones standing.
3. When a claim you already reported turns out to be wrong, correct it plainly and say what the real
   cause was. A quietly-dropped claim is worse than the original error.
4. Prefer two instruments that fail differently (a live sweep and exact arithmetic) over one you trust.
