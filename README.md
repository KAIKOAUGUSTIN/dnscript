# 🌐 Cloudflare DDNS Updater

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.6%2B-blue)
![Platform](https://img.shields.io/badge/platform-Linux-success)
![Cloudflare](https://img.shields.io/badge/API-Cloudflare-orange)
![Systemd](https://img.shields.io/badge/service-systemd-lightgrey)
![Status](https://img.shields.io/badge/status-production-brightgreen)

Automated Python-based Dynamic DNS updater for Cloudflare with Telegram
notifications, Cloudflared tunnel validation, structured logging, and
systemd timer integration.

------------------------------------------------------------------------

## 🚀 Overview

Cloudflare DDNS Updater keeps your DNS records automatically
synchronized with your public IP address.\
It is designed for home labs, self-hosted infrastructure, VPS
environments, and production-grade setups.

------------------------------------------------------------------------

## ✨ Features

-   🔄 Automatic public IP detection and DNS update
-   🛡 Preserves existing DNS records (no destructive operations)
-   📱 Telegram notifications on IP change
-   🔒 Optional Cloudflared tunnel validation
-   📝 Structured logging with configurable log levels
-   ⏱ systemd timer integration (default: every 5 minutes)
-   ⚙ Fully configurable YAML configuration file

------------------------------------------------------------------------

## 📦 Requirements

-   Linux (Ubuntu, Debian, CentOS, etc.)
-   Python 3.6+
-   Python packages:
    -   requests
    -   pyyaml
-   Cloudflare API Token (Zone:Read + DNS:Edit)
-   sudo permissions for installation

------------------------------------------------------------------------

## 📂 Project Structure

    /opt/ddns-updater/
    ├── ddns_updater.py
    ├── config.yaml
    └── logs (/var/log/ddns_updater.log)

    /etc/systemd/system/
    ├── ddns-updater.service
    └── ddns-updater.timer

------------------------------------------------------------------------

## ⚙️ Installation

### 1️⃣ Download Installer

``` bash
curl -sSL https://raw.githubusercontent.com/KAIKOAUGUSTIN/dnscript/main/install.sh -o install.sh
chmod +x install.sh
sudo ./install.sh
```

### 2️⃣ Configure Credentials

``` bash
sudo nano /opt/ddns-updater/config.yaml
```

------------------------------------------------------------------------

## 🛠 Configuration Example

``` yaml
settings:
  check_interval: 300
  log_level: INFO
  log_file: "/var/log/ddns_updater.log"

cloudflare:
  api_token: "YOUR_API_TOKEN"
  zone_id: "YOUR_ZONE_ID"

telegram:
  enabled: true
  bot_token: "YOUR_BOT_TOKEN"
  chat_id: "YOUR_CHAT_ID"

dns_records:
  - name: "home.example.com"
    type: "A"
    proxied: false
    use_cloudflared: false
```

------------------------------------------------------------------------

## 🔐 Security Best Practices

-   Never commit `config.yaml` to version control
-   Use minimal Cloudflare API permissions
-   Restrict file permissions:

``` bash
sudo chmod 600 /opt/ddns-updater/config.yaml
sudo chown root:root /opt/ddns-updater/config.yaml
```

------------------------------------------------------------------------

## 🧪 Manual Execution

``` bash
sudo python3 /opt/ddns-updater/ddns_updater.py
```

------------------------------------------------------------------------

## 🔎 Monitoring

Check service status:

``` bash
sudo systemctl status ddns-updater.timer
```

View logs:

``` bash
sudo journalctl -u ddns-updater.service -f
```

------------------------------------------------------------------------

## 🔄 Updating

``` bash
sudo systemctl stop ddns-updater.timer
sudo curl -sSL https://raw.githubusercontent.com/KAIKOAUGUSTIN/dnscript/main/ddns_updater.py -o /opt/ddns-updater/ddns_updater.py
sudo chmod +x /opt/ddns-updater/ddns_updater.py
sudo systemctl start ddns-updater.timer
```

------------------------------------------------------------------------

## 🤝 Contributing

1.  Fork the repository
2.  Create a feature branch
3.  Commit changes
4.  Open a Pull Request

------------------------------------------------------------------------

## 📜 License

This project is licensed under the MIT License.

------------------------------------------------------------------------

## ⭐ Support

If this project helped you, consider giving it a star on GitHub.
