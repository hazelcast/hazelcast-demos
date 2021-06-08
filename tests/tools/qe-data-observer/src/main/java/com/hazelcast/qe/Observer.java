package com.hazelcast.qe;

import com.hazelcast.client.HazelcastClient;
import com.hazelcast.client.config.ClientConfig;
import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.map.IMap;
import com.hazelcast.map.listener.MapListener;
import com.hazelcast.qe.listener.AddEntryEventListener;
import com.hazelcast.qe.listener.UpdateEntryEventListener;
import com.hazelcast.qe.util.Locker;

import java.util.concurrent.TimeUnit;

public class Observer {
    String mapName;
    String observeOperation;
    String clusterName;
    Long timeout;
    Integer eventsNumber;
    Locker locker;
    HazelcastInstance hzInstance;
    TestResult testResult = new TestResult();

    public Observer(String mapName, String observeOperation, String clusterName, Long timeout, Integer eventsNumber) {
        this.mapName = mapName;
        this.observeOperation = observeOperation;
        this.clusterName = clusterName;
        this.timeout = timeout;
        this.eventsNumber = eventsNumber;
    }

    public void observe() throws Exception {
        ClientConfig clientConfig = new ClientConfig();
        clientConfig.setClusterName(clusterName);

        hzInstance = HazelcastClient.newHazelcastClient(clientConfig);
        locker = new Locker();
        IMap observableMap = hzInstance.getMap(mapName);
        MapListener listener = getListener();
        observableMap.addEntryListener(listener, true);
        locker.lock(timeout, TimeUnit.MILLISECONDS);
        hzInstance.shutdown();

        verifyTestResult();

    }

    private void verifyTestResult() throws Exception {
        if (!testResult.getPassed())
            throw new Exception(testResult.getReason());
        else
            System.out.println("************ Test passed ************");
    }

    private MapListener getListener() throws Exception {
        MapListener listener;

        switch (observeOperation) {
            case "update":
                listener = new UpdateEntryEventListener(eventsNumber, locker, testResult);
                break;
            case "add":
                listener = new AddEntryEventListener(eventsNumber, locker, testResult);
                break;
            default:
                throw new Exception("Unknown operation type: " + observeOperation);

        }

        return listener;
    }
}
