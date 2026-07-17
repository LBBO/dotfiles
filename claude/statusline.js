#!/usr/bin/env node

let input = "";
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  const data = JSON.parse(input);
  const model = data.model.display_name;
  const cost = data.cost?.total_cost_usd || 0;
  const windowSize = data.context_window?.context_window_size || 0;
  const inputTokens = data.context_window?.total_input_tokens ?? 0;
  const outputTokens = data.context_window?.total_output_tokens ?? 0;
  const usedTokens = inputTokens + outputTokens;
  const pct = windowSize
    ? Math.floor((usedTokens / windowSize) * 100)
    : Math.floor(data.context_window?.used_percentage || 0);

  const WHITE = "\x1b[37m",
    MAGENTA = "\x1b[35m",
    BLUE = "\x1b[34m",
    RED = "\x1b[31m",
    GREEN = "\x1b[32m",
    DIM = "\x1b[2m",
    BOLD = "\x1b[1m",
    RESET = "\x1b[0m";

  const BAR_WIDTH = 6;

  // Formats large numbers compactly, e.g. 60000 -> "60k", 1000000 -> "1.0M".
  const formatCompact = (n) => {
    if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
    if (n >= 1_000) return `${Math.round(n / 1_000)}k`;
    return `${n}`;
  };

  const makeBar = (percentage, color) => {
    const p = Math.min(100, Math.max(0, Math.floor(percentage)));
    const f = Math.round((p / 100) * BAR_WIDTH);
    return `${color}${"█".repeat(f)}${DIM}${"░".repeat(BAR_WIDTH - f)}${RESET}`;
  };

  // Compact reset countdown + absolute time, e.g. "↺2h30m@14:30" or
  // "↺1d3h@09:00 Mon" (weekday only shown when the reset is >=24h out), from
  // resets_at (unix seconds).
  const formatResetCompact = (resetsAt) => {
    if (!resetsAt) return "";
    const diffSec = Math.max(0, resetsAt - Date.now() / 1000);
    const days = Math.floor(diffSec / 86400);
    const hours = Math.floor((diffSec % 86400) / 3600);
    const minutes = Math.floor((diffSec % 3600) / 60);
    const countdown =
      days >= 1 ? `↺${days}d${hours}h` : hours >= 1 ? `↺${hours}h${minutes}m` : `↺${minutes}m`;

    const resetDate = new Date(resetsAt * 1000);
    const timeStr = resetDate.toLocaleTimeString([], {
      hour: "2-digit",
      minute: "2-digit",
      hour12: false,
    });
    const dayMarker =
      days >= 1 ? ` ${resetDate.toLocaleDateString([], { weekday: "short" })}` : "";

    return `${countdown}@${timeStr}${dayMarker}`;
  };

  const contextBar = makeBar(pct, WHITE);
  const contextInfo = `${formatCompact(usedTokens)}/${formatCompact(windowSize)} (${pct}%)`;

  const line1 = [];

  line1.push(`${BLUE}Model: ${model}${RESET}`);
  line1.push(`${WHITE}Context: ${contextBar} ${contextInfo}${RESET}`);
  line1.push(`${GREEN}Cost: $${cost.toFixed(2)}${RESET}`);

  const line2 = [];

  const fiveHour = data.rate_limits?.five_hour;
  const sevenDay = data.rate_limits?.seven_day;

  if (fiveHour) {
    const reset = formatResetCompact(fiveHour.resets_at);
    line2.push(
      `${MAGENTA}Daily ${makeBar(fiveHour.used_percentage, MAGENTA)} ${fiveHour.used_percentage.toFixed(1)}%${reset ? ` ${reset}` : ""}${RESET}`,
    );
  }
  if (sevenDay) {
    const reset = formatResetCompact(sevenDay.resets_at);
    line2.push(
      `${RED}Weekly ${makeBar(sevenDay.used_percentage, RED)} ${sevenDay.used_percentage.toFixed(1)}%${reset ? ` ${reset}` : ""}${RESET}`,
    );
  }

  const line1Content = line1.join(`${DIM} | ${RESET}`);
  const line2Content = line2.join(`${DIM} | ${RESET}`);

  console.log(line2Content ? `${line1Content}\n${line2Content}` : line1Content);
});

