#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SYNC="$REPO_DIR/sync-skill-factory.sh"

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

# A typo'd --dry-run must be rejected, not silently executed as a real sync.
# Run with a non-existent SKILL_FACTORY so the script never touches real skills;
# the option rejection must happen before the output_skills existence check.
test_rejects_unknown_option() {
    local output
    set +e
    output="$(SKILL_FACTORY=/nonexistent "$SYNC" --dryrun 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected sync-skill-factory to reject unknown option" >&2
        exit 1
    fi

    assert_contains "$output" "unknown option"
}

test_accepts_dry_run_option() {
    local output
    set +e
    output="$(SKILL_FACTORY=/nonexistent "$SYNC" --dry-run 2>&1)"
    local exit_code=$?
    set -e

    assert_not_contains "$output" "unknown option"
}

test_rejects_unknown_option
test_accepts_dry_run_option
