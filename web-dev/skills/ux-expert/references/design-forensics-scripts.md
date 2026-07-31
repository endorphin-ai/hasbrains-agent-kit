# Design Forensics — Capture & Pixel-Sampling Scripts

> **Source**: adapted from [tommyjepsen/awesome-ux-skills](https://github.com/tommyjepsen/awesome-ux-skills) (`design-analysis.md`).
> **Load when**: MEASURING a design instead of eyeballing it — the input triage table, capture.mjs (screenshots + computed-style harvest), palette.mjs (pixel palette + composition metrics), and how to read the composition numbers. NEVER guess a hex, size, or spacing value these scripts can measure.

> ⚠️ **PATH + VIEWPORT OVERRIDES APPLY.** The script bodies below are verbatim from the source and still
> name `/tmp/design-analysis/`, `localhost:3000`, and the `1440×900 / 390×844` viewport pair. Use the
> project's own values instead: the git-ignored scratch folder (`.ai_log/ux-forensics/` by this kit's
> convention), `{config.dev_url}`, and the breakpoint ladder `{config.frontend_runtime}` declares —
> edit the `vp` array in `capture.mjs` before running. Full table:
> **[Project adaptation](#project-adaptation--overrides-the-source-paths-above)** at the end of this file.

---

## Step 1 — Identify the input

| Input | What to do |
|---|---|
| Image file path (`.png`, `.jpg`, `.webp`, `.avif`) | Skip to Step 3, then Step 4 |
| Image pasted into the conversation | View it, then Step 4. Ask for a file path or URL if exact hexes matter — you cannot sample pixels from a pasted image |
| URL | Step 2 (capture) → Step 3 (pixels) → Step 4 (look) |
| Figma link | Use the Figma tooling if available; otherwise ask for an exported PNG |
| Local dev server / running app | Same as URL — `{config.dev_url}` (the source said `:3000`; read the real one from project config) |
| Multiple inputs | Analyze each, then add a **Comparison** section that puts the dimensions side by side |

Also settle **scope** before capturing: one page, one component, or a whole flow. If the request is vague ("analyze my site"), analyze the page they gave you and say which page you analyzed.

---

## Step 2 — Capture (URL inputs)

Write this to `.ai_log/ux-forensics/capture.mjs` and run it. As written it screenshots desktop (1440×900, plus full-page) and mobile (390×844) at 2× density and harvests computed styles — the ground truth for typography, color, spacing, shape, and motion. **Edit the `vp` array to the project's own breakpoint ladder before the first run.**

```js
// Usage: node capture.mjs <url> <outdir>
import { createRequire } from 'node:module';
import { execSync } from 'node:child_process';
import { mkdirSync, writeFileSync } from 'node:fs';
import path from 'node:path';

// Resolve playwright from the project, then from the global npm root.
const require = createRequire(import.meta.url);
function loadPlaywright() {
  const names = ['playwright', '@playwright/test', 'playwright-core'];
  for (const n of names) { try { return require(n); } catch {} }
  let root = ''; try { root = execSync('npm root -g', { encoding: 'utf8' }).trim(); } catch {}
  for (const n of names) { try { return require(path.join(root, n)); } catch {} }
  console.error('Playwright not found. Install it with: npm i -D playwright && npx playwright install chromium');
  process.exit(2);
}
const { chromium } = loadPlaywright();

const url = process.argv[2];
const out = process.argv[3] || '.';
if (!url) { console.error('usage: node capture.mjs <url> <outdir>'); process.exit(1); }
mkdirSync(out, { recursive: true });

const browser = await chromium.launch();
const shots = [];

for (const vp of [
  { tag: 'desktop', width: 1440, height: 900 },
  { tag: 'mobile', width: 390, height: 844, mobile: true },
]) {
  const ctx = await browser.newContext({
    viewport: { width: vp.width, height: vp.height },
    deviceScaleFactor: 2,
    isMobile: !!vp.mobile,
    hasTouch: !!vp.mobile,
  });
  const page = await ctx.newPage();
  await page.goto(url, { waitUntil: 'networkidle', timeout: 60000 }).catch(() =>
    page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 }));
  await page.waitForTimeout(1200);
  // settle lazy content, then return to top
  await page.evaluate(async () => {
    for (let y = 0; y < document.body.scrollHeight; y += window.innerHeight) {
      window.scrollTo(0, y); await new Promise(r => setTimeout(r, 120));
    }
    window.scrollTo(0, 0);
  });
  await page.waitForTimeout(600);

  const fold = path.join(out, `${vp.tag}-fold.png`);
  await page.screenshot({ path: fold });
  shots.push(fold);
  if (vp.tag === 'desktop') {
    const full = path.join(out, 'desktop-full.png');
    await page.screenshot({ path: full, fullPage: true });
    shots.push(full);
    writeFileSync(path.join(out, 'styles.json'), JSON.stringify(await harvest(page), null, 2));
  }
  await ctx.close();
}
await browser.close();
console.log(JSON.stringify({ shots, styles: path.join(out, 'styles.json') }, null, 2));

async function harvest(page) {
  return page.evaluate(() => {
    const px = v => Math.round(parseFloat(v) || 0);
    // Any CSS color -> sRGB, resolved by the engine via relative color syntax.
    // Modern stylesheets compute to oklch()/lab()/color(display-p3) — shadcn is all
    // oklch — and those never match a regex on rgb(). `rgb(from X r g b)` serializes
    // to `color(srgb ...)` floats, which also exposes out-of-gamut channels.
    const probe = document.createElement('div');
    probe.style.display = 'none'; document.body.appendChild(probe);
    const srgb = v => {
      if (typeof v !== 'string') return null;
      const str = v.trim();
      if (!str || /^(none|transparent|currentcolor)$/i.test(str)) return null;
      if (/gradient|url\(|image\(/i.test(str)) return null; // not a flat color
      probe.style.color = 'rgb(1, 2, 3)';                     // sentinel
      probe.style.color = `rgb(from ${str} r g b / alpha)`;    // ignored if unparseable
      const out = getComputedStyle(probe).color;
      if (out === 'rgb(1, 2, 3)' && !/1,\s*2,\s*3|#010203/.test(str)) return null;
      let m = out.match(/color\(srgb ([-\d.e]+) ([-\d.e]+) ([-\d.e]+)(?:\s*\/\s*([\d.e]+))?\)/);
      let ch, a = 1;
      if (m) { ch = m.slice(1, 4).map(Number); if (m[4] !== undefined) a = +m[4]; }
      else {
        m = out.match(/rgba?\(([^)]+)\)/);
        if (!m) return null;
        const parts = m[1].split(/[,/ ]+/).filter(Boolean).map(Number);
        ch = parts.slice(0, 3).map(n => n / 255);
        if (parts[3] !== undefined) a = parts[3];
      }
      const outOfGamut = ch.some(n => n < -0.001 || n > 1.001);
      const bytes = ch.map(n => Math.max(0, Math.min(255, Math.round(n * 255))));
      const hex = '#' + bytes.map(n => n.toString(16).padStart(2, '0')).join('');
      return { hex, alpha: a, outOfGamut, rgb: bytes };
    };
    // Backwards-compatible string form: '#rrggbb', or '#rrggbb @ 0.5' when translucent.
    const toHex = v => {
      const c = srgb(v);
      if (!c) return v;
      return c.alpha < 1 ? `${c.hex} @ ${+c.alpha.toFixed(3)}` : c.hex;
    };
    const bump = (m, k) => k && m.set(k, (m.get(k) || 0) + 1);
    const top = (m, n = 14) => [...m.entries()].sort((a, b) => b[1] - a[1]).slice(0, n)
      .map(([value, count]) => ({ value, count }));
    // sRGB -> OKLCH (Ottosson), validated against Chromium's own relative-color
    // resolution; paste-ready as shadcn v4 token values.
    const oklch = h => {
      const m = h.match(/^#(\w\w)(\w\w)(\w\w)/); if (!m) return null;
      const [R, G, B] = m.slice(1).map(x => { const v = parseInt(x, 16) / 255;
        return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; });
      const l_ = Math.cbrt(0.4122214708 * R + 0.5363325363 * G + 0.0514459929 * B);
      const m_ = Math.cbrt(0.2119034982 * R + 0.6806995451 * G + 0.1073969566 * B);
      const s_ = Math.cbrt(0.0883024619 * R + 0.2817188376 * G + 0.6299787005 * B);
      const L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_;
      const A = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_;
      const Bb = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_;
      const C = Math.hypot(A, Bb);
      let Hh = Math.atan2(Bb, A) * 180 / Math.PI; if (Hh < 0) Hh += 360;
      return C < 0.002 ? `oklch(${+L.toFixed(3)} 0 0)`
                       : `oklch(${+L.toFixed(3)} ${+C.toFixed(3)} ${+Hh.toFixed(1)})`;
    };
    // Keep the authored value, add sRGB hex, and add OKLCH. When the page already
    // computes to oklch() that string is used verbatim: shadcn's --destructive sits
    // outside sRGB, so re-deriving it from a clamped hex would shift the token.
    const withColor = arr => arr.map(e => {
      const c = srgb(e.value);
      if (!c) return e;
      const authored = String(e.value).trim();
      return {
        ...e,
        hex: c.alpha < 1 ? `${c.hex} @ ${+c.alpha.toFixed(3)}` : c.hex,
        oklch: /^oklch\(/i.test(authored) ? authored : oklch(c.hex),
        ...(c.outOfGamut ? { outOfGamut: true } : {}),
      };
    });

    const fonts = new Map(), sizes = new Map(), weights = new Map(), tracking = new Map();
    const fg = new Map(), bg = new Map(), border = new Map();
    const radius = new Map(), shadow = new Map(), gaps = new Map(), pads = new Map(), grids = new Map();
    const transitions = new Map(), animations = new Map();
    const type = []; // representative text runs, largest first

    const nodes = [...document.querySelectorAll('*')].filter(el => {
      const r = el.getBoundingClientRect();
      const s = getComputedStyle(el);
      return r.width > 0 && r.height > 0 && s.visibility !== 'hidden' && s.display !== 'none' && +s.opacity > 0.05;
    });

    for (const el of nodes) {
      const s = getComputedStyle(el);
      const text = [...el.childNodes].filter(n => n.nodeType === 3).map(n => n.textContent.trim()).join(' ').trim();
      if (text) {
        const fam = s.fontFamily.split(',')[0].replace(/["']/g, '').trim();
        bump(fonts, fam); bump(sizes, `${px(s.fontSize)}px`); bump(weights, s.fontWeight);
        bump(tracking, s.letterSpacing); bump(fg, s.color);
        const w = Math.round(el.getBoundingClientRect().width);
        // Widest rendered line box, not the container: a short label in a wide
        // block measures short, and a wrapped paragraph measures its real column.
        const range = document.createRange(); range.selectNodeContents(el);
        const rects = [...range.getClientRects()].filter(r => r.width > 0);
        const lineWidth = rects.length ? Math.round(Math.max(...rects.map(r => r.width))) : w;
        type.push({
          tag: el.tagName.toLowerCase(), size: px(s.fontSize), weight: +s.fontWeight,
          family: fam, lineHeight: s.lineHeight === 'normal' ? 'normal' : px(s.lineHeight),
          letterSpacing: s.letterSpacing, transform: s.textTransform, color: toHex(s.color),
          blockWidth: w, lineWidth, lines: rects.length,
          // measure in characters: ~0.5em average advance width for Latin text
          measureCh: Math.round(lineWidth / (px(s.fontSize) * 0.5)),
          sample: text.slice(0, 70),
        });
      }
      const bgc = s.backgroundColor;
      if (bgc && bgc !== 'rgba(0, 0, 0, 0)' && bgc !== 'transparent') bump(bg, bgc);
      if (s.backgroundImage !== 'none' && /gradient/.test(s.backgroundImage)) bump(bg, s.backgroundImage.slice(0, 90));
      if (px(s.borderTopWidth) > 0) bump(border, `${s.borderTopWidth} ${s.borderTopStyle} ${toHex(s.borderTopColor)}`);
      if (px(s.borderTopLeftRadius) > 0) bump(radius, s.borderTopLeftRadius);
      if (s.boxShadow !== 'none') bump(shadow, s.boxShadow);
      if (/flex|grid/.test(s.display) && s.gap !== 'normal' && px(s.gap) > 0) bump(gaps, s.gap);
      // computed grid templates resolve to px — column counts and widths, for free
      if (s.display.includes('grid') && s.gridTemplateColumns !== 'none') {
        const cols = s.gridTemplateColumns.split(' ').length;
        bump(grids, `${cols} cols: ${s.gridTemplateColumns}`);
      }
      for (const p of ['paddingTop', 'paddingLeft']) if (px(s[p]) > 0) bump(pads, `${px(s[p])}px`);
      if (s.transitionDuration !== '0s') {
        const props = s.transitionProperty.split(', '), durs = s.transitionDuration.split(', '),
              eases = s.transitionTimingFunction.split(/, (?![^(]*\))/);
        props.forEach((p, i) => bump(transitions,
          `${p} ${durs[i % durs.length]} ${eases[i % eases.length]}`));
      }
      if (s.animationName !== 'none') bump(animations, `${s.animationName} ${s.animationDuration} ${s.animationIterationCount}`);
    }

    const imgs = [...document.images].filter(i => i.width > 24 && i.height > 24).map(i => ({
      w: i.width, h: i.height, ratio: +(i.width / i.height).toFixed(2),
      alt: i.alt || null, src: /^data:/.test(i.currentSrc || i.src) ? (i.currentSrc || i.src).split(';')[0] : (i.currentSrc || i.src).slice(0, 120),
      radius: getComputedStyle(i).borderRadius, fit: getComputedStyle(i).objectFit,
    }));
    const svgs = document.querySelectorAll('svg').length;
    const videos = document.querySelectorAll('video').length;

    // container width: widest common block width among direct wrappers
    const widths = new Map();
    for (const el of nodes) {
      const r = el.getBoundingClientRect();
      if (r.width > 320 && r.width < innerWidth) bump(widths, `${Math.round(r.width)}px`);
    }

    const vars = {}, breakpoints = new Set();
    let prefersColorScheme = false;
    const walk = rules => {
      for (const r of rules) {
        if (r.style && (r.selectorText === ':root' || r.selectorText === 'html')) {
          for (const p of r.style) if (p.startsWith('--')) vars[p] = r.style.getPropertyValue(p).trim();
        }
        if (r.media) { const t = r.conditionText || r.media.mediaText;
          if (/prefers-color-scheme/.test(t)) prefersColorScheme = true;
          (t.match(/\d+(\.\d+)?(px|em|rem)/g) || []).forEach(v => breakpoints.add(v)); }
        if (r.cssRules) walk([...r.cssRules]);
      }
    };
    for (const sheet of [...document.styleSheets]) {
      try { walk([...sheet.cssRules]); } catch {}
    }
    const webfonts = [...new Set([...document.fonts].map(f =>
      `${f.family} ${f.weight} ${f.style} (${f.status})`))];
    const bodyBg = getComputedStyle(document.body).backgroundColor;

    // Is this a shadcn/ui token system? Its variable names are distinctive.
    const SHADCN = ['--background', '--foreground', '--card', '--card-foreground',
      '--popover', '--popover-foreground', '--primary', '--primary-foreground',
      '--secondary', '--secondary-foreground', '--muted', '--muted-foreground',
      '--accent', '--accent-foreground', '--destructive', '--border', '--input',
      '--ring', '--chart-1', '--chart-2', '--chart-3', '--chart-4', '--chart-5',
      '--sidebar', '--sidebar-foreground', '--sidebar-primary', '--sidebar-accent',
      '--sidebar-border', '--sidebar-ring', '--radius'];
    const matched = SHADCN.filter(v => v in vars);
    const sample = matched.map(v => vars[v]).find(Boolean) || '';
    const shadcn = {
      detected: matched.length >= 6,
      matchedTokens: matched,
      missingTokens: matched.length >= 6 ? SHADCN.filter(v => !(v in vars)) : [],
      // v4 ships raw oklch(); v3 shipped bare HSL channel triplets read via hsl(var(--x))
      valueFormat: /oklch/i.test(sample) ? 'oklch (Tailwind v4 era)'
        : /^\s*[\d.]+\s+[\d.]+%\s+[\d.]+%/.test(sample) ? 'hsl channel triplets (Tailwind v3 era)'
        : /^#/.test(sample) ? 'hex' : 'unknown',
      radius: vars['--radius'] || null,
      darkModeStrategy: document.querySelector('.dark, [data-theme="dark"]') ? 'class on element'
        : prefersColorScheme ? 'prefers-color-scheme media query' : 'not detected in this render',
    };

    return {
      page: { title: document.title, url: location.href, viewport: innerWidth + 'x' + innerHeight,
              scrollHeight: document.body.scrollHeight, folds: +(document.body.scrollHeight / innerHeight).toFixed(1),
              viewportMeta: document.querySelector('meta[name=viewport]')?.content || null },
      typography: { families: top(fonts), sizes: top(sizes, 20), weights: top(weights), letterSpacing: top(tracking, 6),
                    scale: [...new Set(type.map(t => t.size))].sort((a, b) => b - a),
                    runs: type.sort((a, b) => b.size - a.size).slice(0, 22) },
      color: { text: withColor(top(fg)), backgrounds: withColor(top(bg)), borders: top(border, 8) },
      shape: { radii: top(radius, 8), shadows: top(shadow, 6) },
      space: { gaps: top(gaps, 10), paddings: top(pads, 12), commonWidths: top(widths, 6), gridTemplates: top(grids, 8) },
      motion: { transitions: top(transitions, 10), animations: top(animations, 5) },
      media: { images: imgs.slice(0, 24), imageCount: imgs.length, svgCount: svgs, videoCount: videos },
      cssVariables: vars,
      breakpoints: [...breakpoints].sort((a, b) => parseFloat(a) - parseFloat(b)),
      webfonts,
      theme: { bodyBackground: toHex(bodyBg),
               colorScheme: getComputedStyle(document.documentElement).colorScheme || 'normal' },
      shadcn,
    };
  });
}
```

```bash
OUT=.ai_log/ux-forensics
mkdir -p "$OUT/out"
node "$OUT/capture.mjs" "{config.dev_url}/" "$OUT/out"   # or the per-PR preview — never production
```

**When capture fails:**

- `Playwright not found` → `npm i -D playwright && npx playwright install chromium`. On managed/sandboxed environments Chromium is often pre-installed — try `NODE_PATH=$(npm root -g)` and skip the download.
- Login wall, paywall, or bot block → say so and ask the user for a screenshot. Do not analyze the block page as if it were the design.
- Cookie banner covering the fold → note it, and use `desktop-full.png` for the layout read.
- `403`/`407`/tunnel errors → egress is blocked by policy. Report the blocked host; do not work around it.
- Page needs auth → ask whether they can export a screenshot instead.

---

## Step 3 — Sample the pixels

Computed styles tell you what the CSS *says*. Pixels tell you what the design *is* — actual area shares, whitespace, and visual balance. This script also handles plain image inputs, where pixels are all you have.

Write to `.ai_log/ux-forensics/palette.mjs`. It decodes through Chromium, so it needs no image libraries and reads PNG/JPEG/WebP/AVIF/GIF/SVG.

```js
// Usage: node palette.mjs <image> [maxColors]
// Prints JSON: palette (hex + area share + role), color summary, composition metrics.
import { createRequire } from 'node:module';
import { execSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import path from 'node:path';

const require = createRequire(import.meta.url);
function loadPlaywright() {
  const names = ['playwright', '@playwright/test', 'playwright-core'];
  for (const n of names) { try { return require(n); } catch {} }
  let root = ''; try { root = execSync('npm root -g', { encoding: 'utf8' }).trim(); } catch {}
  for (const n of names) { try { return require(path.join(root, n)); } catch {} }
  console.error('Playwright not found: npm i -D playwright && npx playwright install chromium');
  process.exit(2);
}
const { chromium } = loadPlaywright();

const file = process.argv[2];
const maxColors = +(process.argv[3] || 10);
if (!file) { console.error('usage: node palette.mjs <image> [maxColors]'); process.exit(1); }
const ext = path.extname(file).slice(1).toLowerCase();
const mime = { png: 'image/png', jpg: 'image/jpeg', jpeg: 'image/jpeg', webp: 'image/webp',
               gif: 'image/gif', avif: 'image/avif', svg: 'image/svg+xml' }[ext] || 'image/png';
const dataUri = `data:${mime};base64,${readFileSync(file).toString('base64')}`;

const browser = await chromium.launch();
const page = await browser.newPage();
const result = await page.evaluate(async ({ dataUri, maxColors }) => {
  const img = new Image(); img.src = dataUri; await img.decode();
  const W = Math.min(img.naturalWidth, 1200);
  const H = Math.max(1, Math.round(img.naturalHeight * (W / img.naturalWidth)));
  const c = document.createElement('canvas'); c.width = W; c.height = H;
  const ctx = c.getContext('2d', { willReadFrequently: true });
  ctx.drawImage(img, 0, 0, W, H);
  const { data } = ctx.getImageData(0, 0, W, H);
  const at = (x, y) => { const i = 4 * (y * W + x); return [data[i], data[i + 1], data[i + 2]]; };

  const hex = ([r, g, b]) => '#' + [r, g, b].map(v => v.toString(16).padStart(2, '0')).join('');
  const lin = v => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; };
  const lum = ([r, g, b]) => 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
  const contrast = (a, b) => { const [x, y] = [lum(a), lum(b)].sort((p, q) => q - p); return +((x + 0.05) / (y + 0.05)).toFixed(2); };
  const hsl = ([r, g, b]) => {
    const R = r / 255, G = g / 255, B = b / 255;
    const mx = Math.max(R, G, B), mn = Math.min(R, G, B), d = mx - mn, l = (mx + mn) / 2;
    let h = 0, s = 0;
    if (d) { s = d / (1 - Math.abs(2 * l - 1));
      h = mx === R ? ((G - B) / d) % 6 : mx === G ? (B - R) / d + 2 : (R - G) / d + 4;
      h = Math.round(h * 60); if (h < 0) h += 360; }
    return { h, s: Math.round(s * 100), l: Math.round(l * 100) };
  };
  // sRGB -> OKLCH (Ottosson). Validated against Chromium's own
  // `oklch(from <color> l c h)` over 400 random colors: L and C agree to
  // <0.0001, hue to <0.2 deg above C=0.01 (below that hue is meaningless and
  // can differ ~0.5 deg). Paste-ready as shadcn v4 token values.
  const oklch = ([r, g, b]) => {
    const f = v => { v /= 255; return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; };
    const [R, G, B] = [f(r), f(g), f(b)];
    const l_ = Math.cbrt(0.4122214708 * R + 0.5363325363 * G + 0.0514459929 * B);
    const m_ = Math.cbrt(0.2119034982 * R + 0.6806995451 * G + 0.1073969566 * B);
    const s_ = Math.cbrt(0.0883024619 * R + 0.2817188376 * G + 0.6299787005 * B);
    const L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_;
    const A = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_;
    const Bb = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_;
    const C = Math.hypot(A, Bb);
    let H = Math.atan2(Bb, A) * 180 / Math.PI; if (H < 0) H += 360;
    // shadcn writes achromatic colors as `oklch(1 0 0)` — hue is meaningless at C≈0
    return C < 0.002 ? `oklch(${+L.toFixed(3)} 0 0)`
                     : `oklch(${+L.toFixed(3)} ${+C.toFixed(3)} ${+H.toFixed(1)})`;
  };
  // chroma = max-min in 0-255. Robust "is this actually colorful" test at any lightness.
  const chroma = ([r, g, b]) => Math.max(r, g, b) - Math.min(r, g, b);
  const temp = h => (h >= 15 && h < 75) ? 'warm' : (h >= 75 && h < 165) ? 'green'
    : (h >= 165 && h < 255) ? 'cool' : (h >= 255 && h < 315) ? 'violet' : 'red';
  const role = rgb => {
    const ch = chroma(rgb), { l } = hsl(rgb);
    if (ch < 10) return l > 92 ? 'near-white' : l < 12 ? 'near-black' : 'neutral';
    if (ch < 26) return l > 90 ? 'tinted-white' : l < 18 ? 'tinted-black' : 'muted';
    if (ch < 90) return 'chromatic';
    return l > 45 ? 'vivid' : 'deep';
  };

  const hist = new Map();
  let total = 0, sumL = 0, sumC = 0;
  const bands = new Array(10).fill(0);
  for (let i = 0; i < data.length; i += 4) {
    if (data[i + 3] < 128) continue;
    const rgb = [data[i], data[i + 1], data[i + 2]];
    const k = ((rgb[0] >> 3) << 10) | ((rgb[1] >> 3) << 5) | (rgb[2] >> 3);
    const e = hist.get(k) || [0, 0, 0, 0];
    e[0] += rgb[0]; e[1] += rgb[1]; e[2] += rgb[2]; e[3]++;
    hist.set(k, e);
    const { l } = hsl(rgb);
    sumL += l; sumC += chroma(rgb); bands[Math.min(9, Math.floor(l / 10))]++; total++;
  }
  const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1], a[2] - b[2]);
  const merged = [];
  for (const [r, g, b, n] of [...hist.values()].sort((a, b) => b[3] - a[3])) {
    const rgb = [Math.round(r / n), Math.round(g / n), Math.round(b / n)];
    const near = merged.find(m => dist(m.rgb, rgb) < 40);
    if (near) { near.n += n; continue; }
    merged.push({ rgb, n });
    if (merged.length >= 64) break;
  }
  merged.sort((a, b) => b.n - a.n);
  const palette = merged.slice(0, maxColors).map(m => {
    const { h, s, l } = hsl(m.rgb);
    return { hex: hex(m.rgb), hsl: `hsl(${h} ${s}% ${l}%)`, oklch: oklch(m.rgb),
             share: +(100 * m.n / total).toFixed(1),
             chroma: chroma(m.rgb), role: role(m.rgb), temperature: chroma(m.rgb) < 6 ? 'achromatic' : temp(h) };
  });
  const dominant = merged[0].rgb;
  const accents = palette.filter(p => p.chroma >= 26);

  const pairs = [];
  for (let i = 0; i < palette.length; i++) for (let j = i + 1; j < palette.length; j++) {
    const A = palette[i].hex.match(/\w\w/g).map(x => parseInt(x, 16));
    const B = palette[j].hex.match(/\w\w/g).map(x => parseInt(x, 16));
    pairs.push({ pair: `${palette[i].hex} on ${palette[j].hex}`, ratio: contrast(A, B) });
  }

  // ---- composition: where is the ink? ----
  // Threshold stays tight: on a dark UI, panel surfaces sit only ~20 away from
  // the page background, and a loose threshold counts every panel as empty field.
  const isBg = rgb => dist(rgb, dominant) < 12;
  const grey = ([r, g, b]) => (r + g + b) / 3;
  let ink = 0, edges = 0;
  const ROWS = 24, COLS = 24;
  const rowInk = new Array(ROWS).fill(0), colInk = new Array(COLS).fill(0);
  const step = Math.max(1, Math.round(Math.min(W, H) / 400));
  let sampled = 0;
  for (let y = 0; y < H; y += step) for (let x = 0; x < W; x += step) {
    const rgb = at(x, y); sampled++;
    if (!isBg(rgb)) { ink++; rowInk[Math.min(ROWS - 1, Math.floor(ROWS * y / H))]++; colInk[Math.min(COLS - 1, Math.floor(COLS * x / W))]++; }
    // local gradient: detail density, independent of which color is the background
    const g0 = grey(rgb);
    if (x + step < W && Math.abs(g0 - grey(at(x + step, y))) > 12) edges++;
    else if (y + step < H && Math.abs(g0 - grey(at(x, y + step))) > 12) edges++;
  }
  const norm = a => { const mx = Math.max(...a) || 1; return a.map(v => +(v / mx).toFixed(2)); };
  const grid = [];
  for (let gy = 0; gy < 3; gy++) { const row = [];
    for (let gx = 0; gx < 3; gx++) {
      const h2 = new Map();
      for (let y = Math.floor(gy * H / 3); y < (gy + 1) * H / 3; y += step)
        for (let x = Math.floor(gx * W / 3); x < (gx + 1) * W / 3; x += step) {
          const rgb = at(x, y); const k = ((rgb[0] >> 4) << 8) | ((rgb[1] >> 4) << 4) | (rgb[2] >> 4);
          const e = h2.get(k) || [0, 0, 0, 0]; e[0] += rgb[0]; e[1] += rgb[1]; e[2] += rgb[2]; e[3]++; h2.set(k, e);
        }
      const [r, g, b, n] = [...h2.values()].sort((p, q) => q[3] - p[3])[0];
      row.push(hex([Math.round(r / n), Math.round(g / n), Math.round(b / n)]));
    }
    grid.push(row); }
  const colN = norm(colInk), rowN = norm(rowInk);
  const centroid = a => { const t = a.reduce((x, y) => x + y, 0) || 1;
    return +(a.reduce((x, v, i) => x + v * (i + 0.5) / a.length, 0) / t).toFixed(2); };
  const mirror = a => { const rev = [...a].reverse();
    return +(1 - a.reduce((x, v, i) => x + Math.abs(v - rev[i]), 0) / a.length).toFixed(2); };

  return {
    source: { file: 'see argv', width: img.naturalWidth, height: img.naturalHeight, sampled: `${W}x${H}`,
              aspect: +(img.naturalWidth / img.naturalHeight).toFixed(2) },
    palette,
    color: {
      key: (sumL / total) > 62 ? 'light' : (sumL / total) < 38 ? 'dark' : 'mid',
      averageLightness: Math.round(sumL / total),
      averageChroma: Math.round(sumC / total),
      neutralShare: +palette.filter(p => p.chroma < 26).reduce((a, p) => a + p.share, 0).toFixed(1),
      accentShare: +accents.reduce((a, p) => a + p.share, 0).toFixed(1),
      accentHexes: accents.map(p => p.hex),
      temperatures: [...new Set(palette.filter(p => p.chroma >= 6).map(p => p.temperature))],
      lightnessDeciles: bands.map(b => +(100 * b / total).toFixed(1)),
      dominant: hex(dominant),
    },
    contrastPairs: pairs.sort((a, b) => b.ratio - a.ratio).slice(0, 8),
    composition: {
      inkCoverage: +(100 * ink / sampled).toFixed(1),
      backgroundShare: +(100 - 100 * ink / sampled).toFixed(1),
      edgeDensity: +(100 * edges / sampled).toFixed(1),
      rowDensity: rowN,
      colDensity: colN,
      horizontalCentroid: centroid(colInk),
      verticalCentroid: centroid(rowInk),
      mirrorSymmetry: mirror(colN),
      balance: (() => { const c = centroid(colInk);
        return c < 0.45 ? 'weighted left' : c > 0.55 ? 'weighted right' : 'horizontally centered'; })(),
      gridDominantColors: grid,
    },
  };
}, { dataUri, maxColors });
result.source.file = file;
await browser.close();
console.log(JSON.stringify(result, null, 2));
```

```bash
node "$OUT/palette.mjs" "$OUT/out/desktop-fold.png" 10
```

Run it on the **fold** shot for the palette that greets a visitor, and on the **full-page** shot for the palette of the whole page. On a plain image input, run it on the image.

**How to read the composition numbers:**

| Field | Meaning |
|---|---|
| `inkCoverage` / `backgroundShare` | Share of pixels that differ from / match the dominant background color. Measured reference points: an airy marketing page ≈ 17% ink, a panelled dashboard ≈ 32%, a full-bleed photograph ≈ 70%. On a light page `backgroundShare` is roughly whitespace; on a dark UI it is the field the panels sit on, which is not the same thing — don't call it whitespace there |
| `edgeDensity` | Share of pixels on a hard tonal edge. This is a *detail* measure, not a fullness measure: text-heavy layouts and textured photography push it up, while large flat fields keep it low even when the screen is packed. A dense dashboard of flat panels can score below an airy marketing page. Use it to separate "detailed" from "flat", and `inkCoverage` to separate "full" from "empty" |
| `rowDensity` | 24 horizontal bands, normalized. Zeros are breathing room; runs of high values are content blocks. This is the page's vertical rhythm |
| `colDensity` | 24 vertical bands. Peaks are content columns; flat edges are margins |
| `horizontalCentroid` | 0.5 = visual weight centered, <0.45 left, >0.55 right |
| `mirrorSymmetry` | 1.0 = perfectly mirrored layout, below ~0.7 = deliberately asymmetric |
| `gridDominantColors` | Dominant color per third — catches dark bands, split-screen layouts, colored hero blocks |
| `lightnessDeciles` | Tonal distribution. A spike in the top decile means a light UI on white; two spikes means a hard light/dark split |


---

## Project adaptation — overrides the source paths above

| Source says | Use instead | Why |
|---|---|---|
| write scripts to `/tmp/design-analysis/` | the project's git-ignored scratch folder (`.ai_log/ux-forensics/` by this kit's convention) | Throwaway evidence stays out of git; durable findings go to `docs/ux/`. |
| `http://localhost:3000` | `{config.dev_url}` | The project's dev server, read from `{config.frontend_runtime}`. |
| any deployed URL | the project's per-PR / staging preview | Deployed verification NEVER runs against production. |
| viewports `1440x900` + `390x844` | the project's pinned breakpoint ladder (commonly `375 / 768 / 1024 / 1440`) | The design oracle pins the widths (`docs/design/` manifest + `designer-frontend-contract`). Edit the `vp` array in `capture.mjs` before running. |
| `npm i -D playwright` | prefer the project's existing install | Most repos already carry Playwright as a dev dependency for e2e. Resolve from `node_modules`; do not add a global install. |

- A browser DRIVER and these SCRIPTS coexist: drive the page (the `agent-browser` CLI, Playwright, or a browser MCP) for interactive snapshot/click/console reads; run these scripts when you need **measured numbers** (exact hexes, area shares, computed type scale, composition metrics).
- Analysing a page of the project's own app? The measured values must reconcile against `docs/design/design-tokens.md` + the token source `{config.frontend_runtime}` declares. A measured value that has no token is a finding, not a new token — report it, never silently mint one.
