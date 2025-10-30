#!/bin/bash
# =============================================================================
# Oh My Zsh Installation Script
# =============================================================================
# Installs Oh My Zsh, plugins, and Powerlevel10k theme with idempotency
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
    export RUNZSH=no
    export CHSH=no
fi

print_status "Installing Oh My Zsh framework..."

# Check if Oh My Zsh is already installed
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_success "Oh My Zsh is already installed"

    # Optionally update
    if [[ -f "$HOME/.oh-my-zsh/tools/upgrade.sh" ]]; then
        print_status "Checking for updates..."
        if ! $NON_INTERACTIVE; then
            read -p "Update Oh My Zsh? (y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                bash "$HOME/.oh-my-zsh/tools/upgrade.sh" || print_warning "Update failed (continuing anyway)"
            fi
        fi
    fi
else
    # Install Oh My Zsh
    print_status "Downloading and installing Oh My Zsh..."

    if $NON_INTERACTIVE; then
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
            print_error "Failed to install Oh My Zsh"
            exit 1
        }
    else
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
            print_error "Failed to install Oh My Zsh"
            exit 1
        }
    fi

    print_success "Oh My Zsh installed"
fi

# Patch Oh My Zsh upgrade.sh to fix "local: can only be used in a function" error
if [[ -f "$HOME/.oh-my-zsh/tools/upgrade.sh" ]]; then
    if grep -q "^local ret=0" "$HOME/.oh-my-zsh/tools/upgrade.sh" 2>/dev/null; then
        print_status "Patching Oh My Zsh upgrade.sh..."
        # Fix line 4 and line 228 where 'local ret=0' appears outside functions
        sed -i.bak 's/^local ret=0/ret=0/' "$HOME/.oh-my-zsh/tools/upgrade.sh"
        print_success "Patched upgrade.sh to fix script-level 'local' declarations"
    fi
fi

# Define plugin/theme locations
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUGINS_DIR="$ZSH_CUSTOM/plugins"
THEMES_DIR="$ZSH_CUSTOM/themes"

# Install zsh-autosuggestions plugin
print_status "Installing zsh-autosuggestions plugin..."
if [[ -d "$PLUGINS_DIR/zsh-autosuggestions" ]]; then
    print_success "zsh-autosuggestions already installed"

    # Update if not non-interactive
    if ! $NON_INTERACTIVE; then
        cd "$PLUGINS_DIR/zsh-autosuggestions"
        print_status "Checking for plugin updates..."
        git pull origin master 2>/dev/null || print_warning "Update failed (continuing anyway)"
        cd - > /dev/null
    fi
else
    print_status "Cloning zsh-autosuggestions..."
    if git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"; then
        print_success "zsh-autosuggestions installed"
    else
        print_error "Failed to install zsh-autosuggestions"
        exit 1
    fi
fi

# Install zsh-syntax-highlighting plugin
print_status "Installing zsh-syntax-highlighting plugin..."
if [[ -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]]; then
    print_success "zsh-syntax-highlighting already installed"

    # Update if not non-interactive
    if ! $NON_INTERACTIVE; then
        cd "$PLUGINS_DIR/zsh-syntax-highlighting"
        print_status "Checking for plugin updates..."
        git pull origin master 2>/dev/null || print_warning "Update failed (continuing anyway)"
        cd - > /dev/null
    fi
else
    print_status "Cloning zsh-syntax-highlighting..."
    if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGINS_DIR/zsh-syntax-highlighting"; then
        print_success "zsh-syntax-highlighting installed"
    else
        print_error "Failed to install zsh-syntax-highlighting"
        exit 1
    fi
fi

# Install Powerlevel10k theme
print_status "Installing Powerlevel10k theme..."
if [[ -d "$THEMES_DIR/powerlevel10k" ]]; then
    print_success "Powerlevel10k already installed"

    # Update if not non-interactive
    if ! $NON_INTERACTIVE; then
        cd "$THEMES_DIR/powerlevel10k"
        print_status "Checking for theme updates..."
        git pull origin master 2>/dev/null || print_warning "Update failed (continuing anyway)"
        cd - > /dev/null
    fi
else
    print_status "Cloning Powerlevel10k theme..."
    if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$THEMES_DIR/powerlevel10k"; then
        print_success "Powerlevel10k installed"
    else
        print_error "Failed to install Powerlevel10k"
        exit 1
    fi
fi

print_success "Oh My Zsh installation complete"
echo ""
print_status "Installed components:"
echo "  ✅ Oh My Zsh framework"
echo "  ✅ zsh-autosuggestions plugin"
echo "  ✅ zsh-syntax-highlighting plugin"
echo "  ✅ Powerlevel10k theme"
echo ""
print_status "Configure your shell with: ./setup-helpers/03-setup-shell.sh"
