#!/bin/bash

# CPU Cooler Installation Script
# This script automates the setup of the CPU cooler display service

set -e  # Exit on any error

echo "=== CPU Cooler Installation Script ==="
echo

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "❌ This script should NOT be run as root. Please run as a regular user."
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📁 Installation directory: $SCRIPT_DIR"
echo

# Check if required files exist
if [[ ! -f "$SCRIPT_DIR/cpu_cooler.py" ]]; then
    echo "❌ cpu_cooler.py not found in $SCRIPT_DIR"
    exit 1
fi

if [[ ! -f "$SCRIPT_DIR/99-cpu-cooler.rules" ]]; then
    echo "❌ 99-cpu-cooler.rules not found in $SCRIPT_DIR"
    exit 1
fi

if [[ ! -f "$SCRIPT_DIR/cpu-cooler.service" ]]; then
    echo "❌ cpu-cooler.service not found in $SCRIPT_DIR"
    exit 1
fi

echo "✅ All required files found"
echo

# Check for USB device
echo "🔍 Checking for CPU cooler USB device..."
if lsusb | grep -q "aa88:8666"; then
    echo "✅ CPU cooler device found (aa88:8666)"
else
    echo "⚠️  CPU cooler device not found. Make sure it's connected."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo

# Detect CPU type and temperature sensor
echo "🌡️  Detecting CPU temperature sensors..."
python3 -c "
import psutil
import sys

temps = psutil.sensors_temperatures()
if not temps:
    print('❌ No temperature sensors found')
    sys.exit(1)

print('Available sensors:')
for sensor, entries in temps.items():
    if entries:
        print(f'  - {sensor}: {len(entries)} sensor(s)')

# Determine the best sensor to use
if 'coretemp' in temps:
    sensor_name = 'coretemp'
    print(f'✅ Using Intel sensor: {sensor_name}')
elif 'k10temp' in temps:
    sensor_name = 'k10temp'
    print(f'✅ Using AMD sensor: {sensor_name}')
else:
    # Use the first available sensor
    sensor_name = list(temps.keys())[0]
    print(f'⚠️  Using first available sensor: {sensor_name}')

# Write the sensor name to a temporary file for the bash script
with open('/tmp/cpu_sensor_name', 'w') as f:
    f.write(sensor_name)
"

if [[ ! -f "/tmp/cpu_sensor_name" ]]; then
    echo "❌ Failed to detect CPU sensor"
    exit 1
fi

CPU_SENSOR=$(cat /tmp/cpu_sensor_name)
rm -f /tmp/cpu_sensor_name
echo "🎯 Selected sensor: $CPU_SENSOR"
echo

# Create Python virtual environment
echo "🐍 Setting up Python virtual environment..."
if [[ ! -d "$SCRIPT_DIR/.venv" ]]; then
    python3 -m venv "$SCRIPT_DIR/.venv"
    echo "✅ Virtual environment created"
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment and install packages
echo "📦 Installing Python packages..."
"$SCRIPT_DIR/.venv/bin/pip" install --upgrade pip
"$SCRIPT_DIR/.venv/bin/pip" install psutil pyusb

echo "✅ Python packages installed"
echo

# Update cpu_cooler.py with the correct sensor
echo "🔧 Updating cpu_cooler.py with detected sensor..."
sed -i "s/temps\['[^']*'\]/temps['$CPU_SENSOR']/g" "$SCRIPT_DIR/cpu_cooler.py"
echo "✅ cpu_cooler.py updated to use '$CPU_SENSOR' sensor"
echo

# Update service file with absolute paths
echo "🔧 Updating service file paths..."
SERVICE_FILE="$SCRIPT_DIR/cpu-cooler.service"
TEMP_SERVICE="/tmp/cpu-cooler.service"

sed "s|/home/rafaelwms/util/water-cooler|$SCRIPT_DIR|g" "$SERVICE_FILE" > "$TEMP_SERVICE"
echo "✅ Service file updated with current paths"
echo

# Install udev rule (requires sudo)
echo "🔐 Installing udev rule (requires sudo)..."
sudo cp "$SCRIPT_DIR/99-cpu-cooler.rules" /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
echo "✅ udev rule installed"
echo

# Install systemd service
echo "🚀 Installing systemd service..."
mkdir -p ~/.config/systemd/user
cp "$TEMP_SERVICE" ~/.config/systemd/user/cpu-cooler.service
systemctl --user daemon-reload
rm -f "$TEMP_SERVICE"
echo "✅ systemd service installed"
echo

# Test the script
echo "🧪 Testing the script..."
timeout 5s "$SCRIPT_DIR/.venv/bin/python" "$SCRIPT_DIR/cpu_cooler.py" || true
echo "✅ Script test completed"
echo

# Enable and start service
echo "🎬 Enabling and starting service..."
systemctl --user enable cpu-cooler.service
systemctl --user start cpu-cooler.service

# Check service status
if systemctl --user is-active --quiet cpu-cooler.service; then
    echo "✅ Service is running successfully"
else
    echo "⚠️  Service may not be running. Check status with:"
    echo "   systemctl --user status cpu-cooler.service"
fi
echo

echo "🎉 Installation completed successfully!"
echo
echo "📋 Summary:"
echo "   - CPU sensor: $CPU_SENSOR"
echo "   - Service: cpu-cooler.service"
echo "   - Status: systemctl --user status cpu-cooler.service"
echo "   - Logs: journalctl --user -u cpu-cooler.service -f"
echo
echo "🔄 The service will start automatically on boot."
echo "📱 Your CPU temperature should now be displayed on the cooler."