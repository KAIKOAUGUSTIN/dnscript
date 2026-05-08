# Cloudflare DDNS Updater

![License](https://img.shields.io/badge/license-GPL3-blue.svg)
![Python](https://img.shields.io/badge/python-3.10%2B-blue)
![Platform](https://img.shields.io/badge/platform-Linux-success)
![Cloudflare](https://img.shields.io/badge/API-Cloudflare-orange)
![Systemd](https://img.shields.io/badge/service-systemd-lightgrey)
![Status](https://img.shields.io/badge/status-production-brightgreen)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=KAIKOAUGUSTIN_dnscript&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=KAIKOAUGUSTIN_dnscript)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=KAIKOAUGUSTIN_dnscript&metric=reliability_rating)](https://sonarcloud.io/summary/new_code?id=KAIKOAUGUSTIN_dnscript)

## Overview

A lightweight, production-ready dynamic DNS updater for Cloudflare that automatically keeps your DNS records in sync with your current public IP address. Designed for homelab setups, self-hosted infrastructure, and environments where static IPs aren't available.

## Features

- **Automatic IP Detection** – Monitors your public IP and updates Cloudflare records only when changes occur
- **Cloudflare API Integration** – Direct, efficient integration using Cloudflare's official API
- **Systemd Integration** – Runs as a managed system service with automatic restart capabilities
- **Minimal Overhead** – Lightweight Python implementation suitable for low-resource environments
- **Credential Security** – Encrypted credential handling and secure token management
- **Detailed Logging** – Comprehensive logging for monitoring and debugging
- **Multiple Record Support** – Update single or multiple DNS records simultaneously
- **IPv4 & IPv6 Ready** – Full support for both address families

## Requirements

- **Python** 3.10 or higher
- **Linux** system with systemd
- **Cloudflare Account** with API access enabled
- **Cloudflare API Token** with DNS edit permissions

## Quick Start

### 1. Installation

```bash
git clone https://github.com/KAIKOAUGUSTIN/cloudflare-ddns-updater.git
cd cloudflare-ddns-updater
pip install -r requirements.txt
```

### 2. Configuration

Create a `.env` file in the project root:

```env
CLOUDFLARE_API_TOKEN=your_api_token_here
CLOUDFLARE_ZONE_ID=your_zone_id_here
CLOUDFLARE_RECORD_IDS=record_id_1,record_id_2
CHECK_INTERVAL=300
LOG_LEVEL=INFO
```

### 3. Setup as Systemd Service

```bash
sudo cp cloudflare-ddns.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable cloudflare-ddns
sudo systemctl start cloudflare-ddns
```

### 4. Verify Status

```bash
sudo systemctl status cloudflare-ddns
journalctl -u cloudflare-ddns -f
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `CLOUDFLARE_API_TOKEN` | Your Cloudflare API token | *Required* |
| `CLOUDFLARE_ZONE_ID` | The zone ID from Cloudflare dashboard | *Required* |
| `CLOUDFLARE_RECORD_IDS` | Comma-separated list of record IDs to update | *Required* |
| `CHECK_INTERVAL` | Time in seconds between IP checks | `300` |
| `LOG_LEVEL` | Logging verbosity (DEBUG, INFO, WARNING, ERROR) | `INFO` |
| `IP_PROVIDER` | External service for IP detection | `ipify` |

### Getting Your Cloudflare Credentials

1. Visit [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Select your domain and navigate to **DNS**
3. Find the record IDs you want to update
4. Create an API token with DNS edit permissions
5. Copy the Zone ID from the overview page

## How It Works

The updater runs on a configurable interval and:

1. Fetches your current public IP address
2. Compares it against the last known value
3. If changed, updates all configured Cloudflare DNS records
4. Logs the result and waits for the next check cycle

This approach minimizes API calls and avoids unnecessary rate limiting.

## Troubleshooting

### Service won't start
```bash
journalctl -u cloudflare-ddns -n 50 -p err
```
Check that your `.env` file is in the correct location with proper permissions.

### IP updates not working
- Verify your API token has DNS edit permissions
- Confirm the record IDs are correct
- Check rate limiting: Cloudflare has API request limits
- Review logs: `journalctl -u cloudflare-ddns -f`

### High CPU or memory usage
Increase the `CHECK_INTERVAL` to reduce polling frequency (default is 5 minutes, which is reasonable for most cases).

## Advanced Usage

### Running Multiple Instances

Create separate service files for different domains:

```bash
sudo cp cloudflare-ddns.service /etc/systemd/system/cloudflare-ddns-example-com.service
```

Edit the new file and override the environment variables for each domain.

### Custom IP Providers

The updater supports multiple IP detection services. Configure via `IP_PROVIDER`:

- `ipify` – Default, uses IPv4/IPv6 APIs
- `ifconfig.me` – Alternative provider
- `wtfismyip` – Another reliable option

## Logging and Monitoring

Logs are sent to systemd journal by default:

```bash
# View recent logs
journalctl -u cloudflare-ddns --since "1 hour ago"

# Follow logs in real-time
journalctl -u cloudflare-ddns -f

# Export logs to file
journalctl -u cloudflare-ddns > dns-updates.log
```

## Security Considerations

- **Never commit credentials** – Always use environment variables
- **Restrict service file permissions** – Use `chmod 600` on config files
- **Rotate API tokens** – Periodically refresh your Cloudflare credentials
- **Monitor logs** – Watch for failed authentication attempts
- **Use strong tokens** – Generate tokens with minimal required permissions

## Performance

- Memory footprint: ~20–30 MB
- CPU usage: Minimal (idle between checks)
- Network traffic: ~1 KB per check
- Typical check duration: 2–5 seconds

## License

This project is licensed under the GPL-3.0 License. See `LICENSE` file for details.

## Contributing

Contributions are welcome! Please ensure code follows PEP 8 standards and includes appropriate tests.

```bash
# Run linting
pylint src/

# Run tests
pytest tests/
```

## Support

For issues, feature requests, or contributions, please open an issue or pull request on GitHub.

---

**Note:** This documentation assumes you're familiar with Linux systemd, environment variables, and Cloudflare's dashboard. For detailed Cloudflare API documentation, visit [developers.cloudflare.com](https://developers.cloudflare.com).
