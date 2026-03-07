#!/bin/bash
# Sync skills from skill-factory into .agents/skills via symlinks.
# Adds symlinks only for skills not already present (no overwrite of native skills).
# Run after pulling skill-factory to make new skills available to all tools.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_FACTORY="${SKILL_FACTORY:-$REPO_DIR/../skill-factory}"
OUTPUT_SKILLS="$SKILL_FACTORY/output_skills"
CANONICAL_SKILLS="$REPO_DIR/.agents/skills"

usage() {
    cat << EOF
Usage: $(basename "$0") [--dry-run]

Syncs skill-factory's output_skills into this repo's .agents/skills/ by creating
relative symlinks for each skill that does not already exist (native skills like
xp-* are never overwritten). Run after pulling skill-factory to get new skills.

  SKILL_FACTORY  Default: \$REPO/../skill-factory (sibling directory)
  --dry-run      List what would be linked, do not create symlinks

Example:
  cd ~/saski/skill-factory && git pull
  cd ~/saski/augmentedcode-configuration && ./sync-skill-factory.sh
EOF
    exit 0
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
fi

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

if [[ ! -d "$OUTPUT_SKILLS" ]]; then
    echo "❌ skill-factory output_skills not found: $OUTPUT_SKILLS"
    echo "   Set SKILL_FACTORY to the skill-factory repo root, or clone it as a sibling."
    exit 1
fi

if [[ ! -d "$CANONICAL_SKILLS" ]]; then
    echo "❌ Canonical skills dir not found: $CANONICAL_SKILLS"
    exit 1
fi

added=0
skipped=0

while IFS= read -r -d '' skill_md; do
    skill_dir="$(dirname "$skill_md")"
    name="$(basename "$skill_dir")"
    target="$CANONICAL_SKILLS/$name"

    if [[ -e "$target" ]]; then
        ((skipped++)) || true
        if [[ "$DRY_RUN" == true ]]; then
            echo "  skip (exists) $name"
        fi
        continue
    fi

    rel_path="$(python3 -c "import os.path; print(os.path.relpath(r'$skill_dir', r'$CANONICAL_SKILLS'))")"
    if [[ "$DRY_RUN" == true ]]; then
        echo "  link $name -> $rel_path"
        ((added++)) || true
        continue
    fi

    ln -s "$rel_path" "$target"
    echo "  + $name -> $rel_path"
    ((added++)) || true
done < <(find "$OUTPUT_SKILLS" -name "SKILL.md" -type f -print0 2>/dev/null | sort -z)

if [[ "$DRY_RUN" == true ]]; then
    echo ""
    echo "Dry run: would add $added symlink(s), skip $skipped existing."
else
    echo ""
    echo "✅ Synced: $added new symlink(s), $skipped already present."
fi
