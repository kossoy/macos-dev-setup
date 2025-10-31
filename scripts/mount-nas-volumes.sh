#!/bin/bash
# =============================================================================
# NAS VOLUME MOUNTER (Bash + AppleScript Hybrid)
# =============================================================================
# Automatically mounts NAS/SMB volumes using credentials from macOS Keychain
# =============================================================================

set -euo pipefail

# Configuration
TRUENAS_IP="10.0.0.155"
LENOVO_IP="10.0.0.29"
NAS_USERNAME="oleg"
KEYCHAIN_SERVICE="NAS_Credentials"

# TrueNAS volumes
TRUENAS_VOLUMES=("Applications" "Media" "WinBackup")

# Lenovo volumes  
LENOVO_VOLUMES=("HomeLAB")

# Get password from Keychain
echo "🔑 Retrieving credentials from Keychain..."
NAS_PASSWORD=$(security find-generic-password -a "$NAS_USERNAME" -s "$KEYCHAIN_SERVICE" -w 2>/dev/null)

if [[ -z "$NAS_PASSWORD" ]]; then
    echo "❌ Failed to retrieve password from Keychain"
    echo "Please run setup-nas-keychain.sh first"
    exit 1
fi

# Get currently mounted volumes
echo "📁 Checking currently mounted volumes..."
MOUNTED_VOLUMES=$(ls /Volumes/)

# Mount TrueNAS volumes
echo ""
echo "🖥️  Processing TrueNAS volumes..."
for VOLUME in "${TRUENAS_VOLUMES[@]}"; do
    if echo "$MOUNTED_VOLUMES" | grep -q "^${VOLUME}$"; then
        echo "  ✓ $VOLUME is already mounted"
    else
        echo "  ⏳ Mounting $VOLUME..."
        osascript -e "mount volume \"smb://${NAS_USERNAME}:${NAS_PASSWORD}@${TRUENAS_IP}/${VOLUME}\"" 2>/dev/null && \
            echo "  ✅ $VOLUME mounted successfully" || \
            echo "  ❌ Failed to mount $VOLUME"
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
        osascript -e "mount volume \"smb://${LENOVO_IP}/${VOLUME}\"" 2>/dev/null && \
            echo "  ✅ $VOLUME mounted successfully" || \
            echo "  ❌ Failed to mount $VOLUME"
    fi
done

echo ""
echo "✅ NAS volume mount process completed"

# Send notification
osascript -e 'display notification "All NAS volumes checked" with title "NAS Mount Complete"'

# Clear sensitive variables
unset NAS_PASSWORD
