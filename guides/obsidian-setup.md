# Obsidian Setup Guide

Quick guide to set up and use Obsidian with your development documentation.

## Installation

### Using DMG (Recommended)

1. Download from [obsidian.md](https://obsidian.md/)
2. Open the DMG file
3. Drag **Obsidian.app** to **Applications**
4. Eject the DMG

### Using Homebrew (Alternative)

```bash
brew install --cask obsidian
```

## Opening Your Docs Vault

### Method 1: Via Obsidian UI

1. Launch Obsidian
2. Click **"Open folder as vault"**
3. Navigate to: `/Users/user123/work/docs`
4. Click **"Open"**

### Method 2: Via Terminal

```bash
# Quick open
open -a Obsidian

# Direct vault open (once Obsidian is installed)
open "obsidian://open?path=/Users/user123/work/docs"
```

### Method 3: Create Alias (Convenient)

```bash
# Add to ~/.config/zsh/aliases/aliases.zsh
echo 'alias opendocs="open \"obsidian://open?path=/Users/user123/work/docs\""' >> ~/.config/zsh/aliases/aliases.zsh

# Reload shell
source ~/.zshrc

# Use it
opendocs
```

## First Time Setup

### Trust the Vault

When opening for the first time:
- Click **"Trust author and enable plugins"**
- This is your own vault, so it's safe

### Recommended Settings

**Settings** (⌘,) → **Options**:

#### Editor
- ✅ **Readable line length** - Makes text easier to read
- ✅ **Strict line breaks** - Better markdown compatibility
- ✅ **Show frontmatter** - See metadata

#### Files & Links
- ✅ **Automatically update internal links** - Keeps links working when you move files
- **Default location for new notes**: Same folder as current file

#### Appearance
- Choose a theme you like (default is great, or try "Minimal")
- Adjust font size to your preference

#### Core Plugins (Enable These)
- ✅ **Backlinks** - See what links to current note
- ✅ **Graph view** - Visualize note connections
- ✅ **Outline** - Shows headings in current note
- ✅ **Tag pane** - Browse by tags
- ✅ **Quick switcher** - Fast file navigation
- ✅ **Command palette** - Access all commands

## Essential Keyboard Shortcuts

### Navigation
```
⌘O                      Quick switcher (open any file)
⌘P                      Command palette
⌘↩                      Follow link under cursor
⌘←                      Go back
⌘→                      Go forward
⌘\                      Split pane vertically
```

### Editing
```
⌘N                      New note
⌘E                      Toggle edit/preview mode
⌘,                      Open settings
⌘K                      Insert link
⌘⇧F                     Search in all files
```

### Views
```
⌘G                      Open graph view
⌘⇧E                     Toggle file explorer
⌘⇧L                     Toggle outline
```

## Using Your Development Docs

### Start Here

1. Open **README.md** - Main navigation hub
2. Use internal links to navigate to specific guides
3. Use Quick Switcher (⌘O) to jump to any file

### Folder Structure

```
docs/
├── README.md              # Start here - main index
├── setup/                 # Step-by-step setup guides
│   ├── 01-system-setup.md
│   ├── 02-python-environment.md
│   └── 06-databases.md
├── guides/                # Specific configurations
│   ├── cursor-setup.md
│   ├── datagrip-setup.md
│   └── ...
├── reference/             # Quick references
│   ├── quick-reference.md
│   └── troubleshooting.md
└── testing/               # Test documentation
```

### Search Tips

**Search Everything** (⌘⇧F):
```
docker                     # Find all mentions of docker
path:setup/                # Search only in setup folder
tag:#database              # Search by tag
```

**Quick Switcher** (⌘O):
- Type part of filename: `cursor` → finds cursor-setup.md
- Type abbreviation: `qr` → finds quick-reference.md

## Useful Features

### Graph View (⌘G)

Visualize connections between your documentation:
- Hover over nodes to see note titles
- Click nodes to open notes
- Use filters to focus on specific areas

### Backlinks

See what other notes link to the current one:
- Useful for seeing related documentation
- Found in right sidebar

### Outline

Shows all headings in current note:
- Quick navigation within large files
- Found in right sidebar

### Split Panes

Work with multiple files at once:
- ⌘\ to split vertically
- Drag tabs to split horizontally
- Great for comparing configurations

## Tips & Tricks

### 1. Use Split View

```bash
# Open related docs side-by-side
# Open README.md
# ⌘-click a link to open in new pane
```

### 2. Create Your Own Notes

```bash
# Press ⌘N to create new note
# Save in appropriate folder
# Link to existing docs with [[file-name]]
```

### 3. Add Personal Notes

Add your own notes alongside the documentation:
```markdown
# In any guide, add your notes at the bottom:

---
## My Notes
- Custom configuration I did on 2025-10-06
- Issues I encountered and how I fixed them
```

### 4. Tag Important Sections

```markdown
Use tags for quick filtering:
#important #todo #completed #work #personal
```

### 5. Use Callouts

```markdown
> [!tip] Pro Tip
> Your helpful tip here

> [!warning] Important
> Something to be careful about

> [!note]
> Additional information
```

## Obsidian + Your Workflow

### Daily Development

```bash
# Morning routine
1. Open Obsidian: opendocs (if you created the alias)
2. Check Quick Reference for commands
3. Reference setup guides as needed

# When troubleshooting
1. ⌘⇧F to search for error
2. Check troubleshooting.md
3. Add your own notes if you find a solution
```

### When Learning New Tool

1. Open relevant setup guide
2. Split pane (⌘\) to have guide + terminal visible
3. Follow along step-by-step
4. Add notes about what you customized

## Mobile Access (Optional)

Obsidian has mobile apps (iOS/Android):

1. Install Obsidian mobile app
2. Enable **Obsidian Sync** (paid) or use iCloud/Dropbox
3. Access your docs on phone/tablet

**For iCloud sync:**
```bash
# Move vault to iCloud
mv ~/work/docs ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/dev-docs

# Create symlink to keep it at ~/work/docs
ln -s ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/dev-docs ~/work/docs
```

**For GitHub sync (recommended):**

See the comprehensive **[Obsidian GitHub Sync Guide](obsidian-github-sync.md)** for:
- Free cross-platform sync via GitHub
- Automated sync with Obsidian Git plugin
- Multi-device setup (macOS, Windows, Linux, iOS, Android)
- Version control and backup
- Best practices and troubleshooting

## Syncing This Documentation Vault

This specific documentation vault (`macos-dev-setup`) is already set up as a Git repository. Here's how to keep it synced across devices.

### Prerequisites

- Obsidian installed on all devices
- Git installed on all devices
- GitHub CLI (`gh`) authenticated: `gh auth login`
- SSH keys configured for GitHub (see [GitHub SSH Setup](github-ssh-setup.md))

### Setting Up on a New Device

#### 1. Clone the Repository

```bash
cd ~  # or your preferred location
gh repo clone username/macos-dev-setup
```

#### 2. Install Obsidian Git Plugin

1. Open Obsidian
2. **Settings** → **Community plugins**
3. Disable **Restricted mode** if enabled
4. Click **Browse** and search for "Obsidian Git"
5. Install and enable the plugin

#### 3. Configure Obsidian Git Plugin

Navigate to **Settings** → **Community plugins** → **Obsidian Git**:

**Recommended Settings:**
- ✅ **Disable push**: Off (you want to push changes)
- ✅ **Pull updates on startup**: On
- ✅ **Auto pull interval (minutes)**: 10
- ✅ **Auto backup after file change**: On
- ✅ **Auto backup interval (minutes)**: 5
- ✅ **Commit message**: `vault backup: {{date}}`
- ✅ **Sync method**: Commit, pull, push
- ✅ **Pull before push**: On
- ✅ **Show status bar**: On

#### 4. Configure Git Author

```bash
cd ~/macos-dev-setup  # or wherever you cloned
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### Using the Plugin

**Automatic Syncing:**
- Changes are automatically backed up every 5 minutes
- Vault pulls updates every 10 minutes
- Changes are committed and pushed automatically

**Manual Syncing:**
- **Command Palette** (⌘P): Type "Git: Create backup"
- **Status Bar**: Click the Git icon in the bottom right

### Workflow Best Practices

**Starting Your Day:**
- Plugin auto-pulls when you open Obsidian

**Working Normally:**
- Just work as usual! Plugin auto-saves and auto-pushes

**Switching Devices:**
1. Open Obsidian on the new device
2. Plugin auto-pulls latest changes
3. Start working

### Handling Conflicts

If you edit the same file on multiple devices:
1. Plugin shows a conflict notification
2. Open the file with conflicts
3. Manually resolve (choose which version to keep)
4. Commit the resolved version

**Prevention**: Work on different files on different devices, or always pull before starting.

### Troubleshooting Sync Issues

**Authentication Errors:**
```bash
# Ensure GitHub CLI is authenticated
gh auth status

# Or use SSH keys (see github-ssh-setup.md)
```

**Plugin Not Auto-Syncing:**
1. Check plugin is enabled: **Settings** → **Community plugins**
2. Verify auto backup is enabled in plugin settings
3. Check status bar for error messages

### Security Notes

- This repository should be **private**
- Use SSH keys for passwordless authentication
- Never commit sensitive data (passwords, API keys)

## Plugins (Advanced)

### Recommended Community Plugins

1. **Obsidian Git** - Sync vault with Git (auto-commit changes) - [Setup Guide](obsidian-github-sync.md)
2. **Dataview** - Query your notes like a database
3. **Calendar** - Daily notes with calendar view
4. **Excalidraw** - Draw diagrams directly in Obsidian

Install via: Settings → Community plugins → Browse

> [!tip] GitHub Sync
> For detailed instructions on syncing your vault via GitHub (free and cross-platform), see the **[Obsidian GitHub Sync Guide](obsidian-github-sync.md)**.

## Troubleshooting

### Vault Won't Open

```bash
# Check folder exists
ls -la ~/work/docs/

# Check permissions
chmod -R u+r ~/work/docs/

# Try opening with full path
open "obsidian://open?path=/Users/user123/work/docs"
```

### Links Not Working

- Make sure you're using relative paths: `[text](../folder/file.md)`
- Or use Obsidian wiki links: `[[file-name]]`

### Slow Performance

- Settings → Files & Links → Reduce "Excluded files"
- Close graph view if not needed
- Disable unused plugins

## Quick Start Checklist

- [ ] Install Obsidian (DMG or Homebrew)
- [ ] Open ~/work/docs as vault
- [ ] Trust vault and enable plugins
- [ ] Configure recommended settings
- [ ] Learn basic shortcuts (⌘O, ⌘P, ⌘⇧F)
- [ ] Explore README.md and linked guides
- [ ] Try graph view (⌘G)
- [ ] Create test note to familiarize with editor

---

**For more help**: Press ⌘? in Obsidian for help, or visit [help.obsidian.md](https://help.obsidian.md/)

**Last Updated**: October 5, 2025
