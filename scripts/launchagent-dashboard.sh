#!/bin/bash
# =============================================================================
# LAUNCHAGENT DASHBOARD
# =============================================================================
# Interactive TUI for monitoring LaunchAgent status in real-time
#
# Usage:
#   launchagent-dashboard.sh
#   launchagent-dashboard.sh --refresh 5
#
# Controls:
#   q - Quit
#   r - Refresh
#   f - Filter user agents only
#   a - Show all agents
#   l - View logs for selected agent
#
# =============================================================================

set -euo pipefail

# Configuration
REFRESH_INTERVAL="${REFRESH_INTERVAL:-3}"
FILTER_USER_ONLY="${FILTER_USER_ONLY:-true}"
SHOW_DETAILS="${SHOW_DETAILS:-false}"

# Constants
readonly LAUNCHAGENTS_DIR="$HOME/Library/LaunchAgents"
readonly LOGS_DIR="$HOME/Library/Logs"

# Color codes
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_MAGENTA='\033[0;35m'
readonly COLOR_WHITE='\033[1;37m'
readonly COLOR_GRAY='\033[0;90m'
readonly COLOR_RESET='\033[0m'
readonly COLOR_BOLD='\033[1m'

# Terminal control
readonly CLEAR_SCREEN='\033[2J'
readonly MOVE_CURSOR_HOME='\033[H'
readonly HIDE_CURSOR='\033[?25l'
readonly SHOW_CURSOR='\033[?25h'

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

cleanup() {
    # Show cursor on exit
    echo -ne "$SHOW_CURSOR"
    clear
}

trap cleanup EXIT INT TERM

get_agent_status() {
    local label="$1"
    local output

    if output=$(launchctl list "$label" 2>/dev/null); then
        echo "$output"
        return 0
    else
        return 1
    fi
}

get_agent_pid() {
    local label="$1"
    local status

    if status=$(get_agent_status "$label"); then
        echo "$status" | awk '/PID/ {gsub(/[";]/, ""); print $3}'
    else
        echo "-"
    fi
}

get_agent_exit_code() {
    local label="$1"
    local status

    if status=$(get_agent_status "$label"); then
        local exit_code
        exit_code=$(echo "$status" | awk '/"LastExitStatus"/ {gsub(/[";]/, ""); print $3}')
        if [[ -n "$exit_code" ]]; then
            echo "$exit_code"
        else
            echo "0"
        fi
    else
        echo "-"
    fi
}

format_agent_status() {
    local label="$1"
    local pid
    local exit_code

    pid=$(get_agent_pid "$label")
    exit_code=$(get_agent_exit_code "$label")

    if [[ "$pid" != "-" ]]; then
        echo -e "${COLOR_GREEN}●${COLOR_RESET} Running (PID: $pid)"
    elif [[ "$exit_code" == "0" ]]; then
        echo -e "${COLOR_BLUE}○${COLOR_RESET} Loaded (not running)"
    elif [[ "$exit_code" != "-" ]]; then
        echo -e "${COLOR_RED}✗${COLOR_RESET} Failed (exit: $exit_code)"
    else
        echo -e "${COLOR_GRAY}○${COLOR_RESET} Not loaded"
    fi
}

get_agent_plist() {
    local label="$1"

    # Check user LaunchAgents
    if [[ -f "$LAUNCHAGENTS_DIR/${label}.plist" ]]; then
        echo "$LAUNCHAGENTS_DIR/${label}.plist"
        return 0
    fi

    # Check system LaunchAgents
    if [[ -f "/Library/LaunchAgents/${label}.plist" ]]; then
        echo "/Library/LaunchAgents/${label}.plist"
        return 0
    fi

    return 1
}

# =============================================================================
# DISPLAY FUNCTIONS
# =============================================================================

draw_header() {
    local agent_count="$1"
    local running_count="$2"
    local failed_count="$3"

    echo -ne "$MOVE_CURSOR_HOME"
    echo -e "${COLOR_BOLD}${COLOR_CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_BOLD}${COLOR_CYAN}║${COLOR_RESET} ${COLOR_WHITE}LaunchAgent Dashboard${COLOR_RESET}                                                      ${COLOR_BOLD}${COLOR_CYAN}║${COLOR_RESET}"
    echo -e "${COLOR_BOLD}${COLOR_CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${COLOR_RESET}"
    echo -e "${COLOR_BOLD}${COLOR_CYAN}║${COLOR_RESET} Total: $agent_count | Running: ${COLOR_GREEN}$running_count${COLOR_RESET} | Failed: ${COLOR_RED}$failed_count${COLOR_RESET}                                  ${COLOR_BOLD}${COLOR_CYAN}║${COLOR_RESET}"
    echo -e "${COLOR_BOLD}${COLOR_CYAN}║${COLOR_RESET} Updated: $(date '+%Y-%m-%d %H:%M:%S') | Refresh: ${REFRESH_INTERVAL}s                              ${COLOR_BOLD}${COLOR_CYAN}║${COLOR_RESET}"
    echo -e "${COLOR_BOLD}${COLOR_CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${COLOR_RESET}"
    echo
}

draw_agent_list() {
    echo -e "${COLOR_BOLD}${COLOR_WHITE}Status  PID      Exit  Label${COLOR_RESET}"
    echo -e "${COLOR_GRAY}────────────────────────────────────────────────────────────────────────────────${COLOR_RESET}"

    local agents
    if [[ "$FILTER_USER_ONLY" == "true" ]]; then
        agents=$(launchctl list | awk 'NR>1 {print $3}' | grep "^com.user." | sort)
    else
        agents=$(launchctl list | awk 'NR>1 {print $3}' | sort)
    fi

    local count=0
    local running=0
    local failed=0

    while IFS= read -r label; do
        if [[ -z "$label" ]]; then
            continue
        fi

        ((count++))

        local pid
        local exit_code
        local status_icon

        pid=$(get_agent_pid "$label")
        exit_code=$(get_agent_exit_code "$label")

        if [[ "$pid" != "-" ]]; then
            status_icon="${COLOR_GREEN}●${COLOR_RESET}"
            ((running++))
        elif [[ "$exit_code" == "0" ]]; then
            status_icon="${COLOR_BLUE}○${COLOR_RESET}"
        elif [[ "$exit_code" != "-" ]]; then
            status_icon="${COLOR_RED}✗${COLOR_RESET}"
            ((failed++))
        else
            status_icon="${COLOR_GRAY}○${COLOR_RESET}"
        fi

        printf "%b  %-8s %-5s %s\n" \
            "$status_icon" \
            "$pid" \
            "$exit_code" \
            "$label"
    done <<< "$agents"

    echo "$count" > /tmp/la-dashboard-count.$$
    echo "$running" > /tmp/la-dashboard-running.$$
    echo "$failed" > /tmp/la-dashboard-failed.$$
}

draw_footer() {
    echo
    echo -e "${COLOR_GRAY}────────────────────────────────────────────────────────────────────────────────${COLOR_RESET}"
    echo -e "${COLOR_BOLD}Commands:${COLOR_RESET} [${COLOR_CYAN}q${COLOR_RESET}] Quit | [${COLOR_CYAN}r${COLOR_RESET}] Refresh | [${COLOR_CYAN}f${COLOR_RESET}] Filter User | [${COLOR_CYAN}a${COLOR_RESET}] Show All"
}

# =============================================================================
# MAIN DASHBOARD
# =============================================================================

draw_dashboard() {
    # Hide cursor
    echo -ne "$HIDE_CURSOR"

    # Clear screen
    echo -ne "$CLEAR_SCREEN"

    # Draw agents
    draw_agent_list

    # Read counts
    local count
    local running
    local failed
    count=$(cat /tmp/la-dashboard-count.$$ 2>/dev/null || echo "0")
    running=$(cat /tmp/la-dashboard-running.$$ 2>/dev/null || echo "0")
    failed=$(cat /tmp/la-dashboard-failed.$$ 2>/dev/null || echo "0")

    # Draw header (after we know counts)
    draw_header "$count" "$running" "$failed"

    # Re-draw agents below header
    draw_agent_list

    # Draw footer
    draw_footer

    # Cleanup temp files
    rm -f /tmp/la-dashboard-count.$$ /tmp/la-dashboard-running.$$ /tmp/la-dashboard-failed.$$
}

# =============================================================================
# INTERACTIVE MODE
# =============================================================================

interactive_dashboard() {
    while true; do
        draw_dashboard

        # Read key with timeout
        if read -t "$REFRESH_INTERVAL" -n 1 key 2>/dev/null; then
            case "$key" in
                q|Q)
                    break
                    ;;
                r|R)
                    # Force refresh
                    continue
                    ;;
                f|F)
                    FILTER_USER_ONLY="true"
                    ;;
                a|A)
                    FILTER_USER_ONLY="false"
                    ;;
            esac
        fi
    done
}

# =============================================================================
# MAIN
# =============================================================================

usage() {
    cat <<EOF
LaunchAgent Dashboard - Real-time monitoring of LaunchAgents

Usage:
    $(basename "$0") [options]

Options:
    -r, --refresh SECONDS    Refresh interval (default: 3)
    -f, --filter             Show user agents only (default)
    -a, --all                Show all agents
    -h, --help               Show this help

Interactive Commands:
    q - Quit
    r - Refresh now
    f - Filter user agents only
    a - Show all agents

Examples:
    # Default (refresh every 3s, user agents only)
    $(basename "$0")

    # Refresh every 5 seconds
    $(basename "$0") --refresh 5

    # Show all agents
    $(basename "$0") --all

EOF
}

main() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r|--refresh)
                REFRESH_INTERVAL="$2"
                shift 2
                ;;
            -f|--filter)
                FILTER_USER_ONLY="true"
                shift
                ;;
            -a|--all)
                FILTER_USER_ONLY="false"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Check if we're in a terminal
    if [[ ! -t 0 ]]; then
        echo "Error: Dashboard requires an interactive terminal"
        exit 1
    fi

    interactive_dashboard
}

main "$@"
