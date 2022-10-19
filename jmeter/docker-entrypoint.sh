#!/bin/bash
set -e

stats() {
	jq -r 'del( .Total.transaction ) | .Total|keys[] as $k | "\($k) \(.[$k])"' < "${REPORT_DIR}/statistics.json"
}

JMETER_TEST_PLAN_FILE="${JMETER_TEST_PLAN_FILE:-/test/test.jmx}"
REPORT_DIR="/tmp/jmeter-report"
JMETER_ARGS=${JMETER_ARGS:-}

if [ ! -f "${JMETER_TEST_PLAN_FILE}" ]; then
	echo "ERROR: JMETER_TEST_PLAN_FILE=${JMETER_TEST_PLAN_FILE} not found. Did you forget to mount as volume or via ConfigMap?" > /dev/stderr
	exit 1
fi

# If PUSHGATEWAY_URL is defined, test the connection to see if its viable, exit with error if not
if [ -n "${PUSHGATEWAY_URL}" ]; then
  # tests if the Pushgateway is returning a successful
  # HTTP response for /-/ready as a sanity check.
  echo "Pinging Pushgateway..."
  curl --no-progress-meter --fail --request-target "/-/ready" "${PUSHGATEWAY_URL}" || {
    echo "PUSHGATEWAY_URL was specified but test connection to ${PUSHGATEWAY_URL} failed. Exiting."
    return 1
  }
  echo
fi

# shellcheck disable=SC2086
jmeter -n -t "${JMETER_TEST_PLAN_FILE}" -l "/tmp/results.dat" -e -o "${REPORT_DIR}" $JMETER_ARGS

# Push the basic statistics
if [ -n "${PUSHGATEWAY_URL}" ]; then
	stats | curl --data-binary @- "${PUSHGATEWAY_URL}"
else
	echo "WARN: No PUSHGATEWAY_URL configured" > /dev/stderr
fi
