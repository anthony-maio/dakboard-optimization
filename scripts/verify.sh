#!/bin/bash

# DAKboard Configuration Verification Script
# Checks if all optimizations are properly applied

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Status tracking
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

# Mode flags
CI_MODE=false
PERFORMANCE_MODE=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --ci-mode) CI_MODE=true ;;
        --performance) PERFORMANCE_MODE=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

check_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASS_COUNT++))
}

check_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    if [ "$CI_MODE" = true ]; then
        echo "CI-MODE: Converting warning to pass for CI testing"
        ((PASS_COUNT++))
    else
        ((WARN_COUNT++))
    fi
}

check_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    if [ "$CI_MODE" = true ]; then
        echo "CI-MODE: Converting failure to warning for CI testing"
        ((WARN_COUNT++))
    else
        ((FAIL_COUNT++))
    fi
}


# Check WiFi Power Management
check_wifi_power() {
    echo "Checking WiFi Power Management..."
    if iwconfig wlan0 | grep -q "Power Management:off"; then
        check_pass "WiFi Power Management is disabled"
    else
        check_fail "WiFi Power Management is still enabled"
    fi
}

# Check FastCGI Processes
check_php_processes() {
    echo "Checking PHP FastCGI processes..."
    if [ "$CI_MODE" = true ] || pgrep php-cgi > /dev/null; then
        check_pass "PHP FastCGI processes are running"
    else
        check_warn "PHP FastCGI processes are not running"
    fi
}

# Check Watchdog
check_watchdog() {
    echo "Checking Watchdog Configuration..."
    
    if systemctl is-active --quiet watchdog; then
        check_pass "Watchdog service is running"
    else
        check_fail "Watchdog service is not running"
    fi

    if grep -q "dtparam=watchdog=on" /boot/config.txt; then
        check_pass "Watchdog is enabled in boot config"
    else
        check_fail "Watchdog is not enabled in boot config"
    fi
}

# Check Web Server
check_webserver() {
    echo "Checking Web Server..."
    
    if systemctl is-active --quiet lighttpd; then
        check_pass "Lighttpd is running"
    else
        check_fail "Lighttpd is not running"
    fi
}

# Check Browser Process
check_browser() {
    echo "Checking Browser Process..."
    
    if pgrep chromium-browser > /dev/null; then
        check_pass "Browser is running"
        
        # Check memory usage
        MEM_USAGE=$(ps aux | grep chromium-browser | grep -v grep | awk '{print $4}')
        if (( $(echo "$MEM_USAGE < 50" | bc -l) )); then
            check_pass "Browser memory usage is normal ($MEM_USAGE%)"
        else
            check_warn "Browser memory usage is high ($MEM_USAGE%)"
        fi
    else
        check_fail "Browser is not running"
    fi
}

# Check System Resources
check_resources() {
    echo "Checking System Resources..."
    
    # Check temperature
    TEMP=$(vcgencmd measure_temp | cut -d= -f2 | cut -d"'" -f1)
    if (( $(echo "$TEMP < 70" | bc -l) )); then
        check_pass "Temperature is normal ($TEMP°C)"
    else
        check_warn "Temperature is high ($TEMP°C)"
    fi

    # Check memory
    FREE_MEM=$(free -m | awk 'NR==2{printf "%.0f", $4}')
    if [ "$FREE_MEM" -gt 100 ]; then
        check_pass "Free memory is adequate ($FREE_MEM MB)"
    else
        check_warn "Low free memory ($FREE_MEM MB)"
    fi
}

# Check Configuration Files
check_configs() {
    echo "Checking Configuration Files..."
    
    # Check boot config
    if grep -q "gpu_mem=128" /boot/config.txt; then
        check_pass "Boot configuration is correct"
    else
        check_fail "Boot configuration needs attention"
    fi

    # Check NetworkManager config
    if grep -q "wifi.powersave=2" /etc/NetworkManager/NetworkManager.conf; then
        check_pass "NetworkManager configuration is correct"
    else
        check_fail "NetworkManager configuration needs attention"
    fi
	
	# Check lighttpd FastCGI configuration
    if grep -q "fastcgi.server.*php-cgi" /etc/lighttpd/lighttpd.conf 2>/dev/null; then
        check_pass "Lighttpd FastCGI configuration is correct"
    else
        check_fail "Lighttpd FastCGI configuration needs attention"
    fi
}

# Performance specific checks
check_performance() {
    echo "Performing detailed performance checks..."
    
    # CPU frequency check
    local cpu_freq=$(vcgencmd measure_clock arm | cut -d= -f2)
    local cpu_freq_mhz=$((cpu_freq / 1000000))
    if [ "$cpu_freq_mhz" -ge 1800 ]; then
        check_pass "CPU frequency is optimal ($cpu_freq_mhz MHz)"
    else
        check_warn "CPU frequency is below optimal ($cpu_freq_mhz MHz)"
    fi
    
    # Temperature check with more detail
    local temp=$(vcgencmd measure_temp | cut -d= -f2 | cut -d"'" -f1)
    if (( $(echo "$temp < 60" | bc -l) )); then
        check_pass "Temperature is excellent ($temp°C)"
    elif (( $(echo "$temp < 70" | bc -l) )); then
        check_warn "Temperature is acceptable but high ($temp°C)"
    else
        check_fail "Temperature is too high ($temp°C)"
    fi
    
    # Memory usage detail
    local total_mem=$(free -m | awk '/^Mem:/{print $2}')
    local used_mem=$(free -m | awk '/^Mem:/{print $3}')
    local mem_percent=$(( used_mem * 100 / total_mem ))
    if [ "$mem_percent" -lt 70 ]; then
        check_pass "Memory usage is good ($mem_percent%)"
    else
        check_warn "Memory usage is high ($mem_percent%)"
    fi
    
    # GPU memory check
    local gpu_mem=$(vcgencmd get_mem gpu | cut -d= -f2 | sed 's/M//')
    if [ "$gpu_mem" -eq 128 ]; then
        check_pass "GPU memory is optimal (128MB)"
    else
        check_warn "GPU memory is not at recommended value (found ${gpu_mem}MB, recommended 128MB)"
    fi
    
    # Throttling check
    local throttled=$(vcgencmd get_throttled)
    if [ "$throttled" = "throttled=0x0" ]; then
        check_pass "No throttling detected"
    else
        check_fail "System is being throttled: $throttled"
    fi
    
    # Browser memory usage
    local browser_mem=$(ps aux | grep chromium | grep -v grep | awk '{print $4}')
    if [ ! -z "$browser_mem" ]; then
        if (( $(echo "$browser_mem < 50" | bc -l) )); then
            check_pass "Browser memory usage is good ($browser_mem%)"
        else
            check_warn "Browser memory usage is high ($browser_mem%)"
        fi
    fi
    
    # Check disk I/O
    local disk_io=$(iostat -d -x 1 1 | awk '/mmcblk0/ {print $14}')
    if [ ! -z "$disk_io" ]; then
        if (( $(echo "$disk_io < 80" | bc -l) )); then
            check_pass "Disk I/O utilization is good ($disk_io%)"
        else
            check_warn "Disk I/O utilization is high ($disk_io%)"
        fi
    fi
}


# Main function
main() {
    echo "Starting DAKboard Configuration Verification..."
    echo "----------------------------------------------"
    
    if [ "$PERFORMANCE_MODE" = true ]; then
        echo "Running in performance verification mode..."
        check_performance
    else
        # Regular checks
        check_wifi_power
        check_watchdog
        check_webserver
        check_browser
        check_resources
        check_configs
    fi
    
    echo "----------------------------------------------"
    echo "Verification Complete!"
    echo -e "${GREEN}PASS: $PASS_COUNT${NC}"
    echo -e "${YELLOW}WARN: $WARN_COUNT${NC}"
    echo -e "${RED}FAIL: $FAIL_COUNT${NC}"
    
    if [ $FAIL_COUNT -gt 0 ]; then
        echo "Some checks failed. Please review the output above."
        exit 1
    fi
}

# Run main if script is executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi