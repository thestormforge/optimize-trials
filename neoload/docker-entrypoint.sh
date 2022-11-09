#!/bin/bash
set -e

if [ -z "${ZONE}" ]; then
	ZONE="USEGCP"
fi

if [ -z "${LGS}" ]; then
	LGS=2
fi

if [ -z "${SCENARIO}" ]; then
	SCENARIO="StormForgeScenario"
fi

if [ -z "${TEST_NAME}" ]; then
	TEST_NAME="SF-"$(uuidgen)
fi

if [ -z "${NEOLOAD_TOKEN}" ]; then
	echo "ERROR: NEOLOAD_TOKEN not found. You must specify a valid NeoLoad authentication token to access NeoLoad Web." > /dev/stderr
	exit 1
fi

if [ ! -f "${TEST_FILE}" ]; then
	echo "ERROR: TEST_FILE = ${TEST_FILE} not found. Did you forget to mount as volume or via ConfigMap?" > /dev/stderr
	exit 1
fi

# neoload read-only bug workaround
cp "${TEST_FILE}" /tmp/neoload-stormforge.yaml
TEST_FILE="/tmp/neoload-stormforge.yaml"

neoload login ${NEOLOAD_TOKEN} 
neoload test-settings --zone ${ZONE}  --lgs ${LGS} --scenario ${SCENARIO} create "${TEST_NAME}"

neoload project --path ${TEST_FILE} upload
neoload test-settings use "${TEST_NAME}"
neoload run

neoload report --template builtin:transactions-csv > transactions.csv

/parse-report.sh

# Push the basic statistics
if [ -n "${PUSHGATEWAY_URL}" ]; then
	/parse_report.sh | curl --data-binary @- "${PUSHGATEWAY_URL}"
else
	echo "No Pushgateway URL" 1>&2
fi
