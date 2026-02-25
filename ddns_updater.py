#!/usr/bin/env python3
# ddns_updater.py
# Upload this to your GitHub repo for the installer to fetch it

import requests
import yaml
import logging
import subprocess
import sys
import os

# Determine config path based on installation directory
INSTALL_DIR = "/opt/ddns-updater"
CONFIG_PATH = os.path.join(INSTALL_DIR, 'config.yaml')

def load_config():
    try:
        with open(CONFIG_PATH, 'r') as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Error: Config file not found at {CONFIG_PATH}")
        sys.exit(1)

def setup_logging(log_file, level):
    # Ensure log directory exists
    log_dir = os.path.dirname(log_file)
    if log_dir and not os.path.exists(log_dir):
        os.makedirs(log_dir)
        
    logging.basicConfig(
        level=getattr(logging, level),
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler()
        ]
    )

def get_public_ip():
    try:
        return requests.get('https://api.ipify.org', timeout=5).text.strip()
    except Exception as e:
        logging.error(f"Failed to get public IP: {e}")
        return None

def check_cloudflared_status():
    try:
        result = subprocess.run(['systemctl', 'is-active', 'cloudflared'], capture_output=True, text=True)
        return result.stdout.strip() == 'active'
    except Exception:
        return False

def send_telegram_message(token, chat_id, message):
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    payload = {
        'chat_id': chat_id,
        'text': message,
        'parse_mode': 'Markdown'
    }
    try:
        requests.post(url, json=payload, timeout=5)
    except Exception as e:
        logging.error(f"Failed to send Telegram message: {e}")

def get_dns_records(zone_id, headers, record_name, record_type):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    params = {'type': record_type, 'name': record_name}
    try:
        response = requests.get(url, headers=headers, params=params, timeout=5)
        response.raise_for_status()
        return response.json().get('result', [])
    except Exception as e:
        logging.error(f"Failed to fetch DNS records: {e}")
        return []

def update_dns_record(zone_id, headers, record_id, name, type, content, proxied):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{record_id}"
    data = {
        'type': type,
        'name': name,
        'content': content,
        'proxied': proxied
    }
    try:
        response = requests.put(url, headers=headers, json=data, timeout=5)
        return response.json().get('success', False)
    except Exception as e:
        logging.error(f"Failed to update DNS record: {e}")
        return False

def create_dns_record(zone_id, headers, name, type, content, proxied):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    data = {
        'type': type,
        'name': name,
        'content': content,
        'proxied': proxied
    }
    try:
        response = requests.post(url, headers=headers, json=data, timeout=5)
        return response.json().get('success', False)
    except Exception as e:
        logging.error(f"Failed to create DNS record: {e}")
        return False

def main():
    config = load_config()
    setup_logging(config['settings'].get('log_file', '/var/log/ddns_updater.log'), 
                  config['settings'].get('log_level', 'INFO'))
    
    cf_token = config['cloudflare']['api_token']
    zone_id = config['cloudflare']['zone_id']
    headers = {
        'Authorization': f'Bearer {cf_token}',
        'Content-Type': 'application/json'
    }
    
    current_ip = get_public_ip()
    if not current_ip:
        logging.error("Could not determine public IP. Exiting.")
        return

    logging.info(f"Current Public IP: {current_ip}")

    for record in config['dns_records']:
        name = record['name']
        r_type = record['type']
        proxied = record.get('proxied', False)
        use_cloudflared = record.get('use_cloudflared', False)

        if use_cloudflared:
            if not check_cloudflared_status():
                logging.warning(f"Skipping {name}: cloudflared is not active.")
                continue
            else:
                logging.info(f"Cloudflared status verified for {name}.")

        existing_records = get_dns_records(zone_id, headers, name, r_type)
        
        match_found = False
        updated = False
        
        for rec in existing_records:
            if rec['content'] == current_ip:
                match_found = True
                logging.info(f"Record {name} already points to {current_ip}.")
                break
            else:
                # Record exists but has different IP. 
                # Update this specific record ID to preserve other records (e.g. AAAA or other A records)
                logging.info(f"Updating record {rec['id']} ({rec['content']}) to {current_ip}")
                success = update_dns_record(zone_id, headers, rec['id'], name, r_type, current_ip, proxied)
                if success:
                    updated = True
                    msg = f"🔄 *DNS Updated*\nHost: `{name}`\nNew IP: `{current_ip}`"
                    if config['telegram'].get('enabled'):
                        send_telegram_message(
                            config['telegram']['bot_token'],
                            config['telegram']['chat_id'],
                            msg
                        )
                break
        
        if not match_found and not updated:
            # No record matched current IP, and we didn't update an existing one.
            # Create a new record (adds them without deleting others)
            logging.info(f"Creating new record for {name} with {current_ip}")
            success = create_dns_record(zone_id, headers, name, r_type, current_ip, proxied)
            if success:
                msg = f"➕ *DNS Created*\nHost: `{name}`\nIP: `{current_ip}`"
                if config['telegram'].get('enabled'):
                    send_telegram_message(
                        config['telegram']['bot_token'],
                        config['telegram']['chat_id'],
                        msg
                    )

if __name__ == "__main__":
    main()Unit=ddns-updater.service

[Install]
WantedBy=timers.target
EOF

# Recarregar systemd
sudo systemctl daemon-reload

# Ativar timer
sudo systemctl enable ddns-updater.timer
sudo systemctl start ddns-updater.timer

echo "✅ Instalação concluída!"
echo "🔎 Verifique com: systemctl list-timers | grep ddns"
