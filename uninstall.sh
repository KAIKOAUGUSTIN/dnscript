#!/bin/bash

SERVICE_NAME="ddns-updater.service"
INSTALL_DIR="/opt/ddns-updater"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
LOG_FILE="/var/log/ddns_updater.log"

echo "⚠️  This will completely remove ddns-updater from your system."
read -p "Type 'yes' to continue: " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo "🔧 Stopping service..."
systemctl stop $SERVICE_NAME 2>/dev/null

echo "🔧 Disabling service..."
systemctl disable $SERVICE_NAME 2>/dev/null

if [ -f "$SERVICE_PATH" ]; then
    echo "🗑️ Removing systemd service file..."
    rm -f $SERVICE_PATH
fi

echo "🔄 Reloading systemd..."
systemctl daemon-reload

if [ -d "$INSTALL_DIR" ]; then
    echo "🗑️ Removing installation directory..."
    rm -rf $INSTALL_DIR
fi

if [ -f "$LOG_FILE" ]; then
    echo "🗑️ Removing log file..."
    rm -f $LOG_FILE
fi

echo "🐍 Checking for global pip packages..."

# Remove possíveis dependências globais
pip3 uninstall -y requests PyYAML 2>/dev/null

echo "🧹 Cleaning empty pip cache..."
pip3 cache purge 2>/dev/null

echo "✅ ddns-updater fully removed."
