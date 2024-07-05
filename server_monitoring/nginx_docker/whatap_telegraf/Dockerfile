from ubuntu:22.04

WORKDIR /app/whatap

ADD . .

RUN chmod +x ./*.sh
RUN ./install_telegraf.sh

CMD [ "./entrypoint.sh" ]