# Git Configuration & Version Control

Complete Git setup, configuration, and version control tools.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Git installed (via Homebrew or Xcode Command Line Tools)

## 1. Git Global Configuration

### User Information

```bash
# Set your name and email
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify configuration
git config --global user.name
git config --global user.email

# For context-aware setup, use the context functions
work        # Sets: John Doe <john.doe@company.com>
personal    # Sets: John Doe <john@personal-org.com>
```

### Default Branch

```bash
# Set default branch name to 'main'
git config --global init.defaultBranch main

# Verify
git config --global init.defaultBranch
```

### Editor Configuration

```bash
# Set Cursor as default editor for Git
git config --global core.editor "cursor --wait"

# Or use Neovim
git config --global core.editor "nvim"

# Verify
git config --global core.editor
```

### Useful Global Settings

```bash
# Enable color output
git config --global color.ui auto

# Set default pull behavior (rebase instead of merge)
git config --global pull.rebase true

# Enable helpful aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'

# Better diff algorithm
git config --global diff.algorithm histogram

# Reuse recorded resolution (for merge conflicts)
git config --global rerere.enabled true

# Cache credentials (macOS Keychain)
git config --global credential.helper osxkeychain
```

## 2. Useful Git Aliases

Add these to your shell configuration (already included if you ran integration script):

```bash
# ~/.config/zsh/aliases/aliases.zsh
alias gs="git status"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gp="git push"
alias gpl="git pull"
alias gf="git fetch"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gb="git branch"
alias gbd="git branch -d"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline"
alias glog="git log --oneline --graph --decorate --all"
alias gst="git stash"
alias gstp="git stash pop"
alias gsta="git stash apply"
alias greset="git reset --hard HEAD"
alias gclean="git clean -fd"
```

## 3. GitHub CLI

GitHub CLI provides command-line access to GitHub features.

```bash
# Install GitHub CLI
brew install gh

# Authenticate with GitHub
gh auth login

# Follow prompts:
# - Choose GitHub.com
# - Choose HTTPS
# - Authenticate via web browser

# Verify authentication
gh auth status

# Test
gh repo list
```

### Common GitHub CLI Commands

```bash
# Repository operations
gh repo create my-repo --public
gh repo clone username/repo
gh repo view
gh repo fork

# Pull requests
gh pr create
gh pr list
gh pr view 123
gh pr checkout 123
gh pr merge 123

# Issues
gh issue create
gh issue list
gh issue view 42
gh issue close 42

# Workflows (GitHub Actions)
gh workflow list
gh workflow run workflow-name
gh run list
gh run view

# Gists
gh gist create file.txt
gh gist list
gh gist view gist-id

# SSH keys
gh ssh-key add ~/.ssh/id_ed25519.pub
gh ssh-key list
```

## 4. SSH Key Setup

### Generate SSH Key

```bash
# Generate new SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Press Enter to accept default location (~/.ssh/id_ed25519)
# Enter passphrase (recommended) or leave empty

# Start SSH agent
eval "$(ssh-agent -s)"

# Add SSH key to agent
ssh-add ~/.ssh/id_ed25519

# For macOS, also add to Keychain
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### Add SSH Key to GitHub

```bash
# Copy SSH public key to clipboard
cat ~/.ssh/id_ed25519.pub | pbcopy

# Or use GitHub CLI
gh ssh-key add ~/.ssh/id_ed25519.pub --title "MacBook Pro M1"

# Or manually:
# 1. Go to GitHub.com → Settings → SSH and GPG keys
# 2. Click "New SSH key"
# 3. Paste key and save

# Test SSH connection
ssh -T git@github.com
# Should see: "Hi username! You've successfully authenticated..."
```

### SSH Config

Create `~/.ssh/config` for easier SSH management:

```bash
cat > ~/.ssh/config << 'EOF'
# GitHub
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  AddKeysToAgent yes
  UseKeychain yes

# Work GitHub Enterprise (if applicable)
Host github.company.com
  HostName github.company.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work
  AddKeysToAgent yes
  UseKeychain yes
EOF

chmod 600 ~/.ssh/config
```

## 5. Git GUI Tools

### Sourcetree (Recommended)

```bash
# Install Sourcetree
brew install --cask sourcetree

# Launch
open -a Sourcetree
```

### GitKraken

```bash
# Install GitKraken
brew install --cask gitkraken

# Launch
open -a GitKraken
```

### JetBrains Built-in Git

All JetBrains IDEs have excellent built-in Git support:
- Visual diff and merge tools
- Interactive rebase
- Branch management
- Commit history visualization
- Blame annotations

## 6. .gitignore Templates

### Global .gitignore

Create a global gitignore for OS/IDE files:

```bash
# Create global gitignore
cat > ~/.gitignore_global << 'EOF'
# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# IDEs
.idea/
.vscode/
*.swp
*.swo
*~

# Environment
.env
.env.local
.env.*.local

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
EOF

# Configure Git to use it
git config --global core.excludesfile ~/.gitignore_global
```

### Project-Specific .gitignore

```bash
# Node.js project
cat > .gitignore << 'EOF'
node_modules/
dist/
build/
.env
.env.local
*.log
EOF

# Python project
cat > .gitignore << 'EOF'
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
ENV/
.env
*.egg-info/
dist/
build/
EOF

# Java project
cat > .gitignore << 'EOF'
target/
*.class
*.jar
*.war
*.ear
.idea/
.settings/
.classpath
.project
EOF
```

## 7. Advanced Git Workflows

### Feature Branch Workflow

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "Add feature"

# Push to remote
git push -u origin feature/my-feature

# Create pull request
gh pr create --title "Add my feature" --body "Description"

# After PR is merged, update main
git checkout main
git pull
git branch -d feature/my-feature
```

### Gitflow Workflow

```bash
# Install git-flow
brew install git-flow

# Initialize in repository
git flow init

# Start new feature
git flow feature start my-feature

# Finish feature
git flow feature finish my-feature

# Start release
git flow release start 1.0.0

# Finish release
git flow release finish 1.0.0

# Start hotfix
git flow hotfix start 1.0.1

# Finish hotfix
git flow hotfix finish 1.0.1
```

### Rebase Workflow

```bash
# Update feature branch with latest main
git checkout feature-branch
git fetch origin
git rebase origin/main

# If conflicts, resolve them
git add resolved-file
git rebase --continue

# Or abort rebase
git rebase --abort

# Force push (only on your feature branch!)
git push --force-with-lease
```

## 8. Useful Git Commands

### Viewing History

```bash
# View commits
git log
git log --oneline
git log --graph --decorate --all
git log --oneline --author="Your Name"
git log --since="2 weeks ago"

# View file history
git log -- path/to/file
git log -p path/to/file  # Show diffs

# View who changed what
git blame path/to/file

# Search commits
git log --grep="keyword"
git log -S "code snippet"  # Search code changes
```

### Undoing Changes

```bash
# Discard local changes
git checkout -- file.txt
git restore file.txt  # Git 2.23+

# Unstage file
git reset HEAD file.txt
git restore --staged file.txt  # Git 2.23+

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Undo commits but keep files staged
git reset --mixed HEAD~2

# Revert commit (creates new commit)
git revert abc123

# Amend last commit
git commit --amend
git commit --amend --no-edit  # Keep commit message
```

### Stashing Changes

```bash
# Stash changes
git stash
git stash save "Work in progress"

# List stashes
git stash list

# Apply stash
git stash apply
git stash apply stash@{2}

# Apply and remove stash
git stash pop

# Create branch from stash
git stash branch feature-branch

# Drop stash
git stash drop stash@{0}

# Clear all stashes
git stash clear
```

### Working with Remotes

```bash
# View remotes
git remote -v

# Add remote
git remote add upstream https://github.com/original/repo.git

# Fetch from remote
git fetch origin
git fetch --all

# Pull with rebase
git pull --rebase origin main

# Push to remote
git push origin main
git push -u origin feature-branch

# Delete remote branch
git push origin --delete feature-branch

# Update remote URL
git remote set-url origin git@github.com:username/repo.git
```

### Cleaning Up

```bash
# Remove untracked files (dry run)
git clean -n

# Remove untracked files
git clean -f

# Remove untracked files and directories
git clean -fd

# Remove ignored files too
git clean -fdx

# Prune remote tracking branches
git fetch --prune
git remote prune origin
```

## 9. Git Hooks

Git hooks are scripts that run automatically on certain Git events.

```bash
# Hooks location
ls -la .git/hooks/

# Pre-commit hook example (run tests before commit)
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Run tests
npm test

# If tests fail, abort commit
if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi
EOF

chmod +x .git/hooks/pre-commit

# Pre-push hook example (run linter)
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

# Run linter
npm run lint

if [ $? -ne 0 ]; then
    echo "Linting failed. Push aborted."
    exit 1
fi
EOF

chmod +x .git/hooks/pre-push
```

### Husky (Git Hooks Manager)

```bash
# Install husky
npm install --save-dev husky

# Initialize husky
npx husky install

# Add pre-commit hook
npx husky add .husky/pre-commit "npm test"

# Add commit-msg hook (for conventional commits)
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit "$1"'
```

## 10. Troubleshooting

### Conflicts

```bash
# View conflicted files
git status

# Resolve conflicts in editor, then:
git add resolved-file
git commit

# Or use merge tool
git mergetool

# Abort merge
git merge --abort

# Abort rebase
git rebase --abort
```

### Accidentally Deleted Branch

```bash
# View reflog
git reflog

# Find commit hash, then restore branch
git checkout -b restored-branch abc123
```

### Accidentally Committed to Wrong Branch

```bash
# Move commit to correct branch
git log  # Find commit hash
git checkout correct-branch
git cherry-pick abc123

# Remove from wrong branch
git checkout wrong-branch
git reset --hard HEAD~1
```

## 11. Best Practices

1. **Commit Often**: Small, focused commits are better than large ones
2. **Write Good Commit Messages**: 
   - First line: short summary (50 chars)
   - Blank line
   - Detailed explanation if needed
3. **Use Branches**: Never commit directly to main
4. **Pull Before Push**: Always fetch/pull before pushing
5. **Review Before Commit**: Use `git diff --staged`
6. **Use .gitignore**: Don't commit build artifacts or sensitive data
7. **Test Before Commit**: Run tests in pre-commit hook
8. **Use SSH**: More secure than HTTPS

## Next Steps

Continue with:
- **[API Development](11-api-development.md)** - Testing tools setup
- **[IDEs & Editors](09-ides-editors.md)** - Git integration in IDEs

---

**Estimated Time**: 20 minutes  
**Difficulty**: Beginner to Intermediate  
**Last Updated**: October 5, 2025
