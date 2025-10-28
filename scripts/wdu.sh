#!/bin/zsh

# Enhanced graphical disk usage display
# Original thanks to bolk http://bolknote.ru/2011/09/14/~3407#07

set -eo pipefail

# Configuration
readonly DEFAULT_LIST_LENGTH=10
readonly MIN_BAR_WIDTH=20
readonly MAX_BAR_WIDTH=50
readonly SIZE_COL_WIDTH=7
readonly MIN_NAME_WIDTH=20
readonly BAR_CHAR="█"  # Default bar character

# Initialize colors based on terminal capabilities
declare color_green color_yellow color_red color_reset

# Only use colors if outputting to a terminal
if [[ -t 1 ]] || [[ "${FORCE_COLOR:-}" == "1" ]]; then
    # Try 256-color mode if supported, otherwise fall back to 8-color
    if [[ ${TERM:-} =~ 256color ]] || [[ ${COLORTERM:-} =~ (truecolor|24bit) ]]; then
        # 256-color mode
        color_green=$'\033[38;5;34m'
        color_yellow=$'\033[38;5;220m'
        color_red=$'\033[38;5;160m'
        color_reset=$'\033[0m'
    else
        # Basic 8-color mode (more compatible)
        color_green=$'\033[32m'
        color_yellow=$'\033[33m'
        color_red=$'\033[31m'
        color_reset=$'\033[0m'
    fi
else
    # No colors for non-terminal output
    color_green=""
    color_yellow=""
    color_red=""
    color_reset=""
fi

# Print usage information
usage() {
    cat <<EOF
Usage: $(basename "$0") [NUMBER]
Display disk usage in a graphical bar chart format.

Arguments:
  NUMBER    Number of items to display (default: $DEFAULT_LIST_LENGTH)

Example:
  $(basename "$0")      # Show top 10 items
  $(basename "$0") 20   # Show top 20 items
EOF
    exit 1
}

# Display disk usage items with bars
print_items() {
    local list_length=${1:-$DEFAULT_LIST_LENGTH}

    # Check if du command is available
    if ! command -v du &> /dev/null; then
        echo "Error: 'du' command not found" >&2
        return 1
    fi

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

    # Process empty results
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

    # Display items with bars
    while IFS=$'\t' read -r human_size item; do
        # Skip empty items
        [[ -z "${item:-}" ]] && continue

        # Get numeric size for percentage calculation
        local size=$(du -s "$item" 2>/dev/null | awk '{print $1}' || echo "0")
        [[ -z "$size" ]] && size=0

        # Calculate bar length
        local percent=$(( (size * bar_width) / max_size ))
        (( percent > bar_width )) && percent=$bar_width
        (( percent < 0 )) && percent=0

        # Select color based on percentage of bar width
        local bar_color="$color_green"
        local threshold_yellow=$((bar_width * 33 / 100))
        local threshold_red=$((bar_width * 50 / 100))
        (( percent >= threshold_yellow )) && bar_color="$color_yellow"
        (( percent >= threshold_red )) && bar_color="$color_red"

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
        printf "│ ${bar_color}%-${bar_width}s${color_reset} │ %${SIZE_COL_WIDTH}s │ %-${name_width}s │\n" \
            "${bar}${empty}" "$human_size" "$display_name"

    done <<< "$du_output"

    echo "└${bar_border}┴${size_border}┴${name_border}┘"
}

# Main function
main() {
    local list_length=$DEFAULT_LIST_LENGTH

    # Parse arguments
    if [[ ${1:-} ]]; then
        if [[ "$1" == "-h" || "$1" == "--help" ]]; then
            usage
        fi

        if [[ ! "$1" =~ ^[0-9]+$ ]]; then
            echo "Error: Argument must be a positive number" >&2
            usage
        fi

        list_length=$1

        if (( list_length < 1 || list_length > 100 )); then
            echo "Error: Number must be between 1 and 100" >&2
            exit 1
        fi
    fi

    # Check if we're in a readable directory
    if [[ ! -r "." ]]; then
        echo "Error: Cannot read current directory" >&2
        exit 1
    fi

    # Display the chart
    print_items "$list_length"
}

# Run main function (zsh-specific sourcing check)
if [[ -n "${ZSH_VERSION}" ]]; then
    # Running in zsh - check if being sourced
    [[ "${(%):-%x}" == "${0}" ]] && main "$@"
else
    # Fallback for other shells (shouldn't happen with #!/bin/zsh shebang)
    main "$@"
fi
# vim: set ts=4 sw=4 et: