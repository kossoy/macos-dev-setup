#!/usr/bin/env zsh
# Vaultwarden Backup Monitoring Dashboard
# Version: 1.0.0
# Last Updated: October 6, 2025

set -euo pipefail

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

CONFIG_FILE="${HOME}/.vaultwarden-backup-config"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    BACKUP_DIR="${HOME}/Documents/vaultwarden-backups"
    VERSIONS_DIR="${BACKUP_DIR}/versions"
fi

ALERT_THRESHOLD_HOURS=6  # Alert if backup older than this
WARNING_THRESHOLD_HOURS=4 # Warning if backup older than this

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------

print_header() {
    local title="$1"
    echo ""
    echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${CYAN}${title}${NC}"
    echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_section() {
    local title="$1"
    echo ""
    echo "${BLUE}▌ ${title}${NC}"
    echo "${BLUE}────────────────────────────────────────${NC}"
}

status_icon() {
    local status="$1"
    case $status in
        "ok"|"success"|"good")
            echo "${GREEN}✅${NC}"
            ;;
        "warning"|"caution")
            echo "${YELLOW}⚠️${NC}"
            ;;
        "error"|"critical"|"fail")
            echo "${RED}❌${NC}"
            ;;
        "info")
            echo "${BLUE}ℹ️${NC}"
            ;;
        *)
            echo "•"
            ;;
    esac
}

format_time_ago() {
    local seconds=$1
    local minutes=$((seconds / 60))
    local hours=$((minutes / 60))
    local days=$((hours / 24))
    
    if (( days > 0 )); then
        echo "${days}d ${hours % 24}h ago"
    elif (( hours > 0 )); then
        echo "${hours}h ${minutes % 60}m ago"
    elif (( minutes > 0 )); then
        echo "${minutes}m ago"
    else
        echo "${seconds}s ago"
    fi
}

# -----------------------------------------------------------------------------
# Check Functions
# -----------------------------------------------------------------------------

check_backup_directory() {
    print_section "Backup Directory Status"
    
    if [[ -d "$BACKUP_DIR" ]]; then
        echo "$(status_icon ok) Directory exists: $BACKUP_DIR"
        
        # Check permissions
        if [[ -r "$BACKUP_DIR" && -w "$BACKUP_DIR" ]]; then
            echo "$(status_icon ok) Permissions: Read/Write ✓"
        else
            echo "$(status_icon error) Permissions: Read/Write ✗"
        fi
        
        # Check disk space
        local available=$(df -h "$BACKUP_DIR" | awk 'NR==2 {print $4}')
        local usage=$(df -h "$BACKUP_DIR" | awk 'NR==2 {print $5}')
        echo "$(status_icon info) Disk space: ${available} available (${usage} used)"
        
        # Check if it's a git repo
        if [[ -d "$BACKUP_DIR/.git" ]]; then
            echo "$(status_icon ok) Git repository: Yes"
        else
            echo "$(status_icon warning) Git repository: No"
        fi
    else
        echo "$(status_icon error) Directory not found: $BACKUP_DIR"
        return 1
    fi
}

check_backup_files() {
    print_section "Backup Files"
    
    if [[ ! -d "$VERSIONS_DIR" ]]; then
        echo "$(status_icon error) Versions directory not found"
        return 1
    fi
    
    # Count backup files
    local backup_count=$(ls -1 "$VERSIONS_DIR"/vault-*.json 2>/dev/null | wc -l | tr -d ' ')
    echo "$(status_icon info) Total backups: ${backup_count}"
    
    if (( backup_count == 0 )); then
        echo "$(status_icon error) No backup files found!"
        return 1
    fi
    
    # Get latest backup
    local latest=$(ls -t "$VERSIONS_DIR"/vault-*.json 2>/dev/null | head -1)
    
    if [[ -n "$latest" ]]; then
        local latest_name=$(basename "$latest")
        local latest_size=$(du -h "$latest" | cut -f1)
        local latest_time=$(stat -f %m "$latest" 2>/dev/null || stat -c %Y "$latest")
        local now=$(date +%s)
        local age_seconds=$((now - latest_time))
        local age_hours=$((age_seconds / 3600))
        
        echo ""
        echo "Latest backup:"
        echo "  File: ${latest_name}"
        echo "  Size: ${latest_size}"
        echo "  Age:  $(format_time_ago $age_seconds)"
        
        # Status based on age
        if (( age_hours > ALERT_THRESHOLD_HOURS )); then
            echo "  $(status_icon error) Status: CRITICAL - Backup too old (>${ALERT_THRESHOLD_HOURS}h)"
            return 1
        elif (( age_hours > WARNING_THRESHOLD_HOURS )); then
            echo "  $(status_icon warning) Status: WARNING - Backup aging (>${WARNING_THRESHOLD_HOURS}h)"
        else
            echo "  $(status_icon ok) Status: FRESH"
        fi
        
        # Check if backup is encrypted
        if head -n 1 "$latest" | grep -q '"encrypted":true'; then
            echo "  $(status_icon ok) Encryption: Yes"
        else
            echo "  $(status_icon warning) Encryption: No (plaintext)"
        fi
    else
        echo "$(status_icon error) Could not determine latest backup"
        return 1
    fi
    
    # Show recent backups
    echo ""
    echo "Recent backups:"
    ls -lht "$VERSIONS_DIR"/vault-*.json 2>/dev/null | head -5 | awk '{print "  " $9 " - " $5 " - " $6 " " $7 " " $8}'
}

check_git_status() {
    print_section "Git Repository Status"
    
    if [[ ! -d "$BACKUP_DIR/.git" ]]; then
        echo "$(status_icon warning) Not a git repository"
        return 0
    fi
    
    cd "$BACKUP_DIR"
    
    # Check remote
    local remote=$(git remote -v | grep fetch | awk '{print $2}' | head -1)
    if [[ -n "$remote" ]]; then
        echo "$(status_icon ok) Remote: ${remote}"
    else
        echo "$(status_icon warning) No remote configured"
    fi
    
    # Check current branch
    local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    echo "$(status_icon info) Branch: ${branch}"
    
    # Check commit count
    local commit_count=$(git log --oneline | wc -l | tr -d ' ')
    echo "$(status_icon info) Total commits: ${commit_count}"
    
    # Check last commit
    local last_commit=$(git log -1 --format="%ar - %s" 2>/dev/null)
    if [[ -n "$last_commit" ]]; then
        echo "$(status_icon info) Last commit: ${last_commit}"
    fi
    
    # Check if there are uncommitted changes
    if git diff --quiet && git diff --cached --quiet; then
        echo "$(status_icon ok) Working tree: Clean"
    else
        echo "$(status_icon warning) Working tree: Uncommitted changes"
        git status --short | head -5 | sed 's/^/  /'
    fi
    
    # Check if remote is up to date
    if git remote get-url origin &>/dev/null; then
        git fetch --dry-run &>/dev/null
        local behind=$(git rev-list HEAD..origin/$branch --count 2>/dev/null || echo "0")
        local ahead=$(git rev-list origin/$branch..HEAD --count 2>/dev/null || echo "0")
        
        if (( behind > 0 )); then
            echo "$(status_icon warning) Status: ${behind} commit(s) behind remote"
        elif (( ahead > 0 )); then
            echo "$(status_icon warning) Status: ${ahead} commit(s) ahead of remote (needs push)"
        else
            echo "$(status_icon ok) Status: Up to date with remote"
        fi
    fi
}

check_credentials() {
    print_section "Keychain Credentials"
    
    local all_found=true
    
    for service in "vaultwarden-backup-master" "vaultwarden-backup-encrypt"; do
        if security find-generic-password -a "$USER" -s "$service" &>/dev/null; then
            echo "$(status_icon ok) ${service}"
        else
            echo "$(status_icon error) ${service} - NOT FOUND"
            all_found=false
        fi
    done
    
    # Optional credentials
    for service in "vaultwarden-backup-telegram-token" "vaultwarden-backup-telegram-chat"; do
        if security find-generic-password -a "$USER" -s "$service" &>/dev/null; then
            echo "$(status_icon ok) ${service} (optional)"
        else
            echo "$(status_icon info) ${service} - Not configured (optional)"
        fi
    done
    
    if ! $all_found; then
        return 1
    fi
}

check_bitwarden_cli() {
    print_section "Bitwarden CLI"
    
    if command -v bw &> /dev/null; then
        local version=$(bw --version)
        echo "$(status_icon ok) Installed: ${version}"
        
        # Check server configuration
        local server=$(bw config server 2>/dev/null || echo "not configured")
        echo "$(status_icon info) Server: ${server}"
        
        # Check login status
        local status=$(bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "unknown")
        echo "$(status_icon info) Status: ${status}"
    else
        echo "$(status_icon error) Bitwarden CLI not found"
        echo "  Install with: brew install bitwarden-cli"
        return 1
    fi
}

check_launchagent() {
    print_section "LaunchAgent Status"
    
    local plist="${HOME}/Library/LaunchAgents/com.user.vaultwarden-backup.plist"
    
    if [[ -f "$plist" ]]; then
        echo "$(status_icon ok) Plist file exists"
        
        # Check if loaded
        if launchctl list | grep -q "vaultwarden-backup"; then
            echo "$(status_icon ok) LaunchAgent: Loaded"
            
            # Get status
            local status_output=$(launchctl print gui/$(id -u)/com.user.vaultwarden-backup 2>/dev/null)
            
            # Extract last exit status
            local exit_code=$(echo "$status_output" | grep "last exit code" | awk '{print $NF}')
            if [[ "$exit_code" == "0" ]]; then
                echo "$(status_icon ok) Last run: Success (exit 0)"
            elif [[ -n "$exit_code" ]]; then
                echo "$(status_icon error) Last run: Failed (exit ${exit_code})"
            fi
            
            # Check next run time
            local next_run=$(echo "$status_output" | grep "next run" | cut -d'=' -f2-)
            if [[ -n "$next_run" ]]; then
                echo "$(status_icon info) Next run: ${next_run}"
            fi
        else
            echo "$(status_icon warning) LaunchAgent: Not loaded"
            echo "  Load with: launchctl load $plist"
        fi
    else
        echo "$(status_icon warning) Plist file not found"
        echo "  Expected: $plist"
    fi
}

check_logs() {
    print_section "Recent Logs"
    
    local log_file="${HOME}/Library/Logs/vaultwarden-backup.log"
    local error_log="${HOME}/Library/Logs/vaultwarden-backup-error.log"
    
    if [[ -f "$log_file" ]]; then
        echo "$(status_icon ok) Log file exists: $log_file"
        
        local log_size=$(du -h "$log_file" | cut -f1)
        echo "$(status_icon info) Size: ${log_size}"
        
        echo ""
        echo "Last 10 log entries:"
        tail -n 10 "$log_file" | sed 's/^/  /'
    else
        echo "$(status_icon warning) No log file found (backup may not have run yet)"
    fi
    
    echo ""
    
    if [[ -f "$error_log" && -s "$error_log" ]]; then
        echo "$(status_icon warning) Error log has content:"
        tail -n 10 "$error_log" | sed 's/^/  /'
    else
        echo "$(status_icon ok) No errors in error log"
    fi
}

generate_health_score() {
    local score=100
    local issues=()
    
    # Check backup age
    if [[ -d "$VERSIONS_DIR" ]]; then
        local latest=$(ls -t "$VERSIONS_DIR"/vault-*.json 2>/dev/null | head -1)
        if [[ -n "$latest" ]]; then
            local latest_time=$(stat -f %m "$latest" 2>/dev/null || stat -c %Y "$latest")
            local now=$(date +%s)
            local age_hours=$(( (now - latest_time) / 3600 ))
            
            if (( age_hours > ALERT_THRESHOLD_HOURS )); then
                score=$((score - 30))
                issues+=("Backup too old (${age_hours}h)")
            elif (( age_hours > WARNING_THRESHOLD_HOURS )); then
                score=$((score - 10))
                issues+=("Backup aging (${age_hours}h)")
            fi
        else
            score=$((score - 40))
            issues+=("No backups found")
        fi
    fi
    
    # Check credentials
    for service in "vaultwarden-backup-master" "vaultwarden-backup-encrypt"; do
        if ! security find-generic-password -a "$USER" -s "$service" &>/dev/null; then
            score=$((score - 15))
            issues+=("Missing credential: $service")
        fi
    done
    
    # Check git status
    if [[ -d "$BACKUP_DIR/.git" ]]; then
        cd "$BACKUP_DIR"
        local ahead=$(git rev-list origin/$(git branch --show-current)..HEAD --count 2>/dev/null || echo "0")
        if (( ahead > 5 )); then
            score=$((score - 5))
            issues+=("${ahead} unpushed commits")
        fi
    else
        score=$((score - 10))
        issues+=("Not a git repository")
    fi
    
    # Check LaunchAgent
    if ! launchctl list | grep -q "vaultwarden-backup"; then
        score=$((score - 20))
        issues+=("LaunchAgent not loaded")
    fi
    
    # Cap score at 0
    if (( score < 0 )); then
        score=0
    fi
    
    # Display health score
    print_section "Health Score"
    
    local color=$GREEN
    local status="EXCELLENT"
    
    if (( score < 50 )); then
        color=$RED
        status="CRITICAL"
    elif (( score < 70 )); then
        color=$YELLOW
        status="WARNING"
    elif (( score < 90 )); then
        color=$BLUE
        status="GOOD"
    fi
    
    echo ""
    echo "${color}╔════════════════════════════════╗${NC}"
    echo "${color}║  HEALTH SCORE: ${score}/100        ║${NC}"
    echo "${color}║  STATUS: ${status}$(printf '%*s' $((20 - ${#status})) '')║${NC}"
    echo "${color}╚════════════════════════════════╝${NC}"
    echo ""
    
    if (( ${#issues[@]} > 0 )); then
        echo "${YELLOW}Issues detected:${NC}"
        for issue in "${issues[@]}"; do
            echo "  • $issue"
        done
    else
        echo "${GREEN}No issues detected! 🎉${NC}"
    fi
}

show_statistics() {
    print_section "Statistics"
    
    if [[ ! -d "$VERSIONS_DIR" ]]; then
        echo "$(status_icon warning) No statistics available"
        return
    fi
    
    # Total backups
    local total=$(ls -1 "$VERSIONS_DIR"/vault-*.json 2>/dev/null | wc -l | tr -d ' ')
    echo "Total backups: ${total}"
    
    # Total size
    local total_size=$(du -sh "$VERSIONS_DIR" 2>/dev/null | cut -f1)
    echo "Total size: ${total_size}"
    
    # Average backup size
    if (( total > 0 )); then
        local avg_size=$(du "$VERSIONS_DIR"/vault-*.json 2>/dev/null | awk '{total+=$1; count++} END {if(count>0) print total/count}')
        echo "Average backup size: $(numfmt --to=iec --suffix=B $((avg_size * 512)) 2>/dev/null || echo "${avg_size}K")"
    fi
    
    # Backups per day (last 7 days)
    local today=$(date +%Y%m%d)
    local week_count=0
    for i in {0..6}; do
        local date=$(date -v-${i}d +%Y%m%d 2>/dev/null || date -d "${i} days ago" +%Y%m%d)
        local count=$(ls -1 "$VERSIONS_DIR"/vault-${date}-*.json 2>/dev/null | wc -l | tr -d ' ')
        week_count=$((week_count + count))
    done
    echo "Backups (last 7 days): ${week_count}"
    
    # Git statistics
    if [[ -d "$BACKUP_DIR/.git" ]]; then
        cd "$BACKUP_DIR"
        local commits=$(git log --oneline | wc -l | tr -d ' ')
        echo "Git commits: ${commits}"
        
        local repo_size=$(du -sh "$BACKUP_DIR/.git" 2>/dev/null | cut -f1)
        echo "Git repository size: ${repo_size}"
    fi
}

# -----------------------------------------------------------------------------
# Main Function
# -----------------------------------------------------------------------------

main() {
    local show_full=false
    local show_stats=false
    
    # Parse arguments
    for arg in "$@"; do
        case $arg in
            --full|-f)
                show_full=true
                ;;
            --stats|-s)
                show_stats=true
                ;;
            --help|-h)
                echo "Vaultwarden Backup Monitor"
                echo ""
                echo "Usage: $(basename $0) [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  -f, --full     Show full detailed report"
                echo "  -s, --stats    Show statistics"
                echo "  -h, --help     Show this help message"
                echo ""
                exit 0
                ;;
        esac
    done
    
    print_header "🔐 Vaultwarden Backup System Monitor"
    echo "$(date '+%Y-%m-%d %H:%M:%S')"
    echo "Host: $(hostname -s)"
    
    # Always run these checks
    check_backup_directory
    check_backup_files
    
    if $show_full; then
        check_git_status
        check_credentials
        check_bitwarden_cli
        check_launchagent
        check_logs
    fi
    
    if $show_stats; then
        show_statistics
    fi
    
    generate_health_score
    
    echo ""
    print_header "✨ Monitor Complete"
}

# Run main function
main "$@"

