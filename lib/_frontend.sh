#!/bin/bash
# 
# functions for setting up app frontend

#######################################
# updates frontend code
# Arguments:
#   None
#######################################
frontend_node_dependencies() {
  print_banner
  printf "${WHITE} 💻 Instalando dependências do frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sudo su - deploy <<EOF
  cd /home/deploy/whaticket/frontend
  npm install
EOF
}

#######################################
# updates frontend code
# Arguments:
#   None
#######################################
frontend_node_build() {
  print_banner
  printf "${WHITE} 💻 Compilando o código do frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sudo su - deploy <<EOF
  cd /home/deploy/whaticket/frontend
  npm install
  npm run build
EOF
}

#######################################
# updates frontend code
# Arguments:
#   None
#######################################
frontend_update() {
  print_banner
  printf "${WHITE} 💻 Atualizando o frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sudo su - deploy <<EOF
  cd /home/deploy/whaticket
  git pull
  cd /home/deploy/whaticket/frontend
  npm install
  rm -rf build
  npm run build
  pm2 restart all
EOF
}


#######################################
# updates frontend code
# Arguments:
#   None
#######################################
frontend_set_env() {
  print_banner
  printf "${WHITE} 💻 Configurando variáveis de ambiente (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  backend_url=https://api.mydomain.com

sudo su - deploy << EOF
  cat <<[-]EOF > /home/deploy/whaticket/frontend/.env
REACT_APP_BACKEND_URL=${backend_url}
[-]EOF
EOF
}

#######################################
# updates frontend code
# Arguments:
#   None
#######################################
frontend_start_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sudo su - deploy <<EOF
  cd /home/deploy/whaticket/frontend
  pm2 start server.js --name whaticket-frontend
  pm2 save
EOF
}

#######################################
# updates frontend code
# Arguments:
#   None
#######################################
frontend_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  frontend_url=https://myapp.mydomain.com
  frontend_url=$(echo "${frontend_url/https:\/\/}")

sudo su - root << EOF

cat > /etc/nginx/sites-available/whaticket-frontend << 'END'
server {
  server_name $frontend_url;

  location / {
    proxy_pass http://127.0.0.1:3333;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END

sudo ln -s /etc/nginx/sites-available/whaticket-frontend /etc/nginx/sites-enabled
EOF
}
