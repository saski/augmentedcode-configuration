#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALLER="$REPO_DIR/.agents/skills/openspec/scripts/install-openspec"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

assert_dir() {
    local path="$1"

    if [ ! -d "$path" ]; then
        fail "expected directory: $path"
    fi
}

assert_symlink_target() {
    local path="$1"
    local expected_target="$2"

    if [ ! -L "$path" ]; then
        fail "expected symlink: $path"
    fi

    local actual_target
    actual_target="$(readlink "$path")"
    if [ "$actual_target" != "$expected_target" ]; then
        fail "expected $path -> $expected_target, got $actual_target"
    fi
}

test_installs_under_docs_when_docs_exists() {
    local fixture_dir fake_bin log_path

    fixture_dir="$(mktemp -d)"
    fake_bin="$fixture_dir/bin"
    log_path="$fixture_dir/openspec.log"
    mkdir -p "$fixture_dir/repo/docs" "$fake_bin"

    cat > "$fake_bin/openspec" <<'FAKE_OPENSPEC'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >> "$OPENSPEC_TEST_LOG"
target="${@: -1}"
mkdir -p "$target/openspec/changes/archive" "$target/openspec/specs"
FAKE_OPENSPEC
    chmod +x "$fake_bin/openspec"

    OPENSPEC_BIN="$fake_bin/openspec" \
        OPENSPEC_TEST_LOG="$log_path" \
        "$INSTALLER" "$fixture_dir/repo"

    assert_dir "$fixture_dir/repo/docs/openspec/changes/archive"
    assert_dir "$fixture_dir/repo/docs/openspec/specs"
    assert_symlink_target "$fixture_dir/repo/openspec" "docs/openspec"

    if ! grep -Fq "init --tools none $fixture_dir/repo/docs" "$log_path"; then
        fail "expected OpenSpec init to target existing docs directory"
    fi
}

test_installs_under_thoughts_when_docs_is_missing() {
    local fixture_dir fake_bin log_path

    fixture_dir="$(mktemp -d)"
    fake_bin="$fixture_dir/bin"
    log_path="$fixture_dir/openspec.log"
    mkdir -p "$fixture_dir/repo/thoughts" "$fake_bin"

    cat > "$fake_bin/openspec" <<'FAKE_OPENSPEC'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >> "$OPENSPEC_TEST_LOG"
target="${@: -1}"
mkdir -p "$target/openspec/changes/archive" "$target/openspec/specs"
FAKE_OPENSPEC
    chmod +x "$fake_bin/openspec"

    OPENSPEC_BIN="$fake_bin/openspec" \
        OPENSPEC_TEST_LOG="$log_path" \
        "$INSTALLER" "$fixture_dir/repo"

    assert_dir "$fixture_dir/repo/thoughts/openspec/changes/archive"
    assert_dir "$fixture_dir/repo/thoughts/openspec/specs"
    assert_symlink_target "$fixture_dir/repo/openspec" "thoughts/openspec"

    if ! grep -Fq "init --tools none $fixture_dir/repo/thoughts" "$log_path"; then
        fail "expected OpenSpec init to target existing thoughts directory"
    fi
}

test_installs_under_docs_when_docs_exists
test_installs_under_thoughts_when_docs_is_missing

printf 'openspec install tests passed\n'
