package com.hazelcast.qe;

import java.util.ArrayList;


public class Runner {
    private static final ArrayList<String> operations = new ArrayList<String>(){{
        add("update");
        add("add");
    }};

    public static void main(String[] args) throws Exception {
        if(!System.getProperties().containsKey("mapName")){
            printUsage();
            System.exit(1);
        }
        if(!System.getProperties().containsKey("observeOperation")){
            printUsage();
            System.exit(1);
        }
        String mapName = System.getProperty("mapName");
        String observeOperation = System.getProperty("observeOperation");
        String clusterName = System.getProperty("clusterName", "jet");
        Long timeout = Long.valueOf(System.getProperty("observeTimeout", "50000"));
        Integer eventsNumber = Integer.valueOf(System.getProperty("eventsNumber", "5"));

        if(!operations.contains(observeOperation)){
            printUsage();
            System.exit(1);
        }

        System.out.println("************ Verification of map "+mapName+" under "+clusterName+" cluster ************");
        System.out.println("************ Test parameters: test type: "+observeOperation+" timeout: "+timeout+" ms, number of events: "+eventsNumber);

        Observer observer = new Observer(mapName,
                observeOperation,
                clusterName,
                timeout,
                eventsNumber);
        observer.observe();
    }

    private static void printUsage(){
        System.out.println("Please specify mandatory parameters:");
        System.out.println("[MANDATORY] -DmapName=MAP_TO_OBSERVE");
        System.out.println("[MANDATORY] -DobserveOperation=OPERATIN   possible values: add, update");
        System.out.println("-DclusterName=CLUSTER_NAME   default: jet");
        System.out.println("-DobserveTimeout=TIMEOUT_MS   default: 50000");
        System.out.println("-DeventsNumber=NUMBER_OF_EVENTS   default: 5");


    }
}
