FROM openjdk:20-bullseye

RUN \
     curl -LJO https://loadrunner-cloud.saas.microfocus.com/ng1/build/external/storm-cli/lrc_java_cli.zip \
  && unzip lrc_java_cli.zip && rm lrc_java_cli.zip \
  && mkdir -p /loadrunner/jar \
  && mv cli.jar /loadrunner/jar/

COPY docker-entrypoint.sh /usr/local/bin/

VOLUME ["/tmp"]
ENTRYPOINT ["docker-entrypoint.sh"]
