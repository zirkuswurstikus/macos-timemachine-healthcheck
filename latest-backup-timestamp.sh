#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# Override with command line argument if provided
if [ ! -z "$1" ]; then
    MAX_AGE_HOURS="$1"
fi

# Check if backup is currently running
BACKUP_RUNNING=$(tmutil status | grep "Running = 1" | wc -l)
if [ $BACKUP_RUNNING -gt 0 ]; then
    # Backup in progress, skip check
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$(date '+%Y-%m-%d %H:%M')|SKIPPED|Backup in progress" > "$SCRIPT_DIR/lastrun"
    exit 0
fi

LATEST_BACKUP=$(tmutil listbackups | tail -1)
BACKUP_NAME=$(basename "$LATEST_BACKUP")
TIMESTAMP=$(echo "$BACKUP_NAME" | sed 's/\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{6\}\).*/\1/')

BACKUP_DATE=$(echo "$TIMESTAMP" | cut -d'-' -f1-3)
BACKUP_EPOCH=$(date -j -f "%Y-%m-%d" "$BACKUP_DATE" "+%s")
CURRENT_EPOCH=$(date "+%s")
AGE_HOURS=$(((CURRENT_EPOCH - BACKUP_EPOCH) / 3600))

# Update lastrun file with current timestamp and backup info
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "$(date '+%Y-%m-%d %H:%M')|$BACKUP_NAME|$LATEST_BACKUP" > "$SCRIPT_DIR/lastrun"

# Only send success signal - let healthcheck.io handle timeout/fail logic
curl -fsS "$SUCCESS_URL"
