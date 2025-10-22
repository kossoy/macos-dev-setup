# Company GitHub Enterprise Setup - Quick Start

**For**: Company employees using `github.company.com`  
**Setup Time**: ~2 minutes

## What You Saw

```bash
$ work
🏢 Switching to Company work context...
   🌐 Switching default browser to chrome...
   🔐 Switching GitHub CLI authentication...
   Please authenticate with your work account (john.doe@company.com)
? Where do you use GitHub? Other
? Hostname: github.company.com      # ← You have to type this every time
```

## The Fix

Make it automatic! Configure once, never type the hostname again.

## Setup (One-Time)

### Step 1: Edit Configuration

```bash
# Open the configuration file
edit ~/.config/zsh/paths/paths.zsh

# Or use vim/nvim
nvim ~/.config/zsh/paths/paths.zsh
```

### Step 2: Add GitHub Enterprise Configuration

Find this section (around line 43) and uncomment/edit:

```bash
# GitHub hostnames for context switching
# Uncomment and customize if you use GitHub Enterprise Server
# Default is github.com for both contexts
export WORK_GITHUB_HOST="github.company.com"        # ← Uncomment and set this
export PERSONAL_GITHUB_HOST="github.com"           # ← Uncomment this (or leave as default)
```

**Result:**
```bash
# GitHub hostnames for context switching
export WORK_GITHUB_HOST="github.company.com"
export PERSONAL_GITHUB_HOST="github.com"
```

### Step 3: Reload Configuration

```bash
source ~/.zshrc
```

### Step 4: Test It

```bash
$ work
🏢 Switching to Company work context...
   🌐 Switching default browser to chrome...
   🔐 Switching GitHub CLI authentication...
   Please authenticate with your work account (john.doe@company.com)
   Using GitHub Enterprise: github.company.com      # ← Shows it knows!
? Authenticate Git with your GitHub credentials? Yes
? How would you like to authenticate GitHub CLI? Login with a web browser
# Browser opens → Authenticate → Done!
```

**No more typing the hostname!** 🎉

## What Changed

### Before (Manual)
```bash
work
# Type: Other
# Type: github.company.com
# Authenticate
```

### After (Automatic)
```bash
work
# Automatically uses github.company.com
# Just authenticate - that's it!
```

## Verification

### Check Configuration

```bash
# Verify environment variables are set
echo $WORK_GITHUB_HOST
# Output: github.company.com

echo $PERSONAL_GITHUB_HOST  
# Output: github.com
```

### Check Authentication

```bash
# After running 'work' and authenticating
gh auth status

# Output:
# github.company.com
#   ✓ Logged in to github.company.com as johndoe (oauth_token)
#   ✓ Git operations configured to use https protocol.
```

### Check Context

```bash
show-context

# Shows:
# 🔐 GitHub CLI:
#    Logged in to: github.company.com
#    Account: johndoe
```

## Now You Can Use GitHub CLI

All `gh` commands now work with Company's GitHub Enterprise:

```bash
# After 'work' context
gh repo list                           # Lists Company repos
gh pr list                             # Your work PRs
gh pr create                           # Create PR at github.company.com
gh issue create                        # Create issue at github.company.com

# Clone repos
gh repo clone company-org/some-repo
```

## Personal Projects Still Work

```bash
# Switch to personal
personal
# Automatically uses github.com

gh repo list                           # Lists your personal repos
gh pr create                           # Creates PR on github.com
```

## Complete Company Configuration

Here's the complete recommended setup for Company developers:

```bash
# File: ~/.config/zsh/paths/paths.zsh

# Browser preferences
export WORK_BROWSER="chrome"           # Chrome for work
export PERSONAL_BROWSER="brave"        # Brave for personal

# GitHub hostnames
export WORK_GITHUB_HOST="github.company.com"    # Company Enterprise
export PERSONAL_GITHUB_HOST="github.com"       # Public GitHub

# Git protocol preferences (optional)
export WORK_GH_PROTOCOL="ssh"          # Use SSH for work (requires SSH keys)
export PERSONAL_GH_PROTOCOL="ssh"      # Use SSH for personal

# VPN automation (optional)
export WORK_VPN_CONNECT="true"         # Auto-connect VPN for work
export PERSONAL_VPN_DISCONNECT="true"  # Auto-disconnect VPN for personal
export VPN_PORTAL="vpn.company.com"     # Your Company VPN portal
```

**Notes**:
- If you configure SSH protocol, make sure your SSH keys are set up. See [GitHub SSH Configuration](GITHUB_SSH_CONFIGURATION.md) for details.
- VPN automation requires Palo Alto GlobalProtect. See [VPN Automation](VPN_AUTOMATION.md) for setup.

Then reload:

```bash
source ~/.zshrc
```

Now when you switch contexts:

### Work Context (`work`)
- ✅ VPN: Auto-connect (configurable)
- ✅ Browser: Chrome
- ✅ GitHub: github.company.com (Company Enterprise)
- ✅ Git Protocol: SSH (configurable)
- ✅ Git Email: john.doe@company.com
- ✅ Database: localhost:5432

### Personal Context (`personal`)
- ✅ VPN: Auto-disconnect (configurable)
- ✅ Browser: Brave
- ✅ GitHub: github.com (Public)
- ✅ Git Protocol: SSH (configurable)
- ✅ Git Email: john@personal-org.com
- ✅ Database: localhost:5433

## Troubleshooting

### Still Asks for Hostname

```bash
# Check if variable is set
echo $WORK_GITHUB_HOST

# If empty, make sure you:
# 1. Added 'export' before the variable
# 2. Reloaded: source ~/.zshrc
```

### Wrong GitHub Instance

```bash
# Clear all authentications and start fresh
gh auth logout --hostname github.com
gh auth logout --hostname github.company.com

# Now switch context
work
# Should use github.company.com automatically
```

### Need VPN?

Some Company resources might require VPN:

```bash
# Connect to VPN first
# Then authenticate
work
```

## Quick Reference

```bash
# Setup (one-time)
edit ~/.config/zsh/paths/paths.zsh
# Add: export WORK_GITHUB_HOST="github.company.com"
source ~/.zshrc

# Daily use
work            # Switches to Company (github.company.com)
personal        # Switches to personal (github.com)
show-context    # Shows current GitHub host

# Verify
gh auth status  # Shows authenticated hosts
```

## Related Documentation

- **[GitHub Enterprise Setup](GITHUB_ENTERPRISE_SETUP.md)** - Complete guide
- **[GitHub SSH Configuration](GITHUB_SSH_CONFIGURATION.md)** - SSH protocol setup
- **[VPN Automation](VPN_AUTOMATION.md)** - Automatic VPN connect/disconnect
- **[Context Switching](CONTEXT_SWITCHING_FIXED.md)** - All context features
- **[GitHub CLI Integration](GITHUB_CLI_INTEGRATION.md)** - GitHub CLI details
- **[GitHub SSH Setup](guides/github-ssh-setup.md)** - SSH key configuration

---

**Quick Links**:
- Company GitHub Enterprise: https://github.company.com
- GitHub CLI Documentation: https://cli.github.com

**Setup Time**: ~2 minutes  
**Benefit**: Never type the hostname again! ✨
