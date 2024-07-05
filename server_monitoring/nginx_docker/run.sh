#!/usr/bin/env bash

export LICENSE="xxxx-xxxx-xxxx"
export WHATAP_SERVER_HOST="1.2.3.4/5.6.7.8"
export PCODE="1234"

cat <<EOF > docker-compose.yaml
version: '3.3'

services:
  nginx:
    build:
      context: ./nginx
    volumes:
      - nginxlog:/usr/local/nginx/logs
    ports:
      - "80:80"
    networks:
      - nginx_net

  whatap_telegraf:
    build:
      context: ./whatap_telegraf
    volumes:
      - nginxlog:/var/log/nginx
    networks:
      - nginx_net
    environment:
      - LICENSE=${LICENSE}
      - WHATAP_SERVER_HOST=${WHATAP_SERVER_HOST}
      - PCODE=${PCODE}
      - NGINX_HOST=nginx

volumes:
  nginxlog:

networks:
  nginx_net:

EOF

docker-compose  up --build