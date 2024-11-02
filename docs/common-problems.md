# Common Problems and Solutions

## WiFi Issues

### Frequent Disconnections
**Symptoms:**
- WiFi drops every few hours
- Error in logs: `brcmf_proto_bcdc_query_dcmd: failed w/status -110`

**Solution:**
```bash
# Check power management
iwconfig wlan0 | grep "Power Management"

# Verify configuration
cat /etc/NetworkManager/NetworkManager.conf

# Restart networking
sudo systemctl restart NetworkManager
```

### Poor Signal Strength
**Symptoms:**
- Intermittent connection
- Slow response times

**Solution:**
```bash
# Check signal strength
iwconfig wlan0 | grep "Signal level"

# Verify antenna configuration
vcgencmd get_config ant2

# Check interference
sudo iwlist wlan0 scan | grep -A 5 "Cell"
```

## Display Issues

### Screen Tearing
**Symptoms:**
- Visual artifacts
- Horizontal lines during updates

**Solution:**
```bash
# Verify boot config
grep -E "max_framebuffers|dtoverlay=vc4" /boot/config.txt

# Check GPU memory
vcgencmd get_mem gpu

# Monitor temperature
vcgencmd measure_temp
```

### Black Screen
**Symptoms:**
- No display output
- System responds to SSH

**Solution:**
```bash
# Check HDMI configuration
grep hdmi_force_hotplug /boot/config.txt

# Verify display settings
tvservice -s

# Reset display
tvservice -o && sleep 5 && tvservice -p
```

## Performance Issues

### High Memory Usage
**Symptoms:**
- System sluggish
- Browser crashes

**Solution:**
```bash
# Check memory usage
free -h

# Monitor processes
top -o %MEM

# Clear browser cache
rm -rf /dev/shm/chromium-cache/*
```

### High CPU Temperature
**Symptoms:**
- Thermal throttling
- Performance drops

**Solution:**
```bash
# Monitor temperature
watch -n 1 vcgencmd measure_temp

# Check throttling
vcgencmd get_throttled

# Verify cooling
gpio -g read 14  # If using GPIO fan control
```

## Browser Issues

### Browser Crashes
**Symptoms:**
- Display freezes
- Browser process disappears

**Solution:**
```bash
# Check browser process
ps aux | grep chromium

# Clear cache and restart
killall -9 chromium-browser
rm -rf /dev/shm/chromium-cache/*
sudo systemctl restart dakboard
```

### Memory Leaks
**Symptoms:**
- Increasing memory usage
- Gradual slowdown

**Solution:**
```bash
# Monitor memory usage
watch -n 10 'ps aux | grep chromium'

# Setup automatic restart
echo "0 4 * * * /usr/bin/systemctl restart dakboard" | sudo crontab -
```

## System Recovery

### Complete Lockup
**Symptoms:**
- No SSH access
- No display updates

**Solution:**
```bash
# Hardware reset required
# After reboot, check logs:
journalctl -b -1 -n 100

# Verify watchdog
systemctl status watchdog
```

### Corrupted Configuration
**Symptoms:**
- Services won't start
- Error messages in logs

**Solution:**
```bash
# Restore backup configurations
sudo cp /boot/config.txt.backup /boot/config.txt
sudo cp /etc/lighttpd/lighttpd.conf.backup /etc/lighttpd/lighttpd.conf

# Verify services
sudo systemctl daemon-reload
sudo systemctl restart lighttpd NetworkManager dakboard
```
