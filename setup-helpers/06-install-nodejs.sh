#!/bin/bash
# =============================================================================
# Node.js Environment Installation Script
# =============================================================================
# Installs Volta and Node.js with multiple installation modes
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

# Default mode
MODE="standard"
NON_INTERACTIVE=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --mode=*)
            MODE="${arg#*=}"
            ;;
        --non-interactive)
            NON_INTERACTIVE=true
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --mode=MODE          Installation mode (minimal|standard|full)"
            echo "  --non-interactive    Non-interactive installation"
            echo "  --help              Show this help message"
            echo ""
            echo "Modes:"
            echo "  minimal    - Volta only"
            echo "  standard   - Volta + Node.js LTS (default)"
            echo "  full       - Standard + global packages (yarn, pnpm, typescript, etc.)"
            exit 0
            ;;
    esac
done

print_header "📦 Node.js Environment Installation"
print_header "===================================="
echo ""
print_status "Installation mode: $MODE"
echo ""

# Check if Homebrew is available
if ! command -v brew &>/dev/null; then
    print_error "Homebrew is not installed. Please install Homebrew first:"
    echo "  ./setup-helpers/01-install-homebrew.sh"
    exit 1
fi

# Install Volta
print_status "Installing Volta (Node.js version manager)..."
if command -v volta &>/dev/null; then
    print_success "Volta already installed"
    volta --version
else
    print_status "Installing Volta via Homebrew..."
    if brew install volta; then
        print_success "Volta installed"
    else
        print_error "Failed to install Volta"
        exit 1
    fi
fi

# Configure shell for Volta
print_status "Configuring shell environment..."
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Add to shell config if not already there
if [[ -f "$HOME/.zshrc" ]]; then
    if ! grep -q "VOLTA_HOME" "$HOME/.zshrc"; then
        print_status "Adding Volta to ~/.zshrc..."
        cat >> "$HOME/.zshrc" << 'EOF'

# Volta configuration
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
EOF
        print_success "Volta added to ~/.zshrc"
    else
        print_success "Volta already configured in ~/.zshrc"
    fi
fi

# Mode-specific installation
case "$MODE" in
    minimal)
        print_success "Minimal installation complete (Volta only)"
        ;;

    standard)
        print_status "Installing Node.js LTS..."
        if volta list node | grep -q "node"; then
            print_success "Node.js already installed"
        else
            if volta install node; then
                print_success "Node.js LTS installed"
            else
                print_error "Failed to install Node.js"
                exit 1
            fi
        fi

        # Verify installation
        print_status "Verifying Node.js installation..."
        node --version
        npm --version
        print_success "Node.js ready"
        ;;

    full)
        print_status "Installing Node.js LTS..."
        if volta list node | grep -q "node"; then
            print_success "Node.js already installed"
        else
            if volta install node; then
                print_success "Node.js LTS installed"
            else
                print_error "Failed to install Node.js"
                exit 1
            fi
        fi

        # Install Yarn
        print_status "Installing Yarn..."
        if command -v yarn &>/dev/null; then
            print_success "Yarn already installed"
        else
            volta install yarn || print_warning "Failed to install Yarn"
        fi

        # Install pnpm
        print_status "Installing pnpm..."
        if command -v pnpm &>/dev/null; then
            print_success "pnpm already installed"
        else
            volta install pnpm || print_warning "Failed to install pnpm"
        fi

        # Install global packages
        print_status "Installing global packages..."

        # TypeScript
        print_status "Installing TypeScript..."
        npm install -g typescript @types/node || print_warning "Failed to install TypeScript"

        # Linters and formatters
        print_status "Installing ESLint and Prettier..."
        npm install -g eslint prettier || print_warning "Failed to install linters"

        # Build tools
        print_status "Installing build tools..."
        npm install -g vite webpack webpack-cli || print_warning "Failed to install build tools"

        # Utilities
        print_status "Installing utilities..."
        npm install -g serve http-server nodemon || print_warning "Failed to install utilities"

        print_success "Global packages installed"
        ;;

    *)
        print_error "Unknown mode: $MODE"
        echo "Valid modes: minimal, standard, full"
        exit 1
        ;;
esac

# Verify installation
print_status "Verifying installation..."
volta --version

if [[ "$MODE" != "minimal" ]]; then
    node --version
    npm --version
fi

if [[ "$MODE" == "full" ]]; then
    command -v yarn &>/dev/null && yarn --version
    command -v pnpm &>/dev/null && pnpm --version
fi

echo ""
print_success "Node.js installation complete!"
echo ""
print_status "Installed:"
case "$MODE" in
    minimal)
        echo "  ✅ Volta"
        ;;
    standard)
        echo "  ✅ Volta"
        echo "  ✅ Node.js LTS"
        echo "  ✅ npm"
        ;;
    full)
        echo "  ✅ Volta"
        echo "  ✅ Node.js LTS"
        echo "  ✅ npm, yarn, pnpm"
        echo "  ✅ TypeScript, @types/node"
        echo "  ✅ ESLint, Prettier"
        echo "  ✅ Vite, Webpack"
        echo "  ✅ Utilities (serve, http-server, nodemon)"
        ;;
esac

echo ""
print_status "Usage:"
echo "  Install specific Node version: volta install node@18"
echo "  Pin project Node version: volta pin node@18"
echo "  List installed versions: volta list"
echo "  Install global package: npm install -g <package>"
echo ""
print_status "Package managers:"
echo "  npm  - Default Node.js package manager"
[[ "$MODE" == "full" ]] && echo "  yarn - Alternative package manager (faster)"
[[ "$MODE" == "full" ]] && echo "  pnpm - Efficient package manager (disk space saver)"
