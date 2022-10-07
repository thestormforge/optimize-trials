FROM openjdk:20-slim-bullseye

ARG JMETER_VERSION=5.5

USER root

RUN \
     apt-get update -yqq \
  && apt-get install -yq --no-install-recommends \
      curl \
      jq \
  && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

RUN \
     curl -L -o jmeter.tgz https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz \
  && tar xpvzf jmeter.tgz \
  && rm jmeter.tgz

ENV JMETER_BIN=/apache-jmeter-${JMETER_VERSION}/bin
ENV PATH=$PATH:${JMETER_BIN}

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
VOLUME ["/tmp", "/test"]
