#!/bin/bash

# DAKboard Browser Optimization Script
# Author: Anthony Maio
# Repository: https://github.com/anthony-maio/dakboard-optimization

# Environment setup
export DISPLAY=:0
export XAUTHORITY=/home/dakboard/.Xauthority

# Configuration
CHROME_FLAGS=(
    # Window and display settings
    "--window-size=1920,1080"
    "--window-position=0,0"
    "--start-fullscreen"
    "--kiosk"
    "--noerrdialogs"
    "--disable-infobars"
    "--check-for-update-interval=31536000"
    
    # Memory optimization
    "--single-process"
    "--process-per-site"
    "--disable-features=site-per-process"
    "--disable-background-networking"
    "--disable-background-timer-throttling"
    "--disable-backgrounding-occluded-windows"
    "--disable-renderer-backgrounding"
    "--memory-model=low"
    "--disable-dev-shm-usage"
    
    # GPU and rendering optimization
    "--disable-gpu-vsync"
    "--disable-gpu-compositing"
    "--disable-smooth-scrolling"
    "--disable-software-rasterizer"
    "--disable-gpu-driver-bug-workarounds"
    "--disable-accelerated-2d-canvas"
    
    # Cache and storage settings
    "--disk-cache-size=1"
    "--media-cache-size=1"
    "--disable-application-cache"
    "--disable-sync"
    "--disable-translate"
    "--disable-extensions"
    "--disable-default-apps"
    
    # Security and privacy
    "--no-first-run"
    "--no-default-browser-check"
    "--disable-sync-preferences"
    "--disable-prompt-on-repost"
    "--disable-client-side-phishing-detection"
    "--disable-component-update"
    
    # Network settings
    "--disable-quic"
    "--disable-features=NetworkService"
    "--disable-background-networking"
)

# Log helper function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/dakboard-browser.log
}

# Function to check if network is available
check_network() {
    # Try multiple DNS servers
    for dns in 8.8.8.8 1.1.1.1 9.9.9.9; do
        if ping -c 1 -W 5 $dns > /dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}

# Function to check if X server is running
check_x_server() {
    for i in {1..30}; do
        if xset q &>/dev/null; then
            return 0
        fi
        sleep 1
    done
    return 1
}

# Function to cleanup zombie processes
cleanup_zombies() {
    pkill -9 -f "chromium" || true
    pkill -9 -f "chrome" || true
    sleep 2
}

# Function to set screen settings
configure_screen() {
    # Disable screen blanking and screensaver
    xset s off
    xset s noblank
    xset -dpms
    
    # Set default screen resolution
    xrandr --output HDMI-1 --mode 1920x1080 --rate 60
}

# Function to monitor browser health
monitor_browser() {
    local pid=$1
    while true; do
        if ! ps -p $pid > /dev/null; then
            log "Browser process died, restarting..."
            return 1
        fi
        
        # Check memory usage
        local mem_usage=$(ps -o rss= -p $pid)
        if [[ $mem_usage -gt 1500000 ]]; then  # 1.5GB
            log "Browser memory usage too high ($mem_usage KB), restarting..."
            return 1
        }
        
        sleep 30
    done
}

# Main browser launch function
launch_browser() {
    local retry_count=0
    local max_retries=5
    
    while [[ $retry_count -lt $max_retries ]]; do
        if ! check_network; then
            log "Waiting for network connection..."
            sleep 5
            continue
        fi

        cleanup_zombies
        configure_screen
        
        log "Starting browser..."
        chromium-browser "${CHROME_FLAGS[@]}" \
            file:///home/dakboard/startup/browser-init.html &
        
        local browser_pid=$!
        log "Browser started with PID: $browser_pid"
        
        # Monitor browser health
        if monitor_browser $browser_pid; then
            retry_count=0  # Reset counter on successful run
        else
            retry_count=$((retry_count + 1))
            log "Browser restart attempt $retry_count of $max_retries"
            sleep 5
        fi
    done
    
    log "Maximum retry count reached. Please check system logs."
    return 1
}

# Main execution
main() {
    log "Starting DAKboard browser optimization script"
    
    if ! check_x_server; then
        log "X server not available after 30 seconds, exiting"
        exit 1
    fi
    
    # Create RAM disk for browser cache if it doesn't exist
    if [[ ! -d /dev/shm/chromium-cache ]]; then
        mkdir -p /dev/shm/chromium-cache
        chmod 777 /dev/shm/chromium-cache
    fi
    
    # Set environment for cache directory
    export CHROMIUM_USER_FLAGS="--disk-cache-dir=/dev/shm/chromium-cache"
    
    # Launch browser with monitoring
    launch_browser
}

# Run main function
main "$@"