# Cubase 14 Pro Installation & Setup Guide

This guide covers the complete installation and configuration of Steinberg Cubase 14 Pro on macOS, including initial setup, audio interface configuration, plugin management, and workflow optimization.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Software Installation](#software-installation)
- [Initial Configuration](#initial-configuration)
- [Audio Interface Setup](#audio-interface-setup)
- [Plugin Management](#plugin-management)
- [Project Templates](#project-templates)
- [Optimization](#optimization)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements

**Minimum Requirements:**
- **macOS:** 10.15 Catalina or later (macOS Sequoia 15.0.1 compatible)
- **Processor:** Intel Core i5 or Apple Silicon (M1/M2/M3)
- **RAM:** 8 GB minimum
- **Disk Space:** 70 GB free disk space
- **Display:** 1440 × 900 resolution minimum

**Recommended Requirements:**
- **macOS:** 13 Ventura or later
- **Processor:** Apple M1 Pro/Max/Ultra or Intel Core i7/i9
- **RAM:** 16 GB or more (32 GB for large orchestral projects)
- **Disk Space:** 256 GB SSD (separate drive for samples recommended)
- **Display:** 2560 × 1440 or higher
- **Audio Interface:** Professional USB/Thunderbolt audio interface

### Before You Begin

- **Steinberg Account:** Create account at https://www.steinberg.net/
- **License Information:** Have your Cubase 14 Pro license code ready
- **eLicenser (for older content):** Some legacy libraries may require USB-eLicenser
- **Internet Connection:** Required for download, activation, and updates
- **Backup:** Back up existing Cubase projects if upgrading

---

## Software Installation

### 1. Download Steinberg Download Assistant

All Steinberg software is managed through the **Steinberg Download Assistant**.

#### Installation Steps:

1. **Visit the Steinberg website:**
   ```bash
   # Open in your browser:
   # https://www.steinberg.net/download-assistant/
   ```

2. **Download for macOS:**
   - Click **"Download for macOS"**
   - Save the `.dmg` file to your Downloads folder

3. **Install the Download Assistant:**
   ```bash
   # Open the downloaded .dmg file
   open ~/Downloads/Steinberg_Download_Assistant*.dmg
   
   # Drag to Applications folder
   # Launch from Applications
   ```

4. **Log in to your Steinberg account:**
   - Open **Steinberg Download Assistant**
   - Click **"Sign In"**
   - Enter your Steinberg ID credentials
   - If you don't have an account, click **"Register"**

---

### 2. Activate Your Cubase 14 Pro License

#### Steinberg Licensing (New System):

Cubase 14 uses **Steinberg Licensing** (no USB dongle required for new licenses).

1. **Access your license:**
   - Log in at: https://www.steinberg.net/
   - Navigate to **"My Products"**
   - Enter your Cubase 14 Pro activation code
   - Click **"Activate"**

2. **Download Steinberg Activation Manager:**
   ```bash
   # Available in Download Assistant or:
   # https://www.steinberg.net/activation-manager/
   ```

3. **Install Activation Manager:**
   - Open the downloaded installer
   - Follow installation prompts
   - Restart your Mac when complete

4. **Activate Cubase 14 Pro:**
   - Open **Steinberg Activation Manager**
   - Sign in with your Steinberg ID
   - Your Cubase 14 Pro license will appear
   - Click **"Activate on this Computer"**
   - Activation is complete

#### Legacy eLicenser (for older content):

If you have legacy content requiring the USB-eLicenser:

1. **Install eLicenser Control Center:**
   - Download from Download Assistant
   - Install and restart your Mac

2. **Connect USB-eLicenser:**
   - Plug in your USB-eLicenser dongle
   - Open **eLicenser Control Center**
   - Enter maintenance mode if licenses need transfer

---

### 3. Install Cubase 14 Pro

#### Download and Install:

1. **Open Steinberg Download Assistant**
   ```bash
   open "/Applications/Steinberg Download Assistant.app"
   ```

2. **Select Cubase 14 Pro:**
   - In the **"Products"** tab, find **"Cubase Pro 14"**
   - Check the box next to Cubase Pro 14
   - Also select:
     - ☑ Cubase Pro 14 Application
     - ☑ HALion Sonic SE
     - ☑ Groove Agent SE
     - ☑ Additional Content (optional)
     - ☑ Sound Libraries (optional, ~35 GB)

3. **Choose installation location:**
   ```
   Application: /Applications/Cubase 14/
   VST Plugins: /Library/Audio/Plug-Ins/VST3/
   Content: /Library/Application Support/Steinberg/Content/
   ```

4. **Start download and installation:**
   - Click **"Install"** or **"Download"**
   - The process may take 30-60 minutes depending on selected content
   - Do not interrupt the installation

5. **Complete installation:**
   - Restart your Mac after installation completes
   - Cubase 14 Pro is now installed

---

### 4. First Launch and Setup Assistant

#### Initial Launch:

1. **Launch Cubase 14 Pro:**
   ```bash
   open "/Applications/Cubase 14/Cubase Pro.app"
   ```

2. **License Verification:**
   - Cubase will automatically verify your license
   - If prompted, sign in to Steinberg Activation Manager
   - The application should open successfully

3. **Setup Assistant (First Launch):**
   
   The **Setup Assistant** guides you through initial configuration:

   **a) Audio Interface Selection:**
   - Select your primary audio interface from the dropdown
   - Examples: Audient iD14, Focusrite, Universal Audio, etc.
   - If using aggregate device, select your aggregate device

   **b) MIDI Input Configuration:**
   - Enable connected MIDI controllers
   - Check devices you want to use:
     - ☑ MIDI keyboard
     - ☑ Drum pads
     - ☑ Control surfaces

   **c) VST Plugin Paths:**
   - Cubase will scan for plugins automatically
   - Default paths:
     ```
     /Library/Audio/Plug-Ins/VST/
     /Library/Audio/Plug-Ins/VST3/
     ~/Library/Audio/Plug-Ins/VST/
     ~/Library/Audio/Plug-Ins/VST3/
     ```
   - Add custom paths if you have plugins elsewhere

   **d) Sample Rate & Buffer Size:**
   - **Sample Rate:** 48000 Hz (recommended)
   - **Buffer Size:** 256 samples (adjust later based on needs)

4. **Complete Setup Assistant:**
   - Click **"Next"** through all steps
   - Click **"Finish"** to proceed to main window

---

## Initial Configuration

### 1. Studio Setup (Audio Connections)

Configure audio routing for your interface:

1. **Open Studio Setup:**
   ```
   Cubase > Studio > Studio Setup (Cmd + Shift + P)
   ```

2. **Audio System Settings:**
   - Select **"Audio System"** in the left panel
   
   **Configuration:**
   ```
   ASIO Driver: Select your audio interface
   Sample Rate: 48000 Hz (recommended)
   Control Panel: Click to open interface control panel
   ```

3. **VST Audio System:**
   - Select **"VST Audio System"** in the left panel
   
   **Advanced Options:**
   ```
   ☑ Activate ASIO-Guard
   ASIO-Guard Level: Normal or High
   ☑ Multi Processing
   ☑ Disk Preload: 1-2 seconds
   Audio Priority: Normal
   ```

4. **Port Configuration:**
   - Select your audio interface under **VST Audio System**
   - Enable/disable input and output ports:
     - ☑ Enable visible ports (inputs/outputs you'll use)
     - ☐ Disable unused ports for cleaner routing

5. **Click "Apply" and "OK"**

---

### 2. Audio Connections (Buses)

Set up input, output, and group buses:

1. **Open Audio Connections:**
   ```
   Studio > Audio Connections (F4)
   ```

2. **Outputs Tab:**
   - Create stereo output bus:
     - Click **"Add Bus"**
     - Name: "Stereo Out"
     - Configuration: Stereo
     - Audio Device: Your interface outputs (e.g., iD14 Output 1-2)
   - Create additional buses for headphones, monitors, etc.

3. **Inputs Tab:**
   - Add input buses for recording:
     ```
     - "Vocal Mono" - Mono - Input 1
     - "Guitar Mono" - Mono - Input 2
     - "Stereo In" - Stereo - Inputs 3-4
     - "Line Inputs" - Stereo - Inputs 5-6
     ```

4. **Group/FX Tab:**
   - Create mix groups:
     - "Drums" - Stereo group
     - "Guitars" - Stereo group
     - "Vocals" - Stereo group
   - These can be routed to Stereo Out

5. **Monitor Tab (Control Room - optional):**
   - Enable **Control Room** for advanced monitoring
   - Set up multiple headphone/speaker feeds
   - Configure talkback if needed

---

### 3. Preferences Configuration

Optimize Cubase preferences for your workflow:

1. **Open Preferences:**
   ```
   Cubase > Preferences (Cmd + ,)
   ```

#### Key Preference Sections:

**General:**
```
☑ Auto Save: Enable (every 5-10 minutes)
☑ Create Backup Project in Project Folder
☐ Use Legacy Functions (unless needed)
```

**Editing > Audio:**
```
☑ Snap to Zero Crossing (prevents clicks)
☑ Auto Scroll during Editing
☑ Interpolate Audio Events (smoother stretching)
```

**Editing > Project & MixConsole:**
```
☑ Link Project and MixConsole
☑ Scroll To Selected Track
☑ Enable Track Quick Controls
```

**MIDI:**
```
☑ Reset on Stop
☑ MIDI Thru Active
Length Adjustment Mode: Time-Based
```

**Record > Audio:**
```
☑ Audio Pre-Record Bars: 8 bars
☑ Create Audio Images during Record
☑ Open Audio Editor after Record
☑ Enable Record on Selected Track
```

**Transport:**
```
☑ Return to Start Position on Stop
☑ Stop after Auto Punch Out
Locate when Clicked in Empty Space: Checked
```

**VST:**
```
☑ Plug-in Editors Always on Top
☑ Auto-Suspend VST3 Plug-in Support
Plug-in Scanning: Asynchronous
```

**User Interface:**
```
Color Scheme: Dark (or your preference)
☑ High DPI: Enable for Retina displays
☑ Enable Hi-DPI on External Displays
```

2. **Click "Apply" and "OK"**

---

## Audio Interface Setup

### Configure Your Audio Interface

#### Example: Audient iD14 MkII

1. **Connect and power on your interface**

2. **Select in Studio Setup:**
   ```
   Studio > Studio Setup
   Audio System > ASIO Driver: Audient iD14
   ```

3. **Open interface control panel:**
   - Click **"Control Panel"** button
   - Configure in the iD app:
     ```
     Sample Rate: 48000 Hz (match Cubase)
     Buffer Size: 128-256 samples (recording)
                  512-1024 samples (mixing)
     Clock Source: Internal
     ```

4. **Route in Audio Connections (F4):**
   - Map interface inputs to Cubase input buses
   - Map interface outputs to Cubase output buses

---

### Using Aggregate Devices

If you set up an aggregate device (see [Audio Interfaces Setup](audio-interfaces-setup.md)):

1. **Select aggregate device in Studio Setup:**
   ```
   Audio System > ASIO Driver: Studio Aggregate (or your custom name)
   ```

2. **Configure I/O:**
   - Inputs 1-12: Audient iD14
   - Inputs 13-20: Axe-Fx III
   - Inputs 21-28: HX Stomp
   - (Adjust based on your setup)

3. **Create appropriate input buses** in Audio Connections

---

## Plugin Management

### 1. VST Plugin Scanning

Cubase scans plugins automatically, but you can manage this:

1. **Plugin Manager:**
   ```
   Studio > Plugin Manager
   ```

2. **Manage plugins:**
   - **Whitelist/Blacklist:** Right-click plugins to enable/disable
   - **Collections:** Create folders for organizing plugins
   - **Rescan:** Click "Refresh" to rescan plugin directories

3. **Add custom VST paths:**
   ```
   Cubase > Preferences > Plug-ins > VST Plug-ins
   Click "+" to add additional VST directories
   ```

---

### 2. Organizing Plugins

#### Create Collections:

1. **In Plugin Manager:**
   - Click **"Collections"** tab
   - Create collections:
     ```
     - Favorites
     - Dynamics
     - EQ
     - Reverb
     - Synths
     - Drums (Superior Drummer, etc.)
     - etc.
     ```

2. **Assign plugins to collections:**
   - Drag plugins into collections
   - Or right-click > Add to Collection

---

### 3. Track Presets

Save commonly used plugin chains:

1. **Set up a track** with plugins (e.g., Vocal Chain with EQ, Compressor, Reverb)

2. **Save Track Preset:**
   ```
   Right-click track > Save Track Preset
   Name: "Lead Vocal Chain"
   Category: Vocals
   Include: 
   ☑ Inserts
   ☑ Sends
   ☑ Channel Settings
   ☑ Track Settings
   ```

3. **Load Track Preset:**
   - Right-click empty space in track list
   - **Add Track from Preset > [Your preset name]**

---

## Project Templates

### 1. Create Custom Project Templates

Save time with pre-configured project templates:

#### Example: Music Production Template

1. **Create a new project:**
   ```
   File > New Project
   ```

2. **Set up tracks:**
   ```
   - 8 Audio Tracks (with input buses configured)
   - 2 Instrument Tracks (for VSTs like Superior Drummer)
   - 1 Sampler Track
   - Group Tracks: Drums, Bass, Guitars, Vocals, Keys
   - FX Tracks: Reverb, Delay, Parallel Compression
   - Master Fader Track
   ```

3. **Configure mixer:**
   - Set up default sends to FX tracks
   - Add master bus compression/limiting (optional)
   - Color-code tracks for easy identification

4. **Save as template:**
   ```
   File > Save as Template
   Name: "Music Production - Standard"
   Category: Production
   ```

#### Additional Template Ideas:

- **Mixing Template:** All tracks, groups, FX ready for mixing
- **Recording Template:** Input-monitoring optimized for tracking
- **Podcast Template:** 2-4 voice tracks with processing
- **Scoring Template:** Multiple MIDI tracks for orchestral work

---

### 2. Use Built-in Templates

Cubase includes professional templates:

1. **Create project from template:**
   ```
   File > New Project
   Select a built-in template:
   - Production
   - Recording
   - Mastering
   - Scoring
   - Empty (blank project)
   ```

2. **Modify and save as custom template** if desired

---

## Optimization

### 1. Performance Optimization

#### Reduce Latency During Recording:

1. **Lower buffer size:**
   ```
   Studio > Studio Setup > Audio System
   Buffer Size: 64-128 samples
   ```

2. **Enable Direct Monitoring:**
   - Use your audio interface's direct monitoring feature
   - Disable software monitoring in Cubase (Studio > Studio Setup > VST Audio System > Direct Monitoring)

3. **Freeze tracks with heavy plugins:**
   - Right-click track > Freeze Track
   - Or: Edit > Render in Place (Cmd + Shift + B)

---

#### Increase Stability During Mixing:

1. **Increase buffer size:**
   ```
   Studio > Studio Setup > Audio System
   Buffer Size: 512-1024 samples
   ```

2. **Enable ASIO-Guard:**
   ```
   Studio > Studio Setup > VST Audio System
   ☑ Activate ASIO-Guard: High
   ```

3. **Disable unused plugins:**
   - Right-click plugin slot > **"Deactivate"**
   - Or bypass plugins you're not using

4. **Use Track/Instrument Freeze:**
   - Freeze CPU-intensive VSTi tracks
   - Free up processing power

---

### 2. Disk Performance

1. **Use SSD for projects:**
   - Store active projects on internal SSD
   - Store archives on external HDD

2. **Set Disk Preload:**
   ```
   Cubase > Preferences > VST > Audio
   Disk Preload: 2 seconds (or higher for large sample libraries)
   ```

3. **Record to separate drive (optional):**
   ```
   File > Project Setup
   Record Files: Choose external SSD
   ```

---

### 3. Project Organization

#### Folder Structure:

```
~/Music/Cubase Projects/
├── 2025/
│   ├── October/
│   │   ├── Song Name/
│   │   │   ├── Song Name.cpr (Cubase project)
│   │   │   ├── Audio/
│   │   │   ├── Edits/
│   │   │   ├── Images/
│   │   │   ├── Bounces/
│   │   │   └── Backups/
```

#### Project Settings:

1. **Open Project Setup:**
   ```
   Project > Project Setup (Shift + S)
   ```

2. **Configure:**
   ```
   Sample Rate: 48000 Hz (or 44100 for CD masters)
   Bit Depth: 24-bit
   Project Frame Rate: 25 fps (for video sync)
   Project Length: Adjust as needed
   ```

---

### 4. Backup Strategy

1. **Enable Auto-Save:**
   ```
   Cubase > Preferences > General
   ☑ Auto Save: Every 5 minutes
   Maximum Backup Files: 5-10
   ```

2. **Manual backups:**
   ```
   File > Back up Project
   Choose location (external drive recommended)
   ☑ Remove Unused Files (optional)
   ```

3. **Version control:**
   - Use **"Save New Version"** for major changes
   - File > Save New Version (Ctrl + Alt + S)
   - Cubase appends version number (e.g., "Song Name-01.cpr")

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: High CPU usage / Audio dropouts

**Solution:**
- **Increase buffer size:** Studio > Studio Setup > Audio System > Buffer Size: 512-1024
- **Enable ASIO-Guard:** Studio > Studio Setup > VST Audio System > ASIO-Guard: High
- **Freeze tracks:** Right-click track > Freeze Track
- **Disable plugins:** Deactivate unused plugins
- **Disable Wi-Fi/Bluetooth** during recording sessions
- **Close unnecessary applications**

---

#### Issue: Cubase not detecting audio interface

**Solution:**
- **Ensure interface is connected and powered on**
- **Install latest drivers** from manufacturer's website
- **Select interface in Studio Setup:**
  ```
  Studio > Studio Setup > Audio System
  ASIO Driver: [Your interface name]
  ```
- **Restart Cubase** after selecting interface
- **Check macOS permissions:**
  ```
  System Settings > Privacy & Security > Microphone
  ☑ Cubase Pro
  ```

---

#### Issue: Plugins not appearing in Cubase

**Solution:**
- **Rescan plugins:**
  ```
  Studio > Plugin Manager > Refresh
  ```
- **Check plugin paths:**
  ```
  Cubase > Preferences > Plug-ins > VST Plug-ins
  Verify paths are correct:
  /Library/Audio/Plug-Ins/VST3/
  ~/Library/Audio/Plug-Ins/VST3/
  ```
- **Update plugins** to latest versions
- **Check plugin compatibility:**
  - Cubase 14 uses VST3 primarily
  - VST2 support is deprecated
- **Remove blacklisted plugins:**
  - Studio > Plugin Manager
  - Right-click plugin > Remove from Blacklist

---

#### Issue: Crackling, popping, or distortion

**Solution:**
- **Increase buffer size:** 256-512 samples minimum
- **Check sample rates match:**
  - Interface control panel: 48000 Hz
  - Cubase Project Setup: 48000 Hz
  - Studio Setup: 48000 Hz
- **Disable real-time scanning** (antivirus)
- **Check disk space:** Ensure sufficient free space (20%+ recommended)
- **Update audio interface firmware**

---

#### Issue: MIDI controller not working

**Solution:**
- **Enable MIDI device:**
  ```
  Studio > Studio Setup > MIDI > MIDI Port Setup
  Check "In 'All MIDI Inputs'" for your controller
  ```
- **Check MIDI track input:**
  - Select MIDI track
  - Inspector: MIDI Input > All MIDI Inputs (or specific device)
- **Restart Cubase and reconnect controller**
- **Test in standalone app** to verify controller functionality

---

#### Issue: License activation failed

**Solution:**
- **Check internet connection**
- **Relaunch Steinberg Activation Manager:**
  ```bash
  open "/Applications/Steinberg Activation Manager.app"
  ```
- **Sign out and sign back in**
- **Deactivate and reactivate:**
  - Select license > Deactivate
  - Reactivate on this computer
- **Contact Steinberg support** if issues persist:
  - https://www.steinberg.net/support/

---

#### Issue: Project won't open / Crashes on load

**Solution:**
- **Open in Safe Mode:**
  - Hold **Shift + Alt** while launching Cubase
  - Disable all plugins temporarily
  - Try opening project
- **Check for corrupt plugins:**
  - Disable plugins one by one in Plugin Manager
- **Restore from backup:**
  ```
  Navigate to project folder > Backups/
  Open a recent .bak file
  ```
- **Update Cubase** to latest version
- **Check macOS compatibility**

---

#### Issue: Control Room not working

**Solution:**
- **Enable Control Room:**
  ```
  Studio > Studio Setup > Control Room
  ☑ Enable Control Room
  ```
- **Create Monitor Buses:**
  - Add monitors in Control Room setup
  - Assign physical outputs
- **Check Audio Connections (F4):**
  - Ensure main output is routed correctly

---

### Best Practices

1. **Keep software updated:**
   - Check for Cubase updates monthly
   - Update audio interface drivers
   - Update plugins regularly

2. **Organize your projects:**
   - Use consistent folder structure
   - Name tracks clearly
   - Color-code tracks by instrument group

3. **Use track versions:**
   - Duplicate tracks for alternative takes/arrangements
   - Or use **Track Versions** feature (Cubase 14)

4. **Save frequently:**
   - Use Auto-Save (enabled by default)
   - Manually save before risky operations

5. **Freeze and bounce:**
   - Freeze CPU-intensive tracks
   - Bounce MIDI to audio when editing is complete

6. **Monitor CPU/Disk meters:**
   - Keep an eye on performance meters in transport bar
   - Address issues before they cause crashes

7. **Backup regularly:**
   - Use Time Machine or similar
   - Backup to cloud storage (Google Drive, Dropbox)
   - Keep project backups on external drives

---

## Advanced Features

### 1. VariAudio (Vocal Tuning)

Cubase's built-in pitch correction:

1. **Select audio event** (vocal recording)
2. **Double-click** to open Sample Editor
3. **Click "VariAudio" tab**
4. **Analyze** the audio (click "Pitch & Warp")
5. **Edit pitch:**
   - Drag segments up/down to correct pitch
   - Quantize pitch to scale
   - Adjust formant, straighten pitch curves

---

### 2. Chord Track

Generate and follow chord progressions:

1. **Add Chord Track:**
   ```
   Project > Add Track > Chord
   ```

2. **Enter chords:**
   - Draw chord events
   - Use Chord Assistant for suggestions

3. **Apply to MIDI tracks:**
   - Enable "Follow Chord Track" on MIDI tracks
   - Transpose MIDI to follow chord changes

---

### 3. Sampler Track

Quickly sample and manipulate audio:

1. **Add Sampler Track:**
   ```
   Project > Add Track > Sampler
   ```

2. **Drag audio into sampler track**
3. **Play chromatically** via MIDI
4. **Edit sample** with built-in controls

---

### 4. MixConsole Snapshots

Save and recall mixer settings:

1. **Configure mixer** for a specific section
2. **Create snapshot:**
   ```
   MixConsole > Snapshots > Store
   Name: "Intro", "Verse", "Chorus", etc.
   ```
3. **Recall snapshot** by clicking it
4. **Automate snapshot changes** in timeline

---

## Quick Reference Commands

```bash
# Open Cubase 14 Pro
open "/Applications/Cubase 14/Cubase Pro.app"

# Open Steinberg Download Assistant
open "/Applications/Steinberg Download Assistant.app"

# Open Steinberg Activation Manager
open "/Applications/Steinberg Activation Manager.app"

# Check installed plugins
ls /Library/Audio/Plug-Ins/VST3/ | grep -i cubase
ls ~/Library/Audio/Plug-Ins/VST3/

# Locate project files
find ~/Music/Cubase\ Projects/ -name "*.cpr"

# Check Cubase preferences location
open ~/Library/Preferences/Cubase\ 14/
```

---

## Keyboard Shortcuts

### Essential Shortcuts:

```
File & Project:
Cmd + N          New Project
Cmd + O          Open Project
Cmd + S          Save Project
Cmd + Shift + S  Save New Version
Cmd + ,          Preferences

Transport:
Space            Play/Stop
Num *            Record
Num 1            Go to Left Locator
Num 2            Go to Right Locator
L                Set Left Locator
R                Set Right Locator

Editing:
Cmd + D          Duplicate
Cmd + X          Cut
Cmd + C          Copy
Cmd + V          Paste
Cmd + Z          Undo
Cmd + Shift + Z  Redo

Windows:
F3               MixConsole
F4               Audio Connections
F11              VST Instruments
Cmd + Shift + P  Studio Setup

Tools:
1-9              Select tools (Arrow, Range, Scissors, Glue, etc.)
```

---

## Additional Resources

- **Official Website:** https://www.steinberg.net/cubase/
- **User Manual:** Help > Documentation (within Cubase)
- **Video Tutorials:** https://www.steinberg.net/cubase/tutorials/
- **Knowledge Base:** https://helpcenter.steinberg.de/hc/en-us
- **Forum:** https://forums.steinberg.net/
- **YouTube:** Official Steinberg channel for video tutorials

---

## Related Documentation
- [Audio Interfaces Setup](audio-interfaces-setup.md)
- [Superior Drummer 3 Setup](superior-drummer-3-setup.md)
- [Logic Pro Organization](logic-pro-organization.md)
- [System Setup](../setup/01-system-setup.md)
- [GitHub SSH Setup](github-ssh-setup.md)

---

**Last Updated:** October 2025  
**Software Version:** Cubase Pro 14.0  
**macOS Version:** Sequoia 15.0.1  
**Architecture:** Universal (Intel + Apple Silicon)

