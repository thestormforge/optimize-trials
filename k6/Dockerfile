FROM grafana/k6

USER root
RUN apk add --no-cache \
		curl jq
COPY docker-entrypoint.sh /usr/local/bin/
COPY handleSummary.js .

USER 12345
VOLUME ["/tmp"]
ENTRYPOINT ["docker-entrypoint.sh"]
