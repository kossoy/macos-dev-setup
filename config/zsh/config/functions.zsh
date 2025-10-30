#!/bin/zsh
# =============================================================================
# CUSTOM FUNCTIONS
# =============================================================================
# Enhanced functions with better error handling and cross-platform support
# =============================================================================

# =============================================================================
# DIRECTORY UTILITIES
# =============================================================================

# Create directory and navigate to it
mkcd() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: mkcd <directory>" >&2
        return 1
    fi
    
    local dir="$1"
    if mkdir -p -- "$dir" 2>/dev/null; then
        cd -P -- "$dir" || {
            echo "Error: Failed to change to directory '$dir'" >&2
            return 1
        }
    else
        echo "Error: Failed to create directory '$dir'" >&2
        return 1
    fi
}

# =============================================================================
# PROCESS UTILITIES
# =============================================================================

# Find processes by name (improved version)
psme() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: psme <process_name>" >&2
        return 1
    fi
    
    local pattern="$1"
    ps aux | command grep -i "$pattern" | command grep -v grep
}

# Get process IDs by name
psmes() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: psmes <process_name>" >&2
        return 1
    fi
    
    local pattern="$1"
    ps aux | command grep -i "$pattern" | command grep -v grep | awk '{print $2}'
}

# Kill processes by name with signal
slay() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: slay <process_name> [signal]" >&2
        echo "Signals: -9 (SIGKILL), -15 (SIGTERM, default)" >&2
        return 1
    fi
    
    local pattern="$1"
    local signal="${2:--15}"
    local pids
    
    pids=$(psmes "$pattern")
    
    if [[ -z "$pids" ]]; then
        echo "No processes found matching '$pattern'" >&2
        return 1
    fi
    
    echo "Killing processes: $pids" >&2
    echo "$pids" | xargs kill "$signal"
}

# =============================================================================
# KUBERNETES UTILITIES
# =============================================================================

# Get full pod name (improved with error handling)
get_full_pod_name() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: get_full_pod_name <pod_pattern>" >&2
        return 1
    fi
    
    local pattern="$1"
    local pod_name
    
    pod_name=$(kubectl get pods --no-headers 2>/dev/null | command grep "$pattern" | head -n1 | awk '{print $1}')
    
    if [[ -z "$pod_name" ]]; then
        echo "Error: No pod found matching '$pattern'" >&2
        return 1
    fi
    
    echo "$pod_name"
}

# Connect to pod (improved version)
pod_connect() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: pod_connect <pod_pattern>" >&2
        return 1
    fi
    
    local pattern="$1"
    local pod_name
    local green=$(tput setaf 2 2>/dev/null)
    local reset=$(tput sgr0 2>/dev/null)
    
    pod_name=$(get_full_pod_name "$pattern")
    
    if [[ $? -eq 0 ]]; then
        echo "Connecting to: ${green}${pod_name}${reset}" >&2
        kubectl exec -it "$pod_name" -- sh
    else
        return 1
    fi
}

# Get pod logs (improved version)
klogs() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: klogs <pod_pattern> [options]" >&2
        return 1
    fi
    
    local pattern="$1"
    shift
    local pod_name
    local green=$(tput setaf 2 2>/dev/null)
    local reset=$(tput sgr0 2>/dev/null)
    
    pod_name=$(get_full_pod_name "$pattern")
    
    if [[ $? -eq 0 ]]; then
        echo "Getting logs for: ${green}${pod_name}${reset}" >&2
        kubectl logs "$pod_name" --all-containers=true "$@"
    else
        return 1
    fi
}

# Set Kubernetes context to datascience namespace
dscontext() {
    local current_context
    current_context=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
    
    if [[ -z "$current_context" ]]; then
        echo "Error: Could not get current Kubernetes context" >&2
        return 1
    fi
    
    kubectl config set-context "$current_context" --namespace=datascience
    echo "Set namespace to 'datascience' for context: $current_context" >&2
}

# =============================================================================
# NETWORK UTILITIES
# =============================================================================

# List listening ports (improved version)
listening() {
    local pattern=""
    
    if [[ $# -gt 0 ]]; then
        pattern="$1"
    fi
    
    if [[ -n "$pattern" ]]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P | command grep -i --color "$pattern"
    else
        sudo lsof -iTCP -sTCP:LISTEN -n -P
    fi
}

# =============================================================================
# SYSTEM UTILITIES
# =============================================================================

# Create RAM disk (macOS)
ramdisk() {
    local size_mb="${1:-2048}"  # Default 2GB
    local size_sectors=$((size_mb * 2048))
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local device
        device=$(hdiutil attach -nomount "ram://$size_sectors" 2>/dev/null)
        
        if [[ $? -eq 0 ]]; then
            diskutil erasevolume HFS+ 'RAM Disk' "$device"
            echo "Created RAM disk: $device" >&2
        else
            echo "Error: Failed to create RAM disk" >&2
            return 1
        fi
    else
        echo "Error: ramdisk function only works on macOS" >&2
        return 1
    fi
}

# Mount NAS volumes (macOS)
nasmount() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [[ -f "$HOME/work/bin/CheckVolumes.scpt" ]]; then
            osascript "$HOME/work/bin/CheckVolumes.scpt"
        else
            echo "Error: CheckVolumes.scpt not found" >&2
            return 1
        fi
    else
        echo "Error: nasmount function only works on macOS" >&2
        return 1
    fi
}

# =============================================================================
# DEVELOPMENT UTILITIES
# =============================================================================

# Quick project setup
project_setup() {
    local project_name="$1"
    
    if [[ -z "$project_name" ]]; then
        echo "Usage: project_setup <project_name>" >&2
        return 1
    fi
    
    mkcd "$project_name"
    
    # Initialize git if not already a repo
    if [[ ! -d ".git" ]]; then
        git init
        echo "Initialized git repository" >&2
    fi
    
    # Create basic project structure
    mkdir -p {src,tests,docs,scripts}
    touch README.md .gitignore
    
    echo "Project '$project_name' setup complete" >&2
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Extract various archive formats
extract() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: extract <archive>" >&2
        return 1
    fi
    
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found" >&2
        return 1
    fi
    
    case "$file" in
        *.tar.bz2)   tar xjf "$file"     ;;
        *.tar.gz)    tar xzf "$file"     ;;
        *.bz2)       bunzip2 "$file"     ;;
        *.rar)       unrar e "$file"     ;;
        *.gz)        gunzip "$file"      ;;
        *.tar)       tar xf "$file"      ;;
        *.tbz2)      tar xjf "$file"     ;;
        *.tgz)       tar xzf "$file"     ;;
        *.zip)       unzip "$file"       ;;
        *.Z)         uncompress "$file"  ;;
        *.7z)        7z x "$file"        ;;
        *)           echo "Error: '$file' cannot be extracted" >&2 ;;
    esac
}

# Create a backup of a file
backup() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: backup <file>" >&2
        return 1
    fi
    
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found" >&2
        return 1
    fi
    
    cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backup created: ${file}.backup.$(date +%Y%m%d_%H%M%S)" >&2
}

# =============================================================================
# DEBUGGING UTILITIES
# =============================================================================

# Show function definitions
show_function() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: show_function <function_name>" >&2
        return 1
    fi
    
    local func_name="$1"
    if declare -f "$func_name" >/dev/null 2>&1; then
        declare -f "$func_name"
    else
        echo "Function '$func_name' not found" >&2
        return 1
    fi
}

# List all custom functions
list_functions() {
    echo "Custom functions:" >&2
    declare -f | command grep '^[a-zA-Z_][a-zA-Z0-9_]* ()' | sed 's/ ()//' | sort
}

# =============================================================================
# CONTEXT SWITCHING
# =============================================================================

# Helper function: Get default browser with retry logic to avoid race conditions
_get_default_browser() {
    if ! command -v python3 >/dev/null 2>&1; then
        echo ""  # Return empty if Python3 not available
        return 1
    fi

    python3 <<'EOF'
import plistlib
import os
import time

for attempt in range(3):
    try:
        plist_path = os.path.expanduser(
            '~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist'
        )
        with open(plist_path, 'rb') as f:
            plist = plistlib.load(f)

        handlers = plist.get('LSHandlers', [])
        http_handler = next(
            (h for h in handlers if h.get('LSHandlerURLScheme') == 'http'),
            {}
        )
        print(http_handler.get('LSHandlerRoleAll', ''))
        break
    except Exception:
        if attempt < 2:
            time.sleep(0.1)
        else:
            print('')  # Empty string on final failure
EOF
}

# Switch to work context
work() {
    local green=$(tput setaf 2 2>/dev/null)
    local yellow=$(tput setaf 3 2>/dev/null)
    local red=$(tput setaf 1 2>/dev/null)
    local reset=$(tput sgr0 2>/dev/null)

    local context_name="${WORK_CONTEXT_NAME:-Work}"
    echo "🏢 Switching to ${green}${context_name}${reset} work context..."
    echo ""

    # Get work email from config
    local work_email="${WORK_GIT_EMAIL}"

    # Set environment variables
    export WORK_CONTEXT="${WORK_ORG:-WORK}"
    export PROJECT_ROOT="$HOME/work/projects/work"
    export CONFIG_ROOT="$HOME/work/configs/work"

    # Database variables for work context
    export DB_HOST="${WORK_DB_HOST:-localhost}"
    export DB_PORT="${WORK_DB_PORT:-5433}"
    export DB_NAME="${WORK_DB_NAME:-work_dev}"
    export DB_USER="${WORK_DB_USER:-work_user}"

    # Update Git config
    if [[ -n "$work_email" ]]; then
        if git config --global user.email "$work_email" 2>/dev/null; then
            local actual_email=$(git config --global user.email 2>/dev/null)
            if [[ "$actual_email" == "$work_email" ]]; then
                echo "   ✅ Git email: ${green}${work_email}${reset}"
            else
                echo "   ${yellow}⚠️  Git email may not have been set correctly${reset}" >&2
            fi
        else
            echo "   ${red}❌ Failed to set Git email${reset}" >&2
            echo "   💡 Check if git is installed and configured" >&2
        fi
    else
        echo "   ${yellow}⚠️  Could not determine work email${reset}" >&2
    fi

    # SSH key management
    echo "   🔑 Managing SSH keys..."

    # Ensure personal key is loaded
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        # Check if already loaded
        if ! ssh-add -l 2>/dev/null | grep -q "id_ed25519"; then
            if ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null; then
                echo "   ✅ Personal SSH key loaded"
            else
                echo "   ${red}❌ Failed to load personal SSH key${reset}" >&2
                echo "   💡 Try: ssh-add $HOME/.ssh/id_ed25519" >&2
            fi
        else
            echo "   ✅ Personal SSH key already loaded"
        fi
    else
        echo "   ${yellow}⚠️  Personal SSH key not found: $HOME/.ssh/id_ed25519${reset}" >&2
    fi

    # Load work key
    if [[ -f "$HOME/.ssh/id_ed25519_concur" ]]; then
        if ! ssh-add -l 2>/dev/null | grep -q "id_ed25519_concur"; then
            if ssh-add "$HOME/.ssh/id_ed25519_concur" 2>/dev/null; then
                echo "   ✅ Work SSH key loaded"
            else
                echo "   ${red}❌ Failed to load work SSH key${reset}" >&2
                echo "   💡 Try: ssh-add $HOME/.ssh/id_ed25519_concur" >&2
            fi
        else
            echo "   ✅ Work SSH key already loaded"
        fi
    else
        echo "   ${yellow}⚠️  Work SSH key not found: $HOME/.ssh/id_ed25519_concur${reset}" >&2
    fi

    # Browser switching
    if command -v defaultbrowser >/dev/null 2>&1; then
        local work_browser="${WORK_BROWSER:-browser}"

        # Get current browser before switch
        local current_browser=$(_get_default_browser 2>/dev/null)

        # Map work_browser shorthand to bundle ID
        local expected_bundle_id=""
        case "$work_browser" in
            browser) expected_bundle_id="com.brave.browser" ;;
            beta) expected_bundle_id="com.brave.browser.beta" ;;
            chrome) expected_bundle_id="com.google.chrome" ;;
            safari) expected_bundle_id="com.apple.safari" ;;
            firefox) expected_bundle_id="org.mozilla.firefox" ;;
            *) expected_bundle_id="$work_browser" ;;
        esac

        # Check if browser is already set correctly
        if [[ "$current_browser" == "$expected_bundle_id" ]]; then
            echo "   ✅ Browser already set to correct default"
        else
            echo "   🌐 Switching default browser..."
            defaultbrowser "$work_browser" 2>/dev/null
            echo "   💡 A system alert should appear asking to confirm the browser change"
            echo -n "   Press Enter after confirming (or canceling) the browser change..."
            read -t 30 || echo "${yellow}\n   ⚠️  Timeout waiting for input${reset}" >&2

            # Poll for browser change (max 10 seconds)
            echo "   ⏳ Waiting for system to update browser settings..."
            local max_attempts=20
            local attempt=0
            while [[ $attempt -lt $max_attempts ]]; do
                sleep 0.5
                local new_browser=$(_get_default_browser 2>/dev/null)

                # Check if browser now matches expected
                if [[ "$new_browser" == "$expected_bundle_id" ]]; then
                    echo "   ✅ Browser settings updated"
                    break
                fi

                ((attempt++))
            done

            if [[ $attempt -eq $max_attempts ]]; then
                echo "   ${yellow}⚠️  Browser change not detected (may have been canceled)${reset}"
            fi
        fi
    fi

    # VPN connectivity check for GitHub Enterprise
    local gh_host="${WORK_GITHUB_HOST:-github.com}"
    local skip_gh_check=false

    if [[ "$gh_host" != "github.com" ]]; then
        echo ""
        echo "   🔍 Checking connectivity to ${green}${gh_host}${reset}..."
        if ! curl -s -o /dev/null --max-time 3 -f "https://$gh_host/api/v3" 2>/dev/null; then
            echo "   ${yellow}⚠️  Cannot reach $gh_host${reset}"
            echo "   💡 Please connect to GlobalProtect VPN"
            echo -n "   Press Enter after connecting to VPN (or Ctrl+C to skip)..."
            if ! read -t 300; then  # 5 minute timeout for VPN connection
                echo ""
                echo "   ${yellow}⚠️  Timeout waiting for VPN connection${reset}" >&2
            fi
            echo ""

            # Re-check connectivity
            if curl -s -o /dev/null --max-time 3 -f "https://$gh_host/api/v3" 2>/dev/null; then
                echo "   ✅ Connected to $gh_host"
            else
                echo "   ${yellow}⚠️  Still cannot reach $gh_host - skipping GitHub CLI check${reset}" >&2
                skip_gh_check=true
            fi
        else
            echo "   ✅ VPN connected - $gh_host is reachable"
        fi
    fi

    # GitHub CLI verification
    if [[ "$skip_gh_check" == "false" ]] && command -v gh >/dev/null 2>&1; then
        echo ""
        echo "   🔍 Checking GitHub CLI authentication..."
        local auth_status=$(gh auth status --hostname "$gh_host" 2>&1)

        if echo "$auth_status" | command grep -q "Logged in"; then
            echo "   ✅ Authenticated to $gh_host"

            # Verify username if expected username is set
            if [[ -n "${WORK_GH_USER}" ]]; then
                local gh_user=$(gh api user --hostname "$gh_host" -q .login 2>/dev/null)
                if [[ "$gh_user" == "${WORK_GH_USER}" ]]; then
                    echo "   ✅ Logged in as: ${green}${gh_user}${reset}"
                elif [[ -n "$gh_user" ]] && [[ "$gh_user" != "null" ]]; then
                    echo "   ${yellow}⚠️  Logged in as: $gh_user (expected: ${WORK_GH_USER})${reset}" >&2
                fi
            fi
        else
            echo "   ${yellow}⚠️  Not authenticated to $gh_host${reset}" >&2
            echo "   💡 Run: ${green}gh auth login --hostname $gh_host${reset}"
        fi
    fi

    # Write context file (atomic write with validation)
    local context_file="$HOME/.config/zsh/contexts/current.zsh"
    local temp_file="${context_file}.tmp.$$"
    mkdir -p "$(dirname "$context_file")"

    # Write to temporary file first
    cat > "$temp_file" <<EOF
#!/bin/zsh
# Current development context (auto-generated by work() function)
export WORK_CONTEXT="${WORK_CONTEXT}"
export PROJECT_ROOT="${PROJECT_ROOT}"
export CONFIG_ROOT="${CONFIG_ROOT}"
export DB_HOST="${DB_HOST}"
export DB_PORT="${DB_PORT}"
export DB_NAME="${DB_NAME}"
export DB_USER="${DB_USER}"
EOF

    # Validate and atomically move
    if [[ -s "$temp_file" ]] && grep -q "WORK_CONTEXT" "$temp_file"; then
        chmod 600 "$temp_file"
        mv "$temp_file" "$context_file"
    else
        echo "   ${red}❌ Failed to create context file${reset}" >&2
        rm -f "$temp_file"
        return 1
    fi

    # Change to work projects directory
    if [[ -d "$PROJECT_ROOT" ]]; then
        cd "$PROJECT_ROOT" || echo "   ${yellow}⚠️  Could not change to $PROJECT_ROOT${reset}" >&2
    else
        echo "   ${yellow}⚠️  Projects directory does not exist: $PROJECT_ROOT${reset}" >&2
    fi

    # Display success message
    echo ""
    echo "   ${green}✅ Switched to $context_name work context${reset}"
    echo "   📂 Projects: ${green}${PROJECT_ROOT}${reset}"
    echo "   ⚙️  Config: ${green}${CONFIG_ROOT}${reset}"
    echo "   🗄️  Database: ${green}${DB_HOST}:${DB_PORT}/${DB_NAME}${reset}"
}

# Switch to personal context
personal() {
    local green=$(tput setaf 2 2>/dev/null)
    local yellow=$(tput setaf 3 2>/dev/null)
    local red=$(tput setaf 1 2>/dev/null)
    local reset=$(tput sgr0 2>/dev/null)

    local context_name="${PERSONAL_CONTEXT_NAME:-Personal}"
    echo "🏠 Switching to ${green}${context_name}${reset} personal context..."
    echo ""

    # Get personal email from config
    local personal_email="${PERSONAL_GIT_EMAIL}"

    # Set environment variables
    export WORK_CONTEXT="${PERSONAL_ORG:-PERSONAL}"
    export PROJECT_ROOT="$HOME/work/projects/personal"
    export CONFIG_ROOT="$HOME/work/configs/personal"

    # Database variables for personal context
    export DB_HOST="${PERSONAL_DB_HOST:-localhost}"
    export DB_PORT="${PERSONAL_DB_PORT:-5432}"
    export DB_NAME="${PERSONAL_DB_NAME:-personal_dev}"
    export DB_USER="${PERSONAL_DB_USER:-personal_user}"

    # Update Git config
    if [[ -n "$personal_email" ]]; then
        if git config --global user.email "$personal_email" 2>/dev/null; then
            local actual_email=$(git config --global user.email 2>/dev/null)
            if [[ "$actual_email" == "$personal_email" ]]; then
                echo "   ✅ Git email: ${green}${personal_email}${reset}"
            else
                echo "   ${yellow}⚠️  Git email may not have been set correctly${reset}" >&2
            fi
        else
            echo "   ${red}❌ Failed to set Git email${reset}" >&2
            echo "   💡 Check if git is installed and configured" >&2
        fi
    else
        echo "   ${yellow}⚠️  Could not determine personal email${reset}" >&2
    fi

    # SSH key management
    echo "   🔑 Managing SSH keys..."

    # UNLOAD work key first (before loading personal)
    if [[ -f "$HOME/.ssh/id_ed25519_concur" ]]; then
        if ssh-add -l 2>/dev/null | grep -q "id_ed25519_concur"; then
            if ssh-add -d "$HOME/.ssh/id_ed25519_concur" 2>/dev/null; then
                echo "   ✅ Work SSH key unloaded"
            else
                echo "   ${yellow}⚠️  Could not unload work SSH key${reset}" >&2
            fi
        fi
    fi

    # Ensure personal key is loaded
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        if ! ssh-add -l 2>/dev/null | grep -q "id_ed25519"; then
            if ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null; then
                echo "   ✅ Personal SSH key loaded"
            else
                echo "   ${red}❌ Failed to load personal SSH key${reset}" >&2
                echo "   💡 Try: ssh-add $HOME/.ssh/id_ed25519" >&2
            fi
        else
            echo "   ✅ Personal SSH key already loaded"
        fi
    else
        echo "   ${yellow}⚠️  Personal SSH key not found: $HOME/.ssh/id_ed25519${reset}" >&2
    fi

    # Browser switching
    if command -v defaultbrowser >/dev/null 2>&1; then
        local personal_browser="${PERSONAL_BROWSER:-beta}"

        # Get current browser before switch
        local current_browser=$(_get_default_browser 2>/dev/null)

        # Map personal_browser shorthand to bundle ID
        local expected_bundle_id=""
        case "$personal_browser" in
            browser) expected_bundle_id="com.brave.browser" ;;
            beta) expected_bundle_id="com.brave.browser.beta" ;;
            chrome) expected_bundle_id="com.google.chrome" ;;
            safari) expected_bundle_id="com.apple.safari" ;;
            firefox) expected_bundle_id="org.mozilla.firefox" ;;
            *) expected_bundle_id="$personal_browser" ;;
        esac

        # Check if browser is already set correctly
        if [[ "$current_browser" == "$expected_bundle_id" ]]; then
            echo "   ✅ Browser already set to correct default"
        else
            echo "   🌐 Switching default browser..."
            defaultbrowser "$personal_browser" 2>/dev/null
            echo "   💡 A system alert should appear asking to confirm the browser change"
            echo -n "   Press Enter after confirming (or canceling) the browser change..."
            read -t 30 || echo "${yellow}\n   ⚠️  Timeout waiting for input${reset}" >&2

            # Poll for browser change (max 10 seconds)
            echo "   ⏳ Waiting for system to update browser settings..."
            local max_attempts=20
            local attempt=0
            while [[ $attempt -lt $max_attempts ]]; do
                sleep 0.5
                local new_browser=$(_get_default_browser 2>/dev/null)

                # Check if browser now matches expected
                if [[ "$new_browser" == "$expected_bundle_id" ]]; then
                    echo "   ✅ Browser settings updated"
                    break
                fi

                ((attempt++))
            done

            if [[ $attempt -eq $max_attempts ]]; then
                echo "   ${yellow}⚠️  Browser change not detected (may have been canceled)${reset}"
            fi
        fi
    fi

    # GitHub CLI verification
    if command -v gh >/dev/null 2>&1; then
        local gh_host="${PERSONAL_GITHUB_HOST:-github.com}"
        echo ""
        echo "   🔍 Checking GitHub CLI authentication..."

        # Check connectivity first (test GitHub API endpoint)
        local is_reachable=false
        if curl -s -o /dev/null --max-time 2 -f "https://$gh_host/api/v3" 2>/dev/null; then
            is_reachable=true
        fi

        if [[ "$is_reachable" == "true" ]]; then
            local auth_status=$(gh auth status --hostname "$gh_host" 2>&1)

            if echo "$auth_status" | command grep -q "Logged in"; then
                echo "   ✅ Authenticated to $gh_host"

                # Verify username if expected username is set
                if [[ -n "${PERSONAL_GH_USER}" ]]; then
                    local gh_user=$(gh api user --hostname "$gh_host" -q .login 2>/dev/null)
                    if [[ "$gh_user" == "${PERSONAL_GH_USER}" ]]; then
                        echo "   ✅ Logged in as: ${green}${gh_user}${reset}"
                    elif [[ -n "$gh_user" ]] && [[ "$gh_user" != "null" ]]; then
                        echo "   ${yellow}⚠️  Logged in as: $gh_user (expected: ${PERSONAL_GH_USER})${reset}" >&2
                    fi
                fi
            else
                echo "   ${yellow}⚠️  Not authenticated to $gh_host${reset}" >&2
                echo "   💡 Run: ${green}gh auth login --hostname $gh_host${reset}"
            fi
        else
            echo "   ${yellow}⚠️  Cannot reach $gh_host${reset}" >&2
        fi
    fi

    # Write context file (atomic write with validation)
    local context_file="$HOME/.config/zsh/contexts/current.zsh"
    local temp_file="${context_file}.tmp.$$"
    mkdir -p "$(dirname "$context_file")"

    # Write to temporary file first
    cat > "$temp_file" <<EOF
#!/bin/zsh
# Current development context (auto-generated by personal() function)
export WORK_CONTEXT="${WORK_CONTEXT}"
export PROJECT_ROOT="${PROJECT_ROOT}"
export CONFIG_ROOT="${CONFIG_ROOT}"
export DB_HOST="${DB_HOST}"
export DB_PORT="${DB_PORT}"
export DB_NAME="${DB_NAME}"
export DB_USER="${DB_USER}"
EOF

    # Validate and atomically move
    if [[ -s "$temp_file" ]] && grep -q "WORK_CONTEXT" "$temp_file"; then
        chmod 600 "$temp_file"
        mv "$temp_file" "$context_file"
    else
        echo "   ${red}❌ Failed to create context file${reset}" >&2
        rm -f "$temp_file"
        return 1
    fi

    # Change to personal projects directory
    if [[ -d "$PROJECT_ROOT" ]]; then
        cd "$PROJECT_ROOT" || echo "   ${yellow}⚠️  Could not change to $PROJECT_ROOT${reset}" >&2
    else
        echo "   ${yellow}⚠️  Projects directory does not exist: $PROJECT_ROOT${reset}" >&2
    fi

    # Display success message
    echo ""
    echo "   ${green}✅ Switched to $context_name personal context${reset}"
    echo "   📂 Projects: ${green}${PROJECT_ROOT}${reset}"
    echo "   ⚙️  Config: ${green}${CONFIG_ROOT}${reset}"
    echo "   🗄️  Database: ${green}${DB_HOST}:${DB_PORT}/${DB_NAME}${reset}"
}

# Show current development context
show-context() {
    local green=$(tput setaf 2 2>/dev/null)
    local yellow=$(tput setaf 3 2>/dev/null)
    local blue=$(tput setaf 4 2>/dev/null)
    local reset=$(tput sgr0 2>/dev/null)

    echo "📋 ${blue}Current Development Context${reset}"
    echo "=================================="
    echo ""

    # Determine context type
    local context_type="unknown"
    local context_display="${WORK_CONTEXT:-Not set}"

    if [[ "$WORK_CONTEXT" == "${WORK_ORG}" ]]; then
        context_type="work"
        context_display="${WORK_CONTEXT_NAME:-Work}"
    elif [[ "$WORK_CONTEXT" == "${PERSONAL_ORG}" ]]; then
        context_type="personal"
        context_display="${PERSONAL_CONTEXT_NAME:-Personal}"
    fi

    echo "📍 Context: ${green}${context_display}${reset}"
    echo ""

    # Git configuration
    echo "🔧 Git Configuration:"
    local git_name=$(git config --global user.name 2>/dev/null)
    local git_email=$(git config --global user.email 2>/dev/null)
    if [[ -n "$git_name" ]]; then
        echo "   Name:  ${green}${git_name}${reset}"
    fi
    if [[ -n "$git_email" ]]; then
        echo "   Email: ${green}${git_email}${reset}"
    fi
    echo ""

    # GitHub CLI status - ONLY for current context
    if command -v gh >/dev/null 2>&1; then
        echo "🔐 GitHub CLI:"

        # Determine which host based on current context
        local check_host="github.com"
        if [[ "$context_type" == "work" ]]; then
            check_host="${WORK_GITHUB_HOST:-github.com}"
        elif [[ "$context_type" == "personal" ]]; then
            check_host="${PERSONAL_GITHUB_HOST:-github.com}"
        fi

        # Check connectivity first
        local is_reachable=false
        if [[ "$check_host" == "github.com" ]]; then
            if ping -c 1 -W 1 "$check_host" >/dev/null 2>&1; then
                is_reachable=true
            fi
        else
            if curl -s -o /dev/null --max-time 2 "https://$check_host" 2>/dev/null; then
                is_reachable=true
            fi
        fi

        # Check auth for context's host only
        local auth_status=$(gh auth status --hostname "$check_host" 2>&1)

        if echo "$auth_status" | command grep -q "Logged in"; then
            echo "   ✅ Authenticated to ${green}${check_host}${reset}"

            # Get username only if reachable
            if [[ "$is_reachable" == "true" ]]; then
                local gh_user=$(gh api user --hostname "$check_host" -q .login 2>/dev/null)
                if [[ -n "$gh_user" ]] && [[ "$gh_user" != "null" ]]; then
                    echo "   Logged in as: ${green}${gh_user}${reset}"
                else
                    echo "   ${yellow}⚠️  Cannot retrieve username (check VPN)${reset}"
                fi
            else
                echo "   ${yellow}⚠️  Cannot reach $check_host (VPN required)${reset}"
            fi
        else
            echo "   ${yellow}⚠️  Not authenticated to $check_host${reset}"
            echo "   💡 Run: ${green}gh auth login --hostname $check_host${reset}"
        fi
        echo ""
    fi

    # Browser
    echo "🌐 Browser:"
    if command -v python3 >/dev/null 2>&1; then
        local browser_id=$(_get_default_browser 2>/dev/null)
        [[ -z "$browser_id" ]] && browser_id="Not set"

        # Map bundle ID to friendly name
        local browser_name="$browser_id"
        case "$browser_id" in
            com.brave.browser) browser_name="Brave Browser" ;;
            com.brave.browser.beta) browser_name="Brave Browser Beta" ;;
            com.google.chrome) browser_name="Google Chrome" ;;
            com.apple.safari) browser_name="Safari" ;;
            org.mozilla.firefox) browser_name="Firefox" ;;
        esac

        if [[ -n "$browser_id" ]] && [[ "$browser_id" != "Not set" ]]; then
            echo "   ${green}${browser_name}${reset}"
        else
            echo "   ${yellow}Not set${reset}"
        fi
    else
        echo "   ${yellow}Cannot detect${reset}"
    fi
    echo ""

    # Paths
    echo "📂 Paths:"
    echo "   Projects: ${green}${PROJECT_ROOT:-Not set}${reset}"
    echo "   Config:   ${green}${CONFIG_ROOT:-Not set}${reset}"
    echo "   Current:  ${blue}${PWD}${reset}"
    echo ""

    # Database info
    echo "🗄️  Database:"
    echo "   Host:     ${green}${DB_HOST:-Not set}${reset}"
    echo "   Port:     ${green}${DB_PORT:-Not set}${reset}"
    echo "   Database: ${green}${DB_NAME:-Not set}${reset}"
    echo "   User:     ${green}${DB_USER:-Not set}${reset}"
    echo ""

    # SSH keys loaded
    if command -v ssh-add >/dev/null 2>&1; then
        echo "🔑 SSH Keys Loaded:"
        local keys=$(ssh-add -l 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            echo "$keys" | while IFS= read -r line; do
                echo "   ${green}✓${reset} $line"
            done
        else
            echo "   ${yellow}No keys loaded${reset}"
        fi
    fi
}