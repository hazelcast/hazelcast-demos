package com.hazelcast.qe.listener;

import com.hazelcast.core.EntryEvent;
import com.hazelcast.core.HazelcastJsonValue;
import com.hazelcast.map.listener.EntryAddedListener;
import com.hazelcast.qe.TestResult;
import com.hazelcast.qe.util.Locker;

public class AddEntryEventListener implements EntryAddedListener<String, HazelcastJsonValue> {
    private Locker locker;
    private Integer expectedNumOfUpdates = 0;
    private Integer actualUpdates = 0;
    private TestResult testResult;
    public AddEntryEventListener(Integer expectedNumOfUpdates, Locker locker, TestResult testResult) {
        this.expectedNumOfUpdates = expectedNumOfUpdates;
        this.locker = locker;
        this.testResult = testResult;

//        setting timeout reason in advance
        this.testResult.setReason("Failed wait for "+expectedNumOfUpdates+" updates");
    }



    @Override
    public void entryAdded(EntryEvent<String, HazelcastJsonValue> entryEvent) {
        System.out.println("************ Value is updated ************");
        actualUpdates ++;
        if (actualUpdates.equals(expectedNumOfUpdates)){
            locker.unlock();
            testResult.setPassed(true);
        }

    }

}
