#!/bin/bash -e

CHECK_DIRECTORY="$1"

if [ ! -d "${CHECK_DIRECTORY}" ]; then
    echo "Not a valid directory: ${CHECK_DIRECTORY}"
    exit 1
fi

files_found=$(find "${CHECK_DIRECTORY}" -ctime -1 -type f ! -empty)

if [ "${files_found}" = "" ]; then
    echo "No new files found in ${CHECK_DIRECTORY}"
    exit 1
fi

echo "New files found: ${files_found}"
exit 0
