# Network Configuration Reference

## Overview
Network configuration focuses on optimizing WiFi stability and performance through NetworkManager settings.

## Primary Configuration File
```bash
/etc/NetworkManager/NetworkManager.conf
```

## Key Settings

### WiFi Power Management
```ini
[device]
# Disable power management (0=default, 1=enabled, 2=disabled)
wifi.powersave=2

# Disable random MAC address scanning
wifi.scan-rand-mac-address=no
```

### Connection Management
```ini
[connection]
# Disable IPv6 privacy extensions
ipv6.ip6-privacy=0

# Set connection retry attempts
connection.auth-retries=5

# Set connection timeout (seconds)
connection.timeout=30
```

### DNS Configuration
```ini
[main]
# DNS configuration method
dns=default

# DNS resolver manager
rc-manager=resolvconf
```

## Verification Commands
```bash
# Check WiFi power management status
iwconfig wlan0 | grep "Power Management"

# Check current connections
nmcli connection show

# Check WiFi signal strength
watch -n 1 'iwconfig wlan0 | grep "Signal level"'

# Check DNS resolution
nmcli device show wlan0 | grep DNS
```

## Monitoring Tools
```bash
# Monitor network interface
ifconfig wlan0

# Check connection status
nmcli device status

# Monitor network traffic
iftop -i wlan0

# Check connection speed
speedtest-cli
```

## Troubleshooting Steps
1. Check power management:
   ```bash
   iwconfig wlan0 | grep "Power Management"
   ```

2. Restart NetworkManager:
   ```bash
   sudo systemctl restart NetworkManager
   ```

3. Reset WiFi connection:
   ```bash
   sudo nmcli device disconnect wlan0
   sudo nmcli device connect wlan0
   ```

4. Check logs:
   ```bash
   journalctl -u NetworkManager
   ```

## Common Issues and Solutions

### Frequent Disconnections
```bash
# Disable power management
sudo iwconfig wlan0 power off

# Verify settings applied
sudo iwconfig wlan0
```

### Poor Signal Strength
```bash
# Check signal level
iwconfig wlan0 | grep "Signal level"

# Verify antenna configuration
vcgencmd get_config ant2
```

### DNS Issues
```bash
# Check DNS servers
nmcli device show wlan0 | grep DNS

# Test DNS resolution
dig google.com
```
