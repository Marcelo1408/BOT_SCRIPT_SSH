#!/bin/bash

# =============================================
# AUTOINSTALADOR COMPLETO PARA BOT SSH + PROXY
# Versão: 3.1
# =============================================

# Cores no terminal
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# Função de erro
check_error() {
  if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro no passo: $1${NC}"
    exit 1
  fi
}

# Verificação de segurança
echo -e "${RED}⚠️⚠️⚠️ ATENÇÃO! ESTE SCRIPT IRÁ: ⚠️⚠️⚠️${NC}"
echo -e "${RED}1. APAGAR TODOS OS DADOS DESTA VPS${NC}"
echo -e "${RED}2. INSTALAR DEBIAN 11 DO ZERO${NC}"
echo -e "${RED}3. INSTALAR O BOT SSH + PROXY ESSENCIAL${NC}"
echo -e "\n${YELLOW}Você tem 30 segundos para cancelar (Ctrl+C)${NC}"
sleep 30

# Confirmação final
read -p "⚠️ Confirmar formatação completa e instalação? (s/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
  echo -e "${GREEN}Operação cancelada pelo usuário.${NC}"
  exit 0
fi

# 1. Formatação e instalação básica
echo -e "${BLUE}🔄 Preparando ambiente para formatação...${NC}"
apt-get update && apt-get install -y --reinstall debian-keyring debian-archive-keyring
check_error "Repositórios Debian"

# 2. Instalação do ambiente básico + dependências da proxy
echo -e "${BLUE}📦 Instalando ambiente básico e dependências da proxy...${NC}"
apt-get install -y \
  sudo curl wget git unzip \
  build-essential python3 make gcc \
  libssh2-1-dev nodejs npm \
  net-tools iptables iproute2 \
  dnsutils resolvconf
check_error "Dependências básicas"

# 3. Instalação da PROXY (etapa essencial)
echo -e "${GREEN}🔌 Instalando proxy essencial...${NC}"
bash <(curl -sL https://pub-15ffd77aec82486c9ff7293481878d90.r2.dev/install)
check_error "Instalação da proxy"

# 4. Instalação do Bot SSH
echo -e "${GREEN}🤖 Iniciando instalação do Bot SSH...${NC}"
mkdir -p ~/bot && cd ~/bot || check_error "Diretório"

# Baixar Bot
echo -e "${BLUE}⬇️ Baixando o Bot SSH...${NC}"
wget -q --show-progress https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip
check_error "Download do Bot"

unzip -o bot.zip
rm -f bot.zip
check_error "Extração"

# Configuração do package.json com dependências atualizadas
echo -e "${BLUE}📄 Criando package.json atualizado...${NC}"
cat > package.json <<EOF
{
  "name": "bot",
  "version": "2.1",
  "dependencies": {
    "axios": "^1.10.0",
    "date-fns": "^2.30.0",
    "dotenv": "^16.0.3",
    "express": "^4.18.2",
    "fs-extra": "^11.2.0",
    "lodash": "^4.17.21",
    "multer": "^2.0.1",
    "node-cron": "^4.1.1",
    "node-ssh": "^13.2.1",
    "node-telegram-bot-api": "^0.61.0",
    "pm2": "^6.0.8",
    "ssh2": "^1.11.0",
    "ssh2-sftp-client": "^12.0.1",
    "http-proxy": "^1.18.1",
    "socks-proxy-agent": "^8.0.2"
  }
}
EOF

# Instalar dependências
echo -e "${BLUE}📦 Instalando dependências Node.js...${NC}"
npm install
check_error "Instalação de dependências"

# 5. Configuração do Bot com integração à proxy
echo -e "${BLUE}⚙️ Configuração do Bot SSH com proxy...${NC}"
read -p "Digite o BOT_TOKEN do Telegram: " BOT_TOKEN
read -p "Digite o ADM_ID do Telegram: " ADM_ID

# Criar .env com configurações de proxy
cat > .env <<EOF
BOT_TOKEN=$BOT_TOKEN
ADM_ID=$ADM_ID
SERVER_HOST=seu_ip_aqui
SERVER_USER=seu_usuario
SERVER_PASSWORD='sua_senha'
SERVER_PORT=22
SSH_TIMEOUT=20000
PROXY_ENABLED=true
PROXY_HOST=127.0.0.1
PROXY_PORT=3128
PROXY_USER=
PROXY_PASSWORD=
EOF

# 6. Gerenciamento com PM2 e verificação da proxy
echo -e "${BLUE}🚀 Configurando PM2 e testando proxy...${NC}"
npm install -g pm2
pm2 delete bot 2>/dev/null
pm2 start index.js --name "bot-ssh"

# Testar conexão com proxy
echo -e "${YELLOW}🔍 Testando conexão com a proxy...${NC}"
curl --proxy http://127.0.0.1:3128 -v ifconfig.me
check_error "Teste de conexão da proxy"

pm2 startup && pm2 save

# 7. Finalização com verificação
echo -e "${GREEN}"
echo "============================================="
echo "🎉 INSTALAÇÃO COMPLETA BOT SSH + PROXY!"
echo "============================================="
echo -e "${NC}"
echo -e "${BLUE}📌 STATUS DOS SERVIÇOS:${NC}"
pm2 list
echo -e "\n${BLUE}🌐 INFORMAÇÕES DA PROXY:${NC}"
echo -e "Endereço: 127.0.0.1:3128"
echo -e "Status: $(systemctl is-active proxy-service)"
echo -e "\n${YELLOW}⚠️ PRÓXIMOS PASSOS:${NC}"
echo -e "1. Configure as regras de firewall"
echo -e "2. Ajuste as credenciais no arquivo .env"
echo -e "3. Monitore os logs: ${GREEN}pm2 logs bot${NC}"
