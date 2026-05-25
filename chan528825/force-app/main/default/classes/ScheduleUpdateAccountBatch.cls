global class ScheduleUpdateAccountBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
        UpdateAccountIndustryBatch batch = new UpdateAccountIndustryBatch();
        Database.executeBatch(batch, 200);
    }
}