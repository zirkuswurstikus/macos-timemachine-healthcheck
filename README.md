# Time Machine Health Check

## Purpose

Monitors Time Machine backup age and sends health check signals to ensure backups are recent. The script only sends success signals and lets healthcheck.io handle timeout detection for more reliable monitoring.

## Features

- ✅ **Configurable** via `config.conf` file
- ✅ **Dynamic script path resolution** - works anywhere you install it
- ✅ **Backup progress detection** - skips checks during active backups
- ✅ **Execution tracking** - `lastrun` file with detailed information
- ✅ **Easy customization** - URLs and timing settings
- ✅ **Success-only pings** - no false alarms during travel/backups

## Files

- `latest-backup-timestamp.sh` - Main script (loads config)
- `setup.sh` - Install/uninstall/status/config management
- `config.conf` - Configuration file
- `README.md` - This file

## Configuration (`config.conf`)

### MANDATORY SETTINGS
- `SUCCESS_URL` - Health check success endpoint

### OPTIONAL SETTINGS
- `MAX_AGE_HOURS` - Maximum backup age in hours (default: 72)
- `AGENT_LABEL` - Launch agent identifier
- `AGENT_NAME` - Display name
- `INITIAL_DELAY` - Minutes to wait after login (default: 5)
- `INTERVAL_MINUTES` - Minutes between checks (default: 60)

## Usage

### Setup Commands
```bash
./setup.sh install    # Install launch agent
./setup.sh status     # Check status and configuration
./setup.sh config     # Show current configuration
./setup.sh uninstall  # Remove launch agent
```

### Manual Execution
```bash
./latest-backup-timestamp.sh [max_age_hours]
```

## Default Settings

- **Max age**: 72 hours
- **Schedule**: 5 minutes after login, then every 60 minutes
- **Endpoint**: `https://hc-ping.com/YwnSXEIGX-YS1zQEh5N7oA/littleblue_tm`

## How It Works

1. **Checks for active backups** - Skips if Time Machine is currently backing up
2. **Finds latest backup** - Uses `tmutil listbackups` to get most recent backup
3. **Sends success ping** - Only sends success signals to healthcheck.io
4. **Tracks execution** - Records timestamp and backup info in `lastrun` file
5. **Timeout detection** - healthcheck.io alerts if script doesn't run (travel/backup issues)

## Status Output

The `./setup.sh status` command shows:
- Agent running status
- Current configuration
- Last execution details (timestamp, backup checked, location)
- Launch agent information (plist location, modification time)
