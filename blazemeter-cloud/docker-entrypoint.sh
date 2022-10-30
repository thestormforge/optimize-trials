#!/bin/bash
set -e

if [ -z "${BLAZEMETER_API_ID}" ]; then
	echo "ERROR: BLAZEMETER_API_ID not found. An API ID and an API Secret are required to access Blazemeter." > /dev/stderr
	exit 1
fi

if [ -z "${BLAZEMETER_API_SECRET}" ]; then
	echo "ERROR: BLAZEMETER_API_SECRET not found. An API ID and an API Secret are required to access Blazemeter." > /dev/stderr
	exit 1
fi

if [ -z "${BLAZEMETER_TEST_URL}" ]; then
	echo "ERROR: BLAZEMETER_TEST_URL not found. You must specifiy the URL to a Blazemeter test to run." > /dev/stderr
	exit 1
fi

# Add the basic Taurus arguments
args=(--log="blazemeter.log" -cloud)

# Add the Blazemeter API token
args+=(-o modules.cloud.token="${BLAZEMETER_API_ID}:${BLAZEMETER_API_SECRET}")

# Add the Blazemeter test URL
args+=(-o modules.cloud.test="${BLAZEMETER_TEST_URL}")

# Execute Taurus
bzt "${args[@]}"

# Push the basic statistics
if [ -n "${PUSHGATEWAY_URL}" ]; then
	mlr --c2j remove-empty-columns then rename -g -r '\.0,' /tmp/final-stats.csv \
		| jq -r 'keys[] as $k | "\($k) \(.[$k])"' \
		| curl --data-binary @- "${PUSHGATEWAY_URL}"
else
	echo "WARN: No PUSHGATEWAY_URL configured" > /dev/stderr
fi