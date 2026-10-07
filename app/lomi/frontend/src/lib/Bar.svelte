<script lang="ts">
  import type {Level} from "./format";

  let {pct, lvl, barStyle = "ascii", width = 10}: {
    pct: number | null;
    lvl: Level;
    barStyle?: string;
    width?: number;
  } = $props();

  const clamped = $derived(pct === null ? 0 : Math.min(100, Math.max(0, pct)));
  const filled = $derived(Math.floor((clamped * width) / 100));
  const label = $derived(pct === null ? "no data yet" : `${Math.floor(clamped)}% used`);
</script>

{#if barStyle === "smooth"}
  <span class="smooth {lvl}" role="img" aria-label={label} style="width: {width * 0.62}em">
    <span class="fill" style="width: {clamped}%"></span>
  </span>
{:else}
  <span class="ascii {lvl}" role="img" aria-label={label}>[{"#".repeat(filled)}{"-".repeat(width - filled)}]</span>
{/if}

<style>
  .ascii {
    white-space: pre;
  }
  .smooth {
    display: inline-block;
    height: 0.62em;
    border-radius: 99px;
    background: var(--track);
    overflow: hidden;
    vertical-align: middle;
  }
  .fill {
    display: block;
    height: 100%;
    border-radius: 99px;
    background: currentColor;
    transition: width 0.4s ease;
  }
  .ok {
    color: var(--green);
  }
  .warn {
    color: var(--yellow);
  }
  .danger {
    color: var(--red);
  }
  .none {
    color: var(--dim);
  }
  @media (prefers-reduced-motion: reduce) {
    .fill {
      transition: none;
    }
  }
</style>
