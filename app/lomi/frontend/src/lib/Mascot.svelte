<script lang="ts">
  // A ring gauge with a character whose mood follows the used %.
  let {pct, caption, motion = true}: {
    pct: number | null;
    caption: string;
    motion?: boolean;
  } = $props();

  // The seven moods of the icon sheet. A mood applies from its `from` value up.
  const STAGES = [
    {from: 0, key: "fresh", label: "Fresh"},
    {from: 20, key: "normal", label: "Normal"},
    {from: 40, key: "working", label: "Working"},
    {from: 60, key: "heavy", label: "Getting heavy"},
    {from: 75, key: "tired", label: "Tired"},
    {from: 90, key: "almost", label: "Almost out"},
    {from: 100, key: "out", label: "Out of tokens"},
  ] as const;

  // Each gauge needs its own gradient id, or all of them take the first one's colours.
  const uid = $props.id();
  const gradient = `deck-body-${uid}`;

  const R = 52;
  const CIRC = 2 * Math.PI * R;
  const clamped = $derived(pct === null ? 0 : Math.min(100, Math.max(0, pct)));
  // 99.6% shows as "100%", so it must also look like 100%.
  const stage = $derived(
    pct === null ? null : [...STAGES].reverse().find((s) => Math.round(clamped) >= s.from) ?? STAGES[0],
  );
  const key = $derived(stage?.key ?? "idle");
  const mood = $derived(stage?.label ?? "No data yet");
  const label = $derived(pct === null ? `${caption}: no data yet` : `${caption}: ${Math.round(clamped)}% used, ${mood}`);
</script>

<figure class="mascot {key}" class:still={!motion}>
  <svg viewBox="0 0 120 120" role="img" aria-label={label}>
    <defs>
      <radialGradient id={gradient} cx="34%" cy="24%" r="85%">
        <stop offset="0%" stop-color="var(--hi)"/>
        <stop offset="100%" stop-color="var(--tone)"/>
      </radialGradient>
    </defs>

    <circle class="track" cx="60" cy="60" r={R}/>
    {#if clamped > 0}
      <circle class="arc" cx="60" cy="60" r={R} stroke-dasharray="{(clamped / 100) * CIRC} {CIRC}" transform="rotate(-90 60 60)"/>
    {/if}

    <!-- The mood is redrawn when it changes, so it pops in. -->
    {#key key}
      <g transform="translate(60 68) scale(1.28) translate(-60 -68)">
      <g class="pop">
        {#if key === "out"}
          <ellipse class="shadow" cx="62" cy="91" rx="36" ry="4"/>
          <path class="smoke" d="M77 68c-7-3 5-6-1-9.5c-6-3.5 6-6 0-10"/>
          <rect class="bar" x="51" y="68" width="3.4" height="7" rx="1.7"/>
          <rect class="bar" x="57.5" y="65" width="3.4" height="10" rx="1.7"/>
          <path class="body" d="M30 87c1-9 12-14 26-13 12-2 22 3 27 9 7-1 13 1 13 5 0 3-6 4-34 4-26 0-32-1-32-5z" fill="url(#{gradient})"/>
          <ellipse class="shine" cx="42" cy="80" rx="5" ry="1.8" transform="rotate(-14 42 80)"/>
          <path class="line" d="M48 80l4 4m0-4l-4 4M66 80l4 4m0-4l-4 4"/>
        {:else}
          <ellipse class="shadow" cx="60" cy="92" rx="27" ry="3.5"/>
          <g class="buddy">
            <rect class="bar b1" x="54.2" y="35" width="3.6" height="8" rx="1.8"/>
            <rect class="bar b2" x="61.2" y="31" width="3.6" height="12" rx="1.8"/>
            <path class="body" d="M33 80c-3-19 8-34 27-34s30 15 27 34c0 7-7 10-27 10s-27-3-27-10z" fill="url(#{gradient})"/>
            <ellipse class="shine" cx="45" cy="56" rx="5.5" ry="3" transform="rotate(-38 45 56)"/>

            {#if key === "fresh" || key === "normal"}
              <g class="eyes"><circle class="ink" cx="50" cy="70" r="3.3"/><circle class="ink" cx="70" cy="70" r="3.3"/></g>
              <path class="line" d="M55.5 75.5q4.5 5 9 0"/>
            {:else if key === "working"}
              <g class="eyes"><circle class="ink" cx="50" cy="70" r="3.3"/><circle class="ink" cx="70" cy="70" r="3.3"/></g>
              <path class="line" d="M56 77h8"/>
            {:else if key === "heavy"}
              <g class="brows"><path class="line thin" d="M46 65.5q3.5-3 7-2.5M74 65.5q-3.5-3-7-2.5"/></g>
              <g class="eyes">
                <circle class="ink" cx="50.5" cy="71" r="3.3"/><circle class="ink" cx="69.5" cy="71" r="3.3"/>
                <circle class="glint" cx="51.6" cy="69.9" r="1"/><circle class="glint" cx="70.6" cy="69.9" r="1"/>
              </g>
              <path class="line" d="M56.5 79.5q3.5-4 7 0"/>
            {:else if key === "tired"}
              <path class="line" d="M46 67l6 3.5-6 3.5M74 67l-6 3.5 6 3.5"/>
              <path class="line" d="M54 79.5q1.5-3 3 0t3 0 3 0 3 0"/>
              <path class="drop" d="M79 52c-4.5 6-5.5 9-5.5 11a5.5 5.5 0 0 0 11 0c0-2-1-5-5.5-11z"/>
            {:else if key === "almost"}
              <path class="line" d="M46 66l6 3.5-6 3.5M74 66l-6 3.5 6 3.5"/>
              <path class="ink" d="M55 81.5c0-5 2.2-7 5-7s5 2 5 7c-1.5-1.6-3-2.2-5-2.2s-3.5.6-5 2.2z"/>
              <path class="drop" d="M80 54c-4 5.5-5 8-5 10a5 5 0 0 0 10 0c0-2-1-4.5-5-10z"/>
            {:else}
              <path class="line" d="M46 71q4 3 8 0M66 71q4 3 8 0"/>
              <path class="line" d="M57 78h6"/>
            {/if}
          </g>
          {#if key === "almost"}
            <path class="marks" d="M30 71q-2.5 5 0 10M26.5 73q-1.8 3.5 0 7M90 71q2.5 5 0 10M93.5 73q1.8 3.5 0 7"/>
          {:else if key === "idle"}
            <text class="zzz" x="88" y="40">z</text>
          {/if}
        {/if}
      </g>
      </g>
    {/key}
  </svg>
  <figcaption>
    <span class="pct">{pct === null ? "--%" : `${Math.round(clamped)}%`}</span>
    <span class="mood">{mood}</span>
    <span class="dim">{caption}</span>
  </figcaption>
</figure>

<style>
  .mascot {
    --tone: #6f7180;
    --hi: #a9abb8;
    margin: 0;
    width: 132px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 2px;
    flex: none;
  }
  .fresh {
    --tone: #5fe0a0;
    --hi: #a8f5cd;
  }
  .normal {
    --tone: #7aaeff;
    --hi: #b9d6ff;
  }
  .working {
    --tone: #ab92ff;
    --hi: #d3c5ff;
  }
  .heavy {
    --tone: #ffcf5c;
    --hi: #ffe7a6;
  }
  .tired {
    --tone: #ff8a3d;
    --hi: #ffb987;
  }
  .almost {
    --tone: #ff5f63;
    --hi: #ff9c9e;
  }
  .out {
    --tone: #6e6f80;
    --hi: #9697a6;
  }

  svg {
    width: 124px;
    height: 124px;
    overflow: visible;
  }
  .track, .arc {
    fill: none;
    stroke-width: 7;
  }
  .track {
    stroke: var(--track);
  }
  .arc {
    stroke: var(--tone);
    stroke-linecap: round;
    transition: stroke-dasharray 0.8s ease, stroke 0.4s ease;
  }
  .shadow {
    fill: #000;
    opacity: 0.4;
  }
  .bar {
    fill: var(--tone);
  }
  .shine {
    fill: #fff;
    opacity: 0.38;
  }
  .ink {
    fill: #14151b;
  }
  .glint {
    fill: #fff;
  }
  .line, .marks, .smoke {
    fill: none;
    stroke: #14151b;
    stroke-width: 2.6;
    stroke-linecap: round;
    stroke-linejoin: round;
  }
  .thin {
    stroke-width: 2;
  }
  .marks {
    stroke: var(--dim);
    stroke-width: 2;
  }
  .smoke {
    stroke: var(--hi);
    stroke-width: 3;
  }
  .drop {
    fill: #fff;
    opacity: 0.92;
  }
  .zzz {
    fill: var(--dim);
    font-size: 13px;
    font-weight: 700;
  }
  figcaption {
    display: flex;
    flex-direction: column;
    align-items: center;
    line-height: 1.25;
    white-space: nowrap;
    font-size: 0.86em;
  }
  .pct {
    color: var(--tone);
    font-weight: 700;
    font-size: 1.3em;
  }
  .mood {
    color: var(--text);
  }

  /* Motion. Every mood floats and blinks; the later ones add their own. */
  .pop {
    transform-origin: 60px 70px;
    animation: pop 0.45s cubic-bezier(0.3, 1.5, 0.5, 1);
  }
  .buddy {
    transform-origin: 60px 90px;
    animation: float 3.6s ease-in-out infinite;
  }
  .eyes {
    transform-origin: 60px 70px;
    animation: blink 4.2s infinite;
  }
  .bar {
    transform-box: fill-box;
    transform-origin: 50% 100%;
    animation: signal 1.8s ease-in-out infinite;
  }
  .b2 {
    animation-delay: 0.3s;
  }
  .working .buddy {
    animation: work 1.4s ease-in-out infinite;
  }
  .heavy .buddy {
    animation: sag 3s ease-in-out infinite;
  }
  .brows {
    transform-origin: 60px 64px;
    animation: worry 2.4s ease-in-out infinite;
  }
  .tired .buddy {
    animation: pant 1.1s ease-in-out infinite;
  }
  .almost .buddy {
    animation: shake 0.42s linear infinite;
  }
  .drop {
    animation: drip 1.5s ease-in infinite;
  }
  .marks {
    animation: flicker 0.42s steps(2) infinite;
  }
  .almost .arc {
    animation: glow 1.3s ease-in-out infinite;
  }
  .out .bar {
    animation: none;
    opacity: 0.8;
  }
  .smoke {
    stroke-dasharray: 34;
    animation: smoke 2.6s ease-out infinite;
  }
  .out .body {
    transform-origin: 62px 91px;
    animation: melt 4s ease-in-out infinite;
  }
  .zzz {
    animation: drift 2.8s ease-in-out infinite;
  }
  @keyframes pop {
    0% { transform: scale(0.55); opacity: 0; }
    100% { transform: scale(1); opacity: 1; }
  }
  @keyframes float {
    50% { transform: translateY(-2.5px); }
  }
  @keyframes blink {
    0%, 94%, 100% { transform: scaleY(1); }
    97% { transform: scaleY(0.1); }
  }
  @keyframes signal {
    50% { transform: scaleY(0.6); }
  }
  @keyframes work {
    50% { transform: scale(1.03, 0.97); }
  }
  @keyframes sag {
    50% { transform: scale(1.04, 0.95); }
  }
  @keyframes worry {
    50% { transform: translateY(-1.2px); }
  }
  @keyframes pant {
    50% { transform: scale(1.05, 0.94); }
  }
  @keyframes shake {
    0%, 100% { transform: translateX(0); }
    25% { transform: translateX(-1.6px) rotate(-1.4deg); }
    75% { transform: translateX(1.6px) rotate(1.4deg); }
  }
  @keyframes drip {
    0%, 55% { transform: translateY(0); opacity: 0.92; }
    100% { transform: translateY(13px); opacity: 0; }
  }
  @keyframes flicker {
    50% { opacity: 0.25; }
  }
  @keyframes glow {
    50% { filter: drop-shadow(0 0 8px var(--tone)); }
  }
  @keyframes smoke {
    0% { stroke-dashoffset: 34; opacity: 0; transform: translateY(3px); }
    35% { opacity: 0.9; }
    100% { stroke-dashoffset: 0; opacity: 0; transform: translateY(-6px); }
  }
  @keyframes melt {
    50% { transform: scale(1.04, 0.92); }
  }
  @keyframes drift {
    0% { transform: translate(0, 0); opacity: 0; }
    40% { opacity: 1; }
    100% { transform: translate(5px, -9px); opacity: 0; }
  }
  .still *, .still .arc {
    animation: none !important;
    transition: none !important;
  }
  @media (prefers-reduced-motion: reduce) {
    .mascot * {
      animation: none !important;
      transition: none !important;
    }
  }
</style>
