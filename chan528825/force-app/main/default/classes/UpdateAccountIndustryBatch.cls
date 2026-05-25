global class UpdateAccountIndustryBatch implements Database.Batchable<SObject> {

    // 1. Start method — defines the query
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Industry FROM Account WHERE Industry = NULL'
        );
    }

    // 2. Execute method — processes each batch of records
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        for (Account acc : scope) {
            acc.Industry = 'Technology';
        }
        update scope;
        System.debug('Updated batch of ' + scope.size() + ' Accounts.');
    }

    // 3. Finish method — optional post-processing
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch Finished!');
    }
}