public with sharing class CalculatorHandler {
    public static Boolean hasRun = false;

    public static void totalval(List<Calculator__c> recordList) {
        List<Calculator__c> updates = new List<Calculator__c>();

        for (Calculator__c rec : recordList) {
            if (rec.Price__c != null && rec.Qty__c != null) {
                Calculator__c updateRec = new Calculator__c(
                    Id = rec.Id,
                    TotalPrice__c = rec.Price__c * rec.Qty__c
                );
                updates.add(updateRec);
            }
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }
}

/*

public class CalculatorUpdater {
    public static void updateTotal(List<Calculator__c> originalRecords) {
        List<Calculator__c> recordsToUpdate = new List<Calculator__c>();

        for (Calculator__c original : originalRecords) {
            // Make sure both fields have values
            if (original.Price__c != null && original.Qty__c != null) {
                // Calculate total
                Decimal calculatedTotal = original.Price__c * original.Qty__c;

                // Create a new record with only the Id and updated field
                Calculator__c updated = new Calculator__c();
                updated.Id = original.Id;               // Target the same record
                updated.Total__c = calculatedTotal;     // Only update Total__c

                // Add to update list
                recordsToUpdate.add(updated);
            }
        }

        // Perform update if needed
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }
}

*/