#!/bin/bash
set -e

stats() {
	cat "${REPORT_DIR}/statistics.json" \
		| jq -r 'del( .Total.transaction ) | .Total|keys[] as $k | "\($k) \(.[$k])"'
}

TEST_CASE_FILE="${TEST_CASE_FILE:-/test/test.jmx}"
REPORT_DIR="/tmp/jmeter-report"
JMETER_ARGS=${JMETER_ARGS:-}

if [ ! -f "${TEST_CASE_FILE}" ]; then
	echo "ERROR: TEST_CASE_FILE=${TEST_CASE_FILE} not found. Did you forget to mount as volume or via ConfigMap?" > /dev/stderr
	exit 1
fi

jmeter -n -t "${TEST_CASE_FILE}" -l "results.dat" -e -o "${REPORT_DIR}" $JMETER_ARGS

stats

# Push the basic statistics
if [ -n "${PUSHGATEWAY_URL}" ]; then
	stats | curl --data-binary @- "${PUSHGATEWAY_URL}"
else
	echo "WARN: No PUSHGATEWAY_URL configured" > /dev/stderr
fi
