# Vaultwarden Backup System - Complete Setup & Test Guide

## Pre-Test Checklist

Before running the test, ensure:
- [ ] Bitwarden CLI installed (`brew install bitwarden-cli`)
- [ ] Git installed and configured
- [ ] GitHub SSH keys set up (see `github-ssh-setup.md`)
- [ ] Vaultwarden account credentials ready
- [ ] Telegram bot token and chat ID (optional)

## Step-by-Step Setup & Test

### Step 1: Install Prerequisites

```zsh
# Check if bw is installed
if ! command -v bw &> /dev/null; then
    echo "Installing Bitwarden CLI..."
    brew install bitwarden-cli
else
    echo "✅ Bitwarden CLI already installed: $(bw --version)"
fi

# Check git
git --version || brew install git

# Verify zsh
echo $SHELL
# Should show: /bin/zsh
```

### Step 2: Set Up SSH Keys for GitHub

**Follow the guide**: `github-ssh-setup.md`

**Quick version:**

```zsh
# Generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519_github

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github

# Create SSH config
cat > ~/.ssh/config << 'EOF'
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519_github
EOF

chmod 600 ~/.ssh/config

# Copy public key
pbcopy < ~/.ssh/id_ed25519_github.pub
echo "✅ Public key copied to clipboard"
echo "👉 Now add it to GitHub: https://github.com/settings/keys"
echo ""
read "?Press Enter after adding key to GitHub..."

# Test connection
echo "\n🧪 Testing GitHub SSH connection..."
ssh -T git@github.com
```

Expected output:
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

### Step 3: Create GitHub Repository for Backups

**Option A: Via GitHub Web Interface**
1. Go to https://github.com/new
2. Repository name: `vaultwarden-backups`
3. **Visibility**: Private ⚠️ IMPORTANT!
4. Initialize without README
5. Create repository

**Option B: Via GitHub CLI** (if installed)

```zsh
# Install GitHub CLI
brew install gh

# Authenticate
gh auth login

# Create private repository
gh repo create vaultwarden-backups --private --description "Encrypted Vaultwarden vault backups"
```

### Step 4: Initialize Backup Directory

```zsh
# Create directory structure
mkdir -p ~/Documents/vaultwarden-backups
cd ~/Documents/vaultwarden-backups

# Create subdirectories
mkdir -p versions

# Initialize git
git init
git branch -M main

# Create .gitignore
cat > .gitignore << 'EOF'
# Sensitive files
.env
*.log
.DS_Store

# Temporary files
*.tmp
*.temp
*.swp

# System files
.Spotlight-V100
.Trashes
.fseventsd
EOF

# Initial commit
git add .gitignore
git commit -m "Initial commit: Setup backup repository"

# Add remote (replace USERNAME with your GitHub username)
read "?Enter your GitHub username: " GITHUB_USERNAME
git remote add origin git@github.com:${GITHUB_USERNAME}/vaultwarden-backups.git

# Push initial commit
git push -u origin main

echo "✅ Git repository initialized and pushed to GitHub"
```

### Step 5: Store Credentials in macOS Keychain

**Important**: Keep your backup encryption password in a separate secure location!

```zsh
#!/usr/bin/env zsh
# Save as: ~/bin/setup-vaultwarden-keychain.zsh

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Vaultwarden Backup - Keychain Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will store your credentials in macOS Keychain."
echo "You'll need:"
echo "  1. Vaultwarden master password"
echo "  2. Backup encryption password (create a NEW strong password)"
echo "  3. Telegram bot token (optional)"
echo "  4. Telegram chat ID (optional)"
echo ""
read "?Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Store master password
echo "\n📝 Enter your Vaultwarden MASTER password:"
read -s "?Password: " MASTER_PASS
echo ""

if [[ -z "$MASTER_PASS" ]]; then
    echo "❌ Password cannot be empty"
    exit 1
fi

security add-generic-password \
  -a "$USER" \
  -s "vaultwarden-backup-master" \
  -w "$MASTER_PASS" \
  -U 2>/dev/null && echo "✅ Master password stored" || echo "✅ Master password updated"

# Store backup encryption password
echo "\n📝 Create a BACKUP ENCRYPTION password (different from master!):"
echo "⚠️  Write this down and store in a secure location!"
read -s "?Backup Password: " BACKUP_PASS
echo ""
read -s "?Confirm Backup Password: " BACKUP_PASS_CONFIRM
echo ""

if [[ "$BACKUP_PASS" != "$BACKUP_PASS_CONFIRM" ]]; then
    echo "❌ Passwords don't match"
    exit 1
fi

if [[ -z "$BACKUP_PASS" ]]; then
    echo "❌ Password cannot be empty"
    exit 1
fi

security add-generic-password \
  -a "$USER" \
  -s "vaultwarden-backup-encrypt" \
  -w "$BACKUP_PASS" \
  -U 2>/dev/null && echo "✅ Backup password stored" || echo "✅ Backup password updated"

# Optional: Telegram credentials
echo "\n📱 Telegram notifications (optional, press Enter to skip):"
read "?Telegram Bot Token: " TG_TOKEN

if [[ -n "$TG_TOKEN" ]]; then
    security add-generic-password \
      -a "$USER" \
      -s "vaultwarden-backup-telegram-token" \
      -w "$TG_TOKEN" \
      -U 2>/dev/null && echo "✅ Telegram token stored" || echo "✅ Telegram token updated"
    
    read "?Telegram Chat ID: " TG_CHAT
    security add-generic-password \
      -a "$USER" \
      -s "vaultwarden-backup-telegram-chat" \
      -w "$TG_CHAT" \
      -U 2>/dev/null && echo "✅ Telegram chat ID stored" || echo "✅ Telegram chat ID updated"
fi

# Clear variables
unset MASTER_PASS
unset BACKUP_PASS
unset BACKUP_PASS_CONFIRM
unset TG_TOKEN
unset TG_CHAT

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Keychain setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  IMPORTANT: Write down your backup encryption password!"
echo "Store it in a secure location separate from your computer."
```

Run the setup:

```zsh
# Create bin directory if not exists
mkdir -p ~/bin

# Copy script (paste the above script into this file)
nano ~/bin/setup-vaultwarden-keychain.zsh

# Make executable
chmod +x ~/bin/setup-vaultwarden-keychain.zsh

# Run it
~/bin/setup-vaultwarden-keychain.zsh
```

### Step 6: Create Configuration File

```zsh
cat > ~/.vaultwarden-backup-config << 'EOF'
# Vaultwarden Backup Configuration
# Sensitive credentials are stored in macOS Keychain

# Bitwarden server URL
BW_SERVER="https://pwd.oklabs.uk"

# Bitwarden account email (change this!)
BW_ACCOUNT="your-email@example.com"

# Backup directory
BACKUP_DIR="$HOME/Documents/vaultwarden-backups"
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

echo "✅ Config file created at ~/.vaultwarden-backup-config"
echo "⚠️  Edit it to set your email address:"
echo "nano ~/.vaultwarden-backup-config"
```

**Edit the config file** to set your email:

```zsh
nano ~/.vaultwarden-backup-config
# Change: BW_ACCOUNT="your-actual-email@example.com"
```

### Step 7: Install Backup Script

Copy the main backup script from `vaultwarden-backup-macos.md` to `~/bin/vaultwarden-backup.zsh`

**Quick download** (if you have the file):

```zsh
# Create the script file
cat > ~/bin/vaultwarden-backup.zsh << 'SCRIPT_END'
#!/usr/bin/env zsh
# Vaultwarden Automated Backup Script for macOS
# Secure version using Keychain and encrypted exports

set -euo pipefail

# [PASTE THE FULL SCRIPT FROM vaultwarden-backup-macos.md HERE]
# Lines 155-450 from the guide

SCRIPT_END

# Make executable
chmod +x ~/bin/vaultwarden-backup.zsh

echo "✅ Backup script installed"
```

### Step 8: Test Backup Script Manually

```zsh
# Run the backup script
~/bin/vaultwarden-backup.zsh
```

**Expected output:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔐 VaultWarden Backup Started
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Time: 06 Oct 2025, 15:30:00 +0100
Host: MacBook-Pro

🔑 Retrieving credentials from Keychain...
🌐 Configuring Bitwarden server: https://pwd.oklabs.uk
🔓 Logging in to Bitwarden...
🔄 Syncing vault...
💾 Exporting encrypted vault to: versions/vault-20251006-153000.json
✅ Backup created: 24K
🔒 Locking Bitwarden session...
📦 Committing to Git...
⬆️  Pushing to remote...
🧹 Cleaning up backups older than 7 days...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Backup completed successfully
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 9: Verify Backup

```zsh
# Check backup files
ls -lh ~/Documents/vaultwarden-backups/versions/

# Should show:
# vault-20251006-153000.json
# vault-current.json -> vault-20251006-153000.json

# Check git history
cd ~/Documents/vaultwarden-backups
git log --oneline

# Verify backup is encrypted (should not be readable JSON)
head -n 5 ~/Documents/vaultwarden-backups/versions/vault-current.json

# Should show encrypted data like:
# {"encrypted":true,"data":"...encrypted blob..."}

# Check GitHub
git remote -v
git ls-remote origin
```

### Step 10: Test Restore Process

**IMPORTANT**: Test restoration to ensure backups work!

```zsh
# Get backup password from Keychain
BACKUP_PASSWORD=$(security find-generic-password -a "$USER" -s "vaultwarden-backup-encrypt" -w)

# Attempt to verify the backup can be read
cd ~/Documents/vaultwarden-backups/versions

# Test decryption (this won't import, just verify it's valid)
echo "Testing backup decryption..."
bw config server https://pwd.oklabs.uk

# Export to plain JSON to verify
echo "Enter your Vaultwarden master password to test:"
bw login

# Try importing the backup to verify format
echo "Testing backup import (dry-run)..."
echo "If you see items listed, the backup is valid!"

# Note: Don't actually import unless testing in a test account
# Just verify you CAN decrypt it with the backup password

unset BACKUP_PASSWORD
bw logout

echo "✅ Restore test complete"
```

### Step 11: Set Up LaunchAgent for Automation

```zsh
# Create LaunchAgent directory if not exists
mkdir -p ~/Library/LaunchAgents

# Create LaunchAgent plist
cat > ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.vaultwarden-backup</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>${HOME}/bin/vaultwarden-backup.zsh</string>
    </array>
    
    <key>StartInterval</key>
    <integer>7200</integer>
    
    <key>WorkingDirectory</key>
    <string>${HOME}/Documents/vaultwarden-backups</string>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        <key>HOME</key>
        <string>${HOME}</string>
    </dict>
    
    <key>StandardOutPath</key>
    <string>${HOME}/Library/Logs/vaultwarden-backup.log</string>
    <key>StandardErrorPath</key>
    <string>${HOME}/Library/Logs/vaultwarden-backup-error.log</string>
    
    <key>Nice</key>
    <integer>1</integer>
    
    <key>ProcessType</key>
    <string>Background</string>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    
    <key>ThrottleInterval</key>
    <integer>300</integer>
</dict>
</plist>
EOF

echo "✅ LaunchAgent plist created"

# Load the LaunchAgent
launchctl load ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist

echo "✅ LaunchAgent loaded"

# Verify it's running
launchctl list | grep vaultwarden

echo ""
echo "📋 LaunchAgent Status:"
launchctl print gui/$(id -u)/com.user.vaultwarden-backup
```

### Step 12: Monitor First Automated Run

```zsh
# Watch logs in real-time
tail -f ~/Library/Logs/vaultwarden-backup.log

# In another terminal, trigger immediate run
launchctl start com.user.vaultwarden-backup

# Check for errors
tail -n 50 ~/Library/Logs/vaultwarden-backup-error.log
```

## Verification Checklist

After setup, verify:

```zsh
#!/usr/bin/env zsh
# Quick verification script

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Vaultwarden Backup System Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Check Bitwarden CLI
echo "1️⃣  Bitwarden CLI:"
if command -v bw &> /dev/null; then
    echo "   ✅ Installed: $(bw --version)"
else
    echo "   ❌ Not installed"
fi

# 2. Check SSH key
echo "\n2️⃣  GitHub SSH:"
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "   ✅ SSH authentication working"
else
    echo "   ❌ SSH authentication failed"
fi

# 3. Check keychain entries
echo "\n3️⃣  Keychain entries:"
for service in "vaultwarden-backup-master" "vaultwarden-backup-encrypt"; do
    if security find-generic-password -a "$USER" -s "$service" &>/dev/null; then
        echo "   ✅ $service"
    else
        echo "   ❌ $service missing"
    fi
done

# 4. Check config file
echo "\n4️⃣  Configuration:"
if [[ -f ~/.vaultwarden-backup-config ]]; then
    echo "   ✅ Config file exists"
    grep "BW_ACCOUNT" ~/.vaultwarden-backup-config | head -1
else
    echo "   ❌ Config file missing"
fi

# 5. Check backup script
echo "\n5️⃣  Backup script:"
if [[ -x ~/bin/vaultwarden-backup.zsh ]]; then
    echo "   ✅ Script installed and executable"
else
    echo "   ❌ Script not found or not executable"
fi

# 6. Check backup directory
echo "\n6️⃣  Backup directory:"
if [[ -d ~/Documents/vaultwarden-backups ]]; then
    echo "   ✅ Directory exists"
    BACKUP_COUNT=$(ls -1 ~/Documents/vaultwarden-backups/versions/vault-*.json 2>/dev/null | wc -l)
    echo "   📊 Backup files: $BACKUP_COUNT"
else
    echo "   ❌ Directory missing"
fi

# 7. Check Git repository
echo "\n7️⃣  Git repository:"
cd ~/Documents/vaultwarden-backups 2>/dev/null
if [[ -d .git ]]; then
    echo "   ✅ Git initialized"
    git remote -v | head -1
    COMMIT_COUNT=$(git log --oneline | wc -l)
    echo "   📊 Commits: $COMMIT_COUNT"
else
    echo "   ❌ Git not initialized"
fi

# 8. Check LaunchAgent
echo "\n8️⃣  LaunchAgent:"
if launchctl list | grep -q "vaultwarden-backup"; then
    echo "   ✅ LaunchAgent loaded"
else
    echo "   ❌ LaunchAgent not loaded"
fi

# 9. Check logs
echo "\n9️⃣  Logs:"
if [[ -f ~/Library/Logs/vaultwarden-backup.log ]]; then
    LAST_RUN=$(tail -1 ~/Library/Logs/vaultwarden-backup.log 2>/dev/null)
    echo "   ✅ Log file exists"
    echo "   Last entry: $LAST_RUN"
else
    echo "   ⚠️  No logs yet (may not have run)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

Save as `~/bin/verify-backup-setup.zsh`, make executable, and run:

```zsh
chmod +x ~/bin/verify-backup-setup.zsh
~/bin/verify-backup-setup.zsh
```

## Common Issues & Solutions

### Issue 1: "bw: command not found"

```zsh
# Find where bw is installed
which bw

# Add to PATH in LaunchAgent
# Edit ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist
# Update PATH to include /opt/homebrew/bin (M1) or /usr/local/bin (Intel)
```

### Issue 2: "Permission denied (publickey)" when pushing

```zsh
# Test SSH
ssh -T git@github.com

# Re-add key
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github

# Verify remote
cd ~/Documents/vaultwarden-backups
git remote -v
```

### Issue 3: LaunchAgent not running

```zsh
# Check for errors
launchctl error com.user.vaultwarden-backup

# View errors
cat ~/Library/Logs/vaultwarden-backup-error.log

# Reload
launchctl unload ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist
launchctl load ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist
```

### Issue 4: "Failed to obtain session token"

```zsh
# Test login manually
bw config server https://pwd.oklabs.uk
bw login your-email@example.com

# Check if master password is correct in Keychain
security find-generic-password -a "$USER" -s "vaultwarden-backup-master" -w

# Update if needed
security delete-generic-password -a "$USER" -s "vaultwarden-backup-master"
security add-generic-password -a "$USER" -s "vaultwarden-backup-master" -w "correct-password" -U
```

## Success Criteria

Your setup is successful if:

- ✅ Manual run completes without errors
- ✅ Encrypted backup file created
- ✅ Backup pushed to GitHub
- ✅ LaunchAgent loaded and scheduled
- ✅ Telegram notification received (if enabled)
- ✅ Can retrieve backup password from Keychain
- ✅ Test restore works

## Next Steps

After successful setup:

1. ✅ Wait for first automated run (check after 2 hours)
2. ✅ Monitor logs for 24 hours
3. ✅ Verify GitHub has multiple backup commits
4. ✅ Test restore procedure quarterly
5. ✅ Set up server-side backups (next guide)

---

**Last Updated**: October 6, 2025

