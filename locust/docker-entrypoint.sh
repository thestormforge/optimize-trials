#!/bin/sh
set -e

HOST=${HOST:-http://localhost:8000}
NUM_USERS=${NUM_USERS:-200}
SPAWN_RATE=${SPAWN_RATE:-20}
RUN_TIME=${RUN_TIME:-180}
PUSHGATEWAY_URL=${LOAD_TEST_PAUSE:-http://prometheus:9091/metrics/job/trialRun}

locust -f locustfile.py \
  --host "${HOST}" \
  --user "${NUM_USERS}" \
  --spawn-rate "${SPAWN_RATE}" \
  --headless \
  --run-time "${RUN_TIME}" \
  --csv "locust"

# parse locust metrics
python parse_metrics.py --metrics_file locust_stats.csv

cat "output.json" \
  | jq -r '.|keys[] as $k | "\($k) \(.[$k])"' \
  | curl --data-binary @- "${PUSHGATEWAY_URL}"
