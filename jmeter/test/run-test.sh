#!/usr/bin/env bash

set -eu -o pipefail

assert_logs_contains() {
    cat $LOGS_TEMPFILE | grep --quiet "$@" || (echo "grep failed: grep \"$@\"" > /dev/stderr; exit 1)
}

IMAGE_NAME="${IMAGE_NAME:-"jmeter:tmp"}"
CONTAINER_NAME="jmeter-test"
LOGS_TEMPFILE="$(mktemp)"

docker run --rm --name "${CONTAINER_NAME}" -ti -v "$(pwd)/$(dirname $0):/test:ro" "${IMAGE_NAME}" 2>&1 | tee $LOGS_TEMPFILE

test -f $LOGS_TEMPFILE

assert_logs_contains "errorCount" # we have stats
assert_logs_contains "errorPct"
assert_logs_contains "pct1ResTime"
assert_logs_contains "... end of run" # jmeter was executed

echo "done"