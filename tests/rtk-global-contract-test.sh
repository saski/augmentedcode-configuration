#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$REPO_DIR/.agents/hooks/rtk-rewrite.sh"
CLAUDE_HOOK="$REPO_DIR/.claude/hooks/rtk-rewrite.sh"

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
    sed -i '' "s/REPLACE_OUTPUT/$output/" "$path"
    # shellcheck disable=SC2016
    sed -i '' "s/REPLACE_VERSION/$version/" "$path"
    chmod +x "$path"
}

test_canonical_layout_contract() {
    assert_file_exists "$HOOK"
    assert_symlink_target_contains "$CLAUDE_HOOK" ".agents/hooks/rtk-rewrite.sh"
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

test_canonical_layout_contract
test_agents_bin_policy_when_homebrew_rtk_exists
test_resolution_prefers_path_then_agents_home
test_fail_open_when_rtk_too_old
