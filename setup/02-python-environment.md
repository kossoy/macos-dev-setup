# Python Development Environment

Complete Python setup with pyenv for version management and essential packages for web development and AI/ML.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Homebrew installed
- Xcode Command Line Tools installed

## 1. Pyenv (Python Version Management)

Pyenv allows you to easily switch between multiple versions of Python.

```bash
# Install pyenv
brew install pyenv

# Add to shell configuration
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# Reload shell
source ~/.zshrc

# Install latest Python versions
pyenv install 3.11.7
pyenv install 3.12.1
pyenv global 3.12.1

# Verify installation
python --version
pip --version
```

## 2. Essential Python Packages

### Package Managers & Virtual Environments

```bash
# Upgrade pip
pip install --upgrade pip

# Install package managers
pip install pipenv poetry virtualenv
```

### Development Tools

```bash
# Code quality and testing
pip install black flake8 mypy pytest pytest-cov
```

### AI/ML Packages

```bash
# Core data science libraries
pip install numpy pandas matplotlib seaborn scikit-learn

# Deep learning frameworks
pip install tensorflow torch

# Jupyter for notebooks
pip install jupyter jupyterlab
```

### Web Development

```bash
# Web frameworks
pip install django flask fastapi

# HTTP and web scraping
pip install requests beautifulsoup4
```

### All-in-One Installation

```bash
# Install all essential packages at once
pip install \
  pipenv poetry virtualenv \
  black flake8 mypy pytest pytest-cov \
  numpy pandas matplotlib seaborn scikit-learn \
  tensorflow torch \
  jupyter jupyterlab \
  django flask fastapi \
  requests beautifulsoup4
```

## 3. Jupyter Lab/Notebook

Jupyter provides an interactive computing environment.

```bash
# Install Jupyter Lab
pip install jupyterlab

# Install Jupyter extensions
pip install jupyter-contrib-nbextensions

# Generate configuration
jupyter lab --generate-config

# Start Jupyter Lab
jupyter lab
```

## 4. Virtual Environment Best Practices

### Using venv (Built-in)

```bash
# Create virtual environment
python -m venv myproject-env

# Activate
source myproject-env/bin/activate

# Deactivate
deactivate
```

### Using pipenv

```bash
# Install dependencies from Pipfile
pipenv install

# Activate environment
pipenv shell

# Install package
pipenv install requests

# Install dev dependencies
pipenv install --dev pytest
```

### Using poetry

```bash
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

```bash
# Check Python version
python --version

# List installed packages
pip list

# Show package info
pip show <package-name>

# Update all packages
pip list --outdated
pip install --upgrade <package-name>

# Freeze dependencies
pip freeze > requirements.txt

# Install from requirements
pip install -r requirements.txt
```

## 8. Troubleshooting

### SSL Certificate Issues

```bash
# Update certificates
pip install --upgrade certifi
```

### M1 Mac Compatibility

Some packages may need special installation:

```bash
# For TensorFlow on M1
pip install tensorflow-macos tensorflow-metal

# For PyTorch on M1 (automatic detection)
pip install torch torchvision torchaudio
```

### Permission Errors

Never use `sudo pip install`. Instead:

```bash
# Use --user flag
pip install --user <package-name>

# Or use virtual environment (recommended)
python -m venv venv
source venv/bin/activate
pip install <package-name>
```

## Next Steps

Continue with:
- **[Node.js Environment](03-nodejs-environment.md)** - JavaScript development
- **[AI/ML Tools](12-ai-ml-tools.md)** - Advanced ML development setup
- **[IDEs & Editors](09-ides-editors.md)** - PyCharm configuration

---

**Estimated Time**: 20 minutes  
**Difficulty**: Beginner  
**Last Updated**: October 5, 2025
