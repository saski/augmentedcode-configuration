#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SYNC="$REPO_DIR/sync-saski-repos.sh"

_CLEANUP_DIRS=()
_cleanup() {
    for d in ${_CLEANUP_DIRS[@]+"${_CLEANUP_DIRS[@]}"}; do rm -rf "$d"; done
}
trap _cleanup EXIT

assert_contains() {
    local haystack="$1"
    local needle="$2"

    if [[ "$haystack" != *"$needle"* ]]; then
        echo "expected output to contain: $needle" >&2
        echo "--- output ---" >&2
        echo "$haystack" >&2
        exit 1
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"

    if [[ "$haystack" == *"$needle"* ]]; then
        echo "expected output to NOT contain: $needle" >&2
        echo "--- output ---" >&2
        echo "$haystack" >&2
        exit 1
    fi
}

# Create a git repo whose HEAD cannot be resolved (unborn after deleting the
# local branch) but with a valid refs/remotes/<remote>/<branch> ref, so the
# sync logic reaches the local-HEAD rev-parse step.
make_broken_head_repo() {
    local repo="$1"
    local remote="$2"
    local branch="$3"

    mkdir -p "$repo"
    git -C "$repo" -c init.defaultBranch="$branch" init -q
    git -C "$repo" commit --allow-empty -q -m init
    git -C "$repo" update-ref "refs/remotes/$remote/$branch" HEAD
    git -C "$repo" update-ref -d "refs/heads/$branch"
}

test_reports_error_when_local_head_unresolvable() {
    local root manifest
    root="$(mktemp -d)"
    manifest="$(mktemp)"
    _CLEANUP_DIRS+=("$root" "$manifest")

    make_broken_head_repo "$root/myrepo" origin main
    printf 'myrepo\torigin\tmain\tmain\t-\n' > "$manifest"

    local output
    set +e
    output="$("$SYNC" --no-fetch --root "$root" --manifest "$manifest" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected sync to fail when local HEAD is unresolvable" >&2
        exit 1
    fi

    assert_contains "$output" "error"
    assert_contains "$output" "myrepo"
    assert_contains "$output" "failed to resolve local HEAD"
    assert_contains "$output" "failed=1"
}

test_rejects_unknown_option() {
    local output
    set +e
    output="$("$SYNC" --bogus 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected sync to reject unknown option" >&2
        exit 1
    fi

    assert_contains "$output" "unknown option"
}

test_reports_error_when_local_head_unresolvable
test_rejects_unknown_option
