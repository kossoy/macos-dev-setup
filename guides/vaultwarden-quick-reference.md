# Vaultwarden Backup - Quick Reference Card

## 🚀 Quick Commands

### Backup Operations
```zsh
# Manual backup
~/bin/vaultwarden-backup.zsh

# Or using alias
vw-backup
```

### Monitoring
```zsh
# Quick status
vw-monitor

# Full detailed report
vw-monitor --full

# With statistics
vw-monitor --full --stats

# Watch mode (refreshes every 30s)
watch -n 30 vw-monitor
```

### LaunchAgent Management
```zsh
# Start backup now
launchctl start com.user.vaultwarden-backup

# Stop service
launchctl stop com.user.vaultwarden-backup

# Reload after changes
launchctl unload ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist
launchctl load ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist

# Check status
launchctl list | grep vaultwarden
```

### View Logs
```zsh
# Follow backup log
tail -f ~/Library/Logs/vaultwarden-backup.log

# View errors
tail -f ~/Library/Logs/vaultwarden-backup-error.log

# Last 50 lines
tail -n 50 ~/Library/Logs/vaultwarden-backup.log
```

### Backup Files
```zsh
# List backups (newest first)
ls -lht ~/backups/vaultwarden-backups/versions/

# Show latest backup
ls -lht ~/backups/vaultwarden-backups/versions/ | head -1

# Count backups
ls -1 ~/backups/vaultwarden-backups/versions/vault-*.json | wc -l

# Check backup sizes
du -sh ~/backups/vaultwarden-backups/versions/
```

### Git Operations
```zsh
cd ~/backups/vaultwarden-backups

# View commit history
git log --oneline -10

# Check status
git status

# View changes
git diff

# Push manually
git push origin main

# View remote
git remote -v
```

## 🔑 Keychain Access

### Retrieve Passwords
```zsh
# Get master password
security find-generic-password -a "$USER" -s "vaultwarden-backup-master" -w

# Get backup encryption password
security find-generic-password -a "$USER" -s "vaultwarden-backup-encrypt" -w

# Get Telegram token
security find-generic-password -a "$USER" -s "vaultwarden-backup-telegram-token" -w
```

### Update Passwords
```zsh
# Update master password
security delete-generic-password -a "$USER" -s "vaultwarden-backup-master"
security add-generic-password -a "$USER" -s "vaultwarden-backup-master" -w "NEW_PASSWORD" -U

# Update backup encryption password
security delete-generic-password -a "$USER" -s "vaultwarden-backup-encrypt"
security add-generic-password -a "$USER" -s "vaultwarden-backup-encrypt" -w "NEW_PASSWORD" -U
```

## 🔧 Troubleshooting

### Backup Not Running
```zsh
# Check if LaunchAgent is loaded
launchctl list | grep vaultwarden

# Check for errors
launchctl error com.user.vaultwarden-backup

# View error log
cat ~/Library/Logs/vaultwarden-backup-error.log

# Reload LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist
launchctl load ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist
```

### Git Push Fails
```zsh
# Test SSH
ssh -T git@github.com

# Re-add SSH key
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github

# Check remote
cd ~/backups/vaultwarden-backups
git remote -v

# Update remote to use SSH
git remote set-url origin git@github.com:USERNAME/vaultwarden-backups.git
```

### Backup Password Not Working
```zsh
# Verify password exists
security find-generic-password -a "$USER" -s "vaultwarden-backup-encrypt"

# Re-add if needed
security delete-generic-password -a "$USER" -s "vaultwarden-backup-encrypt"
security add-generic-password -a "$USER" -s "vaultwarden-backup-encrypt" -w "YOUR_PASSWORD" -U
```

### bw Command Not Found
```zsh
# Find bw location
which bw

# Install if missing
brew install bitwarden-cli

# Add to PATH in LaunchAgent
# Edit ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist
# Update PATH to include /opt/homebrew/bin or /usr/local/bin
```

## 📊 Health Check Checklist

```zsh
# 1. Check backup age
ls -lht ~/backups/vaultwarden-backups/versions/ | head -1

# 2. Verify credentials
for s in "vaultwarden-backup-master" "vaultwarden-backup-encrypt"; do
  security find-generic-password -a "$USER" -s "$s" &>/dev/null && echo "✅ $s" || echo "❌ $s"
done

# 3. Check LaunchAgent
launchctl list | grep vaultwarden

# 4. Test Bitwarden CLI
bw config server https://pwd.oklabs.uk
bw status

# 5. Check git sync
cd ~/backups/vaultwarden-backups
git fetch && git status

# 6. Check disk space
df -h ~/backups/vaultwarden-backups

# Or use monitor
vw-monitor --full
```

## 🔄 Restore Quick Steps

### Restore Single Item
1. Find backup: `ls -lht ~/backups/vaultwarden-backups/versions/`
2. Go to https://pwd.oklabs.uk
3. Settings → Vault options → Import items
4. Select file, enter backup password
5. Import

### Restore Full Vault
```zsh
# Get backup password
BACKUP_PASSWORD=$(security find-generic-password -a "$USER" -s "vaultwarden-backup-encrypt" -w)

# Configure and login
bw config server https://pwd.oklabs.uk
bw login your-email@example.com

# Import backup
cd ~/backups/vaultwarden-backups/versions
bw import bitwardenjson vault-20251006-143000.json --password "$BACKUP_PASSWORD"

# Sync
bw sync
```

## 📁 Important File Locations

```
Configuration:
  ~/.vaultwarden-backup-config

Scripts:
  ~/bin/vaultwarden-backup.zsh
  ~/bin/vaultwarden-backup-monitor.zsh

LaunchAgent:
  ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist

Logs:
  ~/Library/Logs/vaultwarden-backup.log
  ~/Library/Logs/vaultwarden-backup-error.log

Backups:
  ~/backups/vaultwarden-backups/
  ~/backups/vaultwarden-backups/versions/

SSH Keys:
  ~/.ssh/id_ed25519_github
  ~/.ssh/id_ed25519_github.pub
  ~/.ssh/config

Documentation:
  ~/work/docs/guides/vaultwarden-*.md
```

## 🆘 Emergency Contacts

**Backup Issues**:
- Check monitoring: `vw-monitor --full`
- View logs: `tail -f ~/Library/Logs/vaultwarden-backup.log`

**Lost Master Password**:
- Cannot recover from encrypted backups
- Server admin cannot help (zero-knowledge encryption)

**Lost Backup Password**:
- Cannot decrypt backup exports
- Check secure storage location (safe, etc.)

**Server Down**:
- User-level backups still accessible
- Import to temporary Bitwarden instance

## 📈 Maintenance Commands

```zsh
# Weekly: Check backup health
vw-monitor --full

# Monthly: Test restore
cd ~/backups/vaultwarden-backups/versions
LATEST=$(ls -t vault-*.json | head -1)
echo "Latest backup: $LATEST"
# Then test import via web interface

# Quarterly: Full system check
vw-monitor --full --stats
tail -n 100 ~/Library/Logs/vaultwarden-backup.log
git log --oneline -20

# Annually: Rotate SSH keys
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519_github_2025
# Add new key to GitHub
# Update ~/.ssh/config
# Remove old key from GitHub
```

## 🔗 Useful URLs

- Vaultwarden Server: https://pwd.oklabs.uk
- GitHub Settings (SSH keys): https://github.com/settings/keys
- Bitwarden CLI Docs: https://bitwarden.com/help/cli/
- Documentation Index: `~/work/docs/guides/vaultwarden-backup-index.md`

---

**Print this page** for quick reference during emergencies!

**Last Updated**: October 6, 2025

