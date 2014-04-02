#!/bin/bash -e

# See http://sensuapp.org/docs/0.12/checks
#
# exit code  = 0 : OK
# exit code  = 1 : WARNING
# exit code  = 2 : CRITICAL
# exit code >= 3 : UNKNOWN

CHECK_DIRECTORY="$1"

if [ ! -d "${CHECK_DIRECTORY}" ]; then
    echo "Error checking directory (doesn't exit): ${CHECK_DIRECTORY}"
    exit 2
fi

files_found=$(find "${CHECK_DIRECTORY}" -mtime -1.125 -type f ! -empty)

if [ "${files_found}" = "" ]; then
    echo "No new files found in ${CHECK_DIRECTORY}"
    exit 2
fi

echo "OK, new files found: ${files_found}"
exit 0
