#!/bin/bash
# =============================================================================
# Shell Configuration Setup Script
# =============================================================================
# Sets up zsh configuration with user-provided values
# =============================================================================

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"


echo "⚙️  Setting up shell configuration..."

# Create zsh configuration directory structure
echo "📁 Creating configuration directories..."
mkdir -p ~/.zsh/{config,plugins,themes,private}

# Copy configuration files
echo "📋 Copying configuration files..."
cp "$PACKAGE_DIR/config/zsh/config/paths.zsh" ~/.zsh/config/paths.zsh
cp "$PACKAGE_DIR/config/zsh/config/aliases.zsh" ~/.zsh/config/aliases.zsh
cp "$PACKAGE_DIR/config/zsh/config/functions.zsh" ~/.zsh/config/functions.zsh
cp "$PACKAGE_DIR/config/zsh/config/tools.zsh" ~/.zsh/config/tools.zsh

# Create main zshrc from template
echo "📝 Creating .zshrc from template..."
# Backup existing .zshrc if it exists
if [[ -f ~/.zshrc ]]; then
    echo "📋 Backing up existing .zshrc to .zshrc.backup"
    cp ~/.zshrc ~/.zshrc.backup
fi
cp "$PACKAGE_DIR/config/zsh/zshrc.template" ~/.zshrc

# Create context template
echo "📝 Creating context template..."
cp "$PACKAGE_DIR/config/zsh/contexts/current.zsh.template" ~/.zsh/private/current.zsh

# Create API keys template
echo "🔑 Creating API keys template..."
cp "$PACKAGE_DIR/config/zsh/private/api-keys.zsh.template" ~/.zsh/private/api-keys.zsh

# Set proper permissions for sensitive files
chmod 600 ~/.zsh/private/api-keys.zsh

# Copy Powerlevel10k configuration
echo "🎨 Installing Powerlevel10k configuration..."
cp "$PACKAGE_DIR/config/p10k.zsh" ~/.p10k.zsh

# Create work directory structure
echo "📁 Creating work directory structure..."
mkdir -p ~/work/{databases,tools,projects/{work,personal},configs/{work,personal},scripts,docs,bin}

# Copy utility scripts
echo "📜 Copying utility scripts..."
cp "$PACKAGE_DIR/scripts"/* ~/work/scripts/
chmod +x ~/work/scripts/*.sh

# Backup existing .zshrc if it exists
if [[ -f ~/.zshrc.bak ]]; then
    echo "⚠️  Existing .zshrc.bak found, creating new backup..."
    mv ~/.zshrc.bak ~/.zshrc.bak.$(date +%Y%m%d_%H%M%S)
fi

if [[ -f ~/.zshrc ]]; then
    echo "💾 Backing up existing .zshrc..."
    cp ~/.zshrc ~/.zshrc.bak
fi

echo "✅ Shell configuration setup complete"
echo ""
echo "📋 Next steps:"
echo "1. Restore your API keys to ~/.config/zsh/private/api-keys.zsh"
echo "2. Run: source ~/.zshrc"
echo "3. Configure your Git settings:"
echo "   git config --global user.name 'Your Name'"
echo "   git config --global user.email 'your.email@example.com'"
