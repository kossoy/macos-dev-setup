# Security & Monitoring Tools

Complete setup for security, monitoring, and backup solutions.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Homebrew installed

## 1. Password Managers

### Bitwarden

```bash
# Install Bitwarden CLI
brew install bitwarden-cli

# Login
bw login

# Unlock vault
bw unlock

# Get password
bw get password example.com

# Sync vault
bw sync
```

### 1Password

```bash
# Install 1Password
brew install --cask 1password

# Launch
open -a 1Password
```

## 2. Security Scanning Tools

### nmap (Network Scanner)

```bash
# Install nmap
brew install nmap

# Scan host
nmap example.com

# Scan ports
nmap -p 1-65535 example.com

# Service detection
nmap -sV example.com
```

### Wireshark (Network Analyzer)

```bash
# Install Wireshark
brew install --cask wireshark

# Launch
open -a Wireshark
```

## 3. System Monitoring

### htop (Process Viewer)

```bash
# Install htop
brew install htop

# Run
htop

# Keyboard shortcuts:
# - F5: Tree view
# - F9: Kill process
# - F10: Quit
```

### iotop (I/O Monitor)

```bash
# Install iotop
brew install iotop

# Run (requires sudo)
sudo iotop
```

### nethogs (Network Monitor)

```bash
# Install nethogs
brew install nethogs

# Run (requires sudo)
sudo nethogs
```

## 4. Network Tools

### tcpdump (Packet Analyzer)

```bash
# List interfaces
tcpdump -D

# Capture on interface
sudo tcpdump -i en0

# Save to file
sudo tcpdump -i en0 -w capture.pcap

# Read from file
tcpdump -r capture.pcap
```

### netcat (Network Utility)

```bash
# Install netcat (already on macOS)
# Listen on port
nc -l 1234

# Connect to port
nc example.com 80

# Port scanning
nc -zv example.com 80-100
```

## 5. Backup Solutions

### Time Machine

macOS built-in backup solution:

1. Connect external drive
2. System Settings → General → Time Machine
3. Select backup disk
4. Enable automatic backups

### Bitwarden Vault Backup

Automated backup script already available:

```bash
# Setup (configure credentials first)
editapi

# Add:
export BW_COMMAND="/usr/local/bin/bw"
export BW_SERVER="https://vault.yourdomain.com"
export BW_ACCOUNT="your-email@example.com"
export BW_PASS="your-password"

# Run backup
~/work/scripts/vault-backup.sh

# Automate with cron
crontab -e
# Add: 0 2 * * * ~/work/scripts/vault-backup.sh
```

### Configuration Backups

```bash
# Backup zsh configs
tar -czf ~/backups/zsh-config-$(date +%Y%m%d).tar.gz \
  ~/.config/zsh \
  ~/.zshrc

# Backup projects
tar -czf ~/backups/projects-$(date +%Y%m%d).tar.gz \
  ~/work/projects

# Backup to remote
rsync -avz ~/work/ user@backup-server:/backups/work/
```

## 6. Credential Management

### Environment Variables

```bash
# Store in secure file
editapi

# File: ~/.config/zsh/api-keys.zsh
# Permissions: 600 (read/write by owner only)
chmod 600 ~/.config/zsh/api-keys.zsh
```

### macOS Keychain

```bash
# Add password to Keychain
security add-generic-password \
  -a "username" \
  -s "service-name" \
  -w "password"

# Get password from Keychain
security find-generic-password \
  -a "username" \
  -s "service-name" \
  -w

# NAS Keychain setup (secure NAS passwords)
~/work/scripts/setup-nas-keychain.sh
```

## 7. Firewall Configuration

### macOS Firewall

```bash
# Enable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Set logging mode
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on

# Block all incoming connections
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setblockall on

# Allow specific app
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /Applications/MyApp.app

# Check status
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

## 8. Security Best Practices

### 1. Keep System Updated

```bash
# Check for updates
softwareupdate -l

# Install all updates
sudo softwareupdate -i -a
```

### 2. Use FileVault

Enable full disk encryption:
1. System Settings → Privacy & Security
2. FileVault → Turn On

### 3. Use Strong Passwords

- Minimum 16 characters
- Use password manager
- Enable 2FA everywhere

### 4. Regular Backups

- Time Machine (hourly)
- Cloud backup (daily)
- Off-site backup (weekly)

### 5. Firewall Enabled

Keep macOS firewall enabled and configured.

### 6. Secure SSH

```bash
# Generate strong SSH key
ssh-keygen -t ed25519 -a 100

# Disable password authentication (server-side)
# /etc/ssh/sshd_config:
# PasswordAuthentication no
# PubkeyAuthentication yes
```

### 7. Audit Permissions

```bash
# Check file permissions
ls -la ~/work/

# Fix overly permissive files
chmod 600 ~/.config/zsh/api-keys.zsh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
```

## 9. Monitoring Scripts

### System Health Check

```bash
# Create health check script
cat > ~/work/scripts/system-health.sh << 'EOF'
#!/bin/bash

echo "System Health Report - $(date)"
echo "================================"

echo -e "\nCPU Usage:"
top -l 1 | grep "CPU usage"

echo -e "\nMemory Usage:"
vm_stat | head -5

echo -e "\nDisk Usage:"
df -h | grep -E "(Filesystem|/dev/)"

echo -e "\nNetwork Connections:"
netstat -an | grep ESTABLISHED | wc -l

echo -e "\nDocker Status:"
docker ps --format "table {{.Names}}\t{{.Status}}"

echo -e "\nFailed Login Attempts:"
grep "Failed" /var/log/system.log | tail -5
EOF

chmod +x ~/work/scripts/system-health.sh
```

## 10. Logging

### Centralized Logging

```bash
# View system logs
log show --predicate 'eventMessage contains "error"' --last 1h

# View Docker logs
docker logs container-name

# Save logs
log show --last 24h > ~/logs/system-$(date +%Y%m%d).log
```

## 11. Security Checklist

- [ ] FileVault enabled
- [ ] Firewall enabled
- [ ] Time Machine configured
- [ ] Password manager installed
- [ ] SSH keys generated
- [ ] 2FA enabled on accounts
- [ ] Secure credential storage (api-keys.zsh chmod 600)
- [ ] NAS credentials in Keychain
- [ ] Regular backups automated
- [ ] System updates automated

## Next Steps

Continue with:
- **[Maintenance](../reference/troubleshooting.md)** - Keep system healthy
- **[Backup Strategy](../guides/scripts-integration.md)** - Automated backups

---

**Estimated Time**: 30 minutes  
**Difficulty**: Intermediate  
**Last Updated**: October 5, 2025
