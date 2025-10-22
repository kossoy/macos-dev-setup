# Vaultwarden Automatic Backup Setup for macOS

## Overview

This guide sets up automated, **encrypted** Vaultwarden vault backups on macOS that:
- Run automatically every 2-3 hours via LaunchAgent
- Store encrypted vault exports (password-protected JSON)
- Keep backups in Git repository with version history
- Implement 3-2-1 backup strategy
- Send Telegram notifications on success/failure
- Use macOS Keychain for secure credential storage
- Auto-cleanup old backups

## Prerequisites

- macOS (tested on macOS Tahoe 26.0.1)
- Bitwarden CLI installed
- Git repository for backups
- Telegram bot (optional, for notifications)

## Installation

### 1. Install Bitwarden CLI

```zsh
# Using Homebrew
brew install bitwarden-cli

# Verify installation
bw --version
```

### 2. Create Backup Directory Structure

**Option A: New Repository (Fresh Start)**

```zsh
# Create backup directory in ~/work (avoids iCloud sync)
mkdir -p ~/backups/vaultwarden-backups
cd ~/backups/vaultwarden-backups

# Initialize git repository (if not exists)
git init
git remote add origin <your-git-repo-url>

# Create versions directory
mkdir -p versions

# Create .gitignore
cat > .gitignore << 'EOF'
.env
*.log
.DS_Store
EOF

git add .gitignore
git commit -m "Initial commit: add .gitignore"
```

**Option B: Using Existing Repository (Migrate from Plain Text)**

If you already have a repository with plain text backups (like `username/VaultWarden-Backup`), here's how to migrate to encrypted backups:

```zsh
# Clone your existing repository
cd ~/work
gh repo clone username/VaultWarden-Backup vaultwarden-backups
cd vaultwarden-backups

# Create versions directory if it doesn't exist
mkdir -p versions

# IMPORTANT: Remove old plain text backups for security!
# First, let's archive them locally (optional but recommended)
mkdir -p ~/work/old-plaintext-backups
mv vault-*.json ~/work/old-plaintext-backups/ 2>/dev/null || true

# Update .gitignore
cat > .gitignore << 'EOF'
.env
*.log
.DS_Store
EOF

# Create a clean commit removing old plain text files
git add -A
git commit -m "Security: Remove plain text backups, switching to encrypted exports

BREAKING CHANGE: All backups will now be encrypted with a separate password.
Old plain text backups archived locally for one-time migration if needed.
"

git push origin main

# Optional: Delete old plain text backups from git history (nuclear option)
# This completely removes them from git history - do this if they contained sensitive data
# WARNING: This rewrites history, coordinate with any other users of the repo
# git filter-branch --force --index-filter \
#   'git rm --cached --ignore-unmatch vault-*.json' \
#   --prune-empty --tag-name-filter cat -- --all
# git push origin --force --all
```

**⚠️ Security Note**: If your old plain text backups are in the git history, they're still accessible. Consider:
1. **Minimum**: Change passwords for any items in those backups
2. **Better**: Use `git filter-branch` or BFG Repo-Cleaner to remove from history
3. **Best**: Delete repository and create new one (if practical)

### 3. Configure Secure Credentials in Keychain

Instead of storing passwords in plain text, we'll use macOS Keychain.

**⚠️ IMPORTANT - About the Backup Encryption Password:**

You need **TWO different passwords**:

1. **Master Password** - Your existing Vaultwarden login password
2. **Backup Encryption Password** - **CREATE A NEW ONE NOW!** 
   - This is NOT your master password
   - Generate a NEW strong password specifically for encrypting backups
   - **Write it down and store in a safe place** (physical safe, separate password manager, etc.)
   - If you lose this password, you CANNOT decrypt your backups!

**Why separate passwords?** If someone gets your master password, they shouldn't automatically access all your backup files too. This is defense-in-depth security.

Now store both passwords in Keychain:

```zsh
# Store your EXISTING Vaultwarden master password
security add-generic-password \
  -a "$USER" \
  -s "vaultwarden-backup-master" \
  -w "YOUR_EXISTING_MASTER_PASSWORD" \
  -U

# Store your NEW backup encryption password (CREATE THIS NOW!)
# Example: Use 1Password generator, or: openssl rand -base64 32
security add-generic-password \
  -a "$USER" \
  -s "vaultwarden-backup-encrypt" \
  -w "YOUR_NEW_BACKUP_PASSWORD" \
  -U

# Store Telegram bot token (optional)
security add-generic-password \
  -a "$USER" \
  -s "vaultwarden-backup-telegram-token" \
  -w "YOUR_BOT_TOKEN" \
  -U

# Store Telegram chat ID (optional)
security add-generic-password \
  -a "$USER" \
  -s "vaultwarden-backup-telegram-chat" \
  -w "YOUR_CHAT_ID" \
  -U
```

**📝 Action Required**: Before proceeding, **write down your new backup encryption password** and store it in:
- ✅ Physical safe or safety deposit box
- ✅ Separate password manager (not the one you're backing up!)
- ✅ Sealed envelope with trusted family member
- ❌ NOT on your computer unencrypted
- ❌ NOT in the same password manager you're backing up

### 4. Create Configuration File

Create a non-sensitive configuration file:

```zsh
cat > ~/.vaultwarden-backup-config << 'EOF'
# Vaultwarden Backup Configuration
# Sensitive credentials are stored in macOS Keychain

# Bitwarden server URL
BW_SERVER="https://pwd.oklabs.uk"

# Bitwarden account email
BW_ACCOUNT="john@personal-org.com"

# Backup directory (using ~/work to avoid iCloud sync)
BACKUP_DIR="$HOME/work/vaultwarden-backups"
VERSIONS_DIR="$BACKUP_DIR/versions"

# Backup retention (days)
RETENTION_DAILY=7
RETENTION_WEEKLY=30
RETENTION_MONTHLY=365

# Telegram notifications (set to 1 to enable)
TELEGRAM_ENABLED=1

# Git repository
GIT_PUSH_ENABLED=1
GIT_REMOTE="origin"
GIT_BRANCH="main"

# Backup file prefix
BACKUP_PREFIX="vault"
EOF
```

### 5. Create the Backup Script

Save this as `~/bin/vaultwarden-backup.zsh`:

```zsh
#!/usr/bin/env zsh
# Vaultwarden Automated Backup Script for macOS
# Secure version using Keychain and encrypted exports

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

CONFIG_FILE="${HOME}/.vaultwarden-backup-config"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ ERROR: Config file not found at $CONFIG_FILE" >&2
  exit 1
fi

source "$CONFIG_FILE"

# Bitwarden CLI command
BW_COMMAND="$(command -v bw)"
if [[ -z "$BW_COMMAND" ]]; then
  echo "❌ ERROR: Bitwarden CLI (bw) not found in PATH" >&2
  exit 1
fi

# -----------------------------------------------------------------------------
# Keychain Functions
# -----------------------------------------------------------------------------

get_keychain_password() {
  local service="$1"
  security find-generic-password \
    -a "$USER" \
    -s "$service" \
    -w 2>/dev/null || {
    echo "❌ ERROR: Failed to retrieve '$service' from Keychain" >&2
    return 1
  }
}

# -----------------------------------------------------------------------------
# Telegram Notification Function
# -----------------------------------------------------------------------------

send_telegram_message() {
  local message="$1"
  
  if [[ "$TELEGRAM_ENABLED" != "1" ]]; then
    return 0
  fi

  local token=$(get_keychain_password "vaultwarden-backup-telegram-token" 2>/dev/null || echo "")
  local chat_id=$(get_keychain_password "vaultwarden-backup-telegram-chat" 2>/dev/null || echo "")

  if [[ -z "$token" || -z "$chat_id" ]]; then
    echo "⚠️  Telegram credentials not found in Keychain, skipping notification"
    return 0
  fi

  curl -s -X POST "https://api.telegram.org/bot${token}/sendMessage" \
    -d chat_id="${chat_id}" \
    -d text="$message" \
    -d parse_mode="Markdown" &>/dev/null || {
    echo "⚠️  Failed to send Telegram notification"
  }
}

# -----------------------------------------------------------------------------
# Error Handler
# -----------------------------------------------------------------------------

error_handler() {
  local exit_code=$?
  local last_command=${(%):-%_}
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  local err_msg="⚠️ *VaultWarden Backup FAILED*
Host: $(hostname -s)
Time: ${timestamp}
Command: ${last_command}
Exit Code: ${exit_code}"

  echo "\n❌ $err_msg" >&2
  send_telegram_message "$err_msg"
  
  # Cleanup session if exists
  if [[ -n "${BW_SESSION:-}" ]]; then
    "$BW_COMMAND" lock &>/dev/null || true
  fi
  
  exit "$exit_code"
}

trap error_handler ERR

# -----------------------------------------------------------------------------
# Cleanup Function
# -----------------------------------------------------------------------------

cleanup_old_backups() {
  local backup_dir="$1"
  local retention_days="$2"
  
  echo "🧹 Cleaning up backups older than ${retention_days} days..."
  
  # Find and delete old backups
  find "$backup_dir" -name "${BACKUP_PREFIX}-*.json" -type f -mtime +${retention_days} -delete 2>/dev/null || true
  
  # Keep weekly backups (Sunday) for longer
  # Keep monthly backups (1st of month) for even longer
  # This is done by git history, files are already tracked
}

# -----------------------------------------------------------------------------
# Main Backup Function
# -----------------------------------------------------------------------------

main() {
  local timestamp_human=$(date "+%d %b %Y, %H:%M:%S %z")
  local timestamp_file=$(date "+%Y%m%d-%H%M%S")
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔐 VaultWarden Backup Started"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Time: ${timestamp_human}"
  echo "Host: $(hostname -s)"
  echo ""

  # Create directories
  mkdir -p "$VERSIONS_DIR"
  
  # Retrieve credentials from Keychain
  echo "🔑 Retrieving credentials from Keychain..."
  local master_password=$(get_keychain_password "vaultwarden-backup-master")
  local backup_password=$(get_keychain_password "vaultwarden-backup-encrypt")
  
  # Configure Bitwarden server
  echo "🌐 Configuring Bitwarden server: ${BW_SERVER}"
  "$BW_COMMAND" config server "$BW_SERVER" &>/dev/null
  
  # Login to Bitwarden
  echo "🔓 Logging in to Bitwarden..."
  local bw_session
  bw_session=$("$BW_COMMAND" login "$BW_ACCOUNT" "$master_password" --raw 2>&1) || {
    # Check if already logged in
    bw_session=$("$BW_COMMAND" unlock "$master_password" --raw 2>&1) || {
      echo "❌ ERROR: Failed to login/unlock Bitwarden" >&2
      exit 1
    }
  }
  
  if [[ -z "$bw_session" ]]; then
    echo "❌ ERROR: Failed to obtain Bitwarden session token" >&2
    exit 1
  fi
  
  export BW_SESSION="$bw_session"
  
  # Sync vault (ensure latest data)
  echo "🔄 Syncing vault..."
  "$BW_COMMAND" sync --session "$BW_SESSION" &>/dev/null || {
    echo "⚠️  Warning: Sync failed, proceeding with cached data"
  }
  
  # Output files
  local output_file="$VERSIONS_DIR/${BACKUP_PREFIX}-${timestamp_file}.json"
  local current_link="$VERSIONS_DIR/${BACKUP_PREFIX}-current.json"
  
  # Export vault (ENCRYPTED)
  echo "💾 Exporting encrypted vault to: ${output_file}"
  "$BW_COMMAND" export \
    --session "$BW_SESSION" \
    --format encrypted_json \
    --password "$backup_password" \
    --output "$output_file"
  
  # Verify backup file exists and is not empty
  if [[ ! -s "$output_file" ]]; then
    echo "❌ ERROR: Backup file is missing or empty" >&2
    exit 1
  fi
  
  # Create/update symlink to latest backup
  ln -sf "$(basename "$output_file")" "$current_link"
  
  # Get file size
  local file_size=$(du -h "$output_file" | cut -f1)
  echo "✅ Backup created: ${file_size}"
  
  # Lock/logout
  echo "🔒 Locking Bitwarden session..."
  "$BW_COMMAND" lock &>/dev/null || true
  
  # Clear sensitive variables
  unset BW_SESSION
  unset master_password
  unset backup_password
  unset bw_session
  
  # Git operations
  if [[ "$GIT_PUSH_ENABLED" == "1" ]]; then
    echo "📦 Committing to Git..."
    cd "$BACKUP_DIR"
    
    git add "$output_file" "$current_link"
    
    if git diff --cached --quiet; then
      echo "ℹ️  No changes detected, skipping commit"
    else
      git commit -m "Vault backup: ${timestamp_human}" \
        -m "File: $(basename "$output_file")" \
        -m "Size: ${file_size}" \
        -m "Encrypted: Yes"
      
      echo "⬆️  Pushing to remote..."
      git push "$GIT_REMOTE" "$GIT_BRANCH" || {
        echo "⚠️  Warning: Git push failed"
      }
    fi
  fi
  
  # Cleanup old backups
  cleanup_old_backups "$VERSIONS_DIR" "$RETENTION_DAILY"
  
  # Success notification
  local success_msg="✅ *VaultWarden Backup Successful*
Host: $(hostname -s)
Time: ${timestamp_human}
Size: ${file_size}
Encrypted: Yes
File: \`$(basename "$output_file")\`"
  
  send_telegram_message "$success_msg"
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Backup completed successfully"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Run main function
main "$@"
```

Make it executable:

```zsh
chmod +x ~/bin/vaultwarden-backup.zsh
```

### 6. Test the Script

Run manually first to ensure everything works:

```zsh
~/bin/vaultwarden-backup.zsh
```

Expected output:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔐 VaultWarden Backup Started
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Time: 06 Oct 2025, 14:30:00 +0100
Host: MacBook-Pro

🔑 Retrieving credentials from Keychain...
🌐 Configuring Bitwarden server: https://pwd.oklabs.uk
🔓 Logging in to Bitwarden...
🔄 Syncing vault...
💾 Exporting encrypted vault to: versions/vault-20251006-143000.json
✅ Backup created: 24K
🔒 Locking Bitwarden session...
📦 Committing to Git...
⬆️  Pushing to remote...
🧹 Cleaning up backups older than 7 days...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Backup completed successfully
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 7. Set Up Automatic Scheduling with LaunchAgent

Create LaunchAgent plist file:

```zsh
cat > ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Job Identification -->
    <key>Label</key>
    <string>com.user.vaultwarden-backup</string>
    
    <!-- Program to Run -->
    <key>ProgramArguments</key>
    <array>
        <string>${HOME}/bin/vaultwarden-backup.zsh</string>
    </array>
    
    <!-- Schedule: Every 2 hours -->
    <key>StartInterval</key>
    <integer>7200</integer>
    
    <!-- Alternative: Run at specific times (uncomment if preferred) -->
    <!--
    <key>StartCalendarInterval</key>
    <array>
        <dict>
            <key>Hour</key>
            <integer>0</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Hour</key>
            <integer>2</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Hour</key>
            <integer>6</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Hour</key>
            <integer>9</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Hour</key>
            <integer>12</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Hour</key>
            <integer>15</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Hour</key>
            <integer>18</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Hour</key>
            <integer>21</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
    </array>
    -->
    
    <!-- Working Directory -->
    <key>WorkingDirectory</key>
    <string>${HOME}/work/vaultwarden-backups</string>
    
    <!-- Environment -->
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin</string>
        <key>HOME</key>
        <string>${HOME}</string>
    </dict>
    
    <!-- Logging -->
    <key>StandardOutPath</key>
    <string>${HOME}/Library/Logs/vaultwarden-backup.log</string>
    <key>StandardErrorPath</key>
    <string>${HOME}/Library/Logs/vaultwarden-backup-error.log</string>
    
    <!-- Resource Limits -->
    <key>Nice</key>
    <integer>1</integer>
    
    <!-- Process Options -->
    <key>ProcessType</key>
    <string>Background</string>
    
    <!-- Launch only when logged in -->
    <key>RunAtLoad</key>
    <true/>
    
    <!-- Keep alive if crash -->
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    
    <!-- Throttle restarts -->
    <key>ThrottleInterval</key>
    <integer>300</integer>
</dict>
</plist>
EOF
```

**Note**: Replace `${HOME}` with your actual home directory path if needed.

Load the LaunchAgent:

```zsh
# Load the agent
launchctl load ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist

# Verify it's loaded
launchctl list | grep vaultwarden

# Check status
launchctl print gui/$(id -u)/com.user.vaultwarden-backup
```

### 8. Manage the Backup Service

```zsh
# Start immediately (also runs on schedule)
launchctl start com.user.vaultwarden-backup

# Stop the service
launchctl stop com.user.vaultwarden-backup

# Unload (disable automatic runs)
launchctl unload ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist

# Reload after making changes
launchctl unload ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist
launchctl load ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist

# View logs
tail -f ~/Library/Logs/vaultwarden-backup.log
tail -f ~/Library/Logs/vaultwarden-backup-error.log
```

## Restore from Backup

### To restore an encrypted backup:

```zsh
cd ~/backups/vaultwarden-backups/versions

# List available backups
ls -lh vault-*.json

# Decrypt and view (requires backup password from Keychain)
BACKUP_PASSWORD=$(security find-generic-password -a "$USER" -s "vaultwarden-backup-encrypt" -w)

# Test decryption
bw import encrypted_json vault-20251006-143000.json --password "$BACKUP_PASSWORD"
```

### To import to vault:

1. **Web interface**: Settings → Vault Options → Import Items → Select "Bitwarden (json)" → Select file
2. **CLI**:
```zsh
bw config server https://pwd.oklabs.uk
bw login
bw import encrypted_json vault-20251006-143000.json
```

## Security Best Practices

### ✅ What This Setup Does Right:

1. **Encrypted Exports**: Vault backups are password-protected encrypted JSON
2. **Keychain Storage**: No plaintext passwords in files
3. **Separate Passwords**: Backup encryption password ≠ master password
4. **Git History**: Version control with full history
5. **Auto-cleanup**: Old backups removed automatically
6. **Monitoring**: Telegram notifications for success/failure
7. **Session Management**: Proper login/logout handling
8. **Error Handling**: Trap errors and notify

### ⚠️ Important Security Notes:

1. **Backup Password**: Store in a **separate secure location** (different password manager, physical safe)
2. **Git Repository**: Should be **private**. Consider additional encryption for the repo itself
3. **Keychain Access**: Protected by macOS user account login
4. **Local Storage**: `~/Documents` should be on encrypted disk (FileVault)
5. **Git Remote**: Use SSH keys or personal access tokens, never password auth

### 🔐 Additional Security Layers (Optional):

#### Option A: Encrypt entire backup directory

```zsh
# Create encrypted sparse bundle
hdiutil create -size 1g -fs "Case-sensitive APFS" \
  -volname "VaultwardenBackups" \
  -encryption AES-256 \
  -type SPARSEBUNDLE \
  ~/Documents/vaultwarden-backups.sparsebundle

# Mount it
open ~/Documents/vaultwarden-backups.sparsebundle

# Update BACKUP_DIR in config to point to mounted volume
# /Volumes/VaultwardenBackups
```

#### Option B: Use GPG encryption for Git repo

```zsh
# Encrypt files before Git commit
gpg --encrypt --recipient your@email.com vault-backup.json

# Add to git-crypt or similar
```

## Monitoring & Maintenance

### Check Backup Status

```zsh
# View recent backups
ls -lht ~/backups/vaultwarden-backups/versions/ | head -10

# Check backup sizes (look for anomalies)
du -sh ~/backups/vaultwarden-backups/versions/vault-*.json

# View git history
cd ~/backups/vaultwarden-backups
git log --oneline -10

# Check LaunchAgent status
launchctl print gui/$(id -u)/com.user.vaultwarden-backup
```

### Create Health Check Script

Save as `~/bin/vaultwarden-backup-check.zsh`:

```zsh
#!/usr/bin/env zsh
# Check backup health

VERSIONS_DIR="$HOME/work/vaultwarden-backups/versions"
LATEST=$(ls -t "$VERSIONS_DIR"/vault-*.json 2>/dev/null | head -1)

if [[ -z "$LATEST" ]]; then
  echo "❌ No backups found!"
  exit 1
fi

LATEST_TIME=$(stat -f %m "$LATEST")
NOW=$(date +%s)
DIFF=$(( (NOW - LATEST_TIME) / 3600 ))

echo "Latest backup: $(basename "$LATEST")"
echo "Age: ${DIFF} hours ago"

if (( DIFF > 6 )); then
  echo "⚠️  WARNING: Backup is older than 6 hours!"
  exit 1
else
  echo "✅ Backup is fresh"
fi
```

## Troubleshooting

### Issue: "Failed to retrieve from Keychain"

```zsh
# Re-add the password
security delete-generic-password -a "$USER" -s "vaultwarden-backup-master"
security add-generic-password -a "$USER" -s "vaultwarden-backup-master" -w "YOUR_PASSWORD" -U
```

### Issue: LaunchAgent not running

```zsh
# Check for errors
launchctl error com.user.vaultwarden-backup

# View logs
cat ~/Library/Logs/vaultwarden-backup-error.log

# Verify permissions
ls -la ~/bin/vaultwarden-backup.zsh

# Should show: -rwxr-xr-x
```

### Issue: Git push fails

```zsh
# Check git remote
cd ~/backups/vaultwarden-backups
git remote -v

# Test SSH key
ssh -T git@github.com

# Or set up credential helper
git config credential.helper osxkeychain
```

### Issue: "bw command not found"

```zsh
# Find bw location
which bw

# Update PATH in LaunchAgent plist to include brew paths
# /opt/homebrew/bin (Apple Silicon)
# /usr/local/bin (Intel)
```

## 3-2-1 Backup Strategy

To complete the 3-2-1 strategy, you have:

1. **Local encrypted backup** (this script in `~/work`) ✅
2. **Git repository** (GitHub/GitLab private repo) ✅
3. **Additional options for 3rd copy**:
   - Cloud storage: B2, S3, or Dropbox (using `rclone`)
   - Remote server: `rsync` to remote machine
   - Offline backup: Monthly export to encrypted external drive

Example for remote server sync:

```zsh
# Add to cron or create separate script
rsync -avz --delete \
  ~/backups/vaultwarden-backups/ \
  user@backup-server:/backups/vaultwarden/

# Or use B2/S3 with rclone
rclone sync ~/backups/vaultwarden-backups/ \
  b2:my-bucket/vaultwarden-backups/
```

## Performance Notes

- **Backup duration**: ~5-15 seconds for typical vault (100-500 items)
- **Storage**: ~20-50 KB per encrypted backup
- **Resource usage**: Minimal CPU/memory impact
- **Network**: Only during git push (~100KB upload)

## Next Steps

1. Test restore process quarterly
2. Document backup password storage location
3. Set up similar backup on another device
4. Consider server-side backup (next tutorial)

---

**Last Updated**: October 6, 2025  
**Tested On**: macOS Tahoe 26.0.1 (Ventura), Apple M1 Max

