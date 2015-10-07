FROM iameli/drumstick

RUN apt-get update && apt-get install -y openssh-server
EXPOSE 22
ADD authorized_keys /build/authorized_keys
ADD entrypoint-eli.fish /build/entrypoint-eli.fish
RUN chmod 600 /build/authorized_keys && \
  chmod 755  /build/entrypoint-eli.fish

CMD /build/entrypoint-eli.fish
