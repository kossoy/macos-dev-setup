# IDEs & Code Editors

Complete setup for JetBrains IDEs, Cursor, and Neovim.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Homebrew installed

## 1. JetBrains IDEs (Primary Development Environment)

### Installation via JetBrains Toolbox (Recommended)

**Why Toolbox over Homebrew?**
- ✅ Better update management
- ✅ Multiple IDE versions support
- ✅ Per-IDE rollback capability
- ✅ Integrated plugin management
- ✅ Easy CLI launcher configuration

```bash
# Download JetBrains Toolbox
# Visit: https://www.jetbrains.com/toolbox-app/

# Or install via Homebrew
brew install --cask jetbrains-toolbox

# Launch Toolbox
open -a "JetBrains Toolbox"
```

### Configure CLI Launchers

1. Open **JetBrains Toolbox** app
2. Click **Settings** (gear icon) → **Tools** → **Shell Scripts**
3. Change script location to: `/Users/<your-username>/work/bin`
4. Click **Generate**

Now you can open projects from terminal:

```bash
# Open projects from command line
idea ~/work/projects/work/my-java-project
pycharm ~/work/projects/personal/ml-project
webstorm ~/work/projects/work/frontend-app
datagrip  # Open DataGrip for database management
```

### Add to PATH

```bash
# Add work/bin to PATH (if not already done)
echo 'export PATH="$HOME/work/bin:$PATH"' >> ~/.config/zsh/paths/paths.zsh
source ~/.zshrc

# Verify launchers
ls ~/work/bin/ | grep -E "(idea|pycharm|webstorm|datagrip)"
```

### IDEs to Install

Install via JetBrains Toolbox:

- **IntelliJ IDEA Ultimate** - Java, Spring, Maven, Gradle
- **PyCharm Professional** - Python, Django, Flask, FastAPI, Data Science
- **WebStorm** - JavaScript/TypeScript, React, Vue, Angular, Node.js
- **DataGrip** - Database management (all databases)
- **GoLand** - Go development (optional)
- **CLion** - C/C++ development (optional)

## 2. Cursor (AI-Powered Editor)

Cursor is an AI-powered fork of VS Code, excellent for AI-assisted development.

```bash
# Install Cursor
brew install --cask cursor

# Verify installation
which cursor

# Open file in Cursor
cursor ~/work/docs/README.md

# Open project
cursor ~/work/projects/my-project
```

### Cursor Configuration

See the comprehensive [Cursor Setup Guide](../guides/cursor-setup.md) for:
- Window management (Agent vs Editor)
- Keyboard shortcuts
- Editor functions (`editapi`, `editzsh`, etc.)
- AI features

### Recommended Cursor Extensions

```bash
# Install via Cursor Extensions panel (Cmd+Shift+X):
# - Python
# - TypeScript and JavaScript
# - Tailwind CSS IntelliSense
# - Docker
# - GitLens
# - Prettier - Code formatter
# - ESLint
```

## 3. Neovim (Terminal Editor)

Neovim is a modern, extensible terminal editor.

```bash
# Install Neovim
brew install neovim

# Verify installation
nvim --version

# Create config directory
mkdir -p ~/.config/nvim
```

### Basic Neovim Configuration

See the comprehensive [Editor Configuration Guide](../guides/editor-configuration.md) for full setup.

Quick basic config:

```bash
# Create basic init.vim
cat > ~/.config/nvim/init.vim << 'EOF'
" Basic Settings
set number relativenumber
set tabstop=4 shiftwidth=4 expandtab
set autoindent smartindent
set mouse=a
set clipboard=unnamedplus
set termguicolors
set hlsearch incsearch
syntax on

" Key Mappings
let mapleader = " "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :wq<CR>
inoremap <C-s> <Esc>:w<CR>a
nnoremap <Esc> :noh<CR>

" Navigation between splits
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" File type specific indentation
autocmd FileType javascript,typescript,json,yaml setlocal ts=2 sw=2
EOF
```

### Neovim Quick Reference

```
MODES:
i           - Insert mode
Esc         - Normal mode
:           - Command mode

BASIC COMMANDS:
Space+w     - Save
Space+q     - Quit
Space+x     - Save and quit
:wq         - Save and quit (alternative)
:q!         - Quit without saving

NAVIGATION:
h,j,k,l     - Left, down, up, right
0           - Start of line
$           - End of line
gg          - Go to top
G           - Go to bottom

EDITING:
dd          - Delete line
yy          - Copy line
p           - Paste
u           - Undo
Ctrl+r      - Redo
```

## 4. Editor Environment Variables

These should already be set if you followed [System Setup](01-system-setup.md):

```bash
# Verify editor environment variables
echo $EDITOR    # Should show: nvim
echo $VISUAL    # Should show: cursor
echo $GIT_EDITOR # Should show: cursor --wait

# If not set, add to ~/.config/zsh/paths/paths.zsh:
export EDITOR="nvim"
export VISUAL="cursor"
export GIT_EDITOR="cursor --wait"
```

## 5. Editor Workflow

### When to Use Each Editor

#### JetBrains IDEs (Primary for Development)

**Use for:**
- Large projects
- Refactoring
- Debugging
- Database work (DataGrip)
- Framework-specific features (Spring, Django)

```bash
# Open project in appropriate IDE
idea ~/work/projects/work/backend-api
pycharm ~/work/projects/personal/ml-project
webstorm ~/work/projects/work/frontend-app
```

#### Cursor (AI-Assisted Development)

**Use for:**
- AI-assisted coding
- Quick prototyping
- Code exploration
- Learning new technologies
- Small projects

```bash
# Quick edit with helper functions
editapi        # Edit API keys
editzsh        # Edit .zshrc
edit some-file.txt

# Or directly
cursor ~/work/projects/my-project
```

#### Neovim (Terminal Editing)

**Use for:**
- Quick config edits
- SSH/remote editing
- Git commit messages
- Terminal-based workflows

```bash
# Quick edits
nvim ~/.zshrc
nvim README.md

# Git will use Cursor by default
# but nvim is good backup
```

## 6. JetBrains IDE Configuration

### Essential Plugins

Install via IDE: **File → Settings → Plugins**

**For All IDEs:**
- Key Promoter X (learn shortcuts)
- Rainbow Brackets
- GitToolBox
- String Manipulation
- Docker
- Kubernetes

**For PyCharm:**
- Python Security
- Jupyter
- Requirements
- Pylint

**For WebStorm:**
- Vue.js
- Angular
- React
- Tailwind CSS

**For IntelliJ IDEA:**
- Spring Assistant
- Lombok
- Maven Helper
- SonarLint

### Settings Sync

Enable settings sync across all JetBrains IDEs:

1. **File → Settings → Settings Sync**
2. Sign in with JetBrains account
3. Enable sync for: Plugins, Code Style, Keymaps, UI Settings

### Keyboard Shortcuts

Essential shortcuts to learn:

```
NAVIGATION:
Cmd+O          - Go to class
Cmd+Shift+O    - Go to file
Cmd+E          - Recent files
Cmd+B          - Go to declaration
Cmd+[/]        - Navigate back/forward

EDITING:
Cmd+D          - Duplicate line
Cmd+/          - Comment line
Cmd+Shift+Up/Down - Move line
Opt+Enter      - Show context actions
Cmd+Opt+L      - Reformat code

SEARCH:
Cmd+F          - Find in file
Cmd+R          - Replace in file
Cmd+Shift+F    - Find in project
Cmd+Shift+R    - Replace in project

REFACTORING:
Shift+F6       - Rename
Cmd+Opt+M      - Extract method
Cmd+Opt+V      - Extract variable
Cmd+Opt+C      - Extract constant

RUN/DEBUG:
Ctrl+R         - Run
Ctrl+D         - Debug
Cmd+F2         - Stop
Cmd+F8         - Toggle breakpoint
```

## 7. Troubleshooting

### JetBrains CLI Launchers Not Working

```bash
# Verify launchers exist
ls ~/work/bin/ | grep -E "(idea|pycharm)"

# If missing, regenerate via Toolbox
# Settings → Tools → Shell Scripts → Generate

# Verify PATH includes ~/work/bin
echo $PATH | grep work/bin

# Add if missing
echo 'export PATH="$HOME/work/bin:$PATH"' >> ~/.config/zsh/paths/paths.zsh
source ~/.zshrc
```

### IDE Won't Open

```bash
# Check if IDE is installed
ls /Applications/ | grep JetBrains

# Try opening from Applications
open -a "IntelliJ IDEA"

# Reset IDE caches (in IDE)
# File → Invalidate Caches → Invalidate and Restart
```

### Cursor Commands Not Working

See [Cursor Setup Guide](../guides/cursor-setup.md) for detailed troubleshooting.

```bash
# Verify cursor is installed
which cursor

# If not found, reinstall
brew reinstall cursor

# Verify editor functions exist
type editapi
```

## 8. Best Practices

### 1. Use Project-Specific Settings

Create `.idea/` or `.vscode/` folders with project settings:
- Code style
- Run configurations
- Inspection profiles

### 2. Gitignore IDE Files

```gitignore
# JetBrains
.idea/workspace.xml
.idea/tasks.xml
.idea/usage.statistics.xml
.idea/dictionaries/
.idea/shelf/

# VS Code / Cursor
.vscode/settings.json
.vscode/launch.json
```

But DO commit:
- `.idea/codeStyles/`
- `.idea/runConfigurations/`
- `.idea/inspectionProfiles/`

### 3. Learn One IDE Deeply

Master keyboard shortcuts for your primary IDE:
- IntelliJ for Java/Spring
- PyCharm for Python
- WebStorm for JavaScript/TypeScript

### 4. Use Consistent Code Style

Set up code style once, sync across all projects:
- EditorConfig for consistency
- Prettier/Black for auto-formatting
- ESLint/Pylint for linting

## Next Steps

Continue with:
- **[Git Configuration](10-git-configuration.md)** - Version control setup
- **[Cursor Setup Guide](../guides/cursor-setup.md)** - Detailed Cursor configuration
- **[Editor Configuration Guide](../guides/editor-configuration.md)** - Detailed editor setup

---

**Estimated Time**: 30 minutes  
**Difficulty**: Beginner  
**Last Updated**: October 5, 2025
