# macOS Fresh Setup - Quick Start Guide

**Setup Time**: ~10-15 minutes  
**Target**: M1 Mac (macOS Tahoe 26.0.1)

## What You Get

This package sets up a complete development environment with:

- **Shell Configuration**: Enhanced zsh with Oh My Zsh, Powerlevel10k theme, and custom functions
- **Context Switching**: Automatic work/personal environment switching
- **Utility Scripts**: Disk usage analyzer, process management, network tools
- **Work Organization**: Structured directory layout for projects
- **Browser Integration**: Automatic browser switching per context

## Quick Start

### 1. Run the Bootstrap Script

```bash
cd macos-fresh-setup
chmod +x bootstrap.sh
./bootstrap.sh
```

### 2. Follow Interactive Prompts

The script will ask for:
- Your full name and email addresses
- Work and personal context names
- Browser preferences
- Installation mode (Full/Minimal/Custom)

### 3. Restore Sensitive Files

After installation, restore your API keys and SSH keys:

```bash
# Use the built-in helper
./setup-helpers/04-restore-sensitive.sh

# Or manually copy from your backups
# See BACKUP_LOCATIONS.md for details
```

### 4. Reload Your Shell

```bash
source ~/.zshrc
# or restart your terminal
```

## Essential Commands

### Context Switching
```bash
work                    # Switch to work context
personal               # Switch to personal context
show-context           # Check current context
```

### Utility Scripts
```bash
wdu                    # Disk usage analyzer
psme <process>         # Find processes
slay <process>         # Kill processes
listening              # Show listening ports
myip                   # Get your public IP
```

### File Operations
```bash
mkcd <dir>             # Create directory and cd into it
files                  # Count files in current directory
organize-screenshots   # Organize screenshots by date
```

## What Gets Installed

### Full Installation Includes:
- **Homebrew**: Package manager
- **Essential Packages**: git, curl, jq, tree, bat, ripgrep, defaultbrowser
- **Oh My Zsh**: Shell framework with plugins
- **Powerlevel10k**: Beautiful prompt theme
- **Shell Configuration**: Modular zsh setup
- **Utility Scripts**: 10+ productivity scripts
- **Work Structure**: Organized project directories

### Shell Features:
- **Context Switching**: Automatic work/personal environment
- **Git Integration**: Context-aware Git configuration
- **Browser Switching**: Different browsers per context
- **GitHub CLI**: Automatic authentication switching
- **Database Ports**: Context-specific database connections

## Directory Structure

After installation, you'll have:

```
~/work/
├── projects/
│   ├── work/          # Company projects
│   └── personal/      # PersonalOrg projects
├── scripts/           # Utility scripts
├── configs/           # Context-specific configs
├── databases/         # Docker database configs
├── docs/              # Documentation
└── bin/               # Custom binaries
```

## Context Switching Explained

The `work` and `personal` commands automatically switch:

| Feature | Work Context | Personal Context |
|---------|--------------|------------------|
| **Git Config** | john.doe@company.com | john@personal-org.com |
| **GitHub CLI** | Work account | Personal account |
| **Browser** | Chrome | Safari/Brave |
| **Database Port** | 5432 | 5433 |
| **Working Dir** | ~/work/projects/work | ~/work/projects/personal |

## Troubleshooting

### Shell Not Loading
```bash
# Check if .zshrc exists
ls -la ~/.zshrc

# Reload manually
source ~/.zshrc

# Check for errors
zsh -x ~/.zshrc
```

### Context Switching Not Working
```bash
# Check if functions are loaded
type work
type personal

# Reload configuration
source ~/.zshrc
```

### Scripts Not Found
```bash
# Check PATH includes work/scripts
echo $PATH | grep work/scripts

# Add manually if needed
export PATH="$HOME/work/scripts:$PATH"
```

### API Keys Not Loading
```bash
# Check file exists and has correct permissions
ls -la ~/.config/zsh/private/api-keys.zsh

# Should be: -rw------- (600)
# Fix with: chmod 600 ~/.config/zsh/private/api-keys.zsh
```

## Next Steps

### 1. Set Up GitHub SSH
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to GitHub
cat ~/.ssh/id_ed25519.pub
# Copy to GitHub Settings → SSH and GPG keys
```

### 2. Install Development Tools
```bash
# JetBrains Toolbox
brew install --cask jetbrains-toolbox

# Docker Desktop
brew install --cask docker

# VS Code / Cursor
brew install --cask cursor
```

### 3. Get Full Documentation
```bash
# Clone comprehensive setup guides
git clone https://github.com/username/macos-fresh-setup ~/work/docs/macos-setup-full

# Browse setup guides (01-14)
open ~/work/docs/macos-setup-full/README.md
```

## Full Documentation

This quick start covers the essentials. For comprehensive setup guides:

- **System Setup**: macOS, Xcode, Homebrew configuration
- **Language Environments**: Python, Node.js, Java setup
- **Development Tools**: Docker, Kubernetes, databases
- **IDEs & Editors**: JetBrains, Cursor, Neovim
- **Git & GitHub**: SSH keys, CLI, workflows
- **Specialized Tools**: AI/ML, security, monitoring

## Support

- **Issues**: Check BACKUP_LOCATIONS.md for file restoration
- **Documentation**: Full guides in ~/work/docs/macos-setup-full/
- **Scripts**: All utility scripts in ~/work/scripts/

---

**Ready to code!** 🚀
