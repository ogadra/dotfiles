#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

model=$(jq -r '.model.display_name // .model.id // ""' <<<"$input")
effort=$(jq -r '.model.effort_level // .model.reasoning_effort // .effort_level // .reasoning_effort // "high"' <<<"$input")
ctx_pct=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
rl_5h=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
rl_7d=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")

RESET=$'\033[0m'
MODEL_COLOR=$'\033[38;2;246;226;183m'
USAGE_COLOR=$'\033[38;2;242;181;144m'
LIMIT_COLOR=$'\033[38;2;233;144;169m'
META_COLOR=$'\033[38;2;148;153;174m'
SEPARATOR_COLOR=$'\033[2m'

colorize() {
  printf '%s%s%s' "$1" "$2" "$RESET"
}

# ccusage呼び出し結果のキャッシュ。
# 月次は重いので15分、当日は1分。stale-while-revalidate的に古い値があれば即返す。
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline"
mkdir -p "$cache_dir"

# 引数: <cache_file> <ttl_sec> <jq_filter> <ccusage args...>
get_cost() {
  local cache_file="$1" ttl="$2" filter="$3"
  shift 3
  local now mtime age
  now=$(date +%s)
  if [ -f "$cache_file" ]; then
    mtime=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0)
    age=$((now - mtime))
    if [ "$age" -lt "$ttl" ]; then
      jq -r "$filter" <"$cache_file" 2>/dev/null || echo ""
      return
    fi
  fi
  if json=$(ccusage "$@" --json 2>/dev/null); then
    printf '%s' "$json" >"$cache_file"
    jq -r "$filter" <<<"$json" 2>/dev/null || echo ""
  elif [ -f "$cache_file" ]; then
    jq -r "$filter" <"$cache_file" 2>/dev/null || echo ""
  fi
}

today=$(date +%Y%m%d)
month_prefix=$(date +%Y-%m)

today_cost=$(get_cost "$cache_dir/today.json" 60 \
  ".daily[0].totalCost // empty" \
  daily --since "$today" --until "$today" --offline)

month_cost=$(get_cost "$cache_dir/month.json" 900 \
  ".monthly[] | select(.period == \"$month_prefix\") | .totalCost" \
  monthly --offline)

parts=()

if [ -n "$ctx_pct" ]; then
  parts+=("$(colorize "$USAGE_COLOR" "$(printf 'Context %.0f%% used' "$ctx_pct")")")
fi

if [ -n "$rl_5h" ]; then
  parts+=("$(colorize "$LIMIT_COLOR" "$(printf '5h %.0f%% used' "$rl_5h")")")
fi
if [ -n "$rl_7d" ]; then
  parts+=("$(colorize "$LIMIT_COLOR" "$(printf 'weekly %.0f%% used' "$rl_7d")")")
fi

cost_parts=()
[ -n "$today_cost" ] && cost_parts+=("$(printf '$%.2f today' "$today_cost")")
[ -n "$month_cost" ] && cost_parts+=("$(printf '$%.2f month' "$month_cost")")
if [ ${#cost_parts[@]} -gt 0 ]; then
  cost_str=""
  for cp in "${cost_parts[@]}"; do
    if [ -z "$cost_str" ]; then cost_str="$cp"; else cost_str="$cost_str / $cp"; fi
  done
  parts+=("$(colorize "$META_COLOR" "$cost_str")")
fi

if [ -n "$model" ]; then
  if [ -n "$effort" ] && [[ " $model " != *" $effort "* ]]; then
    parts+=("$(colorize "$MODEL_COLOR" "$model $effort")")
  else
    parts+=("$(colorize "$MODEL_COLOR" "$model")")
  fi
fi

out=""
for p in "${parts[@]}"; do
  if [ -z "$out" ]; then out="$p"; else out="$out${SEPARATOR_COLOR} · ${RESET}$p"; fi
done
printf '%s' "$out"
