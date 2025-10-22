# Troubleshooting

Common issues and their solutions for the macOS development environment.

## General Issues

### Permission Errors

**Problem**: `Permission denied` errors when installing packages or running commands.

**Solutions**:

```bash
# For Homebrew packages - never use sudo
brew install <package>

# For Python packages - use virtual environment or --user
pip install --user <package>
# OR (preferred)
python -m venv venv
source venv/bin/activate
pip install <package>

# For npm packages - use Volta (never sudo npm)
volta install <package>

# For system commands that require elevated privileges
sudo <command>
```

### PATH Issues

**Problem**: Command not found even though it's installed.

**Solutions**:

```bash
# Check current PATH
echo $PATH

# Check where command is installed
which <command>

# Reload shell configuration
source ~/.zshrc

# Check if Homebrew is in PATH (M1 Macs)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Verify path configuration
cat ~/.config/zsh/paths/paths.zsh
```

### M1 Mac Compatibility

**Problem**: Package doesn't work on Apple Silicon.

**Solutions**:

```bash
# Check architecture
uname -m  # Should show: arm64

# For Python packages that need special builds
# TensorFlow
pip install tensorflow-macos tensorflow-metal

# For Homebrew packages
# Most packages now support M1 natively
# If not, use Rosetta:
arch -x86_64 brew install <package>

# Check if app is running via Rosetta
ps aux | grep <app-name>
```

## Zsh Configuration Issues

### Commands Not Found

**Problem**: Custom commands like `work`, `personal`, `start-db` not working.

**Solutions**:

```bash
# Verify you're using zsh, not bash
echo $SHELL  # Should show: /bin/zsh

# If using bash, switch to zsh
chsh -s /bin/zsh

# Check if configuration is loaded
grep "source ~/.config/zsh" ~/.zshrc

# Manually source configuration
source ~/.config/zsh/zshrc

# Verify configuration files exist
ls -la ~/.config/zsh/
```

### Context Not Persisting

**Problem**: Context switches don't persist across shell sessions.

**Solutions**:

```bash
# Ensure contexts directory exists
mkdir -p ~/.config/zsh/contexts

# Verify context file is created
cat ~/.config/zsh/contexts/current.zsh

# Verify .zshrc sources contexts
grep "contexts/current.zsh" ~/.config/zsh/zshrc

# Reload configuration
source ~/.zshrc
```

### Functions Not Loading

**Problem**: Shell functions like `mkcd`, `listening`, etc. not available.

**Solutions**:

```bash
# Check if functions file exists
ls ~/.config/zsh/functions/functions.zsh

# Run integration script if missing
~/work/scripts/integrate-existing-scripts.sh

# Manually source functions
source ~/.config/zsh/functions/functions.zsh

# List all loaded functions
declare -f | grep "^[a-z_]" | cut -d' ' -f1
```

## Docker Issues

### Docker Desktop Not Starting

**Problem**: Docker daemon not running.

**Solutions**:

```bash
# Start Docker Desktop from Applications
open -a Docker

# Wait for Docker to start (check menu bar icon)

# Verify Docker is running
docker ps

# Restart Docker Desktop
killall Docker && open -a Docker

# Check Docker Desktop settings
# Preferences → Resources → Memory (allocate at least 4GB)
```

### Database Container Won't Start

**Problem**: `docker compose up` fails for databases.

**Solutions**:

```bash
# Check container logs
docker compose logs <container-name>

# Remove and recreate container
docker compose down
docker compose up -d

# Check for port conflicts
lsof -i :5432  # PostgreSQL
lsof -i :3306  # MySQL
lsof -i :27017 # MongoDB
lsof -i :6379  # Redis

# Stop conflicting service
sudo lsof -ti :5432 | xargs kill -9

# Clean up and restart
docker compose down -v  # Removes volumes too
docker compose up -d
```

### Database Connection Refused

**Problem**: Can't connect to database even though container is running.

**Solutions**:

```bash
# Verify container is running
docker ps | grep <database-name>

# Check container health
docker inspect <container-name> | grep Health -A 10

# Verify port mapping
docker port <container-name>

# Test connection from host
# PostgreSQL
telnet localhost 5432

# Check database logs
docker logs <container-name>

# Restart container
docker restart <container-name>
```

## Git Issues

### Git Configuration Not Switching

**Problem**: Git email doesn't change when switching contexts.

**Solutions**:

```bash
# Verify current Git config
git config --global user.name
git config --global user.email

# Manually switch to work context
work

# Verify context changed
show-context
git config --global user.email

# If still not working, manually set
git config --global user.name "John Doe"
git config --global user.email "john.doe@company.com"

# Check functions are loaded
declare -f switch-to-work
```

### SSH Key Issues

**Problem**: Git push fails with authentication error.

**Solutions**:

```bash
# Generate new SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# Start SSH agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Add key to GitHub
cat ~/.ssh/id_ed25519.pub | pbcopy
# Paste into GitHub Settings → SSH Keys

# Test connection
ssh -T git@github.com
```

## Python Issues

### ModuleNotFoundError

**Problem**: Python can't find installed module.

**Solutions**:

```bash
# Verify module is installed
pip list | grep <module-name>

# Check which Python you're using
which python
python --version

# Check which pip
which pip

# Install in correct environment
# If using virtual environment
source venv/bin/activate
pip install <module>

# If using global
pip install --user <module>

# Verify import
python -c "import <module>; print(<module>.__version__)"
```

### PyenvVersionNotInstalled

**Problem**: `pyenv: version '3.x.x' is not installed`.

**Solutions**:

```bash
# List available versions
pyenv install --list

# Install specific version
pyenv install 3.12.1

# Set as global
pyenv global 3.12.1

# Verify
python --version

# Refresh pyenv shims
pyenv rehash
```

## Node.js Issues

### Volta Not Switching Versions

**Problem**: Node version doesn't change in project directory.

**Solutions**:

```bash
# Verify Volta is installed
volta --version

# Check current Node version
node --version

# Pin version in project
cd ~/work/projects/my-project
volta pin node@18

# Verify package.json
cat package.json | grep volta

# Manually switch (not recommended)
volta install node@18
```

### npm Permission Errors

**Problem**: `EACCES` error when installing npm packages.

**Solutions**:

```bash
# Never use sudo npm install!

# Use Volta (recommended)
volta install <package>

# For project dependencies
npm install <package>

# For global packages via Volta
volta install <package>

# If not using Volta, fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```

## JetBrains Issues

### CLI Launchers Not Working

**Problem**: Commands like `idea`, `pycharm` not found.

**Solutions**:

```bash
# Verify launchers exist
ls ~/work/bin/ | grep -E "(idea|pycharm|webstorm)"

# Configure in Toolbox
# Open JetBrains Toolbox
# Settings → Tools → Shell Scripts
# Set path to: /Users/<username>/work/bin
# Click Generate

# Add to PATH if not already
echo 'export PATH="$HOME/work/bin:$PATH"' >> ~/.config/zsh/paths/paths.zsh
source ~/.zshrc

# Verify
which idea
```

### IDE Won't Open Project

**Problem**: IDE opens but doesn't load project.

**Solutions**:

```bash
# Check if project directory exists
ls -la ~/work/projects/work/my-project

# Open from GUI instead
open -a "IntelliJ IDEA" ~/work/projects/work/my-project

# Reset IDE caches
# File → Invalidate Caches → Invalidate and Restart

# Check IDE logs
# Help → Show Log in Finder
```

## Database GUI Issues

### DataGrip Can't Connect

**Problem**: Connection test fails in DataGrip.

**Solutions**:

```bash
# Verify database is running
docker ps | grep <database-name>

# Verify port
docker port <container-name>

# Test connection from terminal
# PostgreSQL
docker exec <container-name> psql -U <user> -d <database>

# Download JDBC drivers in DataGrip
# File → Settings → Database → Drivers
# Select driver → Download

# Check connection settings
# Host: localhost
# Port: <correct-port>
# Database: <database-name>
# User: <username>
# Password: <password>
```

## Network Issues

### Port Already in Use

**Problem**: Can't start service because port is already in use.

**Solutions**:

```bash
# Find process using port
lsof -i :<port>

# Kill process
sudo lsof -ti :<port> | xargs kill -9

# Or use specific signal
sudo lsof -ti :<port> | xargs kill -15

# Change service port if needed
# Edit docker-compose.yml
# Change "5432:5432" to "5433:5432"
```

### Network Connectivity Issues

**Problem**: Can't connect to internet or services.

**Solutions**:

```bash
# Test connectivity
ping 8.8.8.8

# Test DNS
ping google.com

# Flush DNS cache
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# Check network priority
sudo network-priority.sh

# Renew DHCP lease
sudo ipconfig set en0 DHCP
```

## Performance Issues

### System Running Slow

**Problem**: Mac is sluggish, high CPU/memory usage.

**Solutions**:

```bash
# Check CPU usage
top -o cpu

# Check memory
vm_stat

# Check disk space
df -h
wdu.sh  # Visual disk usage

# Clean Docker
docker system prune -a
docker volume prune

# Clean Homebrew
brew cleanup

# Clean node_modules (if safe)
find ~/work/projects -name "node_modules" -type d -prune -exec du -sh {} \;

# Restart services
stop-db
start-db
```

## Credentials Issues

### API Keys Not Loading

**Problem**: Scripts can't access API keys.

**Solutions**:

```bash
# Verify api-keys.zsh exists
ls -la ~/.config/zsh/api-keys.zsh

# Check permissions
chmod 600 ~/.config/zsh/api-keys.zsh

# Verify it's sourced
grep "api-keys.zsh" ~/.config/zsh/zshrc

# Edit credentials
editapi

# Reload shell
source ~/.zshrc

# Test
echo $LLM_API_KEY  # Should show key
```

### NAS Mount Fails

**Problem**: `nasmount` fails to mount NAS volumes.

**Solutions**:

```bash
# Verify credentials in Keychain
# Open Keychain Access.app
# Search for NAS entries

# Re-run setup
~/work/scripts/setup-nas-keychain.sh

# Test mount manually
mount_smbfs //username@nas-server/share /Volumes/share

# Check network connectivity to NAS
ping <nas-server>
```

## Getting More Help

```bash
# Check logs
tail -f ~/work/logs/*.log

# System logs
log show --predicate 'process == "Docker"' --last 1h

# Docker logs
docker logs <container-name>

# Verbose mode for scripts
bash -x ~/work/scripts/<script-name>.sh

# Create minimal reproduction
# Isolate the issue
# Test in clean environment
```

---

**Still having issues?** Create a detailed issue report with:
1. What you tried to do
2. What happened
3. Error messages (full output)
4. System info: `uname -a`, `sw_vers`
5. Relevant logs

**Last Updated**: October 5, 2025
