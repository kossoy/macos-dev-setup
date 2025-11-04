# Complete Guide to uv: Replace pip, pip-tools, virtualenv, and pyenv

A comprehensive guide to using uv - Astral's extremely fast Python package installer and resolver written in Rust.

## Table of Contents

1. [What is uv?](#what-is-uv)
2. [Installation](#installation)
3. [Python Version Management (Replacing pyenv)](#python-version-management-replacing-pyenv)
4. [Virtual Environments (Replacing virtualenv)](#virtual-environments-replacing-virtualenv)
5. [Package Management (Replacing pip)](#package-management-replacing-pip)
6. [Dependency Management (Replacing pip-tools)](#dependency-management-replacing-pip-tools)
7. [Migration Guide](#migration-guide)
8. [Common Workflows](#common-workflows)
9. [Performance Comparisons](#performance-comparisons)
10. [Troubleshooting](#troubleshooting)

## What is uv?

**uv** is an extremely fast Python package installer and resolver developed by Astral (creators of Ruff). It's designed as a drop-in replacement for pip, pip-tools, virtualenv, and pyenv.

### Key Features

- **🚀 10-100x faster** than pip (written in Rust)
- **🎯 All-in-one tool**: Replaces multiple Python tools
- **🔒 Better dependency resolution** with improved conflict detection
- **📦 Smart caching** for repeated installations
- **⚡ Parallel downloads** and installs
- **🍎 Native M1/M2/M3 support**
- **🔄 Drop-in replacement**: Minimal learning curve

### Why Switch to uv?

| Feature | Traditional Tools | uv |
|---------|------------------|-----|
| Package install | pip (slow) | uv pip (10-100x faster) |
| Python versions | pyenv (complex) | uv python (built-in) |
| Virtual envs | virtualenv/venv | uv venv (faster) |
| Lock files | pip-tools | uv pip compile (faster) |
| Installation | Multiple tools | Single binary |

## Installation

### Via Homebrew (Recommended on macOS)

```bash
brew install uv
```

### Via curl (Cross-platform)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Via pip (Ironically)

```bash
pip install uv
```

### Verify Installation

```bash
uv --version
# Output: uv 0.4.x (or newer)
```

## Python Version Management (Replacing pyenv)

uv includes built-in Python version management, eliminating the need for pyenv.

### Command Comparison

| pyenv | uv | Description |
|-------|-----|-------------|
| `pyenv versions` | `uv python list` | List installed versions |
| `pyenv install 3.11` | `uv python install 3.11` | Install Python version |
| `pyenv global 3.11` | `uv python pin 3.11` | Set default version |
| `pyenv local 3.10` | `uv python pin 3.10` | Set project version |
| `pyenv which python` | `uv python find` | Find Python executable |

### Installing Python Versions

```bash
# Install specific Python version
uv python install 3.11

# Install specific patch version
uv python install 3.11.7

# Install multiple versions
uv python install 3.10 3.11 3.12

# Install latest stable
uv python install 3.12
```

### Managing Python Versions

```bash
# List all installed Python versions
uv python list

# List available Python versions (remote)
uv python list --all-versions

# Find Python executable
uv python find 3.11

# Pin Python version for current project
uv python pin 3.11
# This creates a .python-version file

# Use specific Python version for a command
uv run --python 3.11 python script.py
```

### Setting Default Python

```bash
# Create .python-version in your project
cd ~/work/projects/personal/my-project
uv python pin 3.11

# uv will automatically use this version when in this directory
```

### Migration from pyenv

```bash
# Before (pyenv)
pyenv install 3.11.7
pyenv global 3.11.7
pyenv local 3.10.8

# After (uv)
uv python install 3.11.7
uv python pin 3.11.7  # Global default
cd project && uv python pin 3.10.8  # Project-specific
```

**Note**: uv respects `.python-version` files created by pyenv, so your existing projects will work!

## Virtual Environments (Replacing virtualenv)

uv's virtual environment creation is significantly faster than virtualenv or venv.

### Command Comparison

| Traditional | uv | Description |
|------------|-----|-------------|
| `python -m venv .venv` | `uv venv` | Create virtual environment |
| `virtualenv env` | `uv venv env` | Create named venv |
| `python -m venv --python=3.11 .venv` | `uv venv --python 3.11` | Create with specific Python |

### Creating Virtual Environments

```bash
# Create virtual environment in .venv (default)
uv venv

# Create virtual environment with specific name
uv venv my-env

# Create with specific Python version
uv venv --python 3.11

# Create with specific Python executable
uv venv --python /usr/bin/python3.10

# Create with system site packages
uv venv --system-site-packages
```

### Activating Virtual Environments

```bash
# Activation is the same as before
source .venv/bin/activate  # Unix/macOS
.venv\Scripts\activate     # Windows

# Or use uv run (no activation needed)
uv run python script.py
uv run pytest
```

### Migration from virtualenv

```bash
# Before (virtualenv)
virtualenv .venv
source .venv/bin/activate
pip install -r requirements.txt

# After (uv)
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt

# Or even simpler (no activation needed)
uv venv
uv pip install -r requirements.txt
```

## Package Management (Replacing pip)

uv provides a `pip` interface that's significantly faster than traditional pip.

### Command Comparison

| pip | uv | Description |
|-----|-----|-------------|
| `pip install package` | `uv pip install package` | Install package |
| `pip install -r requirements.txt` | `uv pip install -r requirements.txt` | Install from requirements |
| `pip list` | `uv pip list` | List installed packages |
| `pip show package` | `uv pip show package` | Show package info |
| `pip freeze` | `uv pip freeze` | Export installed packages |
| `pip uninstall package` | `uv pip uninstall package` | Uninstall package |

### Installing Packages

```bash
# Install single package
uv pip install requests

# Install multiple packages
uv pip install requests numpy pandas

# Install specific version
uv pip install "django==4.2"
uv pip install "flask>=2.0,<3.0"

# Install from requirements.txt
uv pip install -r requirements.txt

# Install in editable mode (development)
uv pip install -e .

# Install with extras
uv pip install "fastapi[all]"
```

### Managing Packages

```bash
# List installed packages
uv pip list

# List outdated packages
uv pip list --outdated

# Show package information
uv pip show requests

# Uninstall package
uv pip uninstall requests

# Uninstall multiple packages
uv pip uninstall requests numpy pandas

# Freeze installed packages
uv pip freeze > requirements.txt
```

### Upgrading Packages

```bash
# Upgrade single package
uv pip install --upgrade requests

# Upgrade multiple packages
uv pip install --upgrade requests numpy pandas

# Upgrade all packages (not recommended)
uv pip list --outdated | cut -d' ' -f1 | xargs uv pip install --upgrade
```

### Installing to Specific Environment

```bash
# Install to specific Python environment
uv pip install --python ~/.venvs/ai/bin/python requests

# Or specify Python version
uv pip install --python 3.11 requests
```

## Dependency Management (Replacing pip-tools)

uv includes powerful dependency compilation and locking features that replace pip-tools.

### Command Comparison

| pip-tools | uv | Description |
|-----------|-----|-------------|
| `pip-compile requirements.in` | `uv pip compile requirements.in` | Compile dependencies |
| `pip-sync requirements.txt` | `uv pip sync requirements.txt` | Sync environment |

### Creating Lock Files

```bash
# Create requirements.in with your direct dependencies
cat > requirements.in <<EOF
django>=4.2
psycopg2-binary
celery[redis]
EOF

# Compile to requirements.txt with pinned versions
uv pip compile requirements.in -o requirements.txt

# Compile with specific Python version
uv pip compile --python-version 3.11 requirements.in -o requirements.txt

# Compile with extras
uv pip compile --extra dev requirements.in -o requirements-dev.txt
```

### Syncing Environments

```bash
# Sync environment to exact requirements.txt
# This installs missing packages AND removes unlisted ones
uv pip sync requirements.txt

# This ensures your environment matches exactly what's in requirements.txt
```

### Upgrading Dependencies

```bash
# Upgrade all dependencies
uv pip compile --upgrade requirements.in -o requirements.txt

# Upgrade specific package
uv pip compile --upgrade-package django requirements.in -o requirements.txt

# Preview changes without updating
uv pip compile --dry-run requirements.in
```

### Multi-Environment Setup

```bash
# Base dependencies
cat > requirements.in <<EOF
django>=4.2
psycopg2-binary
EOF

# Development dependencies
cat > requirements-dev.in <<EOF
-c requirements.txt
pytest
black
ruff
EOF

# Compile both
uv pip compile requirements.in -o requirements.txt
uv pip compile requirements-dev.in -o requirements-dev.txt

# Install both
uv pip install -r requirements.txt -r requirements-dev.txt
```

## Migration Guide

### Complete Migration Example

#### Before (Traditional Tools)

```bash
# Install pyenv
brew install pyenv

# Install Python
pyenv install 3.11.7
pyenv global 3.11.7

# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install packages
pip install -r requirements.txt

# Create lock file
pip install pip-tools
pip-compile requirements.in

# Sync environment
pip-sync requirements.txt
```

#### After (uv)

```bash
# Install uv
brew install uv

# Install Python
uv python install 3.11.7
uv python pin 3.11.7

# Create virtual environment
uv venv
source .venv/bin/activate

# Install packages
uv pip install -r requirements.txt

# Create lock file
uv pip compile requirements.in -o requirements.txt

# Sync environment
uv pip sync requirements.txt
```

### Step-by-Step Migration

1. **Install uv**
   ```bash
   brew install uv
   ```

2. **Remove old tools** (optional, but recommended after testing)
   ```bash
   brew uninstall pyenv
   pip uninstall pip-tools virtualenv
   ```

3. **Update shell configuration**
   ```bash
   # Remove from ~/.zshrc:
   # export PYENV_ROOT="$HOME/.pyenv"
   # export PATH="$PYENV_ROOT/bin:$PATH"
   # eval "$(pyenv init -)"
   ```

4. **Migrate existing projects**
   ```bash
   cd ~/work/projects/personal/my-project

   # Create .python-version if needed
   uv python pin 3.11

   # Recreate virtual environment with uv
   rm -rf .venv
   uv venv
   source .venv/bin/activate

   # Reinstall packages (much faster!)
   uv pip install -r requirements.txt
   ```

5. **Update your aliases** (already done if using this repo's config!)
   ```bash
   # In config/zsh/config/python.zsh
   alias venv-create='uv venv'
   alias pip='uv pip'  # Optional: force uv usage
   ```

## Common Workflows

### Starting a New Project

```bash
# Create project directory
mkdir my-project && cd my-project

# Pin Python version
uv python pin 3.11

# Create virtual environment
uv venv

# Activate environment
source .venv/bin/activate

# Create requirements.in
cat > requirements.in <<EOF
fastapi
uvicorn[standard]
sqlalchemy
pydantic
EOF

# Compile and install
uv pip compile requirements.in -o requirements.txt
uv pip install -r requirements.txt

# Start developing!
```

### Daily Development Workflow

```bash
# Activate environment
source .venv/bin/activate

# Add new dependency
echo "requests" >> requirements.in
uv pip compile requirements.in -o requirements.txt
uv pip install requests

# Update all dependencies
uv pip compile --upgrade requirements.in -o requirements.txt
uv pip sync requirements.txt

# Run application
uv run python app.py

# Run tests
uv run pytest
```

### Working with Multiple Python Versions

```bash
# Install multiple versions
uv python install 3.10 3.11 3.12

# Create project-specific environments
mkdir py310-project && cd py310-project
uv python pin 3.10
uv venv

mkdir py311-project && cd py311-project
uv python pin 3.11
uv venv

mkdir py312-project && cd py312-project
uv python pin 3.12
uv venv
```

### Creating Development and Production Requirements

```bash
# Base requirements (requirements.in)
cat > requirements.in <<EOF
django>=4.2
psycopg2-binary
celery[redis]
gunicorn
EOF

# Development requirements (requirements-dev.in)
cat > requirements-dev.in <<EOF
-c requirements.txt
pytest
pytest-django
black
ruff
ipython
django-debug-toolbar
EOF

# Compile both
uv pip compile requirements.in -o requirements.txt
uv pip compile requirements-dev.in -o requirements-dev.txt

# Production: install base only
uv pip install -r requirements.txt

# Development: install both
uv pip install -r requirements.txt -r requirements-dev.txt
```

### Working with Jupyter and Data Science

```bash
# Create data science environment
mkdir data-project && cd data-project
uv python pin 3.11
uv venv

# Create requirements
cat > requirements.in <<EOF
jupyter
jupyterlab
numpy
pandas
matplotlib
seaborn
scikit-learn
EOF

# Install (much faster than pip!)
uv pip compile requirements.in -o requirements.txt
uv pip install -r requirements.txt

# Start Jupyter
jupyter lab
```

### CI/CD Pipeline

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install uv
        run: curl -LsSf https://astral.sh/uv/install.sh | sh

      - name: Install Python
        run: uv python install 3.11

      - name: Create venv and install dependencies
        run: |
          uv venv
          uv pip install -r requirements-dev.txt

      - name: Run tests
        run: uv run pytest
```

## Performance Comparisons

### Package Installation Speed

Real-world example installing common data science packages:

```bash
# Test setup
packages="numpy pandas matplotlib seaborn scikit-learn jupyter"

# pip (traditional)
time pip install $packages
# ~120 seconds

# uv pip
time uv pip install $packages
# ~8 seconds

# Result: 15x faster! 🚀
```

### Virtual Environment Creation

```bash
# venv (built-in)
time python -m venv .venv
# ~3 seconds

# uv venv
time uv venv
# ~0.1 seconds

# Result: 30x faster! 🚀
```

### Dependency Resolution

```bash
# pip-compile (pip-tools)
time pip-compile requirements.in
# ~45 seconds

# uv pip compile
time uv pip compile requirements.in -o requirements.txt
# ~2 seconds

# Result: 22x faster! 🚀
```

## Troubleshooting

### Common Issues and Solutions

#### Issue: uv not found after installation

```bash
# Solution: Add to PATH
export PATH="$HOME/.local/bin:$PATH"

# Make permanent
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### Issue: Python version not found

```bash
# List available versions
uv python list --all-versions

# Install specific version
uv python install 3.11.7
```

#### Issue: Package installation fails

```bash
# Try with verbose output
uv pip install --verbose package-name

# Clear cache and retry
rm -rf ~/Library/Caches/uv  # macOS
uv pip install package-name
```

#### Issue: Incompatible dependencies

```bash
# uv has better error messages
uv pip install conflicting-package
# Will show clear conflict resolution

# Override with specific versions
uv pip install "package1==1.0" "package2==2.0"
```

#### Issue: Can't find existing virtual environment

```bash
# Activate explicitly
source .venv/bin/activate

# Or use uv run (no activation needed)
uv run python script.py
```

### Compatibility Notes

#### M1/M2/M3 Mac Compatibility

```bash
# uv handles ARM64 packages automatically
uv pip install tensorflow  # Gets correct ARM version
uv pip install torch       # Gets correct ARM version
```

#### Legacy Projects

```bash
# uv respects .python-version files from pyenv
# No changes needed to existing projects!

# uv works with requirements.txt from pip
uv pip install -r old-requirements.txt
```

#### Docker Usage

```dockerfile
FROM python:3.11-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Install dependencies
COPY requirements.txt .
RUN uv pip install --system -r requirements.txt

# Your application
COPY . .
CMD ["python", "app.py"]
```

## Shell Integration

### Aliases and Functions

Add these to your `~/.zshrc` or use the ones from this repo's `config/zsh/config/python.zsh`:

```bash
# uv shortcuts
alias uv-sync='uv pip sync requirements.txt'
alias uv-compile='uv pip compile requirements.in -o requirements.txt'
alias uv-upgrade='uv pip compile --upgrade requirements.in -o requirements.txt'
alias uv-outdated='uv pip list --outdated'

# Quick venv creation and activation
function uvenv() {
    uv venv && source .venv/bin/activate
}

# Create project with Python version
function new-py-project() {
    local name=$1
    local version=${2:-3.11}
    mkdir "$name" && cd "$name"
    uv python pin "$version"
    uv venv
    echo "Created project: $name with Python $version"
}
```

### Auto-activation

The shell configuration in this repo includes auto-activation for virtual environments:

```bash
# In config/zsh/config/python.zsh
autoload_python_venv() {
    if [[ -d "./.venv" && -z "$VIRTUAL_ENV" ]]; then
        source ./.venv/bin/activate
    elif [[ -d "./venv" && -z "$VIRTUAL_ENV" ]]; then
        source ./venv/bin/activate
    fi
}

add-zsh-hook chpwd autoload_python_venv
```

## Additional Resources

### Official Documentation

- [uv Documentation](https://docs.astral.sh/uv/)
- [GitHub Repository](https://github.com/astral-sh/uv)

### Related Tools from Astral

- **ruff**: Extremely fast Python linter (replacement for flake8, isort, etc.)
- **rye**: Experimental Python package manager (predecessor to uv)

### Commands Quick Reference

```bash
# Python Management
uv python list              # List installed versions
uv python install 3.11      # Install Python version
uv python pin 3.11          # Pin version for project

# Virtual Environments
uv venv                     # Create virtual environment
uv venv --python 3.11       # Create with specific Python

# Package Management
uv pip install package      # Install package
uv pip install -r reqs.txt  # Install from requirements
uv pip list                 # List installed packages
uv pip freeze > reqs.txt    # Export requirements

# Dependency Locking
uv pip compile reqs.in      # Compile lock file
uv pip sync reqs.txt        # Sync to lock file
uv pip compile --upgrade    # Upgrade all dependencies

# Running Commands
uv run python script.py     # Run without activating venv
uv run pytest               # Run tests
```

## Migration Checklist

- [ ] Install uv via Homebrew
- [ ] Install required Python versions with uv
- [ ] Update shell configuration (remove pyenv)
- [ ] Test uv commands in a sample project
- [ ] Migrate existing projects one by one
- [ ] Update CI/CD pipelines
- [ ] Update documentation for team
- [ ] Remove old tools (pyenv, pip-tools, virtualenv)
- [ ] Update shell aliases
- [ ] Celebrate faster workflows! 🎉

---

**Last Updated**: November 4, 2025
**uv Version**: 0.4.x and newer
**Repository**: [macos-dev-setup](https://github.com/kossoy/macos-dev-setup)
