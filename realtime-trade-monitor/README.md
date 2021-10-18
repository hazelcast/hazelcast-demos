# Real-time Trade Monitor

A sample dashboard which uses [Hazelcast](https://github.com/hazelcast/hazelcast)
to ingest trades from Apache Kafka into a distributed map. It also performs
an aggregation on the trades, storing the results into a separate map.

These two maps are utilized by a live dashboard which offers drill down
functionality into viewing individual trades that make up the aggregation.

## How to run:

1. Build the project

```
mvn package
```

1. Create a topic on the Kafka cluster:

```
kafka-topics --create --replication-factor 1 --partitions 4 --topic trades --zookeeper localhost:2181
```

2. Start the Kafka producer

```
java -jar trade-producer/target/trade-producer-5.0.jar <bootstrap servers> <trades per sec>
```

3. Start the Jet cluster. To configure cluster members you can edit 
`hazelcast.yaml` in the `jet-server/src/main/resources` folder.

```
java -jar jet-server/target/jet-server-5.0.jar
```

4. Run the queries

The cluster connection can be configured inside the `hazelcast-client.yaml` file.

* Load static data into map: (Stock names)
```
java -jar trade-queries/target/trade-queries-5.0.jar load-symbols
```

* Ingest trades from Kafka

```
java -jar trade-queries/target/trade-queries-5.0.jar ingest-trades <bootstrap servers>
```
* Aggregate trades by symbol
```
java -jar trade-queries/target/trade-queries-5.0.jar aggregate-query <bootstrap servers>
```

5. Start the front end

The cluster connection can be configured inside the `hazelcast-client.yaml` file.

```
java -jar webapp/target/webapp-5.0.jar 
```

Browse to localhost:9000 to see the dashboard.

## How to run using Hazelcast Cloud:

1. Create Enterprise Hazelcast cluster in https://cloud.hazelcast.com/

2. Open client configuration window on the cluster details page and grab cluster id and discovery token. 

3. Modify Hazelcast client configs `trade-queries/src/main/resources/hazelcast-client.yaml` and
   `webapp/src/main/resources/hazelcast-client.yaml` 
   by putting there cluster id and discovery token from previous step. Minimal working config example:
```
hazelcast-client:
  cluster-name: <CLUSTER_NAME>
  instance-name: query-client
  properties:
    hazelcast.client.cloud.url: "https://uat.hazelcast.cloud" #Optional, if env is not default
    hazelcast.client.cloud.discovery.token: "<CLUSTER_TOKEN>"
```    

4. We need to have Kafka cluster that is reachable by Hazalcast Cloud nodes. For demo purposes, the easiest way is
   to create the simplest Kafka cluster at https://confluent.cloud with defaults.

5. Create topic `trades`. If you use https://confluent.cloud go to Topics section in the UI.


6. Put all kafka consumer/producer properties in `trade-producer/src/main/resources/kafka.properties` and
   `trade-queries/src/main/resources/kafka.properties`. If you use https://confluent.cloud you can find them in
   Data Integration - Client - New Client section.

8. Build the project

```
mvn package
```

8. Start the Kafka producer

```
java -jar trade-producer/target/trade-producer-5.0.jar "" <trades per sec>
```

9. Run the queries

* Load static data into map: (Stock names)
```
java -jar trade-queries/target/trade-queries-5.0.jar load-symbols
```

* Ingest trades from Kafka

```
java -jar trade-queries/target/trade-queries-5.0.jar ingest-trades ""
```
* Aggregate trades by symbol
```
java -jar trade-queries/target/trade-queries-5.0.jar aggregate-query ""
```

5. Start the front end

```
java -jar webapp/target/webapp-5.0.jar 
```

Browse to localhost:9000 to see the dashboard.
