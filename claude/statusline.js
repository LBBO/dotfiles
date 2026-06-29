#!/usr/bin/env node

let input = "";
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  const data = JSON.parse(input);
  const model = data.model.display_name;
  const cost = data.cost?.total_cost_usd || 0;
  const pct = Math.floor(data.context_window?.used_percentage || 0);
  const durationMs = data.cost?.total_duration_ms || 0;
  const windowSize = data.context_window?.context_window_size || 0;
  const inputTokens = data.context_window?.total_input_tokens ?? 0;
  const outputTokens = data.context_window?.total_output_tokens ?? 0;
  const usedTokens = inputTokens + outputTokens;

  const CYAN = "\x1b[36m",
    GREEN = "\x1b[32m",
    YELLOW = "\x1b[33m",
    RED = "\x1b[31m",
    DIM = "\x1b[2m",
    RESET = "\x1b[0m";

  const barColor = pct >= 90 ? RED : pct >= 70 ? YELLOW : GREEN;
  const filled = Math.floor(pct / 10);
  const bar = "█".repeat(filled) + "░".repeat(10 - filled);

  const mins = Math.floor(durationMs / 60000);
  const secs = Math.floor((durationMs % 60000) / 1000);

  const tokenInfo = `${DIM}${usedTokens.toLocaleString()}/${windowSize.toLocaleString()}${RESET}`;

  console.log(
    `${CYAN}[${model}]${RESET} ${tokenInfo} ${barColor}${bar}${RESET} | ${YELLOW}$${cost.toFixed(2)}${RESET} | ⏱️ ${mins}m ${secs}s`,
  );
});

