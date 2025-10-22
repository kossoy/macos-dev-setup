# Vaultwarden Backup System - Complete Documentation

## 📚 Table of Contents

Complete documentation for backing up your self-hosted Vaultwarden instance at `https://pwd.oklabs.uk`.

### 🎯 Quick Start Guides

1. **[GitHub SSH Setup](github-ssh-setup.md)**  
   Set up SSH keys for secure GitHub authentication (required first)

2. **[macOS Automated Backup Setup](vaultwarden-backup-macos.md)**  
   Main guide for setting up encrypted, automated user-level backups every 2-3 hours

3. **[Migrate from Plain Text to Encrypted](vaultwarden-migrate-to-encrypted.md)** 🔒  
   **If you have existing plain text backups** - Secure migration guide

4. **[Complete Setup & Testing](vaultwarden-backup-test.md)**  
   Step-by-step walkthrough to install and test the entire backup system

### 🖥️ Server-Side Backups

5. **[Server Backup Guide (TrueNAS)](vaultwarden-server-backup.md)**  
   Database and full data backups for your TrueNAS Vaultwarden service

### 🔄 Restore & Recovery

6. **[Restore Procedures](vaultwarden-restore-procedures.md)**  
   Complete disaster recovery guide for all scenarios

### 📊 Monitoring

7. **[Monitoring Dashboard](vaultwarden-monitoring.md)**  
   Health monitoring, alerting, and reporting system

---

## 🚀 Quick Setup (TL;DR)

### For User-Level Backups (macOS)

```zsh
# 1. Install dependencies
brew install bitwarden-cli git

# 2. Set up SSH keys
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519_github
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github
# Add public key to GitHub: https://github.com/settings/keys

# 3. Create backup repository on GitHub (private!)
# Then clone it:
mkdir -p ~/Documents/vaultwarden-backups
cd ~/Documents/vaultwarden-backups
git init
git remote add origin git@github.com:USERNAME/vaultwarden-backups.git

# 4. Store credentials in Keychain
security add-generic-password -a "$USER" -s "vaultwarden-backup-master" -w "YOUR_MASTER_PASSWORD" -U
security add-generic-password -a "$USER" -s "vaultwarden-backup-encrypt" -w "STRONG_BACKUP_PASSWORD" -U

# 5. Create config
cat > ~/.vaultwarden-backup-config << 'EOF'
BW_SERVER="https://pwd.oklabs.uk"
BW_ACCOUNT="your-email@example.com"
BACKUP_DIR="$HOME/Documents/vaultwarden-backups"
VERSIONS_DIR="$BACKUP_DIR/versions"
RETENTION_DAILY=7
TELEGRAM_ENABLED=1
GIT_PUSH_ENABLED=1
GIT_REMOTE="origin"
GIT_BRANCH="main"
BACKUP_PREFIX="vault"
EOF

# 6. Copy backup script
mkdir -p ~/bin
cp ~/work/docs/scripts/vaultwarden-backup.zsh ~/bin/
chmod +x ~/bin/vaultwarden-backup.zsh

# 7. Test manual backup
~/bin/vaultwarden-backup.zsh

# 8. Set up LaunchAgent for automation
cp ~/work/docs/guides/vaultwarden-backup-macos.md  # See guide for plist file
launchctl load ~/Library/LaunchAgents/com.user.vaultwarden-backup.plist

# 9. Install monitor
cp ~/work/docs/scripts/vaultwarden-backup-monitor.zsh ~/bin/
chmod +x ~/bin/vaultwarden-backup-monitor.zsh

# 10. Check status
~/bin/vaultwarden-backup-monitor.zsh --full
```

### For Server-Level Backups (TrueNAS)

```bash
# 1. Create backup scripts on TrueNAS
mkdir -p /mnt/pool/scripts

# 2. Create database backup script
# See vaultwarden-server-backup.md for full script

# 3. Set up cron job via TrueNAS UI
# Tasks → Cron Jobs → Add
# Schedule: Every 6 hours
# Command: /mnt/pool/scripts/vaultwarden-db-backup.sh

# 4. Set up ZFS snapshots
# Storage → Snapshots → Add Periodic Snapshot Task

# 5. Configure off-site sync (optional)
# Install rclone and configure cloud storage
```

---

## 📖 Documentation by Use Case

### I need to...

**Set up automated backups for the first time**  
→ Follow: [Setup & Testing Guide](vaultwarden-backup-test.md)

**Backup my personal vault data (user)**  
→ Use: [macOS Automated Backup](vaultwarden-backup-macos.md)

**Backup the entire server database (admin)**  
→ Use: [Server Backup Guide](vaultwarden-server-backup.md)

**Restore a deleted item**  
→ See: [Restore Procedures - Scenario 1](vaultwarden-restore-procedures.md#scenario-1-restore-individual-items)

**Recover from server crash**  
→ See: [Restore Procedures - Scenario 4](vaultwarden-restore-procedures.md#scenario-4-complete-server-failure)

**Monitor backup health**  
→ Use: [Monitoring Dashboard](vaultwarden-monitoring.md)

**Set up GitHub for backups**  
→ Follow: [GitHub SSH Setup](github-ssh-setup.md)

---

## 🎯 Backup Strategy Overview

### User-Level (Client-Side)

**What**: Encrypted vault exports  
**Frequency**: Every 2-3 hours (automated)  
**Format**: Encrypted JSON  
**Storage**: Local + GitHub + iCloud (optional)  
**Retention**: 7 days local, forever in Git history

**Pros**:
- ✅ Under your control
- ✅ Encrypted with separate password
- ✅ Version history via Git
- ✅ Works even if server is down

**Cons**:
- ❌ Requires master password to export
- ❌ Doesn't include server config
- ❌ Manual setup required

### Server-Level (Database Backups)

**What**: SQLite database + attachments  
**Frequency**: Every 6 hours (database), daily (full)  
**Format**: Compressed SQLite files + tar.gz  
**Storage**: TrueNAS local + off-site  
**Retention**: 30 days (DB), 14 days (full)

**Pros**:
- ✅ Complete server state
- ✅ Faster restoration
- ✅ Includes all users
- ✅ Includes RSA keys

**Cons**:
- ❌ Requires server access
- ❌ Needs service downtime for consistent backup
- ❌ Larger storage requirements

### Recommended: Both!

Implement **3-2-1 backup strategy**:
- **3** copies of data
- **2** different media types
- **1** off-site copy

```
User Exports (Local Mac)
    ↓
User Exports (GitHub)
    ↓
Server DB (TrueNAS Local)
    ↓
Server DB (Remote/Cloud)
    ↓
ZFS Snapshots (TrueNAS)
```

---

## 🔧 Available Scripts

### Location: `~/work/docs/scripts/`

1. **`vaultwarden-backup.zsh`**  
   Main backup script (user-level, encrypted exports)
   
2. **`vaultwarden-backup-monitor.zsh`**  
   Monitoring dashboard with health scoring

### Installation

```zsh
# Copy to your bin directory
mkdir -p ~/bin
cp ~/work/docs/scripts/*.zsh ~/bin/
chmod +x ~/bin/*.zsh

# Add to PATH if not already (in ~/.zshrc)
export PATH="$HOME/bin:$PATH"

# Create aliases
echo 'alias vw-backup="~/bin/vaultwarden-backup.zsh"' >> ~/.zshrc
echo 'alias vw-monitor="~/bin/vaultwarden-backup-monitor.zsh"' >> ~/.zshrc
source ~/.zshrc
```

---

## 📊 Feature Comparison

| Feature | User Backup | Server Backup |
|---------|-------------|---------------|
| **Encryption** | ✅ Yes (password) | ❌ No (filesystem) |
| **Automated** | ✅ LaunchAgent | ✅ Cron/Timer |
| **Git Version Control** | ✅ Yes | ❌ No |
| **Includes Attachments** | ❌ No | ✅ Yes |
| **Includes Config** | ❌ No | ✅ Yes |
| **Server Access Required** | ❌ No | ✅ Yes |
| **Works Offline** | ❌ No | ✅ Yes |
| **Multi-User** | ❌ Single user | ✅ All users |
| **Point-in-Time Recovery** | ✅ Git history | ✅ Snapshots |
| **Restore Time** | ~5 min | ~30 min |

---

## 🔒 Security Best Practices

### Critical Security Rules

1. **✅ ALWAYS use different passwords**  
   - Master password ≠ Backup encryption password
   - Store backup password separately (safe, password manager)

2. **✅ ALWAYS use private repositories**  
   - GitHub backups must be private
   - Review repository permissions regularly

3. **✅ ALWAYS encrypt off-site backups**  
   - Use encrypted JSON format for user backups
   - Encrypt server backups before cloud upload

4. **✅ NEVER commit plaintext passwords**  
   - Use Keychain for credentials
   - Use environment files (not in Git)
   - Use SSH keys (not passwords)

5. **✅ ALWAYS test restore procedures**  
   - Monthly: Test database restore
   - Quarterly: Full disaster recovery drill

### Secure Storage Recommendations

**Master Password**:
- Primary: Your memory
- Backup: Written in safe/safety deposit box
- Emergency: Trusted family member (sealed envelope)

**Backup Encryption Password**:
- Primary: Separate password manager
- Backup: Encrypted note in different location
- Emergency: Trusted contact with sealed instructions

**SSH Keys**:
- Protected by macOS Keychain
- Backed up to encrypted external drive
- Never stored in cloud unencrypted

---

## 🆘 Emergency Procedures

### Lost Access Scenarios

**1. Lost Master Password**  
→ Cannot recover from encrypted backups  
→ Server admin cannot help (zero-knowledge encryption)  
→ Use emergency access contacts if set up

**2. Lost Backup Encryption Password**  
→ Cannot decrypt backup exports  
→ Server-level backups still accessible  
→ Use plain JSON export if recently made

**3. Server Completely Down**  
→ Use user-level backups to access data  
→ Import to new Vaultwarden instance  
→ Or use official Bitwarden cloud temporarily

**4. Corrupted Database**  
→ Restore from latest server backup  
→ Or restore from ZFS snapshot  
→ Users can reimport from their backups

---

## 📞 Support & Troubleshooting

### Common Issues

**Issue**: Backup not running automatically  
**Solution**: Check LaunchAgent status in [monitoring guide](vaultwarden-monitoring.md)

**Issue**: Git push fails  
**Solution**: Verify SSH keys in [GitHub SSH guide](github-ssh-setup.md)

**Issue**: Backup password not working  
**Solution**: Check Keychain credentials

**Issue**: Database restore fails  
**Solution**: See [restore procedures](vaultwarden-restore-procedures.md)

### Getting Help

1. Check monitoring dashboard: `vw-monitor --full`
2. Review logs: `tail -f ~/Library/Logs/vaultwarden-backup.log`
3. Test manually: `~/bin/vaultwarden-backup.zsh`
4. Review specific guide for your issue

---

## 📈 Maintenance Schedule

### Daily
- ✅ Automated backups run (every 2-3 hours)
- ✅ Monitoring checks (automated)

### Weekly
- ⚠️ Review backup logs
- ⚠️ Check monitoring dashboard
- ⚠️ Verify Git sync

### Monthly
- 🔧 Test restore procedure
- 🔧 Review backup sizes
- 🔧 Check disk space
- 🔧 Update documentation if needed

### Quarterly
- 🔧 Full disaster recovery drill
- 🔧 Review and rotate SSH keys
- 🔧 Update software (bw CLI, scripts)
- 🔧 Test off-site backups

### Annually
- 🔧 Comprehensive security audit
- 🔧 Review and update procedures
- 🔧 Test all documented scenarios
- 🔧 Update emergency contacts

---

## 📝 Checklist: New Setup

Complete these in order:

- [ ] 1. Install prerequisites (brew, bw, git)
- [ ] 2. Generate SSH keys for GitHub
- [ ] 3. Create private GitHub repository
- [ ] 4. Store credentials in Keychain
- [ ] 5. Create configuration file
- [ ] 6. Copy backup script to ~/bin
- [ ] 7. Test manual backup
- [ ] 8. Set up LaunchAgent
- [ ] 9. Verify first automated run
- [ ] 10. Install monitoring dashboard
- [ ] 11. Test restore procedure
- [ ] 12. Document emergency passwords
- [ ] 13. Set up server-side backups (admin)
- [ ] 14. Configure off-site storage
- [ ] 15. Schedule maintenance reminders

---

## 📚 Related Documentation

- [Main Repository README](../README.md)
- [Obsidian GitHub Sync](obsidian-github-sync.md)
- [Git Configuration](../setup/09-git-configuration.md)

---

**Last Updated**: October 6, 2025  
**Vaultwarden Server**: https://pwd.oklabs.uk  
**Documentation Version**: 1.0.0

**Maintainer**: Document owner  
**Review Frequency**: Quarterly  
**Next Review**: January 6, 2026

