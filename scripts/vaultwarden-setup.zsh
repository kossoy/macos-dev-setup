#!/usr/bin/env zsh
# Vaultwarden Backup System - Quick Setup Script
# Version: 1.0.0
# Last Updated: October 6, 2025

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${CYAN}$1${NC}"
    echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    echo ""
    echo "${BLUE}▶ $1${NC}"
}

print_success() {
    echo "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo "${RED}❌ $1${NC}"
}

print_info() {
    echo "${CYAN}ℹ️  $1${NC}"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCS_DIR="$(dirname "$SCRIPT_DIR")"

print_header "🔐 Vaultwarden Backup System - Quick Setup"

echo "This script will help you set up automated Vaultwarden backups on macOS."
echo "It will:"
echo "  • Install required dependencies"
echo "  • Set up GitHub SSH keys"
echo "  • Configure backup scripts"
echo "  • Store credentials securely"
echo "  • Set up automated backups"
echo ""
read "?Continue with setup? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

# ============================================================================
# STEP 1: Check/Install Dependencies
# ============================================================================

print_step "Step 1: Installing Dependencies"

# Check Homebrew
if ! command -v brew &> /dev/null; then
    print_error "Homebrew not installed"
    echo "Install from: https://brew.sh"
    exit 1
else
    print_success "Homebrew installed"
fi

# Check/Install Bitwarden CLI
if ! command -v bw &> /dev/null; then
    print_info "Installing Bitwarden CLI..."
    brew install bitwarden-cli
    print_success "Bitwarden CLI installed"
else
    print_success "Bitwarden CLI already installed ($(bw --version))"
fi

# Check Git
if ! command -v git &> /dev/null; then
    print_error "Git not installed"
    exit 1
else
    print_success "Git installed ($(git --version | cut -d' ' -f3))"
fi

# ============================================================================
# STEP 2: SSH Key Setup
# ============================================================================

print_step "Step 2: GitHub SSH Key Setup"

SSH_KEY="$HOME/.ssh/id_ed25519_github"

if [[ -f "$SSH_KEY" ]]; then
    print_warning "SSH key already exists at $SSH_KEY"
    read "?Use existing key? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Generating new SSH key..."
        read "?Enter your email for SSH key: " EMAIL
        ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY"
    fi
else
    print_info "Generating SSH key..."
    read "?Enter your email for SSH key: " EMAIL
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY"
    print_success "SSH key generated"
fi

# Add to ssh-agent
eval "$(ssh-agent -s)" > /dev/null
ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null
print_success "SSH key added to agent"

# Create SSH config if needed
if [[ ! -f "$HOME/.ssh/config" ]] || ! grep -q "github.com" "$HOME/.ssh/config"; then
    print_info "Configuring SSH..."
    cat >> "$HOME/.ssh/config" << EOF

# GitHub configuration
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile $SSH_KEY
EOF
    chmod 600 "$HOME/.ssh/config"
    print_success "SSH config updated"
fi

# Copy public key to clipboard
pbcopy < "${SSH_KEY}.pub"
print_success "Public key copied to clipboard"

echo ""
print_warning "ACTION REQUIRED:"
echo "1. Go to: ${CYAN}https://github.com/settings/keys${NC}"
echo "2. Click 'New SSH key'"
echo "3. Paste the key from clipboard (already copied)"
echo "4. Give it a title: 'MacBook Pro - Vaultwarden Backups'"
echo "5. Click 'Add SSH key'"
echo ""
read "?Press Enter after adding key to GitHub..."

# Test SSH connection
print_info "Testing GitHub SSH connection..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    print_success "GitHub SSH authentication working"
else
    print_error "GitHub SSH authentication failed"
    echo "Please check your key was added correctly"
    exit 1
fi

# ============================================================================
# STEP 3: Create GitHub Repository
# ============================================================================

print_step "Step 3: GitHub Repository Setup"

echo ""
print_warning "ACTION REQUIRED:"
echo "Create a PRIVATE repository on GitHub:"
echo "1. Go to: ${CYAN}https://github.com/new${NC}"
echo "2. Repository name: ${CYAN}vaultwarden-backups${NC}"
echo "3. Visibility: ${YELLOW}PRIVATE${NC} (⚠️  IMPORTANT!)"
echo "4. DO NOT initialize with README"
echo "5. Create repository"
echo ""
read "?Enter your GitHub username: " GITHUB_USERNAME

if [[ -z "$GITHUB_USERNAME" ]]; then
    print_error "GitHub username required"
    exit 1
fi

read "?Press Enter after creating the repository..."

# ============================================================================
# STEP 4: Set Up Backup Directory
# ============================================================================

print_step "Step 4: Setting Up Backup Directory"

BACKUP_DIR="$HOME/Documents/vaultwarden-backups"
VERSIONS_DIR="$BACKUP_DIR/versions"

if [[ -d "$BACKUP_DIR/.git" ]]; then
    print_warning "Backup directory already exists and is a git repository"
else
    print_info "Creating backup directory..."
    mkdir -p "$VERSIONS_DIR"
    
    cd "$BACKUP_DIR"
    git init
    git branch -M main
    
    # Create .gitignore
    cat > .gitignore << 'EOF'
# Sensitive files
.env
*.log
.DS_Store

# Temporary files
*.tmp
*.temp
*.swp

# System files
.Spotlight-V100
.Trashes
.fseventsd
EOF
    
    git add .gitignore
    git commit -m "Initial commit: Setup backup repository"
    
    # Add remote
    git remote add origin "git@github.com:${GITHUB_USERNAME}/vaultwarden-backups.git"
    
    # Push
    print_info "Pushing to GitHub..."
    git push -u origin main
    
    print_success "Backup directory initialized and pushed to GitHub"
fi

# ============================================================================
# STEP 5: Store Credentials in Keychain
# ============================================================================

print_step "Step 5: Storing Credentials in Keychain"

echo ""
print_warning "You will need:"
echo "1. Your Vaultwarden master password"
echo "2. A NEW strong backup encryption password (create one now!)"
echo ""

# Master password
read -s "?Enter your Vaultwarden master password: " MASTER_PASS
echo ""

if [[ -z "$MASTER_PASS" ]]; then
    print_error "Master password cannot be empty"
    exit 1
fi

security add-generic-password \
  -a "$USER" \
  -s "vaultwarden-backup-master" \
  -w "$MASTER_PASS" \
  -U 2>/dev/null

print_success "Master password stored in Keychain"

# Backup encryption password
echo ""
print_warning "Create a BACKUP ENCRYPTION password (different from master!)"
echo "⚠️  ${RED}WRITE THIS DOWN AND STORE IT SECURELY!${NC}"
echo "You'll need it to decrypt your backups."
echo ""

read -s "?Enter backup encryption password: " BACKUP_PASS
echo ""
read -s "?Confirm backup encryption password: " BACKUP_PASS_CONFIRM
echo ""

if [[ "$BACKUP_PASS" != "$BACKUP_PASS_CONFIRM" ]]; then
    print_error "Passwords don't match"
    exit 1
fi

if [[ -z "$BACKUP_PASS" ]]; then
    print_error "Backup password cannot be empty"
    exit 1
fi

security add-generic-password \
  -a "$USER" \
  -s "vaultwarden-backup-encrypt" \
  -w "$BACKUP_PASS" \
  -U 2>/dev/null

print_success "Backup password stored in Keychain"

# Clear variables
unset MASTER_PASS
unset BACKUP_PASS
unset BACKUP_PASS_CONFIRM

# Optional: Telegram
echo ""
read "?Set up Telegram notifications? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    read "?Telegram Bot Token: " TG_TOKEN
    read "?Telegram Chat ID: " TG_CHAT
    
    if [[ -n "$TG_TOKEN" && -n "$TG_CHAT" ]]; then
        security add-generic-password \
          -a "$USER" \
          -s "vaultwarden-backup-telegram-token" \
          -w "$TG_TOKEN" \
          -U 2>/dev/null
        
        security add-generic-password \
          -a "$USER" \
          -s "vaultwarden-backup-telegram-chat" \
          -w "$TG_CHAT" \
          -U 2>/dev/null
        
        print_success "Telegram credentials stored"
        TELEGRAM_ENABLED=1
    fi
else
    TELEGRAM_ENABLED=0
fi

# ============================================================================
# STEP 6: Create Configuration File
# ============================================================================

print_step "Step 6: Creating Configuration File"

read "?Enter your Vaultwarden email address: " BW_EMAIL

cat > "$HOME/.vaultwarden-backup-config" << EOF
# Vaultwarden Backup Configuration
# Sensitive credentials are stored in macOS Keychain

# Bitwarden server URL
BW_SERVER="https://pwd.oklabs.uk"

# Bitwarden account email
BW_ACCOUNT="$BW_EMAIL"

# Backup directory
BACKUP_DIR="$HOME/Documents/vaultwarden-backups"
VERSIONS_DIR="\$BACKUP_DIR/versions"

# Backup retention (days)
RETENTION_DAILY=7
RETENTION_WEEKLY=30
RETENTION_MONTHLY=365

# Telegram notifications (set to 1 to enable)
TELEGRAM_ENABLED=$TELEGRAM_ENABLED

# Git repository
GIT_PUSH_ENABLED=1
GIT_REMOTE="origin"
GIT_BRANCH="main"

# Backup file prefix
BACKUP_PREFIX="vault"
EOF

print_success "Configuration file created at ~/.vaultwarden-backup-config"

# ============================================================================
# STEP 7: Install Scripts
# ============================================================================

print_step "Step 7: Installing Backup Scripts"

mkdir -p "$HOME/bin"

# Copy backup script
cp "$SCRIPT_DIR/vaultwarden-backup.zsh" "$HOME/bin/"
chmod +x "$HOME/bin/vaultwarden-backup.zsh"
print_success "Backup script installed to ~/bin/vaultwarden-backup.zsh"

# Copy monitor script
cp "$SCRIPT_DIR/vaultwarden-backup-monitor.zsh" "$HOME/bin/"
chmod +x "$HOME/bin/vaultwarden-backup-monitor.zsh"
print_success "Monitor script installed to ~/bin/vaultwarden-backup-monitor.zsh"

# Add to PATH if needed
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.zshrc"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zshrc"
    print_info "Added ~/bin to PATH in ~/.zshrc"
fi

# Add aliases
if ! grep -q "alias vw-backup" "$HOME/.zshrc"; then
    cat >> "$HOME/.zshrc" << 'EOF'

# Vaultwarden Backup Aliases
alias vw-backup="$HOME/bin/vaultwarden-backup.zsh"
alias vw-monitor="$HOME/bin/vaultwarden-backup-monitor.zsh"
EOF
    print_info "Added aliases to ~/.zshrc"
fi

# ============================================================================
# STEP 8: Test Backup
# ============================================================================

print_step "Step 8: Testing Backup"

echo ""
print_info "Running test backup..."
echo ""

if "$HOME/bin/vaultwarden-backup.zsh"; then
    print_success "Test backup completed successfully!"
else
    print_error "Test backup failed"
    echo "Check the logs for details"
    exit 1
fi

# ============================================================================
# STEP 9: Set Up LaunchAgent
# ============================================================================

print_step "Step 9: Setting Up Automated Backups"

PLIST_FILE="$HOME/Library/LaunchAgents/com.befeast.vaultwarden-backup.plist"

cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.befeast.vaultwarden-backup</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>${HOME}/bin/vaultwarden-backup.zsh</string>
    </array>
    
    <key>StartInterval</key>
    <integer>7200</integer>
    
    <key>WorkingDirectory</key>
    <string>${HOME}/Documents/vaultwarden-backups</string>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        <key>HOME</key>
        <string>${HOME}</string>
    </dict>
    
    <key>StandardOutPath</key>
    <string>${HOME}/Library/Logs/vaultwarden-backup.log</string>
    <key>StandardErrorPath</key>
    <string>${HOME}/Library/Logs/vaultwarden-backup-error.log</string>
    
    <key>Nice</key>
    <integer>1</integer>
    
    <key>ProcessType</key>
    <string>Background</string>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    
    <key>ThrottleInterval</key>
    <integer>300</integer>
</dict>
</plist>
EOF

launchctl load "$PLIST_FILE"
print_success "LaunchAgent loaded (backups will run every 2 hours)"

# ============================================================================
# STEP 10: Final Checks
# ============================================================================

print_step "Step 10: Running Final Checks"

echo ""
"$HOME/bin/vaultwarden-backup-monitor.zsh"

# ============================================================================
# COMPLETE
# ============================================================================

print_header "✅ Setup Complete!"

echo "Your Vaultwarden backup system is now configured and running."
echo ""
echo "${GREEN}What's been set up:${NC}"
echo "  ✅ Automated backups every 2 hours"
echo "  ✅ Encrypted vault exports"
echo "  ✅ Git version control with GitHub"
echo "  ✅ Secure credential storage in Keychain"
echo "  ✅ Monitoring dashboard"
echo ""
echo "${YELLOW}Next steps:${NC}"
echo "  1. Wait 2 hours and verify automatic backup runs"
echo "  2. Check status: ${CYAN}vw-monitor --full${NC}"
echo "  3. View logs: ${CYAN}tail -f ~/Library/Logs/vaultwarden-backup.log${NC}"
echo "  4. Read full docs: ${CYAN}$DOCS_DIR/guides/vaultwarden-backup-index.md${NC}"
echo ""
echo "${RED}⚠️  IMPORTANT:${NC}"
echo "  • Write down your backup encryption password and store it securely!"
echo "  • Test restore procedure quarterly"
echo "  • Keep GitHub repository PRIVATE"
echo ""
echo "${CYAN}Useful commands:${NC}"
echo "  Manual backup:  ${CYAN}vw-backup${NC}"
echo "  Check status:   ${CYAN}vw-monitor${NC}"
echo "  Full report:    ${CYAN}vw-monitor --full${NC}"
echo "  View backups:   ${CYAN}ls -lh ~/Documents/vaultwarden-backups/versions/${NC}"
echo ""
print_success "Happy backing up! 🎉"
echo ""

