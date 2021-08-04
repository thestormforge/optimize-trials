FROM stormforger/cli

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
		curl \
		jq \
	&& rm -rf /var/lib/apt/lists/*	
COPY docker-entrypoint.sh /usr/local/bin/

USER forge
VOLUME ["/tmp"]
ENTRYPOINT ["docker-entrypoint.sh"]
