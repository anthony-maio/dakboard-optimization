# DAKboard RPi4 Installation and Configuration Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Basic Installation](#basic-installation)
3. [Manual Configuration](#manual-configuration)
4. [Optimization Steps](#optimization-steps)
5. [Troubleshooting](#troubleshooting)
6. [Monitoring](#monitoring)

## Prerequisites

### Hardware Requirements
- Raspberry Pi 4 (2GB+ RAM recommended)
- 16GB+ microSD card (high-quality recommended)
- Proper power supply (5V/3A official PSU recommended)
- Optional: Active cooling solution

### Software Requirements
- DAKboardOS installed
- Network connection
- SSH access enabled

### Before You Begin
1. Backup your existing configuration
2. Note down your DAKboard credentials
3. Ensure your Pi has a stable power source
4. Connect via ethernet if possible during setup

## Basic Installation

### Automated Installation
```bash
# 1. Clone the repository
git clone https://github.com/anthony-maio/dakboard-optimization.git
cd dakboard-optimization

# 2. Make the installation script executable
chmod +x scripts/install.sh

# 3. Run the installation script
sudo ./scripts/install.sh
```

### Verifying Installation
After installation, check:
1. System status: `systemctl status lighttpd`
2. Browser process: `ps aux | grep chromium`
3. Network status: `nmcli connection show`
4. Logs: `tail -f /var/log/dakboard-*.log`

## Manual Configuration

### System Configuration
1. Edit boot configuration:
   ```bash
   sudo nano /boot/config.txt
   ```
   Key settings:
   - `gpu_mem=128`
   - `over_voltage=2`
   - `arm_freq=1800`

2. Configure NetworkManager:
   ```bash
   sudo cp config/system/NetworkManager.conf /etc/NetworkManager/
   sudo systemctl restart NetworkManager
   ```

### Web Server Setup
1. Configure lighttpd:
   ```bash
   sudo cp config/lighttpd/lighttpd.conf /etc/lighttpd/
   sudo systemctl restart lighttpd
   ```

2. Verify PHP configuration:
   ```bash
   sudo lighttpd-enable-mod fastcgi-php
   sudo systemctl restart lighttpd
   ```

### Browser Configuration
1. Set up browser optimization:
   ```bash
   sudo cp config/browser/browser.sh /home/dakboard/startup/
   sudo chmod +x /home/dakboard/startup/browser.sh
   ```

2. Configure browser initialization:
   ```bash
   sudo cp config/browser/browser-init.html /home/dakboard/startup/
   ```

## Optimization Steps

### Memory Optimization
1. Create RAM disk for browser:
   ```bash
   mkdir -p /dev/shm/chromium-cache
   chmod 777 /dev/shm/chromium-cache
   ```

2. Configure swap (if needed):
   ```bash
   sudo dphys-swapfile swapoff
   sudo nano /etc/dphys-swapfile
   # Set CONF_SWAPSIZE=1024
   sudo dphys-swapfile setup
   sudo dphys-swapfile swapon
   ```

### Network Optimization
1. Disable power management:
   ```bash
   sudo iwconfig wlan0 power off
   ```

2. Set up monitoring:
   ```bash
   sudo cp scripts/monitor.sh /usr/local/bin/
   sudo chmod +x /usr/local/bin/monitor.sh
   ```

### Performance Tuning
1. Enable hardware acceleration:
   ```bash
   sudo raspi-config
   # Enable GL Driver under Advanced Options
   ```

2. Optimize thermal performance:
   ```bash
   # Check current temperature
   vcgencmd measure_temp
   ```

## Troubleshooting

### Common Issues

1. Browser Crashes
   - Check logs: `tail -f /var/log/dakboard-browser.log`
   - Verify memory usage: `free -h`
   - Restart browser: `sudo systemctl restart dakboard`

2. Network Issues
   - Check connection: `nmcli device wifi list`
   - View logs: `journalctl -u NetworkManager`
   - Test connectivity: `ping -c 4 google.com`

3. Performance Issues
   - Check CPU usage: `top`
   - Monitor temperature: `vcgencmd measure_temp`
   - View system logs: `dmesg | tail`

### Recovery Steps

1. Browser Recovery
   ```bash
   sudo systemctl stop dakboard
   killall -9 chromium-browser
   sudo systemctl start dakboard
   ```

2. Network Recovery
   ```bash
   sudo systemctl restart NetworkManager
   sudo iwconfig wlan0 power off
   ```

3. System Recovery
   ```bash
   sudo reboot
   ```

## Monitoring

### Setting Up Monitoring

1. Enable system monitoring:
   ```bash
   sudo systemctl enable dakboard-monitor
   sudo systemctl start dakboard-monitor
   ```

2. View metrics:
   ```bash
   tail -f /var/log/dakboard-metrics.log
   ```

### Regular Maintenance

1. Log rotation:
   ```bash
   sudo logrotate -f /etc/logrotate.d/dakboard
   ```

2. Cache cleanup:
   ```bash
   sudo rm -rf /dev/shm/chromium-cache/*
   ```

3. Update check:
   ```bash
   cd /path/to/dakboard-optimization
   git pull
   ```

## Support and Updates

### Getting Help
- Open an issue: [GitHub Issues](https://github.com/anthony-maio/dakboard-optimization/issues)
- Check logs: `journalctl -xe`
- Review documentation: [Project Wiki](https://github.com/anthony-maio/dakboard-optimization/wiki)

### Updating
```bash
cd /path/to/dakboard-optimization
git pull
sudo ./scripts/install.sh --update
```

Remember to always backup your configuration before making changes and test in a safe environment first.
