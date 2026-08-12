#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO_DIR/.agents/skills"
SKILL_INDEX="$REPO_DIR/.agents/docs/skill-factory-skills.md"

assert_skill_reference() {
    local skill_name="$1"
    local expected_target="$2"
    local skill_path="$SKILLS_DIR/$skill_name"

    if [[ ! -L "$skill_path" ]]; then
        echo "$skill_name should be a symlink under .agents/skills" >&2
        exit 1
    fi

    local actual_target
    actual_target="$(readlink "$skill_path")"
    if [[ "$actual_target" != "$expected_target" ]]; then
        echo "$skill_name should point to $expected_target, got: $actual_target" >&2
        exit 1
    fi

    if [[ ! -f "$skill_path/SKILL.md" ]]; then
        echo "$skill_name should expose SKILL.md through the symlink" >&2
        exit 1
    fi
}

assert_skill_index_reference() {
    local skill_name="$1"

    if ! grep -Fq "| $skill_name |" "$SKILL_INDEX"; then
        echo "skill index should reference $skill_name" >&2
        exit 1
    fi
}

assert_skill_reference "complexity-review" "../../../augmented-lean-delivery/complexity-review"
assert_skill_reference "hamburger-method" "../../../augmented-lean-delivery/hamburger-method"
assert_skill_reference "micro-steps-coach" "../../../augmented-lean-delivery/micro-steps-coach"
assert_skill_reference "story-splitting" "../../../augmented-lean-delivery/story-splitting"
assert_skill_reference "mutation-testing-js" "../../../augmentedcode-skills/mutation-testing-js"
assert_skill_reference "mutation-testing-python" "../../../augmentedcode-skills/mutation-testing-python"
assert_skill_reference "test-desiderata" "../../../augmentedcode-skills/test-desiderata"

assert_skill_index_reference "complexity-review"
assert_skill_index_reference "hamburger-method"
assert_skill_index_reference "micro-steps-coach"
assert_skill_index_reference "story-splitting"

echo "external skill references contract passed"
