#!/bin/zsh

# Browser Switching Test Script
# Tests browser switching functionality and diagnoses issues

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Emojis
CHECK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  🌐 Browser Switching Test Script"
echo "═══════════════════════════════════════════════════════"
echo ""

# Test 1: Check if defaultbrowser is installed
echo "${BLUE}Test 1: Check if defaultbrowser is installed${NC}"
if command -v defaultbrowser &> /dev/null; then
    echo "${GREEN}${CHECK} defaultbrowser is installed${NC}"
    DEFAULTBROWSER_VERSION=$(defaultbrowser --version 2>/dev/null || echo "unknown")
    echo "   Version: $DEFAULTBROWSER_VERSION"
else
    echo "${RED}${CROSS} defaultbrowser is NOT installed${NC}"
    echo "${YELLOW}${WARNING} Install with: brew install defaultbrowser${NC}"
    exit 1
fi
echo ""

# Test 2: List available browsers
echo "${BLUE}Test 2: List available browsers${NC}"
echo "Available browsers on your system:"
defaultbrowser 2>/dev/null || {
    echo "${RED}${CROSS} Failed to list browsers${NC}"
    exit 1
}
echo ""

# Test 3: Check current default browser
echo "${BLUE}Test 3: Check current default browser${NC}"
CURRENT_BROWSER=$(defaults read ~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers 2>/dev/null | grep -A 2 "https" | grep LSHandlerRoleAll | awk -F'"' '{print $2}' | head -1)
if [ -z "$CURRENT_BROWSER" ]; then
    # Try alternate method
    CURRENT_BROWSER=$(defaultbrowser 2>&1 | grep "Current default:" | awk '{print $3}')
fi

if [ -n "$CURRENT_BROWSER" ]; then
    echo "${GREEN}${CHECK} Current default browser: $CURRENT_BROWSER${NC}"
else
    echo "${YELLOW}${WARNING} Could not determine current browser${NC}"
fi
echo ""

# Test 4: Check environment variables
echo "${BLUE}Test 4: Check environment variables${NC}"
if [ -n "$WORK_BROWSER" ]; then
    echo "${GREEN}${CHECK} WORK_BROWSER is set: $WORK_BROWSER${NC}"
else
    echo "${YELLOW}${WARNING} WORK_BROWSER is not set (defaults to 'chrome')${NC}"
fi

if [ -n "$PERSONAL_BROWSER" ]; then
    echo "${GREEN}${CHECK} PERSONAL_BROWSER is set: $PERSONAL_BROWSER${NC}"
else
    echo "${YELLOW}${WARNING} PERSONAL_BROWSER is not set (defaults to 'safari')${NC}"
fi
echo ""

# Test 5: Check if browsers are actually installed
echo "${BLUE}Test 5: Check if configured browsers are installed${NC}"

WORK_BR="${WORK_BROWSER:-chrome}"
PERSONAL_BR="${PERSONAL_BROWSER:-safari}"

check_browser_installed() {
    local browser=$1
    case $browser in
        chrome)
            [ -d "/Applications/Google Chrome.app" ] && return 0 || return 1
            ;;
        safari)
            [ -d "/Applications/Safari.app" ] && return 0 || return 1
            ;;
        firefox)
            [ -d "/Applications/Firefox.app" ] && return 0 || return 1
            ;;
        brave)
            [ -d "/Applications/Brave Browser.app" ] && return 0 || return 1
            ;;
        edge)
            [ -d "/Applications/Microsoft Edge.app" ] && return 0 || return 1
            ;;
        arc)
            [ -d "/Applications/Arc.app" ] && return 0 || return 1
            ;;
        *)
            return 1
            ;;
    esac
}

if check_browser_installed "$WORK_BR"; then
    echo "${GREEN}${CHECK} Work browser ($WORK_BR) is installed${NC}"
else
    echo "${RED}${CROSS} Work browser ($WORK_BR) is NOT installed${NC}"
fi

if check_browser_installed "$PERSONAL_BR"; then
    echo "${GREEN}${CHECK} Personal browser ($PERSONAL_BR) is installed${NC}"
else
    echo "${RED}${CROSS} Personal browser ($PERSONAL_BR) is NOT installed${NC}"
fi
echo ""

# Test 6: Test switching to work browser
echo "${BLUE}Test 6: Test switching to work browser ($WORK_BR)${NC}"
echo "Attempting to switch to $WORK_BR..."
echo "${YELLOW}${INFO} Watch for confirmation dialogs...${NC}"

# Capture the output and look for confirmation dialog message
OUTPUT=$(defaultbrowser "$WORK_BR" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "${GREEN}${CHECK} Switch command executed${NC}"
    
    # Wait a moment for the change to take effect
    sleep 2
    
    # Verify the switch
    NEW_BROWSER=$(defaults read ~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers 2>/dev/null | grep -A 2 "https" | grep LSHandlerRoleAll | awk -F'"' '{print $2}' | head -1)
    
    if [[ "$NEW_BROWSER" == *"$WORK_BR"* ]] || [[ "$NEW_BROWSER" == *"chrome"* ]]; then
        echo "${GREEN}${CHECK} Browser successfully switched to $WORK_BR${NC}"
    else
        echo "${RED}${CROSS} Browser switch may have failed${NC}"
        echo "   Expected: $WORK_BR"
        echo "   Got: $NEW_BROWSER"
    fi
else
    echo "${RED}${CROSS} Switch command failed with exit code: $EXIT_CODE${NC}"
    echo "   Output: $OUTPUT"
fi

# Check if confirmation dialog was shown
if echo "$OUTPUT" | grep -qi "dialog\|confirm\|prompt"; then
    echo "${RED}${WARNING} CONFIRMATION DIALOG DETECTED${NC}"
    echo ""
    echo "This means browser switching requires manual confirmation."
    echo "To fix this, see 'Permission Fixes' section below."
fi
echo ""

# Test 7: Test switching to personal browser
echo "${BLUE}Test 7: Test switching to personal browser ($PERSONAL_BR)${NC}"
echo "Attempting to switch to $PERSONAL_BR..."
echo "${YELLOW}${INFO} Watch for confirmation dialogs...${NC}"

OUTPUT=$(defaultbrowser "$PERSONAL_BR" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "${GREEN}${CHECK} Switch command executed${NC}"
    
    # Wait a moment for the change to take effect
    sleep 2
    
    # Verify the switch
    NEW_BROWSER=$(defaults read ~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers 2>/dev/null | grep -A 2 "https" | grep LSHandlerRoleAll | awk -F'"' '{print $2}' | head -1)
    
    if [[ "$NEW_BROWSER" == *"$PERSONAL_BR"* ]] || [[ "$NEW_BROWSER" == *"safari"* ]]; then
        echo "${GREEN}${CHECK} Browser successfully switched to $PERSONAL_BR${NC}"
    else
        echo "${RED}${CROSS} Browser switch may have failed${NC}"
        echo "   Expected: $PERSONAL_BR"
        echo "   Got: $NEW_BROWSER"
    fi
else
    echo "${RED}${CROSS} Switch command failed with exit code: $EXIT_CODE${NC}"
    echo "   Output: $OUTPUT"
fi

if echo "$OUTPUT" | grep -qi "dialog\|confirm\|prompt"; then
    echo "${RED}${WARNING} CONFIRMATION DIALOG DETECTED${NC}"
fi
echo ""

# Test 8: Test opening a URL
echo "${BLUE}Test 8: Test opening a URL in default browser${NC}"
echo "This will open GitHub in your current default browser..."
read -q "RESPONSE?Press 'y' to test opening https://github.com: "
echo ""

if [[ "$RESPONSE" == "y" ]]; then
    open "https://github.com"
    echo "${GREEN}${CHECK} URL opened. Verify it opened in the correct browser.${NC}"
else
    echo "${YELLOW}⏭ Skipped URL test${NC}"
fi
echo ""

# Summary
echo "═══════════════════════════════════════════════════════"
echo "  📊 Test Summary"
echo "═══════════════════════════════════════════════════════"
echo ""

# Diagnose issues
echo "${BLUE}Common Issues & Fixes:${NC}"
echo ""

echo "${YELLOW}Issue 1: Confirmation Dialog Appears${NC}"
echo "This happens when Terminal/iTerm doesn't have proper permissions."
echo ""
echo "Fix Option 1 - Grant Full Disk Access:"
echo "  1. Open System Settings"
echo "  2. Go to Privacy & Security → Full Disk Access"
echo "  3. Enable for Terminal.app (or iTerm.app)"
echo "  4. Restart Terminal"
echo ""
echo "Fix Option 2 - Use swiftdefaultapps (alternative tool):"
echo "  brew install lord/tap/swiftdefaultapps"
echo "  # Then modify your context functions to use it"
echo ""
echo "Fix Option 3 - Use duti (another alternative):"
echo "  brew install duti"
echo "  # More reliable, no dialogs"
echo ""

echo "${YELLOW}Issue 2: Browser Switch Doesn't Persist${NC}"
echo "Browser might be resetting itself as default."
echo ""
echo "Fix:"
echo "  1. In each browser, disable 'Check if default browser'"
echo "  2. Chrome: Settings → Default browser → Turn off checking"
echo "  3. Safari: Preferences → General → Uncheck default browser"
echo ""

echo "${YELLOW}Issue 3: Switch Works But Context Functions Don't${NC}"
echo "Check if browser switching is in your context functions."
echo ""
echo "Verify in ~/.config/zsh/functions/functions.zsh:"
echo "  - work() function should call: defaultbrowser \"\${WORK_BROWSER:-chrome}\""
echo "  - personal() function should call: defaultbrowser \"\${PERSONAL_BROWSER:-safari}\""
echo ""

echo "═══════════════════════════════════════════════════════"
echo "  🔧 Recommended Next Steps"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "1. If you see confirmation dialogs:"
echo "   → Grant Full Disk Access to Terminal (see above)"
echo "   → OR switch to 'duti' tool (more reliable)"
echo ""
echo "2. If switches don't persist:"
echo "   → Disable default browser checking in each browser"
echo ""
echo "3. For best reliability:"
echo "   ${GREEN}brew install duti${NC}"
echo "   Then see: guides/browser-switching-duti-fix.md"
echo ""
echo "Test complete!"
echo ""

