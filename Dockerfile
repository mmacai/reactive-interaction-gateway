FROM elixir:1.5

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

WORKDIR /opt/sites/fsa-reactive-gateway
COPY ./fsa-reactive-gateway /opt/sites/fsa-reactive-gateway/
COPY .erlang.cookie /root
EXPOSE 6060
EXPOSE 4369
EXPOSE 9100-9155

# CMD ["/opt/sites/fsa-reactive-gateway/bin/gateway", "foreground"]
COPY run.sh /opt/sites/fsa-reactive-gateway/run.sh
ENTRYPOINT ["/opt/sites/fsa-reactive-gateway/run.sh"]
