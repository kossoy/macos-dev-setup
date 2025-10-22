# Homebrew Auto-Update with LaunchAgent

Automatically update Homebrew packages daily using macOS LaunchAgent (no cron needed).

## Quick Setup

### 1. Create LaunchAgent Configuration

Create file: `~/Library/LaunchAgents/com.homebrew.autoupdate.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.homebrew.autoupdate</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/bin/zsh</string>
        <string>-c</string>
        <string>/opt/homebrew/bin/brew update &amp;&amp; /opt/homebrew/bin/brew upgrade &amp;&amp; /opt/homebrew/bin/brew cleanup</string>
    </array>
    
    <!-- Daily at 10:00 AM -->
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>10</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    
    <key>StandardOutPath</key>
    <string>/Users/YOUR_USERNAME/Library/Logs/homebrew-autoupdate.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/YOUR_USERNAME/Library/Logs/homebrew-autoupdate-error.log</string>
    
    <key>RunAtLoad</key>
    <false/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
```

**Important**: Replace `YOUR_USERNAME` with your actual username.

### 2. Load LaunchAgent

```bash
# Create logs directory
mkdir -p ~/Library/Logs

# Load the agent
launchctl load ~/Library/LaunchAgents/com.homebrew.autoupdate.plist
```

### 3. Verify

```bash
launchctl list | grep homebrew
```

You should see: `-	0	com.homebrew.autoupdate`

## Management Commands

```bash
# Check status
launchctl list | grep homebrew

# View logs
tail -f ~/Library/Logs/homebrew-autoupdate.log

# Disable
launchctl unload ~/Library/LaunchAgents/com.homebrew.autoupdate.plist

# Re-enable
launchctl load ~/Library/LaunchAgents/com.homebrew.autoupdate.plist

# Test manually (don't wait for schedule)
launchctl start com.homebrew.autoupdate
```

## Schedule Customization

### Run twice daily (10 AM & 6 PM)
```xml
<key>StartCalendarInterval</key>
<array>
    <dict>
        <key>Hour</key>
        <integer>10</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <dict>
        <key>Hour</key>
        <integer>18</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</array>
```

### Run weekly (Monday at 9 AM)
```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Weekday</key>
    <integer>1</integer> <!-- 0=Sunday, 1=Monday -->
    <key>Hour</key>
    <integer>9</integer>
    <key>Minute</key>
    <integer>0</integer>
</dict>
```

After editing, reload:
```bash
launchctl unload ~/Library/LaunchAgents/com.homebrew.autoupdate.plist
launchctl load ~/Library/LaunchAgents/com.homebrew.autoupdate.plist
```

## Notes

- LaunchAgent runs only when you're logged in
- Logs are stored in `~/Library/Logs/homebrew-autoupdate*.log`
- Updates run silently in the background
- Use `brew outdated` to check if updates are working

