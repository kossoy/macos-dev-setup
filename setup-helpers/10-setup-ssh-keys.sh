#!/bin/bash
# =============================================================================
# SSH Keys Automatic Setup
# =============================================================================
# Non-interactive automatic SSH key generation
# Creates work and personal SSH keys if they don't exist
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
fi

print_status "Setting up SSH keys..."

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Get user email from git config or use default
WORK_EMAIL=$(git config --global user.email 2>/dev/null || echo "work@example.com")
PERSONAL_EMAIL="${WORK_EMAIL}"

# Check if work-personal-config exists and source it
if [[ -f "$HOME/.config/zsh/private/work-personal-config.zsh" ]]; then
    # Extract emails from config file
    WORK_EMAIL=$(grep "^export WORK_GIT_EMAIL=" "$HOME/.config/zsh/private/work-personal-config.zsh" 2>/dev/null | sed 's/.*"\(.*\)".*/\1/' || echo "$WORK_EMAIL")
    PERSONAL_EMAIL=$(grep "^export PERSONAL_GIT_EMAIL=" "$HOME/.config/zsh/private/work-personal-config.zsh" 2>/dev/null | sed 's/.*"\(.*\)".*/\1/' || echo "$WORK_EMAIL")
fi

# Work SSH key
WORK_KEY="$HOME/.ssh/id_ed25519_work"
if [[ -f "$WORK_KEY" ]]; then
    print_success "Work SSH key already exists: $WORK_KEY"
else
    print_status "Generating work SSH key..."
    ssh-keygen -t ed25519 -C "$WORK_EMAIL" -f "$WORK_KEY" -N "" -q
    chmod 600 "$WORK_KEY"
    chmod 644 "$WORK_KEY.pub"
    print_success "Work SSH key generated: $WORK_KEY"
fi

# Personal SSH key
PERSONAL_KEY="$HOME/.ssh/id_ed25519_personal"
if [[ -f "$PERSONAL_KEY" ]]; then
    print_success "Personal SSH key already exists: $PERSONAL_KEY"
else
    print_status "Generating personal SSH key..."
    ssh-keygen -t ed25519 -C "$PERSONAL_EMAIL" -f "$PERSONAL_KEY" -N "" -q
    chmod 600 "$PERSONAL_KEY"
    chmod 644 "$PERSONAL_KEY.pub"
    print_success "Personal SSH key generated: $PERSONAL_KEY"
fi

# Create/update SSH config if it doesn't exist
if [[ ! -f ~/.ssh/config ]]; then
    print_status "Creating SSH config..."
    cat > ~/.ssh/config << 'EOF'
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

# Default GitHub (use work key by default)
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

# SSH Agent forwarding
Host *
    AddKeysToAgent yes
    UseKeychain yes
EOF
    chmod 600 ~/.ssh/config
    print_success "SSH config created"
else
    print_success "SSH config already exists"
fi

print_success "SSH keys setup complete"

# Display keys if not in non-interactive mode
if [[ "$NON_INTERACTIVE" != "true" ]]; then
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
    print_status "Add these keys to GitHub:"
    echo "  Work: https://github.com/settings/keys"
    echo "  Personal: https://github.com/settings/keys"
    echo ""
fi
