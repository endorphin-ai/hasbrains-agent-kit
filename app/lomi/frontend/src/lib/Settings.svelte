<script lang="ts">
  import {Application} from "@wailsio/runtime";
  import {DeckService, type BridgeStatus, type Config} from "../../bindings/lomi";
  import Icon from "./Icon.svelte";

  let {config, bridge, onsaved, onclose}: {
    config: Config;
    bridge: BridgeStatus | null;
    onsaved: (c: Config) => void;
    onclose: () => void;
  } = $props();

  const copy = (c: Config): Config => JSON.parse(JSON.stringify(c));

  // Edit a copy; the window keeps the saved config until Save succeeds.
  // svelte-ignore state_referenced_locally
  let draft = $state(copy(config));
  let error = $state("");
  let busy = $state(false);

  async function run(action: () => Promise<void>) {
    busy = true;
    error = "";
    try {
      await action();
    } catch (e: any) {
      error = e?.message ?? String(e);
    } finally {
      busy = false;
    }
  }

  const save = () => run(async () => {
    onsaved(await DeckService.SaveConfig(draft));
    onclose();
  });

  const reset = () => run(async () => {
    const c = await DeckService.ResetConfig();
    draft = copy(c);
    onsaved(c);
  });

  const prices = $derived(draft.prices ?? []);
  const addPrice = () => (draft.prices = [...prices, {match: "", in: 0, out: 0, cacheWrite: 0, cacheRead: 0}]);
  const removePrice = (i: number) => (draft.prices = prices.filter((_, j) => j !== i));

  const installBridge = () => run(async () => {
    bridge = await DeckService.InstallBridge();
  });

  const removeBridge = () => run(async () => {
    bridge = await DeckService.RemoveBridge();
  });
</script>

<section class="settings" aria-label="Settings">
  <header>
    <h2>Settings</h2>
    <button class="ghost" onclick={onclose} aria-label="Close settings">✕</button>
  </header>

  <div class="group">
    <h3>Live session data</h3>
    {#if !bridge?.scriptFound}
      <p class="hint">No status line script found at <code>{bridge?.scriptPath}</code>. Check the Claude directory below.</p>
    {:else if bridge.installed}
      <p class="hint"><span class="on">● Bridge installed</span> in <code>{bridge.scriptPath}</code>. Model, context and limits arrive when a Claude Code session refreshes its status line.</p>
      <button onclick={removeBridge} disabled={busy}>Remove bridge</button>
    {:else}
      <p class="hint">Claude Code gives the model, context % and rate limits only to the status line script. The bridge adds one line to <code>{bridge.scriptPath}</code> that saves this data for Lomi. A backup is kept at <code>.bak.lomi</code>.</p>
      <button class="primary" onclick={installBridge} disabled={busy}>Install bridge</button>
    {/if}
  </div>

  <div class="group">
    <h3>Per-model weekly limits</h3>
    <label class="check"><input type="checkbox" bind:checked={draft.modelLimits}/> Show limits such as "Fable this week"</label>
    <p class="hint">Claude Code does not put these limits in the status line data. When this is on, Lomi reads your Claude Code login from the macOS Keychain every 2 minutes and asks <code>api.anthropic.com</code> for your usage, as the <code>/usage</code> command does. That login is your full Claude login. It is kept in memory for the request only and is sent to no other address. macOS can ask you to allow the Keychain access. The endpoint is not documented and can change.</p>
  </div>

  <div class="group">
    <h3>Panels</h3>
    <label class="check"><input type="checkbox" bind:checked={draft.panels.sessions}/> Sessions</label>
    <label class="check"><input type="checkbox" bind:checked={draft.panels.limits}/> Usage limits</label>
    <label class="check"><input type="checkbox" bind:checked={draft.panels.run}/> Command run</label>
    <label class="check"><input type="checkbox" bind:checked={draft.panels.agents}/> Subagents</label>
  </div>

  <div class="group">
    <h3>Display</h3>
    <label class="row">Bar style
      <select bind:value={draft.barStyle}>
        <option value="ascii">[###-------] like the status line</option>
        <option value="smooth">Smooth</option>
      </select>
    </label>
    <label class="row">Subagent rows
      <input type="number" min="1" max="50" bind:value={draft.maxAgents}/>
    </label>
    <label class="row">Refresh every (seconds)
      <input type="number" min="1" max="60" bind:value={draft.refreshSeconds}/>
    </label>
    <label class="check"><input type="checkbox" bind:checked={draft.compact}/> Compact: sessions and limits only</label>
    <label class="check"><input type="checkbox" bind:checked={draft.mascot}/> Show the ring gauge and its character</label>
    <label class="check"><input type="checkbox" bind:checked={draft.motion}/> Animations</label>
    <label class="check"><input type="checkbox" bind:checked={draft.alwaysOnTop}/> Keep the window open and on top (restart to apply)</label>
  </div>

  <div class="group">
    <h3>Git</h3>
    <label class="check"><input type="checkbox" bind:checked={draft.git.show}/> Show git details for each session</label>
    <label class="check sub"><input type="checkbox" bind:checked={draft.git.repo} disabled={!draft.git.show}/> <Icon name="repo"/> Repository</label>
    <label class="check sub"><input type="checkbox" bind:checked={draft.git.branch} disabled={!draft.git.show}/> <Icon name="branch"/> Branch</label>
    <label class="check sub"><input type="checkbox" bind:checked={draft.git.worktree} disabled={!draft.git.show}/> <Icon name="worktree"/> Worktree</label>
  </div>

  <div class="group">
    <h3>Prices · USD per 1M tokens</h3>
    <p class="hint">Claude Code reports only the total cost of a session, and only through the bridge. Every other cost is the token count times these prices. The first row whose text is part of the model id is used, so put a specific id such as <code>fable-5-1</code> above its family; <code>*</code> matches every model. The defaults are Anthropic's API list prices.</p>
    <table class="prices">
      <thead>
        <tr><th scope="col">Model contains</th><th scope="col">Input</th><th scope="col">Output</th><th scope="col">Cache write</th><th scope="col">Cache read</th><th></th></tr>
      </thead>
      <tbody>
        {#each prices as p, i (i)}
          <tr>
            <td><input type="text" aria-label="Model contains" placeholder="opus" bind:value={p.match} spellcheck="false"/></td>
            <td><input type="number" aria-label="Input price" min="0" step="0.01" bind:value={p.in}/></td>
            <td><input type="number" aria-label="Output price" min="0" step="0.01" bind:value={p.out}/></td>
            <td><input type="number" aria-label="Cache write price" min="0" step="0.01" bind:value={p.cacheWrite}/></td>
            <td><input type="number" aria-label="Cache read price" min="0" step="0.01" bind:value={p.cacheRead}/></td>
            <td><button class="ghost" onclick={() => removePrice(i)} aria-label="Remove price row"><Icon name="trash"/></button></td>
          </tr>
        {/each}
      </tbody>
    </table>
    <button onclick={addPrice}><Icon name="plus"/> Add model</button>
  </div>

  <div class="group">
    <h3>Thresholds</h3>
    <label class="row">Yellow above (% used)
      <input type="number" min="1" max="99" bind:value={draft.warnAt}/>
    </label>
    <label class="row">Red above (% used)
      <input type="number" min="1" max="100" bind:value={draft.dangerAt}/>
    </label>
    <label class="row">Flag a limit at (% used)
      <input type="number" min="1" max="100" bind:value={draft.limitAlertAt}/>
    </label>
  </div>

  <div class="group">
    <h3>Data</h3>
    <label class="row">Claude directory
      <input type="text" placeholder="~/.claude" bind:value={draft.claudeDir} spellcheck="false"/>
    </label>
    <label class="row">Context window (tokens)
      <input type="number" min="1000" step="1000" bind:value={draft.contextWindow}/>
    </label>
    <p class="hint">The context window is used only for the estimate shown while the bridge is off.</p>
  </div>

  {#if error}<p class="error" role="alert">{error}</p>{/if}

  <footer>
    <button class="ghost" onclick={reset} disabled={busy}>Reset to defaults</button>
    <button class="ghost" onclick={() => Application.Quit()}><Icon name="power"/> Quit Lomi</button>
    <span class="spacer"></span>
    <button onclick={onclose}>Cancel</button>
    <button class="primary" onclick={save} disabled={busy}>Save</button>
  </footer>
</section>

<style>
  .settings {
    position: absolute;
    inset: 36px 0 29px 0;
    background: var(--bg);
    overflow-y: auto;
    padding: 4px 20px 16px;
    z-index: 5;
  }
  header, footer {
    display: flex;
    align-items: center;
    gap: 8px;
  }
  header {
    justify-content: space-between;
  }
  h2 {
    font-size: 1.05em;
    color: var(--model);
    margin: 0;
  }
  h3 {
    font-size: 0.78em;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--dim);
    margin: 0 0 6px;
    font-weight: 600;
  }
  .group {
    border-top: 1px solid var(--line);
    padding: 12px 0;
    display: flex;
    flex-direction: column;
    gap: 6px;
    align-items: flex-start;
  }
  .row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    width: 100%;
    max-width: 460px;
  }
  .check {
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .check.sub {
    margin-left: 24px;
  }
  .prices {
    border-collapse: collapse;
  }
  .prices th {
    text-align: left;
    font-weight: 400;
    color: var(--dim);
    font-size: 0.86em;
    padding: 0 6px 2px 0;
  }
  .prices td {
    padding: 2px 6px 2px 0;
  }
  .prices input[type="text"] {
    width: 16ch;
    max-width: none;
  }
  .prices input[type="number"] {
    width: 10ch;
  }
  .hint {
    color: var(--dim);
    margin: 0;
    max-width: 62ch;
    line-height: 1.5;
  }
  .on {
    color: var(--green);
  }
  .error {
    color: var(--red);
    margin: 8px 0;
  }
  code {
    color: var(--text);
    overflow-wrap: anywhere;
  }
  input[type="number"] {
    width: 13ch;
  }
  input[type="text"], select {
    width: 34ch;
    max-width: 62%;
  }
  footer {
    border-top: 1px solid var(--line);
    padding-top: 12px;
  }
  .spacer {
    flex: 1;
  }
</style>
