FROM grafana/k6

USER root
RUN apk add --no-cache \
		curl
COPY docker-entrypoint.sh /usr/local/bin/
COPY handleSummary.js .
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN chown 12345 /usr/local/bin/docker-entrypoint.sh

USER 12345
VOLUME ["/tmp"]
ENTRYPOINT ["docker-entrypoint.sh"]
