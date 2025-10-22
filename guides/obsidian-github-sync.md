# Obsidian Vault Sync via GitHub

Complete guide to sync your Obsidian vaults across devices using GitHub.

## 📋 Table of Contents

1. [Why GitHub for Obsidian Sync?](#why-github-for-obsidian-sync)
2. [Prerequisites](#prerequisites)
3. [Initial Setup](#initial-setup)
4. [Manual Sync Workflow](#manual-sync-workflow)
5. [Automated Sync (Obsidian Git Plugin)](#automated-sync-obsidian-git-plugin)
6. [Multi-Device Setup](#multi-device-setup)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Why GitHub for Obsidian Sync?

### Advantages
- ✅ **Free** - GitHub offers free private repositories
- ✅ **Full Version Control** - Complete history of all changes
- ✅ **Cross-Platform** - Works on macOS, Windows, Linux, iOS (Working Copy), Android (MGit)
- ✅ **No Vendor Lock-in** - Your data is always accessible
- ✅ **Conflict Resolution** - Git handles merge conflicts
- ✅ **Selective Sync** - Use `.gitignore` to exclude files

### Disadvantages
- ⚠️ **Requires Manual Commits** - Unless you use the Git plugin
- ⚠️ **Learning Curve** - Basic Git knowledge needed
- ⚠️ **File Size Limits** - GitHub has a 100MB file limit per file

### Alternatives
- **Obsidian Sync** - $8/month, official, easiest
- **iCloud** - Free with Apple ID, macOS/iOS only
- **Syncthing** - Free, self-hosted, complex setup
- **Dropbox/Google Drive** - Works but may cause conflicts

---

## Prerequisites

### 1. Check Git Installation

```bash
# Check if Git is installed
git --version
# Should show: git version 2.x.x

# If not installed (shouldn't happen on recent macOS)
xcode-select --install
```

### 2. Configure Git (if not already done)

```bash
# Set your name and email
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Check configuration
git config --list | grep user
```

### 3. GitHub Account & Authentication

You should already have GitHub CLI (`gh`) configured from the setup guides.

```bash
# Check authentication
gh auth status

# If not authenticated
gh auth login
```

---

## Initial Setup

### Step 1: Initialize Git in Your Vault

```bash
# Navigate to your vault
cd /Users/user123/work/docs

# Initialize Git repository
git init

# Check status
git status
```

### Step 2: Create `.gitignore`

Create a `.gitignore` file to exclude Obsidian workspace files and other temporary files:

```bash
# Create .gitignore in your vault
cat > /Users/user123/work/docs/.gitignore << 'EOF'
# Obsidian workspace files (device-specific)
.obsidian/workspace.json
.obsidian/workspace-mobile.json

# Obsidian cache
.obsidian/cache/

# Mac system files
.DS_Store

# Trash (if using Obsidian trash)
.trash/

# Plugin caches (optional - uncomment if needed)
# .obsidian/plugins/*/data.json

# Large files
*.pdf
*.zip
*.tar.gz

# Sensitive data (if you have any)
# private/
# secrets.md
EOF

# Verify
cat .gitignore
```

**Important Files to Track:**
- ✅ `.obsidian/app.json` - General app settings
- ✅ `.obsidian/appearance.json` - Theme and appearance
- ✅ `.obsidian/core-plugins.json` - Enabled core plugins
- ✅ `.obsidian/community-plugins.json` - Enabled community plugins
- ✅ `.obsidian/hotkeys.json` - Custom keyboard shortcuts
- ✅ All your markdown files (`.md`)

**Files to Exclude:**
- ❌ `.obsidian/workspace.json` - Device-specific window layouts
- ❌ `.obsidian/cache/` - Temporary cache files

### Step 3: Create GitHub Repository

```bash
# Create a private GitHub repository
gh repo create obsidian-vault --private --source=. --remote=origin

# Or create manually on GitHub and add remote:
# gh repo create obsidian-vault --private
# git remote add origin https://github.com/YOUR-USERNAME/obsidian-vault.git
```

### Step 4: First Commit and Push

```bash
# Add all files (respecting .gitignore)
git add .

# Create first commit
git commit -m "Initial commit: Obsidian vault setup"

# Push to GitHub
git branch -M main
git push -u origin main

# Verify
gh repo view --web
```

---

## Manual Sync Workflow

### Daily Workflow

#### 1. Pull Latest Changes (Start of Session)

```bash
cd /Users/user123/work/docs

# Pull changes from other devices
git pull origin main
```

#### 2. Work Normally in Obsidian

Create, edit, and delete notes as usual.

#### 3. Commit and Push Changes (End of Session)

```bash
# Check what changed
git status

# View differences (optional)
git diff

# Add all changes
git add .

# Commit with descriptive message
git commit -m "Update notes: $(date +%Y-%m-%d)"

# Push to GitHub
git push origin main
```

### Quick Sync Alias

Add this to your `~/.config/zsh/aliases/aliases.zsh`:

```bash
# Quick Obsidian vault sync
alias obsync='cd /Users/user123/work/docs && git add . && git commit -m "Sync: $(date +%Y-%m-%d\ %H:%M)" && git push && cd -'

# Pull latest from vault
alias obpull='cd /Users/user123/work/docs && git pull && cd -'
```

**Usage:**

```bash
# Push changes
obsync

# Pull changes
obpull
```

---

## Automated Sync (Obsidian Git Plugin)

The **Obsidian Git** plugin automates the commit and push process.

### Step 1: Install Obsidian Git Plugin

1. Open Obsidian
2. Go to **Settings** → **Community plugins**
3. Click **Browse**
4. Search for **"Obsidian Git"**
5. Click **Install**
6. Click **Enable**

### Step 2: Configure Obsidian Git

Go to **Settings** → **Community plugins** → **Obsidian Git**:

#### Basic Settings

```
✅ Pull updates on startup
   Automatically pulls when Obsidian opens

✅ Auto backup
   Automatically commits and pushes changes

Auto backup interval: 15 minutes
   How often to auto-commit (adjust to preference)

✅ Auto pull interval: 15 minutes
   Automatically pulls from remote

Commit message: {{date}}: {{numFiles}} files updated
   Dynamic commit messages
```

#### Advanced Settings (Optional)

```
Commit author: Your Name <your.email@example.com>
   Override Git config (optional)

✅ Disable push
   Useful if you want to commit locally only

Git branch: main
   Specify branch to use
```

### Step 3: Verify Plugin Setup

1. Make a change to any note
2. Wait for auto-backup interval (or run manual backup)
3. Check GitHub to see if changes were pushed

### Manual Plugin Commands

Access via Command Palette (⌘P):

- **"Obsidian Git: Commit all changes"** - Manual commit
- **"Obsidian Git: Push"** - Push to remote
- **"Obsidian Git: Pull"** - Pull from remote
- **"Obsidian Git: View source control"** - See Git status

### Recommended Plugin Settings

```yaml
Pull on startup: true
Auto backup: true
Auto backup interval: 10 minutes
Auto pull interval: 10 minutes
Push on backup: true
Commit message: vault backup: {{date}}
```

---

## Multi-Device Setup

### Setup on Additional Device

#### macOS/Linux

```bash
# Clone your vault repository
cd ~/work
git clone https://github.com/YOUR-USERNAME/obsidian-vault.git docs

# Open in Obsidian
open "obsidian://open?path=$(pwd)/docs"

# Install Obsidian Git plugin (if using)
# Settings → Community plugins → Browse → Obsidian Git
```

#### Windows

```powershell
# Clone your vault repository
cd C:\Users\YourName\Documents
git clone https://github.com/YOUR-USERNAME/obsidian-vault.git obsidian-vault

# Open Obsidian and "Open folder as vault"
# Navigate to the cloned folder
```

#### iOS (Mobile)

Use **Working Copy** app for Git on iOS:

1. Install **Working Copy** from App Store
2. Clone your repository in Working Copy
3. Open Obsidian app
4. Select "Open folder as vault"
5. Choose the repository from Working Copy
6. Pull/Push via Working Copy app

#### Android (Mobile)

Use **MGit** app for Git on Android:

1. Install **MGit** from Play Store
2. Clone your repository in MGit
3. Open Obsidian app
4. Select repository folder as vault
5. Pull/Push via MGit app

---

## Best Practices

### ✅ Do's

1. **Commit Often** - Small, frequent commits are easier to manage
2. **Pull Before Push** - Always pull before pushing to avoid conflicts
3. **Descriptive Messages** - Use meaningful commit messages
4. **Backup Important Files** - GitHub is a backup, but have local backups too
5. **Use .gitignore** - Exclude workspace and cache files
6. **Test on One Device First** - Ensure sync works before adding more devices

### ❌ Don'ts

1. **Don't Store Large Files** - GitHub has 100MB per file limit
2. **Don't Commit Sensitive Data** - Use `.gitignore` for private notes
3. **Don't Force Push** - Can cause data loss
4. **Don't Skip Pulls** - Can cause merge conflicts
5. **Don't Edit Same File Simultaneously** - On multiple devices without syncing

### Handling Large Files

If you need to store large files (PDFs, images):

**Option 1: Git LFS** (Large File Storage)

```bash
# Install Git LFS
brew install git-lfs

# Initialize in your vault
cd /Users/user123/work/docs
git lfs install

# Track large files
git lfs track "*.pdf"
git lfs track "*.png"

# Commit .gitattributes
git add .gitattributes
git commit -m "Enable Git LFS for large files"
git push
```

**Option 2: External Storage**

Store large files in iCloud/Dropbox and link to them:

```markdown
[Large PDF File](file:///Users/user123/Library/Mobile%20Documents/com~apple~CloudDocs/Documents/large-file.pdf)
```

---

## Troubleshooting

### Merge Conflicts

If you edit the same file on multiple devices without syncing:

```bash
# Pull to see conflicts
cd /Users/user123/work/docs
git pull origin main

# You'll see conflict markers in files:
# <<<<<<< HEAD
# Your local changes
# =======
# Remote changes
# >>>>>>> origin/main

# Option 1: Resolve manually
# Edit the file, remove markers, keep desired content

# Option 2: Use merge tool
git mergetool

# After resolving
git add .
git commit -m "Resolved merge conflict"
git push origin main
```

### Obsidian Git Plugin Not Working

```bash
# Check if Git is properly configured
cd /Users/user123/work/docs
git status

# Check remote
git remote -v

# Test manual commit
git add .
git commit -m "Test commit"
git push

# If manual works but plugin doesn't:
# 1. Restart Obsidian
# 2. Reinstall Obsidian Git plugin
# 3. Check plugin settings
```

### Authentication Issues

If Git asks for credentials repeatedly:

```bash
# Use GitHub CLI authentication
gh auth login

# Or configure SSH keys (recommended)
ssh-keygen -t ed25519 -C "your.email@example.com"
cat ~/.ssh/id_ed25519.pub | pbcopy
# Add to GitHub: Settings → SSH and GPG keys

# Update remote to use SSH
cd /Users/user123/work/docs
git remote set-url origin git@github.com:YOUR-USERNAME/obsidian-vault.git
```

### Large Repository Size

If your repository becomes too large:

```bash
# Check repository size
cd /Users/user123/work/docs
du -sh .git

# Find large files
git ls-files | xargs ls -lh | sort -k5 -hr | head -n 20

# Remove large file from history (CAUTION)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/large/file" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (make sure all devices are synced first)
git push origin --force --all
```

### Accidental Commit of Sensitive Data

If you accidentally committed sensitive information:

```bash
# Remove from latest commit (before pushing)
git reset --soft HEAD~1
git restore --staged path/to/sensitive/file
echo "path/to/sensitive/file" >> .gitignore
git add .
git commit -m "Remove sensitive data"

# If already pushed (need to rewrite history)
# WARNING: This affects all collaborators
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/sensitive/file" \
  --prune-empty --tag-name-filter cat -- --all

git push origin --force --all
```

**Better Prevention:**

```bash
# Add to .gitignore BEFORE committing
echo "private/" >> .gitignore
echo "secrets.md" >> .gitignore
git add .gitignore
git commit -m "Update .gitignore to exclude sensitive files"
```

---

## Advanced: Multiple Vaults

If you have multiple Obsidian vaults:

### Separate Repositories (Recommended)

```bash
# Personal vault
cd ~/personal-vault
git init
gh repo create obsidian-personal --private --source=.

# Work vault
cd ~/work-vault
git init
gh repo create obsidian-work --private --source=.
```

### Mono-repo with Submodules (Advanced)

```bash
# Main repository
mkdir ~/obsidian-vaults
cd ~/obsidian-vaults
git init

# Add vaults as submodules
git submodule add https://github.com/YOU/personal-vault.git personal
git submodule add https://github.com/YOU/work-vault.git work

# Clone all vaults on new device
git clone --recursive https://github.com/YOU/obsidian-vaults.git
```

---

## Quick Reference

### Essential Commands

```bash
# Initial setup
cd /Users/user123/work/docs
git init
git add .
git commit -m "Initial commit"
gh repo create obsidian-vault --private --source=.
git push -u origin main

# Daily workflow
git pull origin main        # Pull changes (start of day)
# ... work in Obsidian ...
git add .                   # Stage changes
git commit -m "Update notes"  # Commit
git push origin main        # Push changes (end of day)

# Quick sync (with alias)
obsync                      # Push changes
obpull                      # Pull changes

# Check status
git status                  # See changes
git log --oneline -10       # Recent commits
git diff                    # View differences
```

### Useful Aliases

Add to `~/.config/zsh/aliases/aliases.zsh`:

```bash
# Obsidian vault aliases
alias obcd='cd /Users/user123/work/docs'
alias obst='cd /Users/user123/work/docs && git status'
alias oblog='cd /Users/user123/work/docs && git log --oneline --graph --all -20'
alias obpull='cd /Users/user123/work/docs && git pull && cd -'
alias obsync='cd /Users/user123/work/docs && git add . && git commit -m "Sync: $(date +%Y-%m-%d\ %H:%M)" && git push && cd -'
alias obopen='open "obsidian://open?path=/Users/user123/work/docs"'
```

---

## Summary

### Manual Sync
1. Initialize Git in vault: `git init`
2. Create `.gitignore` for Obsidian files
3. Create GitHub repository: `gh repo create`
4. Commit and push regularly

### Automated Sync
1. Set up manual sync first
2. Install **Obsidian Git** plugin
3. Configure auto-backup (10-15 minutes)
4. Enable pull on startup

### Multi-Device
1. Clone repository on new device
2. Open as vault in Obsidian
3. Install Git plugin (optional)
4. Sync regularly

---

**Last Updated**: October 5, 2025  
**Related Guides**: [Obsidian Setup](obsidian-setup.md), [Git Configuration](../setup/09-git-configuration.md)

