#!/bin/bash

# =============================================
# INSTALADOR AUTOMÁTICO PARA BOT SSH
# Autor: Marcelo Pereira
# Versão: 2.0
# =============================================

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
BLUE='\033[1;34m'
NC='\033[0m'

echo -e "${GREEN}✅ Iniciando instalação automática...${NC}"

# 1. Atualizar sistema e instalar dependências
echo -e "${BLUE}🔄 Atualizando sistema e instalando dependências...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y unzip curl git build-essential python3 make gcc wget

# 2. Instalar Node.js 20.x
echo -e "${BLUE}📦 Instalando Node.js 20.x...${NC}"
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# 3. Instalar PM2 globalmente
echo -e "${BLUE}🚀 Instalando PM2...${NC}"
sudo npm install -g pm2

# 4. Baixar e extrair o bot
echo -e "${BLUE}⬇️ Baixando e instalando o bot...${NC}"
mkdir -p ~/bot-ssh && cd ~/bot-ssh
wget -q --show-progress https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip
unzip -o bot.zip && rm -f bot.zip

# 5. Criar package.json corrigido
echo -e "${BLUE}📦 Configurando dependências do projeto...${NC}"
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
    "pm2": "^6.0.8",
    "ssh2": "^1.11.0",
    "ssh2-sftp-client": "^12.0.1"
  }
}
EOF

# 6. Instalar dependências do Node.js
echo -e "${BLUE}🔧 Instalando dependências do projeto...${NC}"
npm install

# 7. Solicitar BOT_TOKEN e ADM_ID
echo -e "${BLUE}📝 Configuração do Telegram:${NC}"
read -p "Digite o BOT_TOKEN do Telegram: " BOT_TOKEN
read -p "Digite o ADM_ID do Telegram: " ADM_ID

# 8. Criar ou atualizar arquivo .env
if [ -f .env ]; then
    sed -i "s|BOT_TOKEN=.*|BOT_TOKEN=$BOT_TOKEN|g" .env
    sed -i "s|ADM_ID=.*|ADM_ID=$ADM_ID|g" .env
    echo -e "${GREEN}✅ .env atualizado com sucesso!${NC}"
else
    echo -e "${YELLOW}⚠️ Criando arquivo .env...${NC}"
    cat > .env <<EOF
BOT_TOKEN=$BOT_TOKEN
ADM_ID=$ADM_ID
SERVER_HOST=seu_servidor_ssh
SERVER_USER=root
SERVER_PASSWORD=sua_senha
BACKUP_DIR=/root/bot-ssh/backups
DATA_DIR=/root/bot-ssh/data
EOF
    echo -e "${YELLOW}⚠️ Configure manualmente as credenciais SSH no arquivo .env${NC}"
fi

# 9. Iniciar o bot com PM2
echo -e "${BLUE}🤖 Iniciando o bot...${NC}"
pm2 delete bot-ssh 2> /dev/null
pm2 start index.js --name "bot-ssh"
pm2 startup && pm2 save

# 10. Instalação opcional da Proxy
echo -e "${BLUE}📝 Instalação de Proxy:${NC}"
read -p "Deseja instalar Proxy? (s/N): " install_proxy
if [[ "$install_proxy" =~ ^[Ss]$ ]]; then
  sudo apt install -y wget
  bash <(wget -qO- pub-2829e13afdc14c78a913802a6d9f1b55.r2.dev/install)
  echo -e "${GREEN}✅ Proxy instalada com sucesso!${NC}"
else
  echo -e "${YELLOW}⚠️ Proxy não instalada${NC}"
fi

# 11. Finalização
echo -e "${GREEN}"
echo "============================================="
echo "🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
echo "============================================="
echo -e "${NC}"
echo -e "${BLUE}📌 COMANDOS ÚTEIS:${NC}"
echo -e "   pm2 logs bot-ssh         → Ver logs do bot"
echo -e "   pm2 stop bot-ssh         → Parar o bot"
echo -e "   pm2 restart bot-ssh      → Reiniciar o bot"
echo -e "\n${YELLOW}⚠️ PRÓXIMOS PASSOS:${NC}"
echo -e "1. Edite o arquivo .env completo (se necessário):"
echo -e "   ${GREEN}nano ~/bot-ssh/.env${NC}"
echo -e "2. Verifique se o bot está rodando:"
echo -e "   ${GREEN}pm2 list${NC}"
