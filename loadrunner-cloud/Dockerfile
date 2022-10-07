FROM openjdk:20-slim-bullseye

RUN \
     apt-get update -yqq \
  && apt-get install -yq --no-install-recommends \
      curl \
      unzip \
  && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

RUN \
     curl -LJO https://loadrunner-cloud.saas.microfocus.com/ng1/build/external/storm-cli/lrc_java_cli.zip \
  && unzip lrc_java_cli.zip && rm lrc_java_cli.zip \
  && mkdir -p /loadrunner/jar \
  && mv cli.jar /loadrunner/jar/

COPY docker-entrypoint.sh /usr/local/bin/

VOLUME ["/tmp"]
ENTRYPOINT ["docker-entrypoint.sh"]
