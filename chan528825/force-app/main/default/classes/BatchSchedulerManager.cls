public class BatchSchedulerManager {
    public static void unscheduleJobs() {
        List<String> jobNames = new List<String>{ 'DailyStartBatch', 'RetryBatchAtHourStart', 'RetryBatchAtHourHalf' };
        for (CronTrigger ct : [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name IN :jobNames]) {
            System.abortJob(ct.Id);
        }
    }
}