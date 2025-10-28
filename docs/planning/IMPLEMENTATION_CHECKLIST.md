# Implementation Checklist - macOS Fresh Setup Restructuring

This checklist provides a step-by-step guide for implementing the restructuring plan.

---

## Phase 1: Foundation (Est. 8-10 hours)

### 1.1 Create install.sh (2-3 hours)

- [ ] **Create file**: `install.sh`
- [ ] **Implement**: macOS version detection
  ```bash
  # Check if macOS
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Error: This script is for macOS only"
    exit 1
  fi

  # Check macOS version
  macos_version=$(sw_vers -productVersion)
  ```

- [ ] **Implement**: Xcode Command Line Tools check/install
  ```bash
  if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    # Wait for installation
  fi
  ```

- [ ] **Implement**: Repository cloning
  ```bash
  REPO_URL="https://github.com/username/macos-fresh-setup.git"
  INSTALL_DIR="$HOME/macos-fresh-setup"

  if [[ -d "$INSTALL_DIR" ]]; then
    cd "$INSTALL_DIR" && git pull
  else
    git clone "$REPO_URL" "$INSTALL_DIR"
  fi
  ```

- [ ] **Implement**: Auto-run simple-bootstrap.sh
- [ ] **Implement**: Offer full bootstrap
- [ ] **Add**: Color-coded output functions
- [ ] **Add**: Error handling (set -e)
- [ ] **Test**: Run on clean macOS system
- [ ] **Test**: Run with existing repository
- [ ] **Test**: Run without Xcode CLT
- [ ] **Document**: Usage in README

---

### 1.2 Refactor simple-bootstrap.sh (3-4 hours)

- [ ] **Review**: Current simple-bootstrap.sh
- [ ] **Remove**: ALL interactive prompts
- [ ] **Implement**: Sensible defaults
  ```bash
  # Default values (no prompts)
  DEFAULT_WORK_CONTEXT="WORK"
  DEFAULT_PERSONAL_CONTEXT="PERSONAL"
  DEFAULT_BROWSER="safari"
  ```

- [ ] **Defer**: Git/SSH configuration (move to bootstrap.sh)
- [ ] **Keep**: Homebrew installation (call 01-install-homebrew.sh)
- [ ] **Keep**: Oh My Zsh installation (call 02-install-oh-my-zsh.sh)
- [ ] **Keep**: Shell config deployment (call 03-setup-shell.sh)
- [ ] **Keep**: Work directory creation
- [ ] **Keep**: Utility scripts installation
- [ ] **Add**: Non-interactive flag to helper calls
- [ ] **Add**: Progress indicators
  ```bash
  echo "[1/7] Installing Homebrew..."
  echo "[2/7] Installing Oh My Zsh..."
  # etc.
  ```

- [ ] **Test**: Run without any user input
- [ ] **Test**: Complete in < 10 minutes
- [ ] **Test**: Idempotency (run twice)
- [ ] **Verify**: No hanging prompts

---

### 1.3 Enhance setup-helpers/01-install-homebrew.sh (1 hour)

- [ ] **Add**: Idempotency check
  ```bash
  if command -v brew &>/dev/null; then
    echo "✅ Homebrew already installed"
    exit 0
  fi
  ```

- [ ] **Add**: Non-interactive flag support
  ```bash
  if [[ "$1" == "--non-interactive" ]]; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl ...)"
  fi
  ```

- [ ] **Improve**: Error handling
- [ ] **Add**: Progress indicators
- [ ] **Test**: Fresh install
- [ ] **Test**: Already installed (idempotency)
- [ ] **Test**: Non-interactive mode

---

### 1.4 Enhance setup-helpers/02-install-oh-my-zsh.sh (1 hour)

- [ ] **Add**: Idempotency check
  ```bash
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "✅ Oh My Zsh already installed"
  else
    # Install
  fi
  ```

- [ ] **Add**: Non-interactive installation
  ```bash
  RUNZSH=no CHSH=no sh -c "$(curl ...)"
  ```

- [ ] **Verify**: Plugins installation (autosuggestions, syntax-highlighting)
- [ ] **Verify**: Powerlevel10k installation
- [ ] **Add**: Error handling for failed plugin clones
- [ ] **Test**: Fresh install
- [ ] **Test**: Already installed
- [ ] **Test**: Plugins update

---

### 1.5 Enhance setup-helpers/03-setup-shell.sh (1 hour)

- [ ] **Add**: Backup existing configs
  ```bash
  if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
  fi
  ```

- [ ] **Improve**: Config deployment
  ```bash
  # Copy source configs to ~/.config/zsh/
  mkdir -p "$HOME/.config/zsh"
  cp -r config/zsh/* "$HOME/.config/zsh/"
  ```

- [ ] **Add**: Template processing
  ```bash
  # Copy templates without .template suffix for user editing
  if [[ -f "$HOME/.config/zsh/private/api-keys.zsh.template" ]]; then
    if [[ ! -f "$HOME/.config/zsh/private/api-keys.zsh" ]]; then
      cp "$HOME/.config/zsh/private/api-keys.zsh.template" \
         "$HOME/.config/zsh/private/api-keys.zsh"
      chmod 600 "$HOME/.config/zsh/private/api-keys.zsh"
    fi
  fi
  ```

- [ ] **Add**: Verify sourcing works
  ```bash
  zsh -c "source $HOME/.zshrc" || echo "Warning: .zshrc has errors"
  ```

- [ ] **Test**: Fresh deployment
- [ ] **Test**: Update existing configs
- [ ] **Test**: Backup creation

---

## Phase 2: Modular Helpers (Est. 12-15 hours)

### 2.1 Create setup-helpers/03-git-and-ssh-setup.sh (3 hours)

- [ ] **Create file**: `setup-helpers/03-git-and-ssh-setup.sh`
- [ ] **Add**: Shebang and error handling
  ```bash
  #!/bin/bash
  set -e
  ```

- [ ] **Implement**: Interactive Git configuration
  ```bash
  read -p "Enter your full name for Git: " git_name
  read -p "Enter your work email: " work_email
  read -p "Enter your personal email: " personal_email
  ```

- [ ] **Implement**: SSH key generation
  ```bash
  if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    ssh-keygen -t ed25519 -C "$work_email" -f "$HOME/.ssh/id_ed25519"
  fi

  if [[ ! -f "$HOME/.ssh/id_ed25519_personal" ]]; then
    ssh-keygen -t ed25519 -C "$personal_email" -f "$HOME/.ssh/id_ed25519_personal"
  fi
  ```

- [ ] **Implement**: SSH config generation
  ```bash
  cat >> "$HOME/.ssh/config" << EOF
  # Work GitHub
  Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519

  # Personal GitHub
  Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
  EOF
  ```

- [ ] **Implement**: GitHub CLI authentication
  ```bash
  gh auth login
  ```

- [ ] **Add**: Display SSH public keys for copying
- [ ] **Add**: Instructions for adding keys to GitHub
- [ ] **Test**: Fresh Git config
- [ ] **Test**: Existing SSH keys (skip generation)
- [ ] **Test**: GitHub CLI auth

---

### 2.2 Create setup-helpers/04-install-docker.sh (2 hours)

- [ ] **Create file**: `setup-helpers/04-install-docker.sh`
- [ ] **Add**: Check for existing Docker
  ```bash
  if command -v docker &>/dev/null; then
    echo "✅ Docker already installed"
    exit 0
  fi
  ```

- [ ] **Implement**: Docker Desktop installation
  ```bash
  brew install --cask docker
  ```

- [ ] **Implement**: Wait for Docker daemon
  ```bash
  echo "Waiting for Docker daemon to start..."
  open -a Docker
  while ! docker info &>/dev/null; do
    sleep 2
  done
  ```

- [ ] **Add**: Verification
  ```bash
  docker --version
  docker compose version
  docker run hello-world
  ```

- [ ] **Test**: Fresh installation
- [ ] **Test**: Already installed
- [ ] **Test**: Docker daemon starts

---

### 2.3 Create setup-helpers/05-install-python.sh (3-4 hours)

- [ ] **Create file**: `setup-helpers/05-install-python.sh`
- [ ] **Adapt from**: `setup-python-ai.sh`
- [ ] **Implement**: Installation mode selection
  ```bash
  echo "Choose Python installation mode:"
  echo "1) Minimal - pyenv only"
  echo "2) Standard - pyenv + Python 3.11"
  echo "3) Full - pyenv + multiple Python versions"
  echo "4) AI/ML - Full + AI packages"
  read -p "Select mode (1-4): " mode
  ```

- [ ] **Implement**: Mode 1 - Minimal
  ```bash
  brew install pyenv
  # Add to shell config
  ```

- [ ] **Implement**: Mode 2 - Standard
  ```bash
  # Minimal +
  pyenv install 3.11
  pyenv global 3.11
  ```

- [ ] **Implement**: Mode 3 - Full
  ```bash
  # Standard +
  pyenv install 3.10 3.12
  pip install --upgrade pip setuptools wheel
  ```

- [ ] **Implement**: Mode 4 - AI/ML
  ```bash
  # Full +
  pip install jupyter notebook jupyterlab
  pip install numpy pandas matplotlib scikit-learn
  pip install torch torchvision torchaudio
  pip install tensorflow
  ```

- [ ] **Add**: Shell integration
  ```bash
  # Add to ~/.zshrc or config
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  ```

- [ ] **Add**: Idempotency checks
- [ ] **Add**: Non-interactive mode (default: Standard)
- [ ] **Test**: Each installation mode
- [ ] **Test**: Idempotency
- [ ] **Test**: Python version switching

---

### 2.4 Create setup-helpers/06-install-nodejs.sh (2-3 hours)

- [ ] **Create file**: `setup-helpers/06-install-nodejs.sh`
- [ ] **Implement**: Installation mode selection
  ```bash
  echo "Choose Node.js installation mode:"
  echo "1) Minimal - Volta only"
  echo "2) Standard - Volta + Node LTS"
  echo "3) Full - Volta + Node LTS + global packages"
  read -p "Select mode (1-3): " mode
  ```

- [ ] **Implement**: Mode 1 - Minimal
  ```bash
  brew install volta
  ```

- [ ] **Implement**: Mode 2 - Standard
  ```bash
  # Minimal +
  volta install node
  ```

- [ ] **Implement**: Mode 3 - Full
  ```bash
  # Standard +
  volta install yarn pnpm
  npm install -g typescript @types/node
  npm install -g eslint prettier
  ```

- [ ] **Add**: Shell integration
  ```bash
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
  ```

- [ ] **Add**: Idempotency checks
- [ ] **Add**: Non-interactive mode (default: Standard)
- [ ] **Test**: Each installation mode
- [ ] **Test**: Volta package management
- [ ] **Test**: Node version switching

---

## Phase 3: Advanced Features (Est. 10-12 hours)

### 3.1 Create setup-helpers/07-setup-databases.sh (4-5 hours)

- [ ] **Create file**: `setup-helpers/07-setup-databases.sh`
- [ ] **Implement**: Context detection
  ```bash
  if [[ -f "$HOME/.config/zsh/contexts/current.zsh" ]]; then
    source "$HOME/.config/zsh/contexts/current.zsh"
    CONTEXT="$WORK_CONTEXT"
  else
    CONTEXT="shared"
  fi
  ```

- [ ] **Create**: Docker Compose templates
  ```yaml
  # docker/databases/work-compose.yml
  services:
    postgres-work:
      image: postgres:15
      ports:
        - "5432:5432"
      environment:
        POSTGRES_PASSWORD: dev
      volumes:
        - postgres-work-data:/var/lib/postgresql/data
  ```

- [ ] **Create**: Shared databases compose
  ```yaml
  # docker/databases/shared-compose.yml
  services:
    postgres-shared:
      image: postgres:15
      ports:
        - "5433:5432"
  ```

- [ ] **Implement**: Database selection
  ```bash
  echo "Select databases to install:"
  echo "1) PostgreSQL"
  echo "2) MySQL"
  echo "3) MongoDB"
  echo "4) Redis"
  echo "5) All"
  ```

- [ ] **Implement**: Docker Compose deployment
  ```bash
  mkdir -p ~/work/databases
  cp docker/databases/*.yml ~/work/databases/
  cd ~/work/databases
  docker compose -f shared-compose.yml up -d
  ```

- [ ] **Add**: Database management functions
  ```bash
  # Add to config/zsh/config/functions.zsh
  start-db() {
    docker compose -f ~/work/databases/shared-compose.yml up -d
    if [[ -f ~/work/databases/${WORK_CONTEXT}-compose.yml ]]; then
      docker compose -f ~/work/databases/${WORK_CONTEXT}-compose.yml up -d
    fi
  }
  ```

- [ ] **Test**: Shared databases
- [ ] **Test**: Context-specific databases
- [ ] **Test**: Port isolation
- [ ] **Test**: Database management functions

---

### 3.2 Create setup-helpers/09-install-ai-ml-tools.sh (3-4 hours)

- [ ] **Create file**: `setup-helpers/09-install-ai-ml-tools.sh`
- [ ] **Implement**: Ollama installation
  ```bash
  brew install ollama
  brew services start ollama
  ```

- [ ] **Implement**: Pull common models
  ```bash
  ollama pull llama2
  ollama pull codellama
  ollama pull mistral
  ```

- [ ] **Implement**: MLflow installation
  ```bash
  pip install mlflow
  ```

- [ ] **Implement**: TensorBoard installation
  ```bash
  pip install tensorboard
  ```

- [ ] **Implement**: Jupyter extensions
  ```bash
  pip install jupyterlab-vim
  pip install jupyterlab-git
  jupyter labextension install @jupyter-widgets/jupyterlab-manager
  ```

- [ ] **Add**: Configuration files
  ```bash
  # MLflow config
  mkdir -p ~/work/mlflow
  # Jupyter config
  jupyter notebook --generate-config
  ```

- [ ] **Test**: Ollama functionality
- [ ] **Test**: MLflow tracking
- [ ] **Test**: Jupyter extensions

---

### 3.3 Rename setup-helpers/04-restore-sensitive.sh (0.5 hours)

- [ ] **Rename**: `04-restore-sensitive.sh` → `08-restore-sensitive.sh`
- [ ] **Update**: All references in other scripts
- [ ] **Update**: Documentation
- [ ] **Test**: Script still works after rename

---

### 3.4 Extract context.zsh module (2-3 hours)

- [ ] **Create file**: `config/zsh/config/context.zsh`
- [ ] **Extract**: Context switching functions from `functions.zsh`
  ```bash
  # Functions to extract:
  - work()
  - personal()
  - show-context()
  - new-work()
  - new-personal()
  ```

- [ ] **Enhance**: Context persistence
  ```bash
  # Better state management
  CONTEXT_FILE="$HOME/.config/zsh/contexts/current.zsh"

  work() {
    cat > "$CONTEXT_FILE" << 'EOF'
  export WORK_CONTEXT="WORK"
  export GIT_AUTHOR_NAME="Your Name"
  export GIT_AUTHOR_EMAIL="work@example.com"
  # ... more config
  EOF
    source "$CONTEXT_FILE"
  }
  ```

- [ ] **Add**: Context validation
- [ ] **Add**: Better error messages
- [ ] **Update**: `config/zsh/zshrc` to source `context.zsh`
- [ ] **Test**: Context switching
- [ ] **Test**: Persistence across sessions

---

## Phase 4: Enhancement & Testing (Est. 8-10 hours)

### 4.1 Refactor bootstrap.sh (3-4 hours)

- [ ] **Review**: Current bootstrap.sh structure
- [ ] **Implement**: Cleaner phase separation
  ```bash
  main() {
    print_header "Phase 1: System Verification"
    check_system

    print_header "Phase 2: User Information"
    collect_user_info

    print_header "Phase 3: Installation Mode"
    select_installation_mode

    # ... etc
  }
  ```

- [ ] **Improve**: Helper orchestration
  ```bash
  run_installation() {
    if should_install "homebrew"; then
      run_helper "01-install-homebrew.sh"
    fi
    # ... etc
  }
  ```

- [ ] **Enhance**: Post-install instructions
  ```bash
  display_post_installation() {
    echo "✅ Installation complete!"
    echo ""
    echo "Next steps:"
    echo "1. Reload shell: source ~/.zshrc"
    echo "2. Configure Git: ./setup-helpers/03-git-and-ssh-setup.sh"
    echo ""
    echo "Optional tools:"
    echo "- Python: ./setup-helpers/05-install-python.sh"
    echo "- Node.js: ./setup-helpers/06-install-nodejs.sh"
    # ... etc
  }
  ```

- [ ] **Add**: Better progress indicators
- [ ] **Test**: Full installation flow
- [ ] **Test**: Minimal installation
- [ ] **Test**: Custom installation

---

### 4.2 Update Docker test environment (2-3 hours)

- [ ] **Update**: `docker/Dockerfile` if needed
- [ ] **Update**: `docker/test-setup.sh`
  ```bash
  # Test install.sh flow
  echo "Testing install.sh..."
  ./install.sh

  # Test simple bootstrap
  echo "Testing simple-bootstrap.sh..."
  ./simple-bootstrap.sh

  # Test full bootstrap (non-interactive)
  echo "Testing bootstrap.sh..."
  ./bootstrap.sh --test
  ```

- [ ] **Create**: Test each helper
  ```bash
  # docker/test-helpers.sh
  ./setup-helpers/01-install-homebrew.sh
  ./setup-helpers/02-install-oh-my-zsh.sh
  # ... etc
  ```

- [ ] **Add**: Idempotency tests
  ```bash
  # Run each helper twice
  ./setup-helpers/01-install-homebrew.sh
  ./setup-helpers/01-install-homebrew.sh  # Should skip
  ```

- [ ] **Document**: Test results
- [ ] **Create**: `TESTING_RESULTS.md`

---

### 4.3 Update documentation (2-3 hours)

- [ ] **Update**: `README.md`
  - [ ] Add one-liner installation
  - [ ] Update quick start section
  - [ ] Add installation modes explanation
  - [ ] Update command reference

- [ ] **Update**: `CLAUDE.md`
  - [ ] Update architecture section
  - [ ] Add new helper scripts
  - [ ] Update key commands
  - [ ] Update development workflow

- [ ] **Create**: Setup guide sequence
  - [ ] `docs/setup/00-getting-started.md`
  - [ ] `docs/setup/01-simple-bootstrap.md`
  - [ ] `docs/setup/02-full-bootstrap.md`
  - [ ] `docs/setup/03-optional-tools.md`

- [ ] **Update**: `RESTRUCTURING_PLAN.md`
  - [ ] Mark completed items
  - [ ] Document deviations
  - [ ] Add lessons learned

- [ ] **Create**: `MIGRATION.md`
  - [ ] Guide for existing users
  - [ ] Backward compatibility notes
  - [ ] Update procedures

---

## Final Checklist

### Code Quality
- [ ] All scripts have proper shebangs (`#!/bin/bash` or `#!/usr/bin/env zsh`)
- [ ] All scripts use `set -e` for error handling
- [ ] All scripts have color-coded output
- [ ] All scripts are idempotent
- [ ] All scripts have usage documentation
- [ ] No hardcoded paths (use variables)
- [ ] Consistent naming conventions
- [ ] Proper error messages

### Testing
- [ ] Docker tests pass 100%
- [ ] Manual testing on clean macOS
- [ ] Manual testing on existing system
- [ ] Idempotency verified for all helpers
- [ ] Context switching works
- [ ] Database management works
- [ ] Optional tools install correctly
- [ ] Non-interactive mode works

### Documentation
- [ ] README.md updated
- [ ] CLAUDE.md updated
- [ ] Setup guides created
- [ ] Migration guide created
- [ ] Comments in code
- [ ] Usage examples provided
- [ ] Troubleshooting section added

### Git & Release
- [ ] Feature branch created
- [ ] Commits are atomic and well-described
- [ ] No sensitive data committed
- [ ] .gitignore updated
- [ ] Version tag created
- [ ] Release notes written
- [ ] CHANGELOG.md updated

---

## Time Estimation Summary

| Phase | Description | Estimated Time |
|-------|-------------|----------------|
| Phase 1 | Foundation | 8-10 hours |
| Phase 2 | Modular Helpers | 12-15 hours |
| Phase 3 | Advanced Features | 10-12 hours |
| Phase 4 | Enhancement & Testing | 8-10 hours |
| **Total** | | **38-47 hours** |

**Recommendation**: Plan for 5-6 full working days (8 hours each) or 2-3 weeks part-time.

---

## Daily Breakdown (Example Schedule)

### Day 1 (8 hours): Foundation
- Morning: Create install.sh (3 hours)
- Afternoon: Refactor simple-bootstrap.sh (3 hours)
- Evening: Enhance helpers 01-03 (2 hours)

### Day 2 (8 hours): Git, Docker, Python
- Morning: Create 03-git-and-ssh-setup.sh (3 hours)
- Afternoon: Create 04-install-docker.sh (2 hours)
- Late afternoon: Start 05-install-python.sh (3 hours)

### Day 3 (8 hours): Python, Node.js
- Morning: Finish 05-install-python.sh (1 hour)
- Mid-morning: Test Python modes (1 hour)
- Afternoon: Create 06-install-nodejs.sh (3 hours)
- Late afternoon: Test Node.js modes (1 hour)
- Evening: Code review and cleanup (2 hours)

### Day 4 (8 hours): Databases, AI/ML
- Morning: Create 07-setup-databases.sh (4 hours)
- Afternoon: Create 09-install-ai-ml-tools.sh (3 hours)
- Evening: Rename 04→08, extract context.zsh (1 hour)

### Day 5 (8 hours): Enhancement & Testing
- Morning: Refactor bootstrap.sh (3 hours)
- Afternoon: Update Docker tests (2 hours)
- Late afternoon: Run comprehensive tests (2 hours)
- Evening: Fix any issues found (1 hour)

### Day 6 (8 hours): Documentation & Polish
- Morning: Update all documentation (3 hours)
- Afternoon: Create migration guide (2 hours)
- Late afternoon: Final testing (2 hours)
- Evening: Prepare release (1 hour)

---

**Status**: Ready for implementation
**Last Updated**: 2025-10-28
