# Logs Reference Guide

## Key Log Files

### System Logs
```bash
# Main system log
/var/log/syslog

# DAKboard specific logs
/var/log/dakboard-*.log

# Web server logs
/var/log/lighttpd/*.log
```

## Important Log Patterns

### WiFi Issues
```log
# Power management related
brcmf_proto_bcdc_query_dcmd: failed w/status -110

# Connection drops
wlan0: deauthenticating from XX:XX:XX:XX:XX:XX

# Signal issues
wlan0: failed to initiate AP scan
```

### Browser Issues
```log
# Memory related
[0405/123456.789:ERROR:memory.cc(123)] Out of memory.

# Rendering issues
[0405/123456.789:ERROR:gpu_process_host.cc(123)] GPU process crashed

# Process issues
[0405/123456.789:ERROR:browser_main_loop.cc(123)] Failed to start browser
```

### System Issues
```log
# Temperature warnings
thermal temperature too high

# Memory pressure
Out of memory: Kill process

# Watchdog events
watchdog: watchdog0: watchdog did not stop!
```

## Log Monitoring Commands

### Real-time Monitoring
```bash
# Follow all DAKboard logs
tail -f /var/log/dakboard-*.log

# Follow system log
tail -f /var/log/syslog | grep -i 'error\|warn\|fail'

# Follow web server errors
tail -f /var/log/lighttpd/error.log
```

### Log Analysis
```bash
# Find WiFi related errors
grep -i 'wlan0\|wifi\|wireless' /var/log/syslog

# Check for browser crashes
grep -i 'chromium\|error\|crash' /var/log/dakboard-browser.log

# View watchdog events
grep -i 'watchdog' /var/log/syslog
```

## Log Rotation
Logs are automatically rotated using logrotate:
```bash
# Check rotation config
cat /etc/logrotate.d/dakboard

# Manual rotation
logrotate -f /etc/logrotate.d/dakboard
```

## Metrics Log Format
```log
[TIMESTAMP] | TYPE | VALUE
2024-01-01 12:00:00 | TEMP | 45.2
2024-01-01 12:00:00 | MEM | 65.4
2024-01-01 12:00:00 | WIFI | -67
```

## Log Storage
- Logs are kept for 7 days by default
- Metrics are stored in CSV format
- Automatic compression of old logs

## Best Practices
1. Regular log review
2. Set up log monitoring
3. Act on repeated errors
4. Keep disk space in check
