#!/bin/sh

locust -f locustfile.py \
  --host "${HOST}" \
  --user "${NUM_USERS}" \
  --spawn-rate "${SPAWN_RATE}" \
  --headless \
  --run-time "${RUN_TIME}" \
  --csv "locust"

# parse locust metrics
python parse_metrics.py --metrics_file locust_stats.csv \
  --output_file output.json

cat "output.json" \
  | jq -r '.|keys[] as $k | "\($k) \(.[$k])"' \
  | curl --data-binary @- "${PUSHGATEWAY_URL}"