#!/bin/bash

# LaunchAgent Reload Script
# Reload (unload + load) one or more LaunchAgents

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
    echo -e "${BLUE}   LaunchAgent Reload Tool${NC}"
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
                    status=$(launchctl list | grep "$filename" | awk '{print $2}')
                    if [ "$status" = "0" ] || [ "$status" = "-" ]; then
                        echo -e "  ${GREEN}✓${NC} $filename ${BLUE}(loaded, running)${NC}"
                    else
                        echo -e "  ${RED}✗${NC} $filename ${RED}(loaded, failed: $status)${NC}"
                    fi
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

# Reload a single agent
reload_agent() {
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

    # Check if plist file exists
    if [ ! -f "$plist_file" ]; then
        echo -e "${RED}✗${NC} Agent not found: $plist_file"
        return 1
    fi

    local agent_name=$(basename "$plist_file" .plist)

    echo -e "${BLUE}→${NC} Reloading $agent_name..."

    # Unload if currently loaded
    if launchctl list | grep -q "$agent_name"; then
        echo -e "  ${YELLOW}Unloading...${NC}"
        launchctl unload "$plist_file" 2>/dev/null || true
        sleep 0.5
    fi

    # Load the agent
    echo -e "  ${YELLOW}Loading...${NC}"
    if launchctl load "$plist_file" 2>&1; then
        echo -e "${GREEN}✓${NC} Successfully reloaded: $agent_name"

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
                echo -e "  ${YELLOW}Tip: Check logs with: la-status -L $agent_name${NC}"
            fi
        fi
    else
        echo -e "${RED}✗${NC} Failed to reload: $agent_name"
        return 1
    fi
}

# Usage
show_usage() {
    echo "Usage: $(basename "$0") [OPTIONS] [AGENT_NAME...]"
    echo ""
    echo "Reload (unload + load) one or more LaunchAgents"
    echo ""
    echo "Options:"
    echo "  -l, --list    List all available agents with status"
    echo "  -a, --all     Reload all agents"
    echo "  -h, --help    Show this help"
    echo ""
    echo "Arguments:"
    echo "  AGENT_NAME    Name of the agent to reload (with or without .plist extension)"
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
            echo -e "${YELLOW}Reloading all agents...${NC}"
            echo ""

            reloaded_count=0
            failed_count=0

            if [ -d "$AGENT_DIR" ]; then
                for agent in "$AGENT_DIR"/*.plist; do
                    if [ -f "$agent" ]; then
                        if reload_agent "$agent"; then
                            ((reloaded_count++))
                        else
                            ((failed_count++))
                        fi
                        echo ""
                    fi
                done
            fi

            echo ""
            echo -e "${BLUE}========================================${NC}"
            echo -e "Successfully reloaded: ${GREEN}$reloaded_count${NC}"
            echo -e "Failed: ${RED}$failed_count${NC}"
            echo -e "${BLUE}========================================${NC}"
            ;;
        *)
            # Reload specified agents
            success_count=0
            fail_count=0

            for agent in "$@"; do
                if reload_agent "$agent"; then
                    ((success_count++))
                else
                    ((fail_count++))
                fi
                echo ""
            done

            # Summary
            if [ $# -gt 1 ]; then
                echo -e "${BLUE}========================================${NC}"
                echo -e "Successfully reloaded: ${GREEN}$success_count${NC}"
                echo -e "Failed: ${RED}$fail_count${NC}"
                echo -e "${BLUE}========================================${NC}"
            fi
            ;;
    esac
}

main "$@"
