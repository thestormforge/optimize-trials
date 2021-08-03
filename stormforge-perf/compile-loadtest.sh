#!/bin/bash

output_path="$1"

# If there is no test case file, just get the current version from the server
if [ ! -f "${TEST_CASE_FILE}" ]; then
	forge test-case get "${TEST_CASE}" "${output_path}"
	exit $?
fi


# Include a DO-NO-EDIT disclaimer
cat <<EOF > "${output_path}"
/*
 * NOTICE: DO NOT EDIT!
 *
 * This file is managed via https://github.com/thestormforge/optimize-trials
 */

EOF


# Set the target based on the environment variable
if [ -n "${TARGET}" ]; then
	cat <<-EOF >> "${output_path}"
	const \$target = "${TARGET}";

	EOF
fi


# Add the actual test case script
cat "${TEST_CASE_FILE}" >> "${output_path}"


# Ensure the test case exists on the server
forge test-case create --update "${TEST_CASE}" "${output_path}"
