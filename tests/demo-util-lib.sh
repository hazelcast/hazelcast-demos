#!/bin/bash

function check_text_in_log() {
  local log_file=$1
  EXPECTED_TEXT=$2
  EXPECTED_COUNT=${3:-1}
  echo "Checking log for '${EXPECTED_TEXT}'"
  EXPECTED_TEXT_COUNT=$(grep "${EXPECTED_TEXT}" ${log_file} | wc -l)
  if [ ${EXPECTED_TEXT_COUNT} -ne ${EXPECTED_COUNT} ]; then
    echo "Unexpected count of '${EXPECTED_TEXT}' has not been found in output log. Expected: ${EXPECTED_COUNT} was: ${EXPECTED_TEXT_COUNT}"
    exit 1
  fi
}
function print_usage_help_exit() {
  echo "Platform demos automated tests runner"
  echo "Usage: ./run-tests.sh [OPTIONS]"
  echo "Options:"
  echo "  -h           print usage help and exit the scipt"
  echo "  -p  boolean  enables or disables whole project packaging. Default is true"
  echo "  -t  list     coma separated list of tests. Test case name is equal to project name. Default value is ALL"

  exit
}
