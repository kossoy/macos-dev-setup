# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a semi-automated macOS development environment setup package designed for M1 Mac (macOS Tahoe 26.0.1 / Sequoia 15.0.1). It provides context-aware workspace management that automatically switches between work and personal development environments, complete with shell configuration, utility scripts, and comprehensive documentation.

## Core Architecture

### Bootstrap System

**Root Directory Entry Points** (orchestrators users run directly):
- **install.sh** - Remote one-liner installer (`bash <(curl ...)`)
  - Clones repository → runs simple-bootstrap.sh → offers bootstrap.sh
- **bootstrap.sh** - Interactive full setup orchestrator
  - Calls multiple setup-helpers scripts with user prompts
  - Users run: `git clone ... && cd macos-dev-setup && ./bootstrap.sh`
- **simple-bootstrap.sh** - Non-interactive automated setup orchestrator
  - Same as bootstrap but with sensible defaults, no prompts

**setup-helpers/ Directory** (modular components called by orchestrators):
- **01-install-homebrew.sh** - Package manager installation
- **02-install-oh-my-zsh.sh** - Shell framework with plugins
- **03-setup-shell.sh** - Shell configuration deployment
- **04-install-docker.sh** - Docker Desktop setup
- **05-install-python.sh** - Python + pyenv (supports --mode=ai-ml)
- **06-install-nodejs.sh** - Node.js + Volta
- **07-setup-databases.sh** - Docker databases
- **08-restore-sensitive.sh** - Credential restoration helper
- **09-install-ai-ml-tools.sh** - AI/ML tooling
- **10-setup-ssh-keys.sh** - SSH key generation and GitHub upload
- **11-install-utilities.sh** - Utility tools (DuTop disk analyzer)

Users can run individual helpers directly: `./setup-helpers/05-install-python.sh --mode=ai-ml`

### Context Switching System
The heart of this repository is the context-aware environment system located in `config/zsh/`:

**Configuration Structure:**
```
config/zsh/
├── zshrc                      # Main shell config that sources all modules
├── config/
│   ├── aliases.zsh           # Command aliases
│   ├── functions.zsh         # Custom shell functions
│   ├── paths.zsh             # Environment paths
│   ├── python.zsh            # Python-specific config
│   ├── tools.zsh             # Tool-specific settings
│   └── custom.zsh            # User customizations
├── contexts/
│   ├── current.zsh           # Generated file tracking active context
│   └── current.zsh.template  # Template for context generation
└── private/
    ├── api-keys.zsh          # User API keys (gitignored)
    └── api-keys.zsh.template # Template for API keys
```

**Key Functions (defined in config/zsh/config/functions.zsh):**
- `work` / `personal` - Switch development contexts (Git config, browser, databases)
- `show-context` - Display current context information
- `start-db` / `stop-db` - Context-aware database management
- `start-work-db` / `start-personal-db` - Context-specific database control
- `new-work <name>` / `new-personal <name>` - Create context-specific projects
- Navigation shortcuts: `cdwork`, `cdpersonal`, `cdscripts`, `cdtools`, etc.

### Directory Structure
The system creates a standardized work directory:
```
~/work/
├── databases/       # Docker database configurations
├── tools/          # Development tools
├── projects/
│   ├── work/       # Work context projects
│   └── personal/   # Personal context projects
├── configs/
│   ├── work/       # Work-specific configurations
│   └── personal/   # Personal-specific configurations
├── scripts/        # Utility scripts
├── docs/          # Documentation
└── bin/           # User binaries
```

## Key Commands

### Setup and Installation
```bash
# One-liner installation (recommended)
bash <(curl -fsSL https://raw.githubusercontent.com/kossoy/macos-dev-setup/main/install.sh)

# Simple bootstrap (non-interactive, sensible defaults)
./simple-bootstrap.sh

# Full bootstrap (interactive, full customization)
./bootstrap.sh

# Run in test mode (non-interactive)
./bootstrap.sh --test

# Individual helper scripts (modular installation)
./setup-helpers/01-install-homebrew.sh --non-interactive
./setup-helpers/02-install-oh-my-zsh.sh --non-interactive
./setup-helpers/03-setup-shell.sh --non-interactive
./setup-helpers/03-git-and-ssh-setup.sh      # Interactive
./setup-helpers/04-install-docker.sh
./setup-helpers/05-install-python.sh --mode=ai-ml
./setup-helpers/06-install-nodejs.sh --mode=full
./setup-helpers/07-setup-databases.sh
./setup-helpers/08-restore-sensitive.sh
./setup-helpers/09-install-ai-ml-tools.sh
./setup-helpers/10-setup-ssh-keys.sh
./setup-helpers/11-install-utilities.sh
```

### Context Management
```bash
work                    # Switch to work context
personal               # Switch to personal context
show-context           # Display current context
```

### Database Management
```bash
start-db               # Start all databases (shared + current context)
stop-db                # Stop all databases
start-work-db          # Start work-specific databases
start-personal-db      # Start personal-specific databases
clean-databases        # Clean all databases and volumes
```

### Testing
```bash
# Docker-based testing (syntax, structure, permissions)
cd docker
docker compose up --build
docker compose run test-environment ./docker/test-setup.sh

# Cleanup orphan containers
./docker/cleanup.sh

# Test individual components
./setup-helpers/01-install-homebrew.sh
./setup-helpers/02-install-oh-my-zsh.sh
./setup-helpers/03-setup-shell.sh
```

## Important Implementation Details

### Sensitive Files Management
- **Never commit** files in `config/zsh/private/` (except templates)
- **Never commit** `config/zsh/contexts/current.zsh` (generated file)
- API keys stored in `~/.config/zsh/private/api-keys.zsh` (user's home, not repo)
- Template files use `.template` suffix and contain placeholder values

### Browser Integration
The system uses the `defaultbrowser` utility for context-aware browser switching. Current implementation uses Brave browser with profiles:
- Work context: Brave Profile 1
- Personal context: Brave Default profile

See `guides/browser-switching.md` for detailed configuration.

### Vaultwarden Backup System
Comprehensive backup solution for self-hosted Vaultwarden located in `scripts/`:
- `vaultwarden-backup.zsh` - Main backup script with Keychain integration
- `vaultwarden-backup-monitor.zsh` - Monitoring and alerting
- `vaultwarden-preview.zsh` - Preview backup contents
- `vaultwarden-setup.zsh` - Initial setup and configuration

See `guides/vaultwarden-backup-index.md` for complete documentation.

### Testing Approach
The repository includes Docker-based testing for cross-platform validation:
- **Can test in Docker**: Script syntax, file permissions, path resolution, package structure
- **Cannot test in Docker**: macOS-specific features (Homebrew, Oh My Zsh, Powerlevel10k, system integration)
- Full macOS testing requires a clean user account or VM
- See `docs/TESTING.md` and `docker/README.md` for details

## Documentation Structure

### Setup Guides (setup/)
Comprehensive numbered guides (01-14) covering system setup, programming environments, databases, cloud tools, IDEs, security, and productivity tools.

### User Guides (guides/)
Specific configuration guides including:
- Context switching and workflow
- GitHub/Git configuration (SSH, CLI, Enterprise)
- Vaultwarden backup system (complete suite)
- Browser switching
- Audio production setup
- Editor configuration
- VPN automation

### Reference (reference/)
Quick reference materials for commands, troubleshooting, and common issues.

### Testing (testing/)
Database and system test results and validation reports.

## Development Workflow

When modifying this repository:

1. **Test syntax** before committing:
   ```bash
   find . -name "*.sh" -exec bash -n {} \;
   find . -name "*.zsh" -exec zsh -n {} \;
   ```

2. **Test in Docker** for basic validation:
   ```bash
   cd docker && docker compose run test-environment ./docker/test-setup.sh
   ```

3. **Test on macOS** for full integration (required for Mac-specific features)

4. **Never commit sensitive data** - always use templates with placeholders

5. **Update documentation** when changing context switching behavior or adding new functions

## Architecture Notes

- **Context persistence**: Current context stored in `~/.config/zsh/contexts/current.zsh` (generated at runtime)
- **Modular loading**: Shell config sources modules in order: paths → aliases → functions → contexts
- **Error handling**: Scripts use `set -e` and proper error checking with user-friendly messages
- **Cross-platform consideration**: Uses command detection (`command -v`) and conditional logic for macOS-specific features
- **Template system**: `.template` files contain placeholders; users copy and customize during setup
