#!/bin/bash
# Backup existing ~/.cursor/ configuration before symlink migration

BACKUP_DIR="$HOME/.cursor-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_PATH="$BACKUP_DIR/cursor-backup-$TIMESTAMP"

echo "🗄️  Creating backup of ~/.cursor/..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Copy entire .cursor directory
cp -R ~/.cursor/ "$BACKUP_PATH"

# Verify backup
if [ -d "$BACKUP_PATH" ]; then
    SIZE=$(du -sh "$BACKUP_PATH" | cut -f1)
    echo "✅ Backup created: $BACKUP_PATH ($SIZE)"
    echo ""
    echo "📝 Backup retention: 7 days"
    echo "   To restore: cp -R $BACKUP_PATH ~/.cursor/"
    echo "   To clean old backups: find $BACKUP_DIR -type d -mtime +7 -exec rm -rf {} +"
else
    echo "❌ Backup failed"
    exit 1
fi
