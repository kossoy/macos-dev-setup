#!/bin/bash
# =============================================================================
# PROGRESS INDICATOR LIBRARY
# =============================================================================
# Spinners, progress bars, and visual feedback for long-running operations
#
# Usage:
#   source "$HOME/work/scripts/lib/progress.sh"
#   spinner_start "Processing..."
#   # ... long operation ...
#   spinner_stop
#
#   progress_bar 50 100  # Shows 50%
#
# =============================================================================

# Color codes
readonly PROG_COLOR_GREEN='\033[0;32m'
readonly PROG_COLOR_BLUE='\033[0;34m'
readonly PROG_COLOR_YELLOW='\033[1;33m'
readonly PROG_COLOR_CYAN='\033[0;36m'
readonly PROG_COLOR_RESET='\033[0m'

# Spinner state
SPINNER_PID=""
SPINNER_MESSAGE=""

# Progress bar configuration
PROGRESS_BAR_WIDTH="${PROGRESS_BAR_WIDTH:-50}"
PROGRESS_BAR_CHAR="${PROGRESS_BAR_CHAR:-█}"
PROGRESS_BAR_EMPTY_CHAR="${PROGRESS_BAR_EMPTY_CHAR:-░}"

# =============================================================================
# SPINNER FUNCTIONS
# =============================================================================

# Spinner characters (different styles available)
readonly SPINNER_DOTS='⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏'
readonly SPINNER_LINE='- \\ | /'
readonly SPINNER_ARROW='← ↖ ↑ ↗ → ↘ ↓ ↙'
readonly SPINNER_CIRCLE='◐ ◓ ◑ ◒'
readonly SPINNER_BOUNCE='⠁ ⠂ ⠄ ⡀ ⢀ ⠠ ⠐ ⠈'

# Default spinner style
SPINNER_STYLE="${SPINNER_STYLE:-$SPINNER_DOTS}"

# Spinner animation function (runs in background)
_spinner_animate() {
    local message="$1"
    local spinner_chars
    read -ra spinner_chars <<< "$SPINNER_STYLE"

    local i=0
    while true; do
        printf "\r${PROG_COLOR_CYAN}%s${PROG_COLOR_RESET} %s" \
            "${spinner_chars[$i]}" "$message"
        i=$(( (i + 1) % ${#spinner_chars[@]} ))
        sleep 0.1
    done
}

# Start spinner
# Usage: spinner_start "Processing files..."
spinner_start() {
    local message="${1:-Working...}"
    SPINNER_MESSAGE="$message"

    # Hide cursor
    tput civis 2>/dev/null || true

    # Start spinner in background
    _spinner_animate "$message" &
    SPINNER_PID=$!

    # Trap to ensure spinner stops on script exit
    trap 'spinner_stop' EXIT INT TERM
}

# Stop spinner
# Usage: spinner_stop ["success"|"error"|"warning"] ["message"]
spinner_stop() {
    local status="${1:-success}"
    local message="${2:-}"

    if [[ -n "$SPINNER_PID" ]]; then
        kill "$SPINNER_PID" 2>/dev/null || true
        wait "$SPINNER_PID" 2>/dev/null || true
        SPINNER_PID=""
    fi

    # Clear spinner line
    printf "\r\033[K"

    # Show cursor
    tput cnorm 2>/dev/null || true

    # Print final status
    case "$status" in
        success)
            printf "${PROG_COLOR_GREEN}✓${PROG_COLOR_RESET} %s\n" \
                "${message:-$SPINNER_MESSAGE}"
            ;;
        error)
            printf "${PROG_COLOR_RED}✗${PROG_COLOR_RESET} %s\n" \
                "${message:-$SPINNER_MESSAGE}" >&2
            ;;
        warning)
            printf "${PROG_COLOR_YELLOW}⚠${PROG_COLOR_RESET} %s\n" \
                "${message:-$SPINNER_MESSAGE}"
            ;;
        *)
            printf "${PROG_COLOR_BLUE}→${PROG_COLOR_RESET} %s\n" \
                "${message:-$SPINNER_MESSAGE}"
            ;;
    esac
}

# Update spinner message while running
# Usage: spinner_update "New message..."
spinner_update() {
    local new_message="$1"
    SPINNER_MESSAGE="$new_message"

    if [[ -n "$SPINNER_PID" ]] && kill -0 "$SPINNER_PID" 2>/dev/null; then
        spinner_stop "" ""
        spinner_start "$new_message"
    fi
}

# =============================================================================
# PROGRESS BAR FUNCTIONS
# =============================================================================

# Draw a progress bar
# Usage: progress_bar current total ["message"]
progress_bar() {
    local current="$1"
    local total="$2"
    local message="${3:-}"

    # Calculate percentage
    local percent=$((current * 100 / total))

    # Calculate filled bar length
    local filled=$((PROGRESS_BAR_WIDTH * current / total))
    local empty=$((PROGRESS_BAR_WIDTH - filled))

    # Build progress bar
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar+="$PROGRESS_BAR_CHAR"
    done
    for ((i=0; i<empty; i++)); do
        bar+="$PROGRESS_BAR_EMPTY_CHAR"
    done

    # Color based on percentage
    local color="$PROG_COLOR_CYAN"
    if [[ $percent -ge 100 ]]; then
        color="$PROG_COLOR_GREEN"
    elif [[ $percent -ge 75 ]]; then
        color="$PROG_COLOR_BLUE"
    elif [[ $percent -lt 25 ]]; then
        color="$PROG_COLOR_YELLOW"
    fi

    # Print progress bar
    printf "\r${color}[%s]${PROG_COLOR_RESET} %3d%% %s" \
        "$bar" "$percent" "$message"

    # Newline on completion
    if [[ $current -ge $total ]]; then
        echo
    fi
}

# Progress bar with ETA
# Usage: progress_bar_eta current total start_time ["message"]
progress_bar_eta() {
    local current="$1"
    local total="$2"
    local start_time="$3"
    local message="${4:-}"

    # Calculate percentage
    local percent=$((current * 100 / total))

    # Calculate ETA
    local elapsed=$(($(date +%s) - start_time))
    local eta=""
    if [[ $current -gt 0 ]]; then
        local rate=$((elapsed / current))
        local remaining=$((total - current))
        local eta_seconds=$((rate * remaining))
        eta=$(printf "ETA: %02d:%02d" $((eta_seconds / 60)) $((eta_seconds % 60)))
    fi

    # Calculate filled bar length
    local filled=$((PROGRESS_BAR_WIDTH * current / total))
    local empty=$((PROGRESS_BAR_WIDTH - filled))

    # Build progress bar
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar+="$PROGRESS_BAR_CHAR"
    done
    for ((i=0; i<empty; i++)); do
        bar+="$PROGRESS_BAR_EMPTY_CHAR"
    done

    # Color based on percentage
    local color="$PROG_COLOR_CYAN"
    if [[ $percent -ge 100 ]]; then
        color="$PROG_COLOR_GREEN"
    elif [[ $percent -ge 75 ]]; then
        color="$PROG_COLOR_BLUE"
    fi

    # Print progress bar with ETA
    printf "\r${color}[%s]${PROG_COLOR_RESET} %3d%% | %s | %s" \
        "$bar" "$percent" "$eta" "$message"

    # Newline on completion
    if [[ $current -ge $total ]]; then
        echo
    fi
}

# =============================================================================
# STEP INDICATORS
# =============================================================================

# Show step progress (e.g., "Step 2/5")
# Usage: step_indicator 2 5 "Installing packages"
step_indicator() {
    local current="$1"
    local total="$2"
    local message="${3:-}"

    printf "${PROG_COLOR_BLUE}[%d/%d]${PROG_COLOR_RESET} %s\n" \
        "$current" "$total" "$message"
}

# Show completed step
# Usage: step_complete "Package installed"
step_complete() {
    local message="$1"
    printf "${PROG_COLOR_GREEN}✓${PROG_COLOR_RESET} %s\n" "$message"
}

# Show failed step
# Usage: step_failed "Package installation failed"
step_failed() {
    local message="$1"
    printf "${PROG_COLOR_RED}✗${PROG_COLOR_RESET} %s\n" "$message" >&2
}

# Show skipped step
# Usage: step_skipped "Package already installed"
step_skipped() {
    local message="$1"
    printf "${PROG_COLOR_YELLOW}⊘${PROG_COLOR_RESET} %s\n" "$message"
}

# =============================================================================
# INDETERMINATE PROGRESS
# =============================================================================

# Show an indeterminate progress bar (scrolling effect)
_indeterminate_progress() {
    local message="$1"
    local width="${2:-$PROGRESS_BAR_WIDTH}"

    local pos=0
    local direction=1

    while true; do
        local bar=""
        for ((i=0; i<width; i++)); do
            if [[ $i -eq $pos ]]; then
                bar+="⬤"
            else
                bar+="○"
            fi
        done

        printf "\r${PROG_COLOR_CYAN}[%s]${PROG_COLOR_RESET} %s" "$bar" "$message"

        pos=$((pos + direction))
        if [[ $pos -ge $width ]] || [[ $pos -lt 0 ]]; then
            direction=$((-direction))
            pos=$((pos + 2 * direction))
        fi

        sleep 0.1
    done
}

# Start indeterminate progress indicator
# Usage: progress_indeterminate_start "Waiting for response..."
progress_indeterminate_start() {
    local message="${1:-Processing...}"

    # Hide cursor
    tput civis 2>/dev/null || true

    # Start in background
    _indeterminate_progress "$message" &
    SPINNER_PID=$!

    trap 'progress_indeterminate_stop' EXIT INT TERM
}

# Stop indeterminate progress
# Usage: progress_indeterminate_stop ["message"]
progress_indeterminate_stop() {
    local message="${1:-}"

    if [[ -n "$SPINNER_PID" ]]; then
        kill "$SPINNER_PID" 2>/dev/null || true
        wait "$SPINNER_PID" 2>/dev/null || true
        SPINNER_PID=""
    fi

    # Clear line
    printf "\r\033[K"

    # Show cursor
    tput cnorm 2>/dev/null || true

    if [[ -n "$message" ]]; then
        printf "${PROG_COLOR_GREEN}✓${PROG_COLOR_RESET} %s\n" "$message"
    fi
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Show a countdown timer
# Usage: countdown 10 "Starting in"
countdown() {
    local seconds="$1"
    local message="${2:-Countdown}"

    for ((i=seconds; i>0; i--)); do
        printf "\r${PROG_COLOR_YELLOW}%s: %d${PROG_COLOR_RESET}" "$message" "$i"
        sleep 1
    done
    printf "\r\033[K"
}

# Show elapsed time
# Usage: elapsed_time start_timestamp
elapsed_time() {
    local start="$1"
    local end="${2:-$(date +%s)}"
    local elapsed=$((end - start))

    if [[ $elapsed -lt 60 ]]; then
        printf "%ds" "$elapsed"
    elif [[ $elapsed -lt 3600 ]]; then
        printf "%dm %ds" $((elapsed / 60)) $((elapsed % 60))
    else
        printf "%dh %dm %ds" $((elapsed / 3600)) $(((elapsed % 3600) / 60)) $((elapsed % 60))
    fi
}

# =============================================================================
# EXPORT FUNCTIONS
# =============================================================================

export -f spinner_start
export -f spinner_stop
export -f spinner_update
export -f progress_bar
export -f progress_bar_eta
export -f step_indicator
export -f step_complete
export -f step_failed
export -f step_skipped
export -f progress_indeterminate_start
export -f progress_indeterminate_stop
export -f countdown
export -f elapsed_time
