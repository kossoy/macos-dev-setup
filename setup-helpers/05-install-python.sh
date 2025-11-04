#!/bin/bash
# =============================================================================
# Python Environment Installation Script
# =============================================================================
# Installs uv (fast Python package installer and version manager)
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
            echo "  --mode=MODE          Installation mode (minimal|standard|full|ai-ml)"
            echo "  --non-interactive    Non-interactive installation"
            echo "  --help              Show this help message"
            echo ""
            echo "Modes:"
            echo "  minimal    - uv only"
            echo "  standard   - uv + Python 3.11 (default)"
            echo "  full       - uv + Python 3.10, 3.11, 3.12"
            echo "  ai-ml      - full + AI/ML packages"
            exit 0
            ;;
    esac
done

print_header "🐍 Python Environment Installation"
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

# Install uv
print_status "Installing uv (fast Python package installer)..."
if command -v uv &>/dev/null; then
    print_success "uv already installed"
    uv --version
else
    print_status "Installing uv via Homebrew..."
    if brew install uv; then
        print_success "uv installed"
        uv --version
    else
        print_error "Failed to install uv"
        exit 1
    fi
fi

# Configure PATH for uv
print_status "Configuring shell environment..."
export PATH="$HOME/.local/bin:$PATH"

# Add to shell config if not already there (uv binary location)
if [[ -f "$HOME/.zshrc" ]]; then
    if ! grep -q "\.local/bin" "$HOME/.zshrc" 2>/dev/null; then
        print_status "Adding uv to PATH in ~/.zshrc..."
        cat >> "$HOME/.zshrc" << 'EOF'

# uv configuration
export PATH="$HOME/.local/bin:$PATH"
EOF
        print_success "uv added to ~/.zshrc"
    else
        print_success "uv path already configured in ~/.zshrc"
    fi
fi

# Mode-specific installation
case "$MODE" in
    minimal)
        print_success "Minimal installation complete (uv only)"
        ;;

    standard)
        print_status "Installing Python 3.11 with uv..."
        if uv python list 2>/dev/null | grep -q "3.11"; then
            print_success "Python 3.11 already installed"
        else
            if uv python install 3.11; then
                print_success "Python 3.11 installed"
            else
                print_error "Failed to install Python 3.11"
                exit 1
            fi
        fi

        print_status "Setting Python 3.11 as default..."
        uv python pin 3.11
        print_success "Python 3.11 set as default"
        ;;

    full)
        print_status "Installing multiple Python versions with uv..."

        # Install Python 3.10
        if uv python list 2>/dev/null | grep -q "3.10"; then
            print_success "Python 3.10 already installed"
        else
            print_status "Installing Python 3.10..."
            uv python install 3.10 || print_warning "Failed to install Python 3.10"
        fi

        # Install Python 3.11
        if uv python list 2>/dev/null | grep -q "3.11"; then
            print_success "Python 3.11 already installed"
        else
            print_status "Installing Python 3.11..."
            uv python install 3.11 || { print_error "Failed to install Python 3.11"; exit 1; }
        fi

        # Install Python 3.12
        if uv python list 2>/dev/null | grep -q "3.12"; then
            print_success "Python 3.12 already installed"
        else
            print_status "Installing Python 3.12..."
            uv python install 3.12 || print_warning "Failed to install Python 3.12"
        fi

        print_status "Setting Python 3.11 as default..."
        uv python pin 3.11
        print_success "Python 3.11 set as default"
        ;;

    ai-ml)
        print_status "Installing Python versions for AI/ML..."

        # Install Python 3.11 (recommended for AI/ML)
        if uv python list 2>/dev/null | grep -q "3.11"; then
            print_success "Python 3.11 already installed"
        else
            print_status "Installing Python 3.11..."
            uv python install 3.11 || { print_error "Failed to install Python 3.11"; exit 1; }
        fi

        # Install Python 3.12
        if uv python list 2>/dev/null | grep -q "3.12"; then
            print_success "Python 3.12 already installed"
        else
            print_status "Installing Python 3.12..."
            uv python install 3.12 || print_warning "Failed to install Python 3.12"
        fi

        print_status "Setting Python 3.11 as default..."
        uv python pin 3.11
        print_success "Python 3.11 set as default"

        # Create AI virtual environment
        print_status "Creating AI virtual environment with uv..."
        mkdir -p ~/.venvs

        if [[ -d ~/.venvs/ai ]]; then
            print_success "AI virtual environment already exists"
        else
            uv venv ~/.venvs/ai --python 3.11
            print_success "AI virtual environment created"
        fi

        # Install AI/ML packages using uv pip
        print_status "Installing AI/ML packages with uv (this will be fast!)..."

        # Core AI libraries
        print_status "Installing core AI libraries..."
        uv pip install --python ~/.venvs/ai/bin/python \
            openai anthropic langchain langchain-openai langchain-anthropic python-dotenv requests

        # Jupyter
        print_status "Installing Jupyter..."
        uv pip install --python ~/.venvs/ai/bin/python \
            jupyter ipython notebook jupyterlab

        # Data science packages
        print_status "Installing data science packages..."
        uv pip install --python ~/.venvs/ai/bin/python \
            numpy pandas matplotlib seaborn scikit-learn

        # Web frameworks
        print_status "Installing web frameworks..."
        uv pip install --python ~/.venvs/ai/bin/python \
            flask fastapi uvicorn

        # ML frameworks (optional, large downloads)
        if ! $NON_INTERACTIVE; then
            read -p "Install PyTorch and TensorFlow? (large download, ~2GB) (y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_status "Installing PyTorch..."
                uv pip install --python ~/.venvs/ai/bin/python \
                    torch torchvision torchaudio || print_warning "Failed to install PyTorch"

                print_status "Installing TensorFlow..."
                uv pip install --python ~/.venvs/ai/bin/python \
                    tensorflow || print_warning "Failed to install TensorFlow"
            fi
        fi

        print_success "AI/ML environment configured"
        ;;

    *)
        print_error "Unknown mode: $MODE"
        echo "Valid modes: minimal, standard, full, ai-ml"
        exit 1
        ;;
esac

# Verify installation
print_status "Verifying Python installation..."
if uv python list 2>/dev/null | head -1; then
    print_success "Python environment ready"
fi

echo ""
print_success "Python installation complete!"
echo ""
print_status "Installed:"
case "$MODE" in
    minimal)
        echo "  ✅ uv (fast Python package installer)"
        ;;
    standard)
        echo "  ✅ uv (fast Python package installer)"
        echo "  ✅ Python 3.11"
        ;;
    full)
        echo "  ✅ uv (fast Python package installer)"
        echo "  ✅ Python 3.10, 3.11, 3.12"
        ;;
    ai-ml)
        echo "  ✅ uv (fast Python package installer)"
        echo "  ✅ Python 3.11, 3.12"
        echo "  ✅ AI virtual environment (~/.venvs/ai)"
        echo "  ✅ AI/ML libraries (openai, anthropic, langchain, etc.)"
        echo "  ✅ Jupyter (jupyter, ipython, notebook, jupyterlab)"
        echo "  ✅ Data science (numpy, pandas, matplotlib, etc.)"
        echo "  ✅ Web frameworks (flask, fastapi)"
        ;;
esac

echo ""
print_status "Usage:"
case "$MODE" in
    ai-ml)
        echo "  Activate AI environment: source ~/.venvs/ai/bin/activate"
        echo "  Start Jupyter: jupyter lab"
        echo "  Deactivate: deactivate"
        echo ""
        print_status "Python version management:"
        ;;
esac
echo "  List versions: uv python list"
echo "  Install version: uv python install 3.X.X"
echo "  Pin version (for project): uv python pin 3.X.X"
echo "  Create venv: uv venv"
echo "  Install packages: uv pip install <package>"
