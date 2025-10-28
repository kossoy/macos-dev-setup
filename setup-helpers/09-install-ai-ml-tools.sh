#!/bin/bash
# =============================================================================
# AI/ML Tools Installation Script
# =============================================================================
# Installs Ollama, MLflow, and Jupyter extensions for AI/ML development
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

# Check for non-interactive flag
NON_INTERACTIVE=false
if [[ "$1" == "--non-interactive" ]]; then
    NON_INTERACTIVE=true
fi

print_header "🤖 AI/ML Tools Installation"
print_header "============================"
echo ""

# Check if Homebrew is available
if ! command -v brew &>/dev/null; then
    print_error "Homebrew is not installed"
    print_status "Install with: ./setup-helpers/01-install-homebrew.sh"
    exit 1
fi

# Check if Python is available
if ! command -v python &>/dev/null && ! command -v python3 &>/dev/null; then
    print_error "Python is not installed"
    print_status "Install with: ./setup-helpers/05-install-python.sh"
    exit 1
fi

# ============================================================================
# Ollama Installation
# ============================================================================

print_header "🦙 Installing Ollama (Local LLM Runtime)"
echo ""

if command -v ollama &>/dev/null; then
    print_success "Ollama already installed"
    ollama --version
else
    print_status "Installing Ollama via Homebrew..."
    if brew install ollama; then
        print_success "Ollama installed"
    else
        print_error "Failed to install Ollama"
        exit 1
    fi
fi

# Start Ollama service
print_status "Starting Ollama service..."
if brew services list | grep ollama | grep -q started; then
    print_success "Ollama service is already running"
else
    brew services start ollama
    print_success "Ollama service started"
    sleep 2
fi

echo ""

# Pull common models
if ! $NON_INTERACTIVE; then
    print_status "Ollama can run large language models locally"
    print_warning "Model downloads can be 4-7GB each"
    echo ""
    read -p "Download common models? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_header "📥 Downloading Models"
        echo ""

        # Llama 2 (7B)
        print_status "Downloading Llama 2 (7B) - ~4GB..."
        if ollama list | grep -q "llama2"; then
            print_success "llama2 already downloaded"
        else
            ollama pull llama2 || print_warning "Failed to download llama2"
        fi

        # CodeLlama
        print_status "Downloading CodeLlama - ~4GB..."
        if ollama list | grep -q "codellama"; then
            print_success "codellama already downloaded"
        else
            ollama pull codellama || print_warning "Failed to download codellama"
        fi

        # Mistral
        print_status "Downloading Mistral (7B) - ~4GB..."
        if ollama list | grep -q "mistral"; then
            print_success "mistral already downloaded"
        else
            ollama pull mistral || print_warning "Failed to download mistral"
        fi

        echo ""
        print_success "Models downloaded"
    else
        print_status "Skipped model downloads"
        print_status "Download models later with: ollama pull <model-name>"
    fi
else
    print_status "Non-interactive mode: skipping model downloads"
    print_status "Download models with: ollama pull llama2"
fi

echo ""

# ============================================================================
# MLflow Installation
# ============================================================================

print_header "📊 Installing MLflow"
echo ""

if python -m pip show mlflow &>/dev/null; then
    print_success "MLflow already installed"
else
    print_status "Installing MLflow..."
    python -m pip install mlflow || {
        print_error "Failed to install MLflow"
        print_status "Make sure Python is properly installed"
    }
    print_success "MLflow installed"
fi

# Create MLflow tracking directory
MLFLOW_DIR="$HOME/work/mlflow"
mkdir -p "$MLFLOW_DIR"
print_status "MLflow tracking directory: $MLFLOW_DIR"

echo ""

# ============================================================================
# Jupyter Extensions
# ============================================================================

print_header "📓 Installing Jupyter Extensions"
echo ""

# Check if Jupyter is installed
if ! python -m pip show jupyter &>/dev/null; then
    print_warning "Jupyter is not installed"
    print_status "Installing Jupyter..."
    python -m pip install jupyter jupyterlab notebook || {
        print_warning "Failed to install Jupyter"
    }
fi

if python -m pip show jupyter &>/dev/null; then
    print_status "Installing Jupyter extensions..."

    # Jupyter Vim
    print_status "Installing jupyterlab-vim..."
    python -m pip install jupyterlab-vim || print_warning "Failed to install jupyterlab-vim"

    # Jupyter Git
    print_status "Installing jupyterlab-git..."
    python -m pip install jupyterlab-git || print_warning "Failed to install jupyterlab-git"

    # Widgets
    print_status "Installing ipywidgets..."
    python -m pip install ipywidgets || print_warning "Failed to install ipywidgets"

    # Variable inspector
    print_status "Installing lckr-jupyterlab-variableinspector..."
    python -m pip install lckr-jupyterlab-variableinspector || print_warning "Failed to install variable inspector"

    print_success "Jupyter extensions installed"
else
    print_warning "Skipped Jupyter extensions (Jupyter not available)"
fi

echo ""

# ============================================================================
# TensorBoard
# ============================================================================

print_header "📈 Installing TensorBoard"
echo ""

if python -m pip show tensorboard &>/dev/null; then
    print_success "TensorBoard already installed"
else
    print_status "Installing TensorBoard..."
    python -m pip install tensorboard || print_warning "Failed to install TensorBoard"
    print_success "TensorBoard installed"
fi

echo ""

# ============================================================================
# Configuration
# ============================================================================

print_header "⚙️  Configuration"
echo ""

# Add shell aliases if .zshrc exists
if [[ -f ~/.zshrc ]]; then
    if ! grep -q "# AI/ML aliases" ~/.zshrc; then
        print_status "Adding AI/ML aliases to ~/.zshrc..."
        cat >> ~/.zshrc << 'EOF'

# AI/ML aliases
alias ollama-start='brew services start ollama'
alias ollama-stop='brew services stop ollama'
alias ollama-status='brew services info ollama'
alias mlflow-ui='mlflow ui --backend-store-uri file:///$HOME/work/mlflow'
alias tensorboard='tensorboard --logdir'
alias jl='jupyter lab'
alias jn='jupyter notebook'
EOF
        print_success "Aliases added to ~/.zshrc"
    else
        print_success "AI/ML aliases already configured"
    fi
fi

echo ""

# ============================================================================
# Verification
# ============================================================================

print_header "🧪 Verification"
echo ""

print_status "Checking installations..."

# Ollama
if command -v ollama &>/dev/null; then
    print_success "✓ Ollama: $(ollama --version 2>&1 | head -1)"
else
    print_warning "✗ Ollama not found"
fi

# MLflow
if python -m pip show mlflow &>/dev/null; then
    MLFLOW_VERSION=$(python -m pip show mlflow | grep Version | awk '{print $2}')
    print_success "✓ MLflow: $MLFLOW_VERSION"
else
    print_warning "✗ MLflow not found"
fi

# Jupyter
if python -m pip show jupyter &>/dev/null; then
    print_success "✓ Jupyter installed"
else
    print_warning "✗ Jupyter not found"
fi

# TensorBoard
if python -m pip show tensorboard &>/dev/null; then
    TENSORBOARD_VERSION=$(python -m pip show tensorboard | grep Version | awk '{print $2}')
    print_success "✓ TensorBoard: $TENSORBOARD_VERSION"
else
    print_warning "✗ TensorBoard not found"
fi

echo ""

# ============================================================================
# Summary
# ============================================================================

print_header "✅ AI/ML Tools Installation Complete!"
print_header "======================================"
echo ""

print_success "Installed components:"
echo "  ✅ Ollama (local LLM runtime)"
echo "  ✅ MLflow (ML lifecycle management)"
echo "  ✅ TensorBoard (visualization)"
echo "  ✅ Jupyter Lab/Notebook"
echo "  ✅ Jupyter extensions (vim, git, widgets)"
echo ""

print_status "Quick Start:"
echo ""
echo "  # Run local LLM"
echo "  ollama run llama2"
echo "  ollama run codellama"
echo ""
echo "  # Start Jupyter Lab"
echo "  jl"
echo "  # or: jupyter lab"
echo ""
echo "  # Start MLflow UI"
echo "  mlflow-ui"
echo "  # or: mlflow ui --backend-store-uri file://\$HOME/work/mlflow"
echo ""
echo "  # Start TensorBoard"
echo "  tensorboard --logdir ./logs"
echo ""

print_status "Ollama commands:"
echo "  ollama list              # List downloaded models"
echo "  ollama pull <model>      # Download a model"
echo "  ollama run <model>       # Run a model interactively"
echo "  ollama serve             # Start Ollama server"
echo ""

print_status "Available models to download:"
echo "  llama2          # Meta's Llama 2 (7B)"
echo "  codellama       # Code-specialized Llama"
echo "  mistral         # Mistral 7B"
echo "  mixtral         # Mistral's MoE model"
echo "  phi             # Microsoft's small model"
echo "  gemma           # Google's open model"
echo ""

print_status "MLflow tracking:"
echo "  Experiments saved to: $MLFLOW_DIR"
echo "  View in browser: mlflow-ui"
echo ""

print_status "Jupyter extensions:"
echo "  - Vim bindings (use vim commands in cells)"
echo "  - Git integration (commit from Jupyter)"
echo "  - Interactive widgets"
echo "  - Variable inspector"
echo ""

print_status "Next steps:"
echo "  1. Try running: ollama run llama2"
echo "  2. Start Jupyter: jl"
echo "  3. Create ML experiments with MLflow"
echo "  4. Visualize with TensorBoard"
echo ""

print_status "Reload shell to use new aliases: source ~/.zshrc"
