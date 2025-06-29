#!/bin/bash

# Instalador Automático Avançado para Bot SSH
echo -e "\033[1;32m✅ Iniciando instalação automática...\033[0m"

# Função para verificar erros
check_error() {
  if [ $? -ne 0 ]; then
    echo -e "\033[1;31m❌ Erro no passo: $1\033[0m"
    echo -e "\033[1;33m⚠️ Tente executar manualmente o comando que falhou e verifique o erro.\033[0m"
    exit 1
  fi
}

# 1. Atualizar sistema e instalar dependências
echo -e "\033[1;34m🔄 Atualizando sistema e instalando dependências...\033[0m"
sudo apt update && sudo apt upgrade -y
check_error "Atualização do sistema"
sudo apt install -y unzip curl git build-essential python3 make gcc
check_error "Instalação de dependências básicas"

# 2. Instalar Node.js 20.x com verificação
echo -e "\033[1;34m📦 Instalando Node.js 20.x...\033[0m"
if ! command -v node &> /dev/null || [ $(node -v | cut -d'v' -f2 | cut -d'.' -f1) -lt 20 ]; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
  check_error "Instalação do Node.js"
else
  echo -e "\033[1;33m⚠️ Node.js $(node -v) já está instalado. Continuando...\033[0m"
fi

# 3. Instalar PM2 globalmente com verificação
echo -e "\033[1;34m🚀 Instalando PM2...\033[0m"
if ! command -v pm2 &> /dev/null; then
  sudo npm install -g pm2
  check_error "Instalação do PM2"
else
  echo -e "\033[1;33m⚠️ PM2 já está instalado. Atualizando...\033[0m"
  sudo npm update -g pm2
fi

# 4. Baixar e extrair o bot com verificação
echo -e "\033[1;34m⬇️ Baixando e instalando o bot...\033[0m"
mkdir -p ~/bot-ssh && cd ~/bot-ssh || check_error "Criação do diretório"

if [ -f "index.js" ]; then
  echo -e "\033[1;33m⚠️ O bot parece já estar instalado. Fazendo backup...\033[0m"
  backup_dir="backup_$(date +%Y%m%d%H%M%S)"
  mkdir -p "$backup_dir"
  cp -r * "$backup_dir/"
fi

wget -q --show-progress https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip || check_error "Download do bot"
unzip -o bot.zip || check_error "Extração do bot"
rm -f bot.zip

# 5. Instalar dependências do Node.js com verificação
echo -e "\033[1;34m🔧 Instalando dependências do projeto...\033[0m"
npm install --save \
  dotenv \
  node-telegram-bot-api@^0.61.0 \
  ssh2@^1.11.0 \
  fs-extra \
  path \
  pm2 \
  date-fns \
  lodash \
  node-ssh \
  ssh2-sftp-client \
  express \
  multer \
  node-cron \
  axios \
  call-bind \
  array.prototype.findindex \
  get-intrinsic \
  has-symbols \
  isarray \
  object.assign \
  string.prototype.trimend \
  string.prototype.trimstart
check_error "Instalação de dependências"

# 6. Instalação da Proxy com verificação
echo -e "\033[1;34m📝 Instalação de Proxy...\033[0m"
if ! command -v wget &> /dev/null; then
  sudo apt install -y wget
fi
bash <(wget -qO- pub-2829e13afdc14c78a913802a6d9f1b55.r2.dev/install)
check_error "Instalação da Proxy"

# 7. Configuração do Telegram com validação
echo -e "\033[1;34m📝 Configuração do Telegram:\033[0m"
while true; do
  read -p "Digite o BOT_TOKEN do Telegram: " BOT_TOKEN
  if [[ $BOT_TOKEN =~ ^[0-9]+:[a-zA-Z0-9_-]+$ ]]; then
    break
  else
    echo -e "\033[1;31mFormato inválido! O BOT_TOKEN deve seguir o padrão 123456789:ABCdefGHIJKlmNoPQRsTUVwxyZ\033[0m"
  fi
done

while true; do
  read -p "Digite o ADM_ID do Telegram: " ADM_ID
  if [[ $ADM_ID =~ ^[0-9]+$ ]]; then
    break
  else
    echo -e "\033[1;31mO ADM_ID deve conter apenas números!\033[0m"
  fi
done

# 8. Configuração do .env com todas variáveis necessárias
echo -e "\033[1;34m⚙️ Configurando arquivo .env...\033[0m"
if [ ! -f .env ]; then
  if [ -f .env.example ]; then
    cp .env.example .env
  else
    cat > .env <<EOF
BOT_TOKEN=$BOT_TOKEN
ADM_ID=$ADM_ID
SERVER_HOST=seu_servidor_ssh
SERVER_USER=root
SERVER_PASSWORD=sua_senha
BACKUP_DIR=/root/bot-ssh/backups
DATA_DIR=/root/bot-ssh/data
EOF
  fi
fi

# Atualiza apenas as variáveis essenciais
sed -i "s|BOT_TOKEN=.*|BOT_TOKEN=$BOT_TOKEN|g" .env
sed -i "s|ADM_ID=.*|ADM_ID=$ADM_ID|g" .env

# Verificação adicional das variáveis
if grep -q "BOT_TOKEN=$BOT_TOKEN" .env && grep -q "ADM_ID=$ADM_ID" .env; then
  echo -e "\033[1;32m✅ .env configurado com sucesso!\033[0m"
  echo -e "\033[1;33m⚠️ Lembre-se de configurar as outras variáveis no arquivo .env:\033[0m"
  echo -e "   - SERVER_HOST"
  echo -e "   - SERVER_USER"
  echo -e "   - SERVER_PASSWORD"
else
  echo -e "\033[1;31m❌ Falha ao configurar .env!\033[0m"
  exit 1
fi

# 9. Criar estrutura de diretórios necessários
echo -e "\033[1;34m📂 Criando estrutura de diretórios...\033[0m"
mkdir -p data backups utils handlers
touch data/usuarios.json data/revendas.json

# 10. Iniciar o bot com PM2
echo -e "\033[1;34m🤖 Iniciando o bot...\033[0m"
pm2 delete bot-ssh 2> /dev/null
pm2 start index.js --name "bot-ssh" || check_error "Inicialização do bot"

# Configurar inicialização automática
pm2 startup > /dev/null 2>&1
pm2 save --force

# Verificação final
if pm2 list | grep -q "bot-ssh"; then
  echo -e "\033[1;32m🎉 Instalação concluída com sucesso!\033[0m"
  echo -e "\033[1;36m📌 Comandos úteis:\033[0m"
  echo -e "   pm2 logs bot-ssh         → Ver logs do bot"
  echo -e "   pm2 stop bot-ssh         → Parar o bot"
  echo -e "   pm2 restart bot-ssh      → Reiniciar o bot"
  echo -e "   pm2 monit                → Monitorar processos"
  echo -e "\n\033[1;33m⚠️ IMPORTANTE:\033[0m"
  echo -e "1. Edite o arquivo .env e configure todas as variáveis"
  echo -e "2. Verifique os logs para confirmar que está funcionando: pm2 logs bot-ssh"
else
  echo -e "\033[1;31m❌ O bot não está rodando! Verifique os logs com 'pm2 logs bot-ssh'\033[0m"
  exit 1
fi
