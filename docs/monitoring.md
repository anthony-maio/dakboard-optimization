# System Monitoring Guide

## Overview
This guide covers monitoring your DAKboard system for stability, performance, and potential issues.

## Quick Status Check
```bash
# Run verification script
sudo ./scripts/verify.sh

# View current metrics
tail -f /var/log/dakboard-metrics.log
```

## Key Metrics to Monitor

### System Health
```bash
# Temperature
vcgencmd measure_temp

# CPU Frequency
vcgencmd measure_clock arm

# Voltage
vcgencmd measure_volts core

# Throttling Status
vcgencmd get_throttled
```

### Memory Usage
```bash
# Overall memory status
free -h

# Top memory processes
ps aux --sort=-%mem | head -n 10

# Browser memory usage
ps -o pid,ppid,cmd,%mem,%cpu --sort=-%mem | grep chromium
```

### WiFi Status
```bash
# Signal strength
iwconfig wlan0 | grep "Signal level"

# Connection quality
iwconfig wlan0 | grep "Link Quality"

# Power management status
iwconfig wlan0 | grep "Power Management"
```

### Disk Usage
```bash
# Overall disk usage
df -h

# Write activity
iostat -x 1

# Most active directories
du -sh /* | sort -hr | head -n 10
```

## Automated Monitoring

### Using the Monitor Script
```bash
# Start monitoring
sudo ./scripts/monitor.sh

# View monitoring logs
tail -f /var/log/dakboard/metrics.log
```

### What's Being Monitored
- CPU temperature
- Memory usage
- WiFi connectivity
- Disk usage
- Process status
- System load

### Alert Thresholds
- Temperature > 70°C
- Memory usage > 80%
- WiFi signal < 50%
- Disk usage > 90%

## Log Files

### System Logs
- `/var/log/syslog` - System messages
- `/var/log/daemon.log` - Background processes
- `/var/log/kern.log` - Kernel messages

### Application Logs
- `/var/log/dakboard-browser.log` - Browser events
- `/var/log/lighttpd/error.log` - Web server errors
- `/var/log/dakboard/metrics.log` - System metrics

## Recovery Actions

### High Temperature
```bash
# Check current temperature
vcgencmd measure_temp

# Verify cooling
gpio -g read 14  # If using GPIO fan

# Check throttling
vcgencmd get_throttled
```

### Memory Issues
```bash
# Clear browser cache
rm -rf /dev/shm/chromium-cache/*

# Restart browser
sudo systemctl restart dakboard
```

### WiFi Problems
```bash
# Reset connection
sudo nmcli device disconnect wlan0
sudo nmcli device connect wlan0

# Restart networking
sudo systemctl restart NetworkManager
```

## Long-term Monitoring

### Setting Up Regular Checks
```bash
# Add to crontab
crontab -e

# Add these lines:
*/5 * * * * /usr/local/bin/check-temp.sh
0 * * * * /usr/local/bin/check-memory.sh
```

### Monitoring Scripts
```bash
# Temperature check script
#!/bin/bash
TEMP=$(vcgencmd measure_temp | cut -d= -f2 | cut -d"'" -f1)
if (( $(echo "$TEMP > 70" | bc -l) )); then
    echo "High temperature: $TEMP°C" >> /var/log/dakboard/alerts.log
fi

# Memory check script
#!/bin/bash
MEM=$(free | awk '/^Mem:/{print $3/$2 * 100}')
if (( $(echo "$MEM > 80" | bc -l) )); then
    echo "High memory usage: $MEM%" >> /var/log/dakboard/alerts.log
fi
```

## Best Practices

1. Regular Monitoring
   - Check metrics daily
   - Review logs weekly
   - Monitor trends monthly

2. Preventive Actions
   - Clear caches regularly
   - Review and rotate logs
   - Update monitoring thresholds

3. Documentation
   - Log all issues
   - Track correlations
   - Document solutions
