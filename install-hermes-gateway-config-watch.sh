#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
WATCHER_SOURCE="$REPO_DIR/hermes-gateway-config-watch.sh"
PLIST_TEMPLATE="$REPO_DIR/templates/hermes/ai.hermes.gateway-config-watch.plist"
WATCHER_TARGET="$HERMES_HOME/bin/hermes-gateway-config-watch"
PLIST_TARGET="$HOME/Library/LaunchAgents/ai.hermes.gateway-config-watch.plist"
LAUNCHD_TARGET="gui/$(id -u)/ai.hermes.gateway-config-watch"

escape_sed_replacement() {
  printf '%s' "$1" | sed 's/[|&\\]/\\&/g'
}

for required_file in "$WATCHER_SOURCE" "$PLIST_TEMPLATE"; do
  if [[ ! -f "$required_file" ]]; then
    printf 'missing required file: %s\n' "$required_file" >&2
    exit 1
  fi
done

install -d "$HERMES_HOME/bin" "$HERMES_HOME/logs" "$HOME/Library/LaunchAgents"
install -m 0755 "$WATCHER_SOURCE" "$WATCHER_TARGET"

escaped_home="$(escape_sed_replacement "$HERMES_HOME")"
escaped_watcher="$(escape_sed_replacement "$WATCHER_TARGET")"
temporary_plist="$(mktemp "${TMPDIR:-/tmp}/ai.hermes.gateway-config-watch.XXXXXX.plist")"
trap 'rm -f "$temporary_plist"' EXIT
sed \
  -e "s|__HERMES_HOME__|$escaped_home|g" \
  -e "s|__WATCHER_PATH__|$escaped_watcher|g" \
  "$PLIST_TEMPLATE" >"$temporary_plist"
plutil -lint "$temporary_plist" >/dev/null
install -m 0644 "$temporary_plist" "$PLIST_TARGET"

HERMES_HOME="$HERMES_HOME" "$WATCHER_TARGET" --prime

if launchctl print "$LAUNCHD_TARGET" >/dev/null 2>&1; then
  launchctl bootout "$LAUNCHD_TARGET"
fi
launchctl bootstrap "gui/$(id -u)" "$PLIST_TARGET"
launchctl enable "$LAUNCHD_TARGET"

printf 'Installed %s\n' "$LAUNCHD_TARGET"
printf 'Watching %s, %s, and %s\n' \
  "$HERMES_HOME/config.yaml" "$HERMES_HOME/.env" "$HERMES_HOME/auth.json"
