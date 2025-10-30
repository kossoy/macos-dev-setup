# Shell Functions API Reference

Complete reference for all custom shell functions in `config/zsh/config/functions.zsh`.

---

## Directory Utilities

### `mkcd`

Create a directory and navigate to it in one command.

**Syntax:**
```bash
mkcd <directory>
```

**Parameters:**
- `directory` - Path to directory to create

**Returns:**
- `0` on success
- `1` if directory creation or navigation fails

**Example:**
```bash
mkcd ~/projects/new-project
# Creates ~/projects/new-project and cd's into it
```

**Error Handling:**
- Validates arguments are provided
- Creates parent directories if needed (`-p`)
- Reports if directory creation fails
- Reports if cd fails

---

## Process Utilities

### `psme`

Find processes by name (case-insensitive).

**Syntax:**
```bash
psme <process_name>
```

**Parameters:**
- `process_name` - Pattern to search for in process list

**Returns:**
- `0` on success
- `1` if no arguments provided

**Example:**
```bash
psme python
# Shows all Python processes

psme chrome
# Shows all Chrome processes
```

**Output:**
Displays matching processes with full `ps aux` information (USER, PID, CPU, MEM, etc.)

---

### `psmes`

Get process IDs by name (returns PIDs only).

**Syntax:**
```bash
psmes <process_name>
```

**Parameters:**
- `process_name` - Pattern to search for

**Returns:**
- `0` on success
- `1` if no arguments provided

**Example:**
```bash
psmes node
# Returns: 12345 67890

# Use in scripts
for pid in $(psmes python); do
    echo "Found Python process: $pid"
done
```

**Output:**
Space-separated list of PIDs matching the pattern.

---

### `slay`

Kill processes by name with optional signal.

**Syntax:**
```bash
slay <process_name> [signal]
```

**Parameters:**
- `process_name` - Pattern to match processes
- `signal` - Signal to send (default: `-15` / SIGTERM)
  - `-9` - SIGKILL (force kill)
  - `-15` - SIGTERM (graceful termination)
  - `-1` - SIGHUP (reload config)

**Returns:**
- `0` on success
- `1` if no processes found or invalid arguments

**Example:**
```bash
# Gracefully terminate Python processes
slay python

# Force kill Chrome
slay chrome -9

# Reload nginx
slay nginx -1
```

**Safety:**
- Shows PIDs being killed before taking action
- Confirms no processes found if pattern doesn't match

---

## Kubernetes Utilities

### `get_full_pod_name`

Get full Kubernetes pod name from partial match.

**Syntax:**
```bash
get_full_pod_name <pod_pattern>
```

**Parameters:**
- `pod_pattern` - Partial pod name to match

**Returns:**
- `0` and prints pod name on success
- `1` if no pod found

**Example:**
```bash
# Find pod starting with "api"
pod=$(get_full_pod_name api)
echo "$pod"
# Output: api-deployment-7d8f6b9c-4xj2k
```

**Behavior:**
- Returns first matching pod only
- Uses `kubectl get pods`
- Case-sensitive matching

---

### `pod_connect`

Connect to a Kubernetes pod's shell.

**Syntax:**
```bash
pod_connect <pod_pattern>
```

**Parameters:**
- `pod_pattern` - Partial pod name to match

**Returns:**
- `0` on successful connection
- `1` if pod not found

**Example:**
```bash
pod_connect api
# Connecting to: api-deployment-7d8f6b9c-4xj2k
# Opens interactive shell in pod
```

**Behavior:**
- Shows pod name in green before connecting
- Uses `sh` shell (works with most containers)
- Interactive mode (`-it`)

---

### `klogs`

Get logs from a Kubernetes pod.

**Syntax:**
```bash
klogs <pod_pattern> [kubectl log options]
```

**Parameters:**
- `pod_pattern` - Partial pod name
- Additional options passed to `kubectl logs`

**Returns:**
- `0` on success
- `1` if pod not found

**Example:**
```bash
# Tail logs
klogs api -f

# Get last 100 lines
klogs api --tail=100

# Logs from all containers
klogs api --all-containers
```

**Behavior:**
- Automatically includes all containers (`--all-containers=true`)
- Supports all `kubectl logs` options
- Shows pod name before streaming logs

---

### `dscontext`

Switch Kubernetes context to datascience namespace.

**Syntax:**
```bash
dscontext
```

**Returns:**
- `0` on success
- `1` if context cannot be determined

**Example:**
```bash
dscontext
# Set namespace to 'datascience' for context: my-cluster
```

**Behavior:**
- Gets current context
- Sets namespace to `datascience`
- Confirms change with message

---

## Network Utilities

### `listening`

List processes listening on TCP ports.

**Syntax:**
```bash
listening [pattern]
```

**Parameters:**
- `pattern` - Optional filter pattern (case-insensitive)

**Returns:**
- `0` on success (requires sudo)

**Example:**
```bash
# List all listening ports
listening

# Find processes listening on port 3000
listening 3000

# Find Node.js servers
listening node
```

**Output:**
```
COMMAND  PID  USER  FD  TYPE DEVICE SIZE/OFF NODE NAME
node     1234 user  20u IPv4  12345 0t0     TCP *:3000 (LISTEN)
```

**Requirements:**
- Requires `sudo` (uses `lsof`)
- macOS/Linux compatible

---

## System Utilities

### `ramdisk`

Create a RAM disk (macOS only).

**Syntax:**
```bash
ramdisk [size_mb]
```

**Parameters:**
- `size_mb` - Size in megabytes (default: 2048 = 2GB)

**Returns:**
- `0` on success
- `1` on failure or non-macOS system

**Example:**
```bash
# Create 2GB RAM disk (default)
ramdisk

# Create 4GB RAM disk
ramdisk 4096

# Create 512MB RAM disk
ramdisk 512
```

**Output:**
```
Initialized /dev/disk4 as a 2 GB case-insensitive HFS Plus volume
Created RAM disk: /dev/disk4
```

**Behavior:**
- Formats as HFS+
- Names volume "RAM Disk"
- Mounts automatically
- **Data is lost on restart/shutdown**

**Platform:**
macOS only

---

### `nasmount`

Mount NAS volumes using AppleScript.

**Syntax:**
```bash
nasmount
```

**Returns:**
- `0` on success
- `1` if script not found or non-macOS

**Example:**
```bash
nasmount
```

**Requirements:**
- macOS only
- Requires `CheckVolumes.scpt` at `~/work/bin/`

**Platform:**
macOS only

---

## Development Utilities

### `project_setup`

Quick project scaffolding.

**Syntax:**
```bash
project_setup <project_name>
```

**Parameters:**
- `project_name` - Name of project to create

**Returns:**
- `0` on success
- `1` if no project name provided

**Example:**
```bash
project_setup my-new-app
# Creates:
# my-new-app/
# ├── src/
# ├── tests/
# ├── docs/
# ├── scripts/
# ├── README.md
# ├── .gitignore
# └── .git/
```

**Behavior:**
- Creates project directory and cd's into it
- Initializes git repository
- Creates standard directory structure
- Creates README.md and .gitignore

---

## Archive Utilities

### `extract`

Universal archive extraction.

**Syntax:**
```bash
extract <archive_file>
```

**Parameters:**
- `archive_file` - Path to archive

**Returns:**
- `0` on success
- `1` if file not found or unsupported format

**Supported Formats:**
- `.tar.bz2` - tar + bzip2
- `.tar.gz`, `.tgz` - tar + gzip
- `.tar` - tar only
- `.bz2` - bzip2
- `.gz` - gzip
- `.zip` - zip
- `.rar` - rar (requires `unrar`)
- `.7z` - 7zip (requires `7z`)
- `.Z` - compress

**Example:**
```bash
extract archive.tar.gz
extract package.zip
extract data.7z
```

---

## File Utilities

### `backup`

Create timestamped backup of a file.

**Syntax:**
```bash
backup <file>
```

**Parameters:**
- `file` - File to backup

**Returns:**
- `0` on success
- `1` if file not found

**Example:**
```bash
backup config.json
# Creates: config.json.backup.20251031_004500
```

**Output:**
```
Backup created: config.json.backup.20251031_004500
```

**Behavior:**
- Appends `.backup.YYYYMMDD_HHMMSS` to filename
- Preserves original file
- Shows backup filename

---

## Debugging Utilities

### `show_function`

Display function definition.

**Syntax:**
```bash
show_function <function_name>
```

**Parameters:**
- `function_name` - Name of function to display

**Returns:**
- `0` if function found
- `1` if function doesn't exist

**Example:**
```bash
show_function mkcd
# Output:
# mkcd () {
#     if [[ $# -eq 0 ]]
#     then
#         echo "Usage: mkcd <directory>" >&2
#         return 1
#     fi
#     ...
# }
```

---

### `list_functions`

List all custom functions.

**Syntax:**
```bash
list_functions
```

**Returns:**
- `0` always

**Example:**
```bash
list_functions
# Output:
# Custom functions:
# backup
# dscontext
# extract
# get_full_pod_name
# klogs
# listening
# ...
```

**Output:**
Sorted alphabetical list of all defined functions.

---

## Context Switching Functions

### `work`

Switch to work development context.

**Syntax:**
```bash
work
```

**Returns:**
- `0` on success
- `1` if context file creation fails

**What It Does:**

1. **Sets Environment Variables:**
   - `WORK_CONTEXT` - Work organization identifier
   - `PROJECT_ROOT` - `~/work/projects/work`
   - `CONFIG_ROOT` - `~/work/configs/work`
   - `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` - Work database config

2. **Updates Git Configuration:**
   - Sets `user.email` to work email
   - Verifies email was set correctly

3. **Manages SSH Keys:**
   - Loads personal SSH key (`id_ed25519`)
   - Loads work SSH key (`id_ed25519_concur`)
   - Reports load status

4. **Switches Default Browser:**
   - Changes to work browser (configurable)
   - Waits for user confirmation
   - Polls for settings update (max 10s)

5. **VPN Connectivity:**
   - Checks GitHub Enterprise connectivity
   - Prompts to connect VPN if needed
   - Waits up to 5 minutes for VPN connection

6. **GitHub CLI Authentication:**
   - Verifies authentication to work GitHub instance
   - Checks username matches expected
   - Provides login command if not authenticated

7. **Creates Context File:**
   - Writes `~/.config/zsh/contexts/current.zsh`
   - Atomic write with validation
   - 600 permissions

8. **Changes Directory:**
   - cd to `PROJECT_ROOT`

**Example:**
```bash
work
# 🏢 Switching to Work work context...
#
#    ✅ Git email: work@company.com
#    🔑 Managing SSH keys...
#    ✅ Personal SSH key already loaded
#    ✅ Work SSH key loaded
#    ✅ Browser already set to correct default
#
#    🔍 Checking connectivity to github.company.com...
#    ✅ VPN connected - github.company.com is reachable
#
#    🔍 Checking GitHub CLI authentication...
#    ✅ Authenticated to github.company.com
#    ✅ Logged in as: workuser
#
#    ✅ Switched to Work work context
#    📂 Projects: ~/work/projects/work
#    ⚙️  Config: ~/work/configs/work
#    🗄️  Database: localhost:5433/work_dev
```

**Configuration:**
Uses these environment variables (set in `config/zsh/private/api-keys.zsh`):
- `WORK_CONTEXT_NAME` - Display name
- `WORK_ORG` - Organization identifier
- `WORK_GIT_EMAIL` - Git commit email
- `WORK_BROWSER` - Browser identifier
- `WORK_GITHUB_HOST` - GitHub hostname
- `WORK_GH_USER` - Expected GitHub username
- `WORK_DB_HOST`, `WORK_DB_PORT`, `WORK_DB_NAME`, `WORK_DB_USER` - Database config

---

### `personal`

Switch to personal development context.

**Syntax:**
```bash
personal
```

**Returns:**
- `0` on success
- `1` if context file creation fails

**What It Does:**

Same as `work()` but for personal context:

1. **Sets Environment Variables:**
   - `WORK_CONTEXT` - Personal organization identifier
   - `PROJECT_ROOT` - `~/work/projects/personal`
   - `CONFIG_ROOT` - `~/work/configs/personal`
   - `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` - Personal database config

2. **Updates Git Configuration:**
   - Sets `user.email` to personal email

3. **Manages SSH Keys:**
   - **Unloads work SSH key** (`id_ed25519_concur`)
   - Ensures personal SSH key loaded (`id_ed25519`)

4. **Switches Default Browser:**
   - Changes to personal browser (configurable)

5. **GitHub CLI Authentication:**
   - Verifies authentication to github.com
   - Checks username matches expected

6. **Creates Context File**

7. **Changes Directory:**
   - cd to `PROJECT_ROOT`

**Example:**
```bash
personal
# 🏠 Switching to Personal personal context...
#
#    ✅ Git email: personal@email.com
#    🔑 Managing SSH keys...
#    ✅ Work SSH key unloaded
#    ✅ Personal SSH key already loaded
#    ✅ Browser already set to correct default
#
#    🔍 Checking GitHub CLI authentication...
#    ✅ Authenticated to github.com
#    ✅ Logged in as: personaluser
#
#    ✅ Switched to Personal personal context
#    📂 Projects: ~/work/projects/personal
#    ⚙️  Config: ~/work/configs/personal
#    🗄️  Database: localhost:5432/personal_dev
```

**Configuration:**
Uses these environment variables:
- `PERSONAL_CONTEXT_NAME` - Display name
- `PERSONAL_ORG` - Organization identifier
- `PERSONAL_GIT_EMAIL` - Git commit email
- `PERSONAL_BROWSER` - Browser identifier
- `PERSONAL_GITHUB_HOST` - GitHub hostname (usually github.com)
- `PERSONAL_GH_USER` - Expected GitHub username
- `PERSONAL_DB_HOST`, `PERSONAL_DB_PORT`, `PERSONAL_DB_NAME`, `PERSONAL_DB_USER`

---

### `show-context`

Display current development context information.

**Syntax:**
```bash
show-context
```

**Returns:**
- `0` always

**Example:**
```bash
show-context
# 📋 Current Development Context
# ==================================
#
# 📍 Context: Work
#
# 🔧 Git Configuration:
#    Name:  John Doe
#    Email: john.doe@company.com
#
# 🔐 GitHub CLI:
#    ✅ Authenticated to github.company.com
#    Logged in as: jdoe
#
# 🌐 Browser:
#    Brave Browser
#
# 📂 Paths:
#    Projects: ~/work/projects/work
#    Config:   ~/work/configs/work
#    Current:  ~/work/projects/work/myapp
#
# 🗄️  Database:
#    Host:     localhost
#    Port:     5433
#    Database: work_dev
#    User:     work_user
#
# 🔑 SSH Keys Loaded:
#    ✓ 256 SHA256:... id_ed25519 (ED25519)
#    ✓ 256 SHA256:... id_ed25519_concur (ED25519)
```

**Information Displayed:**
- Current context (Work/Personal/Unknown)
- Git name and email
- GitHub CLI authentication status and username
- Default browser
- Project and config paths
- Current working directory
- Database configuration
- Loaded SSH keys

**Behavior:**
- Only checks GitHub for current context (not both)
- Requires VPN for work context GitHub checks
- Detects browser using Python3
- Maps bundle IDs to friendly names

---

## Internal Helper Functions

### `_get_default_browser`

Get current default browser bundle ID.

**Syntax:**
```bash
_get_default_browser
```

**Returns:**
- `0` and prints bundle ID on success
- `1` if Python3 not available or plist read fails

**Output:**
```
com.brave.browser
```

**Behavior:**
- Uses Python3 to read LaunchServices plist
- Retries up to 3 times with 0.1s delay
- Returns empty string on failure

**Note:**
Internal function used by `work()`, `personal()`, and `show-context()`. Not intended for direct use.

---

## Summary Table

| Function | Category | Purpose |
|----------|----------|---------|
| `mkcd` | Directory | Create and cd to directory |
| `psme` | Process | Find processes by name |
| `psmes` | Process | Get PIDs by name |
| `slay` | Process | Kill processes by name |
| `get_full_pod_name` | Kubernetes | Get full pod name |
| `pod_connect` | Kubernetes | Connect to pod shell |
| `klogs` | Kubernetes | View pod logs |
| `dscontext` | Kubernetes | Switch to datascience namespace |
| `listening` | Network | List listening ports |
| `ramdisk` | System | Create RAM disk (macOS) |
| `nasmount` | System | Mount NAS volumes (macOS) |
| `project_setup` | Development | Scaffold new project |
| `extract` | Archive | Extract various archives |
| `backup` | File | Create timestamped backup |
| `show_function` | Debug | Show function definition |
| `list_functions` | Debug | List all functions |
| `work` | Context | Switch to work context |
| `personal` | Context | Switch to personal context |
| `show-context` | Context | Display current context |

---

## Usage Patterns

### Chaining Functions

```bash
# Create project and set up
mkcd ~/projects/new-app && project_setup new-app

# Kill and restart process
slay node && npm start

# Connect to pod and check logs
pod_connect api
klogs api -f
```

### Using in Scripts

```bash
#!/bin/bash
source ~/.zshrc

# Ensure in work context
work

# Work with Kubernetes
POD=$(get_full_pod_name api)
if [[ -n "$POD" ]]; then
    kubectl exec "$POD" -- /app/deploy.sh
fi
```

### Process Management

```bash
# Find all Python processes
psme python

# Get PIDs for scripting
PIDS=$(psmes python)
for pid in $PIDS; do
    echo "Checking process $pid..."
done

# Graceful shutdown
slay myapp -15
sleep 5
# Force if still running
slay myapp -9
```

---

## Error Handling

All functions follow consistent error handling:

1. **Argument Validation:**
   - Check required arguments
   - Print usage to stderr if invalid
   - Return 1

2. **Command Availability:**
   - Check required commands exist
   - Provide helpful error messages
   - Return 1 if missing

3. **Error Reporting:**
   - Use stderr for errors
   - Use colored output for visibility
   - Provide actionable suggestions

4. **Return Codes:**
   - `0` on success
   - `1` on failure

---

## Platform Compatibility

| Function | macOS | Linux |
|----------|-------|-------|
| mkcd | ✅ | ✅ |
| psme, psmes, slay | ✅ | ✅ |
| Kubernetes functions | ✅ | ✅ |
| listening | ✅ | ✅ |
| ramdisk | ✅ | ❌ |
| nasmount | ✅ | ❌ |
| project_setup | ✅ | ✅ |
| extract | ✅ | ✅ |
| backup | ✅ | ✅ |
| Debug functions | ✅ | ✅ |
| Context functions | ✅ | ✅* |

*Context functions work on Linux but browser switching requires macOS

---

## Configuration

Context switching functions require configuration in `config/zsh/private/api-keys.zsh`:

```bash
# Work Context
export WORK_CONTEXT_NAME="SAP Concur"
export WORK_ORG="CONCUR"
export WORK_GIT_EMAIL="work@company.com"
export WORK_BROWSER="browser"  # or "chrome", "safari", etc.
export WORK_GITHUB_HOST="github.company.com"
export WORK_GH_USER="workusername"
export WORK_DB_HOST="localhost"
export WORK_DB_PORT="5433"
export WORK_DB_NAME="work_dev"
export WORK_DB_USER="work_user"

# Personal Context
export PERSONAL_CONTEXT_NAME="Personal"
export PERSONAL_ORG="PERSONAL"
export PERSONAL_GIT_EMAIL="personal@email.com"
export PERSONAL_BROWSER="beta"
export PERSONAL_GITHUB_HOST="github.com"
export PERSONAL_GH_USER="personaluser"
export PERSONAL_DB_HOST="localhost"
export PERSONAL_DB_PORT="5432"
export PERSONAL_DB_NAME="personal_dev"
export PERSONAL_DB_USER="personal_user"
```

---

## See Also

- [Context API Documentation](context-api.md) - Detailed context switching system
- [Script Conventions](script-conventions.md) - Coding standards for scripts
- `config/zsh/config/functions.zsh` - Source code
- `config/zsh/config/aliases.zsh` - Related aliases
