#!/bin/zsh
# =============================================================================
# PATH MANAGEMENT CONFIGURATION
# =============================================================================
# Centralized PATH management with deduplication and logical ordering
# =============================================================================

# Function to add path only if it exists and isn't already in PATH
add_to_path() {
    local path_to_add="$1"
    if [[ -d "$path_to_add" && ":$PATH:" != *":$path_to_add:"* ]]; then
        export PATH="$path_to_add:$PATH"
    fi
}

# Function to add path to end of PATH
append_to_path() {
    local path_to_add="$1"
    if [[ -d "$path_to_add" && ":$PATH:" != *":$path_to_add:"* ]]; then
        export PATH="$PATH:$path_to_add"
    fi
}

# =============================================================================
# SYSTEM PATHS
# =============================================================================

# Homebrew (Apple Silicon)
if [[ -d "/opt/homebrew/bin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Homebrew (Intel)
if [[ -d "/usr/local/bin" ]]; then
    add_to_path "/usr/local/bin"
fi

# User bin
if [[ -d "$HOME/bin" ]]; then
    add_to_path "$HOME/bin"
fi

# =============================================================================
# DEVELOPMENT TOOLS
# =============================================================================

# Node.js version managers (prioritize volta over nvm)
if [[ -d "$HOME/.volta" ]]; then
    export VOLTA_HOME="$HOME/.volta"
    add_to_path "$VOLTA_HOME/bin"
fi

# pnpm
if [[ -d "$HOME/Library/pnpm" ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
    add_to_path "$PNPM_HOME"
fi

# Python tools
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/.composer/vendor/bin"

# =============================================================================
# CUSTOM BINARIES
# =============================================================================

# Custom work binaries
add_to_path "$HOME/work/bin"

# Local node_modules binaries (for current project)
append_to_path "./node_modules/.bin"

# =============================================================================
# DATABASE CLIENTS
# =============================================================================

# MySQL client
add_to_path "/opt/homebrew/opt/mysql-client/bin"

# =============================================================================
# DEVELOPMENT FRAMEWORKS
# =============================================================================

# Flutter
if [[ -d "$HOME/work/flutter/bin" ]]; then
    add_to_path "$HOME/work/flutter/bin"
fi

# Meteor
if [[ -d "$HOME/.meteor" ]]; then
    add_to_path "$HOME/.meteor"
fi

# =============================================================================
# KUBERNETES TOOLS
# =============================================================================

# Krew plugin manager
if [[ -d "${KREW_ROOT:-$HOME/.krew}/bin" ]]; then
    add_to_path "${KREW_ROOT:-$HOME/.krew}/bin"
fi

# =============================================================================
# AI/ML TOOLS
# =============================================================================

# LM Studio
if [[ -d "$HOME/.lmstudio/bin" ]]; then
    add_to_path "$HOME/.lmstudio/bin"
fi

# =============================================================================
# EXTERNAL TOOLS
# =============================================================================

# JetBrains Toolbox
if [[ -d "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" ]]; then
    append_to_path "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
fi

# =============================================================================
# CONDITIONAL PATHS
# =============================================================================

# Python framework paths (only if they exist)
if [[ -d "/Library/Frameworks/Python.framework/Versions/3.12/bin" ]]; then
    add_to_path "/Library/Frameworks/Python.framework/Versions/3.12/bin"
fi

# =============================================================================
# PATH VERIFICATION
# =============================================================================

# Remove duplicate paths
if command -v typeset >/dev/null 2>&1; then
    typeset -U PATH
fi

# Debug PATH if ZSH_DEBUG is set
if [[ "${ZSH_DEBUG:-false}" == "true" ]]; then
    echo "Final PATH:" >&2
    echo "$PATH" | tr ':' '\n' | nl >&2
fi
