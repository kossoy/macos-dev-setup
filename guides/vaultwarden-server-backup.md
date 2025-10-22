# Vaultwarden Server-Side Backup Guide (TrueNAS)

## Overview

Comprehensive backup strategy for self-hosted Vaultwarden on TrueNAS as a Docker community application. This guide covers database backups, data directory backups, and disaster recovery procedures.

## Architecture

Your setup:
- **Platform**: TrueNAS (Scale/Core)
- **Installation**: Community Docker Application
- **URL**: https://pwd.oklabs.uk
- **Database**: SQLite (default) or PostgreSQL/MySQL
- **Storage**: TrueNAS pool/dataset

## What to Backup

### Critical Files (MUST backup)

```
/mnt/pool/ix-applications/releases/vaultwarden/volumes/
├── db.sqlite3              # Main database
├── db.sqlite3-wal          # Write-ahead log
├── db.sqlite3-shm          # Shared memory
├── rsa_key.pem             # Auth keys (CRITICAL!)
├── rsa_key.der
├── rsa_key.pub.der
└── attachments/            # User file attachments
```

### Important Files (SHOULD backup)

```
├── sends/                  # Bitwarden Send attachments
├── config.json             # Admin configuration
└── icon_cache/             # Site favicons (can regenerate)
```

## Backup Strategy

### Strategy 1: Built-in Vaultwarden Backup (Recommended)

**Available since v1.32.1**

```bash
# For TrueNAS Docker app
docker exec -it <vaultwarden-container-name> /vaultwarden backup

# Find container name
docker ps | grep vaultwarden

# Example
docker exec -it ix-vaultwarden /vaultwarden backup
```

### Strategy 2: SQLite Database Backup

**Using SQLite CLI (most reliable for active databases)**

```bash
#!/usr/bin/env bash
# Save as: /mnt/pool/scripts/vaultwarden-db-backup.sh

set -euo pipefail

# Configuration
VAULTWARDEN_DATA="/mnt/pool/ix-applications/releases/vaultwarden/volumes/ix_volumes/vaultwarden-data"
BACKUP_DIR="/mnt/pool/backups/vaultwarden"
RETENTION_DAYS=30

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Timestamp
TIMESTAMP=$(date "+%Y%m%d-%H%M%S")
BACKUP_FILE="$BACKUP_DIR/vaultwarden-db-${TIMESTAMP}.sqlite3"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Vaultwarden Database Backup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Backup database using SQLite CLI
echo "💾 Backing up database..."
sqlite3 "$VAULTWARDEN_DATA/db.sqlite3" ".backup '$BACKUP_FILE'"

# Verify backup
if [[ -s "$BACKUP_FILE" ]]; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "✅ Backup created: ${SIZE}"
    echo "   📁 ${BACKUP_FILE}"
else
    echo "❌ ERROR: Backup failed or empty"
    exit 1
fi

# Compress backup
echo "🗜️  Compressing backup..."
gzip -9 "$BACKUP_FILE"
COMPRESSED="${BACKUP_FILE}.gz"

if [[ -f "$COMPRESSED" ]]; then
    COMPRESSED_SIZE=$(du -h "$COMPRESSED" | cut -f1)
    echo "✅ Compressed: ${COMPRESSED_SIZE}"
else
    echo "⚠️  Compression failed, keeping uncompressed"
fi

# Cleanup old backups
echo "🧹 Cleaning up old backups (>${RETENTION_DAYS} days)..."
find "$BACKUP_DIR" -name "vaultwarden-db-*.sqlite3.gz" -mtime +${RETENTION_DAYS} -delete
find "$BACKUP_DIR" -name "vaultwarden-db-*.sqlite3" -mtime +${RETENTION_DAYS} -delete

REMAINING=$(ls -1 "$BACKUP_DIR"/vaultwarden-db-*.gz 2>/dev/null | wc -l)
echo "   📊 Backups retained: ${REMAINING}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Backup completed successfully"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

Make it executable:

```bash
chmod +x /mnt/pool/scripts/vaultwarden-db-backup.sh
```

### Strategy 3: Full Data Directory Backup

**Complete backup including attachments and configuration**

```bash
#!/usr/bin/env bash
# Save as: /mnt/pool/scripts/vaultwarden-full-backup.sh

set -euo pipefail

# Configuration
VAULTWARDEN_DATA="/mnt/pool/ix-applications/releases/vaultwarden/volumes/ix_volumes/vaultwarden-data"
BACKUP_DIR="/mnt/pool/backups/vaultwarden-full"
RETENTION_DAYS=14
TELEGRAM_BOT_TOKEN=""  # Optional
TELEGRAM_CHAT_ID=""    # Optional

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Timestamp
TIMESTAMP=$(date "+%Y%m%d-%H%M%S")
BACKUP_FILE="$BACKUP_DIR/vaultwarden-full-${TIMESTAMP}.tar.gz"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Vaultwarden Full Backup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Optional: Stop container for consistent backup
# echo "⏸️  Stopping Vaultwarden container..."
# docker stop ix-vaultwarden

# Create backup
echo "💾 Creating full backup archive..."
tar czf "$BACKUP_FILE" \
    --exclude='icon_cache' \
    -C "$(dirname "$VAULTWARDEN_DATA")" \
    "$(basename "$VAULTWARDEN_DATA")"

# Optional: Restart container
# echo "▶️  Starting Vaultwarden container..."
# docker start ix-vaultwarden

# Verify backup
if [[ -s "$BACKUP_FILE" ]]; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "✅ Backup created: ${SIZE}"
    echo "   📁 ${BACKUP_FILE}"
else
    echo "❌ ERROR: Backup failed or empty"
    exit 1
fi

# Cleanup old backups
echo "🧹 Cleaning up old backups (>${RETENTION_DAYS} days)..."
find "$BACKUP_DIR" -name "vaultwarden-full-*.tar.gz" -mtime +${RETENTION_DAYS} -delete

REMAINING=$(ls -1 "$BACKUP_DIR"/vaultwarden-full-*.tar.gz 2>/dev/null | wc -l)
echo "   📊 Backups retained: ${REMAINING}"

# Optional: Send Telegram notification
if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
    MESSAGE="✅ Vaultwarden Full Backup Complete
Host: $(hostname)
Time: $(date '+%Y-%m-%d %H:%M:%S')
Size: ${SIZE}
File: $(basename "$BACKUP_FILE")"

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="${TELEGRAM_CHAT_ID}" \
        -d text="$MESSAGE" &>/dev/null
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Backup completed successfully"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

Make it executable:

```bash
chmod +x /mnt/pool/scripts/vaultwarden-full-backup.sh
```

## Automated Scheduling

### Option 1: TrueNAS Cron Jobs (Recommended)

**Via TrueNAS Web UI:**

1. Go to **Tasks** → **Cron Jobs**
2. Click **Add**
3. Configure:
   - **Description**: `Vaultwarden Database Backup`
   - **Command**: `/mnt/pool/scripts/vaultwarden-db-backup.sh`
   - **Run As User**: `root`
   - **Schedule**: Custom
   - **Every**: `6 hours` or specific times

**Example schedules:**

```
# Database backup every 6 hours
0 */6 * * * /mnt/pool/scripts/vaultwarden-db-backup.sh >> /var/log/vaultwarden-backup.log 2>&1

# Full backup daily at 2 AM
0 2 * * * /mnt/pool/scripts/vaultwarden-full-backup.sh >> /var/log/vaultwarden-full-backup.log 2>&1

# Weekly full backup on Sunday at 3 AM
0 3 * * 0 /mnt/pool/scripts/vaultwarden-full-backup.sh >> /var/log/vaultwarden-full-backup.log 2>&1
```

### Option 2: Systemd Timer (TrueNAS Scale)

Create systemd service and timer:

```bash
# Service file
cat > /etc/systemd/system/vaultwarden-backup.service << 'EOF'
[Unit]
Description=Vaultwarden Backup Service
After=network.target

[Service]
Type=oneshot
ExecStart=/mnt/pool/scripts/vaultwarden-db-backup.sh
User=root
StandardOutput=journal
StandardError=journal
EOF

# Timer file
cat > /etc/systemd/system/vaultwarden-backup.timer << 'EOF'
[Unit]
Description=Vaultwarden Backup Timer
Requires=vaultwarden-backup.service

[Timer]
OnCalendar=*-*-* 00,06,12,18:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable and start timer
systemctl daemon-reload
systemctl enable vaultwarden-backup.timer
systemctl start vaultwarden-backup.timer

# Check status
systemctl list-timers | grep vaultwarden
```

## Off-Site Backup

### Strategy 1: Rsync to Remote Server

```bash
#!/usr/bin/env bash
# Save as: /mnt/pool/scripts/vaultwarden-offsite-sync.sh

set -euo pipefail

BACKUP_DIR="/mnt/pool/backups/vaultwarden"
REMOTE_USER="backup-user"
REMOTE_HOST="backup-server.example.com"
REMOTE_PATH="/backups/vaultwarden"
SSH_KEY="/root/.ssh/id_ed25519_backup"

echo "📤 Syncing backups to remote server..."

rsync -avz --delete \
    -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" \
    "$BACKUP_DIR/" \
    "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"

if [[ $? -eq 0 ]]; then
    echo "✅ Remote sync completed"
else
    echo "❌ Remote sync failed"
    exit 1
fi
```

### Strategy 2: S3/B2/Wasabi Cloud Backup

```bash
#!/usr/bin/env bash
# Using rclone for cloud backup
# Install: apt install rclone (TrueNAS Scale)

set -euo pipefail

BACKUP_DIR="/mnt/pool/backups/vaultwarden"
RCLONE_REMOTE="b2-backup"  # Configure with: rclone config
RCLONE_PATH="vaultwarden-backups"

echo "☁️  Uploading backups to cloud..."

rclone sync "$BACKUP_DIR" "${RCLONE_REMOTE}:${RCLONE_PATH}" \
    --transfers 4 \
    --checkers 8 \
    --contimeout 60s \
    --timeout 300s \
    --retries 3 \
    --low-level-retries 10 \
    --stats 1s

if [[ $? -eq 0 ]]; then
    echo "✅ Cloud sync completed"
else
    echo "❌ Cloud sync failed"
    exit 1
fi
```

### Configure rclone for B2/S3:

```bash
# Interactive configuration
rclone config

# Or non-interactive for Backblaze B2
rclone config create b2-backup b2 \
    account $B2_ACCOUNT_ID \
    key $B2_APPLICATION_KEY

# Test
rclone lsd b2-backup:
```

## TrueNAS Snapshots

### Enable ZFS Snapshots (Best for Point-in-Time Recovery)

**Via TrueNAS Web UI:**

1. Go to **Storage** → **Snapshots**
2. Click **Add**
3. Configure:
   - **Dataset**: Your Vaultwarden dataset
   - **Snapshot Name**: `auto-%Y%m%d-%H%M`
   - **Recursive**: Yes
   - **Lifetime**: 30 days

**Snapshot Schedule:**
- **Hourly**: Keep 24
- **Daily**: Keep 7
- **Weekly**: Keep 4
- **Monthly**: Keep 12

**Via CLI:**

```bash
# Create snapshot
zfs snapshot pool/ix-applications/releases/vaultwarden@backup-$(date +%Y%m%d-%H%M)

# List snapshots
zfs list -t snapshot | grep vaultwarden

# Rollback to snapshot
zfs rollback pool/ix-applications/releases/vaultwarden@backup-20251006-0200

# Clone snapshot for testing
zfs clone pool/ix-applications/releases/vaultwarden@backup-20251006-0200 \
    pool/vaultwarden-test
```

## Monitoring & Alerting

### Health Check Script

```bash
#!/usr/bin/env bash
# Save as: /mnt/pool/scripts/vaultwarden-backup-check.sh

BACKUP_DIR="/mnt/pool/backups/vaultwarden"
MAX_AGE_HOURS=8
TELEGRAM_BOT_TOKEN=""  # Optional
TELEGRAM_CHAT_ID=""    # Optional

# Find latest backup
LATEST=$(ls -t "$BACKUP_DIR"/vaultwarden-db-*.gz 2>/dev/null | head -1)

if [[ -z "$LATEST" ]]; then
    echo "❌ No backups found!"
    # Send alert
    exit 1
fi

# Check age
LATEST_TIME=$(stat -c %Y "$LATEST")
NOW=$(date +%s)
AGE_HOURS=$(( (NOW - LATEST_TIME) / 3600 ))

echo "Latest backup: $(basename "$LATEST")"
echo "Age: ${AGE_HOURS} hours"

if (( AGE_HOURS > MAX_AGE_HOURS )); then
    echo "⚠️  WARNING: Backup is too old!"
    
    if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
        MESSAGE="⚠️ Vaultwarden Backup Alert
Latest backup is ${AGE_HOURS} hours old!
Threshold: ${MAX_AGE_HOURS} hours
Server: $(hostname)"
        
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d chat_id="${TELEGRAM_CHAT_ID}" \
            -d text="$MESSAGE" &>/dev/null
    fi
    
    exit 1
else
    echo "✅ Backup is fresh"
fi
```

Run via cron every hour:

```bash
0 * * * * /mnt/pool/scripts/vaultwarden-backup-check.sh
```

## Disaster Recovery Procedures

### Restore Database from Backup

```bash
#!/usr/bin/env bash
# Restore Vaultwarden database

# STOP THE CONTAINER FIRST!
docker stop ix-vaultwarden

# Backup current database (just in case)
cp /mnt/pool/.../vaultwarden-data/db.sqlite3 \
   /mnt/pool/.../vaultwarden-data/db.sqlite3.before-restore

# Restore from backup
BACKUP_FILE="/mnt/pool/backups/vaultwarden/vaultwarden-db-20251006-020000.sqlite3.gz"
gunzip -c "$BACKUP_FILE" > /mnt/pool/.../vaultwarden-data/db.sqlite3

# Set permissions
chown 1000:1000 /mnt/pool/.../vaultwarden-data/db.sqlite3
chmod 644 /mnt/pool/.../vaultwarden-data/db.sqlite3

# Start container
docker start ix-vaultwarden

# Test access
curl https://pwd.oklabs.uk/
```

### Full System Restore

```bash
# STOP THE CONTAINER
docker stop ix-vaultwarden

# Remove old data
mv /mnt/pool/.../vaultwarden-data \
   /mnt/pool/.../vaultwarden-data.old

# Restore from full backup
BACKUP_FILE="/mnt/pool/backups/vaultwarden-full/vaultwarden-full-20251006-020000.tar.gz"
tar xzf "$BACKUP_FILE" -C /mnt/pool/.../

# Fix permissions
chown -R 1000:1000 /mnt/pool/.../vaultwarden-data
chmod -R 755 /mnt/pool/.../vaultwarden-data

# Start container
docker start ix-vaultwarden

# Verify
docker logs -f ix-vaultwarden
```

## Complete Backup Workflow

**Recommended comprehensive strategy:**

```
┌─────────────────────────────────────────────────────┐
│ 1. TrueNAS ZFS Snapshots (Hourly/Daily)           │
│    - Fast, space-efficient                         │
│    - Local only                                    │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│ 2. Database Backups (Every 6 hours)               │
│    - SQLite .backup command                        │
│    - Compressed, timestamped                       │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│ 3. Full Data Backup (Daily)                       │
│    - Database + attachments + config               │
│    - Compressed tarball                            │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│ 4. Off-site Sync (Daily)                          │
│    - Rsync to remote server OR                     │
│    - Rclone to cloud storage (B2/S3)              │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│ 5. User Exports (Monthly)                         │
│    - Encrypted JSON exports                        │
│    - User responsibility                           │
└─────────────────────────────────────────────────────┘
```

## Backup Retention Policy

| Backup Type | Frequency | Retention | Location |
|-------------|-----------|-----------|----------|
| ZFS Snapshots | Hourly | 24 hours | Local |
| ZFS Snapshots | Daily | 7 days | Local |
| Database | 6 hours | 30 days | Local |
| Full Backup | Daily | 14 days | Local |
| Off-site Database | Daily | 90 days | Remote/Cloud |
| Off-site Full | Weekly | 365 days | Remote/Cloud |

## Testing Schedule

- **Weekly**: Verify latest backup exists and is recent
- **Monthly**: Test database restore on test system
- **Quarterly**: Full disaster recovery test
- **Annually**: Document and review procedures

## Security Considerations

1. ✅ **Encrypt backups** before off-site transfer
2. ✅ **Restrict backup directory permissions** (700)
3. ✅ **Use SSH keys** for remote sync (no passwords)
4. ✅ **Monitor backup logs** for failures
5. ✅ **Test restores regularly**
6. ✅ **Keep RSA keys** in backups (critical!)
7. ✅ **Use separate credentials** for backup accounts

## Quick Reference Commands

```bash
# Manual database backup
docker exec ix-vaultwarden /vaultwarden backup

# OR
sqlite3 /path/to/db.sqlite3 ".backup '/path/to/backup.sqlite3'"

# List backups
ls -lht /mnt/pool/backups/vaultwarden/

# Restore database
docker stop ix-vaultwarden
gunzip -c backup.sqlite3.gz > /path/to/db.sqlite3
docker start ix-vaultwarden

# Create snapshot
zfs snapshot pool/dataset@manual-$(date +%Y%m%d)

# Check backup age
find /mnt/pool/backups/vaultwarden/ -name "*.gz" -mtime -1
```

---

**Last Updated**: October 6, 2025  
**TrueNAS Version**: Scale 22.x / Core 13.x

