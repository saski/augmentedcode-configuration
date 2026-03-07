#!/bin/bash
# Setup and Validate Symlinks for AI Tool Configuration
# Establishes ~/.cursor/, ~/.claude/, and other AI tool config as symlinks to this repo

set -e

REPO_DIR="$HOME/saski/augmentedcode-configuration"

# Dev/AI tools under ~ that get a direct "$HOME/$tool/skills" symlink.
# Cursor and Codex are handled separately due tool-specific directory layouts.
# Add or remove dot-dir names to cover any dev tool config (e.g. .copilot, .kiro).
TOOLS_WITH_SKILLS=".antigravity .claude .gemini .langflow"

usage() {
    cat << EOF
Usage: $(basename $0) [command]

Commands:
  setup     - Create all symlinks (first-time setup or repair)
  validate  - Verify all symlinks are correct
  status    - Show git status of config changes
  commit    - Stage, commit, and push config changes
  help      - Show this help message

Examples:
  $(basename $0) setup      # Initial setup on new machine
  $(basename $0) validate   # Check symlinks are intact
  $(basename $0) commit     # Commit and push config changes
EOF
    exit 1
}

# Verify we're in the right place
check_environment() {
    if [ ! -d "$REPO_DIR" ]; then
        echo "❌ Repository not found at $REPO_DIR"
        exit 1
    fi

    if [ ! -d "$REPO_DIR/.cursor" ]; then
        echo "❌ .cursor directory not found in repo"
        exit 1
    fi
}

# Create all symlinks
setup_symlinks() {
    echo "🔗 Setting up symlinks..."

    # Backup existing if not symlinks
    if [ -d ~/.cursor/rules ] && [ ! -L ~/.cursor/rules ]; then
        echo "⚠️  Found existing ~/.cursor/rules (not a symlink)"
        echo "   Create backup with: ./backup-cursor-config.sh"
        exit 1
    fi

    # Create .cursor symlinks (skills → canonical .agents/skills)
    mkdir -p ~/.cursor
    ln -sfn "$REPO_DIR/.cursor/rules" ~/.cursor/rules
    ln -sfn "$REPO_DIR/.cursor/commands" ~/.cursor/commands
    ln -sfn "$REPO_DIR/.agents/skills" ~/.cursor/skills
    ln -sfn "$REPO_DIR/.cursor/skills-cursor" ~/.cursor/skills-cursor
    ln -sfn "$REPO_DIR/.agents" ~/.cursor/.agents

    # Codex keeps local system skills under ~/.codex/skills/.system.
    # Link ~/.codex/skills/skills to canonical shared skills.
    mkdir -p "$HOME/.codex/skills"
    ln -sfn "$REPO_DIR/.agents/skills" "$HOME/.codex/skills/skills"

    # Other dev/AI tools: point skills at canonical .agents/skills
    for tool in $TOOLS_WITH_SKILLS; do
        mkdir -p "$HOME/$tool"
        ln -sfn "$REPO_DIR/.agents/skills" "$HOME/$tool/skills"
    done

    # Home-level .agents should always resolve to canonical repo .agents
    # so there is no divergent local skill source.
    if [ -d "$HOME/.agents" ] && [ ! -L "$HOME/.agents" ]; then
        echo "⚠️  Found existing ~/.agents directory (not a symlink)"
        echo "   Please move it to a backup location, then rerun setup."
        exit 1
    fi
    ln -sfn "$REPO_DIR/.agents" "$HOME/.agents"

    # Create .claude symlink
    ln -sfn "$REPO_DIR/.claude" ~/.claude

    # Create root-level config symlinks
    ln -sfn "$REPO_DIR/CLAUDE.md" ~/CLAUDE.md
    ln -sfn "$REPO_DIR/AGENTS.md" ~/AGENTS.md
    ln -sfn "$REPO_DIR/GEMINI.md" ~/GEMINI.md

    echo "✅ Symlinks created"
}

# Validate all symlinks
validate_symlinks() {
    echo "🔍 Validating symlinks..."

    local errors=0

    # Check .cursor symlinks
    for link in rules commands skills skills-cursor .agents; do
        local path="$HOME/.cursor/$link"
        if [ ! -L "$path" ]; then
            echo "❌ $path is not a symlink"
            errors=$((errors + 1))
        elif [ ! -e "$path" ]; then
            echo "❌ $path is a broken symlink"
            errors=$((errors + 1))
        else
            local target
            target=$(readlink "$path")
            if [ "$link" = "skills" ] && [[ "$target" != *".agents/skills" ]]; then
                echo "❌ $path should point to .agents/skills, got: $target"
                errors=$((errors + 1))
            else
                echo "✓ ~/.cursor/$link → $target"
            fi
        fi
    done

    # Check Codex skills symlink (nested path due ~/.codex/skills/.system)
    local codex_path="$HOME/.codex/skills/skills"
    if [ ! -L "$codex_path" ]; then
        echo "❌ $codex_path is not a symlink"
        errors=$((errors + 1))
    elif [ ! -e "$codex_path" ]; then
        echo "❌ $codex_path is a broken symlink"
        errors=$((errors + 1))
    else
        local codex_target
        codex_target=$(readlink "$codex_path")
        if [[ "$codex_target" != *".agents/skills" ]]; then
            echo "❌ $codex_path should point to .agents/skills, got: $codex_target"
            errors=$((errors + 1))
        else
            echo "✓ $codex_path → .agents/skills"
        fi
    fi

    # Check skills symlinks for other dev tools (must point to repo .agents/skills)
    for tool in $TOOLS_WITH_SKILLS; do
        local path="$HOME/$tool/skills"
        if [ ! -L "$path" ]; then
            echo "❌ $path is not a symlink"
            errors=$((errors + 1))
        elif [ ! -e "$path" ]; then
            echo "❌ $path is a broken symlink"
            errors=$((errors + 1))
        else
            local target
            target=$(readlink "$path")
            if [[ "$target" != *".agents/skills" ]]; then
                echo "❌ $path should point to .agents/skills, got: $target"
                errors=$((errors + 1))
            else
                echo "✓ $path → .agents/skills"
            fi
        fi
    done

    # Check .claude
    if [ ! -L ~/.claude ]; then
        echo "❌ ~/.claude is not a symlink"
        errors=$((errors + 1))
    else
        echo "✓ ~/.claude → $(readlink ~/.claude)"
    fi

    # Check ~/.agents canonical link
    if [ ! -L "$HOME/.agents" ]; then
        echo "❌ ~/.agents is not a symlink"
        errors=$((errors + 1))
    elif [ ! -e "$HOME/.agents" ]; then
        echo "❌ ~/.agents is a broken symlink"
        errors=$((errors + 1))
    else
        local agents_target
        agents_target=$(readlink "$HOME/.agents")
        if [[ "$agents_target" != *"augmentedcode-configuration/.agents" ]]; then
            echo "❌ ~/.agents should point to repo .agents, got: $agents_target"
            errors=$((errors + 1))
        else
            echo "✓ ~/.agents → $agents_target"
        fi
    fi

    # Check root configs
    for config in CLAUDE.md AGENTS.md GEMINI.md; do
        local path="$HOME/$config"
        if [ ! -L "$path" ]; then
            echo "❌ ~/$config is not a symlink"
            errors=$((errors + 1))
        else
            echo "✓ ~/$config → $(readlink $path)"
        fi
    done

    if [ $errors -eq 0 ]; then
        echo ""
        echo "✅ All symlinks valid"
        return 0
    else
        echo ""
        echo "❌ Found $errors symlink issues"
        return 1
    fi
}

# Show git status
show_status() {
    echo "📊 Configuration changes:"
    cd "$REPO_DIR"
    git status --short .cursor/ .agents/ *.md 2>/dev/null || true
}

# Commit and push changes
commit_changes() {
    cd "$REPO_DIR"

    if git diff --quiet .cursor/ .agents/ *.md 2>/dev/null; then
        echo "ℹ️  No config changes to commit"
        exit 0
    fi

    echo "📝 Changes to commit:"
    git status --short .cursor/ .agents/ *.md
    echo ""

    read -p "Commit message: " -r message

    if [ -z "$message" ]; then
        echo "❌ Commit message required"
        exit 1
    fi

    git add .cursor/ .agents/ *.md
    git commit -m "$message"

    read -p "Push to remote? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push
        echo "✅ Changes pushed"
    else
        echo "ℹ️  Changes committed locally (not pushed)"
    fi
}

# Main
check_environment

case "${1:-help}" in
    setup)
        setup_symlinks
        ;;
    validate)
        validate_symlinks
        ;;
    status)
        show_status
        ;;
    commit)
        commit_changes
        ;;
    help|*)
        usage
        ;;
esac
