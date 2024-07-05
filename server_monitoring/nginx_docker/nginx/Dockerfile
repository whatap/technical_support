FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Asia/Seoul
RUN sed -i 's/kr.archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list

RUN apt update \
  && apt install -qq -y tzdata vim git net-tools iputils-ping wget curl tcpdump telnet logrotate cron procps \
  && apt install -qq -y gcc make libpcre3-dev libssl-dev zlib1g zlib1g-dev \
  && apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf /var/lib/{apt,dpkg,cache,log}

# Define working directory.
RUN cd /tmp \
 && git clone https://github.com/yaoweibin/nginx_upstream_check_module.git \
 && wget http://nginx.org/download/nginx-1.24.0.tar.gz \
 && tar zxvf nginx-1.24.0.tar.gz \
 && cd nginx-1.24.0 \
 && patch -p1 < ../nginx_upstream_check_module/check_1.20.1+.patch \
 && ./configure --add-module=../nginx_upstream_check_module --with-http_ssl_module --with-http_realip_module --with-http_v2_module --with-http_stub_status_module --with-stream \
 && make \
 && make install \
 && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
 && echo $TZ > /etc/timezone \
 && mkdir -p /usr/local/nginx/mounted/conf \
 && mkdir -p /usr/local/nginx/mounted/sites \
 && mkdir -p /usr/local/nginx/mounted/ssl \
 && mkdir -p /usr/local/nginx/conf/sites \
 && mkdir -p /usr/local/nginx/bin \
 && mkdir -p /usr/local/nginx/ssl \
 && mkdir -p /usr/local/nginx/run \
 && mkdir -p /usr/local/nginx/logs/old \
 && rm -rf /tmp/* \
 && useradd -d /nonexistent -s /usr/sbin/nologin nginx

# Logrotate, cron Install & setting
#COPY docker/logrotate/nginx /etc/logrotate.d/nginx
#RUN chmod 644 /etc/logrotate.d/nginx

#COPY docker/logrotate/logrotate.sh /etc/cron.d/logrotate.sh
#RUN chmod 0755 -R /etc/cron.d/*

ADD bin/nginx_entry_point.sh /usr/local/nginx/bin/nginx_entry_point.sh
RUN chmod +x /usr/local/nginx/bin/nginx_entry_point.sh
# Define working directory.
WORKDIR /usr/local/nginx

EXPOSE 443 80

# Define default command.
#CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
#ENTRYPOINT ["/usr/local/nginx/bin/nginx_entry_point.sh"]
CMD ["/usr/local/nginx/bin/nginx_entry_point.sh"]