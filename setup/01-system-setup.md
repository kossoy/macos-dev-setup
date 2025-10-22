# System Setup

Initial system configuration for macOS Sequoia 15.0.1 development environment.

## Prerequisites

- macOS Sequoia 15.0.1
- MacBook Pro M1
- Administrator access
- Stable internet connection

## Development Environment Organization

Recommended directory structure for both **work (Company)** and **personal (PersonalOrg Organization)** projects:

```
~/work/
├── databases/          # Docker database configurations
├── tools/             # Development tools and utilities
├── projects/          # Development projects
│   ├── work/          # Company work projects
│   └── personal/      # PersonalOrg Organization personal projects
├── configs/           # Configuration files
│   ├── work/          # Work-specific configurations
│   └── personal/      # Personal project configurations
├── scripts/           # Custom scripts and automation
└── docs/              # Documentation and notes
```

### Initial Setup

```bash
# Create the organized development structure
mkdir -p ~/work/{databases,tools,projects/{work,personal},configs/{work,personal},scripts,docs}

# Set up Git for the work directory (optional)
cd ~/work
git init
echo "*.log" >> .gitignore
echo "node_modules/" >> .gitignore
echo ".DS_Store" >> .gitignore
echo "projects/work/" >> .gitignore  # Exclude work projects from personal repo
echo "configs/work/" >> .gitignore   # Exclude work configs from personal repo
```

## 1. System Updates

```bash
# Check for system updates
sudo softwareupdate -l

# Install available updates
sudo softwareupdate -i -a
```

## 2. Xcode Command Line Tools

Required for many development tools including Homebrew, compilers, and more.

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify installation
xcode-select --print-path
# Should output: /Library/Developer/CommandLineTools
```

## 3. Homebrew (Package Manager)

Homebrew is the primary package manager for macOS.

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH for M1 Macs
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Verify installation
brew --version
```

## 4. Essential Homebrew Packages

```bash
# Core utilities
brew install git wget curl tree jq bat exa fd ripgrep

# Development tools
brew install gcc make cmake pkg-config

# Version control
brew install git-lfs

# Install all at once
brew install git wget curl tree jq bat eva fd ripgrep gcc make cmake pkg-config git-lfs
```

## 5. Shell Configuration (Zsh)

macOS Sequoia uses Zsh as the default shell. Let's enhance it.

```bash
# Install Oh My Zsh (if not already installed)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install useful plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Update .zshrc with useful plugins
# Edit ~/.zshrc and add to plugins line:
# plugins=(git docker kubectl helm aws terraform zsh-autosuggestions zsh-syntax-highlighting)
```

## 6. Enhanced Shell Configuration

### Option A: Fresh Install (Recommended for New Setup)

Set up basic shell configuration manually:

```bash
# Create zsh configuration structure
mkdir -p ~/.config/zsh/{aliases,functions,paths,contexts}

# Create paths configuration
cat > ~/.config/zsh/paths/paths.zsh << 'EOF'
# Development paths
export WORK_ROOT="$HOME/work"
export PROJECTS_ROOT="$WORK_ROOT/projects"
export CONFIGS_ROOT="$WORK_ROOT/configs"
export SCRIPTS_ROOT="$WORK_ROOT/scripts"
export TOOLS_ROOT="$WORK_ROOT/tools"
export DOCS_ROOT="$WORK_ROOT/docs"

# Add scripts to PATH
export PATH="$SCRIPTS_ROOT:$PATH"
export PATH="$HOME/work/bin:$PATH"

# Editor preferences
export EDITOR="nvim"
export VISUAL="cursor"
export GIT_EDITOR="cursor --wait"
EOF

# Create basic aliases
cat > ~/.config/zsh/aliases/aliases.zsh << 'EOF'
# Navigation shortcuts
alias cdwork="cd $PROJECTS_ROOT"
alias cdscripts="cd $SCRIPTS_ROOT"
alias cddocs="cd $DOCS_ROOT"

# Common shortcuts
alias ll="ls -la"
alias la="ls -la"
alias ..="cd .."
alias ...="cd ../.."

# Git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias glog="git log --oneline --graph --decorate"

# Editor shortcuts
alias editapi="cursor ~/.config/zsh/api-keys.zsh"
alias editzsh="cursor ~/.zshrc"
EOF

# Create main zsh configuration loader
cat > ~/.config/zsh/zshrc << 'EOF'
# Source all configuration files
for config_file in ~/.config/zsh/{paths,aliases,functions}/*.zsh; do
  [ -f "$config_file" ] && source "$config_file"
done

# Source current context if exists
[ -f ~/.config/zsh/contexts/current.zsh ] && source ~/.config/zsh/contexts/current.zsh
EOF

# Add to main .zshrc
echo '
# Load organized zsh configuration
[ -f ~/.config/zsh/zshrc ] && source ~/.config/zsh/zshrc
' >> ~/.zshrc

# Reload shell
source ~/.zshrc

echo "✅ Basic shell configuration installed"
```

### Option B: Automated Integration (If You Have Existing Scripts)

If you already have scripts and tools in `~/work/Mac OS install/`, use the automated integration:

```bash
# This consolidates all existing utilities and configurations
~/work/scripts/integrate-existing-scripts.sh
```

This will:
- ✅ Install enhanced zsh configurations (aliases, functions, tools)
- ✅ Link utility scripts (disk usage, screenshot org, video conversion, etc.)
- ✅ Configure Apache JMeter for performance testing
- ✅ Set up secure credential management
- ✅ Configure NAS volume mounting with Keychain
- ✅ Set proper file permissions

## 7. Verify Installation

```bash
# Reload shell configuration
source ~/.zshrc

# Verify Homebrew
brew doctor

# Verify Git
git --version

# Check shell
echo $SHELL  # Should be /bin/zsh
```

## Next Steps

Continue with:
- **[Python Environment](02-python-environment.md)** - Set up Python development
- **[Node.js Environment](03-nodejs-environment.md)** - Set up JavaScript development
- **[Java Environment](04-java-environment.md)** - Set up Java development

---

**Estimated Time**: 30 minutes  
**Difficulty**: Beginner  
**Last Updated**: October 5, 2025
