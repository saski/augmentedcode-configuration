#!/usr/bin/env bash
set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
GATEWAY_LABEL="${HERMES_GATEWAY_LABEL:-ai.hermes.gateway}"
STATE_DIR="${HERMES_GATEWAY_CONFIG_WATCH_STATE_DIR:-$HERMES_HOME/run/gateway-config-watch}"
STATE_FILE="$STATE_DIR/fingerprint.sha256"
DEBOUNCE_SECONDS="${HERMES_GATEWAY_CONFIG_WATCH_DEBOUNCE_SECONDS:-2}"
LOG_FILE="${HERMES_GATEWAY_CONFIG_WATCH_LOG_FILE:-$HERMES_HOME/logs/gateway-config-watch.log}"

usage() {
  printf 'Usage: %s [--prime]\n' "${0##*/}"
}

log_message() {
  local message="$1"
  mkdir -p "$(dirname "$LOG_FILE")"
  printf '%s %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$message" >>"$LOG_FILE"
}

file_digest() {
  local path="$1"
  if [[ -f "$path" ]]; then
    shasum -a 256 "$path" | awk '{print $1}'
  else
    printf 'missing'
  fi
}

auth_semantic_digest() {
  local path="$HERMES_HOME/auth.json"
  if [[ ! -f "$path" ]]; then
    printf 'missing'
    return
  fi

  ruby -rjson -rdigest -e '
    data = JSON.parse(File.read(ARGV.fetch(0)))
    providers = (data["providers"] || {}).keys.sort.to_h do |name|
      provider = data["providers"][name]
      provider = {} unless provider.is_a?(Hash)
      tokens = provider["tokens"].is_a?(Hash) ? provider["tokens"] : {}
      [name, {
        "auth_mode" => provider["auth_mode"],
        "client_id" => provider["client_id"],
        "inference_base_url" => provider["inference_base_url"],
        "portal_base_url" => provider["portal_base_url"],
        "account_id" => tokens["account_id"]
      }.compact]
    end
    pools = (data["credential_pool"] || {}).keys.sort.to_h do |name|
      entries = Array(data["credential_pool"][name]).each_with_object([]) do |entry, stable_entries|
        next unless entry.is_a?(Hash)
        stable_entries << {
          "id" => entry["id"],
          "label" => entry["label"],
          "auth_type" => entry["auth_type"],
          "source" => entry["source"],
          "base_url" => entry["base_url"],
          "priority" => entry["priority"]
        }.compact
      end
      [name, entries.sort_by { |entry| entry.fetch("id", "") }]
    end
    stable = {
      "active_provider" => data["active_provider"],
      "providers" => providers,
      "credential_pool" => pools
    }
    print Digest::SHA256.hexdigest(JSON.generate(stable))
  ' "$path"
}

configuration_fingerprint() {
  {
    printf 'config=%s\n' "$(file_digest "$HERMES_HOME/config.yaml")"
    printf 'environment=%s\n' "$(file_digest "$HERMES_HOME/.env")"
    printf 'oauth=%s\n' "$(auth_semantic_digest)"
  } | shasum -a 256 | awk '{print $1}'
}

write_state() {
  local fingerprint="$1"
  local temporary_file
  mkdir -p "$STATE_DIR"
  temporary_file="$(mktemp "$STATE_FILE.XXXXXX")"
  printf '%s\n' "$fingerprint" >"$temporary_file"
  mv "$temporary_file" "$STATE_FILE"
}

prime=false
case "${1:-}" in
  '') ;;
  --prime) prime=true ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

if [[ "$prime" == false ]] && [[ "$DEBOUNCE_SECONDS" != 0 ]]; then
  sleep "$DEBOUNCE_SECONDS"
fi

current_fingerprint="$(configuration_fingerprint)"
previous_fingerprint=''
if [[ -f "$STATE_FILE" ]]; then
  previous_fingerprint="$(<"$STATE_FILE")"
fi

if [[ -z "$previous_fingerprint" ]] || [[ "$prime" == true ]]; then
  write_state "$current_fingerprint"
  log_message 'configuration fingerprint initialized; gateway unchanged'
  exit 0
fi

if [[ "$current_fingerprint" == "$previous_fingerprint" ]]; then
  exit 0
fi

# Persist before restarting so launchd coalescing or a watcher retrigger cannot
# create a restart loop for the same configuration state.
write_state "$current_fingerprint"

gateway_target="gui/$(id -u)/$GATEWAY_LABEL"
if ! launchctl print "$gateway_target" >/dev/null 2>&1; then
  log_message "configuration changed; $GATEWAY_LABEL is not loaded, so no restart was attempted"
  exit 0
fi

if launchctl kickstart -k "$gateway_target"; then
  log_message "configuration changed; restarted $GATEWAY_LABEL"
else
  log_message "configuration changed; failed to restart $GATEWAY_LABEL"
  exit 1
fi
