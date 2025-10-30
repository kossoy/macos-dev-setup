# Session Handoff: Context Switching Implementation

**Date**: October 30, 2025
**Session ID**: Continuation from previous context
**Status**: 🔄 IN PROGRESS

## 🎯 Current Objective

Implement complete context switching system for macOS development environment that allows seamless switching between work (SAP Concur) and personal development contexts.

## 📋 What We're Building

A comprehensive context switching system with:
- Git email/name switching
- GitHub CLI multi-host authentication (github.com + github.concur.com)
- SSH key management (personal always loaded, work loaded on-demand)
- Browser switching (Brave Browser vs Brave Browser Beta)
- VPN connectivity checks for GitHub Enterprise
- Context-aware database management
- Persistent context across terminal sessions

## ✅ What's Been Completed

### 1. Private Configuration File Created
**File**: `/Users/i065699/.config/zsh/private/work-personal-config.zsh`

```zsh
#!/bin/zsh
# Git email addresses
export WORK_GIT_EMAIL="oleg.kossoy@sap.com"
export PERSONAL_GIT_EMAIL="oleg@befeast.com"

# GitHub usernames (for verification)
export WORK_GH_USER="oleg-kossoy"
export PERSONAL_GH_USER="kossoy"

# GitHub hosts
export WORK_GITHUB_HOST="github.concur.com"
export PERSONAL_GITHUB_HOST="github.com"

# Work context identifiers
export WORK_ORG="SAP_CONCUR"
export WORK_CONTEXT_NAME="SAP Concur"

# Personal context identifiers
export PERSONAL_ORG="PERSONAL_ORG"
export PERSONAL_CONTEXT_NAME="Personal"
```

**Status**: ✅ Created and verified loading

### 2. Template File Created
**File**: `/Users/i065699/macos-dev-setup/config/zsh/private/work-personal-config.zsh.template`

**Status**: ✅ Created and committed to git

### 3. .zshrc Updated to Load Private Config
**File**: `/Users/i065699/.zshrc`

Added line 37-38:
```zsh
# Load work/personal configuration (private, not in git)
[[ -f "$HOME/.config/zsh/private/work-personal-config.zsh" ]] && source "$HOME/.config/zsh/private/work-personal-config.zsh"
```

**Status**: ✅ Completed - config now loads on shell start

### 4. Git Configuration
- Remote URL switched from HTTPS to SSH
- Successfully pushed changes to GitHub
- Commit: `f3f4cb8` - "feat: browser switching, context names, VPN check, SSH key management"

**Status**: ✅ Git authentication working

### 5. Browser Configuration
**File**: `/Users/i065699/macos-dev-setup/config/zsh/config/paths.zsh` (lines 149-151)

```zsh
export WORK_BROWSER="browser"      # Brave Browser
export PERSONAL_BROWSER="beta"     # Brave Browser Beta
```

**Status**: ✅ Configuration set, manual switching accepted by user

## ⚠️ CRITICAL DISCOVERY

### The Context Switching Functions Don't Exist!

**Problem**: The `work()`, `personal()`, and `show-context()` functions are:
- ✅ Documented in `/Users/i065699/macos-dev-setup/guides/context-switching.md`
- ❌ **NOT implemented** in `/Users/i065699/macos-dev-setup/config/zsh/config/functions.zsh`
- ⚠️ Currently loaded from Claude shell snapshot at:
  `/Users/i065699/.claude/shell-snapshots/snapshot-zsh-1761828441438-tdpu9n.sh:5565`

**Current Behavior**:
- The `work()` function from the snapshot still shows "Company" instead of "SAP Concur"
- Uses old hardcoded values instead of loading from private config

**What Needs to Happen**:
The complete context switching implementation needs to be added to:
`/Users/i065699/macos-dev-setup/config/zsh/config/functions.zsh`

## 📁 File Status Summary

### Files That ARE in Sync
- ✅ `/Users/i065699/.config/zsh/private/work-personal-config.zsh` (private, gitignored)
- ✅ `/Users/i065699/macos-dev-setup/config/zsh/private/work-personal-config.zsh.template` (committed)
- ✅ `/Users/i065699/.zshrc` (loads private config)
- ✅ `/Users/i065699/macos-dev-setup/config/zsh/config/paths.zsh` (browser config)

### Files That Need Work
- ❌ `/Users/i065699/macos-dev-setup/config/zsh/config/functions.zsh` - Missing context switching functions
- ❌ `/Users/i065699/.config/zsh/config/functions.zsh` - Will need to be synced after repo file is updated

### Sync Issue Discovered
When trying to copy from repo to ~/.config/zsh/config/:
```bash
cp ~/macos-dev-setup/config/zsh/config/functions.zsh ~/.config/zsh/config/functions.zsh
```
Results in interactive prompt: "overwrite... (y/n [n])"

File has `com.apple.provenance` extended attribute that causes prompt.

**Workaround**: Either:
1. Use `cp -f` (force)
2. Remove xattr first: `xattr -d com.apple.provenance ~/.config/zsh/config/functions.zsh`
3. Direct edit of the loaded file

## 🔧 Technical Details Discovered

### 1. BSD grep vs GNU grep
**Issue**: `grep -P` (Perl regex) doesn't work on macOS BSD grep
**Solution**: Use `sed -E` or `grep -E` instead

### 2. GitHub Enterprise Connectivity
**Issue**: `github.concur.com` blocks ICMP ping
**Solution**: Use `curl` for connectivity checks:
```zsh
curl -s -o /dev/null --max-time 3 "https://$gh_host" 2>/dev/null
```

### 3. Zsh vs Bash Syntax
**Issue**: `read -p` doesn't work in zsh
**Solution**: Use zsh syntax:
```zsh
echo -n "Press Enter..."
read
```

### 4. Browser Detection
**Issue**: Parsing `defaultbrowser` output unreliable
**Solution**: Read LaunchServices plist directly with Python:
```zsh
python3 -c "import plistlib, os; plist = plistlib.load(open(os.path.expanduser('~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist'), 'rb')); handlers = plist.get('LSHandlers', []); http_handler = next((h for h in handlers if h.get('LSHandlerURLScheme') == 'http'), {}); print(http_handler.get('LSHandlerRoleAll', 'Not set'))" 2>/dev/null
```

### 5. Browser Identifiers
From `defaultbrowser` tool:
- `browser` = Brave Browser
- `beta` = Brave Browser Beta
- `chrome` = Google Chrome
- `safari` = Safari
- `firefox` = Firefox

### 6. SSH Key Management Requirements
**Personal key**: `~/.ssh/id_ed25519` - ALWAYS loaded
**Work key**: `~/.ssh/id_ed25519_concur` - Load on `work()`, unload on `personal()`

Commands:
```zsh
# Add key
ssh-add -q "$HOME/.ssh/id_ed25519_concur" 2>/dev/null

# Remove key
ssh-add -d "$HOME/.ssh/id_ed25519_concur" 2>/dev/null
```

### 7. GitHub CLI Multi-Host Authentication
**Key Insight**: Can be authenticated to BOTH hosts simultaneously!
- Personal: `github.com`
- Work: `github.concur.com`

Check specific host:
```zsh
gh auth status --hostname "$check_host"
```

No need to logout/re-login on context switch.

## 🎯 What Needs to Be Implemented

### Complete Context Switching Functions

The following functions need to be added to:
`/Users/i065699/macos-dev-setup/config/zsh/config/functions.zsh`

### Function 1: `work()`

**Requirements**:
1. Display message: "🏢 Switching to {WORK_CONTEXT_NAME} work context..."
2. Load work email from `WORK_GIT_EMAIL` or SSH key
3. Set environment variables:
   - `WORK_CONTEXT="${WORK_ORG}"`
   - `PROJECT_ROOT="$HOME/work/projects/work"`
   - `CONFIG_ROOT="$HOME/work/configs/work"`
   - Database variables for work context
4. Update Git config: `git config --global user.email`
5. SSH key management:
   - Ensure personal key loaded: `ssh-add -q "$HOME/.ssh/id_ed25519"`
   - Load work key: `ssh-add -q "$HOME/.ssh/id_ed25519_concur"`
6. Browser switching:
   - Use `defaultbrowser "${WORK_BROWSER}"`
   - Show recommendation message (can't force on modern macOS)
7. VPN connectivity check:
   - If `WORK_GITHUB_HOST != "github.com"`, check connectivity with curl
   - Prompt user to connect to VPN if unreachable
   - Wait for user confirmation (zsh `read` syntax)
   - Re-check after user connects
8. GitHub CLI verification:
   - Check auth status: `gh auth status --hostname "${WORK_GITHUB_HOST}"`
   - Verify username matches `WORK_GH_USER`
   - Only check if host is reachable (skip if VPN down)
9. Write context file: `~/.config/zsh/contexts/current.zsh`
10. Change to work projects directory
11. Display success message with git email, projects path, database info

### Function 2: `personal()`

**Requirements**:
1. Display message: "🏠 Switching to {PERSONAL_CONTEXT_NAME} personal context..."
2. Load personal email from `PERSONAL_GIT_EMAIL` or SSH key
3. Set environment variables:
   - `WORK_CONTEXT="${PERSONAL_ORG}"`
   - `PROJECT_ROOT="$HOME/work/projects/personal"`
   - `CONFIG_ROOT="$HOME/work/configs/personal"`
   - Database variables for personal context
4. Update Git config: `git config --global user.email`
5. SSH key management:
   - Ensure personal key loaded: `ssh-add -q "$HOME/.ssh/id_ed25519"`
   - **UNLOAD work key**: `ssh-add -d "$HOME/.ssh/id_ed25519_concur"`
6. Browser switching:
   - Use `defaultbrowser "${PERSONAL_BROWSER}"`
   - Show recommendation message
7. GitHub CLI verification:
   - Check auth status: `gh auth status --hostname "${PERSONAL_GITHUB_HOST}"`
   - Verify username matches `PERSONAL_GH_USER`
   - Use ping for github.com, curl for others
8. Write context file: `~/.config/zsh/contexts/current.zsh`
9. Change to personal projects directory
10. Display success message

### Function 3: `show-context()`

**Requirements**:
1. Display formatted header: "📋 Current Development Context"
2. Show current context name (work or personal)
3. Git configuration:
   - `git config --global user.name`
   - `git config --global user.email`
4. GitHub CLI status **ONLY for current context**:
   - Determine which host based on current `WORK_CONTEXT`
   - Check connectivity first (ping or curl based on host)
   - Only call GitHub API if host is reachable
   - Show username if authenticated
   - Show warning if unreachable (VPN required)
5. Default browser (from LaunchServices plist)
6. Paths:
   - Projects: `$PROJECT_ROOT`
   - Config: `$CONFIG_ROOT`
   - Current: `$PWD`
7. Database info:
   - Host, Port, Database name, User
8. SSH keys loaded: `ssh-add -l`

**CRITICAL**: Must be context-aware! Only check the CURRENT context's GitHub host, not both.

## 📝 Implementation Reference

### Context File Format
`~/.config/zsh/contexts/current.zsh` should contain:
```zsh
#!/bin/zsh
# Current development context (auto-generated)
export WORK_CONTEXT="SAP_CONCUR"  # or "PERSONAL_ORG"
export PROJECT_ROOT="$HOME/work/projects/work"  # or personal
export CONFIG_ROOT="$HOME/work/configs/work"    # or personal
# Database variables...
```

### VPN Check Pattern
```zsh
local gh_host="${WORK_GITHUB_HOST:-github.com}"
local skip_gh_check=false

if [[ "$gh_host" != "github.com" ]]; then
    echo "   🔍 Checking connectivity to $gh_host..."
    if ! curl -s -o /dev/null --max-time 3 "https://$gh_host" 2>/dev/null; then
        echo "   ⚠️  Cannot reach $gh_host"
        echo "   💡 Please connect to GlobalProtect VPN"
        echo -n "   Press Enter after connecting to VPN (or Ctrl+C to skip)..."
        read
        echo ""

        # Re-check
        if curl -s -o /dev/null --max-time 3 "https://$gh_host" 2>/dev/null; then
            echo "   ✅ Connected to $gh_host"
        else
            echo "   ⚠️  Still cannot reach $gh_host - skipping GitHub CLI check"
            skip_gh_check=true
        fi
    else
        echo "   ✅ VPN connected - $gh_host is reachable"
    fi
fi
```

### GitHub CLI Check Pattern (Context-Aware)
```zsh
if command -v gh >/dev/null 2>&1; then
    echo "🔐 GitHub CLI:"

    # Determine which host based on current context
    local check_host="github.com"
    if [[ "$context_type" == "work" ]]; then
        check_host="${WORK_GITHUB_HOST:-github.com}"
    elif [[ "$context_type" == "personal" ]]; then
        check_host="${PERSONAL_GITHUB_HOST:-github.com}"
    fi

    # Check auth for context's host only
    local auth_status=$(gh auth status --hostname "$check_host" 2>&1)

    if echo "$auth_status" | grep -q "Logged in"; then
        echo "   ✅ Authenticated to $check_host"

        # Get username only if reachable
        local is_reachable=false
        if [[ "$check_host" == "github.com" ]]; then
            ping -c 1 -W 1 "$check_host" >/dev/null 2>&1 && is_reachable=true
        else
            curl -s -o /dev/null --max-time 2 "https://$check_host" 2>/dev/null && is_reachable=true
        fi

        if [[ "$is_reachable" == "true" ]]; then
            local gh_user=$(gh api user --hostname "$check_host" -q .login 2>/dev/null)
            if [[ -n "$gh_user" ]] && [[ "$gh_user" != "null" ]]; then
                echo "   Logged in as: $gh_user"
            else
                echo "   ⚠️  Cannot retrieve username (check VPN)"
            fi
        else
            echo "   ⚠️  Cannot reach $check_host (VPN required)"
        fi
    else
        echo "   ❌ Not authenticated to $check_host"
        echo "   💡 Run: gh auth login --hostname $check_host"
    fi
fi
```

## 🚀 Next Steps (In Order)

### Step 1: Implement Context Switching Functions
1. Open `/Users/i065699/macos-dev-setup/config/zsh/config/functions.zsh`
2. Add complete `work()` function at end of file
3. Add complete `personal()` function
4. Add complete `show-context()` function
5. Save file

### Step 2: Sync to Live Config
```bash
# Option A: Force copy
cp -f ~/macos-dev-setup/config/zsh/config/functions.zsh ~/.config/zsh/config/functions.zsh

# Option B: Remove xattr and copy
xattr -d com.apple.provenance ~/.config/zsh/config/functions.zsh 2>/dev/null || true
cp ~/macos-dev-setup/config/zsh/config/functions.zsh ~/.config/zsh/config/functions.zsh
```

### Step 3: Reload Shell and Test
```bash
source ~/.zshrc

# Verify config loaded
echo "WORK_CONTEXT_NAME=$WORK_CONTEXT_NAME"
echo "WORK_ORG=$WORK_ORG"

# Test work context
work
# Should show: "🏢 Switching to SAP Concur work context..."
# Should prompt for VPN if github.concur.com is unreachable
# Should verify GitHub CLI authentication
# Should show success message with correct email

# Test show-context
show-context
# Should show current context as "SAP Concur"
# Should show git email as oleg.kossoy@sap.com
# Should show GitHub CLI status for github.concur.com only

# Test personal context
personal
# Should show: "🏠 Switching to Personal personal context..."
# Should unload work SSH key
# Should switch to personal email
```

### Step 4: Commit and Push
```bash
cd ~/macos-dev-setup
git add config/zsh/config/functions.zsh
git commit -m "feat: implement complete context switching functions

- Add work() function with VPN check, SSH key management, browser switching
- Add personal() function with SSH key unloading
- Add show-context() function with context-aware checks
- Use dynamic context names from private config
- Fix all BSD grep compatibility issues
- Add curl-based connectivity checks for GHE
- Implement zsh-compatible prompts"
git push
```

### Step 5: Verify Everything Works
- [ ] `work` command shows "SAP Concur" not "Company"
- [ ] Git email switches correctly
- [ ] SSH keys load/unload properly
- [ ] VPN check prompts when github.concur.com unreachable
- [ ] GitHub CLI checks only current context's host
- [ ] `show-context` displays correct information
- [ ] Browser recommendation shows correct app
- [ ] Context persists across new terminal tabs

## 🐛 Known Issues to Address

1. **Browser switching is manual** - Modern macOS security prevents programmatic default browser changes. Showing recommendation message is acceptable.

2. **Shell snapshot has old functions** - The Claude snapshot at `/Users/i065699/.claude/shell-snapshots/snapshot-zsh-1761828441438-tdpu9n.sh` has old hardcoded functions. These will be overridden once new functions are loaded from functions.zsh.

3. **File sync friction** - The extended attributes on ~/.config/zsh/config/functions.zsh cause interactive prompts on copy. Either accept this or script around it.

## 📚 Reference Documentation

- **Context Switching Guide**: `/Users/i065699/macos-dev-setup/guides/context-switching.md`
- **CLAUDE.md**: `/Users/i065699/macos-dev-setup/CLAUDE.md`
- **Private Config Template**: `/Users/i065699/macos-dev-setup/config/zsh/private/work-personal-config.zsh.template`

## 💡 User Preferences Captured

1. **Context Names**:
   - Work: "SAP Concur" (not "Company")
   - Personal: "Personal" (not "PersonalOrg")

2. **Browsers**:
   - Work: Brave Browser (`browser`)
   - Personal: Brave Browser Beta (`beta`)

3. **GitHub Hosts**:
   - Work: `github.concur.com` (Enterprise)
   - Personal: `github.com`

4. **Git Emails**:
   - Work: `oleg.kossoy@sap.com`
   - Personal: `oleg@befeast.com`

5. **GitHub Usernames**:
   - Work: `oleg-kossoy`
   - Personal: `kossoy`

6. **SSH Keys**:
   - Personal: `~/.ssh/id_ed25519` (always loaded)
   - Work: `~/.ssh/id_ed25519_concur` (load/unload on context switch)

## ⚠️ Critical Decisions Made

1. **Multi-host GitHub CLI**: Don't logout/re-login on context switch. Can be authenticated to both github.com and github.concur.com simultaneously.

2. **SSH key strategy**: Personal key always available, work key added/removed on demand.

3. **VPN handling**: Prompt user to connect, wait for confirmation, then re-check connectivity.

4. **Context-aware checks**: `show-context` only checks the current context's GitHub host, not both.

5. **Browser switching**: Show recommendation message instead of forcing (macOS security restriction).

## 🎬 Continuation Checklist

When resuming this work:
- [ ] Read this document thoroughly
- [ ] Check current state of functions.zsh file
- [ ] Verify private config still loads correctly
- [ ] Review user's latest requests in conversation
- [ ] Follow implementation steps in order
- [ ] Test thoroughly before claiming completion (Rule 7!)
- [ ] Update this document if approach changes

---

**Document Purpose**: This document serves as a complete handoff for the next AI session or developer continuing this work. It captures all context, decisions, discoveries, and next steps needed to complete the context switching implementation without loss of progress.

**Last Updated**: October 30, 2025
**Next Action**: Implement the three context switching functions in functions.zsh
