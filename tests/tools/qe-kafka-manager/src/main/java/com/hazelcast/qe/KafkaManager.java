package com.hazelcast.qe;

import kafka.admin.RackAwareMode;
import kafka.server.KafkaConfig;
import kafka.server.KafkaServer;
import kafka.utils.MockTime;
import kafka.utils.TestUtils;
import kafka.utils.ZKStringSerializer$;
import kafka.utils.ZkUtils;
import kafka.zk.EmbeddedZookeeper;
import org.I0Itec.zkclient.ZkClient;
import org.apache.kafka.common.utils.Time;

import java.io.IOException;
import java.nio.file.Files;
import java.util.Properties;

import static kafka.admin.AdminUtils.createTopic;

public class KafkaManager {
    private EmbeddedZookeeper zkServer;
    private ZkUtils zkUtils;
    private KafkaServer kafkaServer;

    public static void main(String[] args) throws IOException {
        KafkaManager manager = new KafkaManager();

        if(System.getenv().containsKey("kafkaTopic"))
            manager.runClusterCreateTopic(System.getProperty("kafkaTopic"));
        else
            manager.runCluster();

    }

    public void runCluster() throws IOException {
        createKafkaCluster();
    }

    public void runClusterCreateTopic(String topic) throws IOException {
        createKafkaCluster();
        createTopic(zkUtils, topic, 32, 1, new Properties(), RackAwareMode.Disabled$.MODULE$);
        System.out.println("************ Kafka: topic "+topic+" has been created ************");


    }

    private void createKafkaCluster() throws IOException {
        System.out.println("************ Starting Kafka service ************");

        zkServer = new EmbeddedZookeeper();
        String zkConnect = "localhost:" + zkServer.port();
        ZkClient zkClient = new ZkClient(zkConnect, 30000, 30000, ZKStringSerializer$.MODULE$);
        zkUtils = ZkUtils.apply(zkClient, false);

        KafkaConfig config = new KafkaConfig(props(
                "zookeeper.connect", zkConnect,
                "broker.id", "0",
                "log.dirs", Files.createTempDirectory("kafka-").toAbsolutePath().toString(),
                "offsets.topic.replication.factor", "1",
                "listeners", "PLAINTEXT://localhost:9092"));
        Time mock = new MockTime();
        kafkaServer = TestUtils.createServer(config, mock);
        System.out.println("************ Kafka service is started ************");

    }

    private static Properties props(String... kvs) {
        final Properties props = new Properties();
        for (int i = 0; i < kvs.length;) {
            props.setProperty(kvs[i++], kvs[i++]);
        }
        return props;
    }
}
