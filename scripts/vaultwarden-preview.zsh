#!/usr/bin/env zsh
# Vaultwarden Encrypted Backup Preview Tool
# Safely preview encrypted backup contents without permanently decrypting
# Version: 1.0.0

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR="$HOME/work/vaultwarden-backups/versions"
TEMP_DIR="/tmp/vaultwarden-preview-$$"

# Cleanup function
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        echo "${YELLOW}🧹 Securely cleaning up temporary files...${NC}"
        # Overwrite with random data before deletion (extra secure)
        find "$TEMP_DIR" -type f -exec shred -n 3 -z -u {} \; 2>/dev/null || \
        find "$TEMP_DIR" -type f -exec rm -P {} \; 2>/dev/null || \
        rm -rf "$TEMP_DIR"
        echo "${GREEN}✅ Cleanup complete${NC}"
    fi
}

# Set trap to cleanup on exit or interrupt
trap cleanup EXIT INT TERM

print_header() {
    echo ""
    echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${CYAN}$1${NC}"
    echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_header "🔐 Vaultwarden Encrypted Backup Preview Tool"

# Check if backup directory exists
if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "${RED}❌ ERROR: Backup directory not found: $BACKUP_DIR${NC}"
    exit 1
fi

# List available backups
echo "${BLUE}📦 Available encrypted backups:${NC}"
echo ""

backups=($(ls -t "$BACKUP_DIR"/vault-*.json 2>/dev/null | grep -v "current"))

if [[ ${#backups[@]} -eq 0 ]]; then
    echo "${RED}❌ No backups found!${NC}"
    exit 1
fi

# Display backups with numbers
i=1
for backup in "${backups[@]}"; do
    filename=$(basename "$backup")
    size=$(du -h "$backup" | cut -f1)
    modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$backup" 2>/dev/null || stat -c "%y" "$backup" | cut -d'.' -f1)
    printf "${GREEN}%2d)${NC} %-35s ${YELLOW}%6s${NC}  ${BLUE}%s${NC}\n" "$i" "$filename" "$size" "$modified"
    ((i++))
done

echo ""
echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get user selection
read "?Select backup number (or 'q' to quit): " selection

if [[ "$selection" == "q" || "$selection" == "Q" ]]; then
    echo "${YELLOW}Cancelled.${NC}"
    exit 0
fi

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#backups[@]} )); then
    echo "${RED}❌ Invalid selection!${NC}"
    exit 1
fi

selected_backup="${backups[$selection]}"
echo "${GREEN}✅ Selected: $(basename "$selected_backup")${NC}"
echo ""

# Get backup password from Keychain
echo "${BLUE}🔑 Retrieving decryption password from Keychain...${NC}"
BACKUP_PASSWORD=$(security find-generic-password -a "$USER" -s "vaultwarden-backup-encrypt" -w 2>/dev/null) || {
    echo "${RED}❌ ERROR: Failed to retrieve backup password from Keychain${NC}"
    exit 1
}

# Create secure temporary directory
mkdir -p "$TEMP_DIR"
chmod 700 "$TEMP_DIR"

TEMP_DECRYPTED="$TEMP_DIR/decrypted.json"

echo "${BLUE}🔓 Decrypting backup...${NC}"

# Decrypt using bw CLI
if ! bw --raw export --format json --password "$BACKUP_PASSWORD" --input "$selected_backup" > "$TEMP_DECRYPTED" 2>/dev/null; then
    # Alternative: Try using openssl if bw doesn't support decryption of existing files
    # For now, we need to use a different approach
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "${YELLOW}⚠️  Warning: jq not installed. Installing for JSON parsing...${NC}"
        brew install jq
    fi
    
    # The encrypted backup is in format: {"encrypted": true, "data": "...", ...}
    # We need the actual Bitwarden CLI to decrypt it
    # Let's use a different approach - extract and show metadata
    
    echo "${YELLOW}Note: Direct decryption requires re-import. Showing backup metadata...${NC}"
    echo ""
    
    # Show file info
    echo "${CYAN}📊 Backup Information:${NC}"
    echo "  File: $(basename "$selected_backup")"
    echo "  Size: $(du -h "$selected_backup" | cut -f1)"
    echo "  Modified: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$selected_backup" 2>/dev/null)"
    echo "  Encrypted: Yes"
    echo ""
    
    # Check if it's encrypted JSON format
    if jq -e '.encrypted' "$selected_backup" &>/dev/null; then
        encrypted=$(jq -r '.encrypted' "$selected_backup")
        echo "  Format: Encrypted JSON"
        
        if [[ "$encrypted" == "true" ]]; then
            echo "${YELLOW}  ⚠️  This backup is encrypted and requires import to view contents${NC}"
            echo ""
            echo "${CYAN}To view contents, you need to:${NC}"
            echo "  1. Import backup to a test account/vault"
            echo "  2. Use the web interface or CLI to browse"
            echo ""
            echo "${BLUE}Quick view options:${NC}"
            echo ""
            read "?Would you like to see raw encrypted data? (y/n): " show_raw
            
            if [[ "$show_raw" =~ ^[Yy]$ ]]; then
                echo ""
                echo "${CYAN}━━━ First 50 lines of encrypted data ━━━${NC}"
                head -n 50 "$selected_backup" | jq '.' 2>/dev/null || head -n 50 "$selected_backup"
            fi
        fi
    else
        # Plain JSON backup (shouldn't happen with new backups)
        echo "  Format: Plain JSON (UNENCRYPTED!)"
        echo ""
        
        item_count=$(jq '[.items[]? // empty] | length' "$selected_backup" 2>/dev/null || echo "unknown")
        folder_count=$(jq '[.folders[]? // empty] | length' "$selected_backup" 2>/dev/null || echo "unknown")
        
        echo "${CYAN}📈 Vault Statistics:${NC}"
        echo "  Total items: $item_count"
        echo "  Total folders: $folder_count"
        echo ""
        
        read "?Would you like to see item names? (y/n): " show_items
        
        if [[ "$show_items" =~ ^[Yy]$ ]]; then
            echo ""
            echo "${CYAN}━━━ Item Names ━━━${NC}"
            jq -r '.items[]? | .name' "$selected_backup" 2>/dev/null | head -20
            echo ""
        fi
    fi
    
    unset BACKUP_PASSWORD
    exit 0
fi

# If we got here, decryption worked (for future versions)
echo "${GREEN}✅ Decrypted successfully${NC}"
echo ""

# Parse and display statistics
item_count=$(jq '[.items[]? // empty] | length' "$TEMP_DECRYPTED" 2>/dev/null || echo "0")
folder_count=$(jq '[.folders[]? // empty] | length' "$TEMP_DECRYPTED" 2>/dev/null || echo "0")

print_header "📈 Vault Statistics"

echo "Total items:   ${GREEN}$item_count${NC}"
echo "Total folders: ${GREEN}$folder_count${NC}"
echo ""

# Show item breakdown by type
echo "${CYAN}Item Types:${NC}"
jq -r '.items[]? | .type' "$TEMP_DECRYPTED" 2>/dev/null | sort | uniq -c | while read count type; do
    case $type in
        1) type_name="Login" ;;
        2) type_name="Secure Note" ;;
        3) type_name="Card" ;;
        4) type_name="Identity" ;;
        *) type_name="Unknown ($type)" ;;
    esac
    printf "  ${BLUE}%-20s${NC} %d\n" "$type_name" "$count"
done

echo ""

# Ask what to display
echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "What would you like to view?"
echo "  ${GREEN}1)${NC} Item names only"
echo "  ${GREEN}2)${NC} Items with folders"
echo "  ${GREEN}3)${NC} Full item details (name, username, URLs)"
echo "  ${GREEN}4)${NC} Folder structure"
echo "  ${GREEN}5)${NC} Search for specific item"
echo "  ${GREEN}q)${NC} Quit"
echo ""

read "?Your choice: " view_choice

case $view_choice in
    1)
        print_header "📝 Item Names"
        jq -r '.items[]? | .name' "$TEMP_DECRYPTED" | sort | nl -w2 -s'. '
        ;;
    2)
        print_header "📁 Items with Folders"
        # Create folder ID to name mapping
        jq -r '.items[]? | "\(.folderId // "no-folder")|\(.name)"' "$TEMP_DECRYPTED" | while IFS='|' read folder_id name; do
            if [[ "$folder_id" == "no-folder" || "$folder_id" == "null" ]]; then
                folder_name="(No Folder)"
            else
                folder_name=$(jq -r ".folders[]? | select(.id == \"$folder_id\") | .name" "$TEMP_DECRYPTED" 2>/dev/null || echo "(Unknown Folder)")
            fi
            printf "  ${BLUE}%-25s${NC} %s\n" "$folder_name" "$name"
        done | sort
        ;;
    3)
        print_header "🔐 Full Item Details"
        jq -r '.items[]? | select(.type == 1) | "Name: \(.name)\nUsername: \(.login.username // "N/A")\nURL: \(.login.uris[0].uri // "N/A")\n---"' "$TEMP_DECRYPTED" | head -100
        ;;
    4)
        print_header "📂 Folder Structure"
        echo "${CYAN}Folders:${NC}"
        jq -r '.folders[]? | "  \(.name)"' "$TEMP_DECRYPTED" | sort
        echo ""
        echo "${CYAN}Items per folder:${NC}"
        jq -r '.items[]? | .folderId // "no-folder"' "$TEMP_DECRYPTED" | sort | uniq -c | while read count folder_id; do
            if [[ "$folder_id" == "no-folder" || "$folder_id" == "null" ]]; then
                folder_name="(No Folder)"
            else
                folder_name=$(jq -r ".folders[]? | select(.id == \"$folder_id\") | .name" "$TEMP_DECRYPTED" 2>/dev/null || echo "(Unknown)")
            fi
            printf "  ${GREEN}%3d${NC} items in ${BLUE}%s${NC}\n" "$count" "$folder_name"
        done
        ;;
    5)
        read "?Enter search term: " search_term
        print_header "🔍 Search Results for: $search_term"
        jq -r ".items[]? | select(.name | test(\"$search_term\"; \"i\")) | \"Name: \(.name)\nUsername: \(.login.username // \"N/A\")\n---\"" "$TEMP_DECRYPTED"
        ;;
    q|Q)
        echo "${YELLOW}Exiting...${NC}"
        ;;
    *)
        echo "${RED}Invalid choice${NC}"
        ;;
esac

echo ""
unset BACKUP_PASSWORD

# Cleanup happens automatically via trap

