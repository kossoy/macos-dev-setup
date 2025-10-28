#!/bin/bash
# =============================================================================
# Homebrew Installation Script
# =============================================================================
# Installs Homebrew package manager with idempotency and error handling
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
    export NONINTERACTIVE=1
fi

print_status "Installing Homebrew..."

# Check if Homebrew is already installed
if command -v brew >/dev/null 2>&1; then
    print_success "Homebrew is already installed"
    brew --version

    # Update Homebrew
    print_status "Updating Homebrew..."
    brew update || print_warning "Failed to update Homebrew (continuing anyway)"

    print_success "Homebrew is up to date"
else
    # Check if we're on macOS or Linux
    if [[ "$(uname -s)" == "Darwin" ]]; then
        # macOS
        if [[ $(uname -m) == "arm64" ]]; then
            print_status "Detected Apple Silicon Mac"
            BREW_PREFIX="/opt/homebrew"
        else
            print_status "Detected Intel Mac"
            BREW_PREFIX="/usr/local"
        fi

        # Install Homebrew for macOS
        print_status "Downloading and installing Homebrew for macOS..."
        print_warning "This may take a few minutes..."

        if $NON_INTERACTIVE; then
            NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        # Add Homebrew to PATH for current session
        if [[ -f "$BREW_PREFIX/bin/brew" ]]; then
            eval "$($BREW_PREFIX/bin/brew shellenv)"
            print_success "Homebrew installed and added to PATH"
        else
            print_error "Homebrew installation failed"
            exit 1
        fi

        # Add to shell profile if not already there
        if [[ -f "$HOME/.zprofile" ]]; then
            if ! grep -q "brew shellenv" "$HOME/.zprofile"; then
                echo 'eval "$('$BREW_PREFIX'/bin/brew shellenv)"' >> "$HOME/.zprofile"
                print_status "Added Homebrew to ~/.zprofile"
            fi
        fi
    else
        # Linux
        print_status "Detected Linux - installing Linuxbrew"
        BREW_PREFIX="/home/linuxbrew/.linuxbrew"

        # Install Homebrew for Linux
        print_status "Downloading and installing Homebrew for Linux..."

        if $NON_INTERACTIVE; then
            NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        # Add Homebrew to PATH for current session
        if [[ -f "$BREW_PREFIX/bin/brew" ]]; then
            eval "$($BREW_PREFIX/bin/brew shellenv)"
            print_success "Homebrew installed and added to PATH"
        else
            print_error "Homebrew installation failed"
            exit 1
        fi
    fi
fi

# Install essential packages
print_status "Installing essential packages..."

# Define package list
ESSENTIAL_PACKAGES=(
    git
    wget
    curl
    tree
    jq
    bat
    fd
    ripgrep
    eza
)

# Install each package with error handling
for package in "${ESSENTIAL_PACKAGES[@]}"; do
    if brew list "$package" &>/dev/null; then
        print_success "$package already installed"
    else
        print_status "Installing $package..."
        if brew install "$package"; then
            print_success "$package installed"
        else
            print_warning "Failed to install $package (continuing anyway)"
        fi
    fi
done

# Install macOS-specific packages only on macOS
if [[ "$(uname -s)" == "Darwin" ]]; then
    print_status "Installing macOS-specific packages..."

    if brew list defaultbrowser &>/dev/null; then
        print_success "defaultbrowser already installed"
    else
        print_status "Installing defaultbrowser..."
        if brew install defaultbrowser; then
            print_success "defaultbrowser installed"
        else
            print_warning "Failed to install defaultbrowser (optional package)"
        fi
    fi
fi

print_success "Homebrew installation complete"
