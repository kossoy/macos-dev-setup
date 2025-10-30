#!/bin/bash
# =============================================================================
# KEYCHAIN INTEGRATION HELPER LIBRARY
# =============================================================================
# Provides functions for interacting with macOS Keychain
#
# Usage:
#   source "$HOME/work/scripts/lib/keychain.sh"
#   keychain_store "service-name" "account-name" "password"
#   password=$(keychain_get "service-name" "account-name")
#
# =============================================================================

# Color codes for output
readonly KC_COLOR_RED='\033[0;31m'
readonly KC_COLOR_GREEN='\033[0;32m'
readonly KC_COLOR_YELLOW='\033[1;33m'
readonly KC_COLOR_BLUE='\033[0;34m'
readonly KC_COLOR_RESET='\033[0m'

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Print colored message
_kc_print() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${KC_COLOR_RESET}"
}

# Print error message
_kc_error() {
    _kc_print "$KC_COLOR_RED" "✗ $1" >&2
}

# Print success message
_kc_success() {
    _kc_print "$KC_COLOR_GREEN" "✓ $1"
}

# Print info message
_kc_info() {
    _kc_print "$KC_COLOR_BLUE" "→ $1"
}

# Print warning message
_kc_warning() {
    _kc_print "$KC_COLOR_YELLOW" "⚠ $1"
}

# =============================================================================
# KEYCHAIN FUNCTIONS
# =============================================================================

# Store a password in Keychain
# Usage: keychain_store "service" "account" "password" ["comment"]
keychain_store() {
    local service="$1"
    local account="$2"
    local password="$3"
    local comment="${4:-}"

    if [[ -z "$service" || -z "$account" || -z "$password" ]]; then
        _kc_error "Usage: keychain_store <service> <account> <password> [comment]"
        return 1
    fi

    # Check if entry already exists
    if keychain_exists "$service" "$account" 2>/dev/null; then
        _kc_warning "Entry exists. Updating password for $service/$account"
        return keychain_update "$service" "$account" "$password"
    fi

    # Store the password
    local cmd=(
        security add-generic-password
        -a "$account"
        -s "$service"
        -w "$password"
    )

    # Add comment if provided
    if [[ -n "$comment" ]]; then
        cmd+=(-j "$comment")
    fi

    if "${cmd[@]}" 2>/dev/null; then
        _kc_success "Stored password for $service/$account"
        return 0
    else
        _kc_error "Failed to store password for $service/$account"
        return 1
    fi
}

# Retrieve a password from Keychain
# Usage: password=$(keychain_get "service" "account")
keychain_get() {
    local service="$1"
    local account="$2"

    if [[ -z "$service" || -z "$account" ]]; then
        _kc_error "Usage: keychain_get <service> <account>" >&2
        return 1
    fi

    local password
    password=$(security find-generic-password -a "$account" -s "$service" -w 2>/dev/null)

    if [[ $? -eq 0 && -n "$password" ]]; then
        echo "$password"
        return 0
    else
        _kc_error "Failed to retrieve password for $service/$account" >&2
        return 1
    fi
}

# Update an existing password in Keychain
# Usage: keychain_update "service" "account" "new_password"
keychain_update() {
    local service="$1"
    local account="$2"
    local new_password="$3"

    if [[ -z "$service" || -z "$account" || -z "$new_password" ]]; then
        _kc_error "Usage: keychain_update <service> <account> <new_password>"
        return 1
    fi

    # Check if entry exists
    if ! keychain_exists "$service" "$account" 2>/dev/null; then
        _kc_error "Entry does not exist: $service/$account"
        return 1
    fi

    # Delete old entry
    if ! keychain_delete "$service" "$account" 2>/dev/null; then
        _kc_error "Failed to delete old entry: $service/$account"
        return 1
    fi

    # Store new password
    if keychain_store "$service" "$account" "$new_password" 2>/dev/null; then
        _kc_success "Updated password for $service/$account"
        return 0
    else
        _kc_error "Failed to update password for $service/$account"
        return 1
    fi
}

# Delete a password from Keychain
# Usage: keychain_delete "service" "account"
keychain_delete() {
    local service="$1"
    local account="$2"

    if [[ -z "$service" || -z "$account" ]]; then
        _kc_error "Usage: keychain_delete <service> <account>"
        return 1
    fi

    if security delete-generic-password -a "$account" -s "$service" 2>/dev/null; then
        _kc_success "Deleted password for $service/$account"
        return 0
    else
        _kc_error "Failed to delete password for $service/$account"
        return 1
    fi
}

# Check if a Keychain entry exists
# Usage: if keychain_exists "service" "account"; then ... fi
keychain_exists() {
    local service="$1"
    local account="$2"

    if [[ -z "$service" || -z "$account" ]]; then
        _kc_error "Usage: keychain_exists <service> <account>" >&2
        return 1
    fi

    security find-generic-password -a "$account" -s "$service" >/dev/null 2>&1
    return $?
}

# List all entries for a service
# Usage: keychain_list "service"
keychain_list() {
    local service="$1"

    if [[ -z "$service" ]]; then
        _kc_error "Usage: keychain_list <service>"
        return 1
    fi

    _kc_info "Entries for service: $service"
    security dump-keychain | grep -A 5 "srvr.*$service" | grep "acct" | sed 's/.*"acct"<blob>="\(.*\)"/  - \1/'
}

# Get password with interactive prompt if not found
# Usage: password=$(keychain_get_or_prompt "service" "account" "Prompt message")
keychain_get_or_prompt() {
    local service="$1"
    local account="$2"
    local prompt="${3:-Enter password for $service/$account}"

    if [[ -z "$service" || -z "$account" ]]; then
        _kc_error "Usage: keychain_get_or_prompt <service> <account> [prompt]" >&2
        return 1
    fi

    # Try to get from keychain first
    local password
    password=$(keychain_get "$service" "$account" 2>/dev/null)

    if [[ $? -eq 0 && -n "$password" ]]; then
        echo "$password"
        return 0
    fi

    # Prompt user
    _kc_warning "Password not found in Keychain"
    read -r -s -p "$prompt: " password
    echo >&2

    if [[ -z "$password" ]]; then
        _kc_error "No password provided" >&2
        return 1
    fi

    # Ask to save
    read -r -p "Save to Keychain? (y/n): " save_choice
    if [[ "$save_choice" =~ ^[Yy]$ ]]; then
        keychain_store "$service" "$account" "$password" >/dev/null 2>&1
    fi

    echo "$password"
    return 0
}

# =============================================================================
# VALIDATION
# =============================================================================

# Validate that Keychain is accessible
keychain_validate() {
    if ! command -v security >/dev/null 2>&1; then
        _kc_error "security command not found. This library requires macOS Keychain."
        return 1
    fi

    # Try to access keychain
    if ! security list-keychains >/dev/null 2>&1; then
        _kc_error "Unable to access Keychain. Check permissions."
        return 1
    fi

    return 0
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Validate Keychain access when library is sourced
if ! keychain_validate; then
    _kc_error "Keychain library initialization failed"
    return 1 2>/dev/null || exit 1
fi

# Export functions
export -f keychain_store
export -f keychain_get
export -f keychain_update
export -f keychain_delete
export -f keychain_exists
export -f keychain_list
export -f keychain_get_or_prompt
export -f keychain_validate
