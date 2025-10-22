# Communication Tools

Essential communication applications for messaging and collaboration.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Homebrew installed

## 1. Telegram

Telegram is a cloud-based messaging app with focus on speed, security, and privacy.

### Installation

```bash
# Install Telegram
brew install --cask telegram

# Launch Telegram
open -a Telegram
```

### First-Time Setup

1. **Launch Telegram** from Applications or Spotlight
2. **Enter Phone Number**
   - Select your country code
   - Enter your phone number
   - Click "Next"
3. **Verify Code**
   - Enter the verification code sent via SMS
   - Or approve login on another device
4. **Set Up Profile**
   - Add profile photo (optional)
   - Set display name
   - Add username (optional, for @username)

### Key Features

- **Cloud Sync**: Messages sync across all devices
- **Secret Chats**: End-to-end encrypted chats
- **Large File Sharing**: Send files up to 2GB
- **Channels**: Broadcast to unlimited subscribers
- **Groups**: Up to 200,000 members
- **Bots**: Automate tasks and integrate services
- **Stickers & GIFs**: Rich media support
- **Voice/Video Calls**: High-quality calls

### Keyboard Shortcuts

```
Cmd+N          - New message
Cmd+F          - Search messages
Cmd+0-9        - Switch between chats
Cmd+Shift+M    - Mute/unmute
Cmd+K          - Quick search
Cmd+W          - Close chat
Cmd+,          - Settings
```

### Settings Configuration

1. **Privacy & Security**
   - Settings → Privacy and Security
   - Configure who can see:
     - Phone number
     - Last seen
     - Profile photo
     - Forwarded messages
   - Enable two-step verification

2. **Notifications**
   - Settings → Notifications and Sounds
   - Customize notification sounds
   - Configure exceptions for specific chats
   - Set "Do Not Disturb" schedule

3. **Data and Storage**
   - Settings → Data and Storage
   - Configure auto-download settings
   - Manage cache size
   - Set download location

4. **Appearance**
   - Settings → Chat Settings
   - Choose theme (light/dark/auto)
   - Adjust text size
   - Enable/disable animations

### Advanced Features

#### Telegram Bots

Useful bots for productivity:

```
@BotFather     - Create and manage bots
@GIF           - Find and send GIFs
@YouTube       - Search YouTube videos
@IFTTT         - Automation integration
@GitHub        - GitHub notifications
```

#### Telegram Desktop Features

```bash
# Quick actions
Cmd+T          - New chat
Cmd+Shift+N    - New group
Cmd+E          - Edit message (last sent)
Cmd+D          - Delete message

# Media
Cmd+P          - Pin message
Cmd+J          - Jump to date
Space          - Play/pause media
```

## 2. WhatsApp

WhatsApp is a widely-used messaging app with end-to-end encryption.

### Installation

```bash
# Install WhatsApp
brew install --cask whatsapp

# Launch WhatsApp
open -a WhatsApp
```

### First-Time Setup

1. **Launch WhatsApp** from Applications
2. **Scan QR Code**
   - Open WhatsApp on your phone
   - Go to Settings → Linked Devices
   - Tap "Link a Device"
   - Scan the QR code on your Mac
3. **Wait for Sync**
   - Messages will sync from your phone
   - May take a few minutes for all chats

### Key Features

- **End-to-End Encryption**: All messages encrypted by default
- **Voice/Video Calls**: Free calls over internet
- **Group Chats**: Up to 1024 participants
- **Status Updates**: Share photos/videos that disappear after 24h
- **Document Sharing**: Send PDFs, documents, photos
- **Voice Messages**: Quick audio messages
- **Desktop Sync**: Seamless sync with phone app

### Important Notes

⚠️ **WhatsApp Desktop Requirements:**
- Must be linked to your phone
- Phone must have internet connection
- Desktop app mirrors phone messages
- Cannot use independently from phone

### Keyboard Shortcuts

```
Cmd+N          - New chat
Cmd+F          - Search messages
Cmd+Shift+]    - Next chat
Cmd+Shift+[    - Previous chat
Cmd+E          - Archive chat
Cmd+Shift+M    - Mute chat
Cmd+Shift+U    - Mark as unread
Cmd+Backspace  - Delete chat
```

### Settings Configuration

1. **Notifications**
   - WhatsApp → Preferences → Notifications
   - Enable/disable notifications
   - Configure notification sounds
   - Show/hide message preview

2. **Privacy**
   - Managed on phone app
   - WhatsApp → Settings → Privacy
   - Configure:
     - Last seen
     - Profile photo
     - About
     - Status
     - Read receipts

3. **Data Usage**
   - WhatsApp → Preferences
   - Enable/disable auto-download
   - Configure media auto-download

### Tips for WhatsApp Desktop

#### Keep Phone Connected

```bash
# WhatsApp Desktop requires phone to be:
# - Powered on
# - Connected to internet
# - WhatsApp running in background
```

#### Backup Chats (Phone)

- iOS: WhatsApp → Settings → Chats → Chat Backup → Back Up Now
- Android: WhatsApp → Settings → Chats → Chat backup → Back Up

#### Multiple Devices

You can link WhatsApp to:
- Up to 4 devices simultaneously
- Desktop, web, and tablets
- All devices work independently (when linked)

## 3. Other Communication Tools

### Slack (Team Communication)

```bash
# Install Slack
brew install --cask slack

# Launch
open -a Slack

# Features:
# - Team workspaces
# - Channels and DMs
# - File sharing
# - App integrations
# - Video calls
```

### Discord (Gaming/Communities)

```bash
# Install Discord
brew install --cask discord

# Launch
open -a Discord

# Features:
# - Voice channels
# - Text channels
# - Screen sharing
# - Community servers
# - Bot integrations
```

### Zoom (Video Conferencing)

```bash
# Install Zoom
brew install --cask zoom

# Launch
open -a Zoom

# Features:
# - Video meetings
# - Screen sharing
# - Virtual backgrounds
# - Recording
# - Breakout rooms
```

### Microsoft Teams (Enterprise)

```bash
# Install Microsoft Teams
brew install --cask microsoft-teams

# Launch
open -a "Microsoft Teams"

# Features:
# - Office 365 integration
# - Team collaboration
# - Video meetings
# - File sharing
# - Third-party integrations
```

## 4. Shell Aliases

Add convenience aliases to your shell configuration:

```bash
# Add to ~/.config/zsh/aliases/aliases.zsh
alias telegram="open -a Telegram"
alias whatsapp="open -a WhatsApp"
alias slack="open -a Slack"
alias discord="open -a Discord"
alias zoom="open -a Zoom"
alias teams="open -a 'Microsoft Teams'"
```

## 5. Privacy & Security Best Practices

### 1. Enable Two-Factor Authentication

- **Telegram**: Settings → Privacy and Security → Two-Step Verification
- **WhatsApp**: Settings → Account → Two-step verification (on phone)
- **Slack**: Settings → Security → Two-factor authentication

### 2. Review Privacy Settings

```bash
# Regular tasks:
# - Review who can see your profile
# - Check active sessions
# - Revoke old device access
# - Review group privacy settings
```

### 3. Backup Important Chats

- Export important conversations
- Save media locally if needed
- Backup contacts regularly

### 4. Be Cautious with Links

- Don't click suspicious links
- Verify sender before opening files
- Enable link previews carefully
- Report spam/scam messages

## 6. Notification Management

### macOS Focus Modes

```bash
# Configure Focus modes to control notifications:
# System Settings → Focus

# Create custom Focus modes:
# - Work: Only work communications
# - Personal: Only personal messages
# - Do Not Disturb: All notifications off
```

### Per-App Notifications

```bash
# System Settings → Notifications
# Configure for each app:
# - Allow notifications
# - Show previews (Never/When Unlocked/Always)
# - Play sound
# - Show in Notification Center
# - Badge app icon
```

## 7. Integration with Other Tools

### Share to Communication Apps

Most apps allow sharing to Telegram/WhatsApp:
```bash
# In Finder, Safari, etc:
# Right-click → Share → Telegram/WhatsApp
```

### Alfred/Raycast Integration

```bash
# Quick launch with Alfred/Raycast:
# - Type "telegram" → Launch Telegram
# - Type "wa" → Launch WhatsApp
# - Configure custom shortcuts
```

## 8. Troubleshooting

### Telegram Not Connecting

```bash
# Check internet connection
ping telegram.org

# Clear cache
# Telegram → Settings → Data and Storage → Clear Cache

# Reinstall if needed
brew reinstall --cask telegram
```

### WhatsApp Connection Issues

```bash
# Ensure phone is connected to internet
# Check phone's WhatsApp is running

# Relink device:
# 1. WhatsApp → Preferences → Log Out
# 2. Reopen WhatsApp and scan QR code again

# Reinstall if needed
brew reinstall --cask whatsapp
```

### Notification Issues

```bash
# Check macOS notification permissions
# System Settings → Notifications → [App Name]
# Ensure "Allow Notifications" is enabled

# Check Do Not Disturb is off
# System Settings → Focus → Do Not Disturb

# Restart app
killall Telegram WhatsApp
open -a Telegram
open -a WhatsApp
```

## 9. Best Practices

### 1. Organize Chats

- **Telegram**: 
  - Use folders to organize chats
  - Pin important conversations
  - Archive inactive chats
  
- **WhatsApp**:
  - Pin important chats (up to 3)
  - Archive inactive chats
  - Use broadcast lists for announcements

### 2. Manage Storage

```bash
# Telegram
# Settings → Data and Storage → Storage Usage
# Clear cache and old media

# WhatsApp
# Settings → Storage and Data
# Manage storage from phone app
```

### 3. Use Desktop Efficiently

- Keep desktop apps running for quick access
- Use keyboard shortcuts
- Enable/disable notifications per chat
- Use status updates for availability

### 4. Multi-Device Usage

- Link devices you regularly use
- Review and revoke unused devices
- Keep phone connected for WhatsApp Desktop
- Telegram works independently on each device

## 10. Command-Line Tools (Advanced)

### Telegram CLI (Optional)

```bash
# For automation and scripting
# Install telegram-cli (community tool)
brew install telegram-cli

# Configure and use for:
# - Automated messages
# - Bot development
# - Scripting workflows
```

## Quick Reference

### Installation Commands

```bash
# Install all communication apps
brew install --cask telegram whatsapp slack discord zoom microsoft-teams

# Launch apps
open -a Telegram
open -a WhatsApp
open -a Slack
```

### Common Shortcuts (Across Apps)

```
Cmd+N          - New message/chat
Cmd+F          - Search
Cmd+,          - Settings/Preferences
Cmd+W          - Close window
Cmd+Q          - Quit app
Cmd+K          - Quick jump/search
```

### Maintenance

```bash
# Update all apps
brew upgrade --cask

# Check which communication apps are installed
brew list --cask | grep -E "(telegram|whatsapp|slack|discord|zoom|teams)"

# Uninstall if needed
brew uninstall --cask telegram
```

## Next Steps

Continue with:
- **[Productivity Tools](13-productivity-tools.md)** - Additional productivity apps
- **[Security & Monitoring](12-security-monitoring.md)** - Secure your communications

---

**Estimated Time**: 10 minutes (installation) + 15 minutes (configuration)  
**Difficulty**: Beginner  
**Last Updated**: October 5, 2025
