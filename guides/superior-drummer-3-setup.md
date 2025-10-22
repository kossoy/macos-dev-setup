# Superior Drummer 3 Installation Guide

This guide covers the installation and configuration of Toontrack Superior Drummer 3 on macOS, including the main application, sound libraries, and DAW integration.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Software Installation](#software-installation)
- [Sound Library Installation](#sound-library-installation)
- [DAW Integration](#daw-integration)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements
- **macOS:** 10.10 or later (macOS Sequoia 15.0.1 compatible)
- **Processor:** Intel or Apple Silicon (M1/M2/M3)
- **RAM:** 4 GB minimum (8 GB or more recommended)
- **Disk Space:** 
  - Application: ~1 GB
  - Core Library: ~230 GB (SSD highly recommended)
  - Additional SDX libraries: varies (10-100 GB each)
- **Audio Interface:** ASIO, Core Audio, or WASAPI compatible
- **DAW:** Compatible host (Logic Pro, Ableton Live, Pro Tools, etc.)

### Before You Begin
- Ensure you have your Toontrack account credentials
- Have your Superior Drummer 3 license/serial number ready
- Free up sufficient disk space for sound libraries
- Consider using an external SSD for libraries if internal storage is limited

---

## Software Installation

### 1. Download Toontrack Product Manager

The **Toontrack Product Manager** is required to download and manage all Toontrack products.

#### Installation Steps:

1. **Visit the Toontrack website:**
   ```bash
   # Open in your browser
   # https://www.toontrack.com/product-manager/
   ```

2. **Download the installer:**
   - Download **Toontrack Product Manager** for macOS
   - Save the `.dmg` file to your Downloads folder

3. **Install the Product Manager:**
   ```bash
   # Open the downloaded .dmg file
   # Drag "Toontrack Product Manager" to Applications folder
   open ~/Downloads/Toontrack*.dmg
   ```

4. **Launch and log in:**
   - Open **Toontrack Product Manager** from Applications
   - Log in with your Toontrack account credentials
   - If you don't have an account, create one at toontrack.com

5. **Register your product:**
   - Click **"Register Product"**
   - Enter your Superior Drummer 3 serial number
   - The product will appear in your account

---

### 2. Install Superior Drummer 3

#### Download via Product Manager:

1. **Launch Toontrack Product Manager**
   ```bash
   open "/Applications/Toontrack Product Manager.app"
   ```

2. **Navigate to Superior Drummer 3:**
   - In the **"Products"** tab, find **"Superior Drummer 3"**
   - Click **"Install"** next to the application

3. **Choose installation location:**
   - **Application Location:** `/Applications/` (default, recommended)
   - **Sound Library Location:** Choose a drive with sufficient space
     - Recommended: External SSD or dedicated internal drive
     - Path example: `/Volumes/Audio Libraries/Toontrack/`

4. **Start download and installation:**
   - Click **"Install"**
   - The installer will download and install both:
     - Superior Drummer 3 application
     - Core sound library (230 GB)
   - This may take several hours depending on internet speed

5. **Wait for completion:**
   - Monitor progress in the Product Manager
   - Do not interrupt the download/installation
   - The app will notify you when complete

---

### 3. Install Authorization

Superior Drummer 3 requires online authorization.

#### Authorization Steps:

1. **Launch Superior Drummer 3:**
   ```bash
   # As standalone application
   open "/Applications/Superior Drummer 3.app"
   
   # Or load in your DAW as a plugin
   ```

2. **Authorize the product:**
   - On first launch, you'll see an authorization dialog
   - Click **"Authorize"**
   - Log in with your Toontrack account
   - The software will authorize automatically

3. **Offline authorization (if needed):**
   - If you don't have internet on your music machine:
     - Click **"Offline Authorization"**
     - Follow the instructions to generate a request file
     - Transfer to a machine with internet
     - Visit: https://www.toontrack.com/my-account/
     - Upload the request file to get an authorization file
     - Transfer back and load into Superior Drummer 3

---

## Sound Library Installation

### Core Library

The **Core Library** is included with Superior Drummer 3 and installed via Product Manager.

**Contents:**
- 7 complete drum kits
- 35 GB of meticulously sampled drums
- Recorded at George Massenburg's legendary studios
- ~350,000 individual samples

**Installation is automatic** when you install SD3 via Product Manager.

---

### Additional Sound Libraries (SDX)

Superior Drummer supports additional expansion libraries called **SDX** (Superior Drummer eXpansion).

#### Popular SDX Libraries:
- **Metal Foundry SDX** - Metal drums
- **The Rock Warehouse SDX** - Classic rock drums
- **Decades SDX** - Vintage drums from different eras
- **The Progressive Foundry SDX** - Progressive/fusion drums
- **The Black Album SDX** - Metallica's "Black Album" drums

#### Installing SDX Libraries:

1. **Purchase from Toontrack:**
   - Visit: https://www.toontrack.com/superior-drummer-3/
   - Purchase desired SDX expansion
   - Serial number will be added to your account

2. **Install via Product Manager:**
   ```bash
   open "/Applications/Toontrack Product Manager.app"
   ```
   - The new SDX will appear in your Products list
   - Click **"Install"** next to the SDX
   - Choose installation location (same as Core Library recommended)
   - Wait for download and installation

3. **Access in Superior Drummer 3:**
   - Launch Superior Drummer 3
   - New drum kits will appear in the kit selection menu
   - No additional authorization needed

---

### Managing Library Locations

If you need to move libraries or manage multiple drives:

1. **Open Superior Drummer 3**
2. **Click the Settings/Preferences icon** (gear icon)
3. **Navigate to "Paths"**
4. **Add or modify library locations:**
   ```
   Example paths:
   /Applications/Toontrack/Superior Drummer 3/
   /Volumes/Audio SSD/Toontrack/
   /Volumes/External/SD3 Libraries/
   ```
5. **Click "Rescan"** to index new locations

---

## DAW Integration

Superior Drummer 3 works as a plugin in your DAW.

### Plugin Formats Included:
- **VST3** - Standard plugin format
- **AU** (Audio Units) - macOS native format
- **AAX** - Pro Tools format

---

### Logic Pro Setup

1. **Launch Logic Pro**

2. **Create a software instrument track:**
   - Track > New Software Instrument Track (⌘ + Opt + S)

3. **Load Superior Drummer 3:**
   - In the channel strip, click the **Instrument** slot
   - Navigate: **AU Instruments > Toontrack > Superior Drummer 3**
   - The plugin will open in a new window

4. **Configure I/O (important for mixing):**
   - Superior Drummer 3 can route individual drum pieces to separate channels
   - In SD3, click **Settings > Audio & MIDI**
   - Set **Output Configuration:** 
     - **Stereo** (simple, 1 stereo track)
     - **Multi-out** (route kicks, snares, toms, cymbals to separate tracks)

5. **Enable multi-output in Logic (optional):**
   - Click the **+** icon in the channel strip header
   - Add auxiliary tracks for each SD3 output
   - Route SD3 outputs to separate Logic mixer channels

6. **Configure MIDI:**
   - SD3 responds to MIDI notes (General MIDI mapping)
   - You can use:
     - MIDI keyboard
     - Drum pads (e.g., Akai MPD)
     - Programmed MIDI regions in Logic

---

### Ableton Live Setup

1. **Create a MIDI track:**
   - Cmd + T or Insert > MIDI Track

2. **Load Superior Drummer 3:**
   - In the device browser, navigate to **Plug-ins > AU > Toontrack**
   - Drag **Superior Drummer 3** to the MIDI track
   - Or click an empty instrument slot and select SD3

3. **Configure routing:**
   - In SD3, set up multi-output if needed
   - In Ableton, configure external instrument routing for multiple outs

4. **Arm the track for recording:**
   - Enable MIDI input monitoring
   - Select your MIDI controller

---

### Pro Tools Setup

1. **Create a stereo instrument track:**
   - Track > New > Stereo Instrument Track

2. **Load Superior Drummer 3:**
   - Click the instrument insert slot
   - Navigate: **multichannel plug-in > Instrument > Toontrack > Superior Drummer 3**

3. **Configure multi-output (optional):**
   - In SD3, set output configuration to multi-out
   - In Pro Tools, create auxiliary tracks for each output
   - Route SD3 outputs to individual Pro Tools mixer channels

---

## Configuration

### Initial Setup in Superior Drummer 3

#### 1. Audio & MIDI Settings

1. **Open Superior Drummer 3**
2. **Click Settings icon** (gear)
3. **Audio & MIDI tab:**
   
   **Audio Settings:**
   ```
   Sample Rate: Match your DAW/interface (48000 Hz recommended)
   Buffer Size: 128-512 samples (lower = less latency)
   Output Configuration: Stereo or Multi-out
   ```
   
   **MIDI Settings:**
   ```
   MIDI Input: Select your MIDI controller/keyboard
   MIDI Learn: Enable to map controls
   Velocity Curve: Adjust for your playing style
   ```

#### 2. Mixer Configuration

Superior Drummer 3 has a built-in mixer with extensive routing:

1. **Open the Mixer view** (bottom panel)
2. **Channel configuration:**
   - Each drum piece has its own channel
   - Adjust levels, pan, effects for each piece
   - Route to main mix or separate outputs

3. **Effects routing:**
   - Built-in effects: EQ, compression, reverb, etc.
   - Insert effects on individual channels
   - Send effects on aux buses

#### 3. Drum Mapping

1. **MIDI mapping:**
   - SD3 uses General MIDI mapping by default
   - Custom mappings available for e-drums and pads

2. **To remap notes:**
   - Click **Settings > MIDI**
   - Click **"MIDI Mapping"**
   - Click a drum piece in the interface
   - Hit the MIDI note you want to assign
   - Save mapping

---

### Performance Optimization

#### Reduce CPU Usage:

1. **Bounce/freeze tracks in your DAW:**
   - Once you have a great performance, render to audio
   - Disable the SD3 track to free CPU

2. **Optimize SD3 settings:**
   - **Settings > Performance:**
     ```
     RAM Mode: Load samples to RAM (faster, uses more RAM)
     Streaming Mode: Stream from disk (slower, less RAM usage)
     Voice Count: Reduce if experiencing dropouts
     ```

3. **Increase DAW buffer size:**
   - While mixing (not tracking), increase buffer to 512-1024 samples

---

### Preset Management

#### Saving Presets:

1. **Configure your drum kit, mixer, and effects**
2. **Click the Preset menu** (top left)
3. **"Save Preset As..."**
4. **Name your preset** (e.g., "Rock Mix", "Metal Master")
5. **Choose category** (User presets recommended)
6. **Click Save**

#### Loading Presets:

1. **Click the Preset menu**
2. **Browse factory or user presets**
3. **Click a preset to load instantly**

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: Superior Drummer 3 not appearing in DAW

**Solution:**
- Ensure you installed SD3 completely via Product Manager
- **Rescan plugins in your DAW:**
  - **Logic Pro:** Preferences > Plug-in Manager > Reset & Rescan
  - **Ableton:** Preferences > Plug-ins > Rescan
  - **Pro Tools:** Setup > Plug-ins > Refresh list
- Restart your DAW
- Check plugin installation path:
  ```bash
  # AU plugins (macOS)
  ls /Library/Audio/Plug-Ins/Components/ | grep Superior
  
  # VST3 plugins
  ls /Library/Audio/Plug-Ins/VST3/ | grep Superior
  ```

---

#### Issue: Sound library not loading / "Missing samples" error

**Solution:**
- **Verify library installation:**
  ```bash
  # Check if Core Library exists
  # Default location:
  ls ~/Library/Application\ Support/Toontrack/Superior\ Drummer\ 3/
  
  # Custom location:
  ls /Volumes/Your-Drive/Toontrack/
  ```
- **Re-scan library paths in SD3:**
  - Open SD3
  - Settings > Paths
  - Click **"Rescan"**
- **Reinstall library via Product Manager** if missing

---

#### Issue: High CPU usage / Audio dropouts

**Solution:**
- **Increase buffer size** in DAW audio preferences
- **Switch to Streaming Mode:**
  - SD3 Settings > Performance
  - Enable **"Stream from Disk"** instead of RAM mode
- **Reduce voice count:**
  - Settings > Performance > Max Voices: Set to 256 or lower
- **Disable unused mixer effects**
- **Close unnecessary applications**
- **Use an SSD** for sample storage (not HDD)

---

#### Issue: MIDI notes not triggering drums

**Solution:**
- **Check MIDI input:**
  - SD3 Settings > MIDI
  - Verify correct MIDI device is selected
- **Enable MIDI input in DAW:**
  - Ensure track is record-enabled
  - Check MIDI input routing
- **Verify MIDI mapping:**
  - SD3 uses General MIDI by default
  - Kick: C1 (MIDI note 36)
  - Snare: D1 (MIDI note 38)
  - Hi-hat: F#1 (MIDI note 42)
- **Test with MIDI keyboard:** Rule out controller issues

---

#### Issue: Authorization failed

**Solution:**
- **Check internet connection**
- **Verify Toontrack account:**
  - Log in at: https://www.toontrack.com/my-account/
  - Confirm product is registered
- **Retry authorization:**
  - SD3 > Help > Deauthorize
  - Restart SD3
  - Authorize again
- **Use offline authorization** if online authorization fails:
  - SD3 > Help > Offline Authorization
  - Follow the offline process

---

#### Issue: Plugin crashes or won't load

**Solution:**
- **Update to latest version:**
  - Open Toontrack Product Manager
  - Check for SD3 updates
  - Install available updates
- **Update macOS and DAW** to latest stable versions
- **Check compatibility:**
  - SD3 is compatible with Apple Silicon (M1/M2/M3)
  - Runs natively, no Rosetta required
- **Reinstall the plugin:**
  - Uninstall via Product Manager
  - Restart Mac
  - Reinstall via Product Manager

---

#### Issue: Preset changes not saving

**Solution:**
- **Save presets manually:**
  - Preset menu > Save Preset As...
- **Check write permissions:**
  ```bash
  # Verify you can write to presets folder
  ls -la ~/Library/Application\ Support/Toontrack/Superior\ Drummer\ 3/Presets/
  ```
- **Don't rely on DAW auto-save for plugin state:**
  - Always save important presets within SD3
  - Save DAW project after configuring SD3

---

### Performance Best Practices

1. **Use SSD storage** for sample libraries (HDD will cause streaming issues)
2. **Allocate sufficient RAM** (16 GB+ recommended for large projects)
3. **Bounce to audio** when not tweaking drum sounds
4. **Use multi-out routing** for better mix control
5. **Regularly update** SD3 and Product Manager
6. **Organize presets** into custom categories
7. **Back up your presets** (located in `~/Library/Application Support/Toontrack/`)

---

## Advanced Tips

### Custom Groove Library

Superior Drummer 3 includes MIDI grooves:

1. **Open the Grooves tab** in SD3
2. **Browse by genre, tempo, time signature**
3. **Drag grooves into your DAW** as MIDI regions
4. **Edit MIDI** to customize the performance

### Electronic Drums Integration

If using electronic drums (Roland, Alesis, etc.):

1. **Connect e-drums via MIDI** (USB or 5-pin)
2. **Select MIDI input** in SD3 settings
3. **Load appropriate MIDI mapping:**
   - SD3 Settings > MIDI > MIDI Mapping
   - Select your e-drum brand preset
4. **Adjust velocity curves** for natural response

### Exporting Individual Drum Stems

For mixing in your DAW:

1. **Set SD3 to multi-output mode**
2. **Route each drum piece to separate output**
3. **Record or bounce each output** to separate audio tracks
4. **Mix in your DAW** with full control over each element

---

## Quick Reference Commands

```bash
# Open Product Manager
open "/Applications/Toontrack Product Manager.app"

# Open Superior Drummer 3 (standalone)
open "/Applications/Superior Drummer 3.app"

# Check plugin installation
ls /Library/Audio/Plug-Ins/Components/ | grep Superior
ls /Library/Audio/Plug-Ins/VST3/ | grep Superior

# Check sample library location (default)
ls ~/Library/Application\ Support/Toontrack/Superior\ Drummer\ 3/

# Backup user presets
cp -R ~/Library/Application\ Support/Toontrack/Superior\ Drummer\ 3/Presets ~/Desktop/SD3_Presets_Backup

# Check disk space for libraries
df -h | grep Toontrack
```

---

## Additional Resources

- **Official Website:** https://www.toontrack.com/superior-drummer-3/
- **User Manual:** Available in SD3 > Help > User Manual
- **Video Tutorials:** https://www.toontrack.com/superior-drummer-3/tutorials/
- **Support:** https://www.toontrack.com/support/
- **User Forum:** https://www.toontrack.com/forums/

---

## Related Documentation
- [Audio Interfaces Setup](audio-interfaces-setup.md)
- [Logic Pro Organization](logic-pro-organization.md)
- [System Setup](../setup/01-system-setup.md)
- [IDEs and Editors](../setup/08-ides-editors.md)

---

**Last Updated:** October 2025  
**Software Version:** Superior Drummer 3.3.6  
**macOS Version:** Sequoia 15.0.1  
**Architecture:** Universal (Intel + Apple Silicon)

