#!/bin/bash

# CPU Cooler Uninstallation Script
# This script removes all configurations and services installed by install.sh

set -e  # Exit on any error

echo "=== CPU Cooler Uninstallation Script ==="
echo

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "❌ This script should NOT be run as root. Please run as a regular user."
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📁 Project directory: $SCRIPT_DIR"
echo

# Stop and disable systemd service
echo "🛑 Stopping and disabling systemd service..."
if systemctl --user is-enabled cpu-cooler.service &>/dev/null; then
    systemctl --user stop cpu-cooler.service 2>/dev/null || true
    systemctl --user disable cpu-cooler.service 2>/dev/null || true
    echo "✅ Service stopped and disabled"
else
    echo "ℹ️  Service was not enabled"
fi

# Remove systemd service file
if [[ -f ~/.config/systemd/user/cpu-cooler.service ]]; then
    rm -f ~/.config/systemd/user/cpu-cooler.service
    systemctl --user daemon-reload
    echo "✅ systemd service file removed"
else
    echo "ℹ️  systemd service file not found"
fi

# Remove udev rule (requires sudo)
echo "🔐 Removing udev rule (requires sudo)..."
if [[ -f /etc/udev/rules.d/99-cpu-cooler.rules ]]; then
    sudo rm -f /etc/udev/rules.d/99-cpu-cooler.rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    echo "✅ udev rule removed"
else
    echo "ℹ️  udev rule not found"
fi

# Ask about removing Python virtual environment
echo
echo "🐍 Python virtual environment removal:"
if [[ -d "$SCRIPT_DIR/.venv" ]]; then
    echo "   Found virtual environment at: $SCRIPT_DIR/.venv"
    read -p "   Remove Python virtual environment? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        rm -rf "$SCRIPT_DIR/.venv"
        echo "✅ Python virtual environment removed"
    else
        echo "ℹ️  Python virtual environment kept"
    fi
else
    echo "ℹ️  No virtual environment found"
fi

# Ask about removing project directory
echo
echo "📁 Project directory removal:"
echo "   Current project directory: $SCRIPT_DIR"
read -p "   Remove entire project directory? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "⚠️  This will remove the entire project directory and all files!"
    read -p "   Are you sure? Type 'DELETE' to confirm: " CONFIRM
    if [[ "$CONFIRM" == "DELETE" ]]; then
        cd ..
        rm -rf "$SCRIPT_DIR"
        echo "✅ Project directory removed completely"
        echo
        echo "🎉 Uninstallation completed successfully!"
        echo "   All traces of CPU Cooler have been removed from your system."
        exit 0
    else
        echo "ℹ️  Project directory removal cancelled"
    fi
else
    echo "ℹ️  Project directory kept"
fi

# Check for any remaining processes
echo
echo "🔍 Checking for running processes..."
if pgrep -f "cpu_cooler.py" >/dev/null; then
    echo "⚠️  Found running cpu_cooler.py processes. Terminating..."
    pkill -f "cpu_cooler.py" || true
    echo "✅ Processes terminated"
else
    echo "ℹ️  No running processes found"
fi

echo
echo "🎉 Uninstallation completed successfully!"
echo
echo "📋 Summary of removed components:"
echo "   ✅ systemd service (cpu-cooler.service)"
echo "   ✅ udev rule (/etc/udev/rules.d/99-cpu-cooler.rules)"
echo "   ✅ Running processes"
if [[ ! -d "$SCRIPT_DIR/.venv" ]]; then
    echo "   ✅ Python virtual environment"
fi
echo
echo "📁 Remaining files:"
echo "   - Project directory: $SCRIPT_DIR"
echo "   - Source code and configuration files"
echo
echo "💡 To completely remove the project, run this script again and"
echo "   choose to delete the project directory when prompted."