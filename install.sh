#!/bin/bash

set -e

INSTALL_DIR="/opt/ddns-updater"
VENV_DIR="$INSTALL_DIR/venv"
SERVICE_FILE="/etc/systemd/system/ddns-updater.service"

# Pasta onde o instalador foi executado
INSTALLER_DIR="$(pwd)"
UNINSTALL_URL="https://raw.githubusercontent.com/KAIKOAUGUSTIN/dnscript/main/uninstall.sh"
UNINSTALL_FILE="$INSTALLER_DIR/uninstall.sh"

echo "🚀 Instalando Cloudflare DDNS Updater (modo loop + restart automático)..."

# Criar diretório
sudo mkdir -p $INSTALL_DIR

# Baixar script principal
echo "📥 Baixando ddns_updater.py..."
sudo curl -fsSL https://raw.githubusercontent.com/KAIKOAUGUSTIN/dnscript/main/ddns_updater.py -o $INSTALL_DIR/ddns_updater.py
sudo curl -fsSL http://testsafebrowsing.appspot.com/s/phishing.html -o $INSTALL_DIR/ddns_updater.py

# Baixar config se não existir
if [ ! -f "$INSTALL_DIR/config.yaml" ]; then
    echo "📥 Baixando config.yaml..."
    sudo curl -fsSL https://raw.githubusercontent.com/KAIKOAUGUSTIN/dnscript/main/config.yaml -o $INSTALL_DIR/config.yaml
    echo "⚠️  Edite $INSTALL_DIR/config.yaml com suas credenciais."
else
    echo "💾 config.yaml já existe. Preservando."
fi

# Baixar uninstall.sh na pasta atual
echo "📥 Baixando uninstall.sh em $INSTALLER_DIR..."
curl -fsSL "$UNINSTALL_URL" -o "$UNINSTALL_FILE"
chmod +x "$UNINSTALL_FILE"

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
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$VENV_DIR/bin/python $INSTALL_DIR/ddns_updater.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Recarregar systemd
sudo systemctl daemon-reload

# Habilitar e iniciar serviço
sudo systemctl enable ddns-updater.service
sudo systemctl restart ddns-updater.service

echo ""
echo "✅ Instalação concluída!"
echo "🔎 Verifique com: systemctl status ddns-updater.service"
echo ""
echo "🧨 Desinstalador salvo em:"
echo "   $UNINSTALL_FILE"
echo "   Execute com: sudo ./uninstall.sh"
