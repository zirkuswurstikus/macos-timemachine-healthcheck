#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

PLIST_FILE="$AGENT_LABEL.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

case "$1" in
    install)
        echo "Installing $AGENT_NAME..."
        
        # Generate plist with current directory and config values
        cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$AGENT_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT_DIR/latest-backup-timestamp.sh</string>
        <string>$MAX_AGE_HOURS</string>
    </array>
    <key>StartInterval</key>
    <integer>$((INTERVAL_MINUTES * 60))</integer>
    <key>RunAtLoad</key>
    <false/>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Minute</key>
        <integer>$INITIAL_DELAY</integer>
    </dict>
</dict>
</plist>
EOF
        
        cp "$PLIST_FILE" "$LAUNCH_AGENTS_DIR/"
        launchctl load "$LAUNCH_AGENTS_DIR/$PLIST_FILE"
        echo "Installed! The script will run $INITIAL_DELAY minutes after login and then every $INTERVAL_MINUTES minutes."
        ;;
    uninstall)
        echo "Uninstalling $AGENT_NAME..."
        launchctl unload "$LAUNCH_AGENTS_DIR/$PLIST_FILE" 2>/dev/null
        rm -f "$LAUNCH_AGENTS_DIR/$PLIST_FILE"
        rm -f "$PLIST_FILE"
        echo "Uninstalled!"
        ;;
    status)
        echo "=== Status ==="
        if launchctl list | grep -q "$AGENT_LABEL"; then
            echo "Status: $AGENT_NAME is running"
        else
            echo "Status: $AGENT_NAME is not running"
        fi
        
        echo ""
        echo "=== Configuration ==="
        echo "Max age: $MAX_AGE_HOURS hours"
        echo "Success URL: $SUCCESS_URL"
        echo "Initial delay: $INITIAL_DELAY minutes"
        echo "Interval: $INTERVAL_MINUTES minutes"
        
        if [ -f "$SCRIPT_DIR/lastrun" ]; then
            echo ""
            echo "=== Last Run ==="
            LAST_RUN_DATA=$(cat "$SCRIPT_DIR/lastrun")
            if [[ "$LAST_RUN_DATA" == *"|"* ]]; then
                # New format with backup info
                IFS='|' read -r TIMESTAMP BACKUP_NAME BACKUP_PATH <<< "$LAST_RUN_DATA"
                echo "Last execution: $TIMESTAMP"
                if [ "$BACKUP_NAME" = "SKIPPED" ]; then
                    echo "Status: $BACKUP_PATH"
                else
                    echo "Backup checked: $BACKUP_NAME"
                    echo "Backup location: $BACKUP_PATH"
                fi
            else
                # Old format, just timestamp
                echo "Last execution: $LAST_RUN_DATA"
            fi
        fi
        
        echo ""
        echo "=== Launch Agent Info ==="
        if launchctl list | grep -q "$AGENT_LABEL"; then
            echo "Agent: Loaded and active"
            echo "Plist: $LAUNCH_AGENTS_DIR/$PLIST_FILE"
            if [ -f "$LAUNCH_AGENTS_DIR/$PLIST_FILE" ]; then
                echo "Plist exists: Yes"
                PLIST_MODIFIED=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$LAUNCH_AGENTS_DIR/$PLIST_FILE")
                echo "Plist modified: $PLIST_MODIFIED"
            else
                echo "Plist exists: No"
            fi
            
            # Check when agent was last triggered
            echo ""
            echo "Last launchd execution:"
            if [ -f "$SCRIPT_DIR/lastrun" ]; then
                LAST_RUN_DATA=$(cat "$SCRIPT_DIR/lastrun")
                if [[ "$LAST_RUN_DATA" == *"|"* ]]; then
                    # New format with backup info
                    IFS='|' read -r TIMESTAMP BACKUP_NAME BACKUP_PATH <<< "$LAST_RUN_DATA"
                    echo "Based on lastrun file: $TIMESTAMP"
                else
                    # Old format, just timestamp
                    echo "Based on lastrun file: $LAST_RUN_DATA"
                fi
            else
                echo "No execution record found"
            fi
        else
            echo "Agent: Not loaded"
        fi
        ;;
    config)
        echo "Current configuration:"
        echo "  Max age: $MAX_AGE_HOURS hours"
        echo "  Success URL: $SUCCESS_URL"
        echo "  Initial delay: $INITIAL_DELAY minutes"
        echo "  Interval: $INTERVAL_MINUTES minutes"
        ;;
    *)
        echo "Usage: $0 {install|uninstall|status|config}"
        echo "  install   - Install the launch agent"
        echo "  uninstall - Remove the launch agent"
        echo "  status    - Check if the agent is running"
        echo "  config    - Show current configuration"
        ;;
esac
