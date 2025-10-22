# LaunchAgent Monitoring & Management Guide

Complete guide to listing, monitoring, and managing LaunchAgents on macOS.

## Understanding LaunchAgents vs LaunchDaemons

- **LaunchAgents**: Run when a user logs in (user context)
- **LaunchDaemons**: Run at system boot (system context, no UI access)

## LaunchAgent Locations

LaunchAgents can be stored in multiple locations (priority order):

1. `~/Library/LaunchAgents/` - User-specific (only you)
2. `/Library/LaunchAgents/` - All users (third-party apps)
3. `/System/Library/LaunchAgents/` - Apple's system agents (read-only)

LaunchDaemons locations:
- `/Library/LaunchDaemons/` - Third-party system daemons
- `/System/Library/LaunchDaemons/` - Apple's system daemons

## Listing LaunchAgents

### Show All Currently Loaded Agents
```bash
# List all loaded agents/daemons
launchctl list

# Count total loaded
launchctl list | wc -l

# Search for specific agent
launchctl list | grep -i keyword
```

### List Installed Agent Files

```bash
# Your personal agents
ls -la ~/Library/LaunchAgents/

# System-wide third-party agents
ls -la /Library/LaunchAgents/

# Apple system agents
ls -la /System/Library/LaunchAgents/

# All at once with details
find ~/Library/LaunchAgents /Library/LaunchAgents /System/Library/LaunchAgents \
  -name "*.plist" 2>/dev/null | sort
```

### List Only Your Custom Agents
```bash
# Exclude Apple's agents
launchctl list | grep -v "com.apple"

# Show only user agents
ls ~/Library/LaunchAgents/*.plist 2>/dev/null
```

## Checking Agent Status

### View Specific Agent Details
```bash
# Check if agent is loaded
launchctl list | grep com.homebrew.autoupdate

# Get detailed info
launchctl print gui/$(id -u)/com.homebrew.autoupdate

# Alternative method (older macOS)
launchctl print user/$(id -u)/com.homebrew.autoupdate
```

### Read Agent Configuration
```bash
# View the plist file
cat ~/Library/LaunchAgents/com.homebrew.autoupdate.plist

# Pretty print with plutil
plutil -p ~/Library/LaunchAgents/com.homebrew.autoupdate.plist

# Validate plist syntax
plutil -lint ~/Library/LaunchAgents/com.homebrew.autoupdate.plist
```

## Managing LaunchAgents

### Load/Unload Agents
```bash
# Load (enable) an agent
launchctl load ~/Library/LaunchAgents/com.example.plist

# Unload (disable) an agent
launchctl unload ~/Library/LaunchAgents/com.example.plist

# Reload (disable then enable)
launchctl unload ~/Library/LaunchAgents/com.example.plist
launchctl load ~/Library/LaunchAgents/com.example.plist
```

### Start/Stop Running Agents
```bash
# Start agent manually (without waiting for schedule)
launchctl start com.example.agent

# Stop running agent
launchctl stop com.example.agent

# Restart agent
launchctl kickstart -k gui/$(id -u)/com.example.agent
```

### Bootstrap/Bootout (Modern Method)
```bash
# Bootstrap (load) - macOS 11+
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.example.plist

# Bootout (unload) - macOS 11+
launchctl bootout gui/$(id -u)/com.example.agent
```

## Monitoring Agent Activity

### View Logs
```bash
# System logs for specific agent
log show --predicate 'processImagePath contains "launchd"' \
  --style syslog --last 1h | grep com.example.agent

# Stream live logs
log stream --predicate 'subsystem == "com.example.agent"' --level debug

# Check agent's stdout/stderr logs (if configured in plist)
tail -f ~/Library/Logs/agent-output.log
```

### Monitor Resource Usage
```bash
# Find PID of running agent
launchctl list | grep com.example.agent

# Monitor with Activity Monitor (GUI)
open -a "Activity Monitor"

# Command line monitoring
ps aux | grep "agent-name"
top -pid <PID>
```

### Debugging Agents
```bash
# Check for errors
launchctl error com.example.agent

# Validate plist syntax
plutil -lint ~/Library/LaunchAgents/com.example.agent.plist

# Test agent manually
/path/to/agent/executable

# Check system logs for errors
log show --predicate 'eventMessage contains "com.example.agent"' \
  --style syslog --last 1d
```

## Useful Commands Reference

### Quick Status Check
```bash
# Count all loaded agents
launchctl list | wc -l

# Show only failed agents (Status != 0)
launchctl list | awk '$2 != 0 && $2 != "-" {print}'

# Show agents with PIDs (currently running)
launchctl list | awk '$1 != "-" {print}'
```

### Batch Operations
```bash
# Unload all user agents (dangerous!)
for agent in ~/Library/LaunchAgents/*.plist; do
  launchctl unload "$agent"
done

# Load all user agents
for agent in ~/Library/LaunchAgents/*.plist; do
  launchctl load "$agent"
done
```

### Export Agent List
```bash
# Save list of all loaded agents
launchctl list > ~/Desktop/launchctl-list.txt

# Create inventory of your agents
ls -lh ~/Library/LaunchAgents/ > ~/Desktop/my-agents.txt
```

## GUI Tools

### LaunchControl (Commercial)
- Visual LaunchAgent/Daemon manager
- https://www.soma-zone.com/LaunchControl/

### Lingon (Commercial)
- Create and manage launch agents
- https://www.peterborgapps.com/lingon/

### Built-in Console.app
```bash
# Open Console for log viewing
open -a Console
```

## Your Current Setup

Based on your system scan:

**Total loaded agents/daemons**: 543

**Your personal agents** (15):
```
~/Library/LaunchAgents/
├── com.bjango.istatmenus-setapp.agent.plist
├── com.bjango.istatmenus-setapp.status.plist
├── com.google.GoogleUpdater.wake.plist
├── com.google.keystone.agent.plist
├── com.google.keystone.xpcservice.plist
├── com.homebrew.autoupdate.plist ← (Just created)
├── com.jetbrains.toolbox.plist
├── com.setapp.DesktopClient.SetappAgent.plist
├── com.setapp.DesktopClient.SetappAssistant.plist
├── com.setapp.DesktopClient.SetappLauncher.plist
├── com.setapp.DesktopClient.SetappUpdater.plist
├── com.user.mount-nas-volumes.plist
└── com.user.vaultwarden-backup.plist
```

**System agents**: 459 Apple agents, plus third-party (Microsoft, JAMF, etc.)

## Best Practices

1. **Naming**: Use reverse domain notation (com.domain.name)
2. **Location**: User agents in `~/Library/LaunchAgents/`
3. **Permissions**: 644 for plist files (`chmod 644`)
4. **Validation**: Always validate with `plutil -lint` before loading
5. **Logging**: Configure StandardOutPath/StandardErrorPath
6. **Testing**: Test manually before scheduling
7. **Documentation**: Comment your custom agents

## Troubleshooting

### Agent Won't Load
```bash
# Validate syntax
plutil -lint ~/Library/LaunchAgents/com.example.plist

# Check permissions
ls -l ~/Library/LaunchAgents/com.example.plist

# Check system logs
log show --predicate 'eventMessage contains "com.example"' --last 10m
```

### Agent Not Running
```bash
# Verify it's loaded
launchctl list | grep com.example

# Check exit status (should be 0 or -)
launchctl list com.example.agent

# Start manually
launchctl start com.example.agent

# Check logs
tail -f ~/Library/Logs/example-agent.log
```

## Security Notes

- Agents run with user permissions
- Be cautious loading third-party agents
- Review plist files before loading
- Disable unused agents to reduce attack surface
- macOS may require approval for new agents (System Settings > Privacy & Security)

## Quick Reference

```bash
# List all
launchctl list

# Load
launchctl load ~/Library/LaunchAgents/com.example.plist

# Unload
launchctl unload ~/Library/LaunchAgents/com.example.plist

# Status
launchctl list | grep com.example

# Details
launchctl print gui/$(id -u)/com.example

# Validate
plutil -lint ~/Library/LaunchAgents/com.example.plist

# Logs
log show --predicate 'eventMessage contains "com.example"' --last 1h
```

