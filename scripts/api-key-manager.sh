#!/bin/bash
# =============================================================================
# API KEY MANAGER
# =============================================================================
# Centralized management of API keys using macOS Keychain
#
# Usage:
#   api-key-manager.sh store <service> <key>
#   api-key-manager.sh get <service>
#   api-key-manager.sh delete <service>
#   api-key-manager.sh list
#   api-key-manager.sh rotate <service>
#
# =============================================================================

set -euo pipefail

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

# Source the keychain library
if [[ -f "$LIB_DIR/keychain.sh" ]]; then
    source "$LIB_DIR/keychain.sh"
else
    echo "Error: Keychain library not found at $LIB_DIR/keychain.sh"
    exit 1
fi

# Constants
readonly SERVICE_PREFIX="api-key"
readonly ACCOUNT_NAME="default"

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
    echo -e "${COLOR_BLUE}   API Key Manager${COLOR_RESET}"
    echo -e "${COLOR_BLUE}========================================${COLOR_RESET}"
    echo
}

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

# Store an API key
store_key() {
    local service_name="$1"
    local api_key="${2:-}"

    local keychain_service="${SERVICE_PREFIX}-${service_name}"

    # If no key provided, prompt for it
    if [[ -z "$api_key" ]]; then
        read -r -s -p "Enter API key for $service_name: " api_key
        echo
    fi

    if [[ -z "$api_key" ]]; then
        print_error "No API key provided"
        return 1
    fi

    # Store in keychain
    if keychain_store "$keychain_service" "$ACCOUNT_NAME" "$api_key" "API key for $service_name"; then
        print_success "Stored API key for $service_name"
        return 0
    else
        print_error "Failed to store API key for $service_name"
        return 1
    fi
}

# Retrieve an API key
get_key() {
    local service_name="$1"
    local quiet="${2:-false}"

    local keychain_service="${SERVICE_PREFIX}-${service_name}"

    local api_key
    if api_key=$(keychain_get "$keychain_service" "$ACCOUNT_NAME" 2>/dev/null); then
        if [[ "$quiet" == "true" ]]; then
            echo "$api_key"
        else
            print_info "API key for $service_name:"
            echo "$api_key"
        fi
        return 0
    else
        if [[ "$quiet" != "true" ]]; then
            print_error "API key not found for $service_name"
        fi
        return 1
    fi
}

# Delete an API key
delete_key() {
    local service_name="$1"
    local keychain_service="${SERVICE_PREFIX}-${service_name}"

    # Confirm deletion
    read -r -p "Delete API key for $service_name? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Deletion cancelled"
        return 0
    fi

    if keychain_delete "$keychain_service" "$ACCOUNT_NAME"; then
        print_success "Deleted API key for $service_name"
        return 0
    else
        print_error "Failed to delete API key for $service_name"
        return 1
    fi
}

# List all stored API keys
list_keys() {
    print_info "Stored API keys:"
    echo

    # Get list of all generic passwords with our prefix
    local keys
    keys=$(security dump-keychain 2>/dev/null | grep -A 1 "\"${SERVICE_PREFIX}-" | grep "srvr" | sed "s/.*\"srvr\"<blob>=\"${SERVICE_PREFIX}-\(.*\)\"/\1/" | sort -u)

    if [[ -z "$keys" ]]; then
        print_warning "No API keys found"
        return 0
    fi

    local count=0
    while IFS= read -r key; do
        if [[ -n "$key" ]]; then
            count=$((count + 1))
            echo -e "  ${COLOR_CYAN}$count.${COLOR_RESET} $key"
        fi
    done <<< "$keys"

    echo
    print_info "Total: $count API key(s)"
}

# Rotate an API key
rotate_key() {
    local service_name="$1"

    print_warning "Rotating API key for $service_name"
    echo

    # Show current key (masked)
    if get_key "$service_name" true >/dev/null 2>&1; then
        print_info "Current key exists"
    else
        print_warning "No existing key found"
    fi

    echo
    read -r -s -p "Enter new API key: " new_key
    echo

    if [[ -z "$new_key" ]]; then
        print_error "No key provided"
        return 1
    fi

    read -r -s -p "Confirm new API key: " confirm_key
    echo

    if [[ "$new_key" != "$confirm_key" ]]; then
        print_error "Keys do not match"
        return 1
    fi

    # Update the key
    local keychain_service="${SERVICE_PREFIX}-${service_name}"
    if keychain_exists "$keychain_service" "$ACCOUNT_NAME" 2>/dev/null; then
        if keychain_update "$keychain_service" "$ACCOUNT_NAME" "$new_key"; then
            print_success "Rotated API key for $service_name"
            return 0
        fi
    else
        if keychain_store "$keychain_service" "$ACCOUNT_NAME" "$new_key" "API key for $service_name"; then
            print_success "Created API key for $service_name"
            return 0
        fi
    fi

    print_error "Failed to rotate API key for $service_name"
    return 1
}

# Validate an API key (check if it exists and is non-empty)
validate_key() {
    local service_name="$1"
    local keychain_service="${SERVICE_PREFIX}-${service_name}"

    if keychain_exists "$keychain_service" "$ACCOUNT_NAME" 2>/dev/null; then
        local key
        if key=$(keychain_get "$keychain_service" "$ACCOUNT_NAME" 2>/dev/null) && [[ -n "$key" ]]; then
            print_success "API key for $service_name is valid"
            return 0
        fi
    fi

    print_error "API key for $service_name is invalid or missing"
    return 1
}

# Export API key as environment variable
export_key() {
    local service_name="$1"
    local var_name="${2:-${service_name}_API_KEY}"

    local api_key
    if api_key=$(get_key "$service_name" true 2>/dev/null); then
        echo "export ${var_name}=\"${api_key}\""
        print_success "Export command generated for $service_name" >&2
        print_info "Run: \$(api-key-manager.sh export $service_name)" >&2
        return 0
    else
        print_error "Failed to retrieve API key for $service_name"
        return 1
    fi
}

# =============================================================================
# USAGE
# =============================================================================

usage() {
    cat << EOF
API Key Manager - Centralized API key management using macOS Keychain

Usage:
    $(basename "$0") <command> [arguments]

Commands:
    store <service> [key]     Store an API key for a service
    get <service>             Retrieve an API key
    delete <service>          Delete an API key
    list                      List all stored API keys
    rotate <service>          Rotate an API key (update with confirmation)
    validate <service>        Check if an API key exists and is valid
    export <service> [var]    Generate export command for environment variable

Examples:
    # Store a key interactively
    $(basename "$0") store openai

    # Store a key directly
    $(basename "$0") store github ghp_xxxxxxxxxxxxx

    # Get a key
    $(basename "$0") get openai

    # Export as environment variable
    eval \$($(basename "$0") export openai OPENAI_API_KEY)

    # List all keys
    $(basename "$0") list

    # Rotate a key
    $(basename "$0") rotate openai

    # Validate a key
    $(basename "$0") validate github

    # Delete a key
    $(basename "$0") delete anthropic

Common Services:
    openai, anthropic, github, gitlab, aws, azure, gcp, digitalocean,
    stripe, twilio, sendgrid, slack, discord, notion, airtable

EOF
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    if [[ $# -eq 0 ]]; then
        print_header
        usage
        exit 0
    fi

    local command="$1"
    shift

    case "$command" in
        store)
            if [[ $# -lt 1 ]]; then
                print_error "Usage: store <service> [key]"
                exit 1
            fi
            print_header
            store_key "$@"
            ;;
        get)
            if [[ $# -lt 1 ]]; then
                print_error "Usage: get <service>"
                exit 1
            fi
            print_header
            get_key "$@"
            ;;
        delete)
            if [[ $# -lt 1 ]]; then
                print_error "Usage: delete <service>"
                exit 1
            fi
            print_header
            delete_key "$@"
            ;;
        list)
            print_header
            list_keys
            ;;
        rotate)
            if [[ $# -lt 1 ]]; then
                print_error "Usage: rotate <service>"
                exit 1
            fi
            print_header
            rotate_key "$@"
            ;;
        validate)
            if [[ $# -lt 1 ]]; then
                print_error "Usage: validate <service>"
                exit 1
            fi
            print_header
            validate_key "$@"
            ;;
        export)
            if [[ $# -lt 1 ]]; then
                print_error "Usage: export <service> [variable_name]"
                exit 1
            fi
            export_key "$@"
            ;;
        -h|--help|help)
            print_header
            usage
            ;;
        *)
            print_error "Unknown command: $command"
            echo
            usage
            exit 1
            ;;
    esac
}

main "$@"
