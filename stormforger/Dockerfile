FROM stormforger/cli

USER root
RUN apt-get install -y curl jq
COPY docker-entrypoint.sh compile-loadtest.sh /usr/local/bin/
USER forge

VOLUME ["/tmp"]
ENTRYPOINT ["docker-entrypoint.sh"]
