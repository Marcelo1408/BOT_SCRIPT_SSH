#!/bin/bash

# =============================================
# INSTALADOR RÁPIDO PARA BOT SSH + PROXY
# Versão: 3.3 (Otimizada)
# =============================================

# Cores no terminal
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# Otimização: Verificar e pular etapas já concluídas
check_installed() {
    command -v $1 >/dev/null 2>&1
}

# Função para instalação rápida do Node.js
install_nodejs() {
    if check_installed node; then
        echo -e "${YELLOW}Node.js já instalado. Pulando instalação...${NC}"
        return 0
    fi
    
    echo -e "${BLUE}⚡ Instalando Node.js 20.x...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - >/dev/null 2>&1
    sudo apt-get install -y nodejs >/dev/null 2>&1
}

# Função principal
main() {
    # 1. Atualização rápida do sistema
    echo -e "${BLUE}⚡ Atualizando pacotes...${NC}"
    sudo apt-get update >/dev/null 2>&1

    # 2. Instalação das dependências essenciais
    echo -e "${BLUE}⚡ Instalando dependências...${NC}"
    sudo apt-get install -y --no-install-recommends \
        curl wget git unzip \
        build-essential python3 make gcc \
        libssh2-1-dev \
        net-tools iptables >/dev/null 2>&1

    # 3. Instalação otimizada do Node.js
    install_nodejs

    # 4. Download direto do bot (versão compactada)
    echo -e "${BLUE}⚡ Baixando o Bot SSH...${NC}"
    mkdir -p ~/bot && cd ~/bot
    wget -q --show-progress https://github.com/Marcelo1408/BOT_SCRIPT_SSH/raw/main/novobotssh.zip -O bot.zip
    unzip -o bot.zip && rm -f bot.zip

    # 5. Instalação rápida das dependências do Node
    echo -e "${BLUE}⚡ Instalando dependências do Bot...${NC}"
    npm install --production --silent >/dev/null 2>&1

    # 6. Configuração mínima
    echo -e "${GREEN}🤖 Configuração rápida do Bot:${NC}"
    read -p "Digite o BOT_TOKEN do Telegram: " BOT_TOKEN
    read -p "Digite o ADM_ID do Telegram: " ADM_ID

    cat > .env <<EOF
BOT_TOKEN=$BOT_TOKEN
ADM_ID=$ADM_ID
SERVER_HOST=$(curl -s ifconfig.me)
SERVER_USER=admin
SERVER_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
SERVER_PORT=22
SSH_TIMEOUT=20000
PROXY_ENABLED=true
PROXY_HOST=127.0.0.1
PROXY_PORT=3128
EOF

    # 7. Inicialização com PM2
    echo -e "${BLUE}⚡ Iniciando o Bot...${NC}"
    npm install -g pm2 --silent >/dev/null 2>&1
    pm2 start index.js --name "bot" >/dev/null 2>&1
    pm2 startup && pm2 save >/dev/null 2>&1

    # Finalização
    echo -e "${GREEN}"
    echo "============================================="
    echo "🚀 BOT SSH INSTALADO COM SUCESSO!"
    echo "============================================="
    echo -e "${NC}"
    echo -e "${YELLOW}🔍 Dados de acesso:${NC}"
    echo -e "IP do servidor: $(curl -s ifconfig.me)"
    echo -e "Usuário: admin"
    echo -e "Senha: ${SERVER_PASSWORD}"
    echo -e "\n${BLUE}📌 Comandos úteis:${NC}"
    echo -e "Ver logs: pm2 logs bot-ssh"
    echo -e "Reiniciar: pm2 restart bot-ssh"
}

# Verificação de segurança
echo -e "${YELLOW}⚠️ Este script instalará o Bot SSH + Proxy${NC}"
read -p "Continuar? (s/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    main
else
    echo -e "${RED}Instalação cancelada.${NC}"
fi
