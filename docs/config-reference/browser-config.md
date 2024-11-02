# Browser Configuration Reference

## Overview
Browser configuration optimizes Chromium for kiosk operation and performance on the Raspberry Pi.

## Configuration Location
```bash
/home/dakboard/startup/browser.sh
```

## Key Configuration Parameters

### Window Management
```bash
CHROME_FLAGS=(
    # Basic window settings
    "--window-size=1920,1080"
    "--window-position=0,0"
    "--start-fullscreen"
    "--kiosk"
    
    # Interface settings
    "--noerrdialogs"
    "--disable-infobars"
    "--check-for-update-interval=31536000"
)
```

### Memory Optimization
```bash
CHROME_FLAGS+=(
    # Process management
    "--single-process"
    "--process-per-site"
    "--disable-features=site-per-process"
    
    # Background processing
    "--disable-background-networking"
    "--disable-background-timer-throttling"
    "--disable-backgrounding-occluded-windows"
    "--disable-renderer-backgrounding"
    
    # Memory settings
    "--memory-model=low"
    "--disable-dev-shm-usage"
)
```

### GPU and Rendering
```bash
CHROME_FLAGS+=(
    # GPU settings
    "--disable-gpu-vsync"
    "--disable-gpu-compositing"
    "--disable-smooth-scrolling"
    "--disable-software-rasterizer"
)
```

### Cache Settings
```bash
CHROME_FLAGS+=(
    # Cache configuration
    "--disk-cache-size=1"
    "--media-cache-size=1"
    "--disable-application-cache"
)
```

## RAM Disk Configuration
```bash
# Create RAM disk for browser cache
if [[ ! -d /dev/shm/chromium-cache ]]; then
    mkdir -p /dev/shm/chromium-cache
    chmod 777 /dev/shm/chromium-cache
fi

# Set cache directory
export CHROMIUM_USER_FLAGS="--disk-cache-dir=/dev/shm/chromium-cache"
```

## Monitoring Commands
```bash
# Check browser process
ps aux | grep chromium

# Monitor memory usage
watch -n 1 'ps -o pid,ppid,cmd,%mem,%cpu --sort=-%mem | grep chromium'

# Check cache directory
ls -lh /dev/shm/chromium-cache/

# Monitor GPU usage
chrome://gpu
```

## Recovery Procedures

### Browser Crash Recovery
```bash
# Kill existing processes
killall -9 chromium-browser

# Clear cache
rm -rf /dev/shm/chromium-cache/*

# Restart browser
sudo systemctl restart dakboard
```

### Memory Issues
```bash
# Check memory usage
free -h

# Clear browser cache
rm -rf /dev/shm/chromium-cache/*

# Restart browser with reduced flags
chromium-browser --disable-gpu --disable-software-rasterizer
```

## Performance Tuning

### Memory Optimization
- Use `--single-process` for smaller memory footprint
- Enable RAM disk for cache
- Monitor memory usage regularly

### Display Performance
- Disable GPU features causing issues
- Use hardware acceleration selectively
- Monitor frame rates and tearing

### Stability Improvements
- Regular cache clearing
- Process monitoring
- Automatic crash recovery
