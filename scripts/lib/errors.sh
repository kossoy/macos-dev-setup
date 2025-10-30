#!/bin/bash
# =============================================================================
# ERROR HANDLING LIBRARY
# =============================================================================
# Comprehensive error handling with user-friendly messages and logging
#
# Usage:
#   source "$HOME/work/scripts/lib/errors.sh"
#   error_check $? "Failed to create file"
#   error_exit "Critical error occurred"
#   warn "This is a warning message"
#
# =============================================================================

# Color codes for output
readonly ERR_COLOR_RED='\033[0;31m'
readonly ERR_COLOR_GREEN='\033[0;32m'
readonly ERR_COLOR_YELLOW='\033[1;33m'
readonly ERR_COLOR_BLUE='\033[0;34m'
readonly ERR_COLOR_CYAN='\033[0;36m'
readonly ERR_COLOR_MAGENTA='\033[0;35m'
readonly ERR_COLOR_RESET='\033[0m'

# Error handling configuration
ERR_LOG_FILE="${ERR_LOG_FILE:-$HOME/Library/Logs/script-errors.log}"
ERR_VERBOSE="${ERR_VERBOSE:-false}"
ERR_STACK_TRACE="${ERR_STACK_TRACE:-false}"

# =============================================================================
# INTERNAL HELPER FUNCTIONS
# =============================================================================

# Get current timestamp
_err_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Log to file
_err_log() {
    local level="$1"
    shift
    local message="$*"

    # Create log directory if needed
    local log_dir
    log_dir="$(dirname "$ERR_LOG_FILE")"
    if [[ ! -d "$log_dir" ]]; then
        mkdir -p "$log_dir" 2>/dev/null || true
    fi

    # Write to log file
    if [[ -w "$log_dir" || -w "$ERR_LOG_FILE" ]]; then
        echo "[$(\_err_timestamp)] [$level] $message" >> "$ERR_LOG_FILE" 2>/dev/null || true
    fi
}

# Get stack trace
_err_stack_trace() {
    local frame=0
    echo "Stack trace:"
    while caller $frame; do
        ((frame++))
    done | while read -r line func file; do
        echo "  at $func ($file:$line)"
    done
}

# =============================================================================
# CORE ERROR FUNCTIONS
# =============================================================================

# Print error message and log it
# Usage: error "message"
error() {
    local message="$*"
    echo -e "${ERR_COLOR_RED}✗ Error:${ERR_COLOR_RESET} $message" >&2
    _err_log "ERROR" "$message"

    if [[ "$ERR_STACK_TRACE" == "true" ]]; then
        _err_stack_trace >&2
    fi
}

# Print error and exit
# Usage: error_exit "message" [exit_code]
error_exit() {
    local message="$1"
    local exit_code="${2:-1}"

    error "$message"
    exit "$exit_code"
}

# Check exit code and error if non-zero
# Usage: error_check $? "operation description"
error_check() {
    local exit_code="$1"
    local operation="${2:-Operation}"

    if [[ $exit_code -ne 0 ]]; then
        error "$operation failed (exit code: $exit_code)"
        return "$exit_code"
    fi
    return 0
}

# Check exit code and exit if non-zero
# Usage: error_check_exit $? "operation description"
error_check_exit() {
    local exit_code="$1"
    local operation="${2:-Operation}"

    if [[ $exit_code -ne 0 ]]; then
        error_exit "$operation failed (exit code: $exit_code)" "$exit_code"
    fi
}

# =============================================================================
# WARNING FUNCTIONS
# =============================================================================

# Print warning message
# Usage: warn "message"
warn() {
    local message="$*"
    echo -e "${ERR_COLOR_YELLOW}⚠ Warning:${ERR_COLOR_RESET} $message" >&2
    _err_log "WARN" "$message"
}

# Print warning if condition is true
# Usage: warn_if [ -f file ] "File exists"
warn_if() {
    if eval "$1"; then
        shift
        warn "$*"
    fi
}

# =============================================================================
# INFO FUNCTIONS
# =============================================================================

# Print info message
# Usage: info "message"
info() {
    local message="$*"
    echo -e "${ERR_COLOR_BLUE}→${ERR_COLOR_RESET} $message"
    if [[ "$ERR_VERBOSE" == "true" ]]; then
        _err_log "INFO" "$message"
    fi
}

# Print success message
# Usage: success "message"
success() {
    local message="$*"
    echo -e "${ERR_COLOR_GREEN}✓${ERR_COLOR_RESET} $message"
    if [[ "$ERR_VERBOSE" == "true" ]]; then
        _err_log "SUCCESS" "$message"
    fi
}

# Print debug message (only if verbose)
# Usage: debug "message"
debug() {
    if [[ "$ERR_VERBOSE" == "true" ]]; then
        local message="$*"
        echo -e "${ERR_COLOR_CYAN}[DEBUG]${ERR_COLOR_RESET} $message" >&2
        _err_log "DEBUG" "$message"
    fi
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Require a command to exist
# Usage: require_command git "Git is required"
require_command() {
    local cmd="$1"
    local message="${2:-Command '$cmd' is required but not found}"

    if ! command -v "$cmd" >/dev/null 2>&1; then
        error_exit "$message"
    fi
}

# Require a file to exist
# Usage: require_file /path/to/file "File not found"
require_file() {
    local file="$1"
    local message="${2:-Required file not found: $file}"

    if [[ ! -f "$file" ]]; then
        error_exit "$message"
    fi
}

# Require a directory to exist
# Usage: require_dir /path/to/dir "Directory not found"
require_dir() {
    local dir="$1"
    local message="${2:-Required directory not found: $dir}"

    if [[ ! -d "$dir" ]]; then
        error_exit "$message"
    fi
}

# Require a variable to be set
# Usage: require_var VAR_NAME "Variable required"
require_var() {
    local var_name="$1"
    local message="${2:-Required variable not set: $var_name}"

    if [[ -z "${!var_name:-}" ]]; then
        error_exit "$message"
    fi
}

# Validate number of arguments
# Usage: require_args $# 2 "Usage: script.sh <arg1> <arg2>"
require_args() {
    local actual="$1"
    local expected="$2"
    local usage="${3:-Expected $expected arguments, got $actual}"

    if [[ $actual -ne $expected ]]; then
        error_exit "$usage"
    fi
}

# Validate minimum number of arguments
# Usage: require_min_args $# 1 "Usage: script.sh <arg1> [arg2...]"
require_min_args() {
    local actual="$1"
    local minimum="$2"
    local usage="${3:-Expected at least $minimum arguments, got $actual}"

    if [[ $actual -lt $minimum ]]; then
        error_exit "$usage"
    fi
}

# =============================================================================
# CONFIRMATION FUNCTIONS
# =============================================================================

# Ask user for confirmation
# Usage: if confirm "Delete file?"; then ... fi
confirm() {
    local message="${1:-Are you sure?}"
    local default="${2:-n}"

    local prompt
    if [[ "$default" == "y" || "$default" == "Y" ]]; then
        prompt="$message [Y/n]: "
    else
        prompt="$message [y/N]: "
    fi

    read -r -p "$prompt" response
    response="${response:-$default}"

    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Confirm or exit
# Usage: confirm_or_exit "Delete file?"
confirm_or_exit() {
    local message="${1:-Continue?}"

    if ! confirm "$message"; then
        info "Operation cancelled by user"
        exit 0
    fi
}

# =============================================================================
# ERROR RECOVERY FUNCTIONS
# =============================================================================

# Retry a command with exponential backoff
# Usage: retry 3 5 command arg1 arg2
retry() {
    local max_attempts="$1"
    local delay="$2"
    shift 2
    local command=("$@")

    local attempt=1
    while [[ $attempt -le $max_attempts ]]; do
        debug "Attempt $attempt of $max_attempts: ${command[*]}"

        if "${command[@]}"; then
            success "Command succeeded on attempt $attempt"
            return 0
        fi

        if [[ $attempt -lt $max_attempts ]]; then
            warn "Command failed, retrying in ${delay}s..."
            sleep "$delay"
            delay=$((delay * 2))  # Exponential backoff
        fi

        ((attempt++))
    done

    error "Command failed after $max_attempts attempts: ${command[*]}"
    return 1
}

# Execute command with timeout
# Usage: with_timeout 30 long_running_command
with_timeout() {
    local timeout="$1"
    shift
    local command=("$@")

    debug "Running with timeout ${timeout}s: ${command[*]}"

    if timeout "${timeout}s" "${command[@]}"; then
        return 0
    else
        local exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            error "Command timed out after ${timeout}s: ${command[*]}"
        else
            error "Command failed with exit code $exit_code: ${command[*]}"
        fi
        return $exit_code
    fi
}

# =============================================================================
# TRAP HANDLERS
# =============================================================================

# Cleanup function for trap
_err_cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        error "Script terminated with exit code $exit_code"
    fi

    # Call user cleanup function if defined
    if declare -f cleanup >/dev/null 2>&1; then
        cleanup
    fi
}

# Setup error traps
setup_error_traps() {
    set -euo pipefail  # Exit on error, undefined vars, pipe failures
    trap '_err_cleanup' EXIT
    trap 'error "Script interrupted"; exit 130' INT TERM
}

# =============================================================================
# EXPORT FUNCTIONS
# =============================================================================

export -f error
export -f error_exit
export -f error_check
export -f error_check_exit
export -f warn
export -f warn_if
export -f info
export -f success
export -f debug
export -f require_command
export -f require_file
export -f require_dir
export -f require_var
export -f require_args
export -f require_min_args
export -f confirm
export -f confirm_or_exit
export -f retry
export -f with_timeout
export -f setup_error_traps
