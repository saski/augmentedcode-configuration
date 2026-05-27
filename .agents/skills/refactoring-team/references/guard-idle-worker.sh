#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
TEAMMATE_NAME=$(echo "$INPUT" | jq -r '.teammate_name')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')

case "$TEAMMATE_NAME" in
    worker-*) ;;
    *) exit 0 ;;
esac

if tail -c 5000 "$TRANSCRIPT_PATH" | grep -q '"SendMessage"'; then
    exit 0
fi

echo "Use SendMessage to notify your reviewer before going idle." >&2
exit 2
