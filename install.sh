#!/bin/bash

# install.sh
# Instalador para Cloudflare DDNS Updater
# Repositório: KAIKOAUGUSTIN/dnscript

set -e

# --- CONFIGURAÇÃO ---
# URL Base do seu repositório GitHub (Raw)
# Se o repositório for PRIVADO, adicione o token ao final: ?token=SEU_TOKEN
GITHUB_RAW_URL="https://raw.githubusercontent.com/KAIKOAUGUSTIN/dnscript/main"
# ---------------------

INSTALL_DIR="/opt/ddns-updater"
SERVICE_NAME="ddns-updater"
LOG_FILE="/var/log/ddns_updater.log"

echo "🚀 Iniciando instalação do Cloudflare DDNS Updater..."

# 1. Verificar curl
if ! command -v curl &> /dev/null; then
    echo "❌ curl não está instalado. Por favor instale primeiro."
    exit 1
fi

# 2. Verificar Python 3
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 não está instalado. Por favor instale primeiro."
    exit 1
fi

# 3. Criar Diretório
sudo mkdir -p $INSTALL_DIR
echo "📁 Diretório criado: $INSTALL_DIR"

# 4. Baixar Script Principal (ddns_updater.py)
echo "📥 Baixando ddns_updater.py..."
# Tenta baixar, se falhar (ex: token faltando), avisa
if ! sudo curl -sSL "$GITHUB_RAW_URL/ddns_updater.py" -o "$INSTALL_DIR/ddns_updater.py"; then
    echo "❌ Falha ao baixar ddns_updater.py. Verifique se o arquivo existe no GitHub ou se precisa de token."
    exit 1
fi
sudo chmod +x "$INSTALL_DIR/ddns_updater.py"

# 5. Baixar Configuração (config.yaml)
# Só baixa se não existir, para não sobrescrever suas credenciais
if [ ! -f "$INSTALL_DIR/config.yaml" ]; then
    echo "📥 Baixando config.yaml..."
    if ! sudo curl -sSL "$GITHUB_RAW_URL/config.yaml" -o "$INSTALL_DIR/config.yaml"; then
        echo "❌ Falha ao baixar config.yaml."
        exit 1
    fi
    echo "⚠️  IMPORTANTE: Edite $INSTALL_DIR/config.yaml com suas credenciais."
else
    echo "💾 config.yaml já existe. Pulando download para preservar credenciais."
fi

# 6. Definir Permissões (Segurança)
sudo chmod 700 $INSTALL_DIR
sudo chmod 600 $INSTALL_DIR/config.yaml
echo "🔒 Permissões seguradas."

# 7. Instalar Dependências Python
echo "📦 Instalando dependências Python..."
sudo pip3 install requests pyyaml

# 8. Criar Arquivo de Log
sudo touch $LOG_FILE
sudo chmod 644 $LOG_FILE

# 9. Criar Serviço Systemd
echo "⚙️ Configurando serviço Systemd..."
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

# 10. Criar Timer (Rodar a cada 5 minutos)
sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME.timer <<EOF
[Unit]
Description=Rodar DDNS Updater a cada 5 minutos
Requires=$SERVICE_NAME.service

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=$SERVICE_NAME.service

[Install]
WantedBy=timers.target
EOF"

# 11. Habilitar e Iniciar
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME.timer
sudo systemctl start $SERVICE_NAME.timer

echo "✅ Instalação Completa!"
echo "📝 Arquivo de config: $INSTALL_DIR/config.yaml"
echo "🔍 Ver status: sudo systemctl status $SERVICE_NAME.timer"
echo "📄 Ver logs: sudo journalctl -u $SERVICE_NAME.service"
