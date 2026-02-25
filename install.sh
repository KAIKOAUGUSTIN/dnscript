#!/bin/bash

# install.sh
# Installer for Cloudflare DDNS Updater
# IMPORTANT: Update the GITHUB_RAW_URL below with your own GitHub Raw links

set -e

# --- CONFIGURATION ---
# Replace this with your GitHub Raw URL (e.g., https://raw.githubusercontent.com/USER/REPO/BRANCH)
GITHUB_RAW_URL="https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main"
# ---------------------

INSTALL_DIR="/opt/ddns-updater"
SERVICE_NAME="ddns-updater"
LOG_FILE="/var/log/ddns_updater.log"

echo "🚀 Starting Cloudflare DDNS Updater Installation..."

# 1. Check for curl
if ! command -v curl &> /dev/null; then
    echo "❌ curl is not installed. Please install it first."
    exit 1
fi

# 2. Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install it first."
    exit 1
fi

# 3. Create Directory
sudo mkdir -p $INSTALL_DIR
echo "📁 Created directory: $INSTALL_DIR"

# 4. Download Main Script
echo "📥 Downloading ddns_updater.py..."
sudo curl -sSL "$GITHUB_RAW_URL/ddns_updater.py" -o "$INSTALL_DIR/ddns_updater.py"
sudo chmod +x "$INSTALL_DIR/ddns_updater.py"

# 5. Download Config File (Only if it doesn't exist to preserve credentials)
if [ ! -f "$INSTALL_DIR/config.yaml" ]; then
    echo "📥 Downloading config.yaml..."
    sudo curl -sSL "$GITHUB_RAW_URL/config.yaml" -o "$INSTALL_DIR/config.yaml"
    echo "⚠️  Please edit $INSTALL_DIR/config.yaml with your credentials."
else
    echo "💾 config.yaml already exists. Skipping download to preserve credentials."
fi

# 6. Set Permissions (Secure Config)
sudo chmod 700 $INSTALL_DIR
sudo chmod 600 $INSTALL_DIR/config.yaml
echo "🔒 Permissions secured."

# 7. Install Python Dependencies
echo "📦 Installing Python dependencies..."
sudo pip3 install requests pyyaml

# 8. Create Log File
sudo touch $LOG_FILE
sudo chmod 644 $LOG_FILE

# 9. Create Systemd Service
echo "⚙️ Setting up Systemd service..."
sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME.service <<EOF
[Unit]
Description=Cloudflare DDNS Updater
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/python3 $INSTALL_DIR/ddns_updater.py
WorkingDirectory=$INSTALL_DIR
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF"

# 10. Create Timer (To run every 5 minutes)
sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME.timer <<EOF
[Unit]
Description=Run DDNS Updater every 5 minutes
Requires=$SERVICE_NAME.service

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=$SERVICE_NAME.service

[Install]
WantedBy=timers.target
EOF"

# 11. Enable and Start
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME.timer
sudo systemctl start $SERVICE_NAME.timer

echo "✅ Installation Complete!"
echo "📝 Config file location: $INSTALL_DIR/config.yaml"
echo "🔍 Check status with: sudo systemctl status $SERVICE_NAME.timer"
echo "📄 View logs with: sudo journalctl -u $SERVICE_NAME.service"
