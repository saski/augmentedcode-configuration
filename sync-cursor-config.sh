#!/bin/bash

# Sync Cursor Configuration
# Bidirectional sync between ~/.cursor/ and ~/saski/augmentedcode-configuration/.cursor/

set -e

REPO_DIR="$HOME/saski/augmentedcode-configuration"
GLOBAL_RULES="$HOME/.cursor/rules"
GLOBAL_COMMANDS="$HOME/.cursor/commands"
REPO_RULES="$REPO_DIR/.cursor/rules"
REPO_COMMANDS="$REPO_DIR/.cursor/commands"

usage() {
    echo "Usage: $0 [repo-to-global|global-to-repo|both]"
    echo ""
    echo "  repo-to-global  - Copy from repository to ~/.cursor/"
    echo "  global-to-repo   - Copy from ~/.cursor/ to repository"
    echo "  both            - Sync both directions (default)"
    echo ""
    exit 1
}

sync_repo_to_global() {
    echo "🔄 Syncing repository → global config..."
    
    if [ ! -d "$REPO_RULES" ]; then
        echo "❌ Repository rules directory not found: $REPO_RULES"
        return 1
    fi
    
    mkdir -p "$GLOBAL_RULES" "$GLOBAL_COMMANDS"
    
    echo "  Copying rules..."
    cp -r "$REPO_RULES"/* "$GLOBAL_RULES"/ 2>/dev/null || true
    
    if [ -d "$REPO_COMMANDS" ]; then
        echo "  Copying commands..."
        cp -r "$REPO_COMMANDS"/* "$GLOBAL_COMMANDS"/ 2>/dev/null || true
    fi
    
    echo "✅ Repository → global sync complete"
}

sync_global_to_repo() {
    echo "🔄 Syncing global config → repository..."
    
    if [ ! -d "$GLOBAL_RULES" ]; then
        echo "❌ Global rules directory not found: $GLOBAL_RULES"
        return 1
    fi
    
    mkdir -p "$REPO_RULES" "$REPO_COMMANDS"
    
    echo "  Copying rules..."
    cp -r "$GLOBAL_RULES"/* "$REPO_RULES"/ 2>/dev/null || true
    
    if [ -d "$GLOBAL_COMMANDS" ]; then
        echo "  Copying commands..."
        cp -r "$GLOBAL_COMMANDS"/* "$REPO_COMMANDS"/ 2>/dev/null || true
    fi
    
    echo "✅ Global → repository sync complete"
}

# Main
DIRECTION="${1:-both}"

case "$DIRECTION" in
    repo-to-global)
        sync_repo_to_global
        ;;
    global-to-repo)
        sync_global_to_repo
        ;;
    both)
        sync_repo_to_global
        echo ""
        sync_global_to_repo
        ;;
    *)
        usage
        ;;
esac

echo ""
echo "💡 Tip: After syncing, commit changes in the repository:"
echo "   cd $REPO_DIR && git add .cursor/ && git commit -m 'Sync cursor config' && git push"

