#!/bin/bash
# Pull latest skill-factory repo, then run sync-skill-factory.sh.
# Usage: ./pull-and-sync-skills.sh [sync args...]
# Example: ./pull-and-sync-skills.sh --dry-run
# Respects SKILL_FACTORY (default: ../skill-factory from repo root).

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_FACTORY="${SKILL_FACTORY:-$REPO_DIR/../skill-factory}"

if [[ ! -d "$SKILL_FACTORY/.git" ]]; then
  echo "❌ Not a git repo: $SKILL_FACTORY"
  exit 1
fi
if [[ ! -d "$SKILL_FACTORY/output_skills" ]]; then
  echo "❌ output_skills not found: $SKILL_FACTORY/output_skills"
  exit 1
fi

echo "📥 Pulling skill-factory..."
(cd "$SKILL_FACTORY" && git pull)
echo ""
echo "🔗 Syncing skills..."
cd "$REPO_DIR"
exec ./sync-skill-factory.sh "$@"
