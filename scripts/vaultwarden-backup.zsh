#!/usr/bin/env zsh
# Vaultwarden Automated Backup Script for macOS
# Secure version using Keychain and encrypted exports
# Version: 1.0.0
# Last Updated: October 6, 2025

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

CONFIG_FILE="${HOME}/.vaultwarden-backup-config"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ ERROR: Config file not found at $CONFIG_FILE" >&2
  exit 1
fi

source "$CONFIG_FILE"

# Bitwarden CLI command
BW_COMMAND="$(command -v bw)"
if [[ -z "$BW_COMMAND" ]]; then
  echo "❌ ERROR: Bitwarden CLI (bw) not found in PATH" >&2
  exit 1
fi

# -----------------------------------------------------------------------------
# Keychain Functions
# -----------------------------------------------------------------------------

get_keychain_password() {
  local service="$1"
  security find-generic-password \
    -a "$USER" \
    -s "$service" \
    -w 2>/dev/null || {
    echo "❌ ERROR: Failed to retrieve '$service' from Keychain" >&2
    return 1
  }
}

# -----------------------------------------------------------------------------
# Telegram Notification Function
# -----------------------------------------------------------------------------

send_telegram_message() {
  local message="$1"
  
  if [[ "${TELEGRAM_ENABLED:-0}" != "1" ]]; then
    return 0
  fi

  local token=$(get_keychain_password "vaultwarden-backup-telegram-token" 2>/dev/null || echo "")
  local chat_id=$(get_keychain_password "vaultwarden-backup-telegram-chat" 2>/dev/null || echo "")

  if [[ -z "$token" || -z "$chat_id" ]]; then
    echo "⚠️  Telegram credentials not found in Keychain, skipping notification"
    return 0
  fi

  curl -s -X POST "https://api.telegram.org/bot${token}/sendMessage" \
    -d chat_id="${chat_id}" \
    -d text="$message" \
    -d parse_mode="Markdown" &>/dev/null || {
    echo "⚠️  Failed to send Telegram notification"
  }
}

# -----------------------------------------------------------------------------
# Error Handler
# -----------------------------------------------------------------------------

error_handler() {
  local exit_code=$?
  local last_command=${(%):-%_}
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  local err_msg="⚠️ *VaultWarden Backup FAILED*
Host: $(hostname -s)
Time: ${timestamp}
Command: ${last_command}
Exit Code: ${exit_code}"

  echo "\n❌ $err_msg" >&2
  send_telegram_message "$err_msg"
  
  # Cleanup session if exists
  if [[ -n "${BW_SESSION:-}" ]]; then
    "$BW_COMMAND" lock &>/dev/null || true
  fi
  
  exit "$exit_code"
}

trap error_handler ERR

# -----------------------------------------------------------------------------
# Cleanup Function
# -----------------------------------------------------------------------------

cleanup_old_backups() {
  local backup_dir="$1"
  local retention_days="$2"
  
  echo "🧹 Cleaning up backups older than ${retention_days} days..."
  
  # Find and delete old backups
  find "$backup_dir" -name "${BACKUP_PREFIX}-*.json" -type f -mtime +${retention_days} -delete 2>/dev/null || true
  
  # Count remaining backups
  local remaining=$(ls -1 "$backup_dir"/${BACKUP_PREFIX}-*.json 2>/dev/null | wc -l | tr -d ' ')
  echo "   📊 Backups retained: ${remaining}"
}

# -----------------------------------------------------------------------------
# Main Backup Function
# -----------------------------------------------------------------------------

main() {
  local timestamp_human=$(date "+%d %b %Y, %H:%M:%S %z")
  local timestamp_file=$(date "+%Y%m%d-%H%M%S")
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔐 VaultWarden Backup Started"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Time: ${timestamp_human}"
  echo "Host: $(hostname -s)"
  echo ""

  # Create directories
  mkdir -p "$VERSIONS_DIR"
  
  # Retrieve credentials from Keychain
  echo "🔑 Retrieving credentials from Keychain..."
  local master_password=$(get_keychain_password "vaultwarden-backup-master")
  local backup_password=$(get_keychain_password "vaultwarden-backup-encrypt")
  
  # Configure Bitwarden server (logout first if needed)
  echo "🌐 Configuring Bitwarden server: ${BW_SERVER}"
  "$BW_COMMAND" logout &>/dev/null || true
  "$BW_COMMAND" config server "$BW_SERVER" &>/dev/null || true
  
  # Login to Bitwarden
  echo "🔓 Logging in to Bitwarden..."
  local bw_session
  bw_session=$("$BW_COMMAND" login "$BW_ACCOUNT" "$master_password" --raw 2>&1) || {
    # Check if already logged in
    bw_session=$("$BW_COMMAND" unlock "$master_password" --raw 2>&1) || {
      echo "❌ ERROR: Failed to login/unlock Bitwarden" >&2
      exit 1
    }
  }
  
  if [[ -z "$bw_session" ]]; then
    echo "❌ ERROR: Failed to obtain Bitwarden session token" >&2
    exit 1
  fi
  
  export BW_SESSION="$bw_session"
  
  # Sync vault (ensure latest data)
  echo "🔄 Syncing vault..."
  "$BW_COMMAND" sync --session "$BW_SESSION" &>/dev/null || {
    echo "⚠️  Warning: Sync failed, proceeding with cached data"
  }
  
  # Output files
  local output_file="$VERSIONS_DIR/${BACKUP_PREFIX}-${timestamp_file}.json"
  local current_link="$VERSIONS_DIR/${BACKUP_PREFIX}-current.json"
  
  # Export vault (ENCRYPTED)
  echo "💾 Exporting encrypted vault..."
  "$BW_COMMAND" export \
    --session "$BW_SESSION" \
    --format encrypted_json \
    --password "$backup_password" \
    --output "$output_file"
  
  # Verify backup file exists and is not empty
  if [[ ! -s "$output_file" ]]; then
    echo "❌ ERROR: Backup file is missing or empty" >&2
    exit 1
  fi
  
  # Create/update symlink to latest backup
  ln -sf "$(basename "$output_file")" "$current_link"
  
  # Get file size
  local file_size=$(du -h "$output_file" | cut -f1)
  echo "✅ Backup created: ${file_size}"
  echo "   📁 File: $(basename "$output_file")"
  
  # Lock/logout
  echo "🔒 Locking Bitwarden session..."
  "$BW_COMMAND" lock &>/dev/null || true
  
  # Clear sensitive variables
  unset BW_SESSION
  unset master_password
  unset backup_password
  unset bw_session
  
  # Git operations
  if [[ "${GIT_PUSH_ENABLED:-1}" == "1" ]]; then
    echo "📦 Committing to Git..."
    cd "$BACKUP_DIR"
    
    git add "$output_file" "$current_link" 2>/dev/null || true
    
    if git diff --cached --quiet 2>/dev/null; then
      echo "   ℹ️  No changes detected, skipping commit"
    else
      git commit -m "Vault backup: ${timestamp_human}" \
        -m "File: $(basename "$output_file")" \
        -m "Size: ${file_size}" \
        -m "Encrypted: Yes" &>/dev/null
      
      echo "   ⬆️  Pushing to remote..."
      if git push "${GIT_REMOTE:-origin}" "${GIT_BRANCH:-main}" &>/dev/null; then
        echo "   ✅ Pushed to GitHub"
      else
        echo "   ⚠️  Warning: Git push failed"
      fi
    fi
  fi
  
  # Cleanup old backups
  cleanup_old_backups "$VERSIONS_DIR" "${RETENTION_DAILY:-7}"
  
  # Success notification
  local success_msg="✅ *VaultWarden Backup Successful*
Host: $(hostname -s)
Time: ${timestamp_human}
Size: ${file_size}
Encrypted: Yes
File: \`$(basename "$output_file")\`"
  
  send_telegram_message "$success_msg"
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Backup completed successfully"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Run main function
main "$@"

