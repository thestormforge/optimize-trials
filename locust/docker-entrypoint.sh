#!/bin/sh
set -e

locust -f "${LOCUSTFILE:-/mnt/locust/locustfile.py}" \
	--host "${HOST:-http://localhost:8000}" \
	--user "${NUM_USERS:-200}" \
	--spawn-rate "${SPAWN_RATE:-20}" \
	--headless \
	--run-time "${RUN_TIME:-180}" \
	--csv "locust"

if [ -n "${PUSHGATEWAY_URL}" ]; then
	python parse_metrics.py --metrics_file locust_stats.csv
	cat "output.json" \
		| jq -r '.|keys[] as $k | "\($k) \(.[$k])"' \
		| curl --data-binary @- "${PUSHGATEWAY_URL}"
fi
