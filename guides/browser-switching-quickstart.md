# Browser Switching - Quick Start Guide 🚀

**Setup Time**: ~2 minutes  
**Date**: October 7, 2025

## What You Get

When you run `work` or `personal`, your default browser automatically switches:
- **Work context** → Chrome (default) or your choice
- **Personal context** → Safari (default) or your choice

## Quick Setup

### Step 1: Install `defaultbrowser` Tool

```bash
brew install defaultbrowser
```

### Step 2: (Optional) Customize Your Browser Preferences

Edit `~/.config/zsh/paths/paths.zsh` and add:

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

# Option 4: Arc for both (use Arc's Spaces feature)
export WORK_BROWSER="arc"
export PERSONAL_BROWSER="arc"
```

### Step 3: Reload Your Shell

```bash
source ~/.zshrc
```

### Step 4: Test It!

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

## Supported Browsers

| Browser | Value | Notes |
|---------|-------|-------|
| **Google Chrome** | `chrome` | Most popular for work |
| **Safari** | `safari` | macOS native, best battery |
| **Firefox** | `firefox` | Privacy-focused |
| **Microsoft Edge** | `edge` | Enterprise features |
| **Brave** | `brave` | Privacy + Chrome compatibility |
| **Arc** | `arc` | Modern with built-in Spaces |

## Default Behavior (Without Configuration)

If you don't set `WORK_BROWSER` and `PERSONAL_BROWSER`:
- **Work** → Chrome
- **Personal** → Safari

## Verify It's Working

```bash
# Check which browser is currently default
defaultbrowser

# Should show something like:
# Google Chrome.app

# After switching contexts
work
defaultbrowser
# Should show work browser

personal
defaultbrowser
# Should show personal browser
```

## Complete Context Switching Features

Your `work` and `personal` commands now manage:

| Feature | What Changes |
|---------|--------------|
| ✅ Git Config | Email and name |
| ✅ GitHub CLI | Authenticated account |
| ✅ Browser | Default browser |
| ✅ Directory | Project folder |
| ✅ Database | Connection ports |
| ✅ Environment | Context variables |

## Troubleshooting

### Browser Doesn't Switch

```bash
# Check if defaultbrowser is installed
which defaultbrowser

# If not found
brew install defaultbrowser

# Reload shell
source ~/.zshrc
```

### Want to Check Current Settings

```bash
# Check current browser environment variables
echo "Work: $WORK_BROWSER"
echo "Personal: $PERSONAL_BROWSER"

# Check current default browser
defaultbrowser

# Check complete context
show-context
```

### Manual Browser Switch

```bash
# Set Chrome as default manually
defaultbrowser chrome

# Set Safari as default manually
defaultbrowser safari

# List all available browsers
defaultbrowser
```

## Use Cases

### Scenario 1: Separate Work/Personal Logins

**Setup:**
- Work: Chrome with work Google account
- Personal: Safari with personal accounts

**Benefits:**
- Work Gmail, Calendar, Drive in Chrome
- Personal accounts in Safari
- No accidental mixing of accounts

### Scenario 2: Privacy-Focused Personal Browsing

**Setup:**
- Work: Chrome (for compatibility)
- Personal: Firefox or Brave (for privacy)

**Benefits:**
- Chrome for work tools that require it
- Enhanced privacy for personal browsing

### Scenario 3: Browser-Specific Development

**Setup:**
- Work: Chrome (with work extensions)
- Personal: Firefox or Safari (for testing)

**Benefits:**
- Different browser dev tools
- Testing cross-browser compatibility
- Separate extension sets

## Next Steps

1. **Set up browser profiles** within each browser for extra isolation
2. **Install context-specific extensions**:
   - Work: Enterprise tools, VPN, etc.
   - Personal: Privacy tools, ad blockers
3. **Organize bookmarks** per context
4. **Configure browser sync** separately

## Full Documentation

For comprehensive setup, customization, and advanced features:
- **[Browser Switching Guide](BROWSER_SWITCHING.md)** - Complete guide
- **[Context Switching](CONTEXT_SWITCHING_FIXED.md)** - Main context switching docs

---

**Quick Reference:**

```bash
# Install
brew install defaultbrowser

# Configure (optional)
# Edit ~/.config/zsh/paths/paths.zsh
# Add: export WORK_BROWSER="chrome"
# Add: export PERSONAL_BROWSER="safari"

# Reload
source ~/.zshrc

# Use
work                    # Switches to work context + browser
personal                # Switches to personal context + browser
show-context            # Shows current context + browser
```

**Questions?** See [BROWSER_SWITCHING.md](BROWSER_SWITCHING.md) for detailed documentation.
