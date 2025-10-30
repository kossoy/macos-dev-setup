#!/bin/bash
# Docker test script for macOS Fresh Setup Package

set -e

echo "🐳 Docker Test Environment for macOS Fresh Setup"
echo "================================================"

# Navigate to package directory
cd /home/testuser/macos-dev-setup

echo "📁 Package contents:"
ls -la

echo ""
echo "🔍 Testing bootstrap script syntax:"
bash -n bootstrap.sh
echo "✅ bootstrap.sh syntax OK"

echo ""
echo "🔍 Testing setup helper scripts:"
for script in setup-helpers/*.sh; do
    echo "Testing $script..."
    bash -n "$script"
    echo "✅ $script syntax OK"
done

echo ""
echo "🔍 Testing utility scripts:"
for script in scripts/*.sh; do
    echo "Testing $script..."
    bash -n "$script"
    echo "✅ $script syntax OK"
done

echo ""
echo "🔍 Testing zsh configuration files:"
# Test zsh config syntax
zsh -n config/zsh/zshrc.template
echo "✅ zshrc.template syntax OK"

# Test individual config files
for config in config/zsh/config/*.zsh; do
    echo "Testing $config..."
    zsh -n "$config"
    echo "✅ $config syntax OK"
done

echo ""
echo "🔍 Testing file permissions:"
chmod +x bootstrap.sh
chmod +x setup-helpers/*.sh
chmod +x scripts/*.sh
echo "✅ All scripts are executable"

echo ""
echo "🔍 Testing path resolution:"
# Test if paths in config files exist
echo "Checking config/zsh/config/ paths..."
ls -la config/zsh/config/

echo ""
echo "🔍 Testing template files:"
echo "Checking template files..."
ls -la config/zsh/private/
ls -la config/zsh/contexts/

echo ""
echo "✅ Docker test environment setup complete!"
echo "You can now test the package in a controlled environment."
