#!/usr/bin/env bash
# Reads Claude Code's statusline JSON on stdin and prints a per-session focus
# badge. State is written by /focus-mode into ~/.claude/.focus-state/<session_id>.

input=$(cat)

sid=$(printf '%s' "$input" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]+"' | head -n1 | grep -oE '[0-9a-fA-F-]{36}')
mode=""
if [ -n "$sid" ] && [ -f "$HOME/.claude/.focus-state/$sid" ]; then
  mode=$(tr -d '\r\n[:space:]' < "$HOME/.claude/.focus-state/$sid")
fi

case "$mode" in
  design) badge=$'\033[1;36m🎨 FOCUS:DESIGN\033[0m' ;;
  coding) badge=$'\033[1;33m⚙ FOCUS:CODING\033[0m'  ;;
  *)      badge=$'\033[90m○ FOCUS:none\033[0m'      ;;
esac

printf '%s' "$badge"