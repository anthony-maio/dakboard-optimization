# Installation Verification Guide

## Quick Verification
```bash
# Run verification script
sudo ./scripts/verify.sh
```

## Manual Verification Steps

### 1. WiFi Configuration
```bash
# Check power management
iwconfig wlan0 | grep "Power Management"
# Should show: Power Management:off

# Check signal strength
iwconfig wlan0 | grep "Signal level"
# Should show good signal level (-67 or better)

# Verify NetworkManager settings
cat /etc/NetworkManager/NetworkManager.conf | grep wifi.powersave
# Should show: wifi.powersave=2
```

### 2. System Configuration
```bash
# Check CPU settings
vcgencmd get_config int | grep arm_freq
# Should show: arm_freq=1800

# Check GPU memory
vcgencmd get_mem gpu
# Should show: gpu=128M

# Check temperature
vcgencmd measure_temp
# Should be under 70°C
```

### 3. Service Status
```bash
# Check web server
systemctl status lighttpd
# Should show: active (running)

# Check PHP FastCGI
ps aux | grep php-cgi
# Should show multiple php-cgi processes

# Check watchdog
systemctl status watchdog
# Should show: active (running)
```

### 4. Browser Setup
```bash
# Check browser process
ps aux | grep chromium
# Should show chromium process

# Check RAM disk
df -h /dev/shm
# Should show mounted RAM disk

# Check browser cache
ls -la /dev/shm/chromium-cache/
# Should exist and be writable
```

## Configuration Files

### Verify Boot Configuration
```bash
# Check /boot/config.txt
grep -E "gpu_mem|arm_freq|over_voltage" /boot/config.txt
# Should match our settings
```

### Verify Web Server
```bash
# Test lighttpd configuration
lighttpd -t -f /etc/lighttpd/lighttpd.conf
# Should show: Syntax OK

# Check FastCGI configuration
grep fastcgi /etc/lighttpd/lighttpd.conf
# Should show our FastCGI settings
```

## Performance Verification

### Memory Usage
```bash
# Check available memory
free -h
# Should show reasonable free memory

# Check browser memory
ps -o pid,ppid,cmd,%mem,%cpu --sort=-%mem | grep chromium
# Should be under 50% memory usage
```

### Temperature
```bash
# Monitor temperature under load
watch -n 1 vcgencmd measure_temp
# Should remain under 70°C
```

### Network Performance
```bash
# Check connection speed
speedtest-cli
# Should show reasonable speeds

# Monitor connection quality
watch -n 1 'iwconfig wlan0 | grep "Link Quality"'
# Should show stable quality
```

## Common Issues

### WiFi Problems
```bash
# No power management setting:
sudo iwconfig wlan0 power off

# Poor signal:
# Check antenna configuration in /boot/config.txt
```

### Service Issues
```bash
# Restart services:
sudo systemctl restart lighttpd
sudo systemctl restart watchdog
sudo systemctl restart dakboard
```

### Browser Issues
```bash
# Clear cache and restart:
rm -rf /dev/shm/chromium-cache/*
sudo systemctl restart dakboard
```

## Verification Checklist
- [ ] WiFi power management disabled
- [ ] Services running correctly
- [ ] Temperature in safe range
- [ ] Memory usage acceptable
- [ ] Browser configured correctly
- [ ] Watchdog active
- [ ] Logs being generated

## Next Steps
After verification:
1. Monitor system for 24 hours
2. Check logs for any issues
3. Verify automatic recovery works
4. Document any adjustments needed
