#!/bin/bash

set -e

INSTALL_DIR="/opt/ddns-updater"
VENV_DIR="$INSTALL_DIR/venv"
SERVICE_FILE="/etc/systemd/system/ddns-updater.service"
TIMER_FILE="/etc/systemd/system/ddns-updater.timer"

echo "🚀 Instalando Cloudflare DDNS Updater..."

# Criar diretório
sudo mkdir -p $INSTALL_DIR

# Baixar script principal
echo "📥 Baixando ddns_updater.py..."
sudo curl -sSL https://raw.githubusercontent.com/KAIKOAUGUSTIN/dnscript/main/ddns_updater.py -o $INSTALL_DIR/ddns_updater.py

# Baixar config se não existir
if [ ! -f "$INSTALL_DIR/config.yaml" ]; then
    echo "📥 Baixando config.yaml..."
    sudo curl -sSL https://raw.githubusercontent.com/KAIKOAUGUSTIN/dnscript/main/config.yaml -o $INSTALL_DIR/config.yaml
    echo "⚠️  Edite $INSTALL_DIR/config.yaml com suas credenciais."
else
    echo "💾 config.yaml já existe. Preservando."
fi

# Permissões
sudo chmod 600 $INSTALL_DIR/config.yaml
sudo chmod +x $INSTALL_DIR/ddns_updater.py

# Instalar dependências do sistema
echo "📦 Instalando dependências do sistema..."
sudo apt update
sudo apt install -y python3 python3-venv python3-pip curl

# Criar ambiente virtual
echo "🐍 Criando ambiente virtual..."
sudo python3 -m venv $VENV_DIR

# Instalar dependências Python no venv
echo "📦 Instalando dependências Python no venv..."
sudo $VENV_DIR/bin/pip install --upgrade pip
sudo $VENV_DIR/bin/pip install requests pyyaml

# Criar systemd service
echo "⚙️ Criando service..."
sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Cloudflare DDNS Updater
After=network.target

[Service]
Type=oneshot
ExecStart=$VENV_DIR/bin/python $INSTALL_DIR/ddns_updater.py
User=root
EOF

# Criar timer
echo "⏱ Criando timer..."
sudo tee $TIMER_FILE > /dev/null <<EOF
[Unit]
Description=Run DDNS Updater every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=ddns-updater.service

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
