#!/bin/bash

# =============================================
# INSTALADOR TV BOX (ARMhf - RK322x)
# Versão leve (sem apt pesado / sem nvm)
# =============================================

# Cores
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

echo -e "${GREEN}🚀 Instalando BOT na TV BOX (modo leve)...${NC}"

# =============================================
# 1. Verificar Node.js
# =============================================

echo -e "${BLUE}🔎 Verificando Node.js...${NC}"

node -v >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Node.js não encontrado! Instale manualmente primeiro.${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Node encontrado: $(node -v)${NC}"

# =============================================
# 2. Instalar PM2
# =============================================

echo -e "${BLUE}🚀 Instalando PM2...${NC}"
npm install -g pm2 --unsafe-perm
check_error "PM2"

# =============================================
# 3. Baixar BOT
# =============================================

echo -e "${BLUE}⬇️ Baixando o Bot...${NC}"

mkdir -p ~/bot
cd ~/bot || exit

wget -q --show-progress https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip
check_error "Download"

unzip -o bot.zip
rm -f bot.zip

# =============================================
# 4. Limpar dependências antigas
# =============================================

rm -rf node_modules package-lock.json

# =============================================
# 5. Criar package.json leve
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
# 6. Instalar dependências
# =============================================

echo -e "${BLUE}📦 Instalando dependências (leve)...${NC}"
npm install --no-audit --no-fund --unsafe-perm
check_error "Dependências"

# =============================================
# 7. Configuração Telegram
# =============================================

echo -e "${BLUE}📝 Configuração do Telegram:${NC}"

read -p "BOT_TOKEN: " BOT_TOKEN
read -p "ADM_ID: " ADM_ID

# Criar .env
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
# 8. Iniciar com PM2
# =============================================

echo -e "${BLUE}🤖 Iniciando BOT...${NC}"

pm2 delete bot 2>/dev/null
pm2 start index.js --name bot

pm2 save

# Startup automático
pm2 startup | tail -n 1 | bash

# =============================================
# FINAL
# =============================================

echo -e "${GREEN}"
echo "====================================="
echo "🎉 INSTALAÇÃO FINALIZADA!"
echo "====================================="
echo -e "${NC}"

echo -e "${BLUE}📌 COMANDOS:${NC}"
echo "pm2 list"
echo "pm2 logs bot"
echo "pm2 restart bot"
