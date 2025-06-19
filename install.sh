# ...código anterior...

# 4.1. Solicitar informações do usuário
echo "🔑 Por favor, insira o TOKEN do seu bot do Telegram:"
read TELEGRAM_TOKEN
echo "👤 Agora insira o ID do usuário do Telegram autorizado:"
read TELEGRAM_USER_ID

# 4.2. Substituir BOT_TOKEN e ADM_ID no .env existente
sed -i "s/^BOT_TOKEN=.*/BOT_TOKEN=$TELEGRAM_TOKEN/" .env
sed -i "s/^ADM_ID=.*/ADM_ID=$TELEGRAM_USER_ID/" .env
echo "✅ BOT_TOKEN e ADM_ID atualizados no .env!"

# ...restante do código...
