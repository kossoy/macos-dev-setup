#!/bin/bash
# =============================================================================
# NAS KEYCHAIN SETUP SCRIPT
# =============================================================================
# Adds NAS credentials to macOS Keychain for secure storage
# Run this once to configure, then use mount-nas-volumes.scpt
# =============================================================================

set -euo pipefail

echo "🔐 NAS Keychain Setup"
echo "====================="
echo ""
echo "This script will securely store your NAS credentials in macOS Keychain."
echo ""

# Configuration
SERVICE_NAME="NAS_Credentials"
ACCOUNT_NAME="oleg"

# Check if credentials already exist
if security find-generic-password -a "$ACCOUNT_NAME" -s "$SERVICE_NAME" >/dev/null 2>&1; then
    echo "⚠️  Credentials already exist in Keychain for account: $ACCOUNT_NAME"
    read -p "Do you want to update them? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled."
        exit 0
    fi
    
    # Delete existing entry
    security delete-generic-password -a "$ACCOUNT_NAME" -s "$SERVICE_NAME" 2>/dev/null || true
    echo "✓ Removed existing credentials"
fi

# Prompt for password
echo ""
echo "Enter your NAS password:"
read -s NAS_PASSWORD
echo ""

if [[ -z "$NAS_PASSWORD" ]]; then
    echo "❌ Error: Password cannot be empty"
    exit 1
fi

# Add to Keychain
# Allow all applications to access this password (required for AppleScript)
security add-generic-password \
    -a "$ACCOUNT_NAME" \
    -s "$SERVICE_NAME" \
    -w "$NAS_PASSWORD" \
    -A

if [[ $? -eq 0 ]]; then
    echo "✅ Successfully added NAS credentials to Keychain!"
    echo ""
    echo "You can now use the mount-nas-volumes.scpt script safely."
    echo "Your password is stored securely in macOS Keychain."
else
    echo "❌ Failed to add credentials to Keychain"
    exit 1
fi

# Clear sensitive variables
unset NAS_PASSWORD
