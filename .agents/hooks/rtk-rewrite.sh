#!/usr/bin/env bash
# rtk-hook-version: 3
# RTK shell rewrite hook with deterministic RTK binary resolution.
# Resolution order:
# 1) rtk from PATH
# 2) ~/.agents/bin/rtk
# 3) /opt/homebrew/bin/rtk
#
# Requires: jq and rtk >= 0.23.0

set -euo pipefail

find_rtk_binary() {
  if command -v rtk >/dev/null 2>&1; then
    command -v rtk
    return 0
  fi

  if [[ -x "$HOME/.agents/bin/rtk" ]]; then
    printf '%s\n' "$HOME/.agents/bin/rtk"
    return 0
  fi

  if [[ -x /opt/homebrew/bin/rtk ]]; then
    printf '%s\n' "/opt/homebrew/bin/rtk"
    return 0
  fi

  return 1
}

if ! command -v jq >/dev/null 2>&1; then
  echo "[rtk] WARNING: jq is not installed. Hook cannot rewrite commands. Install jq: https://jqlang.github.io/jq/download/" >&2
  exit 0
fi

RTK_BIN="$(find_rtk_binary || true)"
if [[ -z "$RTK_BIN" ]]; then
  echo "[rtk] WARNING: rtk is not available in PATH, ~/.agents/bin, or /opt/homebrew/bin. Hook cannot rewrite commands." >&2
  exit 0
fi

# Version guard: rtk rewrite was added in 0.23.0.
RTK_VERSION="$("$RTK_BIN" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
if [[ -n "$RTK_VERSION" ]]; then
  MAJOR="$(echo "$RTK_VERSION" | cut -d. -f1)"
  MINOR="$(echo "$RTK_VERSION" | cut -d. -f2)"
  if [[ "$MAJOR" -eq 0 && "$MINOR" -lt 23 ]]; then
    echo "[rtk] WARNING: rtk $RTK_VERSION is too old (need >= 0.23.0). Upgrade your installed RTK binary." >&2
    exit 0
  fi
fi

INPUT="$(cat)"
CMD="$(echo "$INPUT" | jq -r '.tool_input.command // empty')"
if [[ -z "$CMD" ]]; then
  exit 0
fi

# rtk rewrite exits 1 when there is no rewrite; pass through silently.
REWRITTEN="$("$RTK_BIN" rewrite "$CMD" 2>/dev/null)" || exit 0
if [[ "$CMD" == "$REWRITTEN" ]]; then
  exit 0
fi

ORIGINAL_INPUT="$(echo "$INPUT" | jq -c '.tool_input')"
UPDATED_INPUT="$(echo "$ORIGINAL_INPUT" | jq --arg cmd "$REWRITTEN" '.command = $cmd')"

jq -n \
  --argjson updated "$UPDATED_INPUT" \
  '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "allow",
      "permissionDecisionReason": "RTK auto-rewrite",
      "updatedInput": $updated
    }
  }'
