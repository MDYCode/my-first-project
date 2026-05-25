global class MyBatchJob implements Database.Batchable<SObject>, Database.Stateful {
    global Integer processed = 0;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Some_Field__c FROM Contact WHERE Some_Field__c = 'Pending'
        ]);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Contact> contactsToUpdate = new List<Contact>();
        for (SObject s : scope) {
            Contact c = (Contact) s;
            c.Some_Field__c = 'Processed';
            contactsToUpdate.add(c);
        }
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
            processed += contactsToUpdate.size();
        }
    }

    global void finish(Database.BatchableContext bc) {
        Integer remaining = [SELECT COUNT() FROM Contact WHERE Some_Field__c = 'Pending'];

        BatchRunStatus__c status = BatchRunStatus__c.getOrgDefaults();
        if (status == null) {
            status = new BatchRunStatus__c();
        }
        status.RunDate__c = Date.today();
        status.IsSuccessful__c = (remaining == 0);
        upsert status;
    }
}