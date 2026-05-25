public class AccountTriggerHandler {

    // Set default Rating = "Warm" if not filled
    public static void setDefaultRating(List<Account> newAccounts) {
        for (Account acc : newAccounts) {
            if (String.isBlank(acc.Rating)) {
                acc.Rating = 'Warm';
                System.debug('Set default rating "Warm" for Account: ' + acc.Name);
            }
        }
    }

    // Append "様" to the end of Name on before insert/update (avoid duplicate/apply only when Name has non-blank)
    public static void appendSamaToName(List<Account> newRecords, Map<Id, Account> oldMap) {
        for (Account acc : newRecords) {
            if (String.isBlank(acc.Name)) {
                continue;
            }
            String currentName = acc.Name;
            if (currentName.endsWith('様')) {
                continue;
            }
            acc.Name = currentName + '様';
        }
    }

    // Prevent changing Name if Rating is "Hot"
    public static void preventNameChangeForHotAccounts(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        for (Id accId : newMap.keySet()) {
            Account oldAcc = oldMap.get(accId);
            Account newAcc = newMap.get(accId);

            if (oldAcc.Rating == 'Hot' && oldAcc.Name != newAcc.Name) {
                System.debug('Name change blocked for HOT Account: ' + newAcc.Id);
                newAcc.Name = oldAcc.Name;
                newAcc.addError('Cannot change Account Name when Rating is "Hot".');
            }
        }
    }

    // Create Task to follow up on new Accounts
    public static void createFollowUpTasks(List<Account> newAccounts) {
        List<Task> tasksToInsert = new List<Task>();

        for (Account acc : newAccounts) {
            Task followUp = new Task(
                WhatId = acc.Id,
                Subject = 'Follow up with new account',
                ActivityDate = Date.today().addDays(3),
                Status = 'Not Started',
                Priority = 'Normal'
            );
            tasksToInsert.add(followUp);
            System.debug('Created follow-up task for Account: ' + acc.Name);
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
            System.debug('Inserted ' + tasksToInsert.size() + ' follow-up tasks.');
        }
    }

    // Log changes if Industry or Rating changed
    public static void logChanges(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        List<Account_Log__c> logsToInsert = new List<Account_Log__c>();

        for (Id accId : newMap.keySet()) {
            Account oldAcc = oldMap.get(accId);
            Account newAcc = newMap.get(accId);

            String changes = '';
            if (oldAcc.Industry != newAcc.Industry) {
                changes += 'Industry changed from "' + oldAcc.Industry + '" to "' + newAcc.Industry + '". ';
            }
            if (oldAcc.Rating != newAcc.Rating) {
                changes += 'Rating changed from "' + oldAcc.Rating + '" to "' + newAcc.Rating + '". ';
            }

            if (!String.isBlank(changes)) {
                logsToInsert.add(new Account_Log__c(
                    Account__c = accId,
                    Change_Details__c = changes,
                    Changed_On__c = DateTime.now()
                ));
                System.debug('Logging change for Account: ' + accId + ' -> ' + changes);
            }
        }

        if (!logsToInsert.isEmpty()) {
            insert logsToInsert;
            System.debug('Inserted ' + logsToInsert.size() + ' account logs.');
        }
    }
}