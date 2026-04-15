#!/bin/bash
set -e

# =============================================
# INSTALADOR TV BOX (CORRIGIDO - SEM TRAVAMENTO)
# =============================================

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

check_error() {
  if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro: $1${NC}"
    exit 1
  fi
}

echo -e "${GREEN}🚀 Instalando BOT TV BOX (modo estável)...${NC}"

# =============================================
# 1. CONFIGURAR APT MODO LEVE (DEFINITIVO)
# =============================================

echo -e "${BLUE}⚙️ Otimizando APT (sem travamento)...${NC}"

echo 'Acquire::IndexTargets::deb::Contents-deb::DefaultEnabled "false";' | sudo tee /etc/apt/apt.conf.d/99no-contents >/dev/null
echo 'Acquire::Languages "none";' | sudo tee /etc/apt/apt.conf.d/99no-lang >/dev/null
echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/99ipv4 >/dev/null

# =============================================
# 2. INSTALAR DEPENDÊNCIAS (SEM UPDATE!)
# =============================================

echo -e "${BLUE}📦 Instalando dependências essenciais...${NC}"

sudo apt install -y python3 python3-pip make gcc g++ wget unzip curl --no-install-recommends
check_error "Dependências"

# =============================================
# 3. VERIFICAR NODE
# =============================================

echo -e "${BLUE}🔎 Verificando Node.js...${NC}"

node -v >/dev/null 2>&1 || {
  echo -e "${RED}❌ Node.js não instalado!${NC}"
  exit 1
}

echo -e "${GREEN}✅ Node: $(node -v)${NC}"

# =============================================
# 4. INSTALAR PM2
# =============================================

echo -e "${BLUE}🚀 Instalando PM2...${NC}"

npm install -g pm2 --unsafe-perm
check_error "PM2"

# =============================================
# 5. BAIXAR BOT
# =============================================

echo -e "${BLUE}⬇️ Baixando BOT...${NC}"

rm -rf ~/bot
mkdir -p ~/bot && cd ~/bot

wget -q --show-progress https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip
check_error "Download"

unzip -o bot.zip
rm -f bot.zip

rm -rf node_modules package-lock.json

# =============================================
# 6. PACKAGE.JSON
# =============================================

echo -e "${BLUE}📄 Criando package.json...${NC}"

cat > package.json <<EOF
{
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
    "ssh2": "^1.11.0",
    "ssh2-sftp-client": "^12.0.1"
  }
}
EOF

# =============================================
# 7. INSTALAR DEPENDÊNCIAS NODE
# =============================================

echo -e "${BLUE}📦 Instalando dependências do bot...${NC}"

npm install --no-audit --no-fund --unsafe-perm
check_error "npm install"

# =============================================
# 8. INSTALAR PROXY
# =============================================

echo -e "${BLUE}🌐 Instalando proxy...${NC}"

sudo mkdir -p /opt/proxy

if bash <(curl -fsSL https://pub-15ffd77aec82486c9ff7293481878d90.r2.dev/install); then
  echo -e "${GREEN}✅ Proxy instalada${NC}"
else
  echo -e "${YELLOW}⚠️ Falha na proxy (possível incompatibilidade ARM)${NC}"
fi

# =============================================
# 9. CONFIG TELEGRAM
# =============================================

echo -e "${BLUE}📝 Configurando Telegram...${NC}"

read -p "BOT_TOKEN: " BOT_TOKEN
read -p "ADM_ID: " ADM_ID

cat > .env <<EOF
BOT_TOKEN=$BOT_TOKEN
ADM_ID=$ADM_ID
SERVER_HOST=123.123.123.23
SERVER_USER=user
SERVER_PASSWORD=senha
SERVER_PORT=22
SSH_TIMEOUT=20000
EOF

echo -e "${GREEN}✅ .env criado${NC}"

# =============================================
# 10. INICIAR BOT
# =============================================

echo -e "${BLUE}🤖 Iniciando bot...${NC}"

pm2 delete bot 2>/dev/null
pm2 start index.js --name bot

pm2 save
pm2 startup | tail -n 1 | bash

# =============================================
# FINAL
# =============================================

echo -e "${GREEN}"
echo "====================================="
echo "🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
echo "============================================="
echo -e "${NC}"
echo -e "${BLUE}📌 COMANDOS ÚTEIS:${NC}"
echo -e "   pm2 logs bot         → Ver logs do bot"
echo -e "   pm2 stop bot         → Parar o bot"
echo -e "   pm2 restart bot    → Reiniciar o bot"
echo -e "${YELLOW}\n⚠️ PRÓXIMO PASSO:${NC}"
echo -e "   Verifique se o bot está rodando:"
echo -e "   ${GREEN}pm2 list${NC}"
echo -e "   APÓS O ADD O SERVIDOR VOLTE AQUI NO TERMINAL E DIGITE ${GREEN}pm2 restart bot${NC} PARA REINICIAR O BOT"
echo -e "PARA ATIVAR AS POSTAS PARA FUNCIONAR SEU BOT SSH, DIGITE ${GREEN}proxymenu"
