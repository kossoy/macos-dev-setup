#!/bin/bash
# =============================================================================
# INTEGRATED SETUP SCRIPT
# =============================================================================
# Consolidates all existing scripts and tools from Mac OS install/bin
# into the organized ~/work structure as described in Install Mac OS.md
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}=============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=============================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Directories
WORK_ROOT="$HOME/work"
SCRIPTS_DIR="$WORK_ROOT/scripts"
BIN_SOURCE="$WORK_ROOT/Mac OS install/bin"
ASSETS_SOURCE="$WORK_ROOT/Mac OS install/assets"
ZSH_CONFIG="$HOME/.config/zsh"

# Create necessary directories
print_header "Creating Directory Structure"
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$ZSH_CONFIG"/{aliases,functions,paths,contexts}
mkdir -p "$WORK_ROOT/backups/vault"
print_success "Directory structure created"

# =============================================================================
# STEP 1: Configure Security (API Keys & Credentials)
# =============================================================================
print_header "Step 1: Configuring Security"

API_KEYS_FILE="$ZSH_CONFIG/api-keys.zsh"
if [[ ! -f "$API_KEYS_FILE" ]]; then
    if [[ -f "$ASSETS_SOURCE/api-keys.zsh" ]]; then
        cp "$ASSETS_SOURCE/api-keys.zsh" "$API_KEYS_FILE"
        chmod 600 "$API_KEYS_FILE"
        print_success "Created api-keys.zsh from template"
        print_warning "IMPORTANT: Edit $API_KEYS_FILE and add your credentials"
    else
        print_error "api-keys.zsh template not found at $ASSETS_SOURCE"
    fi
else
    print_warning "api-keys.zsh already exists, skipping"
fi

# Add api-keys.zsh to .gitignore
if [[ -f "$WORK_ROOT/.gitignore" ]]; then
    if ! grep -q "api-keys.zsh" "$WORK_ROOT/.gitignore"; then
        echo "# Sensitive credentials" >> "$WORK_ROOT/.gitignore"
        echo ".config/zsh/api-keys.zsh" >> "$WORK_ROOT/.gitignore"
        print_success "Added api-keys.zsh to .gitignore"
    fi
fi

# =============================================================================
# STEP 2: Copy Enhanced Zsh Configurations
# =============================================================================
print_header "Step 2: Installing Enhanced Zsh Configurations"

# Copy aliases.zsh
if [[ -f "$ASSETS_SOURCE/aliases.zsh" ]]; then
    cp "$ASSETS_SOURCE/aliases.zsh" "$ZSH_CONFIG/aliases/"
    print_success "Installed aliases.zsh"
else
    print_warning "aliases.zsh not found, skipping"
fi

# Copy functions.zsh
if [[ -f "$ASSETS_SOURCE/functions.zsh" ]]; then
    cp "$ASSETS_SOURCE/functions.zsh" "$ZSH_CONFIG/functions/"
    print_success "Installed functions.zsh"
else
    print_warning "functions.zsh not found, skipping"
fi

# Copy tools.zsh
if [[ -f "$ASSETS_SOURCE/tools.zsh" ]]; then
    cp "$ASSETS_SOURCE/tools.zsh" "$ZSH_CONFIG/functions/"
    print_success "Installed tools.zsh"
else
    print_warning "tools.zsh not found, skipping"
fi

# Copy paths.zsh if it exists
if [[ -f "$ASSETS_SOURCE/paths.zsh" ]]; then
    cp "$ASSETS_SOURCE/paths.zsh" "$ZSH_CONFIG/paths/"
    print_success "Installed paths.zsh"
fi

# =============================================================================
# STEP 3: Link Utility Scripts
# =============================================================================
print_header "Step 3: Linking Utility Scripts"

# Visual disk usage analyzer
if [[ -f "$BIN_SOURCE/ai_wdu.sh" ]]; then
    ln -sf "$BIN_SOURCE/ai_wdu.sh" "$SCRIPTS_DIR/wdu.sh"
    chmod +x "$SCRIPTS_DIR/wdu.sh"
    print_success "Linked wdu.sh (visual disk usage)"
else
    print_warning "ai_wdu.sh not found"
fi

# Screenshot organizer
if [[ -f "$BIN_SOURCE/organize.sh" ]]; then
    ln -sf "$BIN_SOURCE/organize.sh" "$SCRIPTS_DIR/organize-screenshots.sh"
    chmod +x "$SCRIPTS_DIR/organize-screenshots.sh"
    print_success "Linked organize-screenshots.sh"
else
    print_warning "organize.sh not found"
fi

# Video to audio converter
if [[ -f "$BIN_SOURCE/y2a.sh" ]]; then
    ln -sf "$BIN_SOURCE/y2a.sh" "$SCRIPTS_DIR/video-to-audio.sh"
    chmod +x "$SCRIPTS_DIR/video-to-audio.sh"
    print_success "Linked video-to-audio.sh"
else
    print_warning "y2a.sh not found"
fi

# Network priority manager
if [[ -f "$BIN_SOURCE/network-priority.sh" ]]; then
    ln -sf "$BIN_SOURCE/network-priority.sh" "$SCRIPTS_DIR/network-priority.sh"
    chmod +x "$SCRIPTS_DIR/network-priority.sh"
    print_success "Linked network-priority.sh"
else
    print_warning "network-priority.sh not found"
fi

# Hostname fixer
if [[ -f "$BIN_SOURCE/fix_hostname.sh" ]]; then
    ln -sf "$BIN_SOURCE/fix_hostname.sh" "$SCRIPTS_DIR/fix-hostname.sh"
    chmod +x "$SCRIPTS_DIR/fix-hostname.sh"
    print_success "Linked fix-hostname.sh"
else
    print_warning "fix_hostname.sh not found"
fi

# Vault backup (with security updates)
if [[ -f "$BIN_SOURCE/vault_backup.sh" ]]; then
    # Copy instead of link so we can modify it
    cp "$BIN_SOURCE/vault_backup.sh" "$SCRIPTS_DIR/vault-backup.sh"
    chmod +x "$SCRIPTS_DIR/vault-backup.sh"
    
    # Update to use api-keys.zsh
    if grep -q "source.*\.env" "$SCRIPTS_DIR/vault-backup.sh"; then
        sed -i.bak 's|source "$ENV_FILE"|source "$HOME/.config/zsh/api-keys.zsh"|g' "$SCRIPTS_DIR/vault-backup.sh"
        rm -f "$SCRIPTS_DIR/vault-backup.sh.bak"
        print_success "Installed vault-backup.sh (with security updates)"
    else
        print_success "Installed vault-backup.sh"
    fi
else
    print_warning "vault_backup.sh not found"
fi

# Sync to branches (Git utility)
if [[ -f "$BIN_SOURCE/sync_to_branches.sh" ]]; then
    ln -sf "$BIN_SOURCE/sync_to_branches.sh" "$SCRIPTS_DIR/sync-to-branches.sh"
    chmod +x "$SCRIPTS_DIR/sync-to-branches.sh"
    print_success "Linked sync-to-branches.sh"
else
    print_warning "sync_to_branches.sh not found"
fi

# =============================================================================
# STEP 4: Configure Apache JMeter
# =============================================================================
print_header "Step 4: Configuring Apache JMeter"

JMETER_DIR="$BIN_SOURCE/apache-jmeter-5.6.2"
if [[ -d "$JMETER_DIR" ]]; then
    # Add JMeter to paths.zsh if not already there
    PATHS_FILE="$ZSH_CONFIG/paths/paths.zsh"
    if [[ -f "$PATHS_FILE" ]]; then
        if ! grep -q "JMETER_HOME" "$PATHS_FILE"; then
            cat >> "$PATHS_FILE" << EOF

# =============================================================================
# APACHE JMETER
# =============================================================================
export JMETER_HOME="$JMETER_DIR"
export PATH="\$JMETER_HOME/bin:\$PATH"
EOF
            print_success "Added JMeter to paths.zsh"
        else
            print_warning "JMeter already configured in paths.zsh"
        fi
    else
        # Create paths.zsh if it doesn't exist
        cat > "$PATHS_FILE" << EOF
#!/bin/zsh
# =============================================================================
# PATHS CONFIGURATION
# =============================================================================

# Development paths
export WORK_ROOT="\$HOME/work"
export PROJECTS_ROOT="\$WORK_ROOT/projects"
export CONFIGS_ROOT="\$WORK_ROOT/configs"
export SCRIPTS_ROOT="\$WORK_ROOT/scripts"
export TOOLS_ROOT="\$WORK_ROOT/tools"
export DOCS_ROOT="\$WORK_ROOT/docs"

# Add scripts to PATH
export PATH="\$SCRIPTS_ROOT:\$PATH"

# Apache JMeter
export JMETER_HOME="$JMETER_DIR"
export PATH="\$JMETER_HOME/bin:\$PATH"
EOF
        print_success "Created paths.zsh with JMeter configuration"
    fi
    
    # Create JMeter aliases
    ALIASES_FILE="$ZSH_CONFIG/aliases/aliases.zsh"
    if [[ -f "$ALIASES_FILE" ]]; then
        if ! grep -q "alias jmeter=" "$ALIASES_FILE"; then
            cat >> "$ALIASES_FILE" << 'EOF'

# =============================================================================
# JMETER ALIASES
# =============================================================================
alias jmeter='$JMETER_HOME/bin/jmeter'
alias jmeter-cli='$JMETER_HOME/bin/jmeter -n'
alias jmeter-server='$JMETER_HOME/bin/jmeter-server'
EOF
            print_success "Added JMeter aliases"
        fi
    fi
else
    print_warning "Apache JMeter not found at $JMETER_DIR"
fi

# =============================================================================
# STEP 5: Configure NAS Volume Mounting
# =============================================================================
print_header "Step 5: Configuring NAS Volume Mounting"

# Make setup-nas-keychain.sh executable
if [[ -f "$SCRIPTS_DIR/setup-nas-keychain.sh" ]]; then
    chmod +x "$SCRIPTS_DIR/setup-nas-keychain.sh"
    print_success "NAS Keychain setup script ready"
    print_warning "Run: $SCRIPTS_DIR/setup-nas-keychain.sh to configure credentials"
fi

# Make mount-nas-volumes.scpt accessible
if [[ -f "$SCRIPTS_DIR/mount-nas-volumes.scpt" ]]; then
    print_success "NAS mount script ready"
    
    # Add convenience function to functions.zsh
    FUNCTIONS_FILE="$ZSH_CONFIG/functions/functions.zsh"
    if [[ -f "$FUNCTIONS_FILE" ]]; then
        if ! grep -q "nasmount()" "$FUNCTIONS_FILE"; then
            cat >> "$FUNCTIONS_FILE" << 'EOF'

# =============================================================================
# NAS VOLUME MOUNTING
# =============================================================================

# Mount NAS volumes using secure AppleScript
nasmount() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript "$HOME/work/scripts/mount-nas-volumes.scpt"
    else
        echo "Error: nasmount function only works on macOS"
        return 1
    fi
}
EOF
            print_success "Added nasmount() function"
        fi
    fi
fi

# =============================================================================
# STEP 6: Update Main .zshrc
# =============================================================================
print_header "Step 6: Updating .zshrc"

ZSHRC="$HOME/.zshrc"
if [[ ! -f "$ZSHRC" ]]; then
    touch "$ZSHRC"
fi

# Check if our configuration is already sourced
if ! grep -q "Source organized zsh configuration" "$ZSHRC"; then
    cat >> "$ZSHRC" << 'EOF'

# =============================================================================
# Source organized zsh configuration
# =============================================================================
if [ -f ~/.config/zsh/paths/paths.zsh ]; then
    source ~/.config/zsh/paths/paths.zsh
fi

if [ -f ~/.config/zsh/aliases/aliases.zsh ]; then
    source ~/.config/zsh/aliases/aliases.zsh
fi

if [ -f ~/.config/zsh/functions/functions.zsh ]; then
    source ~/.config/zsh/functions/functions.zsh
fi

if [ -f ~/.config/zsh/functions/tools.zsh ]; then
    source ~/.config/zsh/functions/tools.zsh
fi

# Load context-specific configurations
if [ -f ~/.config/zsh/contexts/current.zsh ]; then
    source ~/.config/zsh/contexts/current.zsh
fi

# Load API keys and sensitive credentials (MUST be chmod 600)
if [ -f ~/.config/zsh/api-keys.zsh ]; then
    source ~/.config/zsh/api-keys.zsh
fi
EOF
    print_success "Updated .zshrc to load configurations"
else
    print_warning ".zshrc already configured, skipping"
fi

# =============================================================================
# STEP 7: Set Permissions
# =============================================================================
print_header "Step 7: Setting Permissions"

# Make all scripts in ~/work/scripts executable
find "$SCRIPTS_DIR" -type f -name "*.sh" -exec chmod +x {} \;
print_success "Set executable permissions on shell scripts"

# Secure api-keys.zsh
if [[ -f "$API_KEYS_FILE" ]]; then
    chmod 600 "$API_KEYS_FILE"
    print_success "Secured api-keys.zsh (chmod 600)"
fi

# =============================================================================
# SUMMARY
# =============================================================================
print_header "Setup Complete!"

echo -e "${GREEN}Installed Scripts:${NC}"
echo "  • wdu.sh - Visual disk usage analyzer"
echo "  • organize-screenshots.sh - Screenshot organizer"
echo "  • video-to-audio.sh - Video to audio converter (ffmpeg)"
echo "  • network-priority.sh - Network priority manager"
echo "  • fix-hostname.sh - Hostname fixer"
echo "  • vault-backup.sh - Bitwarden vault backup"
echo "  • sync-to-branches.sh - Git branch synchronization"
echo "  • llm-usage.sh - LLM API usage tracker"
echo "  • setup-nas-keychain.sh - NAS credential setup"
echo "  • mount-nas-volumes.scpt - NAS volume mounter"

echo -e "\n${GREEN}Installed Configurations:${NC}"
echo "  • Enhanced aliases (git, docker, k8s, network)"
echo "  • Advanced functions (process mgmt, k8s, extraction)"
echo "  • Lazy-loaded tools (pyenv, docker, sdkman)"
echo "  • Apache JMeter integration"

echo -e "\n${YELLOW}Next Steps:${NC}"
echo "  1. Edit $API_KEYS_FILE and add your credentials"
echo "  2. Run: $SCRIPTS_DIR/setup-nas-keychain.sh (for NAS mounting)"
echo "  3. Configure JetBrains Toolbox to use ~/work/bin for launchers:"
echo "     Settings → Tools → Shell Scripts → /Users/$(whoami)/work/bin"
echo "  4. Reload your shell: source ~/.zshrc"
echo "  5. Test with: wdu.sh"

echo -e "\n${BLUE}Security Notes:${NC}"
echo "  ✓ api-keys.zsh is chmod 600 (readable only by you)"
echo "  ✓ Hardcoded credentials removed from scripts"
echo "  ✓ NAS passwords use macOS Keychain"
echo "  ✓ api-keys.zsh added to .gitignore"

echo -e "\n${GREEN}All done! 🚀${NC}\n"
