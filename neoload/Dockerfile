FROM python:3.10-bullseye

USER root

RUN \
     apt-get update -yqq \
  && apt-get install -yq --no-install-recommends \
      uuid-runtime \
      curl \
      jq \
  && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

RUN pip3 install neoload

COPY docker-entrypoint.sh parse-report.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
