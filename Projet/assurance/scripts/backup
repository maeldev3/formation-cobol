#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$PROJECT_DIR/backups"
DATA_DIR="$PROJECT_DIR/data"

mkdir -p "$BACKUP_DIR"

BACKUP_FILE="$BACKUP_DIR/assurance_backup_$(date +%Y%m%d_%H%M%S).tar.gz"

echo "Backup des données..."
tar -czf "$BACKUP_FILE" -C "$PROJECT_DIR" data/input/ 2>/dev/null

if [ -f "$BACKUP_FILE" ]; then
    echo "Backup créé: $BACKUP_FILE"
    # Supprimer les backups de plus de 30 jours
    find "$BACKUP_DIR" -name "assurance_backup_*.tar.gz" -mtime +30 -delete 2>/dev/null
else
    echo "Aucune donnée à backuper"
fi
