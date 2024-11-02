# DAKboard Troubleshooting Guide

## Common Problems and Solutions

### 1. WiFi Disconnection Issues

#### Symptoms:
```
ieee80211 phy0: brcmf_proto_bcdc_query_dcmd: brcmf_proto_bcdc_msg failed w/status -110
```

#### Quick Checks:
```bash
# Check power management
iwconfig wlan0 | grep "Power Management"

# Check signal strength
watch -n 1 'iwconfig wlan0 | grep "Signal level"'

# Check for errors in syslog
tail -f /var/log/syslog | grep brcmf
```

#### Solutions:
1. Verify power management is disabled:
   ```bash
   sudo ./scripts/verify.sh
   ```
2. Restart NetworkManager:
   ```bash
   sudo systemctl restart NetworkManager
   ```
3. Check antenna configuration in `/boot/config.txt`

### 2. Browser Issues

#### Symptoms:
- Display frozen
- Black screen
- High memory usage
- Browser crashes

#### Quick Checks:
```bash
# Check browser process
ps aux | grep chromium

# Check memory usage
free -h

# Check browser logs
tail -f /var/log/dakboard-browser.log
```

#### Solutions:
1. Clear browser cache:
   ```bash
   rm -rf /dev/shm/chromium-cache/*
   ```
2. Restart browser:
   ```bash
   sudo systemctl restart dakboard
   ```
3. Check GPU memory allocation in `/boot/config.txt`

### 3. System Performance Issues

#### Symptoms:
- Slow response
- High temperature
- System freezes

#### Quick Checks:
```bash
# Check temperature
vcgencmd measure_temp

# Check CPU frequency
vcgencmd measure_clock arm

# Check throttling
vcgencmd get_throttled
```

#### Solutions:
1. Verify cooling:
   ```bash
   # Temperature should be under 70°C
   watch -n 1 vcgencmd measure_temp
   ```
2. Check system load:
   ```bash
   uptime
   ```
3. Review running processes:
   ```bash
   top -o %CPU
   ```

### 4. Watchdog Issues

#### Symptoms:
- System not auto-recovering
- Watchdog service not running
- Missing log entries

#### Quick Checks:
```bash
# Check watchdog status
systemctl status watchdog

# Check watchdog device
ls -l /dev/watchdog

# Check watchdog logs
journalctl -u watchdog
```

#### Solutions:
1. Restart watchdog:
   ```bash
   sudo systemctl restart watchdog
   ```
2. Verify configuration:
   ```bash
   cat /etc/watchdog.conf
   ```
3. Check kernel module:
   ```bash
   lsmod | grep watchdog
   ```

### 5. Web Server Issues

#### Symptoms:
- 502 Bad Gateway
- Slow page loads
- PHP errors

#### Quick Checks:
```bash
# Check lighttpd status
systemctl status lighttpd

# Check PHP processes
ps aux | grep php

# Check error logs
tail -f /var/log/lighttpd/error.log
```

#### Solutions:
1. Restart web server:
   ```bash
   sudo systemctl restart lighttpd
   ```
2. Check PHP configuration:
   ```bash
   php -v
   php-fpm -tt
   ```
3. Verify permissions:
   ```bash
   ls -la /var/www/html
   ```

## Log Analysis Guide

### Important Log Files
1. `/var/log/syslog` - System messages
2. `/var/log/dakboard-browser.log` - Browser operations
3. `/var/log/lighttpd/error.log` - Web server errors
4. `/var/log/dakboard-metrics.log` - System metrics
5. `/var/log/messages` - General system messages

### Common Error Patterns
```
# WiFi disconnection
brcmf_proto_bcdc_query_dcmd: failed w/status -110

# Memory pressure
Out of memory: Kill process

# Temperature warning
Thermal throttling detected

# Browser crash
ERROR:browser_main_loop.cc
```

## Recovery Procedures

### Quick Recovery Script
```bash
#!/bin/bash
# Quick recovery of all services
sudo systemctl restart NetworkManager
sudo systemctl restart lighttpd
sudo systemctl restart watchdog
killall chromium-browser
sudo systemctl restart dakboard
```

### Emergency Recovery
If the system becomes unresponsive:
1. SSH access:
   ```bash
   ssh dakboard@your-pi-ip
   ```
2. Force reboot if needed:
   ```bash
   sudo reboot -f
   ```

## Prevention Tips
1. Regular monitoring
2. Periodic log review
3. Temperature management
4. Memory usage tracking
5. Network quality monitoring

Remember: Always check the verify script output first when troubleshooting:
```bash
sudo ./scripts/verify.sh
```
