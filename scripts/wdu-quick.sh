#!/bin/zsh

# Quick disk usage display - simple version
# Shows disk usage of current directory only (top 10 items)

set -eo pipefail

# Configuration
readonly DEFAULT_LIST_LENGTH=10
readonly MIN_BAR_WIDTH=20
readonly MAX_BAR_WIDTH=40
readonly SIZE_COL_WIDTH=7
readonly MIN_NAME_WIDTH=20

# Initialize colors based on terminal capabilities
declare GREEN YELLOW RED RESET

# Only use colors if outputting to a terminal
if [[ -t 1 ]] || [[ "${FORCE_COLOR:-}" == "1" ]]; then
    # Try 256-color mode if supported, otherwise fall back to 8-color
    if [[ ${TERM:-} =~ 256color ]] || [[ ${COLORTERM:-} =~ (truecolor|24bit) ]]; then
        # 256-color mode
        GREEN=$'\033[38;5;34m'
        YELLOW=$'\033[38;5;220m'
        RED=$'\033[38;5;160m'
        RESET=$'\033[0m'
    else
        # Basic 8-color mode (more compatible)
        GREEN=$'\033[32m'
        YELLOW=$'\033[33m'
        RED=$'\033[31m'
        RESET=$'\033[0m'
    fi
else
    # No colors for non-terminal output
    GREEN=""
    YELLOW=""
    RED=""
    RESET=""
fi

# Main function - no arguments, just shows current directory
main() {
    local list_length=$DEFAULT_LIST_LENGTH

    echo "Analyzing: $(pwd)"

    # Get disk usage data
    local du_output
    local max_size_cmd

    # Use fd if available (much faster), otherwise fall back to du
    if command -v fd >/dev/null 2>&1; then
        # Use fd to list immediate children only, then du each one
        local items
        items=$(fd -d 1 -H --exclude .git . 2>/dev/null | grep -v '^\.$')
        if [[ -n "$items" ]]; then
            du_output=$(echo "$items" | xargs -I {} du -sh "{}" 2>/dev/null | sort -rh | head -n "$list_length")
            max_size_cmd=$(echo "$items" | xargs -I {} du -s "{}" 2>/dev/null | sort -rn | head -1 | awk '{print $1}')
        fi
    else
        # Fall back to traditional du command (disable pipefail temporarily for glob expansion)
        set +o pipefail
        du_output=$(du -sh ./* ./.[!.]* 2>/dev/null | sort -rh | head -n "$list_length")
        max_size_cmd=$(du -s ./* ./.[!.]* 2>/dev/null | sort -rn | head -1 | awk '{print $1}')
        set -o pipefail
    fi

    if [[ -z "$du_output" ]]; then
        echo "┌────────────────────┐"
        echo "│ No files found     │"
        echo "└────────────────────┘"
        return 0
    fi

    # Get max size for scaling (numeric)
    local max_size="${max_size_cmd:-1}"
    [[ -z "$max_size" || "$max_size" -eq 0 ]] && max_size=1

    # Calculate optimal column widths
    local term_width=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}

    # Find longest filename
    local max_name_len=0
    while IFS=$'\t' read -r _ item; do
        [[ -z "${item:-}" ]] && continue
        local item_len=${#item}
        (( item_len > max_name_len )) && max_name_len=$item_len
    done <<< "$du_output"

    # Calculate widths: │ BAR │ SIZE │ NAME │
    # Fixed: borders (6 chars: "│ ", " │ ", " │ ", " │")
    local fixed_width=$((6 + SIZE_COL_WIDTH))
    local available=$((term_width - fixed_width))

    # Allocate space: prefer bar width, then name
    local bar_width=$MIN_BAR_WIDTH
    local name_width=$max_name_len

    # Adjust if content is too wide
    if (( bar_width + name_width > available )); then
        # Prioritize name, adjust bar if needed
        name_width=$((available - bar_width))
        if (( name_width < MIN_NAME_WIDTH )); then
            name_width=$MIN_NAME_WIDTH
            bar_width=$((available - name_width))
            (( bar_width < MIN_BAR_WIDTH )) && bar_width=$MIN_BAR_WIDTH
        fi
    fi

    # Cap bar width at maximum
    (( bar_width > MAX_BAR_WIDTH )) && bar_width=$MAX_BAR_WIDTH

    # Ensure minimum widths
    (( name_width < MIN_NAME_WIDTH )) && name_width=$MIN_NAME_WIDTH

    # Build box borders
    local bar_border=$(printf '─%.0s' $(seq 1 $((bar_width + 2))))
    local size_border=$(printf '─%.0s' $(seq 1 $((SIZE_COL_WIDTH + 2))))
    local name_border=$(printf '─%.0s' $(seq 1 $((name_width + 2))))

    echo "┌${bar_border}┬${size_border}┬${name_border}┐"

    # Display each item
    while IFS=$'\t' read -r human_size item; do
        [[ -z "${item:-}" ]] && continue

        # Get numeric size for percentage
        local size=$(du -s "$item" 2>/dev/null | awk '{print $1}' || echo "0")
        [[ -z "$size" ]] && size=0

        # Calculate bar length
        local percent=$(( (size * bar_width) / max_size ))
        (( percent > bar_width )) && percent=$bar_width
        (( percent < 0 )) && percent=0

        # Select color based on percentage of bar width
        local color=$GREEN
        local threshold_yellow=$((bar_width * 33 / 100))
        local threshold_red=$((bar_width * 50 / 100))
        (( percent >= threshold_yellow )) && color=$YELLOW
        (( percent >= threshold_red )) && color=$RED

        # Create bar
        local bar=""
        if (( percent > 0 )); then
            bar=$(printf "%${percent}s" | tr ' ' '█')
        fi
        local empty=$(printf "%$((bar_width - percent))s" | tr ' ' '░')

        # Truncate filename if needed
        local display_name="$item"
        if (( ${#display_name} > name_width )); then
            display_name="${display_name:0:$((name_width - 3))}..."
        fi

        # Output line with proper alignment
        printf "│ ${color}%-${bar_width}s${RESET} │ %${SIZE_COL_WIDTH}s │ %-${name_width}s │\n" \
            "${bar}${empty}" "$human_size" "$display_name"

    done <<< "$du_output"

    echo "└${bar_border}┴${size_border}┴${name_border}┘"
}

# Run main function (zsh-specific sourcing check)
if [[ -n "${ZSH_VERSION}" ]]; then
    # Running in zsh - check if being sourced
    [[ "${(%):-%x}" == "${0}" ]] && main "$@"
else
    # Fallback for other shells (shouldn't happen with #!/bin/zsh shebang)
    main "$@"
fi
