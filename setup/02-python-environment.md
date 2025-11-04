# Python Development Environment

Complete Python setup with uv - a fast Python package installer and version manager written in Rust by Astral.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Homebrew installed
- Xcode Command Line Tools installed

## 1. uv (Fast Python Package Installer & Version Manager)

uv is an extremely fast Python package installer and resolver, serving as a drop-in replacement for pip, pip-tools, and virtualenv. It's 10-100x faster than pip and also manages Python versions.

```bash
# Install uv
brew install uv

# Verify installation
uv --version

# Install Python versions
uv python install 3.11
uv python install 3.12

# Pin Python version for your project
uv python pin 3.12

# List installed Python versions
uv python list
```

## 2. Essential Python Packages

### Using uv for Package Management

uv provides fast package installation with better dependency resolution:

```bash
# Create a new virtual environment
uv venv

# Activate the environment
source .venv/bin/activate

# Install packages (much faster than pip!)
uv pip install <package-name>
```

### Development Tools

```bash
# Code quality and testing
uv pip install black flake8 mypy pytest pytest-cov ruff
```

### AI/ML Packages

```bash
# Core data science libraries
uv pip install numpy pandas matplotlib seaborn scikit-learn

# Deep learning frameworks
uv pip install tensorflow torch

# Jupyter for notebooks
uv pip install jupyter jupyterlab
```

### Web Development

```bash
# Web frameworks
uv pip install django flask fastapi

# HTTP and web scraping
uv pip install requests beautifulsoup4
```

### All-in-One Installation

```bash
# Install all essential packages at once (blazingly fast with uv!)
uv pip install \
  black flake8 mypy pytest pytest-cov ruff \
  numpy pandas matplotlib seaborn scikit-learn \
  jupyter jupyterlab \
  django flask fastapi \
  requests beautifulsoup4
```

## 3. Jupyter Lab/Notebook

Jupyter provides an interactive computing environment.

```bash
# Install Jupyter Lab
uv pip install jupyterlab

# Install Jupyter extensions
uv pip install jupyter-contrib-nbextensions

# Generate configuration
jupyter lab --generate-config

# Start Jupyter Lab
jupyter lab
```

## 4. Virtual Environment Best Practices

### Using uv (Recommended - Fast!)

```bash
# Create virtual environment with uv (much faster than venv)
uv venv

# Activate
source .venv/bin/activate

# Install packages
uv pip install requests numpy pandas

# Install from requirements.txt
uv pip install -r requirements.txt

# Sync environment to match requirements.txt exactly
uv pip sync requirements.txt

# Compile requirements with pinned versions
uv pip compile requirements.in -o requirements.txt

# Deactivate
deactivate
```

### Using poetry (Alternative)

```bash
# Install poetry
brew install poetry

# Create new project
poetry new myproject

# Install dependencies
poetry install

# Add package
poetry add requests

# Run script in environment
poetry run python script.py
```

## 5. Python Project Template

```bash
# Create new Python project structure
mkdir -p ~/work/projects/personal/my-python-project
cd ~/work/projects/personal/my-python-project

# Create project structure
mkdir -p src tests docs

# Create requirements files
cat > requirements.txt << 'EOF'
# Production dependencies
fastapi>=0.68.0
uvicorn>=0.15.0
pydantic>=1.8.0
sqlalchemy>=2.0.0
alembic>=1.12.0
requests>=2.31.0
python-dotenv>=1.0.0
EOF

cat > requirements-dev.txt << 'EOF'
# Development dependencies
-r requirements.txt
pytest>=7.0.0
black>=22.0.0
flake8>=4.0.0
mypy>=0.950
pytest-cov>=4.0.0
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv
*.egg-info/
dist/
build/

# Testing
.pytest_cache/
.coverage
htmlcov/

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# Environment
.env
.env.local
EOF
```

## 6. Python in JetBrains PyCharm

PyCharm Professional provides the best Python IDE experience:

```bash
# Open project in PyCharm (if installed via JetBrains Toolbox)
pycharm ~/work/projects/personal/my-python-project
```

**Key PyCharm Features:**
- Intelligent code completion
- Built-in debugger
- Database tools integration
- Docker and Kubernetes support
- Jupyter notebook support
- Scientific tools (NumPy, Pandas)
- Web frameworks support (Django, Flask, FastAPI)

## 7. Common Commands

### Python Version Management with uv

```bash
# List installed Python versions
uv python list

# Install a Python version
uv python install 3.12

# Pin Python version for project
uv python pin 3.11

# Find Python installations
uv python find 3.12
```

### Package Management with uv

```bash
# List installed packages
uv pip list

# Show package info
uv pip show <package-name>

# List outdated packages
uv pip list --outdated

# Install/upgrade package
uv pip install --upgrade <package-name>

# Freeze dependencies
uv pip freeze > requirements.txt

# Install from requirements
uv pip install -r requirements.txt

# Sync to exact requirements (removes unlisted packages)
uv pip sync requirements.txt

# Compile requirements with locked versions
uv pip compile requirements.in -o requirements.txt
```

## 8. Troubleshooting

### SSL Certificate Issues

```bash
# Update certificates
uv pip install --upgrade certifi
```

### M1 Mac Compatibility

uv handles M1 compatibility automatically:

```bash
# For TensorFlow on M1 (uv handles the right version)
uv pip install tensorflow-macos tensorflow-metal

# For PyTorch on M1 (automatic detection)
uv pip install torch torchvision torchaudio
```

### Permission Errors

Always use virtual environments with uv (no permission issues):

```bash
# Create and activate virtual environment (recommended)
uv venv
source .venv/bin/activate
uv pip install <package-name>
```

### Speed and Performance

uv is 10-100x faster than pip due to:
- Written in Rust (native performance)
- Parallel downloads and installs
- Better dependency resolution algorithm
- Smart caching

## Next Steps

Continue with:
- **[Node.js Environment](03-nodejs-environment.md)** - JavaScript development
- **[AI/ML Tools](12-ai-ml-tools.md)** - Advanced ML development setup
- **[IDEs & Editors](09-ides-editors.md)** - PyCharm configuration

---

**Estimated Time**: 20 minutes  
**Difficulty**: Beginner  
**Last Updated**: October 5, 2025
