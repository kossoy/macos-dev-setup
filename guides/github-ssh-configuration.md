# GitHub CLI SSH Protocol Configuration

**Date**: October 7, 2025  
**Status**: ✅ **IMPLEMENTED**

## Overview

Your context switching functions now remember your Git protocol preference (SSH vs HTTPS). No more selecting it every time you authenticate!

## Quick Setup

### Step 1: Choose Your Protocol

**SSH (Recommended for work):**
- More secure
- No password prompts after initial setup
- Requires SSH key configuration
- Common for enterprise environments

**HTTPS (Simpler):**
- Works everywhere
- Easier initial setup
- May prompt for credentials
- Good for personal use

### Step 2: Configure Your Preference

Edit `~/.config/zsh/paths/paths.zsh`:

```bash
# GitHub CLI Git protocol preference (ssh or https)
export WORK_GH_PROTOCOL="ssh"                    # Use SSH for work
export PERSONAL_GH_PROTOCOL="ssh"                # Use SSH for personal
```

### Step 3: Reload Configuration

```bash
source ~/.zshrc
```

### Step 4: Test It!

```bash
$ work
🏢 Switching to Company work context...
   🌐 Switching default browser to chrome...
   🔐 Switching GitHub CLI authentication...
   Please authenticate with your work account (john.doe@company.com)
   Using GitHub Enterprise: github.company.com
   Git protocol: ssh                              # ← Automatically selected!
! First copy your one-time code: XXXX-XXXX
Press Enter to open github.com in your browser...
✓ Authentication complete.
```

**No more protocol selection prompt!** 🎉

## Configuration Options

### Option 1: SSH for Both (Recommended)

```bash
export WORK_GH_PROTOCOL="ssh"
export PERSONAL_GH_PROTOCOL="ssh"
```

**Best for**: Developers comfortable with SSH keys

**Requirements**: SSH keys configured (see [GitHub SSH Setup](guides/github-ssh-setup.md))

### Option 2: HTTPS for Both (Simple)

```bash
export WORK_GH_PROTOCOL="https"
export PERSONAL_GH_PROTOCOL="https"
```

**Best for**: Quick setup, beginners, or situations where SSH is blocked

**Requirements**: None, works out of the box

### Option 3: SSH for Work, HTTPS for Personal

```bash
export WORK_GH_PROTOCOL="ssh"
export PERSONAL_GH_PROTOCOL="https"
```

**Best for**: Enterprise work requirements + easy personal setup

### Option 4: HTTPS for Work, SSH for Personal

```bash
export WORK_GH_PROTOCOL="https"
export PERSONAL_GH_PROTOCOL="ssh"
```

**Best for**: Enterprise HTTPS requirement + personal SSH preference

## Complete Configuration Example

Here's a complete Company setup with SSH:

```bash
# File: ~/.config/zsh/paths/paths.zsh

# Browser preferences
export WORK_BROWSER="chrome"
export PERSONAL_BROWSER="brave"

# GitHub hostnames
export WORK_GITHUB_HOST="github.company.com"
export PERSONAL_GITHUB_HOST="github.com"

# Git protocol preferences
export WORK_GH_PROTOCOL="ssh"
export PERSONAL_GH_PROTOCOL="ssh"
```

Then reload:

```bash
source ~/.zshrc
```

## What Changed

### Before (Manual Selection)

```bash
$ work
🏢 Switching to Company work context...
   🔐 Switching GitHub CLI authentication...
? Where do you use GitHub? Other
? Hostname: github.company.com
? What is your preferred protocol? (Use arrow keys)
❯ HTTPS                                    # ← Had to choose every time
  SSH
? Authenticate Git with your GitHub credentials? Yes
```

### After (Automatic)

```bash
$ work
🏢 Switching to Company work context...
   🌐 Switching default browser to chrome...
   🔐 Switching GitHub CLI authentication...
   Please authenticate with your work account (john.doe@company.com)
   Using GitHub Enterprise: github.company.com
   Git protocol: ssh                        # ← Automatically selected!
! First copy your one-time code: XXXX-XXXX
# Just authenticate - done!
```

## SSH Setup (If Using SSH Protocol)

If you chose SSH protocol, make sure your SSH keys are configured:

### Check Existing SSH Keys

```bash
ls -la ~/.ssh
# Look for: id_ed25519, id_ed25519.pub or id_rsa, id_rsa.pub
```

### Generate New SSH Key (If Needed)

```bash
# Generate ED25519 key (recommended)
ssh-keygen -t ed25519 -C "john.doe@company.com" -f ~/.ssh/id_ed25519_work

# Or RSA if ED25519 not supported
ssh-keygen -t rsa -b 4096 -C "john.doe@company.com" -f ~/.ssh/id_rsa_work
```

### Add SSH Key to ssh-agent

```bash
# Start ssh-agent
eval "$(ssh-agent -s)"

# Add key to macOS Keychain
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_work
```

### Add SSH Key to GitHub

```bash
# Copy public key to clipboard
pbcopy < ~/.ssh/id_ed25519_work.pub

# Then:
# 1. Go to GitHub Settings → SSH and GPG keys
# 2. Click "New SSH key"
# 3. Paste your key
# 4. Save
```

For complete SSH setup, see: **[GitHub SSH Setup Guide](guides/github-ssh-setup.md)**

## Verification

### Check Configuration

```bash
# Check configured protocols
echo "Work: ${WORK_GH_PROTOCOL:-https}"
echo "Personal: ${PERSONAL_GH_PROTOCOL:-https}"

# If empty, defaults to https
```

### Check Authentication

```bash
# After running 'work' and authenticating
gh auth status

# Shows protocol being used
# Example for SSH:
# ✓ Logged in to github.company.com as johndoe
# ✓ Git operations configured to use ssh protocol.
```

### Test SSH Connection

```bash
# For work GitHub Enterprise
ssh -T git@github.company.com

# For personal GitHub
ssh -T git@github.com

# Expected output:
# Hi username! You've successfully authenticated...
```

## Benefits of Each Protocol

### SSH Benefits

**Pros:**
- ✅ No password prompts after setup
- ✅ More secure (key-based authentication)
- ✅ Required by many enterprise environments
- ✅ Faster for frequent Git operations
- ✅ Supports commit signing

**Cons:**
- ❌ Initial setup required
- ❌ Need to manage SSH keys
- ❌ May be blocked by some firewalls

### HTTPS Benefits

**Pros:**
- ✅ Works everywhere (no firewall issues)
- ✅ Easier initial setup
- ✅ No key management needed
- ✅ Good for quick/temporary access

**Cons:**
- ❌ May prompt for credentials
- ❌ Requires credential caching setup
- ❌ Less secure than SSH

## Git Operations After Setup

### With SSH Protocol

```bash
# After 'work' context (SSH)
git clone git@github.company.com:org/repo.git     # ← SSH URL
gh repo clone org/repo                           # Uses SSH automatically

# After 'personal' context (SSH)
git clone git@github.com:user/repo.git           # ← SSH URL
gh repo clone user/repo                          # Uses SSH automatically
```

### With HTTPS Protocol

```bash
# After 'work' context (HTTPS)
git clone https://github.company.com/org/repo.git  # ← HTTPS URL
gh repo clone org/repo                            # Uses HTTPS automatically

# After 'personal' context (HTTPS)
git clone https://github.com/user/repo.git        # ← HTTPS URL
gh repo clone user/repo                           # Uses HTTPS automatically
```

## Troubleshooting

### Issue: Still Asks for Protocol

**Cause**: Environment variable not set

```bash
# Check if variable is set
echo $WORK_GH_PROTOCOL
echo $PERSONAL_GH_PROTOCOL

# If empty, edit ~/.config/zsh/paths/paths.zsh
# Add: export WORK_GH_PROTOCOL="ssh"
# Reload: source ~/.zshrc
```

### Issue: SSH Authentication Fails

**Cause**: SSH keys not configured

```bash
# Check if SSH key exists
ls -la ~/.ssh/id_ed25519*

# Test SSH connection
ssh -T git@github.company.com

# If fails, see SSH setup section above
```

### Issue: Permission Denied (publickey)

**Cause**: SSH key not added to GitHub or ssh-agent

```bash
# Check if key is loaded
ssh-add -l

# If not listed, add it
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_work

# Then add public key to GitHub
pbcopy < ~/.ssh/id_ed25519_work.pub
# Go to GitHub → Settings → SSH Keys
```

### Issue: Want to Switch Protocol

```bash
# Edit configuration
edit ~/.config/zsh/paths/paths.zsh

# Change from ssh to https (or vice versa)
export WORK_GH_PROTOCOL="https"  # Changed from "ssh"

# Reload
source ~/.zshrc

# Re-authenticate
gh auth logout
work
```

## Complete Feature Set

Your GitHub CLI authentication now remembers:

| Feature | Configuration | Default |
|---------|---------------|---------|
| **Hostname** | `WORK_GITHUB_HOST` | `github.com` |
| **Protocol** | `WORK_GH_PROTOCOL` | `https` |
| **Browser** | `WORK_BROWSER` | `chrome` |
| **Auth Method** | `--web` flag | Web browser |

All configured once, used automatically! ✨

## Quick Reference

```bash
# Setup (one-time)
edit ~/.config/zsh/paths/paths.zsh

# Add protocol preferences:
export WORK_GH_PROTOCOL="ssh"        # or "https"
export PERSONAL_GH_PROTOCOL="ssh"    # or "https"

# Reload
source ~/.zshrc

# Daily use
work            # Uses configured protocol automatically
personal        # Uses configured protocol automatically

# Verify
gh auth status  # Shows which protocol is active
echo $WORK_GH_PROTOCOL     # Shows configured protocol
```

## Related Documentation

- **[GitHub SSH Setup](guides/github-ssh-setup.md)** - Complete SSH configuration
- **[GitHub Enterprise Setup](GITHUB_ENTERPRISE_SETUP.md)** - Enterprise configuration
- **[Context Switching](CONTEXT_SWITCHING_FIXED.md)** - Main context guide

---

**Implemented**: October 7, 2025  
**Configuration**: `~/.config/zsh/paths/paths.zsh`  
**Functions**: `~/.config/zsh/functions/functions.zsh`  
**Protocols**: `ssh` or `https`
