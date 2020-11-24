FROM locustio/locust

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
		curl \
		jq \
	&& rm -rf /var/lib/apt/lists/*

USER locust
COPY docker-entrypoint.sh parse_metrics.py /home/locust/
ENTRYPOINT ["./docker-entrypoint.sh"]
