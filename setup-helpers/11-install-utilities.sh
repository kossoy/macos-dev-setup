#!/bin/bash
# =============================================================================
# Install Utility Tools
# =============================================================================
# Installs additional utility tools:
# - DuTop: High-performance disk usage analysis tool (Rust)
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if running in non-interactive mode
NON_INTERACTIVE=false
if [[ "$1" == "--non-interactive" ]]; then
    NON_INTERACTIVE=true
fi

# =============================================================================
# DuTop Installation
# =============================================================================

install_dutop() {
    print_status "Installing DuTop (high-performance disk usage analyzer)..."

    # Check if already installed
    if command -v dutop >/dev/null 2>&1; then
        print_success "DuTop is already installed: $(dutop --version 2>&1 || echo 'version unknown')"
        return 0
    fi

    # Try cargo install first (if cargo is available)
    if command -v cargo >/dev/null 2>&1; then
        print_status "Installing DuTop via cargo..."
        if cargo install dutop; then
            print_success "DuTop installed successfully via cargo"
            return 0
        else
            print_warning "Cargo install failed, trying binary download..."
        fi
    fi

    # Download pre-built binary for macOS
    print_status "Downloading pre-built DuTop binary for macOS..."

    local version="v0.1.0"
    local download_dir=$(mktemp -d)
    local binary_url="https://github.com/UnTypeBeats/DuTop/releases/download/${version}/dutop-universal"
    local dest_path="$HOME/work/bin/dutop"

    # Create bin directory if it doesn't exist
    mkdir -p "$HOME/work/bin"

    # Download binary
    if command -v curl >/dev/null 2>&1; then
        if curl -L -o "${download_dir}/dutop" "$binary_url"; then
            print_status "Download successful"
        else
            print_error "Failed to download DuTop binary"
            rm -rf "$download_dir"
            return 1
        fi
    else
        print_error "curl not found - cannot download DuTop binary"
        rm -rf "$download_dir"
        return 1
    fi

    # Remove quarantine attribute (macOS Gatekeeper)
    if [[ "$(uname)" == "Darwin" ]]; then
        print_status "Removing macOS quarantine attribute..."
        xattr -d com.apple.quarantine "${download_dir}/dutop" 2>/dev/null || true
    fi

    # Make executable
    chmod +x "${download_dir}/dutop"

    # Move to bin directory
    mv "${download_dir}/dutop" "$dest_path"

    # Cleanup
    rm -rf "$download_dir"

    # Verify installation
    if [[ -x "$dest_path" ]]; then
        print_success "DuTop installed successfully to $dest_path"

        # Check if ~/work/bin is in PATH
        if [[ ":$PATH:" != *":$HOME/work/bin:"* ]]; then
            print_warning "~/work/bin is not in your PATH"
            print_warning "Add this to your ~/.zshrc: export PATH=\"\$HOME/work/bin:\$PATH\""
            print_warning "Or reload your shell after bootstrap completes"
        fi

        # Test the binary
        if "$dest_path" --version >/dev/null 2>&1; then
            print_success "DuTop is working correctly"
        else
            print_warning "DuTop binary installed but --version check failed"
        fi
    else
        print_error "Failed to install DuTop binary"
        return 1
    fi
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    echo ""
    echo "=============================================="
    echo "Installing Utility Tools"
    echo "=============================================="
    echo ""

    # Install DuTop
    install_dutop

    echo ""
    print_success "Utility tools installation complete!"
    echo ""

    if ! $NON_INTERACTIVE; then
        echo "You can now use:"
        echo "  dutop          - Analyze disk usage (faster than wdu)"
        echo "  dutop --help   - Show DuTop options"
        echo ""
    fi
}

# Run main function
main
