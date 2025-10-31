#!/bin/bash
# =============================================================================
# LAUNCHAGENT CREATION WIZARD
# =============================================================================
# Interactive tool to create and deploy LaunchAgents
#
# Usage:
#   launchagent-create.sh
#   launchagent-create.sh --name my-agent --script ~/path/to/script.sh
#
# =============================================================================

set -euo pipefail

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries
if [[ -f "$SCRIPT_DIR/lib/errors.sh" ]]; then
    source "$SCRIPT_DIR/lib/errors.sh"
    setup_error_traps
fi

# Constants
readonly LAUNCHAGENTS_DIR="$HOME/Library/LaunchAgents"
readonly LOGS_DIR="$HOME/Library/Logs"

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
    echo -e "${COLOR_BLUE}   LaunchAgent Creation Wizard${COLOR_RESET}"
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
# VALIDATION FUNCTIONS
# =============================================================================

validate_label() {
    local label="$1"

    if [[ ! "$label" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        print_error "Label must contain only letters, numbers, dots, and hyphens"
        return 1
    fi

    if [[ ! "$label" =~ \. ]]; then
        print_warning "Label should follow reverse-DNS format (e.g., com.befeast.myagent)"
    fi

    return 0
}

validate_script() {
    local script="$1"

    if [[ ! -f "$script" ]]; then
        print_error "Script does not exist: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        print_warning "Script is not executable: $script"
        if confirm "Make script executable?"; then
            chmod +x "$script"
            print_success "Script is now executable"
        fi
    fi

    return 0
}

# =============================================================================
# SCHEDULE SELECTION
# =============================================================================

select_schedule() {
    echo
    print_info "Select schedule type:"
    echo
    echo "  1) Interval (run every N seconds/minutes/hours)"
    echo "  2) Calendar (run at specific times)"
    echo "  3) At Login (run once when user logs in)"
    echo "  4) Watch Path (run when file/directory changes)"
    echo "  5) Manual only (no automatic schedule)"
    echo

    local choice
    choice=$(prompt "Choice" "1")

    case "$choice" in
        1) schedule_interval ;;
        2) schedule_calendar ;;
        3) schedule_login ;;
        4) schedule_watchpath ;;
        5) schedule_manual ;;
        *) print_error "Invalid choice"; select_schedule ;;
    esac
}

schedule_interval() {
    SCHEDULE_TYPE="interval"
    echo
    print_info "Interval schedule selected"
    echo

    local interval
    interval=$(prompt "Interval in seconds (e.g., 3600 for 1 hour, 7200 for 2 hours)" "3600")

    SCHEDULE_INTERVAL="$interval"

    local hours=$((interval / 3600))
    local minutes=$(((interval % 3600) / 60))
    local seconds=$((interval % 60))

    if [[ $hours -gt 0 ]]; then
        print_success "Agent will run every ${hours}h ${minutes}m ${seconds}s"
    elif [[ $minutes -gt 0 ]]; then
        print_success "Agent will run every ${minutes}m ${seconds}s"
    else
        print_success "Agent will run every ${seconds}s"
    fi
}

schedule_calendar() {
    SCHEDULE_TYPE="calendar"
    echo
    print_info "Calendar schedule selected"
    echo
    print_info "Enter times in 24-hour format (HH:MM)"
    echo

    local times=()
    while true; do
        local time
        time=$(prompt "Enter time (or press Enter to finish)")

        if [[ -z "$time" ]]; then
            if [[ ${#times[@]} -eq 0 ]]; then
                print_error "At least one time is required"
                continue
            fi
            break
        fi

        if [[ "$time" =~ ^([0-1][0-9]|2[0-3]):([0-5][0-9])$ ]]; then
            times+=("$time")
            print_success "Added: $time"
        else
            print_error "Invalid time format. Use HH:MM (24-hour)"
        fi
    done

    SCHEDULE_TIMES=("${times[@]}")
    print_success "Agent will run at: ${times[*]}"
}

schedule_login() {
    SCHEDULE_TYPE="login"
    print_success "Agent will run at login"
}

schedule_watchpath() {
    SCHEDULE_TYPE="watchpath"
    echo
    print_info "Watch path schedule selected"
    echo

    local path
    path=$(prompt "Path to watch" "$HOME/Downloads")

    if [[ ! -e "$path" ]]; then
        print_warning "Path does not exist: $path"
        if ! confirm "Create path?"; then
            schedule_watchpath
            return
        fi

        if [[ "$path" =~ /$ ]] || confirm "Create as directory?"; then
            mkdir -p "$path"
        else
            mkdir -p "$(dirname "$path")"
            touch "$path"
        fi
    fi

    SCHEDULE_WATCHPATH="$path"
    print_success "Agent will run when $path changes"
}

schedule_manual() {
    SCHEDULE_TYPE="manual"
    print_success "Agent will only run when manually triggered"
}

# =============================================================================
# PLIST GENERATION
# =============================================================================

generate_plist() {
    local label="$1"
    local script="$2"

    cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Job Identification -->
    <key>Label</key>
    <string>${label}</string>

    <!-- Program to Run -->
    <key>ProgramArguments</key>
    <array>
        <string>${script}</string>
    </array>

EOF

    # Add schedule based on type
    case "$SCHEDULE_TYPE" in
        interval)
            cat <<EOF
    <!-- Schedule: Run every ${SCHEDULE_INTERVAL} seconds -->
    <key>StartInterval</key>
    <integer>${SCHEDULE_INTERVAL}</integer>

EOF
            ;;
        calendar)
            echo "    <!-- Schedule: Run at specific times -->"
            echo "    <key>StartCalendarInterval</key>"
            echo "    <array>"
            for time in "${SCHEDULE_TIMES[@]}"; do
                local hour="${time%%:*}"
                local minute="${time##*:}"
                cat <<EOF
        <dict>
            <key>Hour</key>
            <integer>${hour}</integer>
            <key>Minute</key>
            <integer>${minute}</integer>
        </dict>
EOF
            done
            echo "    </array>"
            echo
            ;;
        login)
            cat <<EOF
    <!-- Schedule: Run at login -->
    <key>RunAtLoad</key>
    <true/>
    <key>LaunchOnlyOnce</key>
    <true/>

EOF
            ;;
        watchpath)
            cat <<EOF
    <!-- Schedule: Watch path for changes -->
    <key>WatchPaths</key>
    <array>
        <string>${SCHEDULE_WATCHPATH}</string>
    </array>

EOF
            ;;
        manual)
            # No schedule - manual only
            ;;
    esac

    # Add working directory if available
    local work_dir
    work_dir="$(dirname "$script")"
    cat <<EOF
    <!-- Working Directory -->
    <key>WorkingDirectory</key>
    <string>${work_dir}</string>

    <!-- Environment -->
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin</string>
        <key>HOME</key>
        <string>${HOME}</string>
    </dict>

    <!-- Logging -->
    <key>StandardOutPath</key>
    <string>${LOGS_DIR}/${label}.log</string>
    <key>StandardErrorPath</key>
    <string>${LOGS_DIR}/${label}-error.log</string>

    <!-- Resource Limits -->
    <key>Nice</key>
    <integer>1</integer>

    <!-- Process Options -->
    <key>ProcessType</key>
    <string>Background</string>

    <!-- Keep alive if crash (only for non-login agents) -->
EOF

    if [[ "$SCHEDULE_TYPE" != "login" ]]; then
        cat <<EOF
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>

    <!-- Throttle restarts -->
    <key>ThrottleInterval</key>
    <integer>300</integer>
EOF
    fi

    cat <<EOF
</dict>
</plist>
EOF
}

# =============================================================================
# MAIN WIZARD
# =============================================================================

wizard() {
    print_header

    # Get label
    local label
    while true; do
        label=$(prompt "Agent label (e.g., com.befeast.my-agent)")
        if [[ -z "$label" ]]; then
            print_error "Label is required"
            continue
        fi
        if validate_label "$label"; then
            break
        fi
    done

    # Get script path
    local script
    while true; do
        script=$(prompt "Script path" "$HOME/work/scripts/")
        if [[ -z "$script" ]]; then
            print_error "Script path is required"
            continue
        fi
        # Expand tilde
        script="${script/#\~/$HOME}"
        if validate_script "$script"; then
            break
        fi
    done

    # Get schedule
    select_schedule

    echo
    print_info "Summary:"
    echo "  Label:    $label"
    echo "  Script:   $script"
    echo "  Schedule: $SCHEDULE_TYPE"
    echo

    if ! confirm "Create LaunchAgent?"; then
        print_info "Cancelled"
        exit 0
    fi

    # Generate plist
    local plist_file="$LAUNCHAGENTS_DIR/${label}.plist"

    if [[ -f "$plist_file" ]]; then
        print_warning "LaunchAgent already exists: $plist_file"
        if ! confirm "Overwrite existing agent?"; then
            print_info "Cancelled"
            exit 0
        fi
    fi

    # Create LaunchAgents directory if needed
    mkdir -p "$LAUNCHAGENTS_DIR"

    # Generate and save plist
    generate_plist "$label" "$script" > "$plist_file"

    # Validate plist
    if ! plutil -lint "$plist_file" >/dev/null 2>&1; then
        print_error "Generated plist is invalid"
        cat "$plist_file"
        rm "$plist_file"
        exit 1
    fi

    print_success "Created LaunchAgent: $plist_file"

    # Ask to load
    if confirm "Load LaunchAgent now?"; then
        if launchctl load "$plist_file" 2>/dev/null; then
            print_success "LaunchAgent loaded successfully"

            # Show status
            sleep 1
            if launchctl list | grep -q "$label"; then
                print_success "Agent is running"
            else
                print_warning "Agent loaded but not running (may run on schedule)"
            fi
        else
            print_error "Failed to load LaunchAgent"
            print_info "You can load it later with:"
            echo "  launchctl load $plist_file"
        fi
    fi

    echo
    print_success "LaunchAgent created successfully!"
    echo
    print_info "Useful commands:"
    echo "  View logs:   tail -f $LOGS_DIR/${label}.log"
    echo "  Check status: launchctl list | grep $label"
    echo "  Unload:      launchctl unload $plist_file"
    echo "  Edit:        open -e $plist_file"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    # Check for required commands
    if ! command -v plutil >/dev/null 2>&1; then
        print_error "plutil command not found (macOS required)"
        exit 1
    fi

    wizard
}

main "$@"
