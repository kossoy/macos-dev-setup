# NAS Auto-Mount Setup Guide

**Date:** October 5, 2025  
**Status:** ✅ Complete

---

## 🎯 Overview

Secure automatic mounting of NAS/SMB volumes using macOS Keychain and LaunchAgents. This setup provides seamless, password-less mounting of network storage at login without hardcoded credentials.

### Key Features
- 🔐 Secure credential storage in macOS Keychain
- 🚀 Automatic mounting at login via LaunchAgent
- 🔄 Network connectivity checks with retry logic
- 📝 Comprehensive logging
- 🎮 Easy management via control script
- ⚡ Fast detection of already-mounted volumes

---

## 📁 Files Overview

| File | Purpose | Location |
|------|---------|----------|
| `setup-nas-keychain.sh` | Store NAS credentials securely | `~/work/scripts/` |
| `mount-nas-volumes.sh` | Mount NAS volumes (simple) | `~/work/scripts/` |
| `mount-nas-volumes-with-retry.sh` | Mount with network checks | `~/work/scripts/` |
| `nas-mount-control.sh` | Management control script | `~/work/scripts/` |
| `com.user.mount-nas-volumes.plist` | LaunchAgent config | `~/Library/LaunchAgents/` |

---

## 🚀 Quick Start

### First Time Setup

```bash
# 1. Store your NAS password securely
~/work/scripts/setup-nas-keychain.sh

# 2. Test mounting manually
nas-mount

# 3. Enable automatic mounting at login
nas-enable
```

That's it! Your NAS volumes will now mount automatically at login. ✨

---

## 🎮 Available Commands

All commands are available as shell aliases for convenience:

```bash
# Mount commands
nas-mount              # Mount NAS volumes (quick)
nas-mount-retry        # Mount with network retry logic

# Management commands
nas-status             # Check status and view recent logs
nas-enable             # Enable auto-mount at login
nas-disable            # Disable auto-mount
nas-restart            # Restart the LaunchAgent
nas-test               # Run mount script manually
nas-logs               # View all logs
nas-tail               # Follow logs in real-time
```

---

## 📊 Configured Volumes

### TrueNAS (10.0.0.155)
- **Applications** - Application storage
- **Media** - Media files and libraries
- **WinBackup** - Windows backup storage

### Lenovo Server (10.0.0.29)
- **HomeLAB** - Home lab environment

---

## 📝 Log Files

Logs are automatically created and maintained:

- **Output:** `~/Library/Logs/mount-nas-volumes.log`
- **Errors:** `~/Library/Logs/mount-nas-volumes-error.log`

View logs in real-time:
```bash
nas-tail  # Follow the log
```

---

## 🔧 Configuration

### Change Volumes to Mount

Edit `~/work/scripts/mount-nas-volumes.sh`:

```bash
# TrueNAS volumes
TRUENAS_VOLUMES=("Applications" "Media" "WinBackup" "NewVolume")

# Lenovo volumes  
LENOVO_VOLUMES=("HomeLAB" "AnotherShare")
```

### Change IP Addresses

```bash
TRUENAS_IP="10.0.0.155"
LENOVO_IP="10.0.0.29"
```

### Change Username

```bash
NAS_USERNAME="user"
```

**Important:** If you change the username, you must re-run `setup-nas-keychain.sh` with the new username.

### Update Password

Simply re-run the setup script:
```bash
~/work/scripts/setup-nas-keychain.sh
```

---

## 🔍 Troubleshooting

### Volumes Not Mounting at Login

1. **Check LaunchAgent status:**
   ```bash
   nas-status
   ```

2. **View recent logs:**
   ```bash
   nas-logs
   ```

3. **Test manually:**
   ```bash
   nas-test
   ```

### Password Not Found Error

Re-run the credential setup:
```bash
~/work/scripts/setup-nas-keychain.sh
```

### Network Not Ready at Login

The retry version handles this automatically. If issues persist:
```bash
# Use the retry version which waits for network
~/work/scripts/mount-nas-volumes-with-retry.sh
```

### Mount Failed Error

**Common causes and solutions:**

1. **NAS not reachable:**
   ```bash
   ping 10.0.0.155
   ```

2. **NAS powered off:**
   - Check if NAS is running
   - Verify network connection

3. **Wrong volume name:**
   - Volume names are case-sensitive
   - Verify exact name on NAS

4. **Test from Finder:**
   - Press `⌘K`
   - Enter: `smb://10.0.0.155`
   - Verify volumes are accessible

### Checking Keychain Credentials

Verify password is stored correctly:
```bash
security find-generic-password -a "user" -s "NAS_Credentials" -w
```

---

## 🔒 Security Features

### What's Secure ✅

- Password stored in macOS Keychain (encrypted)
- Password cleared from memory after use
- Never hardcoded in scripts
- Logs don't contain passwords
- Proper file permissions (644 for plist, 755 for scripts)
- Keychain access limited to user only

### Security Best Practices

1. **Never commit credentials to Git:**
   - Keychain credentials are safe (system-level)
   - Scripts contain no secrets

2. **Verify file permissions:**
   ```bash
   ls -la ~/work/scripts/mount-nas-volumes.sh
   ls -la ~/Library/LaunchAgents/com.user.mount-nas-volumes.plist
   ```

3. **Regular password rotation:**
   ```bash
   # Update NAS password when it changes
   ~/work/scripts/setup-nas-keychain.sh
   ```

---

## 🎯 How It Works

### Automatic Mount Process

1. **At Login:** LaunchAgent starts automatically
2. **Network Check:** Verifies NAS is reachable (retry version)
3. **Keychain Access:** Retrieves password securely
4. **Volume Detection:** Checks which volumes are already mounted
5. **Mounting:** Only mounts volumes that aren't already present
6. **Cleanup:** Clears password from memory
7. **Logging:** Records results to log files
8. **Notification:** Displays completion notification

### LaunchAgent Behavior

- Runs once at login (`LaunchOnlyOnce=true`)
- Exits after completion (doesn't stay running)
- Will run again at next login
- Logs output for debugging

---

## 📚 Advanced Usage

### Run on a Schedule

Edit the LaunchAgent plist to run periodically:

```bash
# Edit the plist
nano ~/Library/LaunchAgents/com.user.mount-nas-volumes.plist

# Add this key:
<key>StartInterval</key>
<integer>3600</integer>  <!-- Every hour -->
```

Then restart:
```bash
nas-restart
```

### Run on Network Change

Automatically remount when network state changes:

```bash
# Add to plist:
<key>WatchPaths</key>
<array>
    <string>/Library/Preferences/SystemConfiguration</string>
</array>
```

### Integration with Other Scripts

Source credentials in your own scripts:

```bash
#!/bin/bash
# Get NAS password from Keychain
NAS_PASSWORD=$(security find-generic-password -a "user" -s "NAS_Credentials" -w 2>/dev/null)

if [[ -n "$NAS_PASSWORD" ]]; then
    # Use password for your operations
    echo "Password retrieved successfully"
fi

# Always clear sensitive data
unset NAS_PASSWORD
```

---

## 🛠️ Maintenance

### Regular Tasks

```bash
# Check status
nas-status

# View logs
nas-logs

# Test mounting
nas-test

# Update password (when changed on NAS)
~/work/scripts/setup-nas-keychain.sh
```

### Updating Configuration

After modifying scripts or configuration:

```bash
# Restart the LaunchAgent to apply changes
nas-restart
```

### Backing Up Configuration

```bash
# Backup LaunchAgent and scripts
cd ~
tar -czf nas-mount-backup-$(date +%Y%m%d).tar.gz \
    work/scripts/mount-nas-volumes*.sh \
    work/scripts/nas-mount-control.sh \
    work/scripts/setup-nas-keychain.sh \
    Library/LaunchAgents/com.user.mount-nas-volumes.plist
```

---

## 🆘 Getting Help

### Diagnostic Commands

```bash
# Check LaunchAgent is installed
ls -la ~/Library/LaunchAgents/com.user.mount-nas-volumes.plist

# Check scripts exist
ls -la ~/work/scripts/mount-nas-volumes*.sh

# Verify credentials in Keychain
security find-generic-password -a "user" -s "NAS_Credentials"

# Check currently mounted volumes
ls /Volumes/

# Check LaunchAgent logs
cat ~/Library/Logs/mount-nas-volumes.log
cat ~/Library/Logs/mount-nas-volumes-error.log

# Test network connectivity
ping -c 3 10.0.0.155
ping -c 3 10.0.0.29
```

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| "Password not found" | Run `setup-nas-keychain.sh` |
| Mount fails silently | Check `nas-logs` for errors |
| LaunchAgent not running | Run `nas-enable` |
| Network timeout | Use `mount-nas-volumes-with-retry.sh` |
| Volume already mounted | This is normal; script detects it |
| Permission denied | Verify NAS user has access rights |

---

## 📖 Related Documentation

- [Scripts Integration Guide](./scripts-integration.md) - Overview of all utility scripts
- [System Setup](../setup/01-system-setup.md) - Initial macOS configuration
- [Security Monitoring](../setup/12-security-monitoring.md) - Security best practices

---

## 🎉 Summary

You now have a production-ready NAS auto-mount system that:

✅ Stores credentials securely in macOS Keychain  
✅ Automatically mounts volumes at login  
✅ Handles network delays gracefully  
✅ Provides comprehensive logging  
✅ Offers easy management via shell aliases  
✅ Follows security best practices  
✅ Includes robust error handling  

**Total Setup Time:** ~5 minutes  
**Maintenance Required:** Minimal (only when passwords change)  
**Security Level:** High (no hardcoded credentials)

Enjoy seamless NAS access! 🚀

---

**Created:** October 5, 2025  
**Last Updated:** October 5, 2025  
**Author:** AI Assistant  
**Version:** 1.0
