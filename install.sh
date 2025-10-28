#!/bin/bash
# =============================================================================
# macOS Fresh Setup - One-Liner Installer
# =============================================================================
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/username/macos-fresh-setup/main/install.sh)
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

# Check if running on macOS
check_macos() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        print_error "This script is for macOS only"
        print_status "Detected OS: $(uname -s)"
        exit 1
    fi
    print_success "Running on macOS"
}

# Check macOS version
check_macos_version() {
    local macos_version=$(sw_vers -productVersion)
    local macos_name=$(sw_vers -productName)

    print_status "$macos_name version: $macos_version"

    # Extract major version
    local major_version=$(echo "$macos_version" | cut -d. -f1)

    # Check if macOS 15 (Sequoia) or later, or macOS 26 (Tahoe) or later
    if [[ $major_version -ge 15 ]]; then
        print_success "macOS version is compatible"
    else
        print_warning "This script is optimized for macOS Sequoia (15.x) or later"
        print_warning "You have macOS $macos_version"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Check architecture
check_architecture() {
    local arch=$(uname -m)
    print_status "Architecture: $arch"

    if [[ "$arch" == "arm64" ]]; then
        print_success "Apple Silicon detected (M1/M2/M3/M4)"
    elif [[ "$arch" == "x86_64" ]]; then
        print_warning "Intel Mac detected - some optimizations may not apply"
    else
        print_warning "Unknown architecture: $arch"
    fi
}

# Check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Don't run this script as root/sudo"
        exit 1
    fi
}

# Install Xcode Command Line Tools if needed
install_xcode_clt() {
    print_status "Checking Xcode Command Line Tools..."

    if xcode-select -p &>/dev/null; then
        print_success "Xcode Command Line Tools already installed"
        return 0
    fi

    print_status "Installing Xcode Command Line Tools..."
    print_warning "This may take a few minutes and will prompt for administrator password"

    # Trigger installation
    xcode-select --install 2>/dev/null || true

    # Wait for installation to complete
    print_status "Waiting for installation to complete..."
    print_status "Please follow the prompts in the installation window"

    until xcode-select -p &>/dev/null; do
        sleep 5
    done

    print_success "Xcode Command Line Tools installed successfully"
}

# Install git if not available
ensure_git() {
    if command -v git &>/dev/null; then
        print_success "git is already available"
        return 0
    fi

    print_status "git not found, installing via Xcode Command Line Tools..."
    install_xcode_clt

    if command -v git &>/dev/null; then
        print_success "git is now available"
    else
        print_error "Failed to install git"
        exit 1
    fi
}

# Clone or update repository
setup_repository() {
    local repo_url="https://github.com/username/macos-fresh-setup.git"
    local install_dir="$HOME/macos-fresh-setup"

    print_status "Setting up repository at $install_dir"

    if [[ -d "$install_dir" ]]; then
        print_status "Repository already exists, updating..."
        cd "$install_dir"

        # Stash any local changes
        if [[ -n $(git status -s) ]]; then
            print_warning "Local changes detected, stashing..."
            git stash save "Auto-stash before update $(date +%Y%m%d_%H%M%S)"
        fi

        git pull origin main || {
            print_error "Failed to update repository"
            print_status "Continuing with existing version..."
        }

        print_success "Repository updated"
    else
        print_status "Cloning repository..."
        git clone "$repo_url" "$install_dir" || {
            print_error "Failed to clone repository"
            exit 1
        }

        cd "$install_dir"
        print_success "Repository cloned successfully"
    fi

    # Make scripts executable
    chmod +x bootstrap.sh simple-bootstrap.sh 2>/dev/null || true
    chmod +x setup-helpers/*.sh 2>/dev/null || true
    chmod +x scripts/*.sh scripts/*.zsh 2>/dev/null || true
}

# Run simple bootstrap
run_simple_bootstrap() {
    print_header "========================================"
    print_header "Running Simple Bootstrap"
    print_header "========================================"
    echo ""

    if [[ -f "$HOME/macos-fresh-setup/simple-bootstrap.sh" ]]; then
        bash "$HOME/macos-fresh-setup/simple-bootstrap.sh"
    else
        print_error "simple-bootstrap.sh not found"
        exit 1
    fi
}

# Offer full bootstrap
offer_full_bootstrap() {
    echo ""
    print_header "========================================"
    print_header "Simple Bootstrap Complete!"
    print_header "========================================"
    echo ""

    print_status "You now have a basic development environment with:"
    echo "  ✅ Homebrew + essential packages"
    echo "  ✅ Oh My Zsh + plugins + Powerlevel10k"
    echo "  ✅ Shell configuration + aliases + functions"
    echo "  ✅ Work directory structure"
    echo "  ✅ Utility scripts"
    echo ""

    print_status "For advanced configuration (Git, SSH, GitHub CLI, context switching),"
    print_status "you can run the full bootstrap:"
    echo ""
    echo "  cd ~/macos-fresh-setup"
    echo "  ./bootstrap.sh"
    echo ""

    print_status "Optional development environments:"
    echo "  Python:     ./setup-helpers/05-install-python.sh"
    echo "  Node.js:    ./setup-helpers/06-install-nodejs.sh"
    echo "  Docker:     ./setup-helpers/04-install-docker.sh"
    echo "  Databases:  ./setup-helpers/07-setup-databases.sh"
    echo "  AI/ML:      ./setup-helpers/09-install-ai-ml-tools.sh"
    echo ""

    read -p "Would you like to run the full bootstrap now? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Starting full bootstrap..."
        cd "$HOME/macos-fresh-setup"
        ./bootstrap.sh
    else
        print_success "Setup complete! Reload your shell to use the new configuration:"
        echo ""
        echo "  source ~/.zshrc"
        echo "  # or restart your terminal"
        echo ""
    fi
}

# Main execution
main() {
    print_header "🍎 macOS Fresh Setup - One-Liner Installer"
    print_header "=========================================="
    echo ""

    # System checks
    check_not_root
    check_macos
    check_macos_version
    check_architecture
    echo ""

    # Install prerequisites
    install_xcode_clt
    ensure_git
    echo ""

    # Setup repository
    setup_repository
    echo ""

    # Run simple bootstrap
    run_simple_bootstrap

    # Offer full bootstrap
    offer_full_bootstrap
}

# Run main function
main "$@"
