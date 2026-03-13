# 🌐 Cloudflare DDNS Updater

![License](https://img.shields.io/badge/license-GPL3-blue.svg)
![Python](https://img.shields.io/badge/python-3.10%2B-blue)
![Platform](https://img.shields.io/badge/platform-Linux-success)
![Cloudflare](https://img.shields.io/badge/API-Cloudflare-orange)
![Systemd](https://img.shields.io/badge/service-systemd-lightgrey)
![Status](https://img.shields.io/badge/status-production-brightgreen)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=KAIKOAUGUSTIN_dnscript&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=KAIKOAUGUSTIN_dnscript)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=KAIKOAUGUSTIN_dnscript&metric=reliability_rating)](https://sonarcloud.io/summary/new_code?id=KAIKOAUGUSTIN_dnscript)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=KAIKOAUGUSTIN_dnscript&metric=vulnerabilities)](https://sonarcloud.io/summary/new_code?id=KAIKOAUGUSTIN_dnscript)

Atualizador dinâmico de DNS (DDNS) em Python para Cloudflare

---

## 🚀 Visão Geral

O Cloudflare DDNS Updater mantém seus registros DNS sincronizados com o IP público da sua rede. Ideal para home labs, VPS, infraestrutura self-hosted e ambientes de produção leve. O serviço roda em loop contínuo dentro de um processo Python e o `systemd` garante reinício automático em caso de crash.

---

## ✨ Funcionalidades

- 🔄 Detecção automática do IP público
- 🌐 Atualização inteligente de registros DNS
- 📱 Notificações por Telegram em alterações
- 🔒 Verificação opcional de `cloudflared` antes de atualizar
- 📝 Logs estruturados com nível configurável
- 🔁 Loop interno com intervalo configurável via `config.yaml`
- 🐍 Ambiente Python isolado (venv) criado pelo instalador
- 🧨 `uninstall.sh` baixado junto ao instalador (na pasta onde o instalador foi executado)

---

## 📦 Requisitos

- Sistema: Linux (Debian/Ubuntu/CentOS/etc.)
- Python 3.6+
- Permissões `sudo` para instalação e criação de serviço
- Token Cloudflare com permissões: `Zone:Read` e `DNS:Edit`
- (Opcional) Bot Telegram para notificações

---

## 📂 Estrutura do Projeto (instalação típica)

    /opt/ddns-updater/
    ├── ddns_updater.py
    ├── config.yaml
    ├── venv/
    └── (logs em /var/log/ddns_updater.log)

    /etc/systemd/system/
    └── ddns-updater.service

O `uninstall.sh` é baixado para a pasta em que você executou o `install.sh`.

---

## ⚙️ Instalação

1. Baixe o instalador e execute:

```bash
curl -sSL https://raw.githubusercontent.com/KAIKOAUGUSTIN/dnscript/main/install.sh -o install.sh
chmod +x install.sh
sudo ./install.sh
```

O instalador irá:
- Criar `/opt/ddns-updater`
- Baixar `ddns_updater.py` e `config.yaml` (se não existir)
- Criar `venv` e instalar dependências (`requests`, `PyYAML`)
- Criar e habilitar `systemd service` (modo loop + restart automático)
- Baixar `uninstall.sh` na pasta onde você executou o instalador

2. Edite as credenciais:

```bash
sudo nano /opt/ddns-updater/config.yaml
```

---

## 🛠 Exemplo de `config.yaml`

```yaml
settings:
  update_interval: 300        # segundos entre ciclos (ex: 300 = 5 minutos)
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

Observações:
- `update_interval` é em segundos; o script lê o `config.yaml` a cada ciclo (reload dinâmico).
- `use_cloudflared: true` fará o script checar se `systemctl is-active cloudflared` retorna `active` antes de atualizar esse registro.

---

## 🧪 Aplicando alterações

Executar manualmente (dentro do venv):

```bash
sudo systemctl restart ddns-updater.service
```

---

## 🔎 Monitoramento & Logs

Ver status do serviço:

```bash
sudo systemctl status ddns-updater.service
```

Logs em tempo real:

```bash
sudo journalctl -u ddns-updater.service -f
```

Ver arquivo de log:

```bash
sudo tail -n 200 /var/log/ddns_updater.log
```

---

## 🔄 Atualização do script

Para atualizar apenas o script:

```bash
sudo systemctl stop ddns-updater.service
sudo curl -sSL https://raw.githubusercontent.com/KAIKOAUGUSTIN/dnscript/main/ddns_updater.py -o /opt/ddns-updater/ddns_updater.py
sudo chmod +x /opt/ddns-updater/ddns_updater.py
sudo systemctl start ddns-updater.service
```

O `config.yaml` não será sobrescrito.

---

## 🧨 Desinstalação

O `uninstall.sh` vem junto ao instalador, execute o (na pasta onde ele foi salvo):

```bash
chmod +x ./uninstall.sh
sudo ./uninstall.sh
```

O `uninstall.sh` padrão:
- Para e desabilita o service
- Remove `/etc/systemd/system/ddns-updater.service`
- Remove `/opt/ddns-updater` (incluindo `venv`)
- Remove `/var/log/ddns_updater.log`
- Tenta remover globalmente `requests` e `PyYAML` via `pip3 uninstall -y` (se aplicável)
- Executa `systemctl daemon-reload`

O desinstalador pede confirmação antes de remover tudo.

---

## 🤝 Contribuindo

1. Fork no GitHub  
2. Crie uma branch de feature  
3. Commit suas mudanças  
4. Abra um Pull Request descrevendo a motivação  

---

## 📜 Licença

GPL License — veja arquivo `LICENSE` no repositório.

---

## 📞 Suporte

Abra uma Issue no repositório para reportar bugs ou solicitar melhorias.

---

Feito com ❤️ por KAIKOAUGUSTIN
