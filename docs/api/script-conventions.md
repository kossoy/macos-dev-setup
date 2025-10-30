# Script Development Conventions

Coding standards and best practices for scripts in the macos-dev-setup repository.

---

## Table of Contents

- [File Structure](#file-structure)
- [Naming Conventions](#naming-conventions)
- [Script Template](#script-template)
- [Error Handling](#error-handling)
- [Output and Logging](#output-and-logging)
- [Library Usage](#library-usage)
- [Documentation](#documentation)
- [Testing](#testing)
- [Security](#security)
- [Performance](#performance)

---

## File Structure

### Script Location

```
scripts/
├── lib/                    # Shared libraries
│   ├── errors.sh          # Error handling
│   ├── progress.sh        # Progress indicators
│   ├── parallel.sh        # Parallel execution
│   └── keychain.sh        # Keychain integration
├── launchagent-*.sh       # LaunchAgent management
├── vaultwarden-*.zsh      # Vaultwarden backup
├── wdu*.sh                # Disk usage
└── [other scripts]
```

### Deployment

Scripts are deployed to `~/work/scripts/` during bootstrap or setup.

---

## Naming Conventions

### Files

**Format:** `lowercase-with-hyphens.sh` or `.zsh`

**Good:**
```
launchagent-status.sh
vaultwarden-backup.zsh
api-key-manager.sh
```

**Bad:**
```
LaunchAgentStatus.sh
vaultwarden_backup.zsh
api-key-mgr.sh
```

### Functions

**Format:** `lowercase_with_underscores`

**Good:**
```bash
get_agent_status()
validate_plist()
show_dashboard()
```

**Bad:**
```bash
GetAgentStatus()
validatePlist()
showDashboard()
```

### Variables

**Format:**
- Local variables: `lowercase_with_underscores`
- Constants: `UPPERCASE_WITH_UNDERSCORES`
- Exported variables: `UPPERCASE_WITH_UNDERSCORES`

**Good:**
```bash
local service_name="api"
readonly MAX_RETRIES=3
export PROJECT_ROOT="$HOME/work/projects"
```

**Bad:**
```bash
local serviceName="api"
readonly maxRetries=3
export projectRoot="$HOME/work/projects"
```

---

## Script Template

### Basic Shell Script

```bash
#!/bin/bash
# =============================================================================
# SCRIPT NAME
# =============================================================================
# Brief description of what the script does
#
# Usage:
#   script-name.sh [options] <arguments>
#   script-name.sh --help
#
# =============================================================================

set -euo pipefail

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries if available
if [[ -f "$SCRIPT_DIR/lib/errors.sh" ]]; then
    source "$SCRIPT_DIR/lib/errors.sh"
    setup_error_traps
fi

# Constants
readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="1.0.0"

# Color codes
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

print_error() {
    echo -e "${COLOR_RED}✗${COLOR_RESET} $1" >&2
}

print_success() {
    echo -e "${COLOR_GREEN}✓${COLOR_RESET} $1"
}

print_info() {
    echo -e "${COLOR_BLUE}→${COLOR_RESET} $1"
}

print_warning() {
    echo -e "${COLOR_YELLOW}⚠${COLOR_RESET} $1"
}

# =============================================================================
# CORE FUNCTIONS
# =============================================================================

main_function() {
    local arg="$1"

    # Implementation here

    return 0
}

# =============================================================================
# USAGE
# =============================================================================

usage() {
    cat <<EOF
$SCRIPT_NAME - Brief description

Usage:
    $SCRIPT_NAME [options] <arguments>

Options:
    -h, --help      Show this help message
    -v, --version   Show version
    -d, --debug     Enable debug mode

Arguments:
    argument        Description of argument

Examples:
    $SCRIPT_NAME example-arg
    $SCRIPT_NAME --help

EOF
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--version)
                echo "$SCRIPT_NAME version $VERSION"
                exit 0
                ;;
            -d|--debug)
                set -x
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                # Positional argument
                main_function "$1"
                shift
                ;;
        esac
    done
}

main "$@"
```

### Interactive Script Template

```bash
#!/bin/bash
# =============================================================================
# INTERACTIVE SCRIPT NAME
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries
if [[ -f "$SCRIPT_DIR/lib/errors.sh" ]]; then
    source "$SCRIPT_DIR/lib/errors.sh"
    setup_error_traps
fi

if [[ -f "$SCRIPT_DIR/lib/progress.sh" ]]; then
    source "$SCRIPT_DIR/lib/progress.sh"
fi

# Color codes
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_RESET='\033[0m'

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

print_header() {
    echo -e "${COLOR_BLUE}========================================${COLOR_RESET}"
    echo -e "${COLOR_BLUE}   Script Title${COLOR_RESET}"
    echo -e "${COLOR_BLUE}========================================${COLOR_RESET}"
    echo
}

prompt() {
    local prompt_text="$1"
    local default="${2:-}"
    local response

    if [[ -n "$default" ]]; then
        read -r -p "${COLOR_CYAN}${prompt_text}${COLOR_RESET} [${default}]: " response
        echo "${response:-$default}"
    else
        read -r -p "${COLOR_CYAN}${prompt_text}${COLOR_RESET}: " response
        echo "$response"
    fi
}

confirm() {
    local message="$1"
    read -r -p "${COLOR_YELLOW}${message}${COLOR_RESET} (y/n): " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# =============================================================================
# MAIN INTERACTIVE FLOW
# =============================================================================

wizard() {
    print_header

    # Get user input
    local input
    input=$(prompt "Enter value")

    # Confirm action
    if ! confirm "Proceed with operation?"; then
        print_info "Cancelled"
        exit 0
    fi

    # Perform action
    spinner_start "Processing..."
    # ... work ...
    spinner_stop "success" "Complete!"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    wizard
}

main "$@"
```

---

## Error Handling

### Use Error Library

```bash
# Source error library
source "$SCRIPT_DIR/lib/errors.sh"

# Setup error traps
setup_error_traps

# Validate requirements
require_command git "Git is required"
require_file config.json "Configuration file missing"
require_var API_KEY "API_KEY environment variable required"

# Check operations
if ! some_command; then
    error_exit "Command failed"
fi

# Or use error_check
some_command
error_check $? "Command execution"
```

### Manual Error Handling

If not using error library:

```bash
# Enable strict error handling
set -euo pipefail

# Function-level error checking
function_name() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: function_name <arg>" >&2
        return 1
    fi

    if ! command -v required_tool >/dev/null 2>&1; then
        echo "Error: required_tool not found" >&2
        return 1
    fi

    return 0
}

# Cleanup on exit
cleanup() {
    # Cleanup code here
    rm -f /tmp/tempfile.$$
}
trap cleanup EXIT
```

### Error Messages

**Format:** `Error: <description>`

**Good:**
```bash
echo "Error: Configuration file not found: $config_file" >&2
echo "Error: Invalid argument count (expected 2, got $#)" >&2
```

**Bad:**
```bash
echo "config file missing"
echo "ERROR: INVALID ARGS!!!"
```

---

## Output and Logging

### Output Functions

```bash
# Use consistent output functions
print_error "Operation failed"      # Red ✗
print_success "Operation complete"  # Green ✓
print_warning "Be careful"          # Yellow ⚠
print_info "Processing..."          # Blue →
```

### Log Levels

```bash
# Error library supports logging
ERR_LOG_FILE="$HOME/Library/Logs/script-errors.log"

error "Critical error occurred"     # Logged + displayed
warn "This is a warning"            # Logged + displayed
info "Information message"          # Displayed only (unless verbose)
debug "Debug details"               # Only if ERR_VERBOSE=true
```

### Progress Indicators

```bash
# Use progress library
source "$SCRIPT_DIR/lib/progress.sh"

# Spinner for indeterminate operations
spinner_start "Downloading files..."
# ... operation ...
spinner_stop "success" "Download complete"

# Progress bar for determinate operations
start=$(date +%s)
for i in {1..100}; do
    progress_bar_eta $i 100 $start "Processing items"
    # ... work ...
done
```

---

## Library Usage

### Available Libraries

| Library | Purpose | Functions |
|---------|---------|-----------|
| `errors.sh` | Error handling | `error`, `warn`, `require_*`, `confirm`, `retry` |
| `progress.sh` | Progress UI | `spinner_*`, `progress_bar*`, `step_*` |
| `parallel.sh` | Parallel execution | `parallel_run`, `parallel_map`, `parallel_queue_*` |
| `keychain.sh` | Keychain access | `keychain_store`, `keychain_get`, `keychain_*` |

### Sourcing Libraries

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

# Source with error checking
if [[ -f "$LIB_DIR/errors.sh" ]]; then
    source "$LIB_DIR/errors.sh"
else
    echo "Error: Error library not found" >&2
    exit 1
fi

# Optional library
if [[ -f "$LIB_DIR/progress.sh" ]]; then
    source "$LIB_DIR/progress.sh"
fi
```

### Function Exports

If your script defines functions to be used by other scripts:

```bash
# Export functions
export -f my_function
export -f my_other_function

# Used in parallel execution
parallel_map my_function arg1 arg2 arg3
```

---

## Documentation

### Header Comment

Every script must have a header:

```bash
#!/bin/bash
# =============================================================================
# SCRIPT NAME
# =============================================================================
# Detailed description of what this script does, why it exists,
# and any important implementation notes.
#
# Usage:
#   script-name.sh [options] <arguments>
#   script-name.sh --help
#
# Options:
#   -h, --help     Show help message
#   -v, --verbose  Enable verbose output
#
# Examples:
#   script-name.sh input.txt
#   script-name.sh --verbose data.csv
#
# Dependencies:
#   - jq (for JSON processing)
#   - curl (for API calls)
#
# Environment Variables:
#   API_KEY - Required API key for service
#   DEBUG   - Enable debug mode if set
#
# Exit Codes:
#   0 - Success
#   1 - General error
#   2 - Invalid arguments
#
# =============================================================================
```

### Function Documentation

```bash
# Description of what function does
#
# Arguments:
#   $1 - First argument description
#   $2 - Second argument description
#
# Returns:
#   0 on success, 1 on failure
#
# Example:
#   my_function "arg1" "arg2"
my_function() {
    local arg1="$1"
    local arg2="$2"

    # Implementation
}
```

### Inline Comments

```bash
# Good: Explain WHY, not WHAT
# Retry connection because network may be temporarily unavailable
retry 3 5 curl "$API_ENDPOINT"

# Bad: Obvious comment
# Call curl
curl "$API_ENDPOINT"
```

---

## Testing

### Manual Testing

Before committing a script:

1. **Syntax check:**
   ```bash
   bash -n script-name.sh
   zsh -n script-name.zsh
   ```

2. **Run with test data:**
   ```bash
   ./script-name.sh --help
   ./script-name.sh test-arg
   ```

3. **Test error cases:**
   ```bash
   ./script-name.sh  # Missing arguments
   ./script-name.sh invalid-file.txt  # Bad input
   ```

4. **Test with libraries:**
   ```bash
   ERR_VERBOSE=true ./script-name.sh test-arg
   ```

### Test Coverage

Ensure you test:
- ✅ Valid inputs
- ✅ Invalid inputs
- ✅ Missing arguments
- ✅ Missing dependencies
- ✅ File not found scenarios
- ✅ Permission errors
- ✅ Network failures (if applicable)

---

## Security

### Credentials

**Never hardcode credentials:**

```bash
# Bad
API_KEY="sk-1234567890abcdef"

# Good - Use environment
API_KEY="${API_KEY:-}"
require_var API_KEY "API_KEY environment variable required"

# Good - Use keychain
API_KEY=$(keychain_get "service-name" "api-key")
```

### Input Validation

```bash
# Validate file paths
if [[ ! "$file_path" =~ ^[a-zA-Z0-9/_.-]+$ ]]; then
    error_exit "Invalid file path"
fi

# Sanitize user input
sanitized=$(echo "$user_input" | tr -cd '[:alnum:]._-')

# Avoid command injection
# Bad
eval "$user_command"

# Good
if [[ "$user_command" == "allowed-command" ]]; then
    allowed-command
fi
```

### File Permissions

```bash
# Set restrictive permissions on sensitive files
chmod 600 "$config_file"
chmod 700 "$script_file"

# Check permissions before reading
if [[ $(stat -f %p "$file") != *600 ]]; then
    warn "File permissions too open: $file"
fi
```

---

## Performance

### Minimize Subshells

```bash
# Bad - Multiple subshells
count=$(echo "$list" | wc -l)
first=$(echo "$list" | head -1)

# Good - Process once
while IFS= read -r line; do
    ((count++))
    [[ -z "$first" ]] && first="$line"
done <<< "$list"
```

### Use Built-ins

```bash
# Bad - External commands
basename "$file"
dirname "$file"

# Good - Parameter expansion
file_base="${file##*/}"
file_dir="${file%/*}"
```

### Parallel Execution

```bash
# Bad - Sequential
for file in *.txt; do
    process_file "$file"
done

# Good - Parallel
source "$SCRIPT_DIR/lib/parallel.sh"
parallel_auto  # Auto-detect CPU cores
parallel_map process_file *.txt
```

---

## Best Practices

### Portability

```bash
# Check OS before using OS-specific commands
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific
    open file.txt
else
    # Linux specific
    xdg-open file.txt
fi

# Check command availability
if command -v jq >/dev/null 2>&1; then
    # jq is available
    result=$(jq '.key' file.json)
else
    error_exit "jq is required but not installed"
fi
```

### Temporary Files

```bash
# Use process ID for unique temp files
temp_file="/tmp/script-name.$$.tmp"

# Always cleanup
cleanup() {
    rm -f "$temp_file"
}
trap cleanup EXIT

# Use mktemp for secure temp files
temp_dir=$(mktemp -d)
trap "rm -rf $temp_dir" EXIT
```

### Quoting

```bash
# Always quote variables
echo "$variable"
cd "$directory"
command "$arg1" "$arg2"

# Arrays
files=("file 1.txt" "file 2.txt")
for file in "${files[@]}"; do
    echo "$file"
done
```

### Default Values

```bash
# Use parameter expansion for defaults
value="${VAR:-default}"

# Use default for positional arguments
arg1="${1:-default_value}"

# Check if set
if [[ -z "${VAR:-}" ]]; then
    error_exit "VAR must be set"
fi
```

---

## Code Review Checklist

Before submitting a script:

- [ ] Header comment with usage, examples, dependencies
- [ ] Shebang line (`#!/bin/bash` or `#!/bin/zsh`)
- [ ] `set -euo pipefail` for error handling
- [ ] Consistent naming (lowercase-with-hyphens for files)
- [ ] Error handling for all operations
- [ ] Usage function with `--help` option
- [ ] Input validation
- [ ] Colored output for user feedback
- [ ] No hardcoded credentials
- [ ] Proper quoting of variables
- [ ] Cleanup on exit (temp files, etc.)
- [ ] Syntax check passed (`bash -n`)
- [ ] Tested with valid and invalid inputs
- [ ] File permissions set (755 for scripts)
- [ ] Libraries sourced correctly
- [ ] Functions documented
- [ ] Exit codes documented

---

## Examples

### Well-Structured Script

See `scripts/launchagent-status.sh`:
- ✅ Clear header documentation
- ✅ Error library integration
- ✅ Color-coded output
- ✅ Comprehensive help
- ✅ Input validation
- ✅ Proper error handling

### Library Integration

See `scripts/api-key-manager.sh`:
- ✅ Uses keychain library
- ✅ Uses error library functions
- ✅ Consistent error handling
- ✅ Interactive prompts
- ✅ Validation at every step

### Interactive Wizard

See `scripts/launchagent-create.sh`:
- ✅ Clear wizard flow
- ✅ Input prompts with defaults
- ✅ Confirmation before actions
- ✅ Progress feedback
- ✅ Helpful post-action messages

---

## Anti-Patterns

### Don't Do This

```bash
# No error handling
cd $dir
rm -rf *

# No quoting
for file in $files; do
    process $file
done

# Hardcoded paths
cd /Users/username/projects

# No validation
email=$1  # What if empty?

# Silent failures
command 2>/dev/null || true

# Unclear variable names
x=$1
tmp=/tmp/x

# No usage help
[[ $# -eq 0 ]] && exit 1
```

### Do This Instead

```bash
# Proper error handling
cd "$dir" || error_exit "Cannot cd to $dir"
confirm "Delete all files in $dir?" && rm -rf "${dir:?}"/*

# Proper quoting
for file in "${files[@]}"; do
    process "$file"
done

# Use $HOME
cd "$HOME/projects" || exit 1

# Validation
require_min_args $# 1 "Usage: $0 <email>"
email="$1"

# Handle failures
if ! command 2>/dev/null; then
    error "Command failed"
    return 1
fi

# Clear naming
user_email="$1"
temp_file="/tmp/script-name.$$.tmp"

# Proper usage
if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi
```

---

## See Also

- [Shell Functions API](shell-functions.md) - Function reference
- [Context API](context-api.md) - Context switching system
- `scripts/lib/errors.sh` - Error handling library
- `scripts/lib/progress.sh` - Progress indicators library
- `scripts/lib/parallel.sh` - Parallel execution library
- `scripts/lib/keychain.sh` - Keychain integration library
