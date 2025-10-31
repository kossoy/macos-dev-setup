#!/bin/bash
# =============================================================================
# NAS VOLUME MOUNTER WITH NETWORK RETRY
# =============================================================================
# Waits for network connectivity before attempting to mount NAS volumes
# Useful for login agents that may run before network is ready
# =============================================================================

set -euo pipefail

# Configuration
TRUENAS_IP="10.0.0.155"
LENOVO_IP="10.0.0.29"
NAS_USERNAME="oleg"
KEYCHAIN_SERVICE="NAS_Credentials"
MAX_RETRIES=5
RETRY_DELAY=3

# TrueNAS volumes
TRUENAS_VOLUMES=("Applications" "Media" "WinBackup")

# Lenovo volumes  
LENOVO_VOLUMES=("HomeLAB")

# Function to check if host is reachable
check_host() {
    local host=$1
    ping -c 1 -t 2 "$host" >/dev/null 2>&1
}

# Wait for network connectivity
echo "🌐 Checking network connectivity..."
RETRIES=0
while [[ $RETRIES -lt $MAX_RETRIES ]]; do
    if check_host "$TRUENAS_IP"; then
        echo "✅ Network is ready (TrueNAS reachable)"
        break
    fi
    
    RETRIES=$((RETRIES + 1))
    if [[ $RETRIES -lt $MAX_RETRIES ]]; then
        echo "⏳ Network not ready, waiting... (attempt $RETRIES/$MAX_RETRIES)"
        sleep $RETRY_DELAY
    else
        echo "⚠️  Network check failed after $MAX_RETRIES attempts"
        echo "Continuing anyway in case volumes are already mounted..."
    fi
done

# Get password from Keychain
echo "🔑 Retrieving credentials from Keychain..."
NAS_PASSWORD=$(security find-generic-password -a "$NAS_USERNAME" -s "$KEYCHAIN_SERVICE" -w 2>/dev/null || echo "")

if [[ -z "$NAS_PASSWORD" ]]; then
    echo "❌ Failed to retrieve password from Keychain"
    echo "Please run setup-nas-keychain.sh first"
    exit 1
fi

# Get currently mounted volumes
echo "📁 Checking currently mounted volumes..."
MOUNTED_VOLUMES=$(ls /Volumes/ 2>/dev/null || echo "")

# Mount TrueNAS volumes
echo ""
echo "🖥️  Processing TrueNAS volumes..."
for VOLUME in "${TRUENAS_VOLUMES[@]}"; do
    if echo "$MOUNTED_VOLUMES" | grep -q "^${VOLUME}$"; then
        echo "  ✓ $VOLUME is already mounted"
    else
        echo "  ⏳ Mounting $VOLUME..."
        if osascript -e "mount volume \"smb://${NAS_USERNAME}:${NAS_PASSWORD}@${TRUENAS_IP}/${VOLUME}\"" 2>/dev/null; then
            echo "  ✅ $VOLUME mounted successfully"
        else
            echo "  ❌ Failed to mount $VOLUME"
        fi
    fi
done

# Mount Lenovo volumes (no authentication)
echo ""
echo "💻 Processing Lenovo volumes..."
for VOLUME in "${LENOVO_VOLUMES[@]}"; do
    if echo "$MOUNTED_VOLUMES" | grep -q "^${VOLUME}$"; then
        echo "  ✓ $VOLUME is already mounted"
    else
        echo "  ⏳ Mounting $VOLUME..."
        if osascript -e "mount volume \"smb://${LENOVO_IP}/${VOLUME}\"" 2>/dev/null; then
            echo "  ✅ $VOLUME mounted successfully"
        else
            echo "  ❌ Failed to mount $VOLUME"
        fi
    fi
done

echo ""
echo "✅ NAS volume mount process completed"
echo "Timestamp: $(date)"

# Send notification (only if running interactively)
if [[ -t 1 ]]; then
    osascript -e 'display notification "All NAS volumes checked" with title "NAS Mount Complete"'
fi

# Clear sensitive variables
unset NAS_PASSWORD
