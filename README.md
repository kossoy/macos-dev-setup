# macOS Fresh Setup Package

🚀 **Semi-automated development environment setup for M1 Mac (macOS Sequoia 15.x / Tahoe 26.x)**

## Quick Start

### ⚡ One-Liner Installation (Recommended)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/username/macos-fresh-setup/main/install.sh)
```

This single command will:
1. ✅ Validate your macOS system compatibility
2. ✅ Install Xcode Command Line Tools (if needed)
3. ✅ Clone this repository to `~/macos-fresh-setup`
4. ✅ Run simple-bootstrap.sh automatically
5. ✅ Offer to run full bootstrap.sh for advanced setup

### 🔧 Manual Installation

If you prefer manual control:

```bash
# Clone the repository
git clone https://github.com/username/macos-fresh-setup.git
cd macos-fresh-setup

# Option 1: Simple Bootstrap (non-interactive, sensible defaults)
./simple-bootstrap.sh

# Option 2: Full Bootstrap (interactive, full customization)
./bootstrap.sh
```

### 📦 Optional Development Environments

After basic setup, install additional tools as needed:

```bash
# Docker Desktop
./setup-helpers/04-install-docker.sh

# Python environment (pyenv + Python)
./setup-helpers/05-install-python.sh         # Standard mode
./setup-helpers/05-install-python.sh --mode=ai-ml  # With AI/ML packages

# Node.js environment (Volta + Node)
./setup-helpers/06-install-nodejs.sh         # Standard mode
./setup-helpers/06-install-nodejs.sh --mode=full   # With global packages

# Docker-based databases (PostgreSQL, MySQL, MongoDB, Redis)
./setup-helpers/07-setup-databases.sh

# AI/ML tools (Ollama, MLflow, Jupyter)
./setup-helpers/09-install-ai-ml-tools.sh

# Git, SSH, and GitHub CLI configuration
./setup-helpers/03-git-and-ssh-setup.sh
```

### 🔑 Configure API Keys

```bash
# Edit your API keys file
~/.config/zsh/private/api-keys.zsh

# Set proper permissions
chmod 600 ~/.config/zsh/private/api-keys.zsh
```

### 🔄 Reload Shell

```bash
source ~/.zshrc
# or restart your terminal
```

## What You Get

✅ **Enhanced Shell**: Oh My Zsh + Powerlevel10k + custom functions  
✅ **Context Switching**: Automatic work/personal environment switching  
✅ **Utility Scripts**: Disk usage, process management, network tools  
✅ **Work Organization**: Structured project directories  
✅ **Browser Integration**: Context-aware browser switching  

## Essential Commands

```bash
work                    # Switch to work context
personal               # Switch to personal context
wdu                    # Disk usage analyzer
psme <process>         # Find processes
myip                   # Get your public IP
```

## Requirements

- macOS Tahoe 26.0.1
- Apple Silicon (M1/M2/M3)
- Administrator access
- Internet connection

## Documentation

- **Quick Start**: See `docs-quickstart/QUICKSTART.md`
- **Backup Locations**: See `docs/BACKUP_LOCATIONS.md`
- **Testing Guide**: See `docs/TESTING.md`
- **Full Setup Guides**: Clone the full docs repo after installation

---

**Ready to code!** 🚀

## 📖 Documentation Structure

This documentation is organized into logical sections for easy consumption in Obsidian or any markdown editor.

### 🚀 Setup Guides

Complete step-by-step setup instructions for your development environment:

**All Guides Complete & Self-Contained:**

- **[01 - System Setup](setup/01-system-setup.md)** - macOS updates, Xcode, Homebrew, shell configuration
- **[02 - Python Environment](setup/02-python-environment.md)** - Python, pyenv, pip packages, Jupyter
- **[03 - Node.js Environment](setup/03-nodejs-environment.md)** - Volta, Node.js, npm packages, Deno
- **[04 - Java Environment](setup/04-java-environment.md)** - SDKMAN, Java versions, Maven, Gradle, Spring Boot
- **[05 - Docker & Kubernetes](setup/05-docker-kubernetes.md)** - Docker Desktop, kubectl, minikube, Helm, k9s
- **[06 - Databases](setup/06-databases.md)** - Context-aware database setup, Docker Compose, DataGrip
- **[07 - Cloud & DevOps](setup/07-cloud-devops.md)** - AWS CLI, Terraform, Ansible, Prometheus, Grafana
- **[08 - IDEs & Editors](setup/08-ides-editors.md)** - JetBrains IDEs, Cursor, Neovim configuration
- **[09 - Git & Version Control](setup/09-git-configuration.md)** - Git config, GitHub CLI, SSH keys, workflows
- **[10 - API Development](setup/10-api-development.md)** - Postman, HTTPie, cURL, JMeter, GraphQL tools
- **[11 - AI/ML Tools](setup/11-ai-ml-tools.md)** - Jupyter, MLflow, TensorBoard, TensorFlow, PyTorch
- **[12 - Security & Monitoring](setup/12-security-monitoring.md)** - Security tools, monitoring, backups
- **[13 - Productivity Tools](setup/13-productivity-tools.md)** - Setapp, Paste, CleanMyMac X, productivity apps
- **[14 - Communication Tools](setup/14-communication-tools.md)** - Telegram, WhatsApp, Slack, video conferencing

### 📚 Guides

Specific configuration and usage guides:

#### General Development
- **[Obsidian Setup](guides/obsidian-setup.md)** - Install and configure Obsidian for documentation
- **[Obsidian Vault Git Sync](guides/obsidian-vault-git-sync.md)** - **NEW!** Sync this vault across devices using Obsidian Git plugin
- **[Obsidian GitHub Sync](guides/obsidian-github-sync.md)** - Sync your Obsidian vaults across devices via GitHub
- **[Cursor Setup](guides/cursor-setup.md)** - Cursor window management and AI-assisted development
- **[Editor Configuration](guides/editor-configuration.md)** - Neovim and Cursor editor setup
- **[DataGrip Setup](guides/datagrip-setup.md)** - Database connection management across contexts
- **[Scripts Integration](guides/scripts-integration.md)** - Utility scripts and automation integration

#### Context Switching & Workflow
- **[Context Switching](guides/context-switching.md)** - Complete guide to work/personal context switching with Git, GitHub CLI, browser, and database automation
- **[Browser Switching](guides/browser-switching.md)** - Comprehensive browser switching configuration and customization
- **[Browser Switching Comparison](guides/browser-switching-comparison.md)** - Default browser switching vs. Brave profiles - detailed pros/cons analysis
- **[VPN Automation](guides/vpn-automation.md)** - Automatic VPN connection/disconnection with GlobalProtect

**Current Solution:** Using Brave browser with profiles - **Profile 1** for work (Company), **Default** for personal (PersonalOrg)

#### GitHub & Git Configuration
- **[GitHub SSH Setup](guides/github-ssh-setup.md)** - Set up SSH keys for GitHub (foundational)
- **[GitHub CLI Integration](guides/github-cli-integration.md)** - GitHub CLI authentication with context switching
- **[GitHub Enterprise Setup](guides/github-enterprise-setup.md)** - Configure GitHub Enterprise Server instances
- **[GitHub SSH Configuration](guides/github-ssh-configuration.md)** - SSH vs HTTPS protocol configuration
- **[Company GitHub Setup](guides/sap-company-github-setup.md)** - Quick start for Company GitHub Enterprise

#### Audio Production 🎵
- **[Audio Interfaces Setup](guides/audio-interfaces-setup.md)** - Configure multiple USB audio interfaces and aggregate devices
- **[Cubase 14 Pro Setup](guides/cubase-14-pro-setup.md)** - Install and configure Cubase 14 Pro DAW (comprehensive guide)
- **[Superior Drummer 3 Setup](guides/superior-drummer-3-setup.md)** - Install and configure Superior Drummer 3 drum production software
- **[Logic Pro Organization](guides/logic-pro-organization.md)** - Logic Pro project organization and workflow

#### Vaultwarden Backup System 🔐
Complete backup solution for self-hosted Vaultwarden (https://pwd.oklabs.uk):

- **[📖 Backup System Index](guides/vaultwarden-backup-index.md)** - **START HERE** - Complete overview and quick start
- **[🔑 GitHub SSH Setup](guides/github-ssh-setup.md)** - Set up SSH keys for GitHub (required first)
- **[💻 macOS Automated Backup](guides/vaultwarden-backup-macos.md)** - User-level encrypted backups every 2-3 hours
- **[🔒 Migrate to Encrypted](guides/vaultwarden-migrate-to-encrypted.md)** - If you have existing plain text backups
- **[🧪 Complete Setup & Testing](guides/vaultwarden-backup-test.md)** - Step-by-step installation walkthrough
- **[🖥️ Server Backup (TrueNAS)](guides/vaultwarden-server-backup.md)** - Database and full data backups
- **[🔄 Restore Procedures](guides/vaultwarden-restore-procedures.md)** - Disaster recovery for all scenarios
- **[📊 Monitoring Dashboard](guides/vaultwarden-monitoring.md)** - Health monitoring and alerting
- **[⚡ Quick Reference](guides/vaultwarden-quick-reference.md)** - Commands cheat sheet

### 🧪 Testing

Database and system test results:

- **[Database Test Results](testing/database-test-results.md)** - Docker database deployment tests
- **[Database Test Summary](testing/database-test-summary.md)** - Context-aware database architecture validation

### 📋 Reference

Quick reference materials:

- **[Quick Reference](reference/quick-reference.md)** - Commands, aliases, functions cheat sheet
- **[Troubleshooting](reference/troubleshooting.md)** - Common issues and solutions
- **[GlobalProtect Troubleshooting](reference/globalprotect-troubleshooting.md)** - VPN connection and automation issues

## 🎯 Quick Start

### For Fresh macOS Install

Follow the self-contained setup guides in order:

1. **[System Setup](setup/01-system-setup.md)** - macOS, Homebrew, shell
2. **[Python Environment](setup/02-python-environment.md)** - Python, pyenv, packages
3. **[Node.js Environment](setup/03-nodejs-environment.md)** - Volta, Node, npm
4. **[Java Environment](setup/04-java-environment.md)** - SDKMAN, Java, Maven, Gradle
5. **[Docker & Kubernetes](setup/05-docker-kubernetes.md)** - Containers & orchestration
6. **[Databases](setup/06-databases.md)** - Context-aware databases
7. **[Cloud & DevOps](setup/07-cloud-devops.md)** - AWS, Terraform, monitoring
8. **[IDEs & Editors](setup/08-ides-editors.md)** - JetBrains, Cursor, Neovim
9. **[Git Configuration](setup/09-git-configuration.md)** - Git, GitHub CLI, workflows
10. **[API Development](setup/10-api-development.md)** - Postman, testing tools
11. **[AI/ML Tools](setup/11-ai-ml-tools.md)** - Jupyter, TensorFlow, PyTorch
12. **[Security](setup/12-security-monitoring.md)** - Security, monitoring, backups
13. **[Productivity Tools](setup/13-productivity-tools.md)** - Setapp, Paste, productivity apps
14. **[Communication Tools](setup/14-communication-tools.md)** - Telegram, WhatsApp, messaging
15. Configure credentials: `editapi`

### If You Have Existing Scripts

If you already have tools in `~/work/Mac OS install/`:

1. Start with **[System Setup](setup/01-system-setup.md)**
2. Run: `~/work/scripts/integrate-existing-scripts.sh`
3. Follow remaining setup guides
4. Configure credentials: `editapi`

## 🔑 Key Features

- **Context-Aware Development**: Separate work (Company) and personal (PersonalOrg) environments
- **Docker-Based Databases**: PostgreSQL, MySQL, MongoDB, Redis with port isolation
- **JetBrains-First**: Integrated workflow with IntelliJ IDEA, PyCharm, WebStorm, DataGrip
- **AI-Powered Tools**: Cursor, LLM usage tracking, ML development tools
- **Enhanced Shell**: Powerful zsh configuration with aliases, functions, and utilities
- **Secure Credentials**: Centralized credential management with macOS Keychain integration

## 📱 Context Switching

Easily switch between work and personal development contexts:

```bash
# Switch to Company work context
work

# Switch to PersonalOrg personal context  
personal

# Check current context
show-context

# Quick browser profile shortcuts (without full context switch)
brave-work      # Open work profile (Profile 1)
brave-personal  # Open personal profile (Default)
```

## 🗄️ Database Management

Context-aware database management:

```bash
# Start all databases (shared + current context)
start-db

# Start specific context databases
start-work-db        # Company databases
start-personal-db    # PersonalOrg databases  
start-shared-db      # Shared development databases

# Stop all databases
stop-db
```

## 🛠️ Utility Scripts

Powerful utilities for common tasks:

```bash
# Browser switching test
./scripts/test-browser-switching.zsh

# Vaultwarden backup scripts
./scripts/vaultwarden-backup.zsh
./scripts/vaultwarden-backup-monitor.zsh
./scripts/vaultwarden-preview.zsh
./scripts/vaultwarden-setup.zsh

# Disk usage analyzer
wdu.sh

# Screenshot organization
organize-screenshots.sh

# Video to audio conversion
video-to-audio.sh input.mp4 output.mp3

# LLM usage tracking
llm-usage.sh

# Performance testing
jmeter
```

## 🔗 External Resources

- [JetBrains Documentation](https://www.jetbrains.com/help/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Homebrew Documentation](https://docs.brew.sh/)

## 📝 Notes

- All documentation is written in Markdown for easy viewing in Obsidian, VS Code, or any markdown editor
- Code blocks include syntax highlighting and are copy-paste ready
- Cross-references between documents use relative links
- Documentation is version-controlled in Git

---

**Last Updated**: October 5, 2025  
**System**: macOS Sequoia 15.0.1  
**Hardware**: MacBook Pro M1
