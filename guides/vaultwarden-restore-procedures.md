# Vaultwarden Restore Procedures

## Overview

Complete guide for restoring Vaultwarden data from backups in various disaster scenarios. Covers both user-level exports and server-level database restores.

## Table of Contents

1. [User-Level Restore](#user-level-restore)
2. [Server Database Restore](#server-database-restore)
3. [Complete Server Recovery](#complete-server-recovery)
4. [Disaster Recovery Scenarios](#disaster-recovery-scenarios)
5. [Testing Procedures](#testing-procedures)

---

## User-Level Restore

### Scenario 1: Restore Individual Items

**When**: Accidentally deleted item, need specific password, corrupted vault

**Method**: Using encrypted backup export from macOS automated backups

#### Step 1: Locate Backup File

```zsh
cd ~/Documents/vaultwarden-backups/versions

# List available backups
ls -lht vault-*.json

# Show git history to find specific point in time
cd ~/Documents/vaultwarden-backups
git log --oneline --all

# Checkout specific version if needed
git checkout <commit-hash> -- versions/vault-YYYYMMDD-HHMMSS.json
```

#### Step 2: Retrieve Backup Password

```zsh
# Get backup encryption password from Keychain
BACKUP_PASSWORD=$(security find-generic-password \
  -a "$USER" \
  -s "vaultwarden-backup-encrypt" \
  -w)

echo $BACKUP_PASSWORD  # Verify it's retrieved
```

#### Step 3: Restore via Web Interface

**Option A: Import into current vault (merges)**

1. Log into https://pwd.oklabs.uk
2. Go to **Settings** → **Vault options**
3. Click **Import items**
4. Select:
   - **File format**: `Bitwarden (json)` (encrypted)
   - **Import to**: Your vault
5. Choose file or paste contents
6. Enter backup password when prompted
7. Click **Import data**

⚠️ **Warning**: This will merge/duplicate items if they already exist!

**Option B: Review backup first (safer)**

```zsh
# Decrypt backup to plain JSON for review
bw config server https://pwd.oklabs.uk
bw login your-email@example.com

# Export backup to readable format
# (This requires the bw CLI to support encrypted JSON import)
```

#### Step 4: Verify Restoration

1. Check that restored items appear in vault
2. Test login credentials work
3. Verify TOTP codes generate correctly
4. Check attachments are accessible

---

### Scenario 2: Complete Vault Restore

**When**: Lost all vault data, switching devices, recovering from account lock

#### Option 1: Restore from GitHub Backup

```zsh
# Clone backup repository (if not already)
git clone git@github.com:USERNAME/vaultwarden-backups.git ~/vaultwarden-restore

cd ~/vaultwarden-restore/versions

# Find the backup you want to restore
ls -lht vault-*.json

# Get backup password
BACKUP_PASSWORD=$(security find-generic-password \
  -a "$USER" \
  -s "vaultwarden-backup-encrypt" \
  -w)

# Configure Bitwarden CLI
bw config server https://pwd.oklabs.uk
bw login your-email@example.com

# Clear current vault (DANGEROUS - only if you're sure!)
# bw sync
# bw list items | jq -r '.[].id' | xargs -I {} bw delete item {}

# Import backup
bw import bitwardenjson vault-20251006-143000.json --password "$BACKUP_PASSWORD"

# Sync
bw sync

# Verify via CLI
bw list items | jq -r '.[] | "\(.name) - \(.login.username)"'
```

#### Option 2: Restore via Web Interface

1. Log into https://pwd.oklabs.uk
2. If needed, **export current vault first** (just in case)
3. Go to **Settings** → **Vault options** → **Import items**
4. Select encrypted JSON backup file
5. Enter backup password
6. Import
7. Verify all items present

---

## Server Database Restore

### Scenario 3: Database Corruption

**When**: Database errors, corrupted SQLite file, failed migration

#### Prerequisites

- SSH/shell access to TrueNAS
- Database backups available
- Vaultwarden container access

#### Step 1: Verify Backup Availability

```bash
# Connect to TrueNAS via SSH
ssh root@truenas-server

# List available backups
ls -lht /mnt/pool/backups/vaultwarden/

# Verify backup integrity
BACKUP="/mnt/pool/backups/vaultwarden/vaultwarden-db-20251006-020000.sqlite3.gz"

gunzip -t "$BACKUP"
if [[ $? -eq 0 ]]; then
    echo "✅ Backup file is valid"
else
    echo "❌ Backup file is corrupted!"
    exit 1
fi
```

#### Step 2: Stop Vaultwarden Service

```bash
# Find container name
docker ps | grep vaultwarden

# Stop container
docker stop ix-vaultwarden

# Verify it's stopped
docker ps | grep vaultwarden
# Should return nothing
```

#### Step 3: Backup Current Database

```bash
# Always backup current state before restore!
VAULTWARDEN_DATA="/mnt/pool/ix-applications/releases/vaultwarden/volumes/ix_volumes/vaultwarden-data"

cp "$VAULTWARDEN_DATA/db.sqlite3" \
   "$VAULTWARDEN_DATA/db.sqlite3.before-restore-$(date +%Y%m%d-%H%M%S)"

# Also backup WAL files if present
cp "$VAULTWARDEN_DATA/db.sqlite3-wal" \
   "$VAULTWARDEN_DATA/db.sqlite3-wal.backup" 2>/dev/null || true
cp "$VAULTWARDEN_DATA/db.sqlite3-shm" \
   "$VAULTWARDEN_DATA/db.sqlite3-shm.backup" 2>/dev/null || true
```

#### Step 4: Restore Database

```bash
# Decompress backup
BACKUP="/mnt/pool/backups/vaultwarden/vaultwarden-db-20251006-020000.sqlite3.gz"
gunzip -c "$BACKUP" > "$VAULTWARDEN_DATA/db.sqlite3"

# Remove WAL files (will be recreated)
rm -f "$VAULTWARDEN_DATA/db.sqlite3-wal"
rm -f "$VAULTWARDEN_DATA/db.sqlite3-shm"

# Verify database integrity
sqlite3 "$VAULTWARDEN_DATA/db.sqlite3" "PRAGMA integrity_check;"
# Should output: ok

# Check database size
du -h "$VAULTWARDEN_DATA/db.sqlite3"
```

#### Step 5: Fix Permissions

```bash
# Vaultwarden runs as UID 1000 typically
chown 1000:1000 "$VAULTWARDEN_DATA/db.sqlite3"
chmod 644 "$VAULTWARDEN_DATA/db.sqlite3"

# Verify
ls -la "$VAULTWARDEN_DATA/db.sqlite3"
```

#### Step 6: Start Vaultwarden

```bash
# Start container
docker start ix-vaultwarden

# Watch logs
docker logs -f --tail 100 ix-vaultwarden

# Look for successful startup messages:
# "Rocket has launched from http://0.0.0.0:80"
```

#### Step 7: Verify Service

```bash
# Test API endpoint
curl -I https://pwd.oklabs.uk/

# Should return 200 OK

# Test login via CLI
bw config server https://pwd.oklabs.uk
bw login your-email@example.com

# List items to verify data
bw list items --pretty
```

---

## Complete Server Recovery

### Scenario 4: Complete Server Failure

**When**: Server crash, hardware failure, starting fresh TrueNAS

#### Step 1: Prepare New Environment

```bash
# Fresh TrueNAS installation
# Install Vaultwarden from community apps
# DO NOT start it yet!

# Create directory structure
mkdir -p /mnt/pool/backups/vaultwarden-restore
```

#### Step 2: Retrieve Backups

**Option A: From remote backup server**

```bash
# SSH to backup server and copy
scp backup-server:/backups/vaultwarden/*.tar.gz \
    /mnt/pool/backups/vaultwarden-restore/

# Or rsync
rsync -avz backup-server:/backups/vaultwarden/ \
    /mnt/pool/backups/vaultwarden-restore/
```

**Option B: From cloud storage (B2/S3)**

```bash
# Install rclone if not present
apt install rclone

# Configure rclone
rclone config

# Download backups
rclone copy b2-backup:vaultwarden-backups \
    /mnt/pool/backups/vaultwarden-restore/ \
    --progress

# Or use s3cmd/aws cli
aws s3 sync s3://bucket/vaultwarden/ \
    /mnt/pool/backups/vaultwarden-restore/
```

**Option C: From GitHub (user exports)**

```bash
git clone https://github.com/USERNAME/vaultwarden-backups.git \
    /mnt/pool/backups/vaultwarden-restore/
```

#### Step 3: Restore Full Data Directory

```bash
# Find latest full backup
LATEST_FULL=$(ls -t /mnt/pool/backups/vaultwarden-restore/vaultwarden-full-*.tar.gz | head -1)

echo "Restoring from: $LATEST_FULL"

# Extract to Vaultwarden data directory
VAULTWARDEN_DATA="/mnt/pool/ix-applications/releases/vaultwarden/volumes/ix_volumes/vaultwarden-data"

tar xzf "$LATEST_FULL" -C "$(dirname "$VAULTWARDEN_DATA")"

# Fix permissions
chown -R 1000:1000 "$VAULTWARDEN_DATA"
chmod -R 755 "$VAULTWARDEN_DATA"
chmod 644 "$VAULTWARDEN_DATA/db.sqlite3"
chmod 600 "$VAULTWARDEN_DATA/rsa_key.*"
```

#### Step 4: Verify Critical Files

```bash
cd "$VAULTWARDEN_DATA"

# Check required files exist
for file in db.sqlite3 rsa_key.pem rsa_key.der rsa_key.pub.der; do
    if [[ -f "$file" ]]; then
        echo "✅ $file"
    else
        echo "❌ $file MISSING!"
    fi
done

# Verify database
sqlite3 db.sqlite3 "PRAGMA integrity_check;"

# Count users
sqlite3 db.sqlite3 "SELECT COUNT(*) FROM users;"

# Count items
sqlite3 db.sqlite3 "SELECT COUNT(*) FROM ciphers;"
```

#### Step 5: Configure Vaultwarden

```bash
# Update environment variables if needed
# Via TrueNAS UI: Apps → Vaultwarden → Edit

# Key settings to verify:
# - DOMAIN=https://pwd.oklabs.uk
# - DATA_FOLDER=/data
# - Database path (if custom)
```

#### Step 6: Start and Test

```bash
# Start container
docker start ix-vaultwarden

# Monitor startup
docker logs -f ix-vaultwarden

# Test service
curl https://pwd.oklabs.uk/alive
# Should return: "alive"

# Test login
bw config server https://pwd.oklabs.uk
bw login your-email@example.com
bw sync
bw list items
```

---

## Disaster Recovery Scenarios

### Scenario 5: Lost Master Password

**Recovery**: Not possible without backup

**Prevention**: 
- Emergency access contacts set up
- Password hints configured  
- Master password written down in secure location

**Mitigation**:
- Use user-level encrypted backups (you need backup password)
- Server admin can't recover master password (zero-knowledge encryption)

### Scenario 6: Corrupted Account

**When**: Account locked, MFA issues, corrupted user data

```bash
# Server-side user investigation
docker exec -it ix-vaultwarden sqlite3 /data/db.sqlite3

# Check user status
SELECT email, created_at, verified, security_stamp 
FROM users 
WHERE email = 'user@example.com';

# Check failed login attempts
SELECT * FROM twofactor_incomplete 
WHERE user_uuid = (SELECT uuid FROM users WHERE email = 'user@example.com');

# Reset MFA for user (if needed - ask user first!)
DELETE FROM twofactor 
WHERE user_uuid = (SELECT uuid FROM users WHERE email = 'user@example.com');

# Exit
.quit
```

### Scenario 7: Ransomware / Malicious Deletion

**Immediate Actions**:
1. Disconnect server from network
2. DO NOT restart Vaultwarden
3. Create forensic copy of current state
4. Restore from last known good backup

```bash
# Create forensic copy
VAULTWARDEN_DATA="/mnt/pool/.../vaultwarden-data"
FORENSIC_DIR="/mnt/pool/forensics/vaultwarden-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$FORENSIC_DIR"
cp -a "$VAULTWARDEN_DATA" "$FORENSIC_DIR/"

# Restore from backup (follow Scenario 4)

# Report to authorities if needed
```

---

## Testing Procedures

### Monthly Restore Test

**Objective**: Verify backups are restorable

```bash
#!/usr/bin/env bash
# Monthly backup test script

set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Monthly Backup Restore Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get latest backup
BACKUP_DIR="/mnt/pool/backups/vaultwarden"
LATEST=$(ls -t "$BACKUP_DIR"/vaultwarden-db-*.gz | head -1)

if [[ -z "$LATEST" ]]; then
    echo "❌ No backups found!"
    exit 1
fi

echo "Testing backup: $(basename "$LATEST")"

# Create test directory
TEST_DIR="/tmp/vaultwarden-restore-test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

# Extract backup
gunzip -c "$LATEST" > "$TEST_DIR/db.sqlite3"

# Verify database
echo "Checking database integrity..."
sqlite3 "$TEST_DIR/db.sqlite3" "PRAGMA integrity_check;"

# Check counts
USER_COUNT=$(sqlite3 "$TEST_DIR/db.sqlite3" "SELECT COUNT(*) FROM users;")
ITEM_COUNT=$(sqlite3 "$TEST_DIR/db.sqlite3" "SELECT COUNT(*) FROM ciphers;")

echo "Users: $USER_COUNT"
echo "Items: $ITEM_COUNT"

# Check backup age
BACKUP_TIME=$(stat -c %Y "$LATEST")
NOW=$(date +%s)
AGE_HOURS=$(( (NOW - BACKUP_TIME) / 3600 ))

echo "Backup age: ${AGE_HOURS} hours"

# Cleanup
rm -rf "$TEST_DIR"

echo "✅ Test completed successfully"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Quarterly Disaster Recovery Drill

**Full procedure test including:**

1. Document current state (user count, item count)
2. Create fresh test environment
3. Restore from backup
4. Verify all data present
5. Test all functionality
6. Document time to recover
7. Update procedures based on findings

**Test checklist**:

- [ ] Backup retrieval time: _____ minutes
- [ ] Database restore time: _____ minutes  
- [ ] Service startup time: _____ minutes
- [ ] Total recovery time: _____ minutes
- [ ] All users accessible: Yes / No
- [ ] All items present: Yes / No
- [ ] Attachments working: Yes / No
- [ ] TOTP codes generating: Yes / No
- [ ] Web interface accessible: Yes / No
- [ ] API responding: Yes / No
- [ ] Browser extension working: Yes / No
- [ ] Mobile app working: Yes / No

---

## Restore Decision Tree

```
┌─────────────────────────────────────┐
│ What do you need to restore?        │
└─────────────────────────────────────┘
           ↓
    ┌──────┴──────┐
    │             │
Single Item   Full Vault
    │             │
    ↓             ↓
┌───────┐   ┌─────────┐
│ User  │   │ Server  │
│ Export│   │ Backup  │
└───────┘   └─────────┘
    │             │
    ↓             ↓
Import via    Stop service
Web UI        Restore DB
              Start service
```

## Recovery Time Objectives (RTO)

| Scenario | Target RTO | Actual Time |
|----------|------------|-------------|
| Single item restore | 5 minutes | Test: _____ |
| User vault restore | 15 minutes | Test: _____ |
| Database restore | 30 minutes | Test: _____ |
| Full server recovery | 2 hours | Test: _____ |
| Complete disaster | 4 hours | Test: _____ |

## Quick Reference Commands

```bash
# Find latest backup
ls -lht /mnt/pool/backups/vaultwarden/ | head -5

# Check backup integrity
gunzip -t backup.sqlite3.gz

# Verify database
sqlite3 db.sqlite3 "PRAGMA integrity_check;"

# Stop service
docker stop ix-vaultwarden

# Restore database
gunzip -c backup.sqlite3.gz > /path/to/db.sqlite3

# Fix permissions
chown 1000:1000 /path/to/db.sqlite3

# Start service  
docker start ix-vaultwarden

# Test service
curl https://pwd.oklabs.uk/alive
```

## Emergency Contacts

**Document these for disaster scenarios:**

- TrueNAS admin: _____________
- Domain/DNS provider: _____________
- Backup storage provider: _____________
- Emergency recovery team: _____________

---

**Last Updated**: October 6, 2025  
**Next Review**: January 6, 2026  
**Last Tested**: ________________

