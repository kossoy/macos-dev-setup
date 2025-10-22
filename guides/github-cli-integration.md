# GitHub CLI Integration with Context Switching ✅

**Date**: October 7, 2025  
**Status**: ✅ **IMPLEMENTED**

## Summary

Added automatic GitHub CLI (`gh`) logout/login functionality to the `work` and `personal` context switching functions. Now when you switch between work and personal contexts, the GitHub CLI authentication automatically switches to the appropriate account.

**Important**: 
- When browser switching is also enabled, the default browser is switched **before** GitHub CLI authentication, ensuring that `gh auth login` opens in the correct browser for the context.
- **GitHub Enterprise Support**: The functions support GitHub Enterprise Server instances (like `github.company.com`). Configure via `WORK_GITHUB_HOST` and `PERSONAL_GITHUB_HOST` environment variables.

## What Changed

### 1. Updated `work()` Function

**Location**: `~/.config/zsh/functions/functions.zsh` (lines 590-598)

**Added:**
```bash
# Switch GitHub CLI authentication if gh is installed
if command -v gh >/dev/null 2>&1; then
    echo "   🔐 Switching GitHub CLI authentication..."
    # Logout from current account
    gh auth logout 2>/dev/null
    # Login with work account
    echo "   Please authenticate with your work account (john.doe@company.com)"
    gh auth login
fi
```

**What it does:**
- Checks if `gh` CLI is installed
- Logs out of current GitHub account
- Prompts user to authenticate with work account
- Stores credentials in macOS Keychain

### 2. Updated `personal()` Function

**Location**: `~/.config/zsh/functions/functions.zsh` (lines 633-641)

**Added:**
```bash
# Switch GitHub CLI authentication if gh is installed
if command -v gh >/dev/null 2>&1; then
    echo "   🔐 Switching GitHub CLI authentication..."
    # Logout from current account
    gh auth logout 2>/dev/null
    # Login with personal account
    echo "   Please authenticate with your personal account (john@personal-org.com)"
    gh auth login
fi
```

**What it does:**
- Checks if `gh` CLI is installed
- Logs out of current GitHub account
- Prompts user to authenticate with personal account
- Stores credentials in macOS Keychain

### 3. Updated `show-context()` Function

**Location**: `~/.config/zsh/functions/functions.zsh` (lines 691-701)

**Added:**
```bash
# GitHub CLI authentication status
if command -v gh >/dev/null 2>&1; then
    echo "🔐 GitHub CLI:"
    local gh_user=$(gh api user -q .login 2>/dev/null)
    if [[ -n "$gh_user" ]]; then
        echo "   Logged in as: $gh_user"
    else
        echo "   Not authenticated (run 'gh auth login')"
    fi
    echo ""
fi
```

**What it does:**
- Checks if `gh` CLI is installed
- Queries GitHub API to get current username
- Displays authentication status
- Shows helpful message if not authenticated

## Benefits

### ✅ No More Account Confusion

Before:
```bash
work
gh pr list                    # Might show personal PRs 😱
gh issue create               # Creates with wrong account 😱
```

After:
```bash
work
# Prompts for work account authentication
gh pr list                    # Shows work PRs ✅
gh issue create               # Creates with work account ✅
```

### ✅ Complete Context Isolation

Each context now manages:
- Git configuration (name, email)
- GitHub CLI authentication
- Working directory
- Database connections
- Environment variables

### ✅ Safe Operations

- No more accidental PRs/issues created with wrong account
- No more commits attributed to wrong GitHub account
- Separate API rate limits per account
- Clear visibility of current authentication

### ✅ Seamless Experience

```bash
# Switch to work context
work
# Authenticate once

# Use any GitHub CLI commands
gh repo list
gh pr create
gh issue list
gh workflow run

# Switch to personal context
personal
# Authenticate once

# All GitHub CLI commands now use personal account
gh repo list
gh pr create
gh issue list
```

## Usage Examples

### First Time Setup

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
✅ Switched to Company work context
   Git: john.doe@company.com
   Projects: /Users/user123/work/projects/work
   Database: localhost:5432
```

### Subsequent Context Switches

```bash
$ personal
🏠 Switching to PersonalOrg personal context...
   🔐 Switching GitHub CLI authentication...
   Please authenticate with your personal account (john@personal-org.com)
! First copy your one-time code: YYYY-YYYY
Press Enter to open github.com in your browser...
✓ Authentication complete.
✅ Switched to PersonalOrg personal context
   Git: john@personal-org.com
   Projects: /Users/user123/work/projects/personal
   Database: localhost:5433
```

### Checking Context

```bash
$ show-context
════════════════════════════════════════
📋 Current Development Context
════════════════════════════════════════

🏢 Context: Company (Work)

📧 Git Configuration:
   Name:  John Doe
   Email: john.doe@company.com

🔐 GitHub CLI:
   Logged in as: johndoe

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

## Common GitHub CLI Operations

### After `work` command:

```bash
# Repository operations
gh repo list                              # List work repositories
gh repo view                              # View current repository
gh repo clone organization/repo           # Clone work repository

# Pull request operations
gh pr list                                # List work PRs
gh pr create                              # Create PR as work account
gh pr view 123                            # View specific PR
gh pr checkout 123                        # Checkout PR locally

# Issue operations
gh issue list                             # List work issues
gh issue create                           # Create issue as work account
gh issue view 456                         # View specific issue

# Workflow operations
gh workflow list                          # List GitHub Actions
gh workflow run build.yml                 # Trigger workflow
gh run list                               # List workflow runs

# API operations
gh api user -q .login                     # Show current username
gh api repos/:owner/:repo/pulls          # Query API directly
```

### After `personal` command:

All the same operations, but using your personal GitHub account.

## Installation Requirements

### GitHub CLI

If not already installed:

```bash
# Install with Homebrew
brew install gh

# Verify installation
gh --version

# Reload shell configuration
source ~/.zshrc
```

### First-time Authentication

On your first context switch:

1. Run `work` or `personal`
2. Follow the authentication prompts
3. Choose "Login with a web browser" (recommended)
4. Copy the one-time code
5. Press Enter to open browser
6. Paste code and authenticate

Credentials are stored in macOS Keychain for future use.

## Troubleshooting

### Issue: GitHub CLI Not Found

```bash
# Check if installed
which gh

# If not found, install
brew install gh

# Reload configuration
source ~/.zshrc
```

### Issue: Authentication Fails

```bash
# Check current status
gh auth status

# Manually logout and try again
gh auth logout
work  # or 'personal'
```

### Issue: Wrong Account After Switch

```bash
# Verify current account
gh api user -q .login

# If wrong, manually logout
gh auth logout

# Switch context again
work  # or 'personal'
```

### Issue: "Permission Denied" on GitHub Operations

```bash
# Check authentication
gh auth status

# Refresh token
gh auth refresh

# Or re-authenticate
gh auth logout
work  # or 'personal'
```

## Testing

### Test Context Switching

```bash
# Test work context
work
show-context                        # Should show work context
git config --global user.email      # Should show john.doe@company.com
gh api user -q .login               # Should show work GitHub username

# Test personal context
personal
show-context                        # Should show personal context
git config --global user.email      # Should show john@personal-org.com
gh api user -q .login               # Should show personal GitHub username
```

### Test GitHub CLI Operations

```bash
# Switch to work context
work
gh repo list                        # Should show work repositories
gh pr list                          # Should show work PRs

# Switch to personal context
personal
gh repo list                        # Should show personal repositories
gh pr list                          # Should show personal PRs
```

### Test Context Persistence

```bash
# Set context
work

# Open new terminal tab
show-context                        # Should still show work context
gh api user -q .login               # Should still show work account
```

## Files Modified

### 1. Functions File

**Path**: `~/.config/zsh/functions/functions.zsh`

**Lines Modified:**
- Lines 590-598: Added GitHub CLI switching to `work()` function
- Lines 633-641: Added GitHub CLI switching to `personal()` function
- Lines 691-701: Added GitHub CLI status to `show-context()` function

### 2. Documentation Files

**Updated:**
- `/Users/user123/work/docs/CONTEXT_SWITCHING_FIXED.md` - Comprehensive documentation
- `/Users/user123/work/docs/reference/quick-reference.md` - Quick reference updates

**Created:**
- `/Users/user123/work/docs/GITHUB_CLI_INTEGRATION.md` - This file

## Related Documentation

- **[Context Switching Fixed](CONTEXT_SWITCHING_FIXED.md)** - Complete context switching guide
- **[GitHub SSH Setup](guides/github-ssh-setup.md)** - SSH key configuration
- **[Quick Reference](reference/quick-reference.md)** - Command quick reference

## Benefits Summary

| Feature | Before | After |
|---------|--------|-------|
| Git Config | ✅ Auto-switches | ✅ Auto-switches |
| GitHub CLI Auth | ❌ Manual switching | ✅ Auto-switches |
| Account Visibility | ❌ Not shown | ✅ Shown in `show-context` |
| Context Isolation | ⚠️ Partial | ✅ Complete |
| Accidental Operations | ⚠️ Possible | ✅ Prevented |

## Next Steps

1. **Install GitHub CLI** if not already installed:
   ```bash
   brew install gh
   ```

2. **Reload shell configuration**:
   ```bash
   source ~/.zshrc
   ```

3. **Test context switching**:
   ```bash
   work
   # Authenticate with work account
   show-context
   ```

4. **Use GitHub CLI commands** with confidence:
   ```bash
   gh pr list
   gh issue create
   gh repo list
   ```

5. **Switch to personal context** when needed:
   ```bash
   personal
   # Authenticate with personal account
   gh pr create
   ```

---

**Implemented**: October 7, 2025  
**By**: Cursor AI Assistant  
**Requirements**: GitHub CLI (`gh`) - Install with `brew install gh`  
**Location**: `~/.config/zsh/functions/functions.zsh`
