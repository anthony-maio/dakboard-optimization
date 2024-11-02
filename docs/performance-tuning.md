# Performance Tuning Guide

## Overview
This guide helps optimize your DAKboard system for better performance and stability.

## Quick Performance Check
```bash
# Run verification script with performance focus
sudo ./scripts/verify.sh --performance

# Check current performance metrics
vcgencmd get_config int | grep -E "arm_freq|gpu_freq|over_voltage"
```

## CPU Optimization

### Frequency Settings
Current configuration in `/boot/config.txt`:
```ini
arm_freq=1800
over_voltage=2
arm_boost=1
```

#### Fine-tuning Options
```ini
# Conservative (cooler, stable)
arm_freq=1500
over_voltage=1

# Balanced (our default)
arm_freq=1800
over_voltage=2

# Aggressive (needs good cooling)
arm_freq=2000
over_voltage=3
```

### Monitoring Impact
```bash
# Watch CPU frequency
watch -n 1 vcgencmd measure_clock arm

# Monitor temperature
watch -n 1 vcgencmd measure_temp

# Check throttling
watch -n 1 vcgencmd get_throttled
```

## Memory Management

### GPU Memory
```ini
# Default setting
gpu_mem=128

# Adjust based on needs:
gpu_mem=96    # Less GPU, more system
gpu_mem=156   # More GPU, less system
```

### Browser Memory
```bash
# Monitor browser memory
watch 'ps -o pid,ppid,cmd,%mem,%cpu --sort=-%mem | grep chromium'

# Clear cache if needed
rm -rf /dev/shm/chromium-cache/*
```

### RAM Disk Usage
```bash
# Check RAM disk usage
df -h /dev/shm

# Adjust size if needed (in /etc/fstab)
tmpfs /dev/shm tmpfs defaults,size=50% 0 0
```

## Display Performance

### Screen Refresh
```ini
# In /boot/config.txt
hdmi_force_hotplug=1
max_framebuffers=2
dtoverlay=vc4-fkms-v3d
```

### Browser Rendering
Browser flags in `browser.sh`:
```bash
--disable-gpu-vsync
--disable-smooth-scrolling
```

## Network Performance

### WiFi Optimization
```ini
# In /boot/config.txt
dtoverlay=disable-wifi-power-management
dtparam=ant2
dtparam=disable_wifi_btcoex=on
```

### Connection Monitoring
```bash
# Signal strength
watch -n 1 'iwconfig wlan0 | grep "Signal level"'

# Network speed
speedtest-cli
```

## System Services

### Web Server Optimization
In `/etc/lighttpd/lighttpd.conf`:
```nginx
server.max-keep-alive-requests = 100
server.max-keep-alive-idle = 30
fastcgi.server = ( ".php" =>
    ((
        "max-procs" => 4,
        "idle-timeout" => 20
    ))
)
```

### Process Priority
```bash
# Give browser higher priority
renice -10 $(pgrep chromium)

# Lower background process priority
renice +10 $(pgrep php-cgi)
```

## Monitoring and Adjusting

### Performance Metrics
```bash
# CPU load
uptime

# Memory usage
free -h

# Disk I/O
iostat -x 1

# Network usage
iftop -i wlan0
```

### Temperature Management
```bash
# Monitor temperature
vcgencmd measure_temp

# Check throttling
vcgencmd get_throttled

# Fan control (if configured)
gpio -g write 14 1
```

## Optimization Checklist

1. Basic Optimization
   - [ ] Verify CPU settings
   - [ ] Check GPU memory
   - [ ] Monitor temperature
   - [ ] Test network speed

2. Advanced Tuning
   - [ ] Adjust process priorities
   - [ ] Configure RAM disk
   - [ ] Optimize web server
   - [ ] Fine-tune browser flags

3. Monitoring Setup
   - [ ] Temperature alerts
   - [ ] Memory monitoring
   - [ ] Network quality checks
   - [ ] Performance logging

## Performance Profiles

### Conservative Profile
```ini
arm_freq=1500
over_voltage=1
gpu_mem=96
```
Best for: Stability, minimal cooling

### Balanced Profile (Default)
```ini
arm_freq=1800
over_voltage=2
gpu_mem=128
```
Best for: Most users, good performance/stability

### Performance Profile
```ini
arm_freq=2000
over_voltage=3
gpu_mem=156
```
Best for: Maximum performance, requires good cooling

## Troubleshooting Performance

### High CPU Usage
1. Check processes:
   ```bash
   top -o %CPU
   ```
2. Monitor temperature:
   ```bash
   watch vcgencmd measure_temp
   ```
3. Review browser processes:
   ```bash
   ps aux | grep chromium
   ```

### Memory Issues
1. Check usage:
   ```bash
   free -h
   ```
2. Clear caches:
   ```bash
   sync; echo 3 > /proc/sys/vm/drop_caches
   ```
3. Restart services:
   ```bash
   sudo systemctl restart dakboard
   ```

## Best Practices

1. Regular Monitoring
   - Check temperatures daily
   - Monitor memory usage
   - Review performance logs

2. Maintenance
   - Clear caches weekly
   - Update configurations
   - Review and adjust settings

3. Documentation
   - Track changes
   - Monitor impacts
   - Document optimizations
