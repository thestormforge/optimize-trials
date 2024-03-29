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
	jq -r '.|keys[] as $k | "\($k) \(.[$k])"' < "output.json" \
		| curl --data-binary @- "${PUSHGATEWAY_URL}"
else
	echo "WARN: No PUSHGATEWAY_URL configured" > /dev/stderr
fi
