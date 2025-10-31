#!/bin/bash
# =============================================================================
# NAS MOUNT LAUNCHAGENT CONTROL SCRIPT
# =============================================================================
# Easily enable, disable, or check status of automatic NAS mounting at login
# =============================================================================

set -euo pipefail

PLIST_PATH="$HOME/Library/LaunchAgents/com.befeast.mount-nas-volumes.plist"
LABEL="com.befeast.mount-nas-volumes"
LOG_PATH="$HOME/Library/Logs/mount-nas-volumes.log"
ERROR_LOG_PATH="$HOME/Library/Logs/mount-nas-volumes-error.log"

show_usage() {
    cat << EOF
🔧 NAS Mount LaunchAgent Control

Usage: $(basename "$0") [command]

Commands:
  enable      Load and enable automatic mounting at login
  disable     Disable automatic mounting at login
  status      Show current status and recent logs
  restart     Restart the service (unload and reload)
  logs        Show recent log output
  test        Run the mount script manually

EOF
}

check_status() {
    echo "📊 LaunchAgent Status"
    echo "===================="
    echo ""
    
    if [[ -f "$PLIST_PATH" ]]; then
        echo "✅ LaunchAgent file exists: $PLIST_PATH"
    else
        echo "❌ LaunchAgent file not found: $PLIST_PATH"
        return 1
    fi
    
    if launchctl list | grep -q "$LABEL"; then
        echo "✅ LaunchAgent is loaded and active"
    else
        echo "⚠️  LaunchAgent is not currently loaded"
    fi
    
    echo ""
    echo "📝 Recent Logs (last 10 lines):"
    echo "================================"
    if [[ -f "$LOG_PATH" ]]; then
        tail -10 "$LOG_PATH"
    else
        echo "(No logs yet)"
    fi
    
    if [[ -f "$ERROR_LOG_PATH" && -s "$ERROR_LOG_PATH" ]]; then
        echo ""
        echo "⚠️  Errors Found:"
        echo "================"
        tail -10 "$ERROR_LOG_PATH"
    fi
}

enable_agent() {
    echo "🚀 Enabling NAS mount at login..."
    
    if ! [[ -f "$PLIST_PATH" ]]; then
        echo "❌ LaunchAgent plist not found at: $PLIST_PATH"
        echo "Please run the setup first."
        exit 1
    fi
    
    # Unload first if already loaded
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    
    # Load the agent
    if launchctl load "$PLIST_PATH"; then
        echo "✅ LaunchAgent enabled successfully!"
        echo "NAS volumes will be mounted automatically at next login."
    else
        echo "❌ Failed to enable LaunchAgent"
        exit 1
    fi
}

disable_agent() {
    echo "🛑 Disabling NAS mount at login..."
    
    if launchctl unload "$PLIST_PATH" 2>/dev/null; then
        echo "✅ LaunchAgent disabled successfully!"
        echo "NAS volumes will no longer be mounted automatically at login."
    else
        echo "⚠️  LaunchAgent was not loaded (already disabled?)"
    fi
}

restart_agent() {
    echo "🔄 Restarting LaunchAgent..."
    disable_agent
    sleep 1
    enable_agent
}

show_logs() {
    echo "📝 Mount Logs"
    echo "============="
    if [[ -f "$LOG_PATH" ]]; then
        cat "$LOG_PATH"
    else
        echo "(No logs found)"
    fi
    
    if [[ -f "$ERROR_LOG_PATH" && -s "$ERROR_LOG_PATH" ]]; then
        echo ""
        echo "⚠️  Error Logs"
        echo "============="
        cat "$ERROR_LOG_PATH"
    fi
}

test_mount() {
    echo "🧪 Testing mount script manually..."
    echo ""
    /Users/i065699/work/scripts/mount-nas-volumes.sh
}

# Main script
case "${1:-}" in
    enable)
        enable_agent
        ;;
    disable)
        disable_agent
        ;;
    status)
        check_status
        ;;
    restart)
        restart_agent
        ;;
    logs)
        show_logs
        ;;
    test)
        test_mount
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
