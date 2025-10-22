#!/bin/bash
# Simple macOS Fresh Setup - Just copy working files
# No overcomplicated package structure, no templates, just works

set -e

echo "🍎 Simple macOS Fresh Setup"
echo "=========================="
echo ""

# Check if running on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📦 Installing Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "📦 Installing essential packages..."
brew install git wget curl tree jq bat fd ripgrep eza

echo "🐚 Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "🔌 Installing Oh My Zsh plugins..."
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
fi

echo "📁 Creating zsh config directory..."
mkdir -p ~/.zsh/{config,private}

echo "📋 Copying your working configuration..."
# Copy your actual working files
cp "$SCRIPT_DIR/config/zsh/config/aliases.zsh" ~/.zsh/config/aliases.zsh
cp "$SCRIPT_DIR/config/zsh/config/functions.zsh" ~/.zsh/config/functions.zsh  
cp "$SCRIPT_DIR/config/zsh/config/paths.zsh" ~/.zsh/config/paths.zsh
cp "$SCRIPT_DIR/config/zsh/config/tools.zsh" ~/.zsh/config/tools.zsh

# Create simple .zshrc that sources your files
cat > ~/.zshrc << 'EOF'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git brew macos zsh-autosuggestions zsh-syntax-highlighting virtualenv pip python docker)
source $ZSH/oh-my-zsh.sh

# Your custom config
ZSH_CONFIG_DIR="$HOME/.zsh/config"
source "$ZSH_CONFIG_DIR/paths.zsh"
source "$ZSH_CONFIG_DIR/aliases.zsh" 
source "$ZSH_CONFIG_DIR/functions.zsh"
source "$ZSH_CONFIG_DIR/tools.zsh"

# Load context if exists
if [ -f "$HOME/.zsh/private/current.zsh" ]; then
    source "$HOME/.zsh/private/current.zsh"
fi
EOF

echo "🎨 Copying Powerlevel10k config..."
cp "$SCRIPT_DIR/config/p10k.zsh" ~/.p10k.zsh

echo "📁 Creating work directory..."
mkdir -p ~/work/{databases,tools,projects/{work,personal},configs/{work,personal},scripts,docs,bin}

echo "📜 Copying utility scripts..."
cp "$SCRIPT_DIR/scripts/"*.sh ~/work/scripts/ 2>/dev/null || true
cp "$SCRIPT_DIR/scripts/"*.zsh ~/work/scripts/ 2>/dev/null || true
chmod +x ~/work/scripts/*.sh ~/work/scripts/*.zsh 2>/dev/null || true

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Configure your API keys in ~/.zsh/private/api-keys.zsh"
echo "3. Set up your context files"
echo ""
echo "Your working configuration has been copied and should work exactly as before."
