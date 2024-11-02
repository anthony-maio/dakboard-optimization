# Configuration Reference

## Overview
This directory contains detailed documentation for all configuration files and settings used in the DAKboard optimization project.

## Quick Reference

### Critical Files
- `/boot/config.txt` - System and hardware settings
- `/etc/lighttpd/lighttpd.conf` - Web server configuration
- `/etc/NetworkManager/NetworkManager.conf` - Network settings
- `/home/dakboard/startup/browser.sh` - Browser optimization
- `/etc/watchdog.conf` - System monitoring

## Configuration Guides
- [Boot Configuration](boot-config.md)
- [Web Server Configuration](lighttpd-config.md)
- [Network Configuration](network-config.md)
- [Browser Configuration](browser-config.md)
- [Watchdog Configuration](watchdog-config.md)

## Key Settings by Category

### System Performance
```ini
# /boot/config.txt
arm_freq=1800
over_voltage=2
gpu_mem=128
```

### WiFi Stability
```ini
# /boot/config.txt
dtoverlay=disable-wifi-power-management
dtparam=ant2
dtparam=disable_wifi_btcoex=on

# /etc/NetworkManager/NetworkManager.conf
[device]
wifi.powersave=2
```

### Display Optimization
```ini
# /boot/config.txt
hdmi_force_hotplug=1
disable_overscan=1
dtoverlay=vc4-fkms-v3d
max_framebuffers=2
```

### Browser Performance
```bash
# /home/dakboard/startup/browser.sh
--disable-gpu-vsync
--memory-model=low
--disable-dev-shm-usage
```

## Common Tasks

### Reset to Default
```bash
# Backup current configs
sudo cp /boot/config.txt /boot/config.txt.backup
sudo cp /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.backup

# Restore from backup
sudo cp /boot/config.txt.backup /boot/config.txt
sudo cp /etc/lighttpd/lighttpd.conf.backup /etc/lighttpd/lighttpd.conf
```

### Verify Configurations
```bash
# Run verification script
sudo ./scripts/verify.sh

# Manual checks
lighttpd -t -f /etc/lighttpd/lighttpd.conf
iwconfig wlan0 | grep "Power Management"
vcgencmd get_config int
```

## Configuration Dependencies

### Boot Configuration
- Affects: System performance, WiFi, Display
- Required by: Browser, System services
- Verifies with: `vcgencmd` commands

### Network Configuration
- Affects: WiFi stability, Connection quality
- Required by: Browser, Web server
- Verifies with: `iwconfig`, `nmcli`

### Browser Configuration
- Affects: Display performance, Memory usage
- Required by: DAKboard interface
- Verifies with: Process monitoring

### Web Server Configuration
- Affects: Page loading, PHP processing
- Required by: DAKboard interface
- Verifies with: Service status, logs

## Best Practices

1. Always backup before changes
2. Test changes individually
3. Monitor after changes
4. Document modifications
5. Verify all dependencies

## Configuration Updates
- Backup before updating
- Test in safe mode
- Monitor for 24 hours
- Document changes
