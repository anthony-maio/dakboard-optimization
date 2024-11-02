# DAKboard Optimization Quick Start Guide

Having WiFi drops on your DAKboard? This guide will help you quickly implement our fixes.

## 1. Quick Install
```bash
# Clone the repository
git clone https://github.com/anthony-maio/dakboard-optimization.git
cd dakboard-optimization

# Make the install script executable
chmod +x scripts/install.sh

# Run the installation
sudo ./scripts/install.sh
```

## 2. Verify Installation
```bash
# Check WiFi power management
iwconfig wlan0 | grep "Power Management"
# Should show: Power Management:off

# Check watchdog status
systemctl status watchdog
# Should show: active (running)

# Check web server
systemctl status lighttpd
# Should show: active (running)
```

## 3. Common Issues

### WiFi Still Dropping?
```bash
# Check logs for errors
sudo tail -f /var/log/syslog | grep brcmf
```

### Display Issues?
Check `/boot/config.txt` settings:
```bash
sudo nano /boot/config.txt
# Verify hdmi_force_hotplug=1 is set
```

### Browser Crashes?
```bash
# Check browser logs
tail -f /var/log/dakboard-browser.log
```

## 4. Monitoring

Check system status:
```bash
# View metrics
tail -f /var/log/dakboard-metrics.log

# Check temperature
vcgencmd measure_temp
```

## Need Help?
- Open an issue on GitHub
- Check the full documentation in the `docs/` directory
- Review logs in `/var/log/dakboard-*.log`

## Want to Revert?
```bash
# Restore original configurations
sudo ./scripts/install.sh --restore
```
