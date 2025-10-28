#!/bin/bash
# =============================================================================
# Shell Configuration Setup Script
# =============================================================================
# Deploys zsh configuration with backup and template processing
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check for non-interactive flag
NON_INTERACTIVE=false
if [[ "$1" == "--non-interactive" ]]; then
    NON_INTERACTIVE=true
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"

print_status "Setting up shell configuration..."

# Backup function with timestamp
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        print_status "Backed up $file to $backup"
    fi
}

# Create configuration directory structure
print_status "Creating configuration directories..."
mkdir -p ~/.config/zsh/{config,contexts,private}
mkdir -p ~/.zsh/{config,private}  # Legacy support
print_success "Configuration directories created"

# Backup existing .zshrc
if [[ -f ~/.zshrc ]]; then
    backup_file ~/.zshrc
fi

# Check if source configuration files exist
if [[ ! -d "$PACKAGE_DIR/config/zsh/config" ]]; then
    print_error "Configuration files not found at $PACKAGE_DIR/config/zsh/config"
    print_status "Please ensure you're running this from the correct directory"
    exit 1
fi

# Copy configuration files
print_status "Deploying configuration files..."

# Core config files
if [[ -f "$PACKAGE_DIR/config/zsh/config/paths.zsh" ]]; then
    cp "$PACKAGE_DIR/config/zsh/config/paths.zsh" ~/.config/zsh/config/paths.zsh
    print_success "Deployed paths.zsh"
else
    print_warning "paths.zsh not found, skipping"
fi

if [[ -f "$PACKAGE_DIR/config/zsh/config/aliases.zsh" ]]; then
    cp "$PACKAGE_DIR/config/zsh/config/aliases.zsh" ~/.config/zsh/config/aliases.zsh
    print_success "Deployed aliases.zsh"
else
    print_warning "aliases.zsh not found, skipping"
fi

if [[ -f "$PACKAGE_DIR/config/zsh/config/functions.zsh" ]]; then
    cp "$PACKAGE_DIR/config/zsh/config/functions.zsh" ~/.config/zsh/config/functions.zsh
    print_success "Deployed functions.zsh"
else
    print_warning "functions.zsh not found, skipping"
fi

if [[ -f "$PACKAGE_DIR/config/zsh/config/tools.zsh" ]]; then
    cp "$PACKAGE_DIR/config/zsh/config/tools.zsh" ~/.config/zsh/config/tools.zsh
    print_success "Deployed tools.zsh"
else
    print_warning "tools.zsh not found, skipping"
fi

if [[ -f "$PACKAGE_DIR/config/zsh/config/python.zsh" ]]; then
    cp "$PACKAGE_DIR/config/zsh/config/python.zsh" ~/.config/zsh/config/python.zsh
    print_success "Deployed python.zsh"
else
    print_warning "python.zsh not found, skipping (optional)"
fi

if [[ -f "$PACKAGE_DIR/config/zsh/config/custom.zsh" ]]; then
    cp "$PACKAGE_DIR/config/zsh/config/custom.zsh" ~/.config/zsh/config/custom.zsh
    print_success "Deployed custom.zsh"
else
    print_warning "custom.zsh not found, skipping (optional)"
fi

# Create main .zshrc
print_status "Creating .zshrc..."
cat > ~/.zshrc << 'EOF'
# =============================================================================
# Zsh Configuration
# =============================================================================

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  brew
  macos
  zsh-autosuggestions
  zsh-syntax-highlighting
  virtualenv
  pip
  python
  docker
)

source $ZSH/oh-my-zsh.sh

# Load custom configuration
ZSH_CONFIG_DIR="$HOME/.config/zsh/config"

[[ -f "$ZSH_CONFIG_DIR/paths.zsh" ]] && source "$ZSH_CONFIG_DIR/paths.zsh"
[[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases.zsh"
[[ -f "$ZSH_CONFIG_DIR/functions.zsh" ]] && source "$ZSH_CONFIG_DIR/functions.zsh"
[[ -f "$ZSH_CONFIG_DIR/tools.zsh" ]] && source "$ZSH_CONFIG_DIR/tools.zsh"
[[ -f "$ZSH_CONFIG_DIR/python.zsh" ]] && source "$ZSH_CONFIG_DIR/python.zsh"
[[ -f "$ZSH_CONFIG_DIR/custom.zsh" ]] && source "$ZSH_CONFIG_DIR/custom.zsh"

# Load context configuration
[[ -f "$HOME/.config/zsh/contexts/current.zsh" ]] && source "$HOME/.config/zsh/contexts/current.zsh"

# Load API keys (private, not in git)
[[ -f "$HOME/.config/zsh/private/api-keys.zsh" ]] && source "$HOME/.config/zsh/private/api-keys.zsh"

# Powerlevel10k configuration
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
EOF

print_success ".zshrc created"

# Create context template if it doesn't exist
if [[ ! -f ~/.config/zsh/contexts/current.zsh" ]]; then
    print_status "Creating default context..."
    cat > ~/.config/zsh/contexts/current.zsh << 'EOF'
# Default context (update via 'work' or 'personal' commands)
export WORK_CONTEXT="default"
export PROJECT_ROOT="$HOME/work/projects"
EOF
    print_success "Default context created"
else
    print_success "Context already exists, not overwriting"
fi

# Create API keys template
if [[ ! -f ~/.config/zsh/private/api-keys.zsh ]]; then
    print_status "Creating API keys template..."
    cat > ~/.config/zsh/private/api-keys.zsh << 'EOF'
# =============================================================================
# API Keys and Sensitive Configuration
# =============================================================================
# This file is gitignored - add your actual API keys here
#
# Example:
# export OPENAI_API_KEY="your-key-here"
# export ANTHROPIC_API_KEY="your-key-here"
# export GITHUB_TOKEN="your-token-here"
# =============================================================================

# Add your API keys below
EOF
    chmod 600 ~/.config/zsh/private/api-keys.zsh
    print_success "API keys template created"
    print_status "Edit ~/.config/zsh/private/api-keys.zsh to add your keys"
else
    print_success "API keys file already exists, not overwriting"
fi

# Copy Powerlevel10k configuration
if [[ -f "$PACKAGE_DIR/config/p10k.zsh" ]]; then
    print_status "Installing Powerlevel10k configuration..."
    if [[ -f ~/.p10k.zsh ]]; then
        backup_file ~/.p10k.zsh
    fi
    cp "$PACKAGE_DIR/config/p10k.zsh" ~/.p10k.zsh
    print_success "Powerlevel10k configuration installed"
else
    print_warning "p10k.zsh not found, skipping (optional)"
fi

# Verify configuration can be sourced
print_status "Verifying configuration..."
if zsh -c "source ~/.zshrc" 2>/dev/null; then
    print_success "Configuration is valid"
else
    print_warning "Configuration has errors, but continuing"
    print_status "You may need to manually fix ~/.zshrc"
fi

print_success "Shell configuration setup complete"
echo ""
print_status "Configuration deployed to:"
echo "  ~/.zshrc (main configuration)"
echo "  ~/.config/zsh/config/ (modular configs)"
echo "  ~/.config/zsh/contexts/current.zsh (context switching)"
echo "  ~/.config/zsh/private/api-keys.zsh (your API keys)"
echo ""
print_status "Next steps:"
echo "  1. Edit API keys: ~/.config/zsh/private/api-keys.zsh"
echo "  2. Reload shell: source ~/.zshrc"
echo "  3. Configure Git: ./setup-helpers/03-git-and-ssh-setup.sh"
