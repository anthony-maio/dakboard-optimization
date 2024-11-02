#!/bin/bash

# DAKboard Optimization Installation Script
# Author: Anthony Maio
# Repository: https://github.com/anthony-maio/dakboard-optimization

set -e  # Exit on error

# Add to beginning of install.sh:
TEST_MODE=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --test-mode) TEST_MODE=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root"
   exit 1
}

# Backup function
backup_file() {
    local file=$1
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Creating backup of $file at $backup"
        cp "$file" "$backup"
    fi
}

# Check system requirements
check_requirements() {
    log_info "Checking system requirements..."
    
	if [ "$TEST_MODE" = true ]; then
        log_info "Running in test mode - skipping hardware checks"
        return 0
    fi
	
    # Check if running on Raspberry Pi 4
    if ! grep -q "Raspberry Pi 4" /proc/device-tree/model; then
        log_error "This script is designed for Raspberry Pi 4 only"
        exit 1
    }

    # Check RAM
    total_ram=$(free -m | awk '/^Mem:/{print $2}')
    if [[ $total_ram -lt 1024 ]]; then
        log_warn "Less than 1GB RAM detected. Some features may not work optimally"
    fi

    # Check if running DAKboardOS
    if ! grep -q "dakboard" /etc/os-release 2>/dev/null; then
        log_warn "DAKboardOS not detected. Some features may not work as expected"
    fi
}

# Install required packages
install_dependencies() {
    log_info "Installing required packages..."
    apt-get update
    apt-get install -y lighttpd php-cgi php-fpm

    # Enable required modules
    lighty-enable-mod fastcgi
    lighty-enable-mod fastcgi-php
}

# Configure system optimizations
configure_system() {
    log_info "Configuring system optimizations..."

    # Backup config.txt
    backup_file "/boot/config.txt"

    # Update boot configuration
    cat > "/boot/config.txt" << 'EOF'
# Display settings
disable_overscan=1
hdmi_force_hotplug=1
dtoverlay=vc4-fkms-v3d
max_framebuffers=2

# Performance settings
arm_boost=1
gpu_mem=128
over_voltage=2
arm_freq=1800

# WiFi optimizations
dtoverlay=disable-wifi-power-management
dtparam=ant2
dtparam=disable_wifi_btcoex=on

# Other settings
avoid_warnings=1
dtoverlay=gpio-shutdown
dtparam=audio=off

# Pi 4 specific
[pi4]
dtoverlay=vc4-fkms-v3d
max_framebuffers=2
EOF
}

# Configure web server
configure_webserver() {
    log_info "Configuring web server..."

    # Backup lighttpd configuration
    backup_file "/etc/lighttpd/lighttpd.conf"

    # Copy optimized lighttpd configuration
    cp "${SCRIPT_DIR}/../config/lighttpd/lighttpd.conf" "/etc/lighttpd/lighttpd.conf"

    # Create required directories
    mkdir -p /var/cache/lighttpd/compress
    chown -R www-data:www-data /var/cache/lighttpd
}

# Configure browser optimizations
configure_browser() {
    log_info "Configuring browser optimizations..."

    BROWSER_DIR="/home/dakboard/startup"
    
    # Backup existing files
    backup_file "${BROWSER_DIR}/browser.sh"
    backup_file "${BROWSER_DIR}/browser-init.html"

    # Copy new configurations
    cp "${SCRIPT_DIR}/../config/browser/browser.sh" "${BROWSER_DIR}/browser.sh"
    cp "${SCRIPT_DIR}/../config/browser/browser-init.html" "${BROWSER_DIR}/browser-init.html"

    # Set permissions
    chmod +x "${BROWSER_DIR}/browser.sh"
    chown -R dakboard:dakboard "${BROWSER_DIR}"
}

# Configure network optimizations
configure_network() {
    log_info "Configuring network optimizations..."

    # Backup NetworkManager configuration
    backup_file "/etc/NetworkManager/NetworkManager.conf"

    # Copy optimized NetworkManager configuration
    cp "${SCRIPT_DIR}/../config/system/NetworkManager.conf" "/etc/NetworkManager/NetworkManager.conf"

    # Disable WiFi power management
    if [[ -f /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf ]]; then
        sed -i 's/wifi.powersave = 3/wifi.powersave = 2/' /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
    fi
}

# Configure watchdog
configure_watchdog() {
    log_info "Configuring watchdog..."
    
    # Install watchdog package
    apt-get install -y watchdog
    
    # Backup existing config if it exists
    backup_file "/etc/watchdog.conf"
    
    # Create watchdog configuration
    cat > "/etc/watchdog.conf" << 'EOF'
# System load watchdog
max-load-1 = 24
max-load-5 = 18
max-load-15 = 12

# Memory watchdog
min-memory = 1
allocatable-memory = 1

# Temperature watchdog
temperature-sensor = /sys/class/thermal/thermal_zone0/temp
max-temperature = 80000

# Network watchdog
interface = wlan0
ping = 8.8.8.8
ping-count = 3

# File system watchdog
watchdog-device = /dev/watchdog
watchdog-timeout = 15

# Process watchdog
pidfile = /var/run/lighttpd.pid
pidfile = /var/run/php-fcgi.pid
EOF

    # Enable watchdog in boot config
    if ! grep -q "dtparam=watchdog=on" /boot/config.txt; then
        echo "dtparam=watchdog=on" >> /boot/config.txt
    fi
    
    # Enable and start watchdog service
    systemctl enable watchdog
    systemctl start watchdog
}

# Modify service restarts
restart_services() {
    if [ "$TEST_MODE" = true ]; then
        log_info "Test mode: Simulating service restarts"
        return 0
    fi
    # Restart services
    log_info "Restarting services..."
    systemctl restart lighttpd
    systemctl restart NetworkManager
    systemctl restart watchdog
}


# Main installation function
main() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    log_info "Starting DAKboard optimization installation..."
    
    # Run installation steps
    check_requirements
    install_dependencies
    configure_system
    configure_webserver
    configure_browser
    configure_network
	configure_watchdog

    restart_services

    log_info "Installation complete! A system reboot is recommended."
    log_info "Would you like to reboot now? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        log_info "Rebooting system..."
        reboot
    else
        log_info "Please reboot your system manually when convenient."
    fi
}

# Run main function
main "$@"