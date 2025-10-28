#!/bin/bash
# =============================================================================
# Python Environment Installation Script
# =============================================================================
# Installs pyenv and Python with multiple installation modes
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
            echo "  minimal    - pyenv only"
            echo "  standard   - pyenv + Python 3.11 (default)"
            echo "  full       - pyenv + Python 3.10, 3.11, 3.12"
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

# Install pyenv
print_status "Installing pyenv..."
if command -v pyenv &>/dev/null; then
    print_success "pyenv already installed"
    pyenv --version
else
    print_status "Installing pyenv via Homebrew..."
    if brew install pyenv; then
        print_success "pyenv installed"
    else
        print_error "Failed to install pyenv"
        exit 1
    fi
fi

# Configure shell for pyenv
print_status "Configuring shell environment..."
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Add to shell config if not already there
if [[ -f "$HOME/.zshrc" ]]; then
    if ! grep -q "PYENV_ROOT" "$HOME/.zshrc"; then
        print_status "Adding pyenv to ~/.zshrc..."
        cat >> "$HOME/.zshrc" << 'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
        print_success "pyenv added to ~/.zshrc"
    else
        print_success "pyenv already configured in ~/.zshrc"
    fi
fi

# Mode-specific installation
case "$MODE" in
    minimal)
        print_success "Minimal installation complete (pyenv only)"
        ;;

    standard)
        print_status "Installing Python 3.11..."
        if pyenv versions | grep -q "3.11"; then
            print_success "Python 3.11 already installed"
        else
            if pyenv install 3.11; then
                print_success "Python 3.11 installed"
            else
                print_error "Failed to install Python 3.11"
                exit 1
            fi
        fi

        print_status "Setting Python 3.11 as global default..."
        pyenv global 3.11
        print_success "Python 3.11 set as global"

        # Upgrade pip
        print_status "Upgrading pip..."
        python -m pip install --upgrade pip setuptools wheel
        print_success "pip upgraded"
        ;;

    full)
        print_status "Installing multiple Python versions..."

        # Install Python 3.10
        if pyenv versions | grep -q "3.10"; then
            print_success "Python 3.10 already installed"
        else
            print_status "Installing Python 3.10..."
            pyenv install 3.10 || print_warning "Failed to install Python 3.10"
        fi

        # Install Python 3.11
        if pyenv versions | grep -q "3.11"; then
            print_success "Python 3.11 already installed"
        else
            print_status "Installing Python 3.11..."
            pyenv install 3.11 || print_error "Failed to install Python 3.11" && exit 1
        fi

        # Install Python 3.12
        if pyenv versions | grep -q "3.12"; then
            print_success "Python 3.12 already installed"
        else
            print_status "Installing Python 3.12..."
            pyenv install 3.12 || print_warning "Failed to install Python 3.12"
        fi

        print_status "Setting Python 3.11 as global default..."
        pyenv global 3.11
        print_success "Python 3.11 set as global"

        # Upgrade pip
        print_status "Upgrading pip..."
        python -m pip install --upgrade pip setuptools wheel
        print_success "pip upgraded"
        ;;

    ai-ml)
        print_status "Installing Python versions for AI/ML..."

        # Install Python 3.11 (recommended for AI/ML)
        if pyenv versions | grep -q "3.11"; then
            print_success "Python 3.11 already installed"
        else
            print_status "Installing Python 3.11..."
            pyenv install 3.11 || { print_error "Failed to install Python 3.11"; exit 1; }
        fi

        # Install Python 3.12
        if pyenv versions | grep -q "3.12"; then
            print_success "Python 3.12 already installed"
        else
            print_status "Installing Python 3.12..."
            pyenv install 3.12 || print_warning "Failed to install Python 3.12"
        fi

        print_status "Setting Python 3.11 as global default..."
        pyenv global 3.11
        print_success "Python 3.11 set as global"

        # Create AI virtual environment
        print_status "Creating AI virtual environment..."
        mkdir -p ~/.venvs

        if [[ -d ~/.venvs/ai ]]; then
            print_success "AI virtual environment already exists"
        else
            python -m venv ~/.venvs/ai
            print_success "AI virtual environment created"
        fi

        # Activate and install AI/ML packages
        print_status "Installing AI/ML packages (this may take several minutes)..."
        source ~/.venvs/ai/bin/activate

        # Upgrade pip
        python -m pip install --upgrade pip setuptools wheel

        # Core AI libraries
        print_status "Installing core AI libraries..."
        pip install openai anthropic langchain langchain-openai langchain-anthropic python-dotenv requests

        # Jupyter
        print_status "Installing Jupyter..."
        pip install jupyter ipython notebook jupyterlab

        # Data science packages
        print_status "Installing data science packages..."
        pip install numpy pandas matplotlib seaborn scikit-learn

        # Web frameworks
        print_status "Installing web frameworks..."
        pip install flask fastapi uvicorn

        # ML frameworks (optional, large downloads)
        if ! $NON_INTERACTIVE; then
            read -p "Install PyTorch and TensorFlow? (large download, ~2GB) (y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_status "Installing PyTorch..."
                pip install torch torchvision torchaudio || print_warning "Failed to install PyTorch"

                print_status "Installing TensorFlow..."
                pip install tensorflow || print_warning "Failed to install TensorFlow"
            fi
        fi

        deactivate
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
python --version
pip --version
print_success "Python environment ready"

echo ""
print_success "Python installation complete!"
echo ""
print_status "Installed:"
case "$MODE" in
    minimal)
        echo "  ✅ pyenv"
        ;;
    standard)
        echo "  ✅ pyenv"
        echo "  ✅ Python 3.11"
        echo "  ✅ pip, setuptools, wheel"
        ;;
    full)
        echo "  ✅ pyenv"
        echo "  ✅ Python 3.10, 3.11, 3.12"
        echo "  ✅ pip, setuptools, wheel"
        ;;
    ai-ml)
        echo "  ✅ pyenv"
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
echo "  List versions: pyenv versions"
echo "  Install version: pyenv install 3.X.X"
echo "  Switch version: pyenv global 3.X.X"
echo "  Local version: pyenv local 3.X.X"
