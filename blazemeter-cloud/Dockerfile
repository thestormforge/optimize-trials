FROM blazemeter/taurus:latest

USER root

RUN \
     apt-get update -yqq \
  && apt-get install -yq --no-install-recommends \
      curl \
      jq \
      miller \
  && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*lo

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
VOLUME ["/tmp", "/test"]