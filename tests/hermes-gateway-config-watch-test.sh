#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WATCHER="$REPO_DIR/hermes-gateway-config-watch.sh"
INSTALLER="$REPO_DIR/install-hermes-gateway-config-watch.sh"
PLIST_TEMPLATE="$REPO_DIR/templates/hermes/ai.hermes.gateway-config-watch.plist"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

HERMES_HOME="$TEST_DIR/hermes"
STATE_DIR="$TEST_DIR/state"
MOCK_BIN="$TEST_DIR/bin"
LAUNCHCTL_LOG="$TEST_DIR/launchctl.log"
mkdir -p "$HERMES_HOME" "$MOCK_BIN"

cat >"$MOCK_BIN/launchctl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$LAUNCHCTL_LOG"
if [[ "${1:-}" == "print" ]]; then
  exit 0
fi
EOF
chmod +x "$MOCK_BIN/launchctl"

cat >"$HERMES_HOME/config.yaml" <<'EOF'
model:
  default: oc/deepseek-v4-flash-free
provider: omniroute
EOF
printf '%s\n' 'WHATSAPP_ENABLED=false' >"$HERMES_HOME/.env"
cat >"$HERMES_HOME/auth.json" <<'EOF'
{
  "version": 1,
  "active_provider": "openai-codex",
  "providers": {
    "openai-codex": {
      "auth_mode": "oauth",
      "last_refresh": "2026-08-12T09:00:00Z",
      "tokens": {
        "access_token": "token-one",
        "refresh_token": "refresh-one",
        "account_id": "account-one"
      }
    }
  },
  "credential_pool": {
    "openai-codex": [
      {
        "id": "openai-codex:account-one",
        "label": "OpenAI Codex",
        "auth_type": "oauth",
        "source": "auth.json",
        "priority": 0,
        "access_token": "token-one",
        "refresh_token": "refresh-one",
        "request_count": 10
      }
    ]
  }
}
EOF

run_watcher() {
  env \
    PATH="$MOCK_BIN:$PATH" \
    LAUNCHCTL_LOG="$LAUNCHCTL_LOG" \
    HERMES_HOME="$HERMES_HOME" \
    HERMES_GATEWAY_CONFIG_WATCH_STATE_DIR="$STATE_DIR" \
    HERMES_GATEWAY_CONFIG_WATCH_DEBOUNCE_SECONDS=0 \
    "$WATCHER" "$@"
}

assert_kickstart_count() {
  local expected="$1"
  local actual=0
  if [[ -f "$LAUNCHCTL_LOG" ]]; then
    actual="$(grep -c '^kickstart -k gui/[0-9][0-9]*/ai.hermes.gateway$' "$LAUNCHCTL_LOG" || true)"
  fi
  if [[ "$actual" != "$expected" ]]; then
    printf 'expected %s gateway kickstarts, got %s\n' "$expected" "$actual" >&2
    cat "$LAUNCHCTL_LOG" >&2 2>/dev/null || true
    exit 1
  fi
}

for required_file in "$WATCHER" "$INSTALLER" "$PLIST_TEMPLATE"; do
  if [[ ! -f "$required_file" ]]; then
    printf 'missing required file: %s\n' "$required_file" >&2
    exit 1
  fi
done

run_watcher --prime
assert_kickstart_count 0

run_watcher
assert_kickstart_count 0

printf '%s\n' 'WHATSAPP_ENABLED=false' 'TELEGRAM_ENABLED=true' >"$HERMES_HOME/.env"
run_watcher
assert_kickstart_count 1

# OAuth token refreshes are volatile and must not interrupt Telegram.
ruby -rjson -e '
  path = ARGV.fetch(0)
  data = JSON.parse(File.read(path))
  provider = data.fetch("providers").fetch("openai-codex")
  provider["last_refresh"] = "2026-08-12T09:05:00Z"
  provider.fetch("tokens")["access_token"] = "token-two"
  pool = data.fetch("credential_pool").fetch("openai-codex").first
  pool["access_token"] = "token-two"
  pool["request_count"] = 11
  File.write(path, JSON.pretty_generate(data))
' "$HERMES_HOME/auth.json"
run_watcher
assert_kickstart_count 1

# Switching OAuth identity is a semantic change and must reload the gateway.
ruby -rjson -e '
  path = ARGV.fetch(0)
  data = JSON.parse(File.read(path))
  data.fetch("providers").fetch("openai-codex").fetch("tokens")["account_id"] = "account-two"
  data.fetch("credential_pool").fetch("openai-codex").first["id"] = "openai-codex:account-two"
  File.write(path, JSON.pretty_generate(data))
' "$HERMES_HOME/auth.json"
run_watcher
assert_kickstart_count 2

grep -q '<string>__HERMES_HOME__/config.yaml</string>' "$PLIST_TEMPLATE"
grep -q '<string>__HERMES_HOME__/.env</string>' "$PLIST_TEMPLATE"
grep -q '<string>__HERMES_HOME__/auth.json</string>' "$PLIST_TEMPLATE"

printf '%s\n' 'hermes gateway config watch tests passed'
