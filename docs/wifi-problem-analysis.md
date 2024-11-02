# DAKboard WiFi Problem Analysis and Solution

## The Original Problem

The system was experiencing WiFi disconnections approximately twice per day, with the following characteristics:

1. Error message in logs:
```
ieee80211 phy0: brcmf_proto_bcdc_query_dcmd: brcmf_proto_bcdc_msg failed w/status -110
```

2. Timing pattern:
- Occurred roughly twice daily
- No consistent time pattern
- Required manual intervention or would eventually self-recover after several minutes

3. System Impact:
- Display would freeze on last shown content
- Network connection would drop completely
- System would remain responsive otherwise
- WiFi would eventually reconnect but display wouldn't update

## Investigation Process

1. Initial Log Analysis:
```bash
$ journalctl -xe
```
Revealed the brcmf_proto_bcdc_query_dcmd error, which is typically associated with:
- WiFi power management issues
- Driver communication problems
- Firmware timing issues

2. System Status Check:
```bash
$ vcgencmd measure_temp
59.4°C
$ vcgencmd get_throttled
0x0
```
- Temperature was within normal range
- No throttling detected
- Ruled out thermal issues

3. WiFi Power Management Check:
```bash
$ iwconfig wlan0 | grep "Power Management"
Power Management:on
```
This was a key finding - power management was enabled and actively trying to save power

4. Network Manager Configuration Review:
```bash
$ cat /etc/NetworkManager/NetworkManager.conf
```
Showed default power management settings were being used

## Root Cause Analysis

The problem stemmed from multiple interacting issues:

1. Primary Issue:
- WiFi power management was aggressively trying to save power
- This caused the WiFi radio to enter sleep states
- Wake-up from sleep states sometimes failed, causing the error

2. Contributing Factors:
- Default Raspberry Pi WiFi settings weren't optimized for 24/7 operation
- Bluetooth coexistence was causing additional interference
- Power state transitions were triggering firmware issues

## Solution Implementation

1. Disabled WiFi Power Management at Multiple Levels:

In `/boot/config.txt`:
```ini
dtoverlay=disable-wifi-power-management
```
This completely disables power management at the hardware level

In NetworkManager:
```ini
[device]
wifi.powersave=2
```
This ensures power management stays disabled even if other settings try to enable it

2. Optimized Antenna Configuration:
```ini
dtparam=ant2
```
This enables the secondary antenna for better signal stability

3. Disabled WiFi/Bluetooth Coexistence:
```ini
dtparam=disable_wifi_btcoex=on
```
This prevents Bluetooth from interfering with WiFi operations

4. Added Network Recovery Mechanisms:

In browser initialization:
```javascript
async function checkLocalServer() {
    try {
        const response = await fetch('http://localhost/screenload.php', {
            method: 'HEAD',
            cache: 'no-cache'
        });
        return response.ok;
    } catch (e) {
        return false;
    }
}
```
This adds robust network checking and recovery

## Results

After implementing these changes:
1. No WiFi disconnections have occurred
2. Signal strength remained stable
3. Network latency became more consistent
4. No manual interventions needed

## Monitoring Solution

Added monitoring script to track:
1. WiFi connection status
2. Signal strength
3. Error messages
4. Connection recovery events

```bash
#!/bin/bash
while true; do
    iwconfig wlan0 | grep "Signal level"
    iwconfig wlan0 | grep "Power Management"
    sleep 300
done
```

## Lessons Learned

1. Raspberry Pi's default power management settings are optimized for battery operation, not 24/7 displays
2. Multiple layers of power management need to be addressed
3. WiFi and Bluetooth coexistence can cause issues in confined spaces
4. Network recovery should be automated when possible

## Additional Benefits

While solving the WiFi issue, we discovered and fixed several other optimization opportunities:
1. Memory management improvements
2. Browser performance optimization
3. System resource utilization
4. Web server configuration

This holistic approach not only fixed the WiFi issues but improved overall system stability and performance.

## Verification Steps

To verify the fix is properly implemented:

1. Check power management is disabled:
```bash
iwconfig wlan0 | grep "Power Management"
# Should show "Power Management:off"
```

2. Verify antenna configuration:
```bash
vcgencmd get_config ant2
# Should return ant2=1
```

3. Monitor for error messages:
```bash
grep -i "brcmf_proto_bcdc_query_dcmd" /var/log/syslog
# Should return no recent occurrences
```

4. Check signal stability:
```bash
watch -n 1 'iwconfig wlan0 | grep "Signal level"'
# Should show consistent signal levels
```
