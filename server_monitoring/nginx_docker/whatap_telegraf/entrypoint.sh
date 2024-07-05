#!/usr/bin/env bash

WHATAP_SERVER_HOST_ARRAY=""

# 함수: 환경변수를 확인하고 없으면 안내 메시지 출력
check_env_var() {
  local var_name="$1"
  local var_value="${!var_name}"

  if [ -z "$var_value" ]; then
    echo "환경변수 $var_name가 설정되지 않았습니다. 해당 환경변수를 설정해 주세요."
    exit 1
  fi
}

prepare(){
    
    # 확인할 환경변수 목록
    env_vars=("LICENSE" "WHATAP_SERVER_HOST" "PCODE" "NGINX_HOST")

    # 각 환경변수에 대해 확인
    for var in "${env_vars[@]}"; do
    check_env_var "$var"
    done


    # 콤마로 구분된 IP 목록을 배열로 변환
    IFS='/' read -ra ADDR <<< "$WHATAP_SERVER_HOST"

    # 결과 문자열 초기화
    WHATAP_SERVER_HOST_ARRAY="["

    # 각 IP 주소에 대해 포트 번호 추가
    for i in "${ADDR[@]}"; do
        WHATAP_SERVER_HOST_ARRAY+="\"tcp://$i:6600\", "
    done

    # 마지막 콤마와 공백 제거
    WHATAP_SERVER_HOST_ARRAY="${WHATAP_SERVER_HOST_ARRAY%, }"

    # 닫는 대괄호 추가
    WHATAP_SERVER_HOST_ARRAY+="]"

}

configure_telegraf() {

    telegraf_config=./
    
    cat <<EOF > $telegraf_config/telegraf.conf
[global_tags]
[agent]
interval = "10s"
round_interval = true
metric_batch_size = 10000
metric_buffer_limit = 100000
collection_jitter = "0s"
flush_interval = "10s"
flush_jitter = "0s"
logtarget = "stderr"
omit_hostname = true

[[outputs.whatap]]
license = "$LICENSE"
pcode = $PCODE
servers = $WHATAP_SERVER_HOST_ARRAY

[[inputs.nginx]]
  ## An array of Nginx Plus status URIs to gather stats.
  urls = ["http://${NGINX_HOST}/nginx_status"]
[[aggregators.basicstats]]
  period = "60s"

  stats = ["diff"]

[[inputs.tail]]
         name_override = "nginxlog"
         files = ["/var/log/nginx/access.log"]
         from_beginning = false
         pipe = false
         data_format = "grok"
         #grok_patterns = ["%{COMBINED_LOG_FORMAT}"]
         grok_custom_patterns = '''
      COMBINED_LOG_FORMAT %{COMMON_LOG_FORMAT} %{QS:referrer} %{QS:agent}
      COMMON_LOG_FORMAT %{IPORHOST:client_ip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "(?:%{WORD:verb} %{NOTSPACE:request}(?: HTTP/%{NUMBER:httpversion})?|%{DATA:rawrequest})" %{NUMBER:response} (?:%{NUMBER:bytes}|-)
    '''


[[aggregators.valuecounter]]
  namepass = ["nginxlog"]
  fields = ["response", "verb"]
  drop_original = true

EOF

}


start_telegraf(){

    ./telegraf --config ./telegraf.conf
}

prepare
configure_telegraf
start_telegraf