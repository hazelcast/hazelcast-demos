# Real-time Trade Monitor

A sample dashboard which uses [Hazelcast Demos](https://github.com/hazelcast/hazelcast-demos)
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
java -jar trade-producer/target/trade-producer-5.0-SNAPSHOT.jar <bootstrap servers> <trades per sec>
```

3. Start the Jet cluster. To configure cluster members you can edit 
`hazelcast.yaml` in the `jet-server/src/main/resources` folder.

```
java -jar jet-server/target/jet-server-5.0-SNAPSHOT.jar
```

4. Run the queries

The cluster connection can be configured inside the `hazelcast-client.yaml` file.

* Load static data into map: (Stock names)
```
java -jar trade-queries/target/trade-queries-5.0-SNAPSHOT.jar load-symbols
```

* Ingest trades from Kafka

```
java -jar trade-queries/target/trade-queries-5.0-SNAPSHOT.jar ingest-trades <bootstrap servers>
```
* Aggregate trades by symbol
```
java -jar trade-queries/target/trade-queries-5.0-SNAPSHOT.jar aggregate-query <bootstrap servers>
```

5. Start the front end

The cluster connection can be configured inside the `hazelcast-client.yaml` file.

```
java -jar webapp/target/webapp-5.0-SNAPSHOT.jar 
```

Browse to localhost:9000 to see the dashboard.
