FROM locustio/locust

USER root
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
RUN apt-get update && \
    apt-get -y install curl jq
COPY parse_metrics.py /locust/
WORKDIR /locust

ENTRYPOINT ["/docker-entrypoint.sh"]