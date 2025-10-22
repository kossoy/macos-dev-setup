# Quick Reference

Comprehensive cheat sheet for commands, aliases, functions, and shortcuts.

## 🚀 Context Switching

```bash
work            # Switch to Company work context (Git + GitHub CLI)
personal        # Switch to PersonalOrg personal context (Git + GitHub CLI)
show-context    # Display current context information (includes GitHub CLI status)
```

**Features:**
- Automatically switches Git config (user.name, user.email)
- Switches GitHub CLI authentication (`gh` commands)
- Changes working directory to context-specific projects folder
- Sets database connection variables

## 📁 Navigation Aliases

```bash
cdwork          # Go to ~/work/projects/work
cdpersonal      # Go to ~/work/projects/personal
cdconfig        # Go to ~/work/configs
cdscripts       # Go to ~/work/scripts
cdtools         # Go to ~/work/tools
cddocs          # Go to ~/work/docs
```

## 🗄️ Database Management

```bash
# Start/Stop All Databases
start-db                 # Start shared + context-specific databases
stop-db                  # Stop all databases
clean-databases          # Clean all databases and volumes

# Context-Specific
start-work-db           # Start Company databases (5432, 6379)
stop-work-db            # Stop Company databases
start-personal-db       # Start PersonalOrg databases (5433, 6380, 27018)
stop-personal-db        # Stop PersonalOrg databases

# Shared Databases
start-shared-db         # Start shared databases (5434, 3307, 27019, 6381)
stop-shared-db          # Stop shared databases

# Quick Connections
docker exec postgres-shared-dev psql -U shared_dev -d shared_dev
docker exec mysql-shared-dev mysql -u shared_dev -pshared_dev_123
docker exec mongodb-shared-dev mongosh
docker exec redis-shared-dev redis-cli
```

## 🛠️ Utility Scripts

```bash
# Disk Usage & File Management
wdu.sh [N]                              # Visual disk usage analyzer (top N items)
organize-screenshots.sh                  # Auto-organize screenshots by date (YYYY/MM/DD)

# Media Conversion
video-to-audio.sh input.mp4 [output.mp3]  # Extract audio from video using ffmpeg

# System Utilities
sudo network-priority.sh                 # Manage Ethernet/Wi-Fi priority
sudo fix-hostname.sh                     # Fix macOS hostname
nasmount                                 # Mount NAS/SMB volumes (uses Keychain)

# Development & Git
sync-to-branches.sh branch1 branch2      # Sync files across Git branches with PRs

# Backup & Security
vault-backup.sh                          # Backup Bitwarden vault to Git
setup-nas-keychain.sh                    # Configure NAS credentials in Keychain

# AI/ML Tools
llm-usage.sh [start] [end]               # Track LLM API usage and costs

# Performance Testing
jmeter                                   # Launch Apache JMeter GUI
jmeter-cli -n -t test.jmx -l results.jtl  # Run JMeter in CLI mode
jmeter-server                            # Start JMeter distributed testing server
```

## ⚡ Enhanced Functions

```bash
# Directory & Project Management
mkcd <dir>                              # Create directory and cd into it
project_setup <name>                     # Scaffold new project with git
backup <file>                           # Create timestamped backup

# Process Management
psme <pattern>                          # Find processes by name
psmes <pattern>                         # Get process IDs by name
slay <pattern> [signal]                 # Kill processes by name

# Kubernetes Utilities
pod_connect <pattern>                    # Connect to pod by pattern
klogs <pattern> [opts]                   # Get pod logs by pattern
dscontext                               # Set namespace to datascience

# Network & System
listening [pattern]                      # List listening ports (with optional pattern)
ramdisk [size_mb]                       # Create RAM disk on macOS

# File Operations
extract <archive>                        # Universal archive extractor (.tar, .gz, .zip, etc.)
```

## 🔀 Git Aliases

```bash
# Status & Info
gs, g              # git status
gl                 # git log --oneline
glog               # git log --oneline --graph --decorate

# Add & Commit
ga                 # git add
gaa                # git add --all
gc                 # git commit
gcm                # git commit -m

# Branch & Checkout
gco                # git checkout
gb                 # git branch

# Remote
gp                 # git push
gpl                # git pull
gf                 # git fetch

# Diff & Stash
gd                 # git diff
gst                # git stash
gstp               # git stash pop
```

## 🐳 Docker Aliases

```bash
d                  # docker
dc                 # docker compose
dps                # docker ps
dpsa               # docker ps -a
di                 # docker images
drm                # docker rm
drmi               # docker rmi
```

## ☸️ Kubernetes Aliases

```bash
k                  # kubectl
kgp                # kubectl get pods
kgs                # kubectl get services
kgd                # kubectl get deployments
kctx               # kubectl config current-context
kns                # kubectl config set-context --current --namespace
```

## 💻 JetBrains IDEs (CLI)

```bash
idea <path>        # Open project in IntelliJ IDEA
pycharm <path>     # Open project in PyCharm
webstorm <path>    # Open project in WebStorm
datagrip           # Open DataGrip
clion <path>       # Open project in CLion
```

## ✏️ Editor Commands

```bash
# Quick Edit (Opens in Cursor, doesn't block terminal)
editapi            # Edit API keys/credentials
editzsh            # Edit .zshrc
editnvim           # Edit nvim configuration
edit <file>        # Edit any file in Cursor

# Terminal Editor (Neovim)
viapi              # Edit API keys in nvim
vizsh              # Edit .zshrc in nvim
vinvim             # Edit nvim config in nvim

# Generic
cursor <file>      # Open file in Cursor
nvim <file>        # Open file in Neovim
```

## 🌐 Network Utilities

```bash
myip               # Show public IP
myip4              # Show public IPv4
myip6              # Show public IPv6
listening          # List all listening ports
listening 8080     # Check if port 8080 is listening
```

## 🍎 macOS Specific

```bash
ds_wipe            # Remove all .DS_Store files recursively
show_hidden        # Show hidden files in Finder
hide_hidden        # Hide hidden files in Finder
```

## 📦 Package Management

```bash
# Homebrew
brew update && brew upgrade        # Update all packages
brew cleanup                       # Clean up old versions
brew doctor                        # Check for issues

# Python (pip)
pip list --outdated               # Show outdated packages
pip install --upgrade <package>   # Upgrade package
pip freeze > requirements.txt     # Export dependencies

# Node.js (npm/volta)
npm outdated -g                   # Show outdated global packages
volta install <package>@latest    # Install/update with Volta
```

## 🔧 System Commands

```bash
# Disk Usage
df -h                             # Show disk space
du -sh *                          # Show directory sizes
wdu.sh                            # Visual disk usage analyzer

# Memory
vm_stat                           # Show memory usage

# Processes
top                               # Process monitor
htop                              # Enhanced process monitor (if installed)

# Network
ping <host>                       # Test connectivity
traceroute <host>                 # Trace network path
lsof -i :<port>                   # Check what's using a port
```

## 🚦 Development Workflow Examples

### Starting a New Work Project

```bash
# Switch to work context
work

# Create new project
new-work my-api-service

# Navigate to project
cd ~/work/projects/work/my-api-service

# Start databases
start-work-db

# Open in IDE
idea .
```

### Starting a New Personal Project

```bash
# Switch to personal context
personal

# Create new project
new-personal my-app

# Navigate to project
cd ~/work/projects/personal/my-app

# Start databases
start-personal-db

# Open in IDE
webstorm .
```

### Daily Development Routine

```bash
# Morning startup
start-db                          # Start all databases
idea ~/work/projects/work/current-project

# Check status
docker ps                         # Verify databases running
show-context                      # Verify current context
gs                                # Check git status

# Evening cleanup
stop-db                           # Stop databases
brew update && brew upgrade       # Update packages
```

## 🔑 Environment Variables

```bash
# Global Paths
$WORK_ROOT         # Base work directory (~/work)
$PROJECTS_ROOT     # Projects directory (~/work/projects)
$CONFIGS_ROOT      # Configurations directory (~/work/configs)
$SCRIPTS_ROOT      # Scripts directory (~/work/scripts)
$TOOLS_ROOT        # Tools directory (~/work/tools)
$DOCS_ROOT         # Documentation directory (~/work/docs)

# Context-Specific (set by context functions)
$WORK_CONTEXT      # Current context (COMPANY_ORG or PERSONAL_ORG)
$PROJECT_ROOT      # Current project root directory
$CONFIG_ROOT       # Current configuration root directory

# Tool Paths
$JMETER_HOME       # Apache JMeter installation directory
```

## 📚 Help Commands

```bash
# Command help
<command> --help              # Show command help
man <command>                 # Show manual page

# Shell help
help                          # List shell builtins
which <command>               # Show command location
type <command>                # Show command type

# Custom help
cursor-editor                 # Show Cursor keyboard shortcuts reminder
```

---

**Pro Tip**: Type `alias` to see all available aliases, or `declare -f` to see all functions.

**Last Updated**: October 5, 2025
