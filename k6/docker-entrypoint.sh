#!/bin/sh
set -e

# Check for the test script file via either a passed-in env path or the default
# In either case, the file should be mounted as a volume (from configmap, etc)
SCRIPT_FILE=${SCRIPT_FILE:-"/scripts/script.js"}

if ! [ -f "${SCRIPT_FILE}" ]; then
  echo "A test script file must be provided."
  exit 1
fi

# NOTE: handleSummary.js currently hardcodes the output file, we're instructing
#       k6 to generate when its done.
PROMETHEUS_OUTPUT_FILE="/tmp/prometheus.txt"

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

COMBINED_SCRIPT_FILE="/tmp/combined_script.js"

# Check for a custom handleSummary() in the provided script, add it otherwise
cp "${SCRIPT_FILE}" ${COMBINED_SCRIPT_FILE}
grep -q "export \+function \+handleSummary" "${SCRIPT_FILE}" || cat "${SCRIPT_FILE}" handleSummary.js > "${COMBINED_SCRIPT_FILE}"

# Run the test script. If we used the default handleSummary.js snippet, the output
# file will be called prometheus.txt. If handleSummary was provided as part of
# the test script file, PROMETHEUS_OUTPUT_FILE will need to be set to the corresponding output file namespace
echo
echo "Launching k6 test..."
# shellcheck disable=SC2086
k6 run ${SF_K6_ARGS} "${COMBINED_SCRIPT_FILE}"

printf "\nk6 run complete"

# Push to the Prometheus PushGateway if specified
if [ -n "${PUSHGATEWAY_URL}" ]; then
  # Check, if our handleSummary function wrote its output
  if ! [ -f "${PROMETHEUS_OUTPUT_FILE}" ]; then
    echo "Test script output was not found at ${PROMETHEUS_OUTPUT_FILE}. Unable to push to Prometheus."
    exit 1
  fi

  printf "\n\nPrometheus metric summary of k6 run:\n"
  cat ${PROMETHEUS_OUTPUT_FILE}
  echo
  echo
  printf "Pushing metrics to %s\n" "${PUSHGATEWAY_URL}"
  curl --fail-with-body -i --no-progress-meter --data-binary @"${PROMETHEUS_OUTPUT_FILE}" "${PUSHGATEWAY_URL}"
  PUSH_OK=$?

  if [ "$PUSH_OK" -ne 0 ]; then
    echo "Uploading to Pushgateway failed, curl exit code ${PUSH_OK}"
    exit $PUSH_OK
  fi
else
  echo "WARN: No PUSHGATEWAY_URL configured" > /dev/stderr
fi
