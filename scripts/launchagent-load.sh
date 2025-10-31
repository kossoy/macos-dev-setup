#!/bin/bash

# LaunchAgent Load Script
# Load one or more LaunchAgents from ~/Library/LaunchAgents/

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

AGENT_DIR="$HOME/Library/LaunchAgents"

# Print header
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}   LaunchAgent Load Tool${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# List available agents
list_agents() {
    echo -e "${YELLOW}Available LaunchAgents:${NC}"
    echo ""

    if [ -d "$AGENT_DIR" ] && [ "$(ls -A "$AGENT_DIR" 2>/dev/null)" ]; then
        for agent in "$AGENT_DIR"/*.plist; do
            if [ -f "$agent" ]; then
                filename=$(basename "$agent" .plist)

                # Check if loaded
                if launchctl list | grep -q "$filename"; then
                    echo -e "  ${GREEN}✓${NC} $filename ${BLUE}(already loaded)${NC}"
                else
                    echo -e "  ${YELLOW}○${NC} $filename ${YELLOW}(not loaded)${NC}"
                fi
            fi
        done
    else
        echo "No LaunchAgents found in $AGENT_DIR"
    fi
    echo ""
}

# Load a single agent
load_agent() {
    local agent=$1
    local plist_file

    # Check if it's a full path or just a name
    if [[ "$agent" == *.plist ]]; then
        plist_file="$agent"
    elif [[ "$agent" == "$AGENT_DIR"/* ]]; then
        plist_file="$agent"
    else
        # Assume it's just the agent name (with or without .plist)
        agent_name="${agent%.plist}"
        plist_file="$AGENT_DIR/${agent_name}.plist"
    fi

    # Check if plist file exists
    if [ ! -f "$plist_file" ]; then
        echo -e "${RED}✗${NC} Agent not found: $plist_file"
        return 1
    fi

    local agent_name=$(basename "$plist_file" .plist)

    # Check if already loaded
    if launchctl list | grep -q "$agent_name"; then
        echo -e "${YELLOW}⚠${NC} $agent_name is already loaded"
        read -p "Reload it? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
        # Unload first
        echo -e "${BLUE}→${NC} Unloading $agent_name..."
        launchctl unload "$plist_file" 2>/dev/null || true
    fi

    # Load the agent
    echo -e "${BLUE}→${NC} Loading $agent_name..."
    if launchctl load "$plist_file" 2>&1; then
        echo -e "${GREEN}✓${NC} Successfully loaded: $agent_name"

        # Show status after a brief delay
        sleep 1
        if launchctl list | grep -q "$agent_name"; then
            status=$(launchctl list | grep "$agent_name" | awk '{print $2}')
            pid=$(launchctl list | grep "$agent_name" | awk '{print $1}')

            if [ "$status" = "0" ] || [ "$status" = "-" ]; then
                echo -e "  ${GREEN}Status: Running${NC}"
                [ "$pid" != "-" ] && echo -e "  PID: $pid"
            else
                echo -e "  ${RED}Status: Failed (Exit code: $status)${NC}"
            fi
        fi
    else
        echo -e "${RED}✗${NC} Failed to load: $agent_name"
        return 1
    fi
}

# Usage
show_usage() {
    echo "Usage: $(basename "$0") [OPTIONS] [AGENT_NAME...]"
    echo ""
    echo "Load one or more LaunchAgents from ~/Library/LaunchAgents/"
    echo ""
    echo "Options:"
    echo "  -l, --list    List all available agents"
    echo "  -a, --all     Load all unloaded agents"
    echo "  -h, --help    Show this help"
    echo ""
    echo "Arguments:"
    echo "  AGENT_NAME    Name of the agent to load (with or without .plist extension)"
    echo "                Can specify multiple agent names"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") -l"
    echo "  $(basename "$0") com.homebrew.autoupdate"
    echo "  $(basename "$0") com.homebrew.autoupdate.plist"
    echo "  $(basename "$0") com.befeast.mount-nas-volumes com.befeast.vaultwarden-backup"
    echo "  $(basename "$0") --all"
    echo ""
}

# Main
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 0
    fi

    print_header

    case "$1" in
        -h|--help)
            show_usage
            exit 0
            ;;
        -l|--list)
            list_agents
            exit 0
            ;;
        -a|--all)
            echo -e "${YELLOW}Loading all unloaded agents...${NC}"
            echo ""

            loaded_count=0
            failed_count=0

            if [ -d "$AGENT_DIR" ]; then
                for agent in "$AGENT_DIR"/*.plist; do
                    if [ -f "$agent" ]; then
                        filename=$(basename "$agent" .plist)

                        # Only load if not already loaded
                        if ! launchctl list | grep -q "$filename"; then
                            if load_agent "$agent"; then
                                ((loaded_count++))
                            else
                                ((failed_count++))
                            fi
                            echo ""
                        fi
                    fi
                done
            fi

            echo ""
            echo -e "${BLUE}========================================${NC}"
            echo -e "Loaded: ${GREEN}$loaded_count${NC}"
            echo -e "Failed: ${RED}$failed_count${NC}"
            echo -e "${BLUE}========================================${NC}"
            ;;
        *)
            # Load specified agents
            success_count=0
            fail_count=0

            for agent in "$@"; do
                if load_agent "$agent"; then
                    ((success_count++))
                else
                    ((fail_count++))
                fi
                echo ""
            done

            # Summary
            if [ $# -gt 1 ]; then
                echo -e "${BLUE}========================================${NC}"
                echo -e "Successfully loaded: ${GREEN}$success_count${NC}"
                echo -e "Failed: ${RED}$fail_count${NC}"
                echo -e "${BLUE}========================================${NC}"
            fi
            ;;
    esac
}

main "$@"
