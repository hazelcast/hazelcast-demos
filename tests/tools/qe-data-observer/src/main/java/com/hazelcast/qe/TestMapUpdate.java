package com.hazelcast.qe;

import com.hazelcast.client.HazelcastClient;
import com.hazelcast.client.config.ClientConfig;
import com.hazelcast.client.config.ClientConnectionStrategyConfig;
import com.hazelcast.client.config.ConnectionRetryConfig;
import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.map.IMap;

public class TestMapUpdate {
    public static void main(String[] args) throws Exception {
        if(args.length!=2){
            System.out.println("Usage: java -jar qe-data-observer-5.0-SNAPSHOT-jar-with-dependencies.jar CLUSTER_NAME  MAP_NAME");
            System.exit(1);
        }

        boolean testResult = false;
        String clusterName = args[0];
        String mapName = args[1];

        System.out.println(">>>>>>>>> Verifying updates of "+mapName+" map in "+clusterName+" cluster <<<<<<<<");

        ClientConfig clientConfig = new ClientConfig();
        clientConfig.setClusterName(clusterName);
        ClientConnectionStrategyConfig connectionStrategyConfig = clientConfig.getConnectionStrategyConfig();
        ConnectionRetryConfig connectionRetryConfig = connectionStrategyConfig.getConnectionRetryConfig();
        connectionRetryConfig.setClusterConnectTimeoutMillis(20000);

        HazelcastInstance hzInstance = HazelcastClient.newHazelcastClient(clientConfig);
        IMap<Object, Object> observableMap = hzInstance.getMap(mapName);
        int initialSize = observableMap.size();

        int i = 0;
        while (i < 20){
            Thread.sleep(10000);
            if(observableMap.size() > initialSize){
                testResult = true;
                break;
            }
            i++;
        }
        hzInstance.shutdown();

        if(testResult){
            System.out.println(">>>>>>>>> Test passed <<<<<<<<");
        }else {
            System.out.println(">>>>>>>>> Test failed wait for updates after 200 second <<<<<<<<");
            System.exit(1);
        }

    }
}
