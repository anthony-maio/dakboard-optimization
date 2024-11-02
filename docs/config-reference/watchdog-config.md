# Watchdog Configuration Reference

## Overview
The watchdog configuration ensures system stability by monitoring various system parameters and automatically recovering from lockups.

## File Location
```bash
/etc/watchdog.conf
```

## Core Configuration

### Basic Settings
```ini
# Device and timeout
watchdog-device = /dev/watchdog
watchdog-timeout = 15

# Retry settings
retry-timeout = 60
max-load-1 = 24
max-load-5 = 18
max-load-15 = 12
```

### Memory Monitoring
```ini
# Memory thresholds
min-memory = 1
allocatable-memory = 1
max-swap-usage = 90
```

### Temperature Monitoring
```ini
# Temperature limits (Raspberry Pi specific)
temperature-sensor = /sys/class/thermal/thermal_zone0/temp
max-temperature = 80000
```

## Network Monitoring

### Connection Checking
```ini
# Network interface to monitor
interface = wlan0

# Ping settings
ping = 8.8.8.8
ping-count = 3
```

### File System Monitoring
```ini
# Check if file system is writable
test-directory = /var/log
test-timeout = 10
```

## Process Monitoring

### Critical Services
```ini
# Monitor specific processes
pidfile = /var/run/lighttpd.pid
pidfile = /var/run/php-fcgi.pid
```

## Boot Configuration

### Enable Hardware Watchdog
In `/boot/config.txt`:
```ini
dtparam=watchdog=on
```

## Service Management

### Enable Service
```bash
# Enable and start watchdog
systemctl enable watchdog
systemctl start watchdog
```

### Service Status
```bash
# Check status
systemctl status watchdog

# Check if hardware watchdog is active
cat /dev/watchdog
# Should return: Device or resource busy
```

## Verification

### Check Configuration
```bash
# Test configuration
watchdog -v -c /etc/watchdog.conf

# Check if running
ps aux | grep watchdog
```

### Monitor Operation
```bash
# Check logs
journalctl -u watchdog

# Check temperature monitoring
cat /sys/class/thermal/thermal_zone0/temp
```

## Recovery Actions

### Manual Testing
```bash
# Trigger watchdog (BE CAREFUL - WILL REBOOT)
echo 1 > /dev/watchdog-trigger

# Test temperature monitoring
# (Monitor only, don't artificially raise temperature)
watch -n 1 vcgencmd measure_temp
```

### Service Recovery
```bash
# Restart watchdog
systemctl restart watchdog

# Clear watchdog
echo V > /dev/watchdog
```

## Common Issues

### Service Won't Start
```bash
# Check kernel module
lsmod | grep watchdog

# Load module if needed
modprobe bcm2835_wdt
```

### False Triggers
```bash
# Adjust thresholds
max-load-1 = 24       # Increase if false triggers
ping-count = 5        # Increase for flaky network
max-temperature = 85000  # Adjust for environment
```

## Monitoring Integration

### System Monitoring
```bash
# Check current load
uptime

# Check memory
free -h

# Check temperature
vcgencmd measure_temp
```

### Log Monitoring
```bash
# Watch for watchdog events
tail -f /var/log/syslog | grep watchdog

# Monitor system reboots
last reboot
```

## Best Practices

1. Regular Testing
   - Check logs weekly
   - Verify thresholds
   - Test recovery

2. Maintenance
   - Update ping targets
   - Adjust thresholds
   - Review recovery actions

3. Monitoring
   - Track reboot frequency
   - Monitor trigger causes
   - Review system logs
