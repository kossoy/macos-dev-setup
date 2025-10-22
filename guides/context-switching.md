# Context Switching Functions - Now Fixed! ✅

**Date**: October 6, 2025  
**Issue**: `show-context`, `work`, and `personal` functions were documented but not implemented  
**Status**: ✅ **FIXED**

## What Was Fixed

The context switching functions were documented in the README but weren't actually implemented in the shell configuration. I've now added:

1. **Environment variables** in `~/.config/zsh/paths/paths.zsh`
2. **Context switching functions** in `~/.config/zsh/functions/functions.zsh`
3. **Bug fix** for `ZSH_DEBUG` parameter check
4. **GitHub CLI integration** - October 7, 2025: Added automatic GitHub logout/login when switching contexts
5. **Browser switching** - October 7, 2025: Added automatic default browser switching when changing contexts
6. **GitHub Enterprise support** - October 7, 2025: Added support for GitHub Enterprise Server instances
7. **Git protocol automation** - October 7, 2025: Automatic SSH/HTTPS protocol selection with `--skip-ssh-key` flag
8. **VPN automation** - October 7, 2025: Automatic Palo Alto GlobalProtect VPN connect/disconnect

## Available Commands

### 🏢 Switch to Work Context (Company)

```bash
work
```

**What it does:**
- Sets `WORK_CONTEXT=COMPANY_ORG`
- Configures Git: `john.doe@company.com`
- Switches GitHub CLI authentication (if installed)
- Switches default browser (if `defaultbrowser` installed)
- Changes to: `~/work/projects/work`
- Database: `localhost:5432` (PostgreSQL)
- Updates context file: `~/.config/zsh/contexts/current.zsh`

**Output:**
```
🏢 Switching to Company work context...
   🌐 Switching default browser to chrome...
   🔐 Switching GitHub CLI authentication...
✅ Switched to Company work context
   Git: john.doe@company.com
   Projects: /Users/user123/work/projects/work
   Database: localhost:5432
```

**Note**: Browser switches **before** GitHub CLI auth so `gh auth login` opens in the correct browser.

### 🏠 Switch to Personal Context (PersonalOrg)

```bash
personal
```

**What it does:**
- Sets `WORK_CONTEXT=PERSONAL_ORG`
- Configures Git: `john@personal-org.com`
- Switches GitHub CLI authentication (if installed)
- Switches default browser (if `defaultbrowser` installed)
- Changes to: `~/work/projects/personal`
- Database: `localhost:5433` (PostgreSQL)
- Updates context file: `~/.config/zsh/contexts/current.zsh`

**Output:**
```
🏠 Switching to PersonalOrg personal context...
   🌐 Switching default browser to safari...
   🔐 Switching GitHub CLI authentication...
✅ Switched to PersonalOrg personal context
   Git: john@personal-org.com
   Projects: /Users/user123/work/projects/personal
   Database: localhost:5433
```

**Note**: Browser switches **before** GitHub CLI auth so `gh auth login` opens in the correct browser.

### 📋 Show Current Context

```bash
show-context
```

**What it displays:**
- Current context name (Company or PersonalOrg)
- Git configuration (name and email)
- GitHub CLI authentication status
- Default browser (if `defaultbrowser` installed)
- Project and config paths
- Current directory
- Database connection details

**Example Output:**
```
════════════════════════════════════════
📋 Current Development Context
════════════════════════════════════════

🏢 Context: Company (Work)

📧 Git Configuration:
   Name:  John Doe
   Email: john.doe@company.com

🔐 GitHub CLI:
   Logged in as: johndoe

🌐 Default Browser:
   Current: chrome

📁 Paths:
   Projects: /Users/user123/work/projects/work
   Config:   /Users/user123/work/configs/work
   Current:  /Users/user123/work/projects/work

🗄️  Database:
   Host: localhost
   Port: 5432
   Database: company_dev
   User: company_dev

════════════════════════════════════════
```

## Environment Variables

The following environment variables are now available:

### Global Variables (Always Available)
```bash
WORK_ROOT              # ~/work
PROJECTS_ROOT          # ~/work/projects
CONFIGS_ROOT           # ~/work/configs
SCRIPTS_ROOT           # ~/work/scripts
TOOLS_ROOT             # ~/work/tools
DOCS_ROOT              # ~/work/docs
```

### Context-Specific Variables

**When in Work Context:**
```bash
WORK_CONTEXT           # COMPANY_ORG
PROJECT_ROOT           # ~/work/projects/work
CONFIG_ROOT            # ~/work/configs/work
COMPANY_DB_HOST         # localhost
COMPANY_DB_PORT         # 5432
COMPANY_DB_NAME         # company_dev
COMPANY_DB_USER         # company_dev
COMPANY_DB_PASSWORD     # company_dev_123
```

**When in Personal Context:**
```bash
WORK_CONTEXT           # PERSONAL_ORG
PROJECT_ROOT           # ~/work/projects/personal
CONFIG_ROOT            # ~/work/configs/personal
PERSONAL_DB_HOST        # localhost
PERSONAL_DB_PORT        # 5433
PERSONAL_DB_NAME        # personal-org_dev
PERSONAL_DB_USER        # personal-org_dev
PERSONAL_DB_PASSWORD    # personal-org_dev_123
```

## Files Modified

### 1. `~/.config/zsh/paths/paths.zsh`

**Added:**
```bash
# Development paths
export WORK_ROOT="$HOME/work"
export PROJECTS_ROOT="$WORK_ROOT/projects"
export CONFIGS_ROOT="$WORK_ROOT/configs"
export SCRIPTS_ROOT="$WORK_ROOT/scripts"
export TOOLS_ROOT="$WORK_ROOT/tools"
export DOCS_ROOT="$WORK_ROOT/docs"
```

**Fixed:**
```bash
# Changed from: if [[ "$ZSH_DEBUG" == "true" ]]
# To: if [[ "${ZSH_DEBUG:-false}" == "true" ]]
```

### 2. `~/.config/zsh/functions/functions.zsh`

**Added 3 new functions:**
- `work()` - Switch to Company work context
- `personal()` - Switch to PersonalOrg personal context
- `show-context()` - Display current context information

## Usage Examples

### Daily Workflow

**Starting Work Day:**
```bash
# Open terminal
work                    # Switch to work context
show-context            # Verify context
cd DS                   # Navigate to DS projects
git status              # Git uses john.doe@company.com
```

**Working on Personal Projects:**
```bash
personal                # Switch to personal context
show-context            # Verify context
cd my-app               # Navigate to personal project
git status              # Git uses john@personal-org.com
```

### Git Configuration Benefits

The context switching automatically updates your Git configuration and GitHub CLI authentication:

```bash
# After 'work'
$ git config --global user.email
john.doe@company.com

$ gh api user -q .login
(your work GitHub username)

# After 'personal'
$ git config --global user.email
john@personal-org.com

$ gh api user -q .login
(your personal GitHub username)
```

This ensures:
- ✅ Commits have the correct email
- ✅ No accidental commits with wrong identity
- ✅ GitHub attribution is correct
- ✅ GitHub CLI uses the correct account
- ✅ Enterprise vs personal accounts are separate

### Database Connection Benefits

Each context has its own database port:

```bash
# Work context
psql -h localhost -p 5432 -U company_dev -d company_dev

# Personal context
psql -h localhost -p 5433 -U personal-org_dev -d personal-org_dev
```

### GitHub CLI Authentication Benefits

Each context automatically switches your GitHub CLI authentication:

**When switching contexts:**
1. Logs out of current GitHub account
2. Prompts you to authenticate with the appropriate account
3. Stores credentials securely in macOS Keychain

**What you can do with `gh` CLI:**
```bash
# After 'work' command
gh repo list                    # Lists your work repositories
gh pr list                      # Shows work pull requests
gh issue create                 # Creates issues as work account
gh api user -q .login          # Shows work GitHub username

# After 'personal' command  
gh repo list                    # Lists your personal repositories
gh pr list                      # Shows personal pull requests
gh issue create                 # Creates issues as personal account
gh api user -q .login          # Shows personal GitHub username
```

**First-time setup:**

When you first run `work` or `personal`, you'll be prompted to authenticate:

```bash
$ work
🏢 Switching to Company work context...
   🔐 Switching GitHub CLI authentication...
   Please authenticate with your work account (john.doe@company.com)
? What account do you want to log into? GitHub.com
? What is your preferred protocol for Git operations? HTTPS
? Authenticate Git with your GitHub credentials? Yes
? How would you like to authenticate GitHub CLI? Login with a web browser

! First copy your one-time code: XXXX-XXXX
Press Enter to open github.com in your browser...
✓ Authentication complete.
```

**After initial setup:**

Subsequent context switches are faster:

```bash
$ personal
🏠 Switching to PersonalOrg personal context...
   🔐 Switching GitHub CLI authentication...
   Please authenticate with your personal account (john@personal-org.com)
! First copy your one-time code: YYYY-YYYY
Press Enter to open github.com in your browser...
✓ Authentication complete.
```

**Verifying GitHub CLI authentication:**

```bash
# Check current GitHub user
gh auth status

# Check which GitHub account is logged in
gh api user -q .login

# List available tokens
gh auth token
```

**Benefits:**
- ✅ No accidental PRs/issues created with wrong account
- ✅ Correct GitHub username in all CLI operations
- ✅ Separate API rate limits per account
- ✅ Works seamlessly with `gh` commands
- ✅ Credentials stored securely in macOS Keychain

## Integration with Other Tools

### DataGrip Database Connections

Create separate connections in DataGrip:

**Work Connection:**
- Name: `Company Dev`
- Host: `localhost`
- Port: `5432`
- Database: `company_dev`
- User: `company_dev`

**Personal Connection:**
- Name: `PersonalOrg Dev`
- Host: `localhost`
- Port: `5433`
- Database: `personal-org_dev`
- User: `personal-org_dev`

### VS Code / Cursor Workspaces

Create separate workspace files:

```bash
~/work/projects/work/company-workspace.code-workspace
~/work/projects/personal/personal-org-workspace.code-workspace
```

### Database Management Functions

The context works with database management functions:

```bash
work
start-work-db          # Starts databases on port 5432, 6379

personal
start-personal-db      # Starts databases on port 5433, 6380, 27018
```

## Automatic Loading

The functions are automatically loaded when you start a new shell because they're sourced in `~/.config/zsh/zshrc`.

To reload in current shell:
```bash
source ~/.zshrc
```

Or reload specific files:
```bash
source ~/.config/zsh/paths/paths.zsh
source ~/.config/zsh/functions/functions.zsh
```

## Testing

Test all functions work:

```bash
# Test work context
work
show-context
git config --global user.email  # Should show john.doe@company.com
gh api user -q .login           # Should show work GitHub username

# Test personal context
personal
show-context
git config --global user.email  # Should show john@personal-org.com
gh api user -q .login           # Should show personal GitHub username

# Test context persistence
work
# Open new terminal tab
show-context  # Should still show work context

# Test GitHub CLI operations
gh repo list                    # Should show repos for current context
gh pr list                      # Should show PRs for current context
```

## Context Persistence

The current context is stored in:
```
~/.config/zsh/contexts/current.zsh
```

This file is sourced automatically when you start a new shell, so your context persists across terminal sessions.

## Troubleshooting

### Functions Not Found

If functions aren't available:
```bash
# Reload your shell configuration
source ~/.zshrc

# Or reload specific file
source ~/.config/zsh/functions/functions.zsh
```

### Variables Not Set

If you get "parameter not set" errors:
```bash
# Reload paths
source ~/.config/zsh/paths/paths.zsh

# Check if PROJECTS_ROOT is set
echo $PROJECTS_ROOT  # Should show /Users/user123/work/projects
```

### Wrong Git Email

If commits have wrong email:
```bash
# Check current git config
git config --global user.email

# Switch to correct context
work        # or 'personal'

# Verify it changed
git config --global user.email
```

### Context Doesn't Persist

If context resets on new shell:
```bash
# Check if context file exists
cat ~/.config/zsh/contexts/current.zsh

# Check if it's being sourced
grep "current.zsh" ~/.config/zsh/zshrc
```

### GitHub CLI Not Installed

If you see no GitHub authentication prompts:
```bash
# Check if gh is installed
which gh

# Install GitHub CLI with Homebrew
brew install gh

# Reload shell configuration
source ~/.zshrc

# Try switching context again
work
```

### GitHub CLI Authentication Fails

If authentication doesn't work:
```bash
# Check authentication status
gh auth status

# Manually logout and login
gh auth logout
gh auth login

# Check which account is logged in
gh api user -q .login

# Verify token is stored
gh auth token
```

### Wrong GitHub Account After Context Switch

If context switch doesn't change GitHub account:
```bash
# Manually logout
gh auth logout

# Switch context (will prompt for login)
work  # or 'personal'

# Verify correct account
gh api user -q .login
show-context  # Should show correct account
```

## Next Steps

Now that context switching works with GitHub CLI integration, you can:

1. **Use `work` command** before working on DS repositories
2. **Authenticate with GitHub CLI** on first context switch
3. **Run the Git sync script** with correct work context:
   ```bash
   work
   cd ~/work/projects/work
   ./sync-all-repos.sh
   ```
4. **Use GitHub CLI commands** with automatic account switching:
   ```bash
   work
   gh pr list              # Work PRs
   gh issue create         # Create work issue
   
   personal
   gh repo list            # Personal repos
   gh pr create            # Create personal PR
   ```
5. **Set up databases** for each context
6. **Create separate IDE workspaces** for work and personal projects

## Related Documentation

- **[System Setup](setup/01-system-setup.md)** - Original setup documentation
- **[Quick Reference](reference/quick-reference.md)** - All commands and aliases
- **[GitHub CLI Integration](GITHUB_CLI_INTEGRATION.md)** - GitHub CLI setup and usage
- **[GitHub Enterprise Setup](GITHUB_ENTERPRISE_SETUP.md)** - GitHub Enterprise Server configuration
- **[GitHub SSH Configuration](GITHUB_SSH_CONFIGURATION.md)** - SSH/HTTPS protocol setup
- **[Browser Switching](BROWSER_SWITCHING.md)** - Browser switching setup and customization
- **[VPN Automation](VPN_AUTOMATION.md)** - Automatic VPN connect/disconnect (GlobalProtect)
- **[DS Git Sync Guide](../projects/work/DS_GIT_SYNC_GUIDE.md)** - Syncing DS repositories
- **[DS Quick Start](../projects/work/DS_QUICK_START.md)** - Getting started with DS

---

**Fixed**: October 6, 2025  
**Enhanced**: October 7, 2025 (GitHub CLI + Browser switching)  
**Functions**: `work`, `personal`, `show-context`  
**Location**: `~/.config/zsh/functions/functions.zsh`  
**Variables**: `~/.config/zsh/paths/paths.zsh`  
**Requirements**: 
- `gh` CLI (install with `brew install gh`) - for GitHub authentication
- `defaultbrowser` (install with `brew install defaultbrowser`) - for browser switching

**Optional Configuration**:
- `WORK_GITHUB_HOST` - GitHub Enterprise hostname for work (default: `github.com`)
- `PERSONAL_GITHUB_HOST` - GitHub hostname for personal (default: `github.com`)
- `WORK_GH_PROTOCOL` - Git protocol for work: `ssh` or `https` (default: `https`)
- `PERSONAL_GH_PROTOCOL` - Git protocol for personal: `ssh` or `https` (default: `https`)
- `WORK_BROWSER` - Browser for work context (default: `chrome`)
- `PERSONAL_BROWSER` - Browser for personal context (default: `safari`)
- `WORK_VPN_CONNECT` - Auto-connect VPN for work: `true` or `false` (default: `false`)
- `PERSONAL_VPN_DISCONNECT` - Auto-disconnect VPN for personal: `true` or `false` (default: `false`)
- `VPN_PORTAL` - VPN portal address (e.g., `vpn.company.com`)

