<script lang="ts">
  // Small inline SVG icons; they take the text colour and size.
  type Name = "bolt" | "clock" | "check" | "sliders" | "collapse" | "expand" | "heart" | "repo" | "branch" | "worktree" | "plus" | "trash" | "power";

  let {name, spin = false}: {name: Name; spin?: boolean} = $props();

  const paths: Record<Name, string> = {
    bolt: "M13 2 4 14h6l-1 8 9-12h-6z",
    clock: "M12 7v5l3 2",
    check: "M5 12.5l4.5 4.5L19 7.5",
    sliders: "M4 7h10M18 7h2M4 17h2M10 17h10M14 7a2 2 0 1 0 4 0 2 2 0 0 0-4 0zM6 17a2 2 0 1 0 4 0 2 2 0 0 0-4 0z",
    collapse: "M4 14h6v6M20 10h-6V4M14 10l7-7M3 21l7-7",
    expand: "M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7",
    heart: "M12 20.5S3.5 15 3.5 9.2A4.7 4.7 0 0 1 12 6.6a4.7 4.7 0 0 1 8.5 2.6c0 5.8-8.5 11.3-8.5 11.3z",
    repo: "M6 3h13v15H6a2 2 0 0 0 0 4h13M6 3a2 2 0 0 0-2 2v15M9 7h6",
    branch: "M7 8v8M7 8a2.2 2.2 0 1 0 0-4.4A2.2 2.2 0 0 0 7 8zM7 20.4A2.2 2.2 0 1 0 7 16a2.2 2.2 0 0 0 0 4.4zM17 10.4A2.2 2.2 0 1 0 17 6a2.2 2.2 0 0 0 0 4.4zM17 10.4c0 3.6-10 2-10 5.6",
    worktree: "M5 4v13a2 2 0 0 0 2 2h4M5 9h6M11 6.5h8v5h-8zM11 16.5h8v5h-8z",
    plus: "M12 5v14M5 12h14",
    trash: "M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13M10 11v6M14 11v6",
    power: "M12 3v9M6.3 6.8a8 8 0 1 0 11.4 0",
  };
</script>

<svg class="icon" class:spin viewBox="0 0 24 24" aria-hidden="true">
  {#if name === "clock"}<circle cx="12" cy="12" r="9"/>{/if}
  <path class:hand={name === "clock"} d={paths[name]} class:solid={name === "bolt" || name === "heart"}/>
</svg>

<style>
  .icon {
    width: 1.05em;
    height: 1.05em;
    vertical-align: -0.16em;
    fill: none;
    stroke: currentColor;
    stroke-width: 2;
    stroke-linecap: round;
    stroke-linejoin: round;
    flex: none;
  }
  .solid {
    fill: currentColor;
    stroke: none;
  }
  .spin .hand {
    transform-origin: 12px 12px;
    animation: turn 2s linear infinite;
  }
  @keyframes turn {
    to { transform: rotate(360deg); }
  }
  @media (prefers-reduced-motion: reduce) {
    .spin .hand {
      animation: none;
    }
  }
</style>
