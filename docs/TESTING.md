# Package Testing Guide

## Testing the macOS Fresh Setup Package

This guide provides testing steps for the macOS Fresh Setup Package to ensure it works correctly on a clean macOS Tahoe 26.0.1 system.

## Prerequisites for Testing

- macOS Tahoe 26.0.1 (or compatible version)
- Apple Silicon Mac (M1/M2/M3)
- Administrator access
- Internet connection
- Clean user account (recommended for testing)

## Testing Environment Setup

### Option 1: Clean User Account (Recommended)
```bash
# Create a test user account
sudo dscl . -create /Users/testuser
sudo dscl . -create /Users/testuser UserShell /bin/zsh
sudo dscl . -create /Users/testuser RealName "Test User"
sudo dscl . -create /Users/testuser UniqueID 1001
sudo dscl . -create /Users/testuser PrimaryGroupID 20
sudo dscl . -create /Users/testuser NFSHomeDirectory /Users/testuser
sudo createhomedir -c -u testuser
```

### Option 2: Virtual Machine
- Use VMware Fusion or Parallels Desktop
- Install macOS Tahoe 26.0.1
- Create a test user account

### Option 3: Existing System (Less Ideal)
- Backup your current configuration
- Test in a separate directory
- Restore after testing

## Testing Steps

### 1. Pre-Test Verification

```bash
# Check system requirements
sw_vers -productVersion  # Should be 26.0.1 or compatible
uname -m                 # Should be arm64 for Apple Silicon

# Check if Homebrew is already installed
which brew               # Should not exist on clean system

# Check if Oh My Zsh is installed
ls ~/.oh-my-zsh          # Should not exist on clean system
```

### 2. Package Installation Test

```bash
# Navigate to package directory
cd /path/to/macos-fresh-setup

# Make bootstrap script executable
chmod +x bootstrap.sh

# Run bootstrap script
./bootstrap.sh
```

### 3. Interactive Prompts Test

Verify the following prompts work correctly:

- **System compatibility check**: Should detect macOS version and architecture
- **User information collection**: 
  - Full name for Git
  - Work email address
  - Personal email address
  - Work context name (default: COMPANY_ORG)
  - Personal context name (default: PERSONAL_ORG)
  - GitHub usernames
  - Browser preferences
  - VPN portal (optional)
- **Installation mode selection**: Full/Minimal/Custom
- **Installation plan confirmation**: Review and confirm

### 4. Installation Components Test

#### Homebrew Installation
```bash
# Check Homebrew installation
which brew
brew --version

# Check essential packages
which git curl jq tree defaultbrowser
```

#### Oh My Zsh Installation
```bash
# Check Oh My Zsh installation
ls ~/.oh-my-zsh

# Check plugins
ls ~/.oh-my-zsh/custom/plugins/
# Should contain: zsh-autosuggestions, zsh-syntax-highlighting

# Check Powerlevel10k theme
ls ~/.oh-my-zsh/custom/themes/powerlevel10k
```

#### Shell Configuration
```bash
# Check zsh configuration structure
ls -la ~/.config/zsh/
# Should contain: aliases, functions, paths, contexts, private

# Check configuration files
ls ~/.config/zsh/aliases/aliases.zsh
ls ~/.config/zsh/functions/functions.zsh
ls ~/.config/zsh/paths/paths.zsh

# Check template files
ls ~/.config/zsh/private/api-keys.zsh.template
ls ~/.config/zsh/contexts/current.zsh.template
```

#### Work Directory Structure
```bash
# Check work directory structure
ls -la ~/work/
# Should contain: databases, tools, projects, configs, scripts, docs, bin

# Check project directories
ls ~/work/projects/
# Should contain: work, personal

# Check scripts
ls ~/work/scripts/
# Should contain utility scripts (excluding sensitive ones)
```

### 5. Functionality Tests

#### Shell Loading Test
```bash
# Test shell configuration loads without errors
zsh -c "source ~/.zshrc; echo 'Shell loaded successfully'"

# Check for any error messages
zsh -x ~/.zshrc 2>&1 | grep -i error
```

#### Context Switching Test
```bash
# Test work context
work
show-context
# Should show work context information

# Test personal context
personal
show-context
# Should show personal context information
```

#### Utility Scripts Test
```bash
# Test utility scripts
wdu                    # Disk usage analyzer
psme chrome           # Process finder
myip                  # IP address utility
listening             # Port listener
```

#### Git Configuration Test
```bash
# Check Git configuration
git config --global user.name
git config --global user.email
# Should show configured values
```

### 6. Post-Installation Verification

#### API Keys Template
```bash
# Check API keys template exists
ls ~/.config/zsh/private/api-keys.zsh.template

# Check file permissions
ls -la ~/.config/zsh/private/api-keys.zsh.template
# Should be readable (not 600 yet, as it's a template)
```

#### Browser Switching Test
```bash
# Test browser switching (if defaultbrowser is installed)
defaultbrowser
# Should show current default browser
```

#### PATH Verification
```bash
# Check PATH includes work directories
echo $PATH | grep work/scripts
echo $PATH | grep work/bin
```

### 7. Error Handling Tests

#### Missing Dependencies
```bash
# Test with missing internet connection
# (Disconnect network and run bootstrap.sh)
# Should handle gracefully
```

#### Permission Issues
```bash
# Test with insufficient permissions
# (Run without sudo when needed)
# Should provide clear error messages
```

#### Existing Installations
```bash
# Test with existing Homebrew installation
# Should detect and skip installation
```

## Expected Results

### Successful Installation
- All prompts work correctly
- No error messages during installation
- Shell configuration loads without errors
- Context switching functions work
- Utility scripts are executable and functional
- Work directory structure is created
- Git configuration is set correctly

### Common Issues and Solutions

#### Shell Not Loading
```bash
# Check for syntax errors
zsh -n ~/.zshrc

# Check file permissions
ls -la ~/.zshrc
```

#### Context Switching Not Working
```bash
# Check if functions are loaded
type work
type personal

# Reload shell configuration
source ~/.zshrc
```

#### Scripts Not Found
```bash
# Check PATH
echo $PATH | grep work/scripts

# Add manually if needed
export PATH="$HOME/work/scripts:$PATH"
```

## Testing Checklist

- [ ] System compatibility check passes
- [ ] All interactive prompts work
- [ ] Homebrew installs successfully
- [ ] Oh My Zsh installs with plugins
- [ ] Shell configuration loads without errors
- [ ] Work directory structure is created
- [ ] Utility scripts are executable
- [ ] Context switching functions work
- [ ] Git configuration is set
- [ ] Template files are created
- [ ] No sensitive files are included
- [ ] Error handling works correctly

## Reporting Issues

If you encounter issues during testing:

1. **Note the exact error message**
2. **Check system requirements**
3. **Verify internet connection**
4. **Check file permissions**
5. **Review installation logs**

## Cleanup After Testing

```bash
# Remove test user account (if created)
sudo dscl . -delete /Users/testuser
sudo rm -rf /Users/testuser

# Or restore from backup (if testing on existing system)
```

## Performance Testing

### Installation Time
- Full installation: ~10-15 minutes
- Minimal installation: ~5-8 minutes
- Custom installation: Variable

### System Impact
- Disk space: ~2-3GB (including Homebrew packages)
- Memory: Minimal impact after installation
- Network: ~500MB download during installation

---

**Testing ensures the package works correctly on clean systems and provides a smooth installation experience for users.**
