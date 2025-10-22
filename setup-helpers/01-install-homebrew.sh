#!/bin/bash
# =============================================================================
# Homebrew Installation Script
# =============================================================================
# Installs Homebrew package manager for Apple Silicon Macs
# =============================================================================

set -e

echo "🍺 Installing Homebrew..."

# Check if Homebrew is already installed
if command -v brew >/dev/null 2>&1; then
    echo "✅ Homebrew is already installed"
    brew --version
    echo "✅ Homebrew added to PATH"
else

# Check if we're on macOS or Linux
if [[ "$(uname -s)" == "Darwin" ]]; then
    # macOS
    if [[ $(uname -m) == "arm64" ]]; then
        echo "📱 Detected Apple Silicon Mac"
        BREW_PREFIX="/opt/homebrew"
    else
        echo "💻 Detected Intel Mac"
        BREW_PREFIX="/usr/local"
    fi
    
    # Install Homebrew for macOS
    echo "📥 Downloading and installing Homebrew for macOS..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ -f "$BREW_PREFIX/bin/brew" ]]; then
        eval "$($BREW_PREFIX/bin/brew shellenv)"
        echo "✅ Homebrew added to PATH"
    else
        echo "❌ Homebrew installation failed"
        exit 1
    fi
else
    # Linux
    echo "🐧 Detected Linux - installing Linuxbrew"
    BREW_PREFIX="/home/linuxbrew/.linuxbrew"
    
    # Install Homebrew for Linux
    echo "📥 Downloading and installing Homebrew for Linux..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ -f "$BREW_PREFIX/bin/brew" ]]; then
        eval "$($BREW_PREFIX/bin/brew shellenv)"
        echo "✅ Homebrew added to PATH"
    else
        echo "❌ Homebrew installation failed"
        exit 1
    fi
fi
fi

# Install essential packages
echo "📦 Installing essential packages..."
# Install packages that exist on both macOS and Linux
brew install git wget curl tree jq bat fd ripgrep eza

# Install macOS-specific packages only on macOS
if [[ "$(uname -s)" == "Darwin" ]]; then
    brew install defaultbrowser
else
    echo "⚠️  Skipping macOS-specific packages on Linux"
fi

echo "✅ Homebrew installation complete"
