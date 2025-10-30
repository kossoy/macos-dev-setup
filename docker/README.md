# Docker Testing Environment

This Docker setup allows you to test the macOS Fresh Setup Package in a controlled environment without affecting your main system.

## Quick Start

```bash
# Build and run the test environment
docker compose up --build

# Or run the test script directly
docker compose run test-environment ./docker/test-setup.sh

# Clean up orphan containers (if you see warnings)
./docker/cleanup.sh
```

## What Gets Tested

### ✅ Can Test in Docker
- **Script syntax** - All bash/zsh scripts
- **File permissions** - Executable permissions
- **Path resolution** - File paths and dependencies
- **Template files** - Configuration templates
- **Package structure** - Directory layout
- **Basic functionality** - Script execution flow

### ❌ Cannot Test in Docker (Mac-Specific)
- **Homebrew installation** - Mac package manager
- **Oh My Zsh installation** - Mac shell framework
- **Powerlevel10k theme** - Mac-specific theme
- **macOS-specific tools** - defaultbrowser, etc.
- **System integration** - LaunchAgents, etc.
- **Hardware detection** - Apple Silicon detection
- **macOS permissions** - System-level permissions

## Testing Strategy

### 1. Docker Testing (Automated)
```bash
# Run comprehensive tests
docker compose run test-environment ./docker/test-setup.sh

# Interactive testing
docker compose up --build
# Then inside container:
cd /home/testuser/macos-dev-setup
./bootstrap.sh
```

### 2. Mac-Specific Testing (Manual)
For Mac-specific features, you'll need to test on actual macOS:

#### Test on Clean macOS
```bash
# Create test user account
sudo dscl . -create /Users/testuser
sudo dscl . -create /Users/testuser UserShell /bin/zsh
sudo dscl . -create /Users/testuser RealName "Test User"
sudo dscl . -create /Users/testuser UniqueID 1001
sudo dscl . -create /Users/testuser PrimaryGroupID 20
sudo dscl . -create /Users/testuser NFSHomeDirectory /Users/testuser
sudo createhomedir -c -u testuser

# Switch to test user
su - testuser
cd /path/to/macos-dev-setup
./bootstrap.sh
```

#### Test on Virtual Machine
- Use VMware Fusion or Parallels Desktop
- Install macOS Tahoe 26.0.1
- Create test user account
- Run bootstrap script

## Common Issues to Test

### 1. Path Resolution Issues
```bash
# Test if all paths in config files exist
grep -r "\.zsh" config/zsh/
# Should not show any missing files
```

### 2. Permission Issues
```bash
# Test if all scripts are executable
find . -name "*.sh" -exec test -x {} \; -print
# Should show all .sh files
```

### 3. Syntax Issues
```bash
# Test all scripts for syntax errors
find . -name "*.sh" -exec bash -n {} \;
find . -name "*.zsh" -exec zsh -n {} \;
# Should not show any errors
```

## Debugging Tips

### 1. Enable Debug Mode
```bash
# Run with debug output
bash -x bootstrap.sh
```

### 2. Check File Permissions
```bash
# Check if files are readable
ls -la config/zsh/config/
# Should show readable files
```

### 3. Test Individual Components
```bash
# Test each setup helper individually
./setup-helpers/01-install-homebrew.sh
./setup-helpers/02-install-oh-my-zsh.sh
./setup-helpers/03-setup-shell.sh
```

## Expected Results

### Docker Testing
- ✅ All scripts have correct syntax
- ✅ All files have correct permissions
- ✅ All paths resolve correctly
- ✅ Template files exist
- ✅ Package structure is correct

### Mac Testing
- ✅ Homebrew installs successfully
- ✅ Oh My Zsh installs with plugins
- ✅ Shell configuration loads without errors
- ✅ Context switching functions work
- ✅ Utility scripts are executable
- ✅ Work directory structure is created

## Troubleshooting

### Common Docker Issues
```bash
# If you see orphan container warnings
./docker/cleanup.sh

# If container won't start
docker compose down
docker compose up --build --force-recreate

# If permissions are wrong
docker compose run test-environment chmod +x bootstrap.sh setup-helpers/*.sh scripts/*.sh
```

### Common Mac Issues
```bash
# If Homebrew won't install
# Check internet connection and Xcode Command Line Tools

# If Oh My Zsh won't install
# Check if .oh-my-zsh directory exists and is writable

# If shell config won't load
# Check file permissions and syntax
```

---

**Use Docker for automated testing, then test Mac-specific features on actual macOS!**
