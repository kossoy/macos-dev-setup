# VPN with Context Switching - Helper Aliases

**Date**: October 7, 2025  
**Status**: ✅ **IMPLEMENTED** (Manual with helpful aliases)  
**VPN**: Palo Alto GlobalProtect

## Update: CLI Automation Not Possible

GlobalProtect on macOS doesn't provide a reliable CLI tool. PanGPS requires the GUI and AppleScript requires accessibility permissions. 

**Solution**: Simple aliases that remind you to click the menu bar icon.

## Overview

Your context switching functions now support automatic VPN connection and disconnection. Perfect for work contexts that require VPN access to enterprise resources.

## Use Case

**Typical Workflow:**
- Switch to `work` context → Need VPN to access GitHub Enterprise, internal tools
- Switch to `personal` context → Don't need VPN, better performance without it

**Now Automated:**
```bash
work        # Automatically connects to VPN
personal    # Automatically disconnects from VPN
```

## Quick Setup

### Step 1: Verify GlobalProtect is Installed

```bash
# Check if GlobalProtect is installed
ls /Applications/GlobalProtect.app

# Check if CLI is available
which globalprotect

# Or check alternative path
ls /Applications/GlobalProtect.app/Contents/MacOS/GlobalProtect
```

### Step 2: Find Your VPN Portal Address

Your VPN portal is typically something like:
- `vpn.company.com`
- `globalprotect.company.com`
- `vpn.company.com` (for Company)

**To find it:**
- Open GlobalProtect app manually
- Look at the portal address field
- Or ask your IT department

### Step 3: Configure Automation

Edit `~/.config/zsh/paths/paths.zsh`:

```bash
# VPN configuration for context switching
export WORK_VPN_CONNECT="true"                  # Auto-connect VPN for work
export PERSONAL_VPN_DISCONNECT="true"           # Auto-disconnect VPN for personal
export VPN_PORTAL="vpn.company.com"              # Your VPN portal address
```

### Step 4: Reload Configuration

```bash
source ~/.zshrc
```

### Step 5: Test It!

```bash
$ work
🏢 Switching to Company work context...
   🌐 Switching default browser to chrome...
   🔒 Connecting to VPN...                       # ← VPN connects!
   🔐 Switching GitHub CLI authentication...
✅ Switched to Company work context

$ personal
🏠 Switching to PersonalOrg personal context...
   🔓 Disconnecting from VPN...                  # ← VPN disconnects!
   🌐 Switching default browser to brave...
   🔐 Switching GitHub CLI authentication...
✅ Switched to PersonalOrg personal context
```

## Configuration Options

### Option 1: Auto VPN for Work Only (Recommended)

```bash
export WORK_VPN_CONNECT="true"
export PERSONAL_VPN_DISCONNECT="true"
export VPN_PORTAL="vpn.company.com"
```

**Behavior:**
- `work` → Connects to VPN
- `personal` → Disconnects from VPN

### Option 2: Auto VPN for Work, Manual for Personal

```bash
export WORK_VPN_CONNECT="true"
# Don't set PERSONAL_VPN_DISCONNECT
export VPN_PORTAL="vpn.company.com"
```

**Behavior:**
- `work` → Connects to VPN
- `personal` → Leaves VPN as-is (you disconnect manually if needed)

### Option 3: Manual VPN Control

```bash
# Don't set any VPN variables
```

**Behavior:**
- `work` → No VPN automation
- `personal` → No VPN automation
- You manage VPN manually

### Option 4: Different VPN Per Context (Advanced)

```bash
# Would require custom modification to support multiple portals
# Currently supports one portal for work context
```

## How It Works

### Execution Order in `work` Context

1. ✅ Configure Git
2. ✅ Switch default browser
3. ✅ **Connect VPN** ← Happens before GitHub auth
4. ✅ Switch GitHub CLI authentication (can now reach enterprise server)
5. ✅ Change directory

**Why VPN before GitHub CLI?**
- GitHub Enterprise might be behind VPN
- GitHub auth needs to reach the enterprise server
- VPN must be connected first

### Execution Order in `personal` Context

1. ✅ Configure Git
2. ✅ Switch default browser
3. ✅ **Disconnect VPN** ← Happens before GitHub auth
4. ✅ Switch GitHub CLI authentication (uses public GitHub)
5. ✅ Change directory

## VPN Commands

### Manual VPN Control

If you need to manually control VPN:

```bash
# Connect manually
globalprotect connect --portal vpn.company.com

# Or using full path
/Applications/GlobalProtect.app/Contents/MacOS/GlobalProtect connect --portal vpn.company.com

# Disconnect manually
globalprotect disconnect

# Check status
globalprotect show --status
```

### GlobalProtect CLI Options

```bash
# Connect to VPN
globalprotect connect --portal <portal>

# Disconnect from VPN
globalprotect disconnect

# Show status
globalprotect show --status

# Show VPN settings
globalprotect show --settings
```

## Verification

### Check VPN Connection Status

```bash
# After 'work' command
globalprotect show --status

# Should show: Connected to vpn.company.com
```

### Check Configuration

```bash
# Verify environment variables
echo "Work VPN: ${WORK_VPN_CONNECT:-false}"
echo "Personal VPN Disconnect: ${PERSONAL_VPN_DISCONNECT:-false}"
echo "VPN Portal: ${VPN_PORTAL:-not set}"
```

## Troubleshooting

### Issue: VPN Not Connecting

**Cause**: GlobalProtect not found or not in PATH

```bash
# Check if GlobalProtect is installed
ls /Applications/GlobalProtect.app

# Try full path
/Applications/GlobalProtect.app/Contents/MacOS/GlobalProtect connect --portal vpn.company.com

# If this works, create alias
alias globalprotect="/Applications/GlobalProtect.app/Contents/MacOS/GlobalProtect"
```

### Issue: VPN Requires Manual Approval

**Cause**: MFA or certificate required

```bash
# Some VPN setups require:
# 1. Multi-factor authentication (MFA)
# 2. Certificate approval
# 3. Manual password entry

# The script initiates connection, but you may need to:
# - Approve MFA prompt
# - Enter password
# - Approve certificate
```

**Solution**: The automation initiates the connection; complete any manual steps in the GlobalProtect popup.

### Issue: Wrong VPN Portal

**Cause**: Incorrect portal address

```bash
# Check current portal in GlobalProtect app
# Open GlobalProtect → Settings → Portal

# Update configuration
edit ~/.config/zsh/paths/paths.zsh
# Fix: export VPN_PORTAL="correct-vpn.company.com"

# Reload
source ~/.zshrc
```

### Issue: VPN Stays Connected After Personal

**Cause**: Disconnect failed or not configured

```bash
# Manually disconnect
globalprotect disconnect

# Or
/Applications/GlobalProtect.app/Contents/MacOS/GlobalProtect disconnect

# Check configuration
echo $PERSONAL_VPN_DISCONNECT  # Should be "true"
```

### Issue: Permission Denied

**Cause**: GlobalProtect requires admin privileges for some operations

```bash
# GlobalProtect may prompt for password
# This is normal - enter your macOS password when prompted
```

## Security Considerations

### 1. VPN Credentials

GlobalProtect stores credentials securely in macOS Keychain. The automation just triggers connect/disconnect - credentials are managed by GlobalProtect itself.

### 2. Auto-Disconnect Safety

Disconnecting VPN when switching to personal context:
- ✅ Prevents accidental access to work resources from personal projects
- ✅ Improves performance for personal development (no VPN overhead)
- ✅ Clear separation between work and personal environments

### 3. MFA Support

If your VPN requires MFA:
- The automation initiates the connection
- You'll be prompted for MFA (push notification, code, etc.)
- Complete the MFA prompt as normal
- Connection completes automatically

## Benefits

### ✅ Automatic Work Setup

```bash
work
# Automatically:
# 1. Connects to VPN
# 2. Switches browser
# 3. Authenticates to GitHub Enterprise (now reachable via VPN)
# 4. Sets up Git config
# Ready to work!
```

### ✅ Clean Personal Environment

```bash
personal
# Automatically:
# 1. Disconnects from VPN
# 2. Switches browser
# 3. Authenticates to public GitHub
# 4. Sets up Git config
# No work VPN overhead!
```

### ✅ Never Forget VPN

No more:
- ❌ "Why can't I access the internal GitHub?"
- ❌ "Oh, I forgot to connect to VPN"
- ❌ "Wait, why is my internet slow? Oh, VPN is still on"

## Complete Configuration Example

Here's a complete Company setup with VPN automation:

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

# VPN automation
export WORK_VPN_CONNECT="true"
export PERSONAL_VPN_DISCONNECT="true"
export VPN_PORTAL="vpn.company.com"
```

Then:

```bash
source ~/.zshrc
```

## Integration with Other Features

Your context switching now manages:

| Feature | Work Context | Personal Context |
|---------|--------------|------------------|
| **VPN** | ✅ Auto-connect | ✅ Auto-disconnect |
| Browser | Chrome | Brave |
| GitHub | github.company.com | github.com |
| Git Protocol | SSH | SSH |
| Git Email | john.doe@company.com | john@personal-org.com |

Complete workflow automation! 🚀

## Alternative: Manual VPN Aliases

If you prefer manual control, you can create aliases:

```bash
# Add to ~/.config/zsh/aliases/aliases.zsh
alias vpn-connect="globalprotect connect --portal vpn.company.com"
alias vpn-disconnect="globalprotect disconnect"
alias vpn-status="globalprotect show --status"
```

## Quick Reference

```bash
# Setup (one-time)
edit ~/.config/zsh/paths/paths.zsh
# Add:
export WORK_VPN_CONNECT="true"
export PERSONAL_VPN_DISCONNECT="true"
export VPN_PORTAL="vpn.company.com"

# Reload
source ~/.zshrc

# Daily use
work        # Auto-connects VPN
personal    # Auto-disconnects VPN

# Manual control (if needed)
globalprotect connect --portal vpn.company.com
globalprotect disconnect
globalprotect show --status
```

## Related Documentation

- **[Context Switching](CONTEXT_SWITCHING_FIXED.md)** - Main context guide
- **[GitHub Enterprise Setup](GITHUB_ENTERPRISE_SETUP.md)** - Enterprise configuration
- **[Company GitHub Setup](COMPANY_ORG_GITHUB_SETUP.md)** - Company specific guide

---

**Implemented**: October 7, 2025  
**VPN**: Palo Alto GlobalProtect  
**Configuration**: `~/.config/zsh/paths/paths.zsh`  
**Functions**: `~/.config/zsh/functions/functions.zsh`
