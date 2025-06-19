#!/bin/bash

# Instalador Automático para Bot SSH
echo "✅ Iniciando instalação automática..."

# 1. Atualizar sistema e instalar dependências
echo "🔄 Atualizando sistema e instalando dependências..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y unzip curl

# 2. Instalar Node.js 20.x
echo "📦 Instalando Node.js 20.x..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# 3. Instalar PM2 globalmente
echo "🚀 Instalando PM2..."
sudo npm install -g pm2

# 4. Baixar e extrair o bot
echo "⬇️ Baixando e instalando o bot..."
mkdir -p ~/bot-ssh && cd ~/bot-ssh
wget -q https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip
unzip -o bot.zip && rm bot.zip

# 5. Instalar dependências do Node.js
echo "🔧 Instalando dependências do projeto..."
npm install dotenv node-telegram-bot-api ssh2 fs path pm2 date-fns lodash node-ssh ssh2-sftp-client express multer node-fetch axios

# 6. Iniciar o bot com PM2
echo "🤖 Iniciando o bot..."
pm2 start index.js
pm2 startup && pm2 save

echo "🎉 Instalação concluída com sucesso!"
echo "📌 Comandos úteis:"
echo "   pm2 logs         → Ver logs do bot"
echo "   pm2 stop index   → Parar o bot"
echo "   pm2 restart index → Reiniciar o bot"
