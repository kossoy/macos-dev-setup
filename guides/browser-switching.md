# Browser Switching with Context Switching 🌐

**Status**: ✅ **IMPLEMENTED**
**Setup Time**: ~2 minutes for quick start
**Date**: October 2025

---

## 🚀 Quick Start (2 Minutes)

### What You Get

When you run `work` or `personal`, your default browser automatically switches:
- **Work context** → Chrome (or your choice)
- **Personal context** → Safari (or your choice)

### Setup in 4 Steps

#### Step 1: Install `defaultbrowser` Tool

```bash
brew install defaultbrowser
```

#### Step 2: (Optional) Customize Your Browser Preferences

Edit `~/.config/zsh/private/work-personal-config.zsh` and set:

```bash
# Browser preferences for context switching
export WORK_BROWSER="chrome"          # or: safari, firefox, edge, brave, arc
export PERSONAL_BROWSER="safari"      # or: chrome, firefox, edge, brave, arc
```

**Popular Combinations:**

```bash
# Option 1: Chrome for work, Safari for personal (recommended)
export WORK_BROWSER="chrome"
export PERSONAL_BROWSER="safari"

# Option 2: Chrome for work, Firefox for personal (privacy-focused)
export WORK_BROWSER="chrome"
export PERSONAL_BROWSER="firefox"

# Option 3: Edge for work, Brave for personal
export WORK_BROWSER="edge"
export PERSONAL_BROWSER="brave"
```

#### Step 3: Reload Your Shell

```bash
source ~/.zshrc
```

#### Step 4: Test It!

```bash
# Switch to work context
work
# Your default browser changes to Chrome (or your WORK_BROWSER)

# Open a link to verify
open https://github.com
# Should open in Chrome

# Switch to personal context
personal
# Your default browser changes to Safari (or your PERSONAL_BROWSER)

# Open a link to verify
open https://github.com
# Should open in Safari

# Check current context
show-context
# Shows current browser among other details
```

### Supported Browsers

| Browser | Value | Notes |
|---------|-------|-------|
| **Google Chrome** | `chrome` | Most popular for work |
| **Safari** | `safari` | macOS native, best battery |
| **Firefox** | `firefox` | Privacy-focused |
| **Microsoft Edge** | `edge` | Enterprise features |
| **Brave** | `brave` | Privacy + Chrome compatibility |
| **Arc** | `arc` | Modern with built-in Spaces |

### Complete Context Switching Features

Your `work` and `personal` commands now manage:

| Feature | What Changes |
|---------|--------------|
| ✅ Git Config | Email and name |
| ✅ GitHub CLI | Authenticated account |
| ✅ Browser | Default browser |
| ✅ Directory | Project folder |
| ✅ Database | Connection ports |
| ✅ Environment | Context variables |

---

## 📖 Complete Setup Guide

### Overview

Your context switching functions automatically change the default web browser when switching between work and personal contexts. This provides complete environment isolation for browsing, debugging, and web-based work.

**Important**: The browser is switched **before** GitHub CLI authentication, ensuring that `gh auth login` opens in the correct browser for the context.

### Use Cases

#### Why Switch Browsers by Context?

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

### Configuration

#### Default Browser Settings

If you don't set `WORK_BROWSER` and `PERSONAL_BROWSER`, the context functions use these defaults:
- **Work context**: Chrome (`chrome`)
- **Personal context**: Safari (`safari`)

#### Customize Browser Preferences

Add these to your `~/.config/zsh/private/work-personal-config.zsh`:

```bash
# Work browser: chrome, firefox, safari, edge, brave, arc
export WORK_BROWSER="chrome"

# Personal browser: chrome, firefox, safari, edge, brave, arc
export PERSONAL_BROWSER="safari"
```

### Usage

#### Automatic Switching

Browser switching happens automatically when you change contexts:

```bash
$ work
🏢 Switching to work context...
   🌐 Switching default browser...
   🔐 Switching GitHub CLI authentication...
✅ Switched to work context
   Git: john.doe@company.com
   Projects: ~/work/projects/work
   Database: localhost:5432
```

```bash
$ personal
🏠 Switching to personal context...
   🌐 Switching default browser...
   🔐 Switching GitHub CLI authentication...
✅ Switched to personal context
   Git: john@personal.com
   Projects: ~/work/projects/personal
   Database: localhost:5433
```

#### Verify Current Browser

```bash
$ show-context
════════════════════════════════════════
📋 Current Development Context
════════════════════════════════════════

🏢 Context: Work

📧 Git Configuration:
   Name:  John Doe
   Email: john.doe@company.com

🔐 GitHub CLI:
   Logged in as: johndoe

🌐 Default Browser:
   Current: chrome

📁 Paths:
   Projects: ~/work/projects/work
   ...
```

#### Manual Browser Switching

You can also manually change the default browser:

```bash
# Set Chrome as default
defaultbrowser chrome

# Set Safari as default
defaultbrowser safari

# Check current default
defaultbrowser
```

### Configuration Examples

#### Example 1: Chrome for Work, Safari for Personal

```bash
export WORK_BROWSER="chrome"
export PERSONAL_BROWSER="safari"
```

**Use case:**
- Chrome for work with Google Workspace integration
- Safari for personal browsing (better battery life on Mac)

#### Example 2: Chrome for Work, Firefox for Personal

```bash
export WORK_BROWSER="chrome"
export PERSONAL_BROWSER="firefox"
```

**Use case:**
- Chrome for work compatibility
- Firefox for personal privacy

#### Example 3: Edge for Work, Brave for Personal

```bash
export WORK_BROWSER="edge"
export PERSONAL_BROWSER="brave"
```

**Use case:**
- Edge for Microsoft 365 integration
- Brave for personal privacy + Chrome extension compatibility

### Advanced Setup

#### Per-Context Browser Profiles

**Chrome Profiles:**

1. Open Chrome
2. Click profile icon → "Add profile"
3. Create "Work" and "Personal" profiles
4. Set different Google accounts, extensions, bookmarks

**Firefox Containers:**

1. Install "Firefox Multi-Account Containers" extension
2. Create "Work" and "Personal" containers
3. Assign work sites to Work container
4. Assign personal sites to Personal container

#### Browser-Specific Extensions

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

### Workflow Examples

#### Example 1: Starting Work Day

```bash
# Open terminal
work                           # Switches to work context + Chrome

# All web links now open in Chrome
# - Documentation links from terminal
# - GitHub OAuth flows
# - Cursor authentication
# - npm package pages
```

#### Example 2: Evening Personal Projects

```bash
# Switch to personal context
personal                       # Switches to personal context + Safari

# All web links now open in Safari
# - Personal GitHub repos
# - Stack Overflow research
# - Personal documentation
```

### Troubleshooting

#### Issue: Browser Doesn't Switch

**Cause:** `defaultbrowser` not installed

```bash
# Check if installed
which defaultbrowser

# If not found, install
brew install defaultbrowser

# Reload shell
source ~/.zshrc
```

#### Issue: Wrong Browser Opens

**Cause:** Environment variable not set or wrong value

```bash
# Check current variables
echo $WORK_BROWSER
echo $PERSONAL_BROWSER

# Set in ~/.config/zsh/private/work-personal-config.zsh
export WORK_BROWSER="chrome"
export PERSONAL_BROWSER="safari"

# Reload configuration
source ~/.zshrc

# Test
work
show-context  # Should show correct browser
```

#### Issue: Browser Not Recognized

**Cause:** Browser not installed or wrong identifier

```bash
# List available browsers
defaultbrowser

# Check if your browser is listed
# Use exact name from the list
```

#### Issue: Permission Denied

**Cause:** macOS security settings

```bash
# Grant terminal full disk access
# System Settings → Privacy & Security → Full Disk Access
# Add Terminal.app or iTerm.app

# Try again
work
```

### Testing

```bash
# Test work context
work
show-context                   # Should show work browser
defaultbrowser                 # Should show work browser as default
open https://github.com       # Should open in work browser

# Test personal context
personal
show-context                   # Should show personal browser
defaultbrowser                 # Should show personal browser as default
open https://github.com       # Should open in personal browser
```

---

## 🆚 Comparison: Browser Switching vs. Browser Profiles

### Quick Comparison

Should you use **default browser switching** (different browsers per context) or **browser profiles** (one browser, multiple profiles)?

| Feature | Default Browser Switching | Browser Profiles |
|---------|--------------------------|------------------|
| **Automatic Switching** | ✅ Fully automatic via context commands | ⚠️ Manual profile selection needed |
| **Visual Distinction** | ✅✅ Completely different browser UI | ⚠️ Same UI, small profile indicator |
| **Setup Complexity** | ⚠️ Configure two browsers | ✅ Configure one browser |
| **Maintenance** | ⚠️ Update/manage two browsers | ✅ Single browser to maintain |
| **Accidental Mixing** | ✅✅ Nearly impossible | ⚠️⚠️ Easy to use wrong profile |
| **OS-Level Isolation** | ✅ Complete separation | ❌ Same browser instance |
| **Disk Space** | ⚠️ ~500MB-1GB per browser | ✅ ~450MB total |

### Approach 1: Default Browser Switching (Current) ✅

#### Pros

1. **Complete OS-Level Isolation**
   - System enforces separation
   - No way to accidentally open work link in personal browser
   - Each browser is completely independent

2. **Clear Visual Distinction**
   - Chrome (colorful interface) vs Safari (minimalist)
   - Instantly know which context you're in
   - Different window styles, toolbars, icons

3. **Fully Automatic**
   ```bash
   work                    # Browser switches automatically
   open https://github.com # Opens in Chrome

   personal               # Browser switches automatically
   open https://github.com # Opens in Safari
   ```
   No manual profile selection needed

4. **Different Browser Capabilities**
   - Safari: Better Mac integration, battery efficiency
   - Chrome: Google Workspace integration, more extensions
   - Firefox: Superior privacy features
   - Choose best tool for each context

#### Cons

1. **Duplicate Setup Required**
   - Must configure both browsers separately
   - Install extensions in each browser
   - Set up bookmarks twice

2. **More Disk Space** (~500MB additional)

3. **Different Extension Availability**
   - Some extensions only for Chrome/Chromium
   - Safari extensions more limited

### Approach 2: Browser Profiles

#### Pros

1. **Single Browser to Maintain**
   - One installation, one update process
   - Consistent UI and keyboard shortcuts

2. **Full Extension Library**
   - All Chrome Web Store extensions work
   - Same extensions available to both profiles

3. **Less Disk Space** (~450MB total vs ~700MB+)

#### Cons

1. **NOT Automatic** ⚠️⚠️
   ```bash
   # With default browser switching:
   work                    # Browser switches automatically

   # With browser profiles:
   work                    # Only switches git/github/database
                          # Must manually switch browser profile
   ```
   **This breaks your automatic workflow**

2. **Easy to Use Wrong Profile** ⚠️⚠️
   - High risk of mistakes when switching frequently
   - Same browser, easy to forget which profile is active

3. **Less Visual Distinction**
   - Same window style, icon, tabs
   - Only small profile indicator to distinguish

### Side-by-Side Workflow

#### With Default Browser Switching

```bash
# Morning work
$ work
$ open https://company-docs.com
# Opens in Chrome ✅

# Lunch break - personal project
$ personal
$ open https://github.com/personal/project
# Opens in Safari ✅

# Back to work
$ work
$ open https://jira.company.com
# Opens in Chrome ✅
```
**Zero manual steps, zero cognitive load**

#### With Browser Profiles

```bash
# Morning work
$ work
$ open https://company-docs.com
# Opens in browser... need to check which profile
# Manual verification and switching required

# Lunch break - personal project
$ personal
$ open https://github.com/personal/project
# Opens in browser... in work profile 🚨
# Need to manually switch profile (4-5 clicks)

# Back to work
$ work
$ open https://jira.company.com
# Opens in browser... in personal profile 🚨
# Need to manually switch again
```
**Constant manual intervention required**

### Recommendation

**For your automatic context switching workflow: Use Default Browser Switching** ✅

**Why:**
1. **Automatic** - No manual steps, preserves your workflow
2. **OS-Enforced** - Impossible to use wrong browser by accident
3. **Visual** - Immediately obvious which context you're in
4. **Isolated** - Complete separation at system level
5. **Proven** - Already working well

**Recommended Configuration:**

```bash
# Work: Chrome (best for corporate environment)
export WORK_BROWSER="chrome"

# Personal: Safari (built-in, great for personal use)
export PERSONAL_BROWSER="safari"
```

**Alternative if you want Chromium for both:**

```bash
# Work: Chrome
export WORK_BROWSER="chrome"

# Personal: Brave (Chromium-based, privacy-focused)
export PERSONAL_BROWSER="brave"
```

### When Browser Profiles Might Work

Browser profiles could work better if:
- You **rarely** switch contexts (once or twice per day max)
- You need Chromium for both contexts
- You're highly disciplined about manual switching
- You want Brave-specific features in both contexts

But for **frequent context switching with automatic workflow**, default browser switching is superior.

---

## 📚 Related Documentation

- **[Context Switching Guide](context-switching.md)** - Main context switching documentation
- **[GitHub CLI Integration](github-cli-integration.md)** - GitHub CLI setup
- **[Quick Reference](../reference/quick-reference.md)** - Command reference

---

## 💡 Benefits Summary

### ✅ Complete Context Isolation

| Feature | Work Context | Personal Context |
|---------|--------------|------------------|
| Browser | Chrome | Safari |
| Logins | Work accounts | Personal accounts |
| Bookmarks | Work resources | Personal sites |
| Extensions | Enterprise tools | Privacy tools |
| History | Work browsing | Personal browsing |

### ✅ Prevents Mistakes

- No more logging into personal GitHub on work browser
- No more work documents in personal browser history
- No more accidental commits with wrong browser profile
- No more confusion about which account is logged in

### ✅ Automatic Workflow

```bash
# Morning: Start work
work                          # Everything switches to work mode
open https://docs.company.com # Opens in work browser

# Evening: Personal projects
personal                      # Everything switches to personal mode
open https://myproject.com    # Opens in personal browser
```

---

**Requirements**: `defaultbrowser` (install with `brew install defaultbrowser`)
**Configuration**: `~/.config/zsh/private/work-personal-config.zsh`
**Implementation**: `config/zsh/config/functions.zsh`
