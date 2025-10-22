# GlobalProtect VPN Troubleshooting

**Issue**: "Detected another instance - An old GlobalProtect instance exists, new instance cannot be started!"

## Quick Fix

If you keep getting this error, the easiest solution is to **disable VPN automation** and manage VPN manually.

### Option 1: Disable VPN Automation (Recommended)

Edit `~/.config/zsh/paths/paths.zsh`:

```bash
# Comment out VPN automation
# export WORK_VPN_CONNECT="true"
# export PERSONAL_VPN_DISCONNECT="true"
# export VPN_PORTAL="sap.gpcloudservice.com"
```

Then reload:
```bash
source ~/.zshrc
```

**Manual VPN workflow:**
```bash
# Start your work day
work                          # Switches context (no VPN)
# Then manually connect VPN using GlobalProtect app

# End work day
personal                      # Switches context (no VPN)
# Manually disconnect VPN if needed
```

### Option 2: Kill GlobalProtect Manually Before Context Switch

```bash
# Before running 'work'
killall -9 GlobalProtect PanGPS PanGPA
work

# Before running 'personal'  
killall -9 GlobalProtect PanGPS PanGPA
personal
```

### Option 3: Use GlobalProtect App Manually

Just keep GlobalProtect app running and connect/disconnect using the GUI:
1. Click GlobalProtect icon in menu bar
2. Click Connect/Disconnect button
3. Much more reliable than CLI automation

## Why This Happens

GlobalProtect has multiple processes:
- `GlobalProtect` - Main app
- `PanGPS` - VPN service
- `PanGPA` - Authentication agent

When one process doesn't exit cleanly, it blocks new instances. The automation tries to kill all of them, but sometimes they're protected by macOS.

## Manual VPN Aliases (Alternative)

Add these to your `~/.config/zsh/aliases/aliases.zsh`:

```bash
# GlobalProtect VPN shortcuts
alias vpn-on="open -a GlobalProtect && sleep 2 && /Applications/GlobalProtect.app/Contents/MacOS/GlobalProtect connect --portal sap.gpcloudservice.com"
alias vpn-off="killall -9 GlobalProtect PanGPS PanGPA"
alias vpn-status="ps aux | grep -i globalprotect | grep -v grep"
```

Then use:
```bash
work
vpn-on      # Connect manually

personal
vpn-off     # Disconnect manually
```

## Full Reset (If Really Stuck)

```bash
# 1. Force kill everything
sudo killall -9 GlobalProtect PanGPS PanGPA

# 2. Remove GlobalProtect cache
rm -rf ~/Library/Caches/com.paloaltonetworks.GlobalProtect*

# 3. Restart GlobalProtect
open -a GlobalProtect

# 4. Reconnect
```

## Recommended Setup

For most users, the simplest approach is:

1. **Keep VPN automation disabled**
2. **Use GlobalProtect GUI** - Click the menu bar icon to connect/disconnect
3. **Or use manual aliases** - `vpn-on` / `vpn-off`

The context switching still handles everything else automatically:
- ✅ Git config
- ✅ GitHub CLI authentication  
- ✅ Browser switching
- ✅ Working directory
- ✅ Database ports

Only VPN needs manual management. This is actually more reliable since VPN requires MFA anyway.

---

**Note**: VPN automation was added for convenience, but GlobalProtect's architecture makes it difficult to automate reliably. Manual management is simpler and more stable.
