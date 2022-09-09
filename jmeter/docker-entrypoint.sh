#!/bin/bash
set -e

# Make sure TEST_CASE has an organization, just take the first one
if [ "${TEST_CASE}" = "$(basename ${TEST_CASE})" ] ; then
	TEST_CASE="$(forge organization list --output plain | head -1)/${TEST_CASE}"
fi


# Launch the test case
args=(--watch --output json)

if [ -n "${TITLE}" ] ; then
	args+=(--title "${TITLE}")
fi

if [ -n "${NOTES}" ] ; then
	args+=(--notes "${NOTES}")
fi

if [ -n "${REGION}" ] ; then
	args+=(--region "${REGION}")
fi

if [ -n "${SIZING}" ] ; then
	args+=(--sizing "${SIZING}")
fi

if [ -n "${TARGET}" ]; then
	args+=(--define "target=${TARGET}")
fi

if [ -f "${TEST_CASE_FILE}" ] ; then
	args+=(--test-case-file "${TEST_CASE_FILE}")
fi

if [ -f "/etc/podinfo/labels" ] ; then
	while read -r label; do
		args+=(--label "${label}")
	done <"/etc/podinfo/labels"
fi

jmeter -n -t testapp.jmx -l results.dat -e -o tmp/

# Push the basic statistics
if [ -n "${PUSHGATEWAY_URL}" ]; then
	cat "/tmp/statistics.json" \
		| jq -r 'del( .Total.transaction ) | .Total|keys[] as $k | "\($k) \(.[$k])"' \
		| curl --data-binary @- "${PUSHGATEWAY_URL}"
else
	echo "No Pushgateway URL" 1>&2
fi
