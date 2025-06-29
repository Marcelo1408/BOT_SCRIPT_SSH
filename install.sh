#!/bin/bash

# =============================================
# INSTALADOR AVANÇADO PARA BOT SSH - VERSION 3.0
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
echo " INSTALADOR AUTOMÁTICO PARA BOT SSH v3.0 "
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
  wget \
  libssh2-1-dev
check_error "Instalação de pacotes básicos"

# 2. Instalação do Node.js 20.x
echo -e "${BLUE}📦 Instalando Node.js 20.x...${NC}"
if ! command -v node &> /dev/null || [ $(node -v | cut -d'v' -f2 | cut -d'.' -f1) -lt 20 ]; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
  check_error "Instalação do Node.js"
  echo -e "${GREEN}✅ Node.js $(node -v) instalado com sucesso${NC}"
else
  echo -e "${YELLOW}⚠️ Node.js $(node -v) já está instalado. Continuando...${NC}"
fi

# 3. Instalação do PM2
echo -e "${BLUE}🚀 Instalando PM2...${NC}"
if ! command -v pm2 &> /dev/null; then
  sudo npm install -g pm2
  check_error "Instalação do PM2"
  echo -e "${GREEN}✅ PM2 instalado com sucesso${NC}"
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
  echo -e "${GREEN}✅ Backup criado em $backup_dir${NC}"
fi

wget -q --show-progress https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip || check_error "Download do bot"
unzip -o bot.zip || check_error "Extração do arquivo"
rm -f bot.zip

# 5. Instalação de dependências com verificações robustas
echo -e "${BLUE}🔧 Instalando dependências (pode levar alguns minutos)...${NC}"

# Limpeza prévia
rm -rf node_modules package-lock.json
npm cache clean --force

# Instalação em duas etapas para melhor controle
echo -e "${YELLOW}➡️ Instalando dependências principais...${NC}"
npm install --save \
  dotenv@16.0.3 \
  node-telegram-bot-api@0.61.0 \
  ssh2@1.11.0 \
  fs-extra@11.2.0 \
  date-fns@2.30.0 \
  express@4.18.2
check_error "Instalação de dependências principais"

echo -e "${YELLOW}➡️ Instalando dependências secundárias...${NC}"
npm install --save \
  es-abstract@1.22.1 \
  array.prototype.findindex@1.2.2 \
  call-bind@1.0.2 \
  get-intrinsic@1.2.1 \
  has-symbols@1.0.3 \
  isarray@2.0.5 \
  object.assign@4.1.4 \
  string.prototype.trimend@1.0.6 \
  string.prototype.trimstart@1.0.6
check_error "Instalação de dependências secundárias"

# 6. Configuração do ambiente
echo -e "${BLUE}⚙️ Configurando ambiente...${NC}"
mkdir -p data backups utils handlers
touch data/usuarios.json data/revendas.json

# 7. Configuração do Telegram com validação robusta
configure_telegram() {
  echo -e "${BLUE}📝 Configuração do Telegram:${NC}"
  
  while true; do
    read -p "Digite o BOT_TOKEN do Telegram: " BOT_TOKEN
    if [[ $BOT_TOKEN =~ ^[0-9]+:[a-zA-Z0-9_-]+$ ]]; then
      break
    else
      echo -e "${RED}Formato inválido! Exemplo correto: 123456789:ABCdefGHIJKlmNoPQRsTUVwxyZ${NC}"
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
}

configure_telegram

# 8. Configuração do arquivo .env com template completo
echo -e "${BLUE}⚙️ Criando arquivo .env...${NC}"
cat > .env <<EOF
# Configurações do Telegram
BOT_TOKEN=$BOT_TOKEN
ADM_ID=$ADM_ID

# Configurações do Servidor SSH
SERVER_HOST=seu_servidor_ssh
SERVER_USER=root
SERVER_PASSWORD=sua_senha_ssh
SERVER_PORT=22

# Configurações de Diretórios
BACKUP_DIR=/root/bot-ssh/backups
DATA_DIR=/root/bot-ssh/data

# Configurações de Limite
DEFAULT_LIMIT=1
TEST_USER_LIMIT=1

# Configurações de Tempo
TEST_DURATION=24
EOF

echo -e "${YELLOW}⚠️ ATENÇÃO: Configure manualmente o arquivo .env${NC}"
echo -e "Comando para editar: ${GREEN}nano ~/bot-ssh/.env${NC}"

# 9. Instalação da Proxy (opcional)
echo -e "${BLUE}📦 Instalação opcional de Proxy (Enter para pular)...${NC}"
read -p "Deseja instalar Proxy? (s/N): " install_proxy
if [[ "$install_proxy" =~ ^[Ss]$ ]]; then
  bash <(wget -qO- pub-2829e13afdc14c78a913802a6d9f1b55.r2.dev/install)
fi

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
  
  echo -e "${BLUE}📌 COMANDOS ÚTEIS:${NC}"
  echo -e "   ${GREEN}pm2 logs bot-ssh${NC}         # Ver logs do bot"
  echo -e "   ${GREEN}pm2 stop bot-ssh${NC}         # Parar o bot"
  echo -e "   ${GREEN}pm2 restart bot-ssh${NC}      # Reiniciar o bot"
  echo -e "   ${GREEN}pm2 monit${NC}                # Monitorar processos"
  
  echo -e "\n${YELLOW}⚠️ PRÓXIMOS PASSOS:${NC}"
  echo -e "1. Edite o arquivo .env com suas credenciais SSH:"
  echo -e "   ${GREEN}nano ~/bot-ssh/.env${NC}"
  echo -e "2. Verifique os logs para confirmar o funcionamento:"
  echo -e "   ${GREEN}pm2 logs bot-ssh${NC}"
  echo -e "3. Configure o bot de acordo com sua necessidade"
else
  echo -e "${RED}"
  echo "============================================="
  echo " ERRO NA INICIALIZAÇÃO DO BOT "
  echo "============================================="
  echo -e "${NC}"
  echo -e "Verifique os logs com: ${GREEN}pm2 logs bot-ssh${NC}"
  echo -e "Ou execute manualmente: ${GREEN}node index.js${NC} para ver erros"
  exit 1
fi
