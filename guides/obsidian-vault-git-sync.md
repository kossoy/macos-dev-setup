# Obsidian Vault Git Sync Setup

## Overview

This guide explains how to sync your Mac OS fresh setup documentation vault across multiple devices using the Obsidian Git plugin.

## Repository Details

- **Repository**: https://github.com/username/macos-fresh-setup
- **Visibility**: Private
- **Purpose**: Sync Mac OS setup documentation across devices

## Prerequisites

- Obsidian installed on all devices
- Git installed on all devices
- GitHub CLI (`gh`) authenticated on all devices
- SSH keys configured for GitHub (recommended for automatic syncing)

## Initial Setup (Already Done on Current Device)

✅ The vault has been initialized and pushed to GitHub with all existing documentation.

## Setting Up on a New Device

### 1. Clone the Repository

```bash
cd ~/Documents  # or your preferred location
gh repo clone username/macos-fresh-setup
```

### 2. Install Obsidian Git Plugin

1. Open Obsidian
2. Go to **Settings** → **Community plugins**
3. Disable **Restricted mode** if enabled
4. Click **Browse** and search for "Obsidian Git"
5. Install and enable the plugin

### 3. Configure Obsidian Git Plugin

Navigate to **Settings** → **Community plugins** → **Obsidian Git**:

#### Recommended Settings

**Backup Settings:**
- ✅ **Disable push**: Off (you want to push changes)
- ✅ **Pull updates on startup**: On
- ✅ **Auto pull interval (minutes)**: 10
- ✅ **Auto backup after file change**: On
- ✅ **Auto backup interval (minutes)**: 5
- ✅ **Commit message**: `vault backup: {{date}}`

**Commit Settings:**
- **Commit author**: `Your Name <your.email@example.com>`
- ✅ **List filenames affected by commit in the commit body**: On

**Pull/Push Settings:**
- ✅ **Sync method**: Commit, pull, push
- ✅ **Pull before push**: On

**Advanced:**
- ✅ **Show status bar**: On
- ✅ **Show popup on sync**: Optional (can be helpful initially)

### 4. Configure Git Author (If Not Already Set)

```bash
cd ~/Documents/macos-fresh-setup  # or wherever you cloned
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

## Using the Plugin

### Automatic Syncing

With the recommended settings above:
- Changes are automatically backed up every 5 minutes
- Vault pulls updates every 10 minutes
- Changes are committed and pushed automatically

### Manual Syncing

You can also manually sync using:
- **Command Palette** (Cmd/Ctrl + P): Type "Git: Commit all changes" or "Git: Pull"
- **Status Bar**: Click the Git icon in the bottom right

## Workflow Best Practices

### 1. Starting Your Day

The plugin will automatically pull updates when you open Obsidian, but you can manually pull:
- Press `Cmd/Ctrl + P`
- Type "Git: Pull"
- Press Enter

### 2. Working Normally

Just work as usual! The plugin will:
- Auto-commit changes every 5 minutes
- Auto-push to GitHub
- Show status in the bottom right corner

### 3. Before Closing

The plugin auto-saves, but if you want to ensure everything is synced:
- Press `Cmd/Ctrl + P`
- Type "Git: Create backup"
- Press Enter

### 4. Switching Devices

1. Open Obsidian on the new device
2. Plugin auto-pulls latest changes
3. Start working
4. Changes auto-sync back

## Handling Conflicts

If you edit the same file on multiple devices simultaneously:

1. The plugin will show a conflict notification
2. Open the file with conflicts (marked with Git conflict markers)
3. Manually resolve by choosing which version to keep
4. Commit the resolved version

**Prevention**: Try to work on different files on different devices, or always pull before starting work.

## Troubleshooting

### Authentication Issues

If you get authentication errors:

```bash
# Ensure GitHub CLI is authenticated
gh auth status

# Or set up SSH keys (recommended)
# See: guides/github-ssh-setup.md
```

### Plugin Not Auto-Syncing

1. Check plugin is enabled: **Settings** → **Community plugins**
2. Verify settings: Auto backup should be enabled
3. Check status bar for error messages
4. Try manual sync to see specific error

### Merge Conflicts

```bash
# If plugin shows conflicts, you can resolve manually:
cd /path/to/vault

# See what files have conflicts
git status

# Edit files to resolve conflicts, then:
git add .
git commit -m "Resolved merge conflicts"
git push
```

### Large Files or Binary Files

Git works best with text files (markdown). For large files:
1. Consider using Git LFS for files > 10MB
2. Or keep large files in cloud storage and link them

## Advanced: Custom Ignore Rules

Create or edit `.gitignore` in your vault root:

```gitignore
# Obsidian workspace (device-specific settings)
.obsidian/workspace.json
.obsidian/workspace-mobile.json

# macOS
.DS_Store

# Temporary files
*.tmp
*.temp
```

## Monitoring Sync Status

The Obsidian Git plugin shows sync status:
- **Green checkmark**: Everything synced
- **Orange**: Changes being synced
- **Red**: Sync error (click for details)

## Command Palette Commands

Useful Obsidian Git commands (Cmd/Ctrl + P):
- `Git: Commit all changes` - Manual commit
- `Git: Push` - Push to remote
- `Git: Pull` - Pull from remote  
- `Git: Create backup` - Commit and push
- `Git: List changed files` - See what changed
- `Git: Open source control view` - View git history

## Security Notes

- Repository is **private** - only you can access it
- Use SSH keys for passwordless authentication
- Never commit sensitive data (passwords, API keys)
- For secrets, use a separate secure vault or password manager

## Related Documentation

- [GitHub SSH Setup](github-ssh-setup.md)
- [GitHub CLI Integration](github-cli-integration.md)
- [Obsidian Setup](obsidian-setup.md)

## Quick Reference

```bash
# View repository status
gh repo view username/macos-fresh-setup

# Clone on new device
gh repo clone username/macos-fresh-setup

# Manual git operations (if needed)
cd /path/to/vault
git status
git pull
git add .
git commit -m "message"
git push
```

## Benefits of This Setup

✅ Automatic syncing across all devices  
✅ Full version history of all changes  
✅ Works offline (sync when back online)  
✅ No file size limits (unlike some cloud sync)  
✅ Fine-grained control over what to sync  
✅ Free for private repositories  
✅ Can collaborate with others if needed  

---

*Last Updated: {{date:YYYY-MM-DD}}*

