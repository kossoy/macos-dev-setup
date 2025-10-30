#!/bin/bash

# LaunchAgent Unload Script
# Unload one or more LaunchAgents

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
    echo -e "${BLUE}   LaunchAgent Unload Tool${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# List loaded agents
list_loaded() {
    echo -e "${YELLOW}Currently Loaded LaunchAgents:${NC}"
    echo ""

    loaded_count=0

    if [ -d "$AGENT_DIR" ]; then
        for agent in "$AGENT_DIR"/*.plist; do
            if [ -f "$agent" ]; then
                filename=$(basename "$agent" .plist)

                # Check if loaded
                if launchctl list | grep -q "$filename"; then
                    status=$(launchctl list | grep "$filename" | awk '{print $2}')
                    pid=$(launchctl list | grep "$filename" | awk '{print $1}')

                    if [ "$status" = "0" ] || [ "$status" = "-" ]; then
                        echo -e "  ${GREEN}✓${NC} $filename"
                        [ "$pid" != "-" ] && echo -e "     PID: $pid"
                    else
                        echo -e "  ${RED}✗${NC} $filename (Exit code: $status)"
                    fi
                    ((loaded_count++))
                fi
            fi
        done
    fi

    if [ $loaded_count -eq 0 ]; then
        echo -e "  ${YELLOW}No agents currently loaded${NC}"
    fi
    echo ""
}

# Unload a single agent
unload_agent() {
    local agent=$1
    local plist_file

    # Check if it's a full path or just a name
    if [[ "$agent" == *.plist ]]; then
        if [[ "$agent" == "$AGENT_DIR"/* ]]; then
            plist_file="$agent"
        elif [[ "$agent" == /* ]]; then
            plist_file="$agent"
        else
            plist_file="$AGENT_DIR/$agent"
        fi
    else
        # Assume it's just the agent name
        agent_name="${agent%.plist}"
        plist_file="$AGENT_DIR/${agent_name}.plist"
    fi

    local agent_name=$(basename "$plist_file" .plist)

    # Check if loaded
    if ! launchctl list | grep -q "$agent_name"; then
        echo -e "${YELLOW}⚠${NC} $agent_name is not currently loaded"
        return 0
    fi

    # Get current status before unloading
    local status=$(launchctl list | grep "$agent_name" | awk '{print $2}')
    local pid=$(launchctl list | grep "$agent_name" | awk '{print $1}')

    echo -e "${BLUE}→${NC} Unloading $agent_name..."
    if [ "$pid" != "-" ]; then
        echo -e "  ${YELLOW}Stopping process (PID: $pid)${NC}"
    fi

    # Unload the agent
    if launchctl unload "$plist_file" 2>&1; then
        echo -e "${GREEN}✓${NC} Successfully unloaded: $agent_name"

        # Verify it's unloaded
        sleep 0.5
        if launchctl list | grep -q "$agent_name"; then
            echo -e "  ${YELLOW}⚠ Warning: Agent still appears in launchctl list${NC}"
        fi
    else
        echo -e "${RED}✗${NC} Failed to unload: $agent_name"
        return 1
    fi
}

# Usage
show_usage() {
    echo "Usage: $(basename "$0") [OPTIONS] [AGENT_NAME...]"
    echo ""
    echo "Unload one or more LaunchAgents"
    echo ""
    echo "Options:"
    echo "  -l, --list    List all currently loaded agents"
    echo "  -a, --all     Unload all loaded agents"
    echo "  -h, --help    Show this help"
    echo ""
    echo "Arguments:"
    echo "  AGENT_NAME    Name of the agent to unload (with or without .plist extension)"
    echo "                Can specify multiple agent names"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") -l"
    echo "  $(basename "$0") com.homebrew.autoupdate"
    echo "  $(basename "$0") com.homebrew.autoupdate.plist"
    echo "  $(basename "$0") com.user.mount-nas-volumes com.user.vaultwarden-backup"
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
            list_loaded
            exit 0
            ;;
        -a|--all)
            echo -e "${YELLOW}Unloading all agents...${NC}"
            echo ""

            unloaded_count=0
            failed_count=0

            if [ -d "$AGENT_DIR" ]; then
                for agent in "$AGENT_DIR"/*.plist; do
                    if [ -f "$agent" ]; then
                        filename=$(basename "$agent" .plist)

                        # Only unload if currently loaded
                        if launchctl list | grep -q "$filename"; then
                            if unload_agent "$agent"; then
                                ((unloaded_count++))
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
            echo -e "Unloaded: ${GREEN}$unloaded_count${NC}"
            echo -e "Failed: ${RED}$failed_count${NC}"
            echo -e "${BLUE}========================================${NC}"
            ;;
        *)
            # Unload specified agents
            success_count=0
            fail_count=0

            for agent in "$@"; do
                if unload_agent "$agent"; then
                    ((success_count++))
                else
                    ((fail_count++))
                fi
                echo ""
            done

            # Summary
            if [ $# -gt 1 ]; then
                echo -e "${BLUE}========================================${NC}"
                echo -e "Successfully unloaded: ${GREEN}$success_count${NC}"
                echo -e "Failed: ${RED}$fail_count${NC}"
                echo -e "${BLUE}========================================${NC}"
            fi
            ;;
    esac
}

main "$@"
