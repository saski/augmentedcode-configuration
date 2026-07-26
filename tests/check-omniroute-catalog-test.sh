#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$REPO_DIR/.agents/skills/free-agent-execution/scripts/check-omniroute-catalog"

_CLEANUP_DIRS=()
cleanup() {
    local directory
    for directory in ${_CLEANUP_DIRS[@]+"${_CLEANUP_DIRS[@]}"}; do
        rm -rf "$directory"
    done
}
trap cleanup EXIT

write_valid_manifest() {
    local manifest_path="$1"
    jq -n '
        {
            manifest_version: "1",
            frontier_role: "codex_principal",
            verified_free_models: ["omniroute/oc/deepseek-v4-flash-free", "omniroute/oc/big-pickle"],
            free_worker: {
                default_model: "omniroute/oc/deepseek-v4-flash-free",
                task_classes: {
                    bounded_code: {
                        sensitivity: "non_sensitive",
                        models: ["omniroute/oc/deepseek-v4-flash-free", "omniroute/oc/big-pickle"]
                    }
                }
            },
            privacy: {
                frontier_only_categories: ["credentials", "personal_data", "security_sensitive"]
            }
        }
    ' >"$manifest_path"
}

test_all_verified_models_present() {
    local fixture_dir
    fixture_dir=$(mktemp -d)
    _CLEANUP_DIRS+=("$fixture_dir")

    local fake_bin="$fixture_dir/bin"
    local manifest="$fixture_dir/routing-manifest.json"
    mkdir -p "$fake_bin"

    write_valid_manifest "$manifest"

    cat >"$fake_bin/curl" <<'FAKE_CURL'
#!/usr/bin/env bash
printf '%s\n' '{"object":"list","data":[{"id":"oc/deepseek-v4-flash-free","object":"model"},{"id":"oc/big-pickle","object":"model"}]}'
FAKE_CURL
    chmod +x "$fake_bin/curl"

    local output
    output=$(PATH="$fake_bin:$PATH" FREE_AGENT_ROUTING_MANIFEST="$manifest" "$SCRIPT" 2>&1) || {
        echo "expected success (exit 0) for all verified models present" >&2
        echo "output: $output" >&2
        exit 1
    }

    if [[ -n "$output" ]]; then
        echo "expected no output on success, got: $output" >&2
        exit 1
    fi
}

test_missing_verified_model() {
    local fixture_dir
    fixture_dir=$(mktemp -d)
    _CLEANUP_DIRS+=("$fixture_dir")

    local fake_bin="$fixture_dir/bin"
    local manifest="$fixture_dir/routing-manifest.json"
    mkdir -p "$fake_bin"

    write_valid_manifest "$manifest"

    cat >"$fake_bin/curl" <<'FAKE_CURL'
#!/usr/bin/env bash
printf '%s\n' '{"object":"list","data":[{"id":"oc/deepseek-v4-flash-free","object":"model"}]}'
FAKE_CURL
    chmod +x "$fake_bin/curl"

    local output
    output=$(PATH="$fake_bin:$PATH" FREE_AGENT_ROUTING_MANIFEST="$manifest" "$SCRIPT" 2>&1) && {
        echo "expected failure (exit non-zero) for missing verified model" >&2
        exit 1
    }

    if ! echo "$output" | grep -Fq "omniroute/oc/big-pickle"; then
        echo "expected error message to name the missing model (omniroute/oc/big-pickle)" >&2
        echo "output: $output" >&2
        exit 1
    fi
}

test_invalid_catalog_response() {
    local fixture_dir
    fixture_dir=$(mktemp -d)
    _CLEANUP_DIRS+=("$fixture_dir")

    local fake_bin="$fixture_dir/bin"
    local manifest="$fixture_dir/routing-manifest.json"
    mkdir -p "$fake_bin"

    write_valid_manifest "$manifest"

    cat >"$fake_bin/curl" <<'FAKE_CURL'
#!/usr/bin/env bash
printf '%s\n' 'not valid json'
FAKE_CURL
    chmod +x "$fake_bin/curl"

    local output
    output=$(PATH="$fake_bin:$PATH" FREE_AGENT_ROUTING_MANIFEST="$manifest" "$SCRIPT" 2>&1) && {
        echo "expected failure (exit non-zero) for invalid catalog response" >&2
        exit 1
    }

    if [[ -z "$output" ]]; then
        echo "expected error output for invalid catalog response" >&2
        exit 1
    fi
}

test_all_verified_models_present
test_missing_verified_model
test_invalid_catalog_response
