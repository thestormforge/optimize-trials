#!/bin/sh
set -e

{

# Check for the test case file via either a passed-in env path or the default
# In either case, the file should be mounted as a volume (from configmap, etc)
TEST_CASE_FILE=${TEST_CASE_FILE:-"/scripts/load_script.js"}

# NOTE: handleSummary.js currently hardcodes the output file, we're instructing
#       k6 to generate when its done.
TEST_CASE_OUTPUT="prometheus.txt"

if ! [ -f "${TEST_CASE_FILE}" ]; then
  echo "A test case JS file must be provided."
  exit 1
fi

# If PUSHGATEWAY_URL is defined, test the connection to see if its viable, exit with error if not
if [ -n "${PUSHGATEWAY_URL}" ]; then
  # tests if the Pushgateway is returning a successful
  # HTTP response for /-/ready as a sanity check.
  curl --fail --request-target "/-/ready" "${PUSHGATEWAY_URL}" || {
    echo "PUSHGATEWAY_URL was specified but test connection to ${PUSHGATEWAY_URL} failed. Exiting."
    return 1
  }
fi

COMBINED_TEST_CASE_FILE="/tmp/combined_load_script.js"

# Check for a custom handleSummary() in the provided load_script, add it otherwise
grep -q "export \+function \+handleSummary" ${TEST_CASE_FILE} && cp ${TEST_CASE_FILE} ${COMBINED_TEST_CASE_FILE} || cat ${TEST_CASE_FILE} handleSummary.js > ${COMBINED_TEST_CASE_FILE}

# Run the test case. If we used the default handleSummary.js snippet, the output
# file will be called prometheus.txt. If handleSummary was provided as part of
# the test case js file, TEST_CASE_OUTPUT will need to be set to the corresponding output file namespace
k6 run "${COMBINED_TEST_CASE_FILE}"

# Push to the Prometheus PushGateway if specified
if [ -n "${PUSHGATEWAY_URL}" ]; then
  # Check, if our handleSummary function wrote its output
  if ! [ -f "${TEST_CASE_OUTPUT}" ]; then
    echo "Test case output was not found at ${TEST_CASE_OUTPUT}. Unable to push to Prometheus."
    exit 1
  fi
  printf "K6 run complete.\n\nTest case output:\n"
  cat ${TEST_CASE_OUTPUT}
  printf "Pushing metrics to ${PUSHGATEWAY_URL}\n"
  PUSH_OUTPUT=$(cat ${TEST_CASE_OUTPUT} | curl --fail-with-body -s --data-binary @- "${PUSHGATEWAY_URL}" &2>1)
  printf "Push output:\n"
  cat ${PUSH_OUTPUT}

  if [ -n "${PUSH_OUTPUT}" ]; then
    echo "Pushgateway returned an error (${PUSH_OUTPUT}). "
    exit 1
  fi
fi

exit $?
} 2>&1
