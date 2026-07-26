#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SETUP_SCRIPT="$REPO_DIR/setup-symlinks.sh"
BASE_RULES="$REPO_DIR/.agents/rules/base.md"

# --- wiring declaration: setup-symlinks.sh installs base.md as ~/.codex/AGENTS.md ---

test_setup_declares_codex_wiring() {
    if ! grep -q '\.agents/rules/base\.md.*\.codex/AGENTS\.md' "$SETUP_SCRIPT"; then
        echo "FAIL: setup-symlinks.sh must declare base.md → \$HOME/.codex/AGENTS.md" >&2
        exit 1
    fi
    echo "PASS: setup-symlinks.sh declares base.md → \$HOME/.codex/AGENTS.md"
}

# --- routing pointer: base.md must contain exactly this durable public rules contract ---

EXPECTED_FREE_AGENT_LINE="- When the user explicitly requests a bounded, non-sensitive free worker, the agent loads and follows the free-agent-execution skill; the frontier agent retains scope preparation and final review."

test_base_rules_routes_free_worker_to_skill() {
    if grep -Fqx -- "$EXPECTED_FREE_AGENT_LINE" "$BASE_RULES"; then
        echo "PASS: base.md contains the free-agent routing pointer"
    else
        echo "FAIL: base.md must contain this exact line:" >&2
        echo "  $EXPECTED_FREE_AGENT_LINE" >&2
        exit 1
    fi
}

test_setup_declares_codex_wiring
test_base_rules_routes_free_worker_to_skill
