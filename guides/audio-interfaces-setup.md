# Audio Interfaces Setup Guide

This guide covers the installation and configuration of multiple USB audio interfaces on macOS, specifically for the Audient iD14 MkII, Fractal Axe-Fx III, and Line6 HX Stomp.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Software Installation](#software-installation)
- [Creating an Aggregate Audio Device](#creating-an-aggregate-audio-device)
- [DAW Configuration](#daw-configuration)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- macOS system with available USB ports (preferably USB-C or USB 3.0)
- All three audio interfaces:
  - Audient iD14 MkII
  - Fractal Axe-Fx III
  - Line6 HX Stomp
- Power supplies for devices (if required)
- Quality USB cables

---

## Software Installation

### 1. Audient iD14 MkII

The iD14 MkII requires the **iD app** for full control and configuration.

#### Installation Steps:
1. **Download the software:**
   - Visit: https://audient.com/products/audio-interfaces/id14/downloads/
   - Download the latest **iD app** for macOS

2. **Install the software:**
   ```bash
   # Connect the iD14 MkII to your Mac via USB
   # Open the downloaded .dmg file
   # Drag the iD app to your Applications folder
   ```

3. **Verify installation:**
   - Open **System Settings > Sound**
   - The iD14 MkII should appear as an available audio device
   - Launch the iD app to configure settings (sample rate, buffer size, etc.)

#### Key Features in iD app:
- Sample rate configuration (44.1, 48, 88.2, 96, 176.4, 192 kHz)
- Buffer size adjustment
- Monitor mix control
- Input gain and phantom power controls

---

### 2. Fractal Axe-Fx III

The Axe-Fx III is **class-compliant** on macOS, meaning it works without additional drivers. However, you may want to install **Fractal-Bot** for firmware updates and **Axe-Edit** for editing patches.

#### Installation Steps:
1. **Download the software (optional but recommended):**
   - Visit: https://www.fractalaudio.com/support/
   - Download **Fractal-Bot** (firmware updater)
   - Download **Axe-Edit** (patch editor)

2. **Connect the device:**
   ```bash
   # Connect the Axe-Fx III to your Mac via USB
   # The device should be immediately recognized
   ```

3. **Verify installation:**
   - Open **Audio MIDI Setup** (Applications > Utilities)
   - The Axe-Fx III should appear in the audio devices list
   - Default: 8 inputs / 8 outputs at up to 192 kHz

#### Notes:
- No driver installation required for basic audio functionality
- Install Axe-Edit for patch management
- Install Fractal-Bot for firmware updates

---

### 3. Line6 HX Stomp

The HX Stomp requires **HX Edit** software for full functionality and patch management.

#### Installation Steps:
1. **Download the software:**
   - Visit: https://line6.com/software/
   - Download **HX Edit** for macOS
   - Download **Line 6 Updater** for firmware updates

2. **Install the software:**
   ```bash
   # Open the downloaded installer
   # Follow the installation wizard
   # Restart your Mac when prompted
   ```

3. **Connect and verify:**
   - Connect the HX Stomp to your Mac via USB
   - Launch **HX Edit** to verify connection
   - The device should appear in the HX Edit interface

4. **Update firmware (if needed):**
   - Launch **Line 6 Updater**
   - Follow prompts to update to the latest firmware

#### HX Stomp Audio Configuration:
- Default: 8 inputs / 8 outputs
- Sample rates: 44.1, 48, 88.2, 96 kHz
- Configure in HX Edit under **Preferences > Audio**

---

## Creating an Aggregate Audio Device

An **Aggregate Device** allows you to use all three interfaces simultaneously as a single virtual audio device with combined inputs and outputs.

### Step-by-Step Process:

1. **Open Audio MIDI Setup:**
   ```bash
   # Navigate to: Applications > Utilities > Audio MIDI Setup
   # Or use Spotlight: Cmd + Space, type "Audio MIDI Setup"
   ```

2. **Create the Aggregate Device:**
   - Click the **+** (plus) button in the bottom-left corner
   - Select **"Create Aggregate Device"**
   - A new device named "Aggregate Device" will appear

3. **Configure the Aggregate Device:**
   
   **a) Rename the device:**
   - Double-click "Aggregate Device" and rename it (e.g., "Studio Aggregate")
   
   **b) Select member devices:**
   - In the right pane, check the **Use** box for:
     - ☑ Audient iD14
     - ☑ Axe-Fx III
     - ☑ HX Stomp
   - **DO NOT** check USB Audio CODEC devices
   
   **c) Set sample rate:**
   - Set all devices to the **same sample rate** (e.g., 48000 Hz)
   - Click the sample rate dropdown for each device
   - Mismatched sample rates will cause sync issues!
   
   **d) Configure clock source:**
   - Choose your **master clock** device from the dropdown
   - **Recommended:** Use the **Audient iD14** as clock master
   - It typically has the most stable clock
   
   **e) Enable drift correction:**
   - For devices **NOT** set as clock master, check **"Drift Correction"**
   - ☑ Axe-Fx III - Drift Correction
   - ☑ HX Stomp - Drift Correction
   - This prevents sync drift over time

4. **Verify the configuration:**
   - Your aggregate device now has combined I/O:
     - **Inputs:** 12 (from iD14) + 8 (Axe-Fx III) + 8 (HX Stomp) = ~28 inputs
     - **Outputs:** 6 (from iD14) + 8 (Axe-Fx III) + 8 (HX Stomp) = ~22 outputs
   - Close Audio MIDI Setup

### Channel Order in Aggregate Device:

The channels will be ordered in the sequence you checked the devices:

```
Inputs:
  Channels 1-12:  Audient iD14
  Channels 13-20: Axe-Fx III
  Channels 21-28: HX Stomp

Outputs:
  Channels 1-6:   Audient iD14
  Channels 7-14:  Axe-Fx III
  Channels 15-22: HX Stomp
```

---

## DAW Configuration

### Setting Up in Your DAW:

1. **Open your DAW** (Logic Pro, Ableton Live, Pro Tools, etc.)

2. **Navigate to Audio Preferences:**
   - Logic Pro: Preferences > Audio > Devices
   - Ableton Live: Preferences > Audio
   - Pro Tools: Setup > Playback Engine

3. **Select the Aggregate Device:**
   - Input Device: **Studio Aggregate** (or your custom name)
   - Output Device: **Studio Aggregate**

4. **Configure buffer size:**
   - Set in your DAW's audio preferences
   - Lower = less latency (64-128 samples for recording)
   - Higher = more stability (256-512 samples for mixing)

5. **Enable inputs/outputs:**
   - In your DAW, enable the specific inputs/outputs you'll use
   - Map them according to the channel order listed above

### Example Track Routing:

```
Track 1: Input 1 (iD14 Mic Input 1)
Track 2: Input 13 (Axe-Fx III Input 1 - Guitar)
Track 3: Input 21 (HX Stomp Input 1 - Guitar)
Main Out: Outputs 1-2 (iD14 Main Monitors)
```

---

## Troubleshooting

### Common Issues and Solutions:

#### Issue: Devices not appearing in Audio MIDI Setup
**Solution:**
- Ensure all devices are powered on and connected via USB
- Try different USB ports (preferably USB 3.0 or higher)
- Restart your Mac
- Reinstall device software

#### Issue: Crackling, popping, or dropouts
**Solution:**
- Check that all devices are set to the **same sample rate**
- Increase buffer size in your DAW
- Enable **Drift Correction** for non-master devices
- Use a powered USB hub if needed
- Close unnecessary applications

#### Issue: Devices out of sync
**Solution:**
- Verify clock master is set correctly
- Enable Drift Correction for slave devices
- Ensure all devices are at the same sample rate
- Try a different device as clock master

#### Issue: Aggregate device not appearing in DAW
**Solution:**
- Restart your DAW
- Quit and reopen Audio MIDI Setup
- Recreate the aggregate device
- Check for macOS or DAW updates

#### Issue: High latency when recording
**Solution:**
- Reduce buffer size in DAW preferences
- Use direct monitoring on the interfaces when possible
- Disable unnecessary plugins during tracking
- Consider recording to individual interfaces instead of aggregate

### Best Practices:

1. **Always use the same sample rate** across all devices (48 kHz recommended)
2. **Use quality USB cables** and avoid passive USB hubs when possible
3. **Set the Audient iD14 as clock master** (most stable clock)
4. **Enable Drift Correction** for slave devices
5. **Keep firmware updated** for all devices
6. **Restart devices** if you change sample rates
7. **Test the setup** before important sessions

---

## Additional Notes

### USB Connection Tips:
- Connect interfaces directly to Mac's USB ports when possible
- If using a hub, use a **powered USB 3.0+ hub**
- Avoid daisy-chaining hubs
- Keep USB cables under 15 feet for reliability

### Sample Rate Recommendations:
- **44.1 kHz:** CD-quality audio, lower CPU usage
- **48 kHz:** Video production standard, recommended for most work
- **88.2/96 kHz:** High-quality recording, higher CPU usage
- **176.4/192 kHz:** Archival quality, very high CPU usage

### When NOT to Use Aggregate Devices:
- If you only need one interface at a time
- When experiencing sync issues that can't be resolved
- For live performance (single interface is more reliable)
- When maximum sample rate support is needed (some devices may be limited)

---

## Quick Reference Commands

```bash
# Open Audio MIDI Setup
open "/Applications/Utilities/Audio MIDI Setup.app"

# Check connected USB audio devices
system_profiler SPAudioDataType

# View USB device tree
system_profiler SPUSBDataType
```

---

## Related Documentation
- [System Setup](../setup/01-system-setup.md)
- [IDEs and Editors](../setup/08-ides-editors.md)
- [Troubleshooting](../reference/troubleshooting.md)

---

**Last Updated:** October 2025
