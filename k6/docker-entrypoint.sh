#!/bin/sh
set -e

{

# curl_pushgateway_test() tests for a valid PUSHGATEWAY_URL by attempting a
# POST of a test metric, checking for a valid curl return code, a valid
# HTTP response code, and lastly a successful query of the test metric value.
curl_pushgateway_test() {
  HTTP_CODE=$(echo "test_metric 42" | curl -s --connect-timeout 5 -w "%{http_code}" --data-binary @- "$@" &2>1)

  if  [ $? -ne 0 ]; then
    echo "PUSHGATEWAY_URL was specified but test connection to ${PUSHGATEWAY_URL} failed. Exiting. "
    return 1
  fi

# curl can sometimes return text along with the http code.
  if [[ ! "${HTTP_CODE}" =~ '^[0-9]+$' ]]; then
    echo "Pushgateway returned a non-numeric error code (${HTTP_CODE}). "
    return 1
  elif [[  ${HTTP_CODE} -lt 200 || ${HTTP_CODE} -gt 299 ]] ; then
    echo "Pushgateway returned HTTP error (${HTTP_CODE}). "
    return 1
  fi

  echo "Verifying POSTED test metric..."
  QUERY_BASE=$(echo $PUSHGATEWAY_URL | cut -d\/ -f1-3)
  TEST_VALUE=$(curl -s "${QUERY_BASE}/api/v1/metrics" | jq -r '.data[0].test_metric.metrics[0].value')
  printf "Queried test mertric value: \"${TEST_VALUE}\" ..."
  if  [ $TEST_VALUE -ne 42 ]; then
    echo " FAILED!"
    echo "\tTest metric POST was successful but test metric verification query failed. Exiting. "
    return 1
  fi
  echo " PASSED!"
}

# Check for the test case file via either a passed-in env path or the default
# In either case, the file should be mounted as a volume (from configmap, etc)
TEST_CASE_FILE=${TEST_CASE_FILE:-"/scripts/load_script.js"}
TEST_CASE_OUTPUT=${TEST_CASE_OUTPUT:-"prometheus.txt"}

if ! [ -f "${TEST_CASE_FILE}" ]; then
  echo "A test case JS file must be provided."
  exit 1
fi


# If PUSHGATEWAY_URL is defined, test the connection to see if its viable, exit with error if not
if [ -n "${PUSHGATEWAY_URL}" ]; then
  echo "PUSHGATEWAY_URL was specified testing connection... "
  curl_pushgateway_test ${PUSHGATEWAY_URL}
  echo "Successfully connected to ${PUSHGATEWAY_URL} and POSTED a test metric. Proceeding. "
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
  echo "Test case output was not found. Unable to push to Prometheus."
  exit 1
fi

# Push to the Prometheus PushGateway if specified
if [ -n "${PUSHGATEWAY_URL}" ]; then
  cat ${TEST_CASE_OUTPUT}
  PUSH_OUTPUT=$(cat ${TEST_CASE_OUTPUT} | curl --fail-with-body -s --data-binary @- "${PUSHGATEWAY_URL}" &2>1)

  if [ -n "${PUSH_OUTPUT}" ]; then
    echo "Pushgateway returned an error (${PUSH_OUTPUT}). "
    exit 1
  fi
fi

exit $?
} 2>&1 | tee -a /proc/1/fd/1
