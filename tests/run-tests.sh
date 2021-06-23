#!/bin/bash
#including libs
. demo-util-lib.sh
. test-cases-lib.sh

export HZ_VERSION=5.0-SNAPSHOT
export TEST_CASES=all
export PACK_JARS=true
export PRINT_USAGE=false

#parsing command line arguments
while getopts t:hp: flag; do

  case "${flag}" in
  t) TEST_CASES=${OPTARG} ;;
  h) PRINT_USAGE='true' ;;
  p) PACK_JARS=${OPTARG} ;;
  esac
done

#just print usage help and exit if -h option is passed
if ${PRINT_USAGE}; then
  print_usage_help_exit
fi

echo "Staring automated testing of platform demos"

#exort demo root to simplify navigation
cd ..
declare -r DEMO_ROOT=$(pwd)

#pack the whole project if packaging is not disabled (-p option)
if ${PACK_JARS}; then
  echo "Packaging all demo projects"
  cd ${DEMO_ROOT}
  mvn clean package -U -B -DskipTests=true
  echo "All artifacts have been successfully built"
fi

#running tests for specified project (each test is identified by project name)
#test case is initiated by calling TEST_${project_name} function
#each test case function takes $DEMO_ROOT as a 1-st parameter and (optionally) $HZ_VERSION as a second one
IFS=',' read -ra TCS <<<"$TEST_CASES"
for project_name in "${TCS[@]}"; do
  #  calling test case functions from test-cases-lib.sh
  TEST_${project_name} $DEMO_ROOT $HZ_VERSION

done
