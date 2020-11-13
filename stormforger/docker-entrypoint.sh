#!/bin/bash

# Check that we can talk to the API
forge ping

# Build the test case script
compile-loadtest.sh > "/tmp/testcase.js"

# Set the notes
if [ -f "/etc/podinfo/labels" ] ; then
	NOTES="$(cat /etc/podinfo/labels)"
fi

# Launch and wait for the test case
forge test-case launch "${TEST_CASE}" --test-case-file="/tmp/testcase.js" \
  --title "${TITLE}" --notes="${NOTES}" ${LAUNCH_ARGS} \
  --watch --output json | tee >(tail -n 1 > "/tmp/output.json")

# Push the basic statistics
cat "/tmp/output.json" \
  | jq -r '.data.attributes.basic_statistics|keys[] as $k | "\($k) \(.[$k])"' \
  | curl --data-binary @- "${PUSHGATEWAY_URL}"
