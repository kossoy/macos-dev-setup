# GitHub SSH Key Setup for macOS

## Overview

Set up SSH keys for secure, passwordless GitHub authentication for your Vaultwarden backup repository.

## Quick Setup

### 1. Check for Existing SSH Keys

```zsh
ls -la ~/.ssh
```

Look for:
- `id_ed25519` and `id_ed25519.pub` (recommended)
- `id_rsa` and `id_rsa.pub` (older)

### 2. Generate New SSH Key (if needed)

```zsh
# Generate ED25519 key (recommended for security)
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519_github

# Or RSA if ED25519 not supported
ssh-keygen -t rsa -b 4096 -C "your-email@example.com" -f ~/.ssh/id_rsa_github
```

When prompted:
- **Enter file**: Press Enter (uses default) or specify custom name
- **Enter passphrase**: Use a strong passphrase (optional but recommended)
- **Re-enter passphrase**: Confirm

### 3. Add SSH Key to ssh-agent

```zsh
# Start the ssh-agent
eval "$(ssh-agent -s)"

# Add to macOS Keychain for automatic loading
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github

# Or for RSA
ssh-add --apple-use-keychain ~/.ssh/id_rsa_github
```

### 4. Configure SSH Config File

Create or edit `~/.ssh/config`:

```zsh
cat > ~/.ssh/config << 'EOF'
# GitHub configuration
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519_github
  
# Optional: Different key for work vs personal
Host github-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work
  AddKeysToAgent yes
  UseKeychain yes

Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
  AddKeysToAgent yes
  UseKeychain yes
EOF

# Set correct permissions
chmod 600 ~/.ssh/config
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519_github
chmod 644 ~/.ssh/id_ed25519_github.pub
```

### 5. Copy Public Key to Clipboard

```zsh
# ED25519
pbcopy < ~/.ssh/id_ed25519_github.pub

# Or RSA
pbcopy < ~/.ssh/id_rsa_github.pub

# Or display it
cat ~/.ssh/id_ed25519_github.pub
```

### 6. Add SSH Key to GitHub

**Option A: Automatic Upload with GitHub CLI (Recommended)**

```zsh
# Install GitHub CLI if not already installed
brew install gh

# Authenticate with GitHub
gh auth login

# Upload SSH key automatically
gh ssh-key add ~/.ssh/id_ed25519_github.pub --title "$(hostname)-$(date +%Y%m%d)"

# Verify
gh ssh-key list
```

**Option B: Manual Upload via Web Interface**

1. Go to [GitHub SSH Keys Settings](https://github.com/settings/keys)
2. Click **"New SSH key"**
3. **Title**: `MacBook Pro M1 - Vaultwarden Backups` (or descriptive name)
4. **Key type**: Authentication Key
5. **Key**: Paste from clipboard (Cmd+V)
6. Click **"Add SSH key"**
7. Confirm with your password/2FA

### 7. Test SSH Connection

```zsh
ssh -T git@github.com
```

Expected output:
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

If you see this, **success!** ✅

### 8. Configure Git to Use SSH

```zsh
# Global Git configuration
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"

# For existing repository, convert HTTPS to SSH
cd ~/Documents/vaultwarden-backups

# Check current remote
git remote -v

# If using HTTPS, convert to SSH
git remote set-url origin git@github.com:username/vaultwarden-backups.git

# Verify
git remote -v
```

### 9. Test Git Push

```zsh
cd ~/Documents/vaultwarden-backups

# Create test commit
echo "# SSH Test" > test.md
git add test.md
git commit -m "Test SSH authentication"
git push origin main

# If successful, clean up test file
git rm test.md
git commit -m "Remove test file"
git push origin main
```

## Troubleshooting

### Issue: "Permission denied (publickey)"

```zsh
# Verify key is loaded
ssh-add -l

# If not listed, add it
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github

# Test with verbose output
ssh -vT git@github.com
```

### Issue: Key not persisting after reboot

Edit `~/.ssh/config` to include:

```
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentitiesOnly yes
```

### Issue: Wrong key being used

```zsh
# Check which key is being offered
ssh -v git@github.com 2>&1 | grep "Offering public key"

# Specify key explicitly in git config
git config core.sshCommand "ssh -i ~/.ssh/id_ed25519_github -F /dev/null"
```

### Issue: Host key verification failed

```zsh
# Remove old GitHub host key
ssh-keygen -R github.com

# Add GitHub's current host key
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

## Multiple GitHub Accounts

If you use multiple GitHub accounts:

### Setup

```zsh
# Generate separate keys
ssh-keygen -t ed25519 -C "work@company.com" -f ~/.ssh/id_ed25519_work
ssh-keygen -t ed25519 -C "personal@email.com" -f ~/.ssh/id_ed25519_personal

# Add both to ssh-agent
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_work
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_personal
```

### Configure SSH

```zsh
cat >> ~/.ssh/config << 'EOF'

# Work GitHub
Host github-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work
  AddKeysToAgent yes
  UseKeychain yes

# Personal GitHub
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
  AddKeysToAgent yes
  UseKeychain yes
EOF
```

### Use in Git

```zsh
# Clone using specific account
git clone git@github-work:company/repo.git
git clone git@github-personal:username/repo.git

# Or set remote for existing repo
git remote set-url origin git@github-work:company/repo.git
```

## Security Best Practices

1. **✅ Use ED25519 keys** (more secure than RSA)
2. **✅ Use passphrase** on private keys
3. **✅ Set proper permissions** (600 for private, 644 for public)
4. **✅ Use different keys** for different purposes
5. **✅ Store keys in Keychain** for convenience
6. **✅ Rotate keys annually**
7. **✅ Revoke old keys** on GitHub when no longer needed
8. **❌ Never share private keys**
9. **❌ Never commit keys** to repositories

## Key Management

### List Current Keys on GitHub

```zsh
# Using GitHub CLI (if installed)
gh auth status
gh ssh-key list

# Or visit: https://github.com/settings/keys
```

### Rotate Keys (Annual Maintenance)

```zsh
# Generate new key
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519_github_2025

# Add to agent
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github_2025

# Update config
# Edit ~/.ssh/config to use new key

# Add to GitHub
pbcopy < ~/.ssh/id_ed25519_github_2025.pub
# Add via GitHub web interface

# Test
ssh -T git@github.com

# Remove old key from GitHub and local
rm ~/.ssh/id_ed25519_github*
```

### Backup Keys

```zsh
# Backup private keys to encrypted location
# Use secure external drive or encrypted disk image

# Create encrypted backup
tar czf - ~/.ssh/id_* | \
  gpg --symmetric --cipher-algo AES256 -o ~/Desktop/ssh-keys-backup-$(date +%Y%m%d).tar.gz.gpg

# Store in secure location (NOT in cloud unencrypted!)
```

## Quick Reference

```zsh
# Generate key
ssh-keygen -t ed25519 -C "email@example.com" -f ~/.ssh/id_ed25519_github

# Add to agent
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github

# Copy public key
pbcopy < ~/.ssh/id_ed25519_github.pub

# Test connection
ssh -T git@github.com

# Convert remote to SSH
git remote set-url origin git@github.com:username/repo.git

# Test push
git push origin main
```

---

**Last Updated**: October 6, 2025  
**macOS Version**: Tahoe 26.0.1 (Ventura)

