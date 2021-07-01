#!/bin/bash

function TEST_all() {
  local demo_root=$1
  local hz_version=$2
  local flight_telemetry_api_key=$3

  TEST_h2o-breast-cancer-classification $demo_root
  TEST_markov-chain-generator $demo_root
  TEST_road-traffic-predictor $demo_root
  TEST_tensorflow $demo_root
  TEST_realtime-trade-monitor $demo_root $hz_version
  TEST_flight-telemetry $demo_root $hz_version $flight_telemetry_api_key
}

function TEST_flight-telemetry() {
  echo "********** START TEST: flight-telemetry **********"
  local demo_root=$1
  local hzVersion=$2
  local api_key=$3
  local log_file=flight-telemetry.txt
  local pause=20

  echo "********** Start flight-telemetry project with 200 sec timeout **********"
  cd $demo_root/flight-telemetry || exit 1
  make up
  sleep $pause
  timeout 200 mvn exec:java -Dtelemetry.api.key=${api_key} -U -B | tee ${log_file}&
  sleep $pause

  echo "********** Launch data-observer to make sure landingMap is being updated by job **********"
  cd $demo_root/tests/tools/qe-data-observer/target || exit 1
  java -jar qe-data-observer-${hzVersion}-jar-with-dependencies.jar FlightTelemetry landingMap
  local TEST_RESULT=$?

  #  cleaning up the environment - killing all launched processes
  echo "********** Killing flight-telemetry processes **********"
  kill $(ps aux | grep '[f]light-telemetry' | awk '{print $2}')
  cd $demo_root/flight-telemetry || exit 1
  make down

  if [ "$TEST_RESULT" != "0" ]
  then
     echo "**********flight-telemetry: Test failed with code ${TEST_RESULT}! **********"
     #exiting if failed to be consistent with other test cases, this will be refactored in the future
     exit 1
  fi

  echo "**********flight-telemetry: Test passed **********"
  echo "********** END TEST: flight-telemetry **********"
}

function TEST_h2o-breast-cancer-classification() {
  echo "********** START TEST: h2o-breast-cancer-classification **********"

  local demo_root=$1
  local log_file=h2o-breast-cancer-classification-log.txt

  cd $demo_root/h2o-breast-cancer-classification || exit 1
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

  cd $demo_root/markov-chain-generator || exit 1
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

  cd $demo_root/road-traffic-predictor || exit 1
  mvn exec:java -U -B -DskipTests=true | tee ${log_file}

  echo "road-traffic-predictor: verifying messages in log"
  check_text_in_log $log_file "Start executing job"
  check_text_in_log $log_file "digraph DAG"
  check_text_in_log $log_file "completed successfully"
  echo "road-traffic-predictor: log messages successfully verified"

  echo "********** END TEST: road-traffic-predictor **********"

}

function TEST_realtime-trade-monitor() {
  echo "********** START TEST: realtime-trade-monitor **********"

  local demo_root=$1
  local hzVersion=$2
  local timeout=200
  local pause=20
  local log_file=realtime-trade-monitor-log.txt

  echo "---------- realtime-trade-monitor: preparing env - starting kafka service and creating \"trades\" topic"
  cd $demo_root/tests/tools/qe-kafka-manager || exit 1
  timeout $timeout mvn exec:java -DkafkaTopic=trades&
  sleep $pause

  echo "---------- realtime-trade-monitor: preparing env - starting trades producer"
  cd $demo_root/realtime-trade-monitor || exit 1
  timeout $timeout java -jar trade-producer/target/trade-producer-${hzVersion}.jar 127.0.0.1:9092 5 | tee ${log_file}&
  sleep $pause

  echo "---------- realtime-trade-monitor: starting jet server"
  timeout $timeout java -jar jet-server/target/jet-server-${hzVersion}.jar | tee ${log_file}&
  sleep $pause

  echo "---------- realtime-trade-monitor: starting jet jobs to ingest and aggregate trades"
  java -jar trade-queries/target/trade-queries-${hzVersion}.jar load-symbols | tee ${log_file}
  sleep $pause
  java -jar trade-queries/target/trade-queries-${hzVersion}.jar ingest-trades 127.0.0.1:9092 | tee ${log_file}
  sleep $pause
  java -jar trade-queries/target/trade-queries-${hzVersion}.jar aggregate-query 127.0.0.1:9092 | tee ${log_file}
  sleep $pause

  echo "********** Launch data-observer to make sure query1_Results is being updated by job **********"
  cd $demo_root/tests/tools/qe-data-observer/target || exit 1
  java -jar qe-data-observer-${hzVersion}-jar-with-dependencies.jar jet query1_Results
  local TEST_RESULT=$?

  #  cleaning up the environment - killing all launched processes
  echo "********** Killing Kafka processes **********"
  kill $(ps aux | grep '[e]xec:java -DkafkaTopic=trades' | awk '{print $2}')
  echo "********** Killing Producer processes **********"
  kill $(ps aux | grep '[t]rade-producer/target/trade-producer-' | awk '{print $2}')
  echo "********** Killing Jet Server processes **********"
  kill $(ps aux | grep '[j]et-server/target/jet-server-' | awk '{print $2}')

  if [ "$TEST_RESULT" != "0" ]
  then
     echo "**********realtime-trade-monitor: Test failed with code ${TEST_RESULT}! **********"
     #exiting if failed to be consistent with other test cases, this will be refactored in the future
     exit 1
  fi

  echo "**********realtime-trade-monitor: Test passed **********"
  echo "********** END TEST: realtime-trade-monitor **********"
}

function TEST_tensorflow() {
  echo "********** START TEST: tensorflow **********"

  local demo_root=$1
  local log_file=tensorflow.txt

  cd $demo_root/tensorflow || exit 1
  mvn compile exec:java -Dexec.mainClass=InProcessClassification -Dexec.args="data" -U -B -DskipTests=true | tee ${log_file}

  echo "tensorflow: verifying messages in log"
  check_text_in_log $log_file "Start execution of job"
  check_text_in_log $log_file "had both good and bad parts"
  check_text_in_log $log_file "is 0.48"
  echo "tensorflow: log messages successfully verified"

  echo "********** END TEST: tensorflow **********"

}
