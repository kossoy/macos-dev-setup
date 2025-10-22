#!/bin/bash

# LaunchAgent Status Monitor
# Quick tool to view and monitor LaunchAgents on macOS

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print header
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}   LaunchAgent Status Monitor${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# List all user agents
list_user_agents() {
    echo -e "${YELLOW}Your Personal LaunchAgents:${NC}"
    echo ""
    
    if [ -d ~/Library/LaunchAgents ] && [ "$(ls -A ~/Library/LaunchAgents 2>/dev/null)" ]; then
        for agent in ~/Library/LaunchAgents/*.plist; do
            if [ -f "$agent" ]; then
                filename=$(basename "$agent" .plist)
                
                # Check if loaded
                if launchctl list | grep -q "$filename"; then
                    status=$(launchctl list | grep "$filename" | awk '{print $2}')
                    pid=$(launchctl list | grep "$filename" | awk '{print $1}')
                    
                    if [ "$status" = "0" ] || [ "$status" = "-" ]; then
                        echo -e "${GREEN}✓${NC} $filename"
                        [ "$pid" != "-" ] && echo -e "   PID: $pid"
                    else
                        echo -e "${RED}✗${NC} $filename (Exit code: $status)"
                    fi
                else
                    echo -e "${YELLOW}○${NC} $filename (Not loaded)"
                fi
            fi
        done
    else
        echo "No personal LaunchAgents found."
    fi
    echo ""
}

# List running agents with PIDs
list_running() {
    echo -e "${YELLOW}Currently Running Agents (with PIDs):${NC}"
    echo ""
    launchctl list | awk 'NR>1 && $1 != "-" {printf "PID: %-6s  Status: %-3s  %s\n", $1, $2, $3}' | head -15
    echo -e "\n${BLUE}(Showing first 15 of $(launchctl list | awk 'NR>1 && $1 != "-"' | wc -l | tr -d ' ') running)${NC}\n"
}

# Show failed agents
list_failed() {
    echo -e "${YELLOW}Failed Agents (Non-zero exit status):${NC}"
    echo ""
    failed=$(launchctl list | awk 'NR>1 && $2 != "0" && $2 != "-" {print}')
    
    if [ -z "$failed" ]; then
        echo -e "${GREEN}No failed agents${NC}"
    else
        echo "$failed" | awk '{printf "Status: %-3s  %s\n", $2, $3}'
    fi
    echo ""
}

# Show statistics
show_stats() {
    echo -e "${YELLOW}Statistics:${NC}"
    echo ""
    
    total=$(launchctl list | tail -n +2 | wc -l | tr -d ' ')
    running=$(launchctl list | awk 'NR>1 && $1 != "-"' | wc -l | tr -d ' ')
    failed=$(launchctl list | awk 'NR>1 && $2 != "0" && $2 != "-"' | wc -l | tr -d ' ')
    user_agents=$(ls ~/Library/LaunchAgents/*.plist 2>/dev/null | wc -l | tr -d ' ')
    
    echo "  Total loaded agents/daemons: $total"
    echo "  Currently running (with PID): $running"
    echo "  Failed (non-zero status): $failed"
    echo "  Your personal agents: $user_agents"
    echo ""
}

# Search for specific agent
search_agent() {
    keyword=$1
    echo -e "${YELLOW}Searching for '$keyword':${NC}"
    echo ""
    launchctl list | grep -i "$keyword"
    echo ""
}

# Show agent details
show_details() {
    agent=$1
    echo -e "${YELLOW}Details for $agent:${NC}"
    echo ""
    
    # Check if loaded
    if launchctl list | grep -q "$agent"; then
        echo -e "${GREEN}Status: Loaded${NC}"
        launchctl list | grep "$agent"
        echo ""
        
        # Try to print full details
        echo "Full configuration:"
        launchctl print gui/$(id -u)/$agent 2>/dev/null || echo "Could not retrieve full details"
    else
        echo -e "${RED}Status: Not loaded${NC}"
    fi
    echo ""
    
    # Check for plist file
    if [ -f ~/Library/LaunchAgents/$agent.plist ]; then
        echo "Configuration file: ~/Library/LaunchAgents/$agent.plist"
        echo ""
        echo "Contents:"
        cat ~/Library/LaunchAgents/$agent.plist
    fi
}

# View logs
view_logs() {
    agent=$1
    echo -e "${YELLOW}Recent logs for $agent:${NC}"
    echo ""
    log show --predicate "eventMessage contains '$agent'" --style syslog --last 1h 2>/dev/null | tail -20
}

# Main menu
show_menu() {
    print_header
    
    case ${1:-} in
        -l|--list)
            list_user_agents
            ;;
        -r|--running)
            list_running
            ;;
        -f|--failed)
            list_failed
            ;;
        -s|--stats)
            show_stats
            ;;
        -a|--all)
            show_stats
            list_user_agents
            list_failed
            ;;
        -S|--search)
            search_agent "$2"
            ;;
        -d|--details)
            show_details "$2"
            ;;
        -L|--logs)
            view_logs "$2"
            ;;
        -h|--help|*)
            echo "Usage: $(basename $0) [OPTIONS] [ARGUMENTS]"
            echo ""
            echo "Options:"
            echo "  -l, --list        List your personal LaunchAgents"
            echo "  -r, --running     Show running agents (with PIDs)"
            echo "  -f, --failed      Show failed agents"
            echo "  -s, --stats       Show statistics"
            echo "  -a, --all         Show all information"
            echo "  -S, --search      Search for agent by keyword"
            echo "  -d, --details     Show details for specific agent"
            echo "  -L, --logs        View recent logs for agent"
            echo "  -h, --help        Show this help"
            echo ""
            echo "Examples:"
            echo "  $(basename $0) -a                                    # Show all info"
            echo "  $(basename $0) -S homebrew                           # Search for 'homebrew'"
            echo "  $(basename $0) -d com.homebrew.autoupdate            # Show details"
            echo "  $(basename $0) -L com.homebrew.autoupdate            # View logs"
            echo ""
            ;;
    esac
}

# Run
show_menu "$@"

