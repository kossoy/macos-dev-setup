#!/bin/bash
# =============================================================================
# Sensitive Files Restoration Helper
# =============================================================================
# Interactive script to help locate and restore sensitive files
# =============================================================================

echo "🔍 Sensitive Files Restoration Helper"
echo "====================================="
echo ""

# Function to check if file exists and is readable
check_file() {
    local file="$1"
    if [[ -f "$file" && -r "$file" ]]; then
        echo "✅ Found: $file"
        return 0
    else
        echo "❌ Not found: $file"
        return 1
    fi
}

# Function to restore file with confirmation
restore_file() {
    local source="$1"
    local destination="$2"
    local description="$3"
    
    if check_file "$source"; then
        echo "📋 $description"
        echo "   Source: $source"
        echo "   Destination: $destination"
        echo ""
        read -p "Copy this file? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$source" "$destination"
            chmod 600 "$destination"
            echo "✅ Copied successfully"
            return 0
        fi
    fi
    return 1
}

echo "🔑 Looking for API keys..."

# Check common backup locations for API keys
API_KEY_LOCATIONS=(
    "$HOME/.zsh/private/api-keys.zsh"
    "$HOME/.zsh/private/api-keys.zsh"
    "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Backups/zsh-config/api-keys.zsh"
    "$HOME/work/backups/zsh-complete-environment-*.tar.gz"
)

# Check Time Machine backups
TM_BACKUPS=$(find /Volumes -name "Backups.backupdb" 2>/dev/null | head -1)
if [[ -n "$TM_BACKUPS" ]]; then
    TM_USER_BACKUP="$TM_BACKUPS/$(whoami)/Latest/Users/$(whoami)/.zsh/private/api-keys.zsh"
    API_KEY_LOCATIONS+=("$TM_USER_BACKUP")
fi

echo "🔍 Checking for API keys in common locations..."
for location in "${API_KEY_LOCATIONS[@]}"; do
    if [[ "$location" == *"*.tar.gz" ]]; then
        # Handle tar.gz files specially
        for backup_file in $location; do
            if [[ -f "$backup_file" ]]; then
                echo "📦 Found backup archive: $backup_file"
                echo "   Extract with: tar -xzf '$backup_file' -C /tmp/ && find /tmp -name 'api-keys.zsh'"
            fi
        done
    else
        restore_file "$location" "$HOME/.zsh/private/api-keys.zsh" "API Keys"
    fi
done

echo ""
echo "🔐 Looking for SSH keys..."

# Check for SSH keys
SSH_KEYS=(
    "$HOME/.ssh/id_ed25519"
    "$HOME/.ssh/id_rsa"
    "$HOME/.ssh/id_ed25519.pub"
    "$HOME/.ssh/id_rsa.pub"
)

echo "🔍 Checking for SSH keys..."
for key in "${SSH_KEYS[@]}"; do
    if check_file "$key"; then
        echo "✅ SSH key found: $key"
    fi
done

echo ""
echo "📋 Manual restoration steps:"
echo "1. If you have Time Machine backups:"
echo "   - Open Time Machine"
echo "   - Navigate to your user folder"
echo "   - Find .zsh/private/api-keys.zsh"
echo "   - Restore it to ~/.zsh/private/"
echo ""
echo "2. If you have cloud backups:"
echo "   - Check iCloud Drive for backup folders"
echo "   - Look for zsh-config or similar folders"
echo ""
echo "3. If you have NAS backups:"
echo "   - Mount your NAS"
echo "   - Look for mac-config or similar folders"
echo ""
echo "4. After restoring, verify with:"
echo "   source ~/.zshrc"
echo "   echo \$OPENAI_API_KEY | head -c 10"
echo ""
echo "✅ Restoration helper complete"
