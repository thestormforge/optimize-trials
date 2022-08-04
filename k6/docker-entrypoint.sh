#!/bin/sh
set -e

# Check for the test case file via either a passed-in env path or the default
# In either case, the file should be mounted as a volume (from configmap, etc)
TEST_CASE_FILE=${TEST_CASE_FILE:-"/scripts/load_script.js"}
TEST_CASE_OUTPUT=${TEST_CASE_OUTPUT:-"prometheus.txt"}

if ! [ -f "${TEST_CASE_FILE}" ]; then
  echo "A test case JS file must be provided." 1>&2
  exit 1
fi

# Check that we have a Prometheus Pushgateway defined
if [ -z "${PUSHGATEWAY_URL}" ]; then
  echo "No Pushgateway URL" 1>&2
  exit 1
fi

COMBINED_TEST_CASE_FILE="/tmp/combined_load_script.js"

# Check for a custom handleSummary() in the provided load_script, add it otherwise
grep -q "export \+function \+handleSummary" ${TEST_CASE_FILE} && cp ${TEST_CASE_FILE} ${COMBINED_TEST_CASE_FILE} || cat ${TEST_CASE_FILE} handleSummary.js > ${COMBINED_TEST_CASE_FILE}

# Run the test case. If we used the default handleSummary.js snippet, the output
# file will be called prometheus.txt. If handleSummary was provided as part of
# the test case js file, TEST_CASE_OUTPUT will need to be set to the corresponding output file namespace
k6 run "${COMBINED_TEST_CASE_FILE}"

# If
if ! [ -f "${TEST_CASE_OUTPUT}" ]; then
  echo "Test case output was not found. Unable to push to Prometheus." 1>&2
  exit 1
fi

# Push to the Prometheus PushGateway
cat ${TEST_CASE_OUTPUT} | curl --data-binary @- "${PUSHGATEWAY_URL}"
