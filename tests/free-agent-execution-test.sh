#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ADAPTER="$REPO_DIR/.agents/skills/free-agent-execution/scripts/run-free-worker"

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

run_bounded_task_case() {
    local with_preexisting_changes="$1"
    local completion_mode="$2"
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$fixture_dir")

    local workspace="$fixture_dir/workspace"
    local fake_bin="$fixture_dir/bin"
    local contract="$fixture_dir/contract.json"
    local capture="$fixture_dir/opencode-invocation.txt"

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

    jq -n \
        --arg workspace "$workspace" \
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
            model: "omniroute/oc/deepseek-v4-flash-free",
            timeout_seconds: 30
        }' >"$contract"

    local result
    result="$(
        PATH="$fake_bin:$PATH" \
            FAKE_CAPTURE="$capture" \
            FAKE_COMPLETION_MODE="$completion_mode" \
            "$ADAPTER" "$contract"
    )"

    assert_json_equals "$result" '.model' '"omniroute/oc/deepseek-v4-flash-free"'
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
    run_bounded_task_case "no" "structured"
}

test_changed_files_ignores_preexisting_git_changes() {
    run_bounded_task_case "yes" "structured"
}

test_worker_accepts_generic_completion_text() {
    run_bounded_task_case "no" "generic"
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
test_legacy_model_identifier_rejected
