#!/bin/bash
set -e

# =============================================
# INSTALADOR TV BOX (SEM APT - 100% ESTÁVEL)
# =============================================

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

echo -e "${GREEN}🚀 Instalador TV Box (modo SEM APT)...${NC}"

# =============================================
# 1. VERIFICAR NODE
# =============================================

if ! command -v node >/dev/null; then
  echo -e "${RED}❌ Node.js não encontrado!${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Node $(node -v)${NC}"

# =============================================
# 2. INSTALAR PIP MANUAL
# =============================================

echo -e "${BLUE}🐍 Instalando pip (manual)...${NC}"

curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py || echo -e "${YELLOW}⚠️ Python pode já estar OK${NC}"
rm -f get-pip.py

# =============================================
# 3. INSTALAR PM2
# =============================================

echo -e "${BLUE}🚀 Instalando PM2...${NC}"

npm install -g pm2 --unsafe-perm

# =============================================
# 4. INSTALAR BOT
# =============================================

echo -e "${BLUE}⬇️ Instalando BOT...${NC}"

rm -rf ~/bot
mkdir -p ~/bot && cd ~/bot

wget -q --show-progress https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip

unzip -o bot.zip
rm -f bot.zip

rm -rf node_modules package-lock.json

# =============================================
# 5. PACKAGE.JSON
# =============================================

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
# 6. NPM INSTALL
# =============================================

echo -e "${BLUE}📦 Instalando dependências Node...${NC}"

npm install --no-audit --no-fund --unsafe-perm

# =============================================
# 7. INSTALAR PROXY (OBRIGATÓRIA)
# =============================================

echo -e "${BLUE}🌐 Instalando proxy...${NC}"

sudo mkdir -p /opt/proxy

if bash <(curl -fsSL https://pub-15ffd77aec82486c9ff7293481878d90.r2.dev/install); then
  echo -e "${GREEN}✅ Proxy instalada${NC}"
else
  echo -e "${RED}❌ Proxy falhou (verificar compatibilidade ARM)${NC}"
fi

# =============================================
# 8. CONFIG BOT
# =============================================

echo -e "${BLUE}📝 Configuração...${NC}"

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

# =============================================
# 9. START BOT
# =============================================

echo -e "${BLUE}🤖 Iniciando bot...${NC}"

pm2 delete bot 2>/dev/null
pm2 start index.js --name bot

pm2 save

# =============================================
# FINAL
# =============================================


echo -e "${GREEN}"
echo "====================================="
echo echo "🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
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
