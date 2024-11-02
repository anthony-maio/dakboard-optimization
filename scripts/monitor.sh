#!/bin/bash

# DAKboard System Monitor
# Works alongside watchdog to provide detailed system metrics

LOG_DIR="/var/log/dakboard"
METRICS_FILE="${LOG_DIR}/metrics.log"
ALERT_FILE="${LOG_DIR}/alerts.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Logging function
log_metric() {
    echo "$(date '+%Y-%m-%d %H:%M:%S')|$1" >> "$METRICS_FILE"
}

log_alert() {
    echo "$(date '+%Y-%m-%d %H:%M:%S')|ALERT|$1" >> "$ALERT_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S')|ALERT|$1" >> "$METRICS_FILE"
}

# System metrics collection
collect_metrics() {
    # CPU Temperature
    temp=$(vcgencmd measure_temp | cut -d= -f2 | cut -d"'" -f1)
    log_metric "TEMP|$temp"

    # Memory Usage
    free -m | awk 'NR==2{printf "MEM|Total: %s MB|Used: %s MB|Free: %s MB\n", $2,$3,$4}' >> "$METRICS_FILE"

    # WiFi Signal Strength
    signal=$(iwconfig wlan0 2>/dev/null | grep "Signal level" | awk '{print $4}' | cut -d= -f2)
    log_metric "WIFI|$signal"

    # Disk Usage
    df -h / | awk 'NR==2{printf "DISK|Used: %s|Free: %s|Use%%: %s\n", $3,$4,$5}' >> "$METRICS_FILE"

    # Process Status
    if ! pgrep chromium-browser > /dev/null; then
        log_alert "Chromium browser not running"
    fi

    if ! systemctl is-active --quiet lighttpd; then
        log_alert "Lighttpd web server not running"
    fi

    if ! systemctl is-active --quiet watchdog; then
        log_alert "Watchdog service not running"
    fi
}

# Cleanup old logs
cleanup_logs() {
    find "$LOG_DIR" -name "*.log" -mtime +7 -delete
    
    # Rotate metrics file if too large
    for file in "$LOG_DIR"/*.log; do
        if [ -f "$file" ] && [ "$(stat -f%z "$file")" -gt 10485760 ]; then  # 10MB
            mv "$file" "${file}.$(date +%Y%m%d)"
            gzip "${file}.$(date +%Y%m%d)"
        fi
    done
}

# Main loop
while true; do
    collect_metrics
    cleanup_logs
    sleep 300  # Run every 5 minutes
done