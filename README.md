# macOS Time Machine Health Check

Monitor Time Machine remote backups (NAS, external drives) and send health check signals to healthcheck.io. Automatically skips checks during active backups.

Perfect for getting notified when your Time Machine remote backups stop working - whether you're traveling, have network issues, or backup problems.

## Features

- ✅ Monitors Time Machine remote backup age (NAS, external drives)
- ✅ Sends success pings to healthcheck.io
- ✅ Skips checks during active backups
- ✅ Configurable via `tm-healthcheck.conf`
- ✅ Works anywhere you install it

## Quick Start

1. **Configure** your healthcheck.io URL in `tm-healthcheck.conf`
2. **Install** the launch agent:
   ```bash
   ./setup.sh install
   ```
3. **Check status**:
   ```bash
   ./setup.sh status
   ```

## Files

- `tm-monitor.sh` - Main monitoring script
- `setup.sh` - Install/uninstall/status management
- `tm-healthcheck.conf` - Configuration settings
- `README.md` - This file
- `LICENSE` - MIT License

## Configuration

Edit `tm-healthcheck.conf` to set your healthcheck.io URL:

```bash
SUCCESS_URL="https://hc-ping.com/YOUR-CHECK-ID/YOUR-CHECK-NAME"
```

## Commands

```bash
./setup.sh install    # Install launch agent
./setup.sh status     # Check status
./setup.sh config     # Show configuration
./setup.sh uninstall  # Remove launch agent
```

## How It Works

1. Checks if Time Machine is currently backing up
2. If not, finds the latest **remote backup** (NAS, external drives)
3. If backup is older than configured interval (default: 24h), sends failure ping
4. Otherwise, sends success ping to healthcheck.io
5. Records execution details in `lastrun` file

**Note:** Only monitors remote backups, not local snapshots. This ensures you're alerted about permanent backup failures, not temporary local storage issues.

healthcheck.io will alert you if the script doesn't run (backup issues, travel, etc.).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
