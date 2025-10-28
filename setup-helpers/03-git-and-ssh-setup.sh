#!/bin/bash
# =============================================================================
# Git and SSH Configuration Script
# =============================================================================
# Interactive setup for Git, SSH keys, and GitHub CLI
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

print_header "🔐 Git and SSH Configuration"
print_header "============================="
echo ""

# Check for non-interactive flag
NON_INTERACTIVE=false
if [[ "$1" == "--non-interactive" ]]; then
    NON_INTERACTIVE=true
    print_error "This script requires interactive input"
    print_status "Please run without --non-interactive flag"
    exit 1
fi

# ============================================================================
# Git Configuration
# ============================================================================

print_header "📝 Git Configuration"
echo ""

# Check if Git is installed
if ! command -v git &>/dev/null; then
    print_error "Git is not installed"
    print_status "Install with: brew install git"
    exit 1
fi

print_success "Git version: $(git --version)"
echo ""

# Get user information
print_status "Please provide your information for Git commits:"
echo ""

read -p "Enter your full name: " USER_FULL_NAME
if [[ -z "$USER_FULL_NAME" ]]; then
    print_error "Name is required"
    exit 1
fi

read -p "Enter your work email: " WORK_EMAIL
if [[ -z "$WORK_EMAIL" ]]; then
    print_error "Work email is required"
    exit 1
fi

read -p "Enter your personal email: " PERSONAL_EMAIL
if [[ -z "$PERSONAL_EMAIL" ]]; then
    print_error "Personal email is required"
    exit 1
fi

echo ""
print_status "Which email should be your global Git default?"
echo "  1) Work email ($WORK_EMAIL)"
echo "  2) Personal email ($PERSONAL_EMAIL)"
read -p "Choice (1 or 2): " email_choice

if [[ "$email_choice" == "1" ]]; then
    DEFAULT_EMAIL="$WORK_EMAIL"
else
    DEFAULT_EMAIL="$PERSONAL_EMAIL"
fi

# Configure Git globally
print_status "Configuring Git..."
git config --global user.name "$USER_FULL_NAME"
git config --global user.email "$DEFAULT_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor "vim"

print_success "Git configured with:"
echo "  Name: $USER_FULL_NAME"
echo "  Email: $DEFAULT_EMAIL"
echo ""

# ============================================================================
# SSH Key Generation
# ============================================================================

print_header "🔑 SSH Key Setup"
echo ""

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Work SSH key
print_status "Setting up work SSH key..."
WORK_KEY="$HOME/.ssh/id_ed25519_work"

if [[ -f "$WORK_KEY" ]]; then
    print_success "Work SSH key already exists: $WORK_KEY"
else
    print_status "Generating work SSH key..."
    ssh-keygen -t ed25519 -C "$WORK_EMAIL" -f "$WORK_KEY" -N ""
    print_success "Work SSH key generated: $WORK_KEY"
fi

# Personal SSH key
print_status "Setting up personal SSH key..."
PERSONAL_KEY="$HOME/.ssh/id_ed25519_personal"

if [[ -f "$PERSONAL_KEY" ]]; then
    print_success "Personal SSH key already exists: $PERSONAL_KEY"
else
    print_status "Generating personal SSH key..."
    ssh-keygen -t ed25519 -C "$PERSONAL_EMAIL" -f "$PERSONAL_KEY" -N ""
    print_success "Personal SSH key generated: $PERSONAL_KEY"
fi

# Set proper permissions
chmod 600 ~/.ssh/id_ed25519_work* 2>/dev/null || true
chmod 600 ~/.ssh/id_ed25519_personal* 2>/dev/null || true

echo ""
print_success "SSH keys created"
echo ""

# ============================================================================
# SSH Config
# ============================================================================

print_status "Configuring SSH..."

# Backup existing SSH config
if [[ -f ~/.ssh/config ]]; then
    cp ~/.ssh/config ~/.ssh/config.backup.$(date +%Y%m%d_%H%M%S)
    print_status "Backed up existing SSH config"
fi

# Create/update SSH config
cat > ~/.ssh/config << EOF
# =============================================================================
# SSH Configuration
# =============================================================================

# Work GitHub (use work SSH key)
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

# Personal GitHub (use personal SSH key)
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# Default GitHub (use default key based on your choice)
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_$([ "$email_choice" == "1" ] && echo "work" || echo "personal")
    IdentitiesOnly yes

# GitHub Enterprise (if you have one)
# Host github.company.com
#     HostName github.company.com
#     User git
#     IdentityFile ~/.ssh/id_ed25519_work
#     IdentitiesOnly yes

# SSH Agent forwarding
Host *
    AddKeysToAgent yes
    UseKeychain yes
EOF

chmod 600 ~/.ssh/config
print_success "SSH config created"
echo ""

# ============================================================================
# Display SSH Public Keys
# ============================================================================

print_header "📋 SSH Public Keys"
echo ""
print_status "Add these public keys to your GitHub accounts:"
echo ""

echo "=================================================="
echo "WORK SSH KEY (add to work GitHub):"
echo "=================================================="
cat "$WORK_KEY.pub"
echo ""

echo "=================================================="
echo "PERSONAL SSH KEY (add to personal GitHub):"
echo "=================================================="
cat "$PERSONAL_KEY.pub"
echo ""

print_warning "Copy the keys above and add them to GitHub:"
echo "  Work: https://github.com/settings/keys (or your work GitHub)"
echo "  Personal: https://github.com/settings/keys"
echo ""

read -p "Press Enter when you've added the keys to GitHub..."
echo ""

# Test SSH connection
print_status "Testing SSH connection to GitHub..."
echo ""

print_status "Testing work key..."
ssh -T git@github.com-work 2>&1 | grep -q "successfully authenticated" && \
    print_success "Work SSH key working!" || \
    print_warning "Work SSH key not verified (you may need to add it to GitHub)"

print_status "Testing personal key..."
ssh -T git@github.com-personal 2>&1 | grep -q "successfully authenticated" && \
    print_success "Personal SSH key working!" || \
    print_warning "Personal SSH key not verified (you may need to add it to GitHub)"

echo ""

# ============================================================================
# GitHub CLI
# ============================================================================

print_header "🐙 GitHub CLI Setup"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &>/dev/null; then
    print_warning "GitHub CLI (gh) not installed"
    read -p "Install GitHub CLI? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installing GitHub CLI..."
        brew install gh
        print_success "GitHub CLI installed"
    else
        print_warning "Skipping GitHub CLI installation"
        print_status "You can install later with: brew install gh"
    fi
else
    print_success "GitHub CLI already installed"
fi

# Authenticate with GitHub CLI
if command -v gh &>/dev/null; then
    echo ""
    print_status "GitHub CLI authentication"
    echo ""
    print_status "You can authenticate with both work and personal accounts"
    echo ""

    read -p "Authenticate with GitHub CLI now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Starting GitHub CLI authentication..."
        print_status "Follow the prompts to authenticate"
        echo ""
        gh auth login

        echo ""
        print_success "GitHub CLI authenticated"
        print_status "Check status with: gh auth status"
    else
        print_status "Authenticate later with: gh auth login"
    fi
fi

echo ""

# ============================================================================
# Summary
# ============================================================================

print_header "✅ Setup Complete!"
print_header "=================="
echo ""

print_success "Git configured with:"
echo "  Name: $USER_FULL_NAME"
echo "  Default email: $DEFAULT_EMAIL"
echo "  Work email: $WORK_EMAIL"
echo "  Personal email: $PERSONAL_EMAIL"
echo ""

print_success "SSH keys created:"
echo "  Work: ~/.ssh/id_ed25519_work"
echo "  Personal: ~/.ssh/id_ed25519_personal"
echo ""

print_success "SSH config created at ~/.ssh/config"
echo ""

print_status "Usage examples:"
echo ""
echo "  # Clone with work key:"
echo "  git clone git@github.com-work:company/repo.git"
echo ""
echo "  # Clone with personal key:"
echo "  git clone git@github.com-personal:username/repo.git"
echo ""
echo "  # Override email for a specific repo:"
echo "  cd repo"
echo "  git config user.email \"$WORK_EMAIL\"  # for work repo"
echo "  git config user.email \"$PERSONAL_EMAIL\"  # for personal repo"
echo ""

if command -v gh &>/dev/null; then
    print_status "GitHub CLI commands:"
    echo "  gh auth status           # Check authentication"
    echo "  gh auth login            # Add another account"
    echo "  gh repo list             # List your repositories"
    echo "  gh pr create            # Create pull request"
    echo ""
fi

print_status "Next steps:"
echo "  1. Verify SSH keys are added to GitHub"
echo "  2. Test cloning a repository"
echo "  3. Configure context switching: run full bootstrap.sh"
echo ""

print_status "Tip: Use context switching functions (work/personal) to automatically"
echo "     switch Git config and SSH keys based on your current project!"
