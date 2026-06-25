#!/usr/bin/env bash
# Statusline wrapper: render ponytail's statusline, then append the per-session
# focus badge set by the /focus skill. Reads Claude Code's statusline JSON on stdin.
# The focus state lives in ~/.claude/.focus-state/<session_id> (one word: design|coding).

input=$(cat)

# --- ponytail segment (auto-follows whatever version is installed) ---
pony=""
pony_ps1=$(ls -d "$HOME"/.claude/plugins/cache/ponytail/ponytail/*/hooks/ponytail-statusline.ps1 2>/dev/null | sort -V | tail -n1)
if [ -n "$pony_ps1" ]; then
  pony=$(printf '%s' "$input" | powershell -NoProfile -ExecutionPolicy Bypass -File "$pony_ps1" 2>/dev/null | tr -d '\r')
fi

# --- focus segment (per-session state file) ---
sid=$(printf '%s' "$input" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]+"' | head -n1 | grep -oE '[0-9a-fA-F-]{36}')
mode=""
if [ -n "$sid" ] && [ -f "$HOME/.claude/.focus-state/$sid" ]; then
  mode=$(tr -d '\r\n[:space:]' < "$HOME/.claude/.focus-state/$sid")
fi

case "$mode" in
  design) badge=$'\033[1;36m\xF0\x9F\x8E\xA8 FOCUS:DESIGN\033[0m' ;;   # cyan
  coding) badge=$'\033[1;33m\xE2\x9A\x99 FOCUS:CODING\033[0m'  ;;      # yellow
  *)      badge=$'\033[90m\xE2\x97\x8B FOCUS:none\033[0m'      ;;      # dim
esac

if [ -n "$pony" ]; then
  printf '%s  %s' "$pony" "$badge"
else
  printf '%s' "$badge"
fi