# Cloudflare DDNS Updater

[![License](https://img.shields.io/badge/license-GPL3-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.6%2B-blue)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/platform-Linux-success)]()
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=KAIKOAUGUSTIN_dnscript&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=KAIKOAUGUSTIN_dnscript)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=KAIKOAUGUSTIN_dnscript&metric=reliability_rating)](https://sonarcloud.io/summary/new_code?id=KAIKOAUGUSTIN_dnscript)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=KAIKOAUGUSTIN_dnscript&metric=vulnerabilities)](https://sonarcloud.io/summary/new_code?id=KAIKOAUGUSTIN_dnscript)

A lightweight Python daemon that keeps your Cloudflare DNS records in sync with your network's public IP address — built for home labs, self-hosted infrastructure, and lightweight production environments.

---

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Logs & Monitoring](#logs--monitoring)
- [Updating](#updating)
- [Uninstalling](#uninstalling)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- Automatic public IP detection and DNS record syncing
- Telegram notifications on IP changes
- Optional `cloudflared` health check per record before updating
- Dynamic config reload — changes to `config.yaml` take effect on the next cycle without a restart
- Structured logging with configurable log level
- Isolated Python environment (`venv`) provisioned by the installer
- Managed by `systemd` with automatic restart on failure

---

## Requirements

- Linux (Debian, Ubuntu, CentOS, or compatible)
- Python 3.6+
- `sudo` access for installation and service management
- Cloudflare API token with `Zone:Read` and `DNS:Edit` permissions
- _(Optional)_ A Telegram bot for IP change notifications

---

## Installation

```bash
curl -sSL https://raw.githubusercontent.com/KAIKOAUGUSTIN/dnscript/main/install.sh -o install.sh
chmod +x install.sh
sudo ./install.sh
```

The installer sets up the following layout and exits:

```
/opt/ddns-updater/
├── ddns_updater.py
├── config.yaml
└── venv/

/etc/systemd/system/
└── ddns-updater.service

/var/log/
└── ddns_updater.log
```

An `uninstall.sh` script is also saved to the directory from which you ran the installer.

Once installation is complete, edit the config before starting the service:

```bash
sudo nano /opt/ddns-updater/config.yaml
sudo systemctl start ddns-updater.service
```

---

## Configuration

All configuration lives in `/opt/ddns-updater/config.yaml`. The script reads this file on every update cycle, so most changes apply without a service restart.

### Full example

```yaml
settings:
  update_interval: 300
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

  - name: "nas.example.com"
    type: "A"
    proxied: true
    use_cloudflared: true
```

### Reference

#### `settings`

| Key               | Type   | Description                                                      |
|-------------------|--------|------------------------------------------------------------------|
| `update_interval` | int    | Seconds between update cycles. Default: `300`                    |
| `log_level`       | string | Logging verbosity. One of `DEBUG`, `INFO`, `WARNING`, `ERROR`    |
| `log_file`        | string | Path to the log file                                             |

#### `cloudflare`

| Key         | Description                                                              |
|-------------|--------------------------------------------------------------------------|
| `api_token` | Cloudflare API token with `Zone:Read` and `DNS:Edit` permissions         |
| `zone_id`   | The zone ID for your domain                                              |

#### `telegram`

| Key         | Type   | Description                                          |
|-------------|--------|------------------------------------------------------|
| `enabled`   | bool   | Enable or disable Telegram notifications             |
| `bot_token` | string | Token from [@BotFather](https://t.me/BotFather)      |
| `chat_id`   | string | Target chat or user ID                               |

#### `dns_records`

| Key               | Type   | Description                                                                                                              |
|-------------------|--------|--------------------------------------------------------------------------------------------------------------------------|
| `name`            | string | Fully qualified domain name to update                                                                                    |
| `type`            | string | DNS record type (e.g. `A`)                                                                                               |
| `proxied`         | bool   | Whether to proxy traffic through Cloudflare                                                                              |
| `use_cloudflared` | bool   | If `true`, checks that `cloudflared` is active via `systemctl is-active` before updating this record                    |

---

## Usage

The service starts automatically on boot. To manage it manually:

```bash
# Start / stop / restart
sudo systemctl start ddns-updater.service
sudo systemctl stop ddns-updater.service
sudo systemctl restart ddns-updater.service

# Check current status
sudo systemctl status ddns-updater.service
```

---

## Logs & Monitoring

```bash
# Stream logs via journald
sudo journalctl -u ddns-updater.service -f

# Read the log file directly
sudo tail -n 200 /var/log/ddns_updater.log
```

---

## Updating

To update the script without touching your configuration:

```bash
sudo systemctl stop ddns-updater.service
sudo curl -sSL https://raw.githubusercontent.com/KAIKOAUGUSTIN/dnscript/main/ddns_updater.py \
  -o /opt/ddns-updater/ddns_updater.py
sudo chmod +x /opt/ddns-updater/ddns_updater.py
sudo systemctl start ddns-updater.service
```

`config.yaml` is never overwritten by this process.

---

## Uninstalling

Run the `uninstall.sh` that was downloaded alongside the installer:

```bash
chmod +x ./uninstall.sh
sudo ./uninstall.sh
```

You will be prompted to confirm before anything is removed. The script will:

- Stop and disable the `systemd` service
- Remove `/etc/systemd/system/ddns-updater.service`
- Remove `/opt/ddns-updater/` (including the `venv`)
- Remove `/var/log/ddns_updater.log`
- Attempt to uninstall `requests` and `PyYAML` globally via `pip3 uninstall -y`
- Run `systemctl daemon-reload`

---

## Contributing

1. Fork the repository
2. Create a branch for your change (`git checkout -b feat/your-feature`)
3. Commit your changes
4. Open a Pull Request describing the motivation and what changed

Please open an Issue first for significant changes so we can discuss the approach before you invest time in the implementation.

---

## License

Distributed under the GPL-3.0 License. See [`LICENSE`](LICENSE) for details.
