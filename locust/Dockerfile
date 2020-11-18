FROM grubykarol/locust:1.2.3-python3.9-alpine3.12

RUN apk add --no-cache curl jq
COPY parse_metrics.py docker-entrypoint.sh /locust/

ENTRYPOINT ["./docker-entrypoint.sh"]