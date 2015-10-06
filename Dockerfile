FROM iameli/drumstick

RUN apt-get update && apt-get install -y openssh-server
EXPOSE 22
ADD authorized_keys /root/.ssh/authorized_keys
ADD entrypoint-eli.fish /root/.build/
RUN chmod 600 /root/.ssh/authorized_keys && \
  chmod 755 /root/.build/entrypoint-eli.fish

CMD /root/.build/entrypoint-eli.fish
