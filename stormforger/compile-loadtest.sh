#!/bin/bash

# If there is no test case file, just get the current version from the server
if [ ! -f "${TESTCASEFILE}" ]; then
	forge test-case get "${TESTCASE}"
	exit $?
fi


# Include a DO-NO-EDIT disclaimer
cat <<EOF
/*
 * NOTICE: DO NOT EDIT!
 *
 * This file is managed via https://github.com/redskyops/trial-jobs
 */

EOF


# Set the target based on the environment variable
if [ -n "${TARGET}" ]; then
	cat <<-EOF
	const $target = "${TARGET}"
	
	EOF
fi


# Add the actual test case script
cat "${TESTCASEFILE}"
