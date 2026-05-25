/**
 * @description Custom controller to display and filter Contact records.
 * It allows users to search contacts by Last Name and navigate
 * to the standard New Contact page.
 */
public with sharing class ContactListAndFilterController {

    // Public property to hold the list of Contact records retrieved.
    public List<Contact> contacts { get; private set; }

    // Public property to hold the search string entered by the user (e.g., Last Name).
    public String searchString { get; set; }

    /**
     * @description Constructor for the ContactListAndFilterController.
     * Initializes the searchString and calls the searchContacts method
     * to load the initial list of contacts (all contacts if no search string).
     */
    public ContactListAndFilterController() {
        // Initialize searchString to null or empty
        searchString = '';
        // Load initial contacts when the page loads
        searchContacts();
    }

    /**
     * @description Performs a SOQL query to retrieve Contact records based on the searchString.
     * If searchString is empty, it retrieves all contacts (up to a limit).
     * If searchString is provided, it filters contacts by Last Name.
     * This method can be invoked from the Visualforce page via a commandButton.
     * @return PageReference - Stays on the current page (returns null).
     */
    public PageReference searchContacts() {
        String query = 'SELECT Id, FirstName, LastName, Email, Phone FROM Contact';
        List<String> conditions = new List<String>();

        // Build WHERE clause based on searchString
        if (searchString != null && searchString.length() > 0) {
            // Using '%' for LIKE operator to allow partial matches
            conditions.add('LastName LIKE \'' + String.escapeSingleQuotes(searchString) + '%\'');
        }

        // Add conditions to the query if any exist
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }

        // Add an ORDER BY clause for consistent results
        query += ' ORDER BY LastName, FirstName';
        
        // Add a LIMIT to prevent fetching too many records and hitting governor limits.
        // Adjust this limit as needed for your specific use case.
        query += ' LIMIT 100'; 

        try {
            // Execute the dynamic SOQL query
            contacts = Database.query(query);
            System.debug('Contacts found: ' + contacts.size());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Found ' + contacts.size() + ' contact(s).'));
        } catch (QueryException e) {
            // Handle SOQL query errors (e.g., malformed query, insufficient permissions)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error querying contacts: ' + e.getMessage()));
            contacts = new List<Contact>(); // Ensure contacts list is not null
        } catch (Exception e) {
            // Catch any other unexpected errors
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected error occurred: ' + e.getMessage()));
            contacts = new List<Contact>();
        }

        return null; // Stay on the same Visualforce page
    }

    /**
     * @description Navigates to the standard "New Contact" creation page.
     * This is useful for providing a seamless user experience to create new records.
     * @return PageReference - A PageReference object pointing to the new contact page.
     */
    public PageReference newContact() {
        // Returns a PageReference that redirects to the standard Contact New record page.
        // The /003/e URL is a standard Salesforce endpoint for creating new Contact records.
        return new PageReference('/003/e');
    }
}