<script lang="ts">
  import {onMount} from "svelte";
  import {Browser} from "@wailsio/runtime";
  import {DeckService, type Config, type Run, type Session, type Snapshot} from "../bindings/lomi";
  import AgentRows from "./lib/AgentRows.svelte";
  import Bar from "./lib/Bar.svelte";
  import Icon from "./lib/Icon.svelte";
  import Mascot from "./lib/Mascot.svelte";
  import Settings from "./lib/Settings.svelte";
  import {fmtAgo, fmtCost, fmtCountdown, fmtDur, fmtReset, level} from "./lib/format";

  const ALL = "all";

  let config = $state<Config | null>(null);
  let snap = $state<Snapshot | null>(null);
  let error = $state("");
  let now = $state(Date.now());
  let showSettings = $state(false);
  let filter = $state("");
  let tab = $state(ALL); // ALL or a session id

  async function refresh() {
    try {
      snap = await DeckService.Snapshot();
      error = "";
    } catch (e: any) {
      // Keep the last good snapshot on screen; only report the failure.
      error = e?.message ?? String(e);
    }
  }

  onMount(() => {
    DeckService.GetConfig().then((c) => (config = c)).catch((e) => (error = String(e)));
    refresh();
    const clock = setInterval(() => (now = Date.now()), 1000);
    return () => clearInterval(clock);
  });

  // Re-read the data on the configured interval.
  $effect(() => {
    const every = (config?.refreshSeconds ?? 2) * 1000;
    const poll = setInterval(refresh, every);
    return () => clearInterval(poll);
  });

  const lvl = (pct: number | null) => level(pct, config?.warnAt ?? 50, config?.dangerAt ?? 75);

  // A fixed order, so the tabs do not move each time a session refreshes.
  const sessions = $derived(
    [...(snap?.sessions ?? [])].sort((a, b) => a.project.localeCompare(b.project) || a.id.localeCompare(b.id)),
  );
  const limits = $derived(snap?.limits ?? []);
  const anyLive = $derived(sessions.some((s) => s.live));
  const compact = $derived(config?.compact ?? false);
  const current = $derived(sessions.find((s) => s.id === tab) ?? null);

  // Sessions in the same project get a number, so their tabs differ.
  const tabLabels = $derived.by(() => {
    const count = new Map<string, number>();
    const base = (s: Session) => s.name || s.project;
    for (const s of sessions) count.set(base(s), (count.get(base(s)) ?? 0) + 1);
    const seen = new Map<string, number>();
    const labels = new Map<string, string>();
    for (const s of sessions) {
      const n = (seen.get(base(s)) ?? 0) + 1;
      seen.set(base(s), n);
      labels.set(s.id, (count.get(base(s)) ?? 0) > 1 ? `${base(s)} #${n}` : base(s));
    }
    return labels;
  });

  const history = $derived.by(() => {
    const all = snap?.agents ?? [];
    const q = filter.trim().toLowerCase();
    return q ? all.filter((a) => `${a.name} ${a.model}`.toLowerCase().includes(q)) : all;
  });

  // The ring follows the session limit. Without limit data it follows the
  // fullest context window, so it still says something useful.
  const gauge = $derived.by(() => {
    if (limits.length > 0) return {pct: limits[0].usedPct as number | null, caption: limits[0].label};
    const known = sessions.filter((s) => s.contextPct !== null).map((s) => s.contextPct as number);
    return {pct: known.length ? Math.max(...known) : null, caption: "fullest context"};
  });
  const alertLimit = $derived(
    [...limits].sort((a, b) => b.usedPct - a.usedPct).find((l) => l.usedPct >= (config?.limitAlertAt ?? 90)) ?? null,
  );

  function runElapsed(r: Run): number {
    const end = r.done && r.endedAt > 0 ? r.endedAt : now / 1000;
    return Math.max(0, end - r.startedAt);
  }

  const HOMEPAGE = "https://hasbrains.com/";
  const openHomepage = () => Browser.OpenURL(HOMEPAGE).catch((e: any) => (error = e?.message ?? String(e)));

  const pctText = (s: Session) =>
    s.contextPct === null ? "--%" : `${s.source === "transcript" ? "~" : ""}${s.contextPct}%`;

  async function toggleCompact() {
    if (!config) return;
    try {
      config = await DeckService.SaveConfig({...config, compact: !config.compact} as Config);
    } catch (e: any) {
      error = e?.message ?? String(e);
    }
  }
</script>

{#snippet sessionLine(s: Session)}
  <span class="model">{s.model}</span>
  <span class="dim">|</span>
  <Bar pct={s.contextPct} lvl={lvl(s.contextPct)} barStyle={config?.barStyle}/>
  <span class="dim pct">{pctText(s)}</span>
  <span class="project" title={s.cwd}>{tabLabels.get(s.id)}</span>
  {#if s.git && config?.git.show}
    {#if config.git.repo}<span class="git" title="Repository"><Icon name="repo"/> {s.git.repo}</span>{/if}
    {#if config.git.branch}<span class="git" title="Branch"><Icon name="branch"/> {s.git.branch}</span>{/if}
    {#if config.git.worktree && s.git.worktree}<span class="git" title="Worktree"><Icon name="worktree"/> {s.git.worktree}</span>{/if}
  {/if}
  {#if s.costUsd > 0}
    <span class="cost" title={s.costEstimated ? "Main-loop tokens priced with the prices in Settings" : "Reported by Claude Code"}>{s.costEstimated ? "~" : ""}{fmtCost(s.costUsd)}</span>
  {/if}
  {#if s.run}<span class="cmd">{s.run.command}</span>{/if}
  <span class="dim when">{s.live ? "live" : fmtAgo(s.updatedAt, now)}</span>
{/snippet}

{#snippet runLine(r: Run)}
  <div class="run">
    <span class="cmd"><Icon name="bolt"/> {r.command}</span>
    {#if r.done && r.endedAt > 0}
      <span class="green"><Icon name="check"/> {fmtDur(runElapsed(r))}</span>
    {:else}
      <span class="green"><Icon name="clock" spin={config?.motion}/> {fmtDur(runElapsed(r))}</span>
    {/if}
    {#if r.agentCount > 0}
      <span class="dim">·</span> {r.agentCount} agents
      <span class="dim">·</span> <span class="cost" title="Tokens priced with the prices in Settings">{fmtCost(r.costUsd)}</span>
    {/if}
  </div>
{/snippet}

<header class="titlebar">
  <span class="title">Lomi</span>
  <span class="state" class:live={anyLive} class:pulse={anyLive && config?.motion}><span class="dot" aria-hidden="true"></span>{anyLive ? "live" : "idle"}</span>
  <span class="spacer"></span>
  <button class="ghost" onclick={toggleCompact} aria-pressed={compact} title="Sessions and limits only"><Icon name={compact ? "expand" : "collapse"}/> {compact ? "Expand" : "Compact"}</button>
  <button class="ghost" onclick={() => (showSettings = !showSettings)} aria-expanded={showSettings}><Icon name="sliders"/> Settings</button>
</header>

<main>
  {#if error}<p class="error" role="alert">Could not read the data: {error}</p>{/if}

  {#if !snap || !config}
    <p class="dim">Reading Claude Code data…</p>
  {:else}
    {#if config.panels.limits}
      <section aria-label="Usage limits">
        <h2>Usage limits {#if snap.limitsAt && now / 1000 - snap.limitsAt > 120}<span class="dim plain">· as of {fmtAgo(snap.limitsAt, now)}</span>{/if}</h2>
        <div class="gauge-row">
          {#if config.mascot}
            <Mascot pct={gauge.pct} caption={gauge.caption} motion={config.motion}/>
          {/if}
          <div class="limits">
            {#if alertLimit}
              <p class="bubble" role="status">{Math.round(alertLimit.usedPct)}% of "{alertLimit.label}" used. Pace yourself.</p>
            {/if}
        {#each limits as l (l.key)}
          <div class="limit" class:alert={l.usedPct >= config.limitAlertAt}>
            <div class="limit-name">
              <span>{l.label}</span>
              <span class="dim small">
                {[l.note, l.resetsAt ? `Resets ${fmtReset(l.resetsAt, now)}` : "", l.resetsAt ? `in ${fmtCountdown(l.resetsAt, now)}` : ""].filter(Boolean).join(" · ")}
              </span>
            </div>
            <Bar pct={l.usedPct} lvl={lvl(l.usedPct)} barStyle={config.barStyle} width={20}/>
            <span class="limit-pct {lvl(l.usedPct)}">{Math.round(l.usedPct)}%</span>
          </div>
        {:else}
          <p class="note">
            {#if config.modelLimits && !snap.limitsError}
              Asking Anthropic for the limits…
            {:else if !snap.bridge.installed}
              Limits come from the status line data. <button class="link" onclick={() => (showSettings = true)}>Install the bridge</button> to show them.
            {:else}
              No limits reported yet. Claude Code sends them after the first reply of a session, on subscription plans only.
            {/if}
          </p>
        {/each}
            {#if config.modelLimits && snap.limitsError}
              <p class="note" role="status">Per-model limits: {snap.limitsError}.</p>
            {/if}
          </div>
        </div>
      </section>
    {/if}

    {#if !compact}
      <div class="tabs" role="tablist" aria-label="Sessions">
        <button role="tab" aria-selected={!current} class:selected={!current} onclick={() => (tab = ALL)}>All <span class="dim">{sessions.length}</span></button>
        {#each sessions as s (s.id)}
          <button role="tab" aria-selected={current?.id === s.id} class:selected={current?.id === s.id} onclick={() => (tab = s.id)} title={`${tabLabels.get(s.id)} · ${s.cwd}`}>
            <span class="dot" class:live={s.live} aria-hidden="true">{s.live ? "●" : "○"}</span>
            <span class="tab-name">{tabLabels.get(s.id)}</span>
            {#if s.run && !s.run.done}<span class="cmd">{s.run.command}</span>{/if}
          </button>
        {/each}
      </div>
    {/if}

    {#if current && !compact}
      <div class="panel" role="tabpanel" aria-label={tabLabels.get(current.id)}>
        {#if config.panels.sessions}
          <div class="session" class:stale={!current.live}>{@render sessionLine(current)}</div>
        {/if}
        {#if config.panels.run}
          {#if current.run}
            {@render runLine(current.run)}
          {:else}
            <p class="note">No /command run in this session yet.</p>
          {/if}
        {/if}
        {#if config.panels.agents}
          <h2 class="gap">Subagents of this session</h2>
          <AgentRows agents={current.agents ?? []} {config} empty="This session has not started a subagent yet."/>
        {/if}
      </div>
    {:else}
      {#if config.panels.sessions}
        <section aria-label="All sessions">
          {#each sessions as s (s.id)}
            <button class="session row" class:stale={!s.live} onclick={() => (tab = s.id)} disabled={compact}>{@render sessionLine(s)}</button>
          {:else}
            <p class="note">No open Claude Code session.</p>
          {/each}
          {#if sessions.some((s) => s.source === "transcript")}
            <p class="note">~ estimated from the transcript, with the prices in Settings. <button class="link" onclick={() => (showSettings = true)}>Install the bridge</button> for the exact value, cost and limits.</p>
          {/if}
        </section>
      {/if}

      {#if !compact && config.panels.agents}
        <section aria-label="Subagent history">
          <div class="agents-head">
            <h2>Subagent history · all sessions</h2>
            <span class="spacer"></span>
            <input class="filter" type="search" placeholder="Filter by name or model" aria-label="Filter subagents" bind:value={filter}/>
          </div>
          <AgentRows agents={history} {config} showProject empty={filter ? "No subagent matches the filter." : "No subagent has run yet."}/>
        </section>
      {/if}
    {/if}
  {/if}
</main>

<footer class="made">
  <button class="link plain" onclick={openHomepage}>Made with <span class="heart" class:beat={config?.motion}><Icon name="heart"/></span> by HasBrains</button>
</footer>

{#if showSettings && config}
  <Settings {config} bridge={snap?.bridge ?? null} onsaved={(c) => { config = c; refresh(); }} onclose={() => (showSettings = false)}/>
{/if}

<style>
  .titlebar {
    --wails-draggable: drag;
    height: 36px;
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 0 10px 0 14px;
    border-bottom: 1px solid var(--line);
    user-select: none;
    -webkit-user-select: none;
  }
  .titlebar button {
    --wails-draggable: no-drag;
  }
  .title {
    color: var(--model);
    font-weight: 600;
  }
  .state {
    color: var(--dim);
    font-size: 0.85em;
  }
  .state.live {
    color: var(--green);
  }
  .state {
    display: flex;
    align-items: center;
    gap: 0.7ch;
  }
  .state .dot {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: currentColor;
  }
  .state.pulse .dot {
    animation: pulse 1.8s ease-out infinite;
  }
  @keyframes pulse {
    0% { box-shadow: 0 0 0 0 color-mix(in srgb, var(--green) 70%, transparent); }
    100% { box-shadow: 0 0 0 7px transparent; }
  }
  @media (prefers-reduced-motion: reduce) {
    .state.pulse .dot {
      animation: none;
    }
  }
  .gauge-row {
    display: flex;
    align-items: center;
    gap: 20px;
  }
  .limits {
    flex: 1;
    min-width: 0;
  }
  .bubble {
    display: inline-block;
    margin: 0 0 6px;
    padding: 3px 10px;
    border-radius: 10px 10px 10px 2px;
    background: var(--text);
    color: var(--bg);
    font-weight: 600;
  }
  .limit-pct.ok {
    color: var(--green);
  }
  .limit-pct.warn {
    color: var(--yellow);
  }
  .limit-pct.danger {
    color: var(--red);
  }
  .spacer {
    flex: 1;
  }
  main {
    padding: 12px 16px 16px;
    overflow-x: hidden;
    overflow-y: auto;
    height: calc(100vh - 37px - 29px);
  }
  section {
    margin-bottom: 16px;
  }
  h2 {
    font-size: 0.78em;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--dim);
    font-weight: 600;
    margin: 0 0 6px;
  }
  .plain {
    text-transform: none;
    letter-spacing: 0;
    font-weight: 400;
  }
  .session {
    display: flex;
    align-items: baseline;
    gap: 1ch;
    white-space: nowrap;
    line-height: 1.7;
    overflow: hidden;
  }
  .session > :global(.git),
  .session > .project {
    min-width: 0;
    flex-shrink: 1;
  }
  .session > :global(:not(.git):not(.project)) {
    flex-shrink: 0;
  }
  .session.stale {
    opacity: 0.6;
  }
  .model {
    color: var(--model);
  }
  .project {
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .when {
    margin-left: auto;
  }
  .pct {
    min-width: 4ch;
  }
  .cost {
    color: var(--cost);
  }
  .git {
    color: var(--dim);
    display: inline-flex;
    align-items: baseline;
    gap: 0.5ch;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .made {
    height: 29px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-top: 1px solid var(--line);
    font-size: 0.86em;
  }
  .made :global(button.plain) {
    color: var(--dim);
    text-decoration: none;
  }
  .made :global(button.plain:hover) {
    color: var(--text);
  }
  .heart {
    color: var(--red);
    display: inline-block;
  }
  .heart.beat {
    animation: beat 1.4s ease-in-out infinite;
  }
  @keyframes beat {
    0%, 40%, 100% { transform: scale(1); }
    20% { transform: scale(1.28); }
  }
  @media (prefers-reduced-motion: reduce) {
    .heart.beat {
      animation: none;
    }
  }
  .green {
    color: var(--green);
  }
  .cmd {
    color: var(--cmd);
  }
  .small {
    font-size: 0.86em;
  }
  .note {
    color: var(--dim);
    margin: 4px 0 0;
    line-height: 1.5;
  }
  .error {
    color: var(--red);
    margin: 0 0 10px;
  }

  .limit {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto 5ch;
    align-items: center;
    gap: 2ch;
    padding: 5px 0;
    border-top: 1px solid var(--line);
  }
  .limit-name {
    display: flex;
    flex-direction: column;
    min-width: 0;
  }
  .limit-pct {
    font-weight: 700;
    font-size: 1.1em;
    text-align: right;
    font-variant-numeric: tabular-nums;
  }
  .limit.alert .limit-pct {
    color: var(--red);
    font-weight: 600;
  }

  .run {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .agents-head {
    display: flex;
    align-items: baseline;
    gap: 1.5ch;
    flex-wrap: wrap;
    margin-bottom: 4px;
  }
  .agents-head h2 {
    margin: 0;
  }
  .filter {
    width: 28ch;
  }
  .tabs {
    display: flex;
    gap: 4px;
    overflow-x: auto;
    scrollbar-width: none;
    border-bottom: 1px solid var(--line);
    margin-bottom: 12px;
  }
  .tabs::-webkit-scrollbar {
    display: none;
  }
  .tabs button {
    display: flex;
    gap: 0.8ch;
    align-items: baseline;
    white-space: nowrap;
    background: transparent;
    border: none;
    border-bottom: 2px solid transparent;
    border-radius: 0;
    padding: 5px 10px;
    color: var(--dim);
  }
  .tab-name {
    max-width: 22ch;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .tabs button:hover {
    color: var(--text);
  }
  .tabs button.selected {
    color: var(--text);
    border-bottom-color: var(--model);
  }
  .dot.live {
    color: var(--green);
  }
  button.row {
    width: 100%;
    background: transparent;
    border: none;
    border-radius: 4px;
    padding: 0 4px;
    margin: 0 -4px;
    text-align: left;
    opacity: 1;
  }
  button.row:hover:not(:disabled) {
    background: var(--line);
  }
  button.row:disabled {
    cursor: default;
  }
  button.row.stale {
    opacity: 0.6;
  }
  .gap {
    margin-top: 14px;
  }
</style>
