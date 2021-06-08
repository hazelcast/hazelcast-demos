package com.hazelcast.qe;

public class TestResult {
    private Boolean passed  = false;
    private String reason = "";

    public Boolean getPassed() {
        return passed;
    }

    public void setPassed(Boolean passed) {
        this.passed = passed;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }
}
