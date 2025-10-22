# Browser Switching with Context Switching 🌐

**Date**: October 7, 2025  
**Status**: ✅ **IMPLEMENTED**

## Overview

Your context switching functions now automatically change the default web browser when switching between work and personal contexts. This provides complete environment isolation for browsing, debugging, and web-based work.

**Important**: The browser is switched **before** GitHub CLI authentication, ensuring that `gh auth login` opens in the correct browser for the context.

## Use Cases

### Why Switch Browsers by Context?

**Work Context (e.g., Chrome):**
- Enterprise SSO logins stay in work browser
- Work bookmarks and extensions
- Company VPN or security tools
- Separate browsing history
- Work-related saved passwords

**Personal Context (e.g., Safari/Firefox):**
- Personal accounts and logins
- Personal bookmarks and extensions
- Different privacy settings
- Personal browsing history
- Personal saved passwords

## Installation

### 1. Install `defaultbrowser` Tool

```bash
# Install via Homebrew
brew install defaultbrowser

# Verify installation
defaultbrowser --version
```

### 2. Check Available Browsers

```bash
# List all installed browsers
defaultbrowser

# Output example:
# Available browsers:
#   chrome
#   safari
#   firefox
#   edge
#   brave
#   arc
```

## Configuration

### Default Browser Settings

The context functions use these defaults:
- **Work context**: Chrome (`chrome`)
- **Personal context**: Safari (`safari`)

### Customize Browser Preferences

You can customize which browsers to use by setting environment variables in your `~/.config/zsh/paths/paths.zsh`:

```bash
# Add to ~/.config/zsh/paths/paths.zsh

# Work browser: chrome, firefox, safari, edge, brave, arc
export WORK_BROWSER="chrome"

# Personal browser: chrome, firefox, safari, edge, brave, arc
export PERSONAL_BROWSER="safari"
```

### Supported Browser Values

| Browser | Value | Notes |
|---------|-------|-------|
| Google Chrome | `chrome` | Most common for work |
| Safari | `safari` | macOS default |
| Firefox | `firefox` | Privacy-focused |
| Microsoft Edge | `edge` | Enterprise alternative |
| Brave | `brave` | Privacy + Chrome compatibility |
| Arc | `arc` | Modern browser with workspaces |

## Usage

### Automatic Switching

Browser switching happens automatically when you change contexts. **Note**: The browser switches **before** GitHub CLI authentication so that `gh auth login` opens in the correct browser:

```bash
$ work
🏢 Switching to Company work context...
   🌐 Switching default browser to chrome...
   🔐 Switching GitHub CLI authentication...
   # Browser opens in Chrome for authentication
✅ Switched to Company work context
   Git: john.doe@company.com
   Projects: /Users/user123/work/projects/work
   Database: localhost:5432
```

```bash
$ personal
🏠 Switching to PersonalOrg personal context...
   🌐 Switching default browser to safari...
   🔐 Switching GitHub CLI authentication...
   # Browser opens in Safari for authentication
✅ Switched to PersonalOrg personal context
   Git: john@personal-org.com
   Projects: /Users/user123/work/projects/personal
   Database: localhost:5433
```

### Verify Current Browser

```bash
$ show-context
════════════════════════════════════════
📋 Current Development Context
════════════════════════════════════════

🏢 Context: Company (Work)

📧 Git Configuration:
   Name:  John Doe
   Email: john.doe@company.com

🔐 GitHub CLI:
   Logged in as: johndoe

🌐 Default Browser:
   Current: chrome

📁 Paths:
   Projects: /Users/user123/work/projects/work
   ...
```

### Manual Browser Switching

You can also manually change the default browser:

```bash
# Set Chrome as default
defaultbrowser chrome

# Set Safari as default
defaultbrowser safari

# Set Firefox as default
defaultbrowser firefox

# Check current default
defaultbrowser
```

## Configuration Examples

### Example 1: Chrome for Work, Safari for Personal

Add to `~/.config/zsh/paths/paths.zsh`:

```bash
export WORK_BROWSER="chrome"
export PERSONAL_BROWSER="safari"
```

**Use case:**
- Chrome for work with Google Workspace integration
- Safari for personal browsing (better battery life on Mac)

### Example 2: Chrome for Work, Firefox for Personal

```bash
export WORK_BROWSER="chrome"
export PERSONAL_BROWSER="firefox"
```

**Use case:**
- Chrome for work compatibility
- Firefox for personal privacy

### Example 3: Edge for Work, Brave for Personal

```bash
export WORK_BROWSER="edge"
export PERSONAL_BROWSER="brave"
```

**Use case:**
- Edge for Microsoft 365 integration
- Brave for personal privacy + Chrome extension compatibility

### Example 4: Arc for Both (Different Spaces)

```bash
export WORK_BROWSER="arc"
export PERSONAL_BROWSER="arc"
```

**Use case:**
- Arc's built-in Spaces feature for organization
- Still gets browser switch signal to open Arc

### Example 5: Context-Specific Chrome Profiles

Even with the same browser, you can use different profiles:

```bash
# Still set different browsers to trigger the switch
export WORK_BROWSER="chrome"
export PERSONAL_BROWSER="chrome"

# Then manually configure Chrome profiles in each context
# Work: Open Chrome → Profile → Work Profile
# Personal: Open Chrome → Profile → Personal Profile
```

## Advanced Setup

### Per-Context Browser Profiles

#### Chrome Profiles

**Setup:**
1. Open Chrome
2. Click profile icon → "Add profile"
3. Create "Work" and "Personal" profiles
4. Set different Google accounts, extensions, bookmarks

**Usage:**
```bash
# After 'work' command, Chrome opens
# Switch to "Work" profile in Chrome

# After 'personal' command, Chrome opens
# Switch to "Personal" profile in Chrome
```

#### Firefox Containers

If using Firefox for both contexts:

1. Install "Firefox Multi-Account Containers" extension
2. Create "Work" and "Personal" containers
3. Assign work sites to Work container
4. Assign personal sites to Personal container

### Browser-Specific Extensions

**Work Browser (Chrome):**
- Corporate VPN extensions
- Enterprise SSO tools
- Work-related developer tools
- Jira, Confluence integrations
- Company security tools

**Personal Browser (Safari/Firefox):**
- Ad blockers
- Privacy extensions
- Personal bookmarks sync
- Personal social media tools

### Bookmarks Management

**Work Bookmarks:**
- Internal company tools
- Work documentation
- Team resources
- Project management tools

**Personal Bookmarks:**
- Personal projects
- Learning resources
- Social media
- Entertainment

## Workflow Examples

### Example 1: Starting Work Day

```bash
# Open terminal
work                           # Switches to work context + Chrome

# All web links now open in Chrome
# - Documentation links from terminal
# - GitHub OAuth flows
# - Cursor authentication
# - npm package pages
```

### Example 2: Evening Personal Projects

```bash
# Switch to personal context
personal                       # Switches to personal context + Safari

# All web links now open in Safari
# - Personal GitHub repos
# - Stack Overflow research
# - Personal documentation
```

### Example 3: Quick Context Check

```bash
# Verify current setup
show-context

# Shows:
# - Context: Work/Personal
# - Git config
# - GitHub CLI user
# - Default browser: chrome/safari
# - Database ports
```

## Troubleshooting

### Issue: Browser Doesn't Switch

**Cause:** `defaultbrowser` not installed

```bash
# Check if installed
which defaultbrowser

# If not found, install
brew install defaultbrowser

# Reload shell
source ~/.zshrc
```

### Issue: Wrong Browser Opens

**Cause:** Environment variable not set or wrong value

```bash
# Check current variables
echo $WORK_BROWSER
echo $PERSONAL_BROWSER

# Set in ~/.config/zsh/paths/paths.zsh
export WORK_BROWSER="chrome"
export PERSONAL_BROWSER="safari"

# Reload configuration
source ~/.zshrc

# Test
work
show-context  # Should show correct browser
```

### Issue: Browser Not Recognized

**Cause:** Browser not installed or wrong identifier

```bash
# List available browsers
defaultbrowser

# Check if your browser is listed
# Use exact name from the list

# Example: If using "Google Chrome", value should be "chrome"
# Example: If using "Microsoft Edge", value should be "edge"
```

### Issue: Permission Denied

**Cause:** macOS security settings

```bash
# Grant terminal full disk access
# System Settings → Privacy & Security → Full Disk Access
# Add Terminal.app or iTerm.app

# Try again
work
```

### Issue: Settings Don't Persist

**Cause:** Browser settings override

```bash
# Some browsers (especially Safari) may ask to be default again
# You can either:

# 1. Allow automatic switching (recommended)
# Just let the context functions handle it

# 2. Disable browser's "Set as default" prompts
# In browser settings, disable "Check if default browser"
```

## Testing

### Test Browser Switching

```bash
# Test work context
work
show-context                   # Should show work browser
defaultbrowser                 # Should show work browser as default

# Open a link
open https://github.com       # Should open in work browser

# Test personal context
personal
show-context                   # Should show personal browser
defaultbrowser                 # Should show personal browser as default

# Open a link
open https://github.com       # Should open in personal browser
```

### Test Environment Variables

```bash
# Check if variables are set
echo "Work: $WORK_BROWSER"
echo "Personal: $PERSONAL_BROWSER"

# Should output:
# Work: chrome
# Personal: safari

# Or your custom values
```

## Benefits

### ✅ Complete Context Isolation

| Feature | Work Context | Personal Context |
|---------|--------------|------------------|
| Browser | Chrome | Safari |
| Logins | Work accounts | Personal accounts |
| Bookmarks | Work resources | Personal sites |
| Extensions | Enterprise tools | Privacy tools |
| History | Work browsing | Personal browsing |
| Profiles | Work profile | Personal profile |

### ✅ Automatic Workflow

```bash
# Morning: Start work
work                          # Everything switches to work mode
open https://docs.company.com # Opens in work browser

# Evening: Personal projects
personal                      # Everything switches to personal mode
open https://myproject.com    # Opens in personal browser
```

### ✅ Prevents Mistakes

- No more logging into personal GitHub on work browser
- No more work documents in personal browser history
- No more accidental commits with wrong browser profile
- No more confusion about which account is logged in

## Integration with Other Context Features

Your context switching now manages:

1. **Git Configuration** ✅
   - User name and email

2. **GitHub CLI Authentication** ✅
   - GitHub account switching

3. **Default Web Browser** ✅ **NEW!**
   - Browser switching

4. **Working Directory** ✅
   - Project folder switching

5. **Database Connections** ✅
   - Port and credential switching

6. **Environment Variables** ✅
   - Context-specific variables

## Related Documentation

- **[Context Switching Fixed](CONTEXT_SWITCHING_FIXED.md)** - Main context switching guide
- **[GitHub CLI Integration](GITHUB_CLI_INTEGRATION.md)** - GitHub CLI setup
- **[Quick Reference](reference/quick-reference.md)** - Command reference

## Next Steps

1. **Install defaultbrowser**:
   ```bash
   brew install defaultbrowser
   ```

2. **Configure browser preferences** (optional):
   ```bash
   # Edit ~/.config/zsh/paths/paths.zsh
   export WORK_BROWSER="chrome"
   export PERSONAL_BROWSER="safari"
   ```

3. **Reload shell**:
   ```bash
   source ~/.zshrc
   ```

4. **Test it**:
   ```bash
   work
   show-context
   open https://github.com  # Should open in work browser
   
   personal
   show-context
   open https://github.com  # Should open in personal browser
   ```

5. **Set up browser profiles** for complete isolation

---

**Implemented**: October 7, 2025  
**Requirements**: `defaultbrowser` (install with `brew install defaultbrowser`)  
**Location**: `~/.config/zsh/functions/functions.zsh`  
**Configuration**: `~/.config/zsh/paths/paths.zsh` (optional customization)
