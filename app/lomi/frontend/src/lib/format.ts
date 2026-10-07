// Formatters that match the Claude Code status line script.

export type Level = "ok" | "warn" | "danger" | "none";

// 98309 -> 98.3k, 1234567 -> 1.2M, 812 -> 812
export function fmtTokens(n: number): string {
  if (!Number.isFinite(n) || n < 0) n = 0;
  if (n >= 1_000_000) return `${Math.floor(n / 1_000_000)}.${Math.floor((n % 1_000_000) / 100_000)}M`;
  if (n >= 1_000) return `${Math.floor(n / 1_000)}.${Math.floor((n % 1_000) / 100)}k`;
  return String(Math.floor(n));
}

// seconds -> "2h 05m", "4m 33s" or "45s"
export function fmtDur(s: number): string {
  if (!Number.isFinite(s) || s < 0) s = 0;
  s = Math.floor(s);
  if (s >= 3600) return `${Math.floor(s / 3600)}h ${String(Math.floor((s % 3600) / 60)).padStart(2, "0")}m`;
  if (s >= 60) return `${Math.floor(s / 60)}m ${s % 60}s`;
  return `${s}s`;
}

export function fmtCost(n: number): string {
  return `$${n.toFixed(2)}`;
}

const time = new Intl.DateTimeFormat(undefined, { hour: "numeric", minute: "2-digit" });
const monthDay = new Intl.DateTimeFormat(undefined, { month: "short", day: "numeric" });
const weekdayShort = new Intl.DateTimeFormat(undefined, { weekday: "short" });
const weekdayLong = new Intl.DateTimeFormat(undefined, { weekday: "long" });

// epoch seconds -> "Oct 6 10:15 PM"
export function fmtDate(epoch: number): string {
  if (!epoch) return "";
  const d = new Date(epoch * 1000);
  return `${monthDay.format(d)} ${time.format(d)}`;
}

// epoch seconds -> "Wed 1:30 AM" when it is within a day, else "Sunday 5:00 PM"
export function fmtReset(epoch: number, nowMs: number): string {
  if (!epoch) return "";
  const d = new Date(epoch * 1000);
  const soon = epoch * 1000 - nowMs < 24 * 3600 * 1000;
  return `${(soon ? weekdayShort : weekdayLong).format(d)} ${time.format(d)}`;
}

// time left until an epoch: "2h 14m", "3d 4h" or "now"
export function fmtCountdown(epoch: number, nowMs: number): string {
  const s = Math.floor(epoch - nowMs / 1000);
  if (s <= 0) return "now";
  if (s >= 86400) return `${Math.floor(s / 86400)}d ${Math.floor((s % 86400) / 3600)}h`;
  if (s >= 3600) return `${Math.floor(s / 3600)}h ${Math.floor((s % 3600) / 60)}m`;
  if (s >= 60) return `${Math.floor(s / 60)}m`;
  return `${s}s`;
}

// time since an epoch: "12s ago", "4m ago", "3h ago"
export function fmtAgo(epoch: number, nowMs: number): string {
  const s = Math.max(0, Math.floor(nowMs / 1000 - epoch));
  if (s >= 3600) return `${Math.floor(s / 3600)}h ago`;
  if (s >= 60) return `${Math.floor(s / 60)}m ago`;
  return `${s}s ago`;
}

// Bar colour by used %: up to warnAt green, up to dangerAt yellow, above it red.
export function level(pct: number | null, warnAt: number, dangerAt: number): Level {
  if (pct === null) return "none";
  if (pct <= warnAt) return "ok";
  if (pct <= dangerAt) return "warn";
  return "danger";
}
