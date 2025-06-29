#!/bin/bash

# =============================================
# INSTALADOR AVANÇADO PARA BOT SSH
# Versão: 2.0
# Autor: Marcelo Pereira
# =============================================

# Configuração de cores
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
echo -e "${GREEN}"
echo "============================================="
echo " INSTALADOR AUTOMÁTICO PARA BOT SSH "
echo "============================================="
echo -e "${NC}"

# 1. Atualização do sistema
echo -e "${BLUE}🔄 Atualizando sistema e instalando dependências básicas...${NC}"
sudo apt update && sudo apt upgrade -y
check_error "Atualização do sistema"

sudo apt install -y \
  unzip \
  curl \
  git \
  build-essential \
  python3 \
  make \
  gcc \
  wget
check_error "Instalação de pacotes básicos"

# 2. Instalação do Node.js 20.x
echo -e "${BLUE}📦 Instalando Node.js 20.x...${NC}"
if ! command -v node &> /dev/null || [ $(node -v | cut -d'v' -f2 | cut -d'.' -f1) -lt 20 ]; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
  check_error "Instalação do Node.js"
else
  echo -e "${YELLOW}⚠️ Node.js $(node -v) já está instalado. Continuando...${NC}"
fi

# 3. Instalação do PM2
echo -e "${BLUE}🚀 Instalando PM2...${NC}"
if ! command -v pm2 &> /dev/null; then
  sudo npm install -g pm2
  check_error "Instalação do PM2"
else
  echo -e "${YELLOW}⚠️ PM2 já está instalado. Atualizando...${NC}"
  sudo npm update -g pm2
fi

# 4. Download e instalação do bot
echo -e "${BLUE}⬇️ Baixando e instalando o bot...${NC}"
mkdir -p ~/bot-ssh && cd ~/bot-ssh || check_error "Acesso ao diretório"

if [ -f "index.js" ]; then
  echo -e "${YELLOW}⚠️ Fazendo backup da instalação existente...${NC}"
  backup_dir="backup_$(date +%Y%m%d%H%M%S)"
  mkdir -p "$backup_dir"
  cp -r * "$backup_dir/"
fi

wget -q --show-progress https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip || check_error "Download do bot"
unzip -o bot.zip || check_error "Extração do arquivo"
rm -f bot.zip

# 5. Instalação de dependências ESSENCIAIS
echo -e "${BLUE}🔧 Instalando dependências críticas...${NC}"
npm install --save \
  dotenv@16.0.3 \
  node-telegram-bot-api@0.61.0 \
  ssh2@1.11.0 \
  fs-extra@11.2.0 \
  date-fns@2.30.0 \
  express@4.18.2 \
  es-to-primitive@1.2.1 \
  es-abstract@1.22.1 \
  array.prototype.findindex@1.2.1 \
  call-bind@1.0.2 \
  get-intrinsic@1.2.1
check_error "Instalação de dependências críticas"

# 6. Instalação de dependências adicionais
echo -e "${BLUE}🔧 Instalando dependências complementares...${NC}"
npm install --save \
  path \
  pm2 \
  lodash \
  node-ssh \
  ssh2-sftp-client \
  multer \
  node-cron \
  axios
check_error "Instalação de dependências complementares"

# 7. Configuração do ambiente
echo -e "${BLUE}⚙️ Configurando ambiente...${NC}"
mkdir -p data backups utils handlers
touch data/usuarios.json data/revendas.json

# 8. Configuração do Telegram
echo -e "${BLUE}📝 Configuração do Telegram:${NC}"
while true; do
  read -p "Digite o BOT_TOKEN do Telegram: " BOT_TOKEN
  if [[ $BOT_TOKEN =~ ^[0-9]+:[a-zA-Z0-9_-]+$ ]]; then
    break
  else
    echo -e "${RED}Formato inválido! Exemplo: 123456789:ABCdefGHIJKlmNoPQRsTUVwxyZ${NC}"
  fi
done

while true; do
  read -p "Digite o ADM_ID do Telegram: " ADM_ID
  if [[ $ADM_ID =~ ^[0-9]+$ ]]; then
    break
  else
    echo -e "${RED}O ADM_ID deve conter apenas números!${NC}"
  fi
done

# 9. Configuração do arquivo .env
echo -e "${BLUE}⚙️ Criando arquivo .env...${NC}"
cat > .env <<EOF
BOT_TOKEN=$BOT_TOKEN
ADM_ID=$ADM_ID
SERVER_HOST=seu_servidor_ssh
SERVER_USER=root
SERVER_PASSWORD=sua_senha_ssh
BACKUP_DIR=/root/bot-ssh/backups
DATA_DIR=/root/bot-ssh/data
EOF

echo -e "${YELLOW}⚠️ Por favor, edite o arquivo .env com as credenciais do servidor SSH${NC}"
echo -e "Comando para editar: nano ~/bot-ssh/.env"

# 10. Inicialização do bot
echo -e "${BLUE}🤖 Iniciando o bot...${NC}"
pm2 delete bot-ssh 2> /dev/null
pm2 start index.js --name "bot-ssh" || check_error "Inicialização do bot"

pm2 startup > /dev/null 2>&1
pm2 save --force

# Verificação final
if pm2 list | grep -q "bot-ssh"; then
  echo -e "${GREEN}"
  echo "============================================="
  echo " INSTALAÇÃO CONCLUÍDA COM SUCESSO! "
  echo "============================================="
  echo -e "${NC}"
  
  echo -e "${BLUE}📌 Comandos úteis:${NC}"
  echo -e "   pm2 logs bot-ssh         # Ver logs do bot"
  echo -e "   pm2 stop bot-ssh         # Parar o bot"
  echo -e "   pm2 restart bot-ssh      # Reiniciar o bot"
  echo -e "   pm2 monit                # Monitorar processos"
  
  echo -e "\n${YELLOW}⚠️ IMPORTANTE:${NC}"
  echo -e "1. Configure o arquivo .env com as credenciais do servidor SSH"
  echo -e "2. Verifique os logs para confirmar o funcionamento: pm2 logs bot-ssh"
else
  echo -e "${RED}❌ Falha ao iniciar o bot! Verifique os logs: pm2 logs bot-ssh${NC}"
  exit 1
fi
