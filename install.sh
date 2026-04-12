#!/bin/bash

# =============================================
# INSTALADOR AUTOMÁTICO PARA BOT SSH (ARM 32)
# Autor: Marcelo Pereira (adaptado para RK322x)
# Versão: 2.1 - ARMhf
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

echo -e "${GREEN}✅ Iniciando instalação automática para ARM 32...${NC}"

# Dependências básicas (inclui compiladores para módulos nativos)
sudo apt update
sudo apt install -y unzip curl git build-essential python3 make gcc wget libssh2-1-dev
check_error "Dependências básicas"

# Instalar nvm (funciona perfeitamente em armhf)
echo -e "${BLUE}📦 Instalando nvm...${NC}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
check_error "nvm"

# Carregar nvm manualmente no script (source ~/.bashrc não funciona aqui)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
check_error "Carregar nvm"

# Instalar a versão LTS do Node.js
echo -e "${BLUE}📦 Instalando Node.js LTS via nvm...${NC}"
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'
check_error "Node.js"

# Verificar versões
node --version
npm --version

# Instalar PM2 globalmente (com permissão para armhf)
echo -e "${BLUE}🚀 Instalando PM2...${NC}"
npm install -g pm2 --unsafe-perm
check_error "PM2"

# Baixar Bot SSH
echo -e "${BLUE}⬇️ Baixando o Bot SSH...${NC}"
mkdir -p ~/bot && cd ~/bot || check_error "Diretório"

wget -q --show-progress https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip
check_error "Download do Bot"

unzip -o bot.zip
rm -f bot.zip
check_error "Extração"

# Limpar dependências antigas
rm -rf node_modules package-lock.json

# Criar package.json correto
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
    "pm2": "^6.0.8",
    "ssh2": "^1.11.0",
    "ssh2-sftp-client": "^12.0.1"
  }
}
EOF

# Instalar dependências (compilação dos módulos nativos em armhf)
echo -e "${BLUE}📦 Instalando dependências (pode levar alguns minutos)...${NC}"
npm install
check_error "Instalação de dependências"

# Instalação da proxy opcional (com adaptação para armhf)
echo -e "${BLUE}📝 Instalar proxy agora? (s/N):${NC}"
read -p " " install_proxy
if [[ "$install_proxy" =~ ^[Ss]$ ]]; then
  echo -e "${YELLOW}⚠️ O script de proxy original pode não ter suporte a ARM 32. Tentando mesmo assim...${NC}"
  sudo apt install -y wget
  rm -fr /opt/proxy && bash <(curl -sL https://pub-15ffd77aec82486c9ff7293481878d90.r2.dev/install) || echo -e "${RED}❌ Falha na instalação do proxy (arquitetura não suportada). Ignorando...${NC}"
fi

# Configuração do Telegram
echo -e "${BLUE}📝 Configuração do Telegram:${NC}"
read -p "Digite o BOT_TOKEN do Telegram: " BOT_TOKEN
read -p "Digite o ADM_ID do Telegram: " ADM_ID

# Criar .env
echo -e "${BLUE}📄 Criando arquivo .env...${NC}"
cat > .env <<EOF
BOT_TOKEN=$BOT_TOKEN
ADM_ID=$ADM_ID
SERVER_HOST=123.123.123.23
SERVER_USER=user
SERVER_PASSWORD='senha'
SERVER_PORT=00
SSH_TIMEOUT=20000
EOF

echo -e "${GREEN}✅ .env criado no formato correto.${NC}"

# Iniciar o Bot com PM2
echo -e "${BLUE}🤖 Iniciando o Bot com PM2...${NC}"
pm2 delete bot 2>/dev/null
pm2 start index.js --name "bot"
pm2 startup && pm2 save

# Finalização
echo -e "${GREEN}"
echo "============================================="
echo "🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
echo "============================================="
echo -e "${NC}"
echo -e "${BLUE}📌 COMANDOS ÚTEIS:${NC}"
echo -e "   pm2 logs bot         → Ver logs do bot"
echo -e "   pm2 stop bot         → Parar o bot"
echo -e "   pm2 restart bot      → Reiniciar o bot"
echo -e "${YELLOW}\n⚠️ PRÓXIMO PASSO:${NC}"
echo -e "   Verifique se o bot está rodando: ${GREEN}pm2 list${NC}"
echo -e "   Após adicionar o servidor, execute: ${GREEN}pm2 restart bot${NC}"
echo -e "   Para ativar as funções do bot SSH, digite: ${GREEN}proxymenu${NC} (se instalado)"# Instalar a versão LTS mais recente (ou uma específica)
nvm install --lts

# Verificar
node --version
npm --version

# Definir como padrão
nvm alias default 'lts/*'

# PM2
echo -e "${BLUE}🚀 Instalando PM2...${NC}"
sudo npm install -g pm2
check_error "PM2"

# Baixar Bot
echo -e "${BLUE}⬇️ Baixando o Bot SSH...${NC}"
mkdir -p ~/bot && cd ~/bot || check_error "Diretório"

wget -q --show-progress https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip
check_error "Download do Bot"

unzip -o bot.zip
rm -f bot.zip
check_error "Extração"

# Limpar dependências antigas
rm -rf node_modules package-lock.json

# Criar package.json correto
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
    "pm2": "^6.0.8",
    "ssh2": "^1.11.0",
    "ssh2-sftp-client": "^12.0.1"
  }
}
EOF

# Instalar dependências certas
echo -e "${BLUE}📦 Instalando dependências...${NC}"
npm install
check_error "Instalação de dependências"

# Instalação da proxy opcional
echo -e "${BLUE}📝 Instalar proxy agora? (s/N):${NC}"
read -p " " install_proxy
if [[ "$install_proxy" =~ ^[Ss]$ ]]; then
  sudo apt install -y wget
  rm -fr /opt/proxy && bash <(curl -sL https://pub-15ffd77aec82486c9ff7293481878d90.r2.dev/install)
fi

# Pegar TOKEN e ADM_ID
echo -e "${BLUE}📝 Configuração do Telegram:${NC}"
read -p "Digite o BOT_TOKEN do Telegram: " BOT_TOKEN
read -p "Digite o ADM_ID do Telegram: " ADM_ID

# Criar .env com seu padrão fixo
echo -e "${BLUE}📄 Criando arquivo .env...${NC}"
cat > .env <<EOF
BOT_TOKEN=$BOT_TOKEN
ADM_ID=$ADM_ID
SERVER_HOST=123.123.123.23
SERVER_USER=user
SERVER_PASSWORD='senha'
SERVER_PORT=00
SSH_TIMEOUT=20000
EOF

echo -e "${GREEN}✅ .env criado no formato correto.${NC}"

# Iniciar o Bot com PM2
echo -e "${BLUE}🤖 Iniciando o Bot com PM2...${NC}"
pm2 delete bot 2>/dev/null
pm2 start index.js --name "bot"
pm2 startup && pm2 save
  
# Finalização
echo -e "${GREEN}"
echo "============================================="
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
