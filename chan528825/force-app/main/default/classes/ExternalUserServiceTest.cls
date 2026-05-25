@isTest
public class ExternalUserServiceTest {
    @isTest
    static void testFetchAndInsertUsers() {
        // Register the mock
        Test.setMock(HttpCalloutMock.class, new ExternalUserMock());

        // Start test context
        Test.startTest();
        ExternalUserService.fetchAndInsertUsers();
        Test.stopTest();

        // Assert record inserted
        List<External_User__c> users = [SELECT Name, Email__c, Phone__c, Username__c FROM External_User__c];
        System.assertEquals(1, users.size());
        System.assertEquals('Leanne Graham', users[0].Name);
        System.assertEquals('rey.padberg@karina.biz', users[0].Email__c);
    }
}