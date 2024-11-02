# Boot Configuration Reference

## Overview
The boot configuration file (`/boot/config.txt`) contains critical settings that control hardware behavior, performance, and system features on the Raspberry Pi.

## File Location
```bash
/boot/config.txt
```

## Critical Settings

### Display Settings
```ini
# Force HDMI output even when no display detected
hdmi_force_hotplug=1

# Disable overscan to prevent black borders
disable_overscan=1

# Enable KMS driver for better display performance
dtoverlay=vc4-fkms-v3d

# Enable double buffering to reduce screen tearing
max_framebuffers=2
```

### Performance Settings
```ini
# Enable CPU frequency boosting
arm_boost=1

# Set GPU memory allocation (MB)
gpu_mem=128

# Slight voltage increase for stability
over_voltage=2

# Set CPU frequency to 1.8GHz
arm_freq=1800
```

### WiFi Optimizations
```ini
# Disable WiFi power management
dtoverlay=disable-wifi-power-management

# Enable secondary antenna
dtparam=ant2

# Disable WiFi/Bluetooth coexistence
dtparam=disable_wifi_btcoex=on
```

### System Settings
```ini
# Disable warning overlays
avoid_warnings=1

# Enable GPIO shutdown capability
dtoverlay=gpio-shutdown

# Disable unused audio hardware
dtparam=audio=off
```

## Performance Impact
Each setting affects system behavior:
- `gpu_mem`: Higher values improve display performance but reduce available system memory
- `over_voltage`: Increases stability but may increase temperature
- `arm_freq`: Higher values improve performance but may require better cooling

## Monitoring Impact
Monitor these values after changes:
```bash
# Check CPU temperature
vcgencmd measure_temp

# Check current frequency
vcgencmd measure_clock arm

# Check throttling status
vcgencmd get_throttled
```

## Safety Considerations
- Don't set `over_voltage` higher than 2 without adequate cooling
- Monitor temperature after changes
- Keep `arm_freq` at or below 1800 for stability

## Troubleshooting
- If display issues occur, revert `hdmi_force_hotplug` and `disable_overscan`
- If system becomes unstable, revert `over_voltage` and `arm_freq`
- If WiFi issues persist, verify `dtoverlay=disable-wifi-power-management` is active
