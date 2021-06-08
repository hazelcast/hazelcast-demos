package com.hazelcast.qe.util;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class Locker {
    private Lock lock = new ReentrantLock();
    private Condition condition = lock.newCondition();


    public void lock(long timeout, TimeUnit timeUnit) {
        lock.lock();
        try {
            if (timeout != 0)
                condition.await(timeout, timeUnit);
            else
                condition.await();
        } catch (InterruptedException e) {
            System.out.println(e.getMessage());
        }
        lock.unlock();
    }

    public void unlock() {
        lock.lock();
        condition.signal();
        lock.unlock();
    }

}
