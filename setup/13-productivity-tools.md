# Productivity Tools & Applications

Complete setup for productivity applications via Setapp and other sources.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Homebrew installed
- Valid Setapp subscription (optional, but recommended)

## 1. Setapp (App Subscription Service)

Setapp provides access to 240+ premium Mac applications for a single subscription fee.

### Installation

```bash
# Install Setapp
brew install --cask setapp

# Launch Setapp
open -a Setapp
```

### First-Time Setup

1. **Sign Up or Sign In**
   - Open Setapp from Applications or menu bar
   - Create account or sign in
   - Choose subscription plan (7-day free trial available)

2. **Grant Permissions**
   - Allow Setapp in System Settings → Privacy & Security
   - Enable Accessibility permissions if prompted

3. **Configure Preferences**
   - Setapp menu → Preferences
   - Choose auto-update behavior
   - Configure menu bar icon visibility
   - Set default download location

### How Setapp Works

- All apps available through Setapp app
- Apps install to `/Applications/Setapp/`
- Apps remain functional as long as subscription is active
- Automatic updates managed by Setapp
- Single subscription covers unlimited installations

## 2. Essential Setapp Applications

### Paste (Clipboard Manager)

Advanced clipboard manager with history, organization, and search.

```bash
# Search for Paste in Setapp
# Or install directly:
open -a Setapp
# Search for "Paste" and click Install
```

**Features:**
- Unlimited clipboard history
- Pinboard for frequently used items
- Smart search and filters
- iCloud sync across devices
- Keyboard shortcuts

**Usage:**
```
Cmd+Shift+V    - Open Paste
Cmd+Shift+C    - Open Pinboard
Type to search - Find clipboard item
Enter          - Paste selected item
```

**Configuration:**
1. Launch Paste
2. Preferences → General
   - Enable "Launch at Login"
   - Set hotkey (default: Cmd+Shift+V)
3. Preferences → Storage
   - Set history duration (default: 1 year)
   - Enable iCloud sync (optional)

### CleanMyMac X (System Maintenance)

Comprehensive Mac cleaning and optimization tool.

```bash
# Install via Setapp
# Search for "CleanMyMac X" and install
```

**Features:**
- System cleanup (cache, logs, temp files)
- Malware removal
- App uninstaller (with leftover cleanup)
- Optimization tools
- Privacy protection

**Common Tasks:**
```
Smart Scan              - Quick system cleanup
Malware Removal         - Security scan
Uninstaller             - Remove apps completely
Maintenance → Free Up   - Quick space recovery
```

### Bartender (Menu Bar Manager)

Organize and hide menu bar icons.

```bash
# Install via Setapp
# Search for "Bartender" and install
```

**Features:**
- Hide unused menu bar icons
- Organize icons by category
- Search menu bar items
- Keyboard shortcuts for quick access

**Setup:**
1. Launch Bartender
2. Grant Accessibility permissions
3. Arrange icons:
   - Drag to "Hidden" section to hide
   - Drag to "Shown" section to always show
4. Set hotkey to reveal hidden items

### iStat Menus (System Monitor)

Advanced system monitoring in menu bar.

```bash
# Install via Setapp
# Search for "iStat Menus" and install
```

**Features:**
- CPU, memory, disk, network monitoring
- Temperature sensors
- Battery status
- Calendar and world clock
- Customizable menu bar display

**Configuration:**
1. Launch iStat Menus
2. Preferences → Choose modules to enable
3. Customize what to display in menu bar
4. Set update intervals

### Ulysses (Writing App)

Professional writing application with markdown support.

```bash
# Install via Setapp
# Search for "Ulysses" and install
```

**Features:**
- Distraction-free writing
- Markdown support
- iCloud sync
- Export to various formats
- Organization with groups and filters

### TablePlus (Database GUI)

Modern, native database management tool.

```bash
# Install via Setapp
# Search for "TablePlus" and install
```

**Features:**
- Supports multiple databases (PostgreSQL, MySQL, SQLite, Redis, etc.)
- Native M1 support
- Fast and lightweight
- Multiple tabs and windows
- SQL autocomplete

**Quick Setup:**
```bash
# Launch TablePlus
open -a TablePlus

# Create connection
# Click "Create a new connection"
# Choose database type
# Enter connection details:
# - Host: localhost
# - Port: 5434 (or your database port)
# - User: your_user
# - Password: your_password
# - Database: your_database
```

### Permute (Media Converter)

Video, audio, and image format converter.

```bash
# Install via Setapp
# Search for "Permute" and install
```

**Features:**
- Convert video, audio, images
- Batch processing
- Drag-and-drop interface
- Preset conversions
- No quality loss

## 3. Other Recommended Setapp Apps

### Development Tools

- **Dash** - API documentation browser
- **RapidAPI** - API testing tool
- **Proxyman** - HTTP debugging proxy
- **Git Tower** - Git client
- **Kaleidoscope** - Diff and merge tool

### Productivity

- **Taskheat** - Visual task management
- **Focus** - Distraction blocker
- **Session** - Pomodoro timer
- **Mind Node** - Mind mapping

### Utilities

- **Archiver** - Archive management
- **Get Plain Text** - Text formatting cleaner
- **Image2icon** - Icon creator
- **Numi** - Calculator with text
- **PDF Search** - Search across PDFs

## 4. Alternative Installation Methods

### For Apps Not in Setapp

```bash
# Using Homebrew Cask
brew install --cask app-name

# Examples:
brew install --cask alfred           # Productivity launcher
brew install --cask rectangle        # Window management
brew install --cask slack            # Team communication
brew install --cask notion           # Note-taking
brew install --cask figma            # Design tool
```

## 5. Productivity App Configuration

### System-Wide Keyboard Shortcuts

```bash
# Avoid conflicts with existing shortcuts
# Common productivity app shortcuts:

Cmd+Space          - Spotlight (system) / Alfred
Cmd+Shift+V        - Paste (clipboard manager)
Cmd+Option+Space   - Bartender (menu bar manager)
Cmd+K              - Dash (documentation)
Opt+Cmd+M          - Rectangle (window management)
```

### Recommended Settings

**General macOS:**
1. System Settings → Keyboard → Keyboard Shortcuts
2. Disable conflicting shortcuts
3. Configure app-specific shortcuts

**Setapp Apps:**
1. Keep auto-updates enabled
2. Enable "Launch at Login" for frequently used apps
3. Configure iCloud sync where available

## 6. Setapp Management

### Common Commands

```bash
# Check Setapp status
open -a Setapp

# View installed apps
ls /Applications/Setapp/

# Remove app (via Setapp interface)
# 1. Open Setapp
# 2. Find app
# 3. Click "Remove"
```

### Subscription Management

```bash
# Access via Setapp menu bar icon
# Setapp → Account → Manage Subscription

# Or visit web:
open https://my.setapp.com/
```

## 7. Productivity Workflow Examples

### Development Workflow

```bash
# Morning routine
1. iStat Menus - Monitor system resources
2. Bartender - Clean up menu bar
3. TablePlus - Check database connections
4. Dash - Quick API reference

# During development
1. Paste - Access code snippets
2. CleanMyMac X - Free up space when needed
3. Permute - Convert media files
```

### Writing Workflow

```bash
# Content creation
1. Ulysses - Draft writing
2. Paste - Store frequently used text
3. Get Plain Text - Clean formatting
4. Focus - Block distractions
```

## 8. Setapp vs Individual Purchases

### Setapp Advantages

- ✅ Single subscription for 240+ apps
- ✅ Try apps risk-free
- ✅ Automatic updates
- ✅ No commitment to individual apps
- ✅ Save money vs buying apps individually

### When to Buy Separately

- ❌ Only need 1-2 apps
- ❌ Apps available cheaper elsewhere
- ❌ Need perpetual license
- ❌ Apps not available on Setapp

### Cost Comparison

```
Setapp: $9.99/month (individual) or $9.99/user/month (family)

Individual Apps:
- CleanMyMac X: $39.95/year
- Bartender: $16 one-time
- Ulysses: $49.99/year
- TablePlus: $89 one-time
- Paste: $14.99/year

Total if bought separately: $209.93 first year
Setapp cost: $119.88/year

Savings: $90+ per year
```

## 9. Integration with Existing Setup

### Shell Aliases

Add convenience aliases for Setapp apps:

```bash
# Add to ~/.config/zsh/aliases/aliases.zsh
alias paste="open -a Paste"
alias cleanmymac="open -a 'CleanMyMac X'"
alias bartender="open -a Bartender"
alias tableplus="open -a TablePlus"
alias ulysses="open -a Ulysses"
alias dash="open -a Dash"
```

### Launch at Login

Configure essential apps to start automatically:

1. System Settings → General → Login Items
2. Add frequently used apps:
   - Paste
   - Bartender
   - iStat Menus
   - Setapp (menu bar)

## 10. Troubleshooting

### Setapp Not Opening

```bash
# Kill Setapp process
killall Setapp

# Relaunch
open -a Setapp

# If issues persist, reinstall
brew reinstall --cask setapp
```

### App Not Installing

```bash
# Check internet connection
ping setapp.com

# Check available disk space
df -h

# Try removing and reinstalling via Setapp
```

### License Issues

```bash
# Sign out and sign in
# Setapp → Account → Sign Out
# Then sign back in

# Or reset Setapp
rm -rf ~/Library/Application\ Support/Setapp
open -a Setapp
```

### Apps Won't Launch

```bash
# Check if subscription is active
# Setapp → Account

# Grant necessary permissions
# System Settings → Privacy & Security

# Restart Setapp
killall Setapp && open -a Setapp
```

## 11. Recommended Apps by Category

### Must-Have (Install These First)

1. **Paste** - Clipboard manager
2. **CleanMyMac X** - System maintenance
3. **Bartender** - Menu bar organization
4. **iStat Menus** - System monitoring

### Development

1. **TablePlus** - Database GUI
2. **Dash** - API documentation
3. **Proxyman** - HTTP debugging
4. **RapidAPI** - API testing
5. **Git Tower** - Git client

### Writing & Productivity

1. **Ulysses** - Writing app
2. **Taskheat** - Visual task management
3. **Focus** - Distraction blocker
4. **Mind Node** - Mind mapping

### Utilities

1. **Permute** - Media converter
2. **Get Plain Text** - Text formatter
3. **Archiver** - Archive manager
4. **PDF Search** - PDF search tool

## 12. Best Practices

### 1. Start with Essentials

Don't install everything at once:
- Start with 3-5 must-have apps
- Add more as you discover needs
- Remove unused apps regularly

### 2. Configure Keyboard Shortcuts

Avoid conflicts:
- Check existing shortcuts first
- Use consistent modifiers (Cmd+Shift, Cmd+Option)
- Document your shortcuts

### 3. Enable Sync Where Available

Keep settings across devices:
- Enable iCloud sync in supported apps
- Backup important configurations

### 4. Regular Maintenance

```bash
# Monthly routine
1. CleanMyMac X → Smart Scan
2. Review installed Setapp apps
3. Remove unused apps
4. Update preferences as needed
```

### 5. Explore New Apps

```bash
# Check "New" section in Setapp
# Try apps for specific tasks
# Read user reviews before installing
```

## 13. Quick Reference

### Launch Setapp Apps

```bash
# From Spotlight
Cmd+Space → Type app name → Enter

# From Setapp
Click Setapp menu bar icon → Search → Click app

# From Terminal
open -a "App Name"
```

### Common Tasks

```bash
# Install app
Setapp → Search → Install

# Remove app
Setapp → My Apps → Click app → Remove

# Update all apps
Setapp → automatically updates apps

# Check subscription
Setapp menu bar → Account

# Browse apps
Setapp → Discover
```

## 14. Security & Privacy

### App Permissions

Review permissions for Setapp apps:
- System Settings → Privacy & Security
- Grant only necessary permissions
- Review periodically

### Data Collection

```bash
# Setapp Privacy Policy
open https://setapp.com/privacy-policy

# Individual app privacy policies
# Check in app's About section
```

### Secure Credential Storage

```bash
# Never store passwords in plain text
# Use macOS Keychain or password manager
# Apps like TablePlus use Keychain automatically
```

## Next Steps

Continue with:
- **[Security & Monitoring](12-security-monitoring.md)** - Secure your applications
- **[IDEs & Editors](08-ides-editors.md)** - Development environment

---

**Estimated Time**: 15 minutes (setup) + 30 minutes (exploring apps)  
**Difficulty**: Beginner  
**Cost**: $9.99/month for Setapp subscription  
**Last Updated**: October 5, 2025

