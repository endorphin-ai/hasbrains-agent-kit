<script lang="ts">
  import type {Agent, Config} from "../../bindings/lomi";
  import Bar from "./Bar.svelte";
  import Icon from "./Icon.svelte";
  import {fmtCost, fmtDate, fmtDur, fmtTokens, level} from "./format";

  let {agents, config, empty, showProject = false}: {
    agents: Agent[];
    config: Config;
    empty: string;
    showProject?: boolean;
  } = $props();

  // Totals over the rows on screen, and the cost split by model.
  const totals = $derived.by(() => {
    const byModel = new Map<string, number>();
    let cost = 0, tokensIn = 0, tokensOut = 0, tools = 0;
    for (const a of agents) {
      cost += a.costUsd;
      tokensIn += a.tokensIn;
      tokensOut += a.tokensOut;
      tools += a.toolCalls;
      if (a.hasCost) byModel.set(a.model || "?", (byModel.get(a.model || "?") ?? 0) + a.costUsd);
    }
    const models = [...byModel.entries()].sort((x, y) => y[1] - x[1]);
    return {cost, tokensIn, tokensOut, tools, models};
  });

  const shortModel = (m: string) => m.replace(/^claude-/, "");
</script>

{#if agents.length > 0}
  <p class="totals dim">
    {agents.length} agents · <span class="cost" title="Tokens priced with the prices in Settings">{fmtCost(totals.cost)} est.</span>
    · ↓{fmtTokens(totals.tokensIn)} ↑{fmtTokens(totals.tokensOut)} · {totals.tools} tools
    {#each totals.models as [m, c]}<span> · {shortModel(m)} {fmtCost(c)}</span>{/each}
  </p>
{/if}
<div class="agents">
  {#each agents as a, i (`${a.name}-${a.finishedAt}-${i}`)}
    {@const lvl = level(a.contextPct, config.warnAt, config.dangerAt)}
    <div class="agent" class:wide={showProject}>
      <span class="dim">{#if a.running}<span class="green" title="Running"><Icon name="clock" spin={config.motion}/></span>{:else}·{/if}</span>
      <span class="model name" title={a.name}>{a.name}</span>
      <Bar pct={a.contextPct} {lvl} barStyle={config.barStyle}/>
      <span class="dim">{a.contextPct}%</span>
      <span class="dim name" title={a.model}>{shortModel(a.model)}</span>
      <span class="cost num">{a.hasCost ? fmtCost(a.costUsd) : ""}</span>
      <span class="dim num">↓{fmtTokens(a.tokensIn)}</span>
      <span class="dim num">↑{fmtTokens(a.tokensOut)}</span>
      <span class="dim num">{fmtDur(a.durationSec)}</span>
      <span class="dim num">{a.toolCalls > 0 ? `${a.toolCalls} tools` : ""}</span>
      <span class="dim date">{a.running ? "running" : fmtDate(a.finishedAt)}</span>
      {#if showProject}<span class="dim name" title={a.project}>{a.project}</span>{/if}
    </div>
  {:else}
    <p class="note">{empty}</p>
  {/each}
</div>

<style>
  .totals {
    font-size: 0.86em;
    margin: 0 0 4px;
  }
  .agents {
    overflow: hidden;
  }
  .agent {
    display: grid;
    grid-template-columns: 2ch minmax(8ch, 18ch) auto 4ch minmax(5ch, 9ch) 7ch 8ch 7ch 8ch 9ch minmax(0, 1fr);
    gap: 1ch;
    align-items: baseline;
    white-space: nowrap;
    line-height: 1.7;
  }
  .agent > :global(*) {
    min-width: 0;
  }
  .agent.wide {
    grid-template-columns: 2ch minmax(8ch, 18ch) auto 4ch minmax(5ch, 9ch) 7ch 8ch 7ch 8ch 9ch minmax(0, 16ch) minmax(0, 1fr);
  }
  .green {
    color: var(--green);
  }
  .model {
    color: var(--model);
  }
  .cost {
    color: var(--cost);
  }
  .name {
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .num {
    text-align: right;
    font-variant-numeric: tabular-nums;
  }
  .date {
    padding-left: 1ch;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .note {
    color: var(--dim);
    margin: 4px 0 0;
  }
</style>
