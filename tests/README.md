# Platform demo projects automated tests runner

Tests runner is a bash script implemented to run platform demo tests.
Tests just launch the project and look log for appropriate messages.

Script is running all tests by default.
Script is packaging the whole project by default

Usage: ./run-tests.sh [OPTIONS]

Options:

  -h           print usage help and exit the scipt

  -p  boolean  enables or disables whole project packaging. Default is true

  -t  list     coma separated list of tests. Test case name is equal to project name. Example of test cases: "road-traffic-predictor,tensorflow". Default value is "all"