#!/bin/bash
# Python AI Development Environment Setup
# Installs pyenv, Python 3.12/3.13, and AI/ML libraries

set -e

echo "🐍 Python AI Development Environment Setup"
echo "=========================================="
echo ""

# Check if running on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📦 Installing pyenv..."
if ! command -v pyenv >/dev/null 2>&1; then
    brew install pyenv
    echo "✅ pyenv installed"
else
    echo "✅ pyenv already installed"
fi

echo "🐍 Installing Python versions..."
# Install Python 3.12 and 3.13
pyenv install 3.12.8 2>/dev/null || echo "Python 3.12.8 already installed"
pyenv install 3.13.9 2>/dev/null || echo "Python 3.13.9 already installed"

# Set Python 3.13 as global default
pyenv global 3.13.9
echo "✅ Python 3.13.9 set as global default"

# Initialize pyenv in this script
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

echo "📁 Creating virtual environment directory..."
mkdir -p ~/.venvs

echo "🤖 Creating AI virtual environment..."
# Create AI virtual environment using pyenv Python
pyenv exec python -m venv ~/.venvs/ai

echo "📦 Installing AI/ML libraries in AI environment..."
# Activate AI environment and install packages
source ~/.venvs/ai/bin/activate

# Upgrade pip first
pip install --upgrade pip

# Install core AI libraries
pip install \
    openai \
    anthropic \
    langchain \
    langchain-openai \
    langchain-anthropic \
    python-dotenv \
    requests \
    jupyter \
    ipython \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    scikit-learn \
    flask \
    fastapi \
    uvicorn

echo "✅ AI libraries installed"

echo "📋 Copying Python shell configuration..."
# Copy Python configuration
mkdir -p ~/.zsh/config
cp "$SCRIPT_DIR/config/zsh/config/python.zsh" ~/.zsh/config/python.zsh

echo "🔄 Updating tools.zsh to load Python config..."
# Update tools.zsh to load python.zsh
if ! grep -q "load_dev_tool \"python\"" ~/.zsh/config/tools.zsh; then
    echo "" >> ~/.zsh/config/tools.zsh
    echo "# Load Python configuration" >> ~/.zsh/config/tools.zsh
    echo "load_dev_tool \"python\"" >> ~/.zsh/config/tools.zsh
    echo "✅ tools.zsh updated"
else
    echo "✅ tools.zsh already configured"
fi

echo ""
echo "✅ Python AI setup complete!"
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Activate AI environment: aienv"
echo "3. Start Jupyter: jl"
echo "4. Create new Python project: mkdir my-project && cd my-project && python -m venv venv"
echo ""
echo "Available commands:"
echo "- aienv: Activate AI virtual environment"
echo "- py: python"
echo "- jl: jupyter lab"
echo "- pip-freeze: Create requirements.txt"
echo ""
echo "Your Python AI development environment is ready!"
