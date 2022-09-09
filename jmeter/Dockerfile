FROM openjdk:8

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
		curl \
		jq \
	&& rm -rf /var/lib/apt/lists/*	
RUN curl -L -o jmeter.tgz https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.5.tgz
RUN tar xpvf jmeter.tgz

COPY docker-entrypoint.sh /usr/local/bin/

ENV JMETER_BIN=/apache-jmeter-5.5/bin
ENV PATH=$PATH:${JMETER_BIN}

VOLUME ["/tmp"]

ENTRYPOINT ["docker-entrypoint.sh"]
