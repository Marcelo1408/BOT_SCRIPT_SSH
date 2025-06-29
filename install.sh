#!/bin/bash

# =============================================
# INSTALADOR AVANÇADO PARA BOT SSH - VERSION 1.0
# Autor: Marcelo Pereira
# =============================================

# Cores para melhor visualização
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# Função para verificar erros
check_error() {
  if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro no passo: $1${NC}"
    echo -e "${YELLOW}⚠️ Execute manualmente o comando que falhou para ver detalhes${NC}"
    exit 1
  fi
}

# Cabeçalho
echo -e "${GREEN}✅ Iniciando instalação automática...${NC}"

# 1. Atualizar sistema e instalar dependências
echo -e "${BLUE}🔄 Atualizando sistema e instalando dependências...${NC}"
sudo apt update && sudo apt upgrade -y
check_error "Atualização do sistema"

sudo apt install -y unzip curl git build-essential python3 make gcc wget libssh2-1-dev
check_error "Instalação de dependências básicas"

# 2. Instalar Node.js 20.x
echo -e "${BLUE}📦 Instalando Node.js 20.x...${NC}"
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
check_error "Configuração do repositório Node.js"

sudo apt install -y nodejs
check_error "Instalação do Node.js"

# 3. Instalar PM2 globalmente
echo -e "${BLUE}🚀 Instalando PM2...${NC}"
sudo npm install -g pm2
check_error "Instalação do PM2"

# 4. Baixar e extrair o bot
echo -e "${BLUE}⬇️ Baixando e instalando o bot...${NC}"
mkdir -p ~/bot-ssh && cd ~/bot-ssh || check_error "Acesso ao diretório"

wget -q --show-progress https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip
check_error "Download do bot"

unzip -o bot.zip || check_error "Extração do arquivo"
rm -f bot.zip

# 5. Instalar dependências do Node.js (com tratamento de erros)
echo -e "${BLUE}🔧 Instalando dependências do projeto...${NC}"
npm install --save \
  dotenv@16.0.3 \
  node-telegram-bot-api@0.61.0 \
  ssh2@1.11.0 \
  fs-extra@11.2.0 \
  path \
  pm2 \
  date-fns@2.30.0 \
  lodash \
  node-ssh \
  ssh2-sftp-client \
  express@4.18.2 \
  multer \
  node-cron \
  axios \
  es-abstract@1.22.1 \
  array.prototype.findindex@^1.2.1 \
  call-bind@^1.0.2 \
  get-intrinsic@^1.2.0
check_error "Instalação de dependências"

# 6. Instalação da Proxy (opcional)
echo -e "${BLUE}📝 Instalação de Proxy:${NC}"
read -p "Deseja instalar Proxy? (s/N): " install_proxy
if [[ "$install_proxy" =~ ^[Ss]$ ]]; then
  sudo apt install -y wget
  bash <(wget -qO- pub-2829e13afdc14c78a913802a6d9f1b55.r2.dev/install)
fi

# 7. Solicitar BOT_TOKEN e ADM_ID (mantido igual ao original)
echo -e "${BLUE}📝 Configuração do Telegram:${NC}"
read -p "Digite o BOT_TOKEN do Telegram: " BOT_TOKEN
read -p "Digite o ADM_ID do Telegram: " ADM_ID

# 8. Atualizar .env (mantido igual ao original)
if [ -f ~/bot-ssh/.env ]; then
    sed -i "s|BOT_TOKEN=.*|BOT_TOKEN=$BOT_TOKEN|g" ~/bot-ssh/.env
    sed -i "s|ADM_ID=.*|ADM_ID=$ADM_ID|g" ~/bot-ssh/.env
    echo -e "${GREEN}✅ .env atualizado com sucesso!${NC}"
else
    echo -e "${YELLOW}⚠️ Criando arquivo .env...${NC}"
    cat > ~/bot-ssh/.env <<EOF
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
pm2 delete index 2> /dev/null
pm2 start index.js --name "bot-ssh" || check_error "Inicialização do bot"
pm2 startup && pm2 save

# Resultado final
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
echo -e "1. Edite o arquivo .env completo:"
echo -e "   ${GREEN}nano ~/bot-ssh/.env${NC}"
echo -e "2. Verifique se o bot está rodando:"
echo -e "   ${GREEN}pm2 list${NC}"
