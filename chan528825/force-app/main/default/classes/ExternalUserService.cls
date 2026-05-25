public with sharing class ExternalUserService {
    public static void fetchAndInsertUsers() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://jsonplaceholder.typicode.com/users');
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            List<External_User__c> usersToInsert = new List<External_User__c>();
            
            List<Object> jsonUsers = (List<Object>) JSON.deserializeUntyped(response.getBody());
            
            for (Object obj : jsonUsers) {
                Map<String, Object> userMap = (Map<String, Object>) obj;
                External_User__c user = new External_User__c();
                user.Name = (String) userMap.get('name');
                user.Email__c = (String) userMap.get('email');
                user.Phone__c = (String) userMap.get('phone');
                user.Username__c = (String) userMap.get('username');
                usersToInsert.add(user);
            }
            
            if (!usersToInsert.isEmpty()) {
                insert usersToInsert;
            }
        } else {
            System.debug('API call failed: ' + response.getStatus());
        }
    }
}