# Vaultwarden Backup Monitoring Dashboard

## Overview

Comprehensive monitoring solution for Vaultwarden backups with health scoring, alerts, and detailed status reporting.

## Installation

### Quick Setup

```zsh
# Copy monitor script to bin
cp ~/work/docs/scripts/vaultwarden-backup-monitor.zsh ~/bin/
chmod +x ~/bin/vaultwarden-backup-monitor.zsh

# Create convenient alias
echo 'alias vw-monitor="~/bin/vaultwarden-backup-monitor.zsh"' >> ~/.zshrc
source ~/.zshrc

# Test it
vw-monitor
```

## Usage

### Basic Status Check

```zsh
vw-monitor
```

**Output example:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔐 Vaultwarden Backup System Monitor
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

2025-10-06 15:45:32
Host: MacBook-Pro

▌ Backup Directory Status
────────────────────────────────────────
✅ Directory exists: /Users/username/Documents/vaultwarden-backups
✅ Permissions: Read/Write ✓
ℹ️  Disk space: 245Gi available (45% used)
✅ Git repository: Yes

▌ Backup Files
────────────────────────────────────────
ℹ️  Total backups: 42

Latest backup:
  File: vault-20251006-144500.json
  Size: 24K
  Age:  1h 15m ago
  ✅ Status: FRESH
  ✅ Encryption: Yes

Recent backups:
  vault-20251006-144500.json - 24K - Oct  6 14:45
  vault-20251006-124500.json - 24K - Oct  6 12:45
  vault-20251006-104500.json - 23K - Oct  6 10:45
  vault-20251006-084500.json - 23K - Oct  6 08:45
  vault-20251006-064500.json - 23K - Oct  6 06:45

▌ Health Score
────────────────────────────────────────

╔════════════════════════════════╗
║  HEALTH SCORE: 95/100          ║
║  STATUS: EXCELLENT             ║
╚════════════════════════════════╝

No issues detected! 🎉

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ Monitor Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Full Detailed Report

```zsh
vw-monitor --full
```

Includes:
- ✅ Backup directory status
- ✅ Backup file analysis
- ✅ Git repository status
- ✅ Keychain credentials check
- ✅ Bitwarden CLI status
- ✅ LaunchAgent status
- ✅ Recent logs review
- ✅ Health score

### Statistics Report

```zsh
vw-monitor --stats
```

Shows:
- Total number of backups
- Total storage used
- Average backup size
- Backups per day (last 7 days)
- Git repository statistics

### Combined Report

```zsh
vw-monitor --full --stats
```

## Health Scoring System

The monitor calculates a health score out of 100 based on:

| Check | Points | Deduction If |
|-------|--------|--------------|
| Backup freshness | 30 | Backup > 6 hours old |
| Backup exists | 40 | No backups found |
| Master password | 15 | Not in Keychain |
| Backup password | 15 | Not in Keychain |
| Git sync | 10 | Not a git repo |
| Unpushed commits | 5 | > 5 unpushed commits |
| LaunchAgent | 20 | Not loaded |

### Score Ranges

- **90-100**: 🟢 EXCELLENT - Everything optimal
- **70-89**: 🔵 GOOD - Minor issues
- **50-69**: 🟡 WARNING - Needs attention
- **0-49**: 🔴 CRITICAL - Immediate action required

## Automated Monitoring

### Daily Health Check Email

Create a script to email daily reports:

```zsh
#!/usr/bin/env zsh
# Save as: ~/bin/vaultwarden-monitor-email.zsh

RECIPIENT="your-email@example.com"
OUTPUT=$( ~/bin/vaultwarden-backup-monitor.zsh --full --stats 2>&1 )

# Send email via mail command (requires mail setup)
echo "$OUTPUT" | mail -s "Vaultwarden Backup Health Report - $(date +%Y-%m-%d)" "$RECIPIENT"

# Or use SMTP directly
# echo "$OUTPUT" | sendmail "$RECIPIENT"
```

Schedule with cron:

```zsh
# Add to crontab (crontab -e)
0 9 * * * ~/bin/vaultwarden-monitor-email.zsh
```

### Slack/Discord Notifications

```zsh
#!/usr/bin/env zsh
# Send to Slack webhook

WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
OUTPUT=$(~/bin/vaultwarden-backup-monitor.zsh --full)

curl -X POST "$WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d "{\"text\":\"$(echo $OUTPUT | sed 's/"/\\"/g')\"}"
```

### Telegram Notifications (Integrated)

The monitor can send alerts via Telegram:

```zsh
# Add to monitor script or create wrapper
# Sends alert if health score < 70

HEALTH_SCORE=$(vw-monitor | grep "HEALTH SCORE" | awk '{print $3}' | cut -d'/' -f1)

if (( HEALTH_SCORE < 70 )); then
    # Send telegram alert
    TELEGRAM_TOKEN=$(security find-generic-password -a "$USER" -s "vaultwarden-backup-telegram-token" -w)
    TELEGRAM_CHAT=$(security find-generic-password -a "$USER" -s "vaultwarden-backup-telegram-chat" -w)
    
    MESSAGE="⚠️ Vaultwarden Backup Health Alert
Score: ${HEALTH_SCORE}/100
Host: $(hostname -s)
Time: $(date)"

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d chat_id="${TELEGRAM_CHAT}" \
        -d text="$MESSAGE"
fi
```

## Dashboard Options

### Terminal Dashboard (Watch Mode)

```zsh
# Continuous monitoring (refreshes every 30 seconds)
watch -n 30 -c ~/bin/vaultwarden-backup-monitor.zsh

# Or with full details
watch -n 60 -c ~/bin/vaultwarden-backup-monitor.zsh --full
```

### Web Dashboard (Simple)

Create a simple web dashboard:

```zsh
#!/usr/bin/env zsh
# Save as: ~/bin/vaultwarden-monitor-web.zsh

# Generate HTML
cat > /tmp/vaultwarden-monitor.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Vaultwarden Backup Monitor</title>
    <meta http-equiv="refresh" content="60">
    <style>
        body {
            font-family: monospace;
            background: #1e1e1e;
            color: #d4d4d4;
            padding: 20px;
        }
        .status-ok { color: #4ec9b0; }
        .status-warning { color: #dcdcaa; }
        .status-error { color: #f48771; }
        pre { white-space: pre-wrap; }
    </style>
</head>
<body>
    <h1>🔐 Vaultwarden Backup Monitor</h1>
    <p>Last updated: $(date)</p>
    <pre>
$(~/bin/vaultwarden-backup-monitor.zsh --full --stats 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
    </pre>
</body>
</html>
EOF

# Serve with Python
cd /tmp
python3 -m http.server 8080 &
echo "Dashboard available at: http://localhost:8080/vaultwarden-monitor.html"
```

### Status Bar (macOS Menu Bar)

Using BitBar/SwiftBar:

```zsh
#!/usr/bin/env zsh
# Save as: ~/Library/Application Support/SwiftBar/vaultwarden-monitor.1h.sh
# Refresh every 1 hour

# Get latest backup info
BACKUP_DIR="${HOME}/Documents/vaultwarden-backups/versions"
LATEST=$(ls -t "$BACKUP_DIR"/vault-*.json 2>/dev/null | head -1)

if [[ -z "$LATEST" ]]; then
    echo "🔐 ⚠️ | color=orange"
    echo "---"
    echo "No backups found"
    exit 0
fi

LATEST_TIME=$(stat -f %m "$LATEST")
NOW=$(date +%s)
AGE_HOURS=$(( (NOW - LATEST_TIME) / 3600 ))

if (( AGE_HOURS > 6 )); then
    echo "🔐 ❌ | color=red"
    STATUS="CRITICAL"
elif (( AGE_HOURS > 4 )); then
    echo "🔐 ⚠️ | color=orange"
    STATUS="WARNING"
else
    echo "🔐 ✅ | color=green"
    STATUS="OK"
fi

echo "---"
echo "Status: $STATUS"
echo "Age: ${AGE_HOURS}h"
echo "---"
echo "Open Dashboard | bash=$0 terminal=true param1=dashboard"
echo "Run Backup Now | bash=$HOME/bin/vaultwarden-backup.zsh terminal=true"
echo "---"
echo "Refresh | refresh=true"

if [[ "$1" == "dashboard" ]]; then
    ~/bin/vaultwarden-backup-monitor.zsh --full
fi
```

## Alerting Rules

### Critical Alerts (Immediate Action)

- Backup > 8 hours old
- No backups exist
- Credentials missing from Keychain
- LaunchAgent not running
- Database backup failed

### Warning Alerts (Check Soon)

- Backup > 4 hours old
- Git not synced (> 5 unpushed commits)
- Low disk space (< 5GB)
- Error logs not empty

### Info Alerts (FYI)

- Backup completed successfully
- Weekly backup summary
- Monthly statistics

## Troubleshooting

### Issue: Monitor shows "No backups found"

```zsh
# Check directory
ls -la ~/Documents/vaultwarden-backups/versions/

# Check configuration
cat ~/.vaultwarden-backup-config

# Run backup manually
~/bin/vaultwarden-backup.zsh
```

### Issue: Health score always low

```zsh
# Run detailed check
vw-monitor --full

# Review issues listed at bottom
# Fix each issue individually
```

### Issue: Git status shows "behind remote"

```zsh
cd ~/Documents/vaultwarden-backups
git fetch
git pull origin main
```

### Issue: LaunchAgent not detected

```zsh
# Check if loaded
launchctl list | grep vaultwarden

# Load it
launchctl load ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist

# Verify
launchctl print gui/$(id -u)/com.user.vaultwarden-backup
```

## Integration with Other Tools

### Prometheus Metrics Export

```zsh
#!/usr/bin/env zsh
# Export metrics in Prometheus format

cat << EOF
# HELP vaultwarden_backup_age_hours Age of latest backup in hours
# TYPE vaultwarden_backup_age_hours gauge
vaultwarden_backup_age_hours $(calculate_age)

# HELP vaultwarden_backup_health_score Backup system health score
# TYPE vaultwarden_backup_health_score gauge
vaultwarden_backup_health_score $(calculate_health_score)

# HELP vaultwarden_backup_total Total number of backups
# TYPE vaultwarden_backup_total gauge
vaultwarden_backup_total $(count_backups)
EOF
```

### Grafana Dashboard

Create JSON dashboard with:
- Backup age graph
- Health score over time
- Backup size trend
- Success/failure rate

### HealthChecks.io Integration

```zsh
# Add to backup script
HEALTHCHECKS_URL="https://hc-ping.com/YOUR-UUID"

# After successful backup
curl -fsS --retry 3 "$HEALTHCHECKS_URL" &>/dev/null
```

## Reporting

### Weekly Summary

```zsh
#!/usr/bin/env zsh
# Generate weekly summary

echo "Vaultwarden Backup Weekly Summary"
echo "Week of $(date -v-7d +%Y-%m-%d) to $(date +%Y-%m-%d)"
echo ""

# Count backups this week
BACKUP_DIR="${HOME}/Documents/vaultwarden-backups/versions"
WEEK_COUNT=0
for i in {0..6}; do
    DATE=$(date -v-${i}d +%Y%m%d)
    COUNT=$(ls -1 "$BACKUP_DIR"/vault-${DATE}-*.json 2>/dev/null | wc -l)
    WEEK_COUNT=$((WEEK_COUNT + COUNT))
done

echo "Total backups: ${WEEK_COUNT}"
echo "Expected backups: 56 (8 per day)"

if (( WEEK_COUNT >= 56 )); then
    echo "Status: ✅ All backups completed"
elif (( WEEK_COUNT >= 42 )); then
    echo "Status: ⚠️ Some backups missed"
else
    echo "Status: ❌ Many backups missed"
fi

# Size stats
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
echo "Total storage: ${TOTAL_SIZE}"

# Git stats
cd ~/Documents/vaultwarden-backups
COMMITS=$(git log --since="1 week ago" --oneline | wc -l)
echo "Git commits: ${COMMITS}"
```

## Quick Reference

```zsh
# Basic check
vw-monitor

# Full report
vw-monitor --full

# With statistics
vw-monitor --full --stats

# Watch mode
watch -n 30 vw-monitor

# Help
vw-monitor --help

# Check backup age
ls -lht ~/Documents/vaultwarden-backups/versions/ | head -1

# Manual backup
~/bin/vaultwarden-backup.zsh

# View logs
tail -f ~/Library/Logs/vaultwarden-backup.log
```

---

**Last Updated**: October 6, 2025  
**Version**: 1.0.0

