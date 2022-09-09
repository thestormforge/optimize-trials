#!/usr/bin/env bash

#
# This script builds a new docker image, runs a load test once 
#


set -eu -o pipefail

assert_logs_contains() {
    docker logs "${CONTAINER_NAME}" | grep --quiet "$@" || (echo "grep failed: grep \"$@\"" > /dev/stderr; exit 1)
}

IMAGE_NAME="jmeter:tmp"
CONTAINER_NAME="jmeter-test"

docker rm "${CONTAINER_NAME}" || true
docker build -t "${IMAGE_NAME}" "$(dirname $0)/.."
docker run --name "${CONTAINER_NAME}" -ti -v "$(pwd)/$(dirname $0):/test:ro" "${IMAGE_NAME}"

assert_logs_contains "errorCount" # we have stats
assert_logs_contains "errorPct"
assert_logs_contains "pct1ResTime"
assert_logs_contains "... end of run" # jmeter was executed

echo "done"