FROM locustio/locust

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
		curl \
		jq \
	&& rm -rf /var/lib/apt/lists/*
COPY docker-entrypoint.sh /usr/local/bin/
COPY parse_metrics.py /home/locust/

USER locust
ENTRYPOINT ["docker-entrypoint.sh"]
