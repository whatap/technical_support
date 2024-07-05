# Nginx Telegraf 모니터링 예제

이 리포지토리는 Nginx를 Telegraf로 모니터링하는 예제를 제공합니다. Docker Compose를 사용하여 Nginx와 Telegraf를 설정하며, Telegraf는 Nginx의 상태를 모니터링하고 로그를 수집합니다.

## 디렉토리 구조
```bash
nginx_docker/
├── nginx/
│ ├── bin/
│ │ └── nginx_entry_point.sh
│ └── Dockerfile
├── whatap_telegraf/
│ ├── Dockerfile
│ ├── entrypoint.sh
│ ├── install_telegraf.sh
├── docker-compose.yaml
├── NginxContainer.json
└── run.sh
```

## 설정 방법

Nginx 설정
Nginx 컨테이너는 /usr/local/nginx/logs 디렉토리를 사용하여 로그를 기록합니다. Telegraf 컨테이너는 이 로그 디렉토리를 /var/log/nginx로 마운트하여 로그 데이터를 수집합니다. 이를 위해 docker-compose.yaml 파일에서 공동 볼륨 처리를 했습니다.

Telegraf 설정
Telegraf는 Nginx의 상태를 모니터링하기 위해 Nginx의 /nginx_status 엔드포인트에 접근합니다. entrypoint.sh 스크립트는 Telegraf가 Nginx 상태 페이지에 접근할 수 있도록 설정합니다.

### 1. `nginx.conf` 수정

사용자는 `nginx.conf` 파일을 수정해야 합니다. Nginx 설정 파일인 `nginx.conf`에 아래 내용을 추가합니다:

```nginx
location /nginx_status {
    stub_status;
    allow 127.0.0.1;   # 로컬 접근 허용
    allow 172.18.0.0/16; # 도커 네트워크에서 접근 허용 (네트워크 서브넷에 맞게 수정)
    deny all;          # 그 외 접근 차단
}
```

### 2. 환경 변수 설정 및 Docker Compose 실행
run.sh 스크립트를 실행하여 Docker Compose 파일을 생성하고 컨테이너를 실행합니다. 스크립트 실행 전에 LICENSE, WHATAP_SERVER_HOST, PCODE 환경 변수를 설정합니다.

```bash
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

docker-compose up --build
```

### 3. 대시보드 Import
NginxContainer.json 플렉스보드를 Import 합니다.
