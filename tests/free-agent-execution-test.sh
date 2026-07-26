#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ADAPTER="$REPO_DIR/.agents/skills/free-agent-execution/scripts/run-free-worker"
MANIFEST_VALIDATOR="$REPO_DIR/.agents/skills/free-agent-execution/scripts/validate-routing-manifest"

_CLEANUP_DIRS=()
cleanup() {
    local directory
    for directory in ${_CLEANUP_DIRS[@]+"${_CLEANUP_DIRS[@]}"}; do
        rm -rf "$directory"
    done
}
trap cleanup EXIT

assert_json_equals() {
    local json="$1"
    local filter="$2"
    local expected="$3"
    local actual

    actual="$(jq -c "$filter" <<<"$json")"
    if [[ "$actual" != "$expected" ]]; then
        echo "expected $filter to equal $expected, got $actual" >&2
        exit 1
    fi
}

write_valid_manifest() {
    local manifest_path="$1"
    local model="$2"

    jq -n --arg model "$model" '
        {
            manifest_version: "1",
            frontier_role: "codex_principal",
            verified_free_models: [$model],
            free_worker: {
                default_model: $model,
                task_classes: {
                    bounded_code: {
                        sensitivity: "non_sensitive",
                        models: [$model]
                    }
                }
            },
            privacy: {
                frontier_only_categories: ["credentials", "personal_data", "security_sensitive"]
            }
        }
    ' >"$manifest_path"
}

run_bounded_task_case() {
    local with_preexisting_changes="$1"
    local completion_mode="$2"
    local model="$3"
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$fixture_dir")

    local workspace="$fixture_dir/workspace"
    local fake_bin="$fixture_dir/bin"
    local contract="$fixture_dir/contract.json"
    local capture="$fixture_dir/opencode-invocation.txt"
    local manifest="$fixture_dir/routing-manifest.json"

    mkdir -p "$workspace" "$fake_bin"
    git -C "$workspace" init -q
    git -C "$workspace" config user.email "test@example.com"
    git -C "$workspace" config user.name "Test User"
    touch "$workspace/.gitkeep"
    printf '%s\n' "committed" >"$workspace/preexisting-tracked.txt"
    git -C "$workspace" add .gitkeep preexisting-tracked.txt
    git -C "$workspace" commit -qm "Initial fixture"

    if [[ "$with_preexisting_changes" == "yes" ]]; then
        printf '%s\n' "dirty before worker" >"$workspace/preexisting-tracked.txt"
        printf '%s\n' "untracked before worker" >"$workspace/preexisting-untracked.txt"
    fi

    cat >"$fake_bin/opencode" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >"$FAKE_CAPTURE"
printf '%s\n' "$OPENCODE_CONFIG_CONTENT" >>"$FAKE_CAPTURE"

workspace=""
while [[ $# -gt 0 ]]; do
    if [[ "$1" == "--dir" ]]; then
        workspace="$2"
        shift 2
        continue
    fi
    shift
done

printf '%s\n' "implemented" >"$workspace/result.txt"
if [[ "${FAKE_COMPLETION_MODE:-structured}" == "generic" ]]; then
    printf '%s\n' '{"type":"text","part":{"text":"Implemented bounded task"}}'
else
    printf '%s\n' '{"type":"text","part":{"text":"FREE_AGENT_RESULT: {\"status\":\"completed\",\"summary\":\"Implemented bounded task\"}"}}'
fi
printf '%s\n' '{"type":"step_finish","part":{"tokens":{"input":10,"output":20}}}'
EOF
    chmod +x "$fake_bin/opencode"

    write_valid_manifest "$manifest" "$model"

    jq -n \
        --arg workspace "$workspace" \
        --arg model "$model" \
        '{
            contract_version: "1",
            mode: "free",
            execution_role: "worker",
            parent_role: "frontier",
            parent_run_id: "run-123",
            delegation_depth: 1,
            task_id: "task-1.1",
            task_class: "bounded_code",
            sensitivity: "non_sensitive",
            working_directory: $workspace,
            requirement: "Create result.txt containing implemented.",
            allowed_files: ["result.txt"],
            validation: {
                command: ["grep", "-Fq", "implemented", "result.txt"]
            },
            model: $model,
            timeout_seconds: 30
        }' >"$contract"

    local result
    result="$(
        PATH="$fake_bin:$PATH" \
            FAKE_CAPTURE="$capture" \
            FAKE_COMPLETION_MODE="$completion_mode" \
            FREE_AGENT_ROUTING_MANIFEST="$manifest" \
            "$ADAPTER" "$contract"
    )"

    assert_json_equals "$result" '.model' "\"$model\""
    assert_json_equals "$result" '.changed_files' '["result.txt"]'
    assert_json_equals "$result" '.status' '"succeeded"'
    assert_json_equals "$result" '.validation.status' '"passed"'
    assert_json_equals "$result" '.usage.output_tokens' '20'

    grep -Fq -- "--pure" "$capture"
    grep -Fq -- "--agent free-worker" "$capture"
    if grep -Fq -- "--auto" "$capture"; then
        echo "expected adapter not to enable OpenCode auto-approval" >&2
        exit 1
    fi
    grep -Fq '"task":"deny"' "$capture"
    grep -Fq '"bash":"deny"' "$capture"
}

test_frontier_principal_delegates_one_bounded_task() {
    run_bounded_task_case "no" "structured" "omniroute/oc/deepseek-v4-flash-free"
}

test_changed_files_ignores_preexisting_git_changes() {
    run_bounded_task_case "yes" "structured" "omniroute/oc/deepseek-v4-flash-free"
}

test_worker_accepts_generic_completion_text() {
    run_bounded_task_case "no" "generic" "omniroute/oc/deepseek-v4-flash-free"
}

test_worker_uses_verified_model_from_routing_manifest() {
    run_bounded_task_case "no" "structured" "omniroute/oc/fixture-free"
}

assert_manifest_rejected() {
    local manifest="$1"

    if "$MANIFEST_VALIDATOR" "$manifest"; then
        echo "expected routing manifest to be rejected: $manifest" >&2
        exit 1
    fi
}

test_routing_manifest_rejects_unsafe_or_incomplete_policy() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$fixture_dir")

    local valid_manifest="$fixture_dir/valid.json"
    write_valid_manifest "$valid_manifest" "omniroute/oc/fixture-free"
    "$MANIFEST_VALIDATOR" "$valid_manifest"

    jq '
        .verified_free_models = ["openai/gpt-5.6-sol"]
        | .free_worker.default_model = "openai/gpt-5.6-sol"
        | .free_worker.task_classes.bounded_code.models = ["openai/gpt-5.6-sol"]
    ' "$valid_manifest" >"$fixture_dir/paid-model.json"
    assert_manifest_rejected "$fixture_dir/paid-model.json"

    jq '.free_worker.default_model = "omniroute/oc/unverified-free"' "$valid_manifest" >"$fixture_dir/unverified-default.json"
    assert_manifest_rejected "$fixture_dir/unverified-default.json"

    jq '.api_key = "sk-12345678901234567890"' "$valid_manifest" >"$fixture_dir/secret-like.json"
    assert_manifest_rejected "$fixture_dir/secret-like.json"

    jq 'del(.free_worker.task_classes)' "$valid_manifest" >"$fixture_dir/missing-task-policy.json"
    assert_manifest_rejected "$fixture_dir/missing-task-policy.json"
}

test_legacy_model_identifier_rejected() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$fixture_dir")

    local contract="$fixture_dir/contract.json"

    jq -n \
        '{
            contract_version: "1",
            mode: "free",
            execution_role: "worker",
            parent_role: "frontier",
            parent_run_id: "run-legacy-test",
            delegation_depth: 1,
            task_id: "task-legacy",
            task_class: "bounded_code",
            sensitivity: "non_sensitive",
            working_directory: "/tmp/unused",
            requirement: "Test legacy model rejection.",
            allowed_files: ["result.txt"],
            validation: {
                command: ["true"]
            },
            model: "oc/deepseek-v4-flash-free",
            timeout_seconds: 30
        }' >"$contract"

    local result
    result="$("$ADAPTER" "$contract")"

    assert_json_equals "$result" '.status' '"failed"'

    local diagnostic
    diagnostic="$(jq -r '.diagnostic // ""' <<<"$result")"
    if [[ -z "$diagnostic" ]]; then
        echo "expected non-empty diagnostic, got empty" >&2
        exit 1
    fi
}

test_frontier_principal_delegates_one_bounded_task
test_changed_files_ignores_preexisting_git_changes
test_worker_accepts_generic_completion_text
test_worker_uses_verified_model_from_routing_manifest
test_routing_manifest_rejects_unsafe_or_incomplete_policy
test_legacy_model_identifier_rejected
