//✅ Trigger Goal Summary:
//Automatically update the Account’s "Primary Contact Name" field whenever a Contact marked as "Primary" is inserted or updated.

public class ContactHandler {

    public static void updatePrimaryContactName(List<Contact> contactList) {
        System.debug('🔄 Starting updatePrimaryContactName method');

        Set<Id> accountIds = new Set<Id>();

        // Step 1: Collect Account Ids from contacts marked as Primary
        for (Contact c : contactList) {
            if (c.Is_Primary__c && c.AccountId != null) {
                accountIds.add(c.AccountId);
                System.debug('✅ Found primary contact - Contact Id: ' + c.Id + ', Account Id: ' + c.AccountId);
            }
        }

        // Step 2: Stop if there are no Account Ids to process
        if (accountIds.isEmpty()) {
            System.debug('⚠️ No Account IDs found. Exiting method.');
            return;
        }
        System.debug('📦 Total Account IDs to process: ' + accountIds);

        // Step 3: Query all primary contacts related to those accounts
        Map<Id, Contact> acctToPrimaryContact = new Map<Id, Contact>();

        List<Contact> primaryContacts = [SELECT Id, FirstName, LastName, AccountId 
                                         FROM Contact 
                                         WHERE Is_Primary__c = true AND AccountId IN :accountIds];

        for (Contact c : primaryContacts) {
            acctToPrimaryContact.put(c.AccountId, c);
            System.debug('🔗 Mapping Account Id ' + c.AccountId + ' → Contact: ' + c.FirstName + ' ' + c.LastName + ' (Id: ' + c.Id + ')');
        }

        // Step 4: Prepare list of accounts to update with primary contact names
        List<Account> accsToUpdate = new List<Account>();

        for (Id accId : acctToPrimaryContact.keySet()) {
            System.debug(' accId : ' + accId);

            Contact c = acctToPrimaryContact.get(accId);
            System.debug(' Contact ' + c);

            String fullName = (c.FirstName != null ? c.FirstName + ' ' : '') + c.LastName;

            Account acc = new Account(Id = accId, Primary_Contact_Name__c = fullName);
            accsToUpdate.add(acc);

            System.debug('✏️ Updating Account Id ' + accId + ' with Primary Contact Name: ' + fullName);
        }

        // Step 5: Update all accounts
        if (!accsToUpdate.isEmpty()) {
            update accsToUpdate;
            System.debug('✅ Accounts updated successfully: ' + accsToUpdate.size());
        } else {
            System.debug('⚠️ No Accounts to update.');
        }

        System.debug('✅ Finished updatePrimaryContactName method');
    }

    public static void updateContactDescription(List<Contact> contactList) {
        System.debug('Starting updateContactDescription method');
        
        Set<Id> acctIds = new Set<Id>();
        for (Contact con : contactList) {
            if (con.AccountId != null) {
                acctIds.add(con.AccountId);
            }
        }
    
        Map<Id, Account> acctMap = new Map<Id, Account>(
            [SELECT Id, Name FROM Account WHERE Id IN :acctIds]
        );
    
        for (Contact con : contactList) {
            if (acctMap.containsKey(con.AccountId)) {
                Account acc = acctMap.get(con.AccountId);
                con.Description = 'Belongs to Account: ' + acc.Name;
            }
        }
    }
}
    

//updatePrimaryContactName
/*
Step 1️⃣
[Start: Loop through Contacts in Trigger.new]
        ↓
Step 1️⃣
[Is Contact Primary AND Has Account?]
        ├─ No → Skip to next contact
        └─ Yes → Add to Map: (AccountId → Contact)
        ↓
Step 2️⃣
[Check: Is Map Empty?]
        ├─ Yes → STOP (nothing to update)
        └─ No → Continue
        ↓
Step 3️⃣
[Debug: Show Account Ids from Map.keySet()]
        ↓
Step 4️⃣
[Loop through Account Ids in Map.keySet()]
        ↓
Step 4️⃣
[Get Contact using Account Id → acctToPrimaryContact.get(accId)]
        ↓
Step 4️⃣
[Build Full Name = FirstName + ' ' + LastName]
        ↓
Step 4️⃣
[Create Account record with new Primary_Contact_Name__c]
        ↓
Step 4️⃣
[Add Account to Update List]
        ↓
Step 5️⃣
[Update All Account Records]
        ↓
✅ DONE

*/