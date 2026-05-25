@isTest
private class AccountTriggerTest {

    @isTest
    static void testAccountTriggerFlow() {
        // Step 1: Insert account (before insert will set default rating and append 様)
        Account acc = new Account(Name = 'Test Corp');
        insert acc;
        System.debug('Inserted Account Id: ' + acc.Id);

        // Verify 様 appended and Rating defaulted
        acc = [SELECT Id, Name, Rating FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Test Corp様', acc.Name, 'Name should end with 様 after insert');
        System.assertEquals('Warm', acc.Rating, 'Default rating should be Warm when blank');

        // Step 2: Update account with Rating = Hot and Industry (Name should not get extra 様)
        acc.Rating = 'Hot';
        acc.Industry = 'Technology';
        update acc;
        System.debug('Updated Account to Rating=Hot');

        acc = [SELECT Id, Name, Rating FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Test Corp様', acc.Name, 'Name should not duplicate 様 on update');

        // Step 3: Try to change name (should fail due to trigger validation)
        acc.Name = 'New Name';
        try {
            update acc;
            System.assert(false, 'Expected error was not thrown.');
        } catch (DmlException e) {
            System.debug('Caught expected exception: ' + e.getMessage());
            System.assert(e.getMessage().contains('Cannot change Account Name when Rating is "Hot".'));
        }

        // Step 4: Reload fresh Account and change Rating to Warm, and update Name without 様 to ensure it gets appended once
        acc = [SELECT Id, Name, Rating FROM Account WHERE Id = :acc.Id];
        acc.Rating = 'Warm';
        acc.Name = 'Another Corp'; // will be appended with 様 in before update
        update acc;
        System.debug('Updated Account Rating to Warm and Name');

        acc = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Another Corp様', acc.Name, 'Name should end with 様 after update');

        // Step 5: Check if log was created
        List<Account_Log__c> logs = [
            SELECT Id, Change_Details__c 
            FROM Account_Log__c 
            WHERE Account__c = :acc.Id
        ];
        System.debug('Account Logs Count: ' + logs.size());
        System.assert(!logs.isEmpty(), 'Change log should be created');
        System.debug('Change Log Details: ' + logs[0].Change_Details__c);
    }

    @isTest
    static void testNoDuplicateSamaAndBlankName() {
        // Insert with name already ending in 様 - should not double append
        Account a1 = new Account(Name = '山田太郎様');
        insert a1;
        a1 = [SELECT Id, Name FROM Account WHERE Id = :a1.Id];
        System.assertEquals('山田太郎様', a1.Name, 'Name already ending with 様 should not get duplicated');

        // Insert with blank/whitespace name - should remain blank (trigger should skip)
        Account a2 = new Account(Name = '   ');
        insert a2;
        a2 = [SELECT Id, Name FROM Account WHERE Id = :a2.Id];
        System.assertEquals('   ', a2.Name, 'Blank/whitespace Name should be left unchanged');
    }
}