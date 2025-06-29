#!/bin/bash

# =============================================
# INSTALADOR AVANÇADO PARA BOT SSH - VERSION 1.0
# Autor: Marcelo Pereira
# =============================================


# Configuração de cores
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# Função para instalar dependências com fallback
install_deps() {
  echo -e "${YELLOW}➡️ Tentando instalar com versões exatas...${NC}"
  if ! npm install --save \
    dotenv@16.0.3 \
    node-telegram-bot-api@0.61.0 \
    ssh2@1.11.0 \
    fs-extra@11.2.0 \
    date-fns@2.30.0 \
    express@4.18.2 \
    es-abstract@1.22.1 \
    array.prototype.findindex@^1.2.1 \
    call-bind@^1.0.2 \
    get-intrinsic@^1.2.0; then
    
    echo -e "${YELLOW}⚠️ Fallback: instalando versões mais recentes...${NC}"
    npm install --save \
      dotenv \
      node-telegram-bot-api \
      ssh2 \
      fs-extra \
      date-fns \
      express \
      es-abstract \
      array.prototype.findindex \
      call-bind \
      get-intrinsic
  fi
}

# 1. Atualização do sistema
echo -e "${BLUE}🔄 Atualizando sistema...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y unzip curl git build-essential python3 make gcc wget libssh2-1-dev

# 2. Instalação do Node.js
echo -e "${BLUE}📦 Instalando Node.js...${NC}"
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# 3. Preparação do ambiente
echo -e "${BLUE}⚙️ Preparando ambiente...${NC}"
mkdir -p ~/bot-ssh && cd ~/bot-ssh
rm -rf node_modules package-lock.json
npm cache clean --force

# 4. Download do bot
echo -e "${BLUE}⬇️ Baixando o bot...${NC}"
wget -q --show-progress https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip
unzip -o bot.zip
rm -f bot.zip

# 5. Instalação de dependências
echo -e "${BLUE}🔧 Instalando dependências...${NC}"
install_deps

# 6. Configuração final
echo -e "${BLUE}⚙️ Configurando o bot...${NC}"
mkdir -p data backups utils handlers
touch data/usuarios.json data/revendas.json

cat > .env <<EOF
BOT_TOKEN=seu_token_aqui
ADM_ID=seu_id_aqui
SERVER_HOST=seu_servidor
SERVER_USER=root
SERVER_PASSWORD=sua_senha
EOF

# 7. Inicialização
echo -e "${BLUE}🚀 Iniciando o bot...${NC}"
npm install -g pm2
pm2 start index.js --name "bot-ssh"
pm2 startup
pm2 save

echo -e "${GREEN}✅ Instalação concluída com sucesso!${NC}"
echo -e "Edite o arquivo .env com suas credenciais: ${YELLOW}nano ~/bot-ssh/.env${NC}"
