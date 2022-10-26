#!/bin/bash
set -xe

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

# TODO: Metrics.... Either CSV/XML output from Taurus or CURL the Blazemeter API for JSON summary metrics
