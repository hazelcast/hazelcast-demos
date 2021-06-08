#!/bin/bash

function TEST_all() {
  local demo_root=$1

  TEST_h2o-breast-cancer-classification $demo_root
  TEST_markov-chain-generator $demo_root
  TEST_road-traffic-predictor $demo_root
  TEST_tensorflow $demo_root
}

function TEST_flight-telemetry() {
  echo "********** START TEST: flight-telemetry **********"
  local demo_root=$1
  local log_file=flight-telemetry.txt

  echo "********** Start flight-telemetry project with 200 sec timeout **********"
  cd $demo_root/flight-telemetry
  timeout 200 mvn exec:java -U -B -DskipTests=true | tee ${log_file}&

  echo "********** Launch data-observer to make sure landingMap is being updated by job **********"
  cd $demo_root/tests/tools/qe-data-observer
  timeout 200 mvn exec:java -DmapName=landingMap -DclusterName=FlightTelemetry -DobserveOperation=update

  echo "********** END TEST: flight-telemetry **********"
}

function TEST_h2o-breast-cancer-classification() {
  echo "********** START TEST: h2o-breast-cancer-classification **********"

  local demo_root=$1
  local log_file=h2o-breast-cancer-classification-log.txt

  cd $demo_root/h2o-breast-cancer-classification
  mvn exec:java -U -B -DskipTests=true | tee ${log_file}

  echo "h2o-breast-cancer-classification: verifying messages in log"
  check_text_in_log $log_file "Start execution of job"
  check_text_in_log $log_file "Read from CSV input file" 2
  check_text_in_log $log_file "BENIGN              0.9997749358618557"
  echo "h2o-breast-cancer-classification: log messages successfully verified"

  echo "********** END TEST: h2o-breast-cancer-classification **********"

}

function TEST_markov-chain-generator() {
  echo "********** START TEST: markov-chain-generator **********"

  local demo_root=$1
  local log_file=markov-chain-generator-log.txt

  cd $demo_root/markov-chain-generator
  mvn exec:java -U -B -DskipTests=true | tee ${log_file}

  echo "markov-chain-generator: verifying messages in log"
  check_text_in_log $log_file "0.3333     | hanging "
  check_text_in_log $log_file "Generating model..."
  check_text_in_log $log_file "ransitions for: tubbes"
  echo "markov-chain-generator: log messages successfully verified"

  echo "********** END TEST: markov-chain-generator **********"

}

function TEST_realtime-image-recognition() {
  echo "********** TEST NOT IMPLEMENTED YET: realtime-image-recognition **********"

}

function TEST_road-traffic-predictor() {
  echo "********** START TEST: road-traffic-predictor **********"

  local demo_root=$1
  local log_file=road-traffic-predictor-log.txt

  cd $demo_root/road-traffic-predictor
  mvn exec:java -U -B -DskipTests=true | tee ${log_file}

  echo "road-traffic-predictor: verifying messages in log"
  check_text_in_log $log_file "Start executing job"
  check_text_in_log $log_file "digraph DAG"
  check_text_in_log $log_file "completed successfully"
  echo "road-traffic-predictor: log messages successfully verified"

  echo "********** END TEST: road-traffic-predictor **********"

}

function TEST_tensorflow() {
  echo "********** START TEST: tensorflow **********"

  local demo_root=$1
  local log_file=tensorflow.txt

  cd $demo_root/tensorflow
  mvn compile exec:java -Dexec.mainClass=InProcessClassification -Dexec.args="data" -U -B -DskipTests=true | tee ${log_file}

  echo "tensorflow: verifying messages in log"
  check_text_in_log $log_file "Start execution of job"
  check_text_in_log $log_file "had both good and bad parts"
  check_text_in_log $log_file "is 0.48"
  echo "tensorflow: log messages successfully verified"

  echo "********** END TEST: tensorflow **********"

}
