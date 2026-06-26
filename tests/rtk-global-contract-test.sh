#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$REPO_DIR/.agents/hooks/rtk-rewrite.sh"
CLAUDE_HOOK="$REPO_DIR/.claude/hooks/rtk-rewrite.sh"
CODEX_HOOK_TEMPLATE="$REPO_DIR/templates/codex/hooks.json"

_CLEANUP_DIRS=()
_cleanup() {
    for d in ${_CLEANUP_DIRS[@]+"${_CLEANUP_DIRS[@]}"}; do rm -rf "$d"; done
}
trap _cleanup EXIT

assert_file_exists() {
    local path="$1"

    if [[ ! -e "$path" ]]; then
        echo "expected file to exist: $path" >&2
        exit 1
    fi
}

assert_symlink_target_contains() {
    local path="$1"
    local expected="$2"

    if [[ ! -L "$path" ]]; then
        echo "expected symlink: $path" >&2
        exit 1
    fi

    local target
    target="$(readlink "$path")"
    if [[ "$target" != *"$expected" ]]; then
        echo "expected symlink target for $path to contain '$expected', got '$target'" >&2
        exit 1
    fi
}

assert_file_contains() {
    local path="$1"
    local expected="$2"

    if ! grep -Fq "$expected" "$path"; then
        echo "expected $path to contain: $expected" >&2
        exit 1
    fi
}

assert_file_not_contains() {
    local path="$1"
    local unexpected="$2"

    if grep -Fq "$unexpected" "$path"; then
        echo "expected $path not to contain: $unexpected" >&2
        exit 1
    fi
}

create_fake_rtk() {
    local output="$1"
    local version="$2"
    local path="$3"

    cat > "$path" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "--version" ]]; then
  echo "REPLACE_VERSION"
  exit 0
fi
if [[ "${1:-}" == "rewrite" ]]; then
  shift
  printf '%s REPLACE_OUTPUT\n' "$1"
  exit 0
fi
exit 1
EOF

    # shellcheck disable=SC2016
    sed -i.bak "s/REPLACE_OUTPUT/$output/" "$path" && rm -f "$path.bak"
    # shellcheck disable=SC2016
    sed -i.bak "s/REPLACE_VERSION/$version/" "$path" && rm -f "$path.bak"
    chmod +x "$path"
}

test_canonical_layout_contract() {
    assert_file_exists "$HOOK"
    assert_symlink_target_contains "$CLAUDE_HOOK" ".agents/hooks/rtk-rewrite.sh"
    assert_file_exists "$CODEX_HOOK_TEMPLATE"
    assert_file_contains "$CODEX_HOOK_TEMPLATE" '$HOME/.codex/hooks/rtk-rewrite.sh'
    assert_file_contains "$REPO_DIR/setup-symlinks.sh" 'ln -sfn "$REPO_DIR/.agents/hooks/rtk-rewrite.sh" "$HOME/.codex/hooks/rtk-rewrite.sh"'
    assert_file_contains "$REPO_DIR/setup-symlinks.sh" 'install_template_file "$CODEX_HOOKS_TEMPLATE" "$HOME/.codex/hooks.json"'
    assert_file_not_contains "$REPO_DIR/.cursor/rules/cursor-config-management.mdc" "RTK.md"

    local live_codex_hook="$HOME/.codex/hooks/rtk-rewrite.sh"
    if [[ -e "$live_codex_hook" || -L "$live_codex_hook" ]]; then
        assert_symlink_target_contains "$live_codex_hook" ".agents/hooks/rtk-rewrite.sh"
    fi
}

test_agents_bin_policy_when_homebrew_rtk_exists() {
    if [[ ! -x /opt/homebrew/bin/rtk ]]; then
        return 0
    fi

    if ! grep -Fq 'mkdir -p "$HOME/.agents/bin"' "$REPO_DIR/setup-symlinks.sh"; then
        echo "expected setup-symlinks.sh to manage ~/.agents/bin" >&2
        exit 1
    fi
    if ! grep -Fq 'link_managed_binary "rtk"' "$REPO_DIR/setup-symlinks.sh"; then
        echo "expected setup-symlinks.sh to link ~/.agents/bin/rtk through the managed binary helper" >&2
        exit 1
    fi
    if ! grep -Fq '"/opt/homebrew/bin/rtk"' "$REPO_DIR/setup-symlinks.sh"; then
        echo "expected setup-symlinks.sh to include /opt/homebrew/bin/rtk as a managed binary candidate" >&2
        exit 1
    fi

    local agents_rtk="$HOME/.agents/bin/rtk"
    if [[ ! -L "$agents_rtk" ]]; then
        return 0
    fi

    local target
    target="$(readlink "$agents_rtk")"
    if [[ "$target" != "/opt/homebrew/bin/rtk" ]]; then
        echo "expected $agents_rtk to point to /opt/homebrew/bin/rtk, got $target" >&2
        exit 1
    fi
}

test_resolution_prefers_path_then_agents_home() {
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$tmp_dir")
    local home_dir="$tmp_dir/home"
    local path_bin="$tmp_dir/path-bin"
    mkdir -p "$home_dir/.agents/bin" "$path_bin"

    create_fake_rtk "from-path" "rtk 0.37.2" "$path_bin/rtk"
    create_fake_rtk "from-agents" "rtk 0.37.2" "$home_dir/.agents/bin/rtk"

    local input='{"tool_input":{"command":"echo hi"}}'
    local output
    output="$(env -i HOME="$home_dir" PATH="$path_bin:/usr/bin:/bin" bash "$HOOK" <<< "$input")"
    local rewritten
    rewritten="$(jq -r '.hookSpecificOutput.updatedInput.command // empty' <<< "$output")"
    if [[ "$rewritten" != "echo hi from-path" ]]; then
        echo "expected PATH rtk to win, got: $rewritten" >&2
        exit 1
    fi

    output="$(env -i HOME="$home_dir" PATH="/usr/bin:/bin" bash "$HOOK" <<< "$input")"
    rewritten="$(jq -r '.hookSpecificOutput.updatedInput.command // empty' <<< "$output")"
    if [[ "$rewritten" != "echo hi from-agents" ]]; then
        echo "expected ~/.agents/bin/rtk fallback, got: $rewritten" >&2
        exit 1
    fi
}

test_fail_open_when_rtk_too_old() {
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$tmp_dir")
    local home_dir="$tmp_dir/home"
    local path_bin="$tmp_dir/path-bin"
    mkdir -p "$home_dir" "$path_bin"

    create_fake_rtk "from-old" "rtk 0.22.0" "$path_bin/rtk"

    local input='{"tool_input":{"command":"echo hi"}}'
    local output
    local stderr_path="$tmp_dir/stderr.log"
    output="$(env -i HOME="$home_dir" PATH="$path_bin:/usr/bin:/bin" bash "$HOOK" <<< "$input" 2>"$stderr_path")"
    if [[ -n "$output" ]]; then
        echo "expected no rewrite output for old rtk binary, got: $output" >&2
        exit 1
    fi
    if ! grep -Fq "rtk 0.22.0 is too old" "$stderr_path"; then
        echo "expected old RTK warning in stderr" >&2
        exit 1
    fi
}

test_fail_open_when_rtk_version_command_fails() {
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$tmp_dir")
    local home_dir="$tmp_dir/home"
    local path_bin="$tmp_dir/path-bin"
    mkdir -p "$home_dir" "$path_bin"

    cat > "$path_bin/rtk" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "--version" ]]; then
  exit 1
fi
if [[ "${1:-}" == "rewrite" ]]; then
  shift
  printf '%s rewritten\n' "$1"
  exit 0
fi
exit 1
EOF
    chmod +x "$path_bin/rtk"

    local input='{"tool_input":{"command":"echo hi"}}'
    local output exit_code
    set +e
    output="$(env -i HOME="$home_dir" PATH="$path_bin:/usr/bin:/bin" bash "$HOOK" <<< "$input" 2>/dev/null)"
    exit_code=$?
    set -e

    if [[ $exit_code -ne 0 ]]; then
        echo "expected hook to fail-open (exit 0) when rtk --version exits non-zero, got exit $exit_code" >&2
        exit 1
    fi
    if [[ -n "$output" ]]; then
        echo "expected no rewrite output when rtk --version fails, got: $output" >&2
        exit 1
    fi
}

test_fail_open_when_stdin_malformed() {
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$tmp_dir")
    local home_dir="$tmp_dir/home"
    local path_bin="$tmp_dir/path-bin"
    mkdir -p "$home_dir" "$path_bin"

    create_fake_rtk "rewritten" "rtk 0.37.2" "$path_bin/rtk"

    local output exit_code
    set +e
    output="$(env -i HOME="$home_dir" PATH="$path_bin:/usr/bin:/bin" bash "$HOOK" <<< "not-json" 2>/dev/null)"
    exit_code=$?
    set -e

    if [[ $exit_code -ne 0 ]]; then
        echo "expected hook to fail-open (exit 0) on malformed stdin, got exit $exit_code" >&2
        exit 1
    fi
}

test_no_empty_command_when_rewrite_output_empty() {
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$tmp_dir")
    local home_dir="$tmp_dir/home"
    local path_bin="$tmp_dir/path-bin"
    mkdir -p "$home_dir" "$path_bin"

    cat > "$path_bin/rtk" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "--version" ]]; then
  echo "rtk 0.37.2"
  exit 0
fi
if [[ "${1:-}" == "rewrite" ]]; then
  exit 0
fi
exit 1
EOF
    chmod +x "$path_bin/rtk"

    local input='{"tool_input":{"command":"echo hi"}}'
    local output exit_code
    set +e
    output="$(env -i HOME="$home_dir" PATH="$path_bin:/usr/bin:/bin" bash "$HOOK" <<< "$input" 2>/dev/null)"
    exit_code=$?
    set -e

    if [[ $exit_code -ne 0 ]]; then
        echo "expected hook to exit 0 when rtk rewrite outputs empty, got exit $exit_code" >&2
        exit 1
    fi
    if [[ -n "$output" ]]; then
        echo "expected no output when rtk rewrite is empty, got: $output" >&2
        exit 1
    fi
}

test_canonical_layout_contract
test_agents_bin_policy_when_homebrew_rtk_exists
test_resolution_prefers_path_then_agents_home
test_fail_open_when_rtk_too_old
test_fail_open_when_rtk_version_command_fails
test_fail_open_when_stdin_malformed
test_no_empty_command_when_rewrite_output_empty
