#!/bin/bash
# =============================================================================
# macOS Fresh Setup - Simple Bootstrap
# =============================================================================
# Non-interactive automated setup with sensible defaults
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

print_step() {
    echo -e "${CYAN}[$1/$2]${NC} $3"
}

# Check if running on macOS
check_macos() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        print_error "This script is for macOS only"
        exit 1
    fi
}

# Main execution
main() {
    local total_steps=9

    print_header "🍎 macOS Fresh Setup - Simple Bootstrap"
    print_header "========================================"
    echo ""
    print_status "This script will set up your development environment with sensible defaults"
    print_status "No interactive prompts - everything is automated"
    echo ""

    # Check macOS
    check_macos

    # Step 1: Install Homebrew
    print_step 1 $total_steps "Installing Homebrew..."
    if command -v brew &>/dev/null; then
        print_success "Homebrew already installed"
    else
        bash "$SCRIPT_DIR/setup-helpers/01-install-homebrew.sh" --non-interactive || {
            print_error "Failed to install Homebrew"
            exit 1
        }
    fi
    echo ""

    # Step 2: Install Oh My Zsh
    print_step 2 $total_steps "Installing Oh My Zsh + plugins..."
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_success "Oh My Zsh already installed"
    else
        bash "$SCRIPT_DIR/setup-helpers/02-install-oh-my-zsh.sh" --non-interactive || {
            print_error "Failed to install Oh My Zsh"
            exit 1
        }
    fi
    echo ""

    # Step 3: Deploy shell configuration
    print_step 3 $total_steps "Deploying shell configuration..."
    bash "$SCRIPT_DIR/setup-helpers/03-setup-shell.sh" --non-interactive || {
        print_error "Failed to deploy shell configuration"
        exit 1
    }
    echo ""

    # Step 4: Create work directory structure
    print_step 4 $total_steps "Creating work directory structure..."
    mkdir -p ~/work/{databases,tools,projects/{work,personal},configs/{work,personal},scripts,docs,bin}
    print_success "Work directory structure created"
    echo ""

    # Step 5: Install utility scripts
    print_step 5 $total_steps "Installing utility scripts..."
    if [[ -d "$SCRIPT_DIR/scripts" ]]; then
        cp "$SCRIPT_DIR/scripts/"*.sh ~/work/scripts/ 2>/dev/null || true
        cp "$SCRIPT_DIR/scripts/"*.zsh ~/work/scripts/ 2>/dev/null || true
        chmod +x ~/work/scripts/*.sh ~/work/scripts/*.zsh 2>/dev/null || true
        print_success "Utility scripts installed"
    else
        print_warning "Scripts directory not found, skipping"
    fi
    echo ""

    # Step 6: Set up SSH keys
    print_step 6 $total_steps "Setting up SSH keys..."
    if [[ ! -f "$HOME/.ssh/id_ed25519_work" ]] || [[ ! -f "$HOME/.ssh/id_ed25519_personal" ]]; then
        bash "$SCRIPT_DIR/setup-helpers/10-setup-ssh-keys.sh" --non-interactive || {
            print_warning "SSH key setup encountered issues (continuing anyway)"
        }
    else
        print_success "SSH keys already exist"
    fi
    echo ""

    # Step 7: Set up basic context (default)
    print_step 7 $total_steps "Setting up default context..."
    mkdir -p ~/.config/zsh/contexts ~/.config/zsh/private

    # Create default context file
    if [[ ! -f "$HOME/.config/zsh/contexts/current.zsh" ]]; then
        cat > "$HOME/.config/zsh/contexts/current.zsh" << 'EOF'
# Default context (update via 'work' or 'personal' commands)
export WORK_CONTEXT="default"
export PROJECT_ROOT="$HOME/work/projects"
EOF
        print_success "Default context created"
    else
        print_success "Context already configured"
    fi
    echo ""

    # Step 8: Install utility tools (DuTop)
    print_step 8 $total_steps "Installing utility tools..."
    bash "$SCRIPT_DIR/setup-helpers/11-install-utilities.sh" --non-interactive || {
        print_warning "Utility tools installation encountered issues (continuing anyway)"
    }
    echo ""

    # Step 9: Final setup
    print_step 9 $total_steps "Finalizing setup..."

    # Ensure ~/.zshrc exists and sources our config
    if [[ ! -f "$HOME/.zshrc" ]] || ! grep -q "\.config/zsh" "$HOME/.zshrc"; then
        print_status "Updating ~/.zshrc to source configuration..."
        bash "$SCRIPT_DIR/setup-helpers/03-setup-shell.sh" --non-interactive &>/dev/null || true
    fi

    print_success "Setup finalized"
    echo ""

    # Display completion message
    print_header "========================================"
    print_header "✅ Simple Bootstrap Complete!"
    print_header "========================================"
    echo ""

    print_success "Your development environment is ready with:"
    echo "  ✅ Homebrew + essential packages"
    echo "  ✅ Oh My Zsh + plugins + Powerlevel10k"
    echo "  ✅ Shell configuration (aliases, functions, paths)"
    echo "  ✅ Work directory structure"
    echo "  ✅ Utility scripts"
    echo "  ✅ Utility tools (DuTop disk analyzer)"
    echo ""

    print_status "To start using your new environment:"
    echo "  source ~/.zshrc"
    echo "  # or restart your terminal"
    echo ""

    print_status "For advanced configuration (Git, SSH, context switching):"
    echo "  cd ~/macos-dev-setup"
    echo "  ./bootstrap.sh"
    echo ""

    print_status "Optional development environments:"
    echo "  Python:     ./setup-helpers/05-install-python.sh"
    echo "  Node.js:    ./setup-helpers/06-install-nodejs.sh"
    echo "  Docker:     ./setup-helpers/04-install-docker.sh"
    echo "  Databases:  ./setup-helpers/07-setup-databases.sh"
    echo "  AI/ML:      ./setup-helpers/09-install-ai-ml-tools.sh"
    echo "  Utilities:  ./setup-helpers/11-install-utilities.sh (includes DuTop)"
    echo ""

    print_status "Optional NAS auto-mount setup:"
    echo "  1. Store credentials: ~/work/scripts/setup-nas-keychain.sh"
    echo "  2. Test mounting:     nas-mount"
    echo "  3. Enable auto-mount: nas-enable"
    echo "  4. Documentation:     guides/nas-auto-mount-setup.md"
    echo ""

    print_status "Next steps:"
    echo "  1. Configure API keys: ~/.config/zsh/private/api-keys.zsh"
    echo "  2. Run full bootstrap for Git/SSH/context setup"
    echo "  3. Install optional environments as needed"
    echo ""
}

# Run main function
main "$@"
