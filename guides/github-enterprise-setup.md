# GitHub Enterprise Setup for Context Switching

**Date**: October 7, 2025  
**Status**: ✅ **IMPLEMENTED**

## Overview

Your context switching functions now support GitHub Enterprise Server instances (like `github.company.com`) in addition to GitHub.com. The functions automatically use the correct hostname when authenticating.

## Quick Setup

### For Company (GitHub Enterprise)

Edit `~/.config/zsh/paths/paths.zsh` and uncomment/add:

```bash
# GitHub hostnames for context switching
export WORK_GITHUB_HOST="github.company.com"        # Your GitHub Enterprise hostname
export PERSONAL_GITHUB_HOST="github.com"           # GitHub.com for personal
```

### Reload Configuration

```bash
source ~/.zshrc
```

### Test It

```bash
$ work
🏢 Switching to Company work context...
   🌐 Switching default browser to chrome...
   🔐 Switching GitHub CLI authentication...
   Please authenticate with your work account (john.doe@company.com)
   Using GitHub Enterprise: github.company.com
? Where do you use GitHub? Other
? Hostname: github.company.com          # ← Pre-filled automatically!
? Authenticate Git with your GitHub credentials? Yes
? How would you like to authenticate GitHub CLI? Login with a web browser
```

## How It Works

### Without Configuration (Default)

Both contexts use `github.com`:

```bash
# Default behavior
work      # Uses github.com
personal  # Uses github.com
```

### With Enterprise Configuration

```bash
# In ~/.config/zsh/paths/paths.zsh
export WORK_GITHUB_HOST="github.company.com"

# Now when you run:
work      # Uses github.company.com
personal  # Uses github.com
```

## Configuration Options

### Option 1: Work = Enterprise, Personal = GitHub.com (Most Common)

```bash
# In ~/.config/zsh/paths/paths.zsh
export WORK_GITHUB_HOST="github.company.com"
export PERSONAL_GITHUB_HOST="github.com"
```

**Use case**: Corporate GitHub Enterprise for work, public GitHub for personal projects

### Option 2: Both Use GitHub.com

```bash
# Leave both unset or explicitly set:
# export WORK_GITHUB_HOST="github.com"
# export PERSONAL_GITHUB_HOST="github.com"
```

**Use case**: Both work and personal use public GitHub with different accounts

### Option 3: Both Use Enterprise

```bash
export WORK_GITHUB_HOST="github.company-a.com"
export PERSONAL_GITHUB_HOST="github.company-b.com"
```

**Use case**: Multiple enterprise instances (consulting, freelancing)

### Option 4: Work = GitHub.com, Personal = Enterprise

```bash
export WORK_GITHUB_HOST="github.com"
export PERSONAL_GITHUB_HOST="github.mycompany.com"
```

**Use case**: Rare, but supported

## Verification

### Check Current Configuration

```bash
# Check what hostnames are configured
echo "Work: $WORK_GITHUB_HOST"
echo "Personal: $PERSONAL_GITHUB_HOST"

# If empty, defaults to github.com
```

### Check Authentication Status

```bash
# Show all authenticated GitHub hosts
gh auth status

# Example output:
# github.company.com
#   ✓ Logged in to github.company.com as johndoe (oauth_token)
#   ✓ Git operations for github.company.com configured to use https protocol.
#   ✓ Token: *******************
```

### Check Context

```bash
show-context

# Shows:
# 🔐 GitHub CLI:
#    Logged in to: github.company.com
#    Account: johndoe
```

## GitHub CLI Commands with Enterprise

Once authenticated, all `gh` commands work with your enterprise instance:

```bash
# After 'work' (authenticated to github.company.com)
gh repo list                           # Lists repos from github.company.com
gh pr list                             # Shows PRs from github.company.com
gh issue create                        # Creates issue on github.company.com

# After 'personal' (authenticated to github.com)
gh repo list                           # Lists repos from github.com
gh pr list                             # Shows PRs from github.com
gh issue create                        # Creates issue on github.com
```

## Manual Authentication (One-Time Setup)

If you want to authenticate manually to remember the hostname:

### For GitHub Enterprise

```bash
gh auth login --hostname github.company.com
```

GitHub CLI will remember `github.company.com` and you can authenticate to it anytime.

### For GitHub.com

```bash
gh auth login
```

### Check All Authenticated Hosts

```bash
gh auth status

# Shows all hosts you've authenticated to:
# - github.com
# - github.company.com
# - etc.
```

## Switching Between Hosts Manually

```bash
# Login to work GitHub Enterprise
gh auth login --hostname github.company.com

# Login to personal GitHub.com
gh auth login --hostname github.com

# Check which ones are active
gh auth status
```

## Git Operations

GitHub CLI also configures Git to use the correct credentials:

```bash
# After 'work' context
git clone https://github.company.com/org/repo.git
# Uses work credentials automatically

# After 'personal' context
git clone https://github.com/user/repo.git
# Uses personal credentials automatically
```

## Troubleshooting

### Issue: Still Asks for Hostname

**Cause**: Environment variable not set or not loaded

```bash
# Check if variable is set
echo $WORK_GITHUB_HOST

# If empty, edit ~/.config/zsh/paths/paths.zsh
# Add: export WORK_GITHUB_HOST="github.company.com"

# Reload
source ~/.zshrc

# Try again
work
```

### Issue: Wrong Host Being Used

**Cause**: Variable typo or not exported

```bash
# Check variables
echo "Work: ${WORK_GITHUB_HOST:-github.com}"
echo "Personal: ${PERSONAL_GITHUB_HOST:-github.com}"

# Fix in ~/.config/zsh/paths/paths.zsh
# Make sure they're exported:
export WORK_GITHUB_HOST="github.company.com"
```

### Issue: Authentication Fails

**Cause**: Enterprise server configuration or network issues

```bash
# Test connectivity
ping github.company.com

# Try manual authentication
gh auth login --hostname github.company.com

# Check if VPN is required
# Some enterprise instances require VPN connection
```

### Issue: Shows "Logged in to github.com" Instead of Enterprise

**Cause**: Authenticated to wrong host

```bash
# Logout from all hosts
gh auth logout --hostname github.com
gh auth logout --hostname github.company.com

# Re-authenticate with correct context
work  # Will prompt for github.company.com
```

## Advanced: Multiple Enterprise Instances

If you work with multiple enterprise instances:

```bash
# In ~/.config/zsh/paths/paths.zsh
export WORK_GITHUB_HOST="github.company.com"
export PERSONAL_GITHUB_HOST="github.mycompany.com"

# Both are enterprise instances
# Context switching will handle them correctly
```

## Complete Configuration Example

Here's a complete example for Company:

```bash
# File: ~/.config/zsh/paths/paths.zsh

# Browser preferences
export WORK_BROWSER="chrome"
export PERSONAL_BROWSER="safari"

# GitHub hostnames
export WORK_GITHUB_HOST="github.company.com"      # Enterprise for work
export PERSONAL_GITHUB_HOST="github.com"         # Public for personal
```

Then:

```bash
# Reload configuration
source ~/.zshrc

# Switch to work
work
# - Browser: Chrome
# - GitHub: github.company.com
# - Git: john.doe@company.com

# Switch to personal
personal
# - Browser: Safari
# - GitHub: github.com
# - Git: john@personal-org.com
```

## Benefits

### ✅ Automatic Enterprise Detection

```bash
# Just run work
work
# Automatically knows to use github.company.com

# No manual --hostname needed
# No typing the hostname each time
```

### ✅ Complete Isolation

| Feature | Work Context | Personal Context |
|---------|--------------|------------------|
| Browser | Chrome | Safari |
| GitHub Host | github.company.com | github.com |
| Git Email | john.doe@company.com | john@personal-org.com |
| Credentials | Work token | Personal token |

### ✅ Prevents Mistakes

- No more pushing to wrong GitHub instance
- No more creating PRs on wrong server
- No more accessing wrong org's repositories
- Clear visibility of current host in `show-context`

## Related Commands

```bash
# Check all authenticated hosts
gh auth status

# Login to specific host
gh auth login --hostname github.company.com

# Logout from specific host
gh auth logout --hostname github.company.com

# Use gh with specific host
gh repo list --hostname github.company.com

# Check current context
show-context
```

## Related Documentation

- **[GitHub CLI Integration](GITHUB_CLI_INTEGRATION.md)** - General GitHub CLI setup
- **[Context Switching](CONTEXT_SWITCHING_FIXED.md)** - Complete context switching guide
- **[Browser Switching](BROWSER_SWITCHING.md)** - Browser configuration

## Quick Reference

```bash
# Setup (one-time)
# Edit ~/.config/zsh/paths/paths.zsh
export WORK_GITHUB_HOST="github.company.com"
export PERSONAL_GITHUB_HOST="github.com"

# Reload
source ~/.zshrc

# Use
work                    # Authenticates to github.company.com
personal                # Authenticates to github.com
show-context            # Shows current GitHub host

# Verify
gh auth status          # Shows all authenticated hosts
echo $WORK_GITHUB_HOST  # Shows configured work host
```

---

**Implemented**: October 7, 2025  
**Configuration**: `~/.config/zsh/paths/paths.zsh`  
**Functions**: `~/.config/zsh/functions/functions.zsh`
