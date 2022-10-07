#!/bin/sh
set -e

if [ -z "${LOADRUNNER_CLOUD_CONNECT}" ]; then
  echo "Missing LOADRUNNER_CLOUD_CONNECT"
  exit 1
fi

if [ -z "${LOADRUNNER_CLOUD_HOST}" ]; then
  echo "Missing LOADRUNNER_CLOUD_HOST"
  exit 1
fi

if [ -z "${LOADRUNNER_CLOUD_TENANTID}" ]; then
  echo "Missing LOADRUNNER_CLOUD_TENANTID"
  exit 1
fi

if [ -z "${LOADRUNNER_CLOUD_TESTID}" ]; then
  echo "Missing LOADRUNNER_CLOUD_TESTID"
  exit 1
fi

cli () {
    java -jar /loadrunner/jar/cli.jar \
        "$1" \
        "testId=${LOADRUNNER_CLOUD_TESTID}" \
        "connect=${LOADRUNNER_CLOUD_CONNECT}" \
        sendEmail=False
}

# https://admhelp.microfocus.com/lrc/en/2022.06/Content/Storm/t_cli_tools.htm
cli "runWithResult"

# FIXME: for status and getResult we need a "runId", not sure how to get it yet
cli "status"
cli "getResult"

