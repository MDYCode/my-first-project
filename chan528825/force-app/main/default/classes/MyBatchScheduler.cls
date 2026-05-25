global class MyBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchRunStatus__c status = BatchRunStatus__c.getOrgDefaults();
        Date today = Date.today();
        Boolean isDone = (status != null && status.RunDate__c == today && status.IsSuccessful__c);

        if (!isDone) {
            Integer hour = DateTime.now().hour();
            if (hour < 23) {
                Database.executeBatch(new MyBatchJob(), 200);
            }
        }
    }
}