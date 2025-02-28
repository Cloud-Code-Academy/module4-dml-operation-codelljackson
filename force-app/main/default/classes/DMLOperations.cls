/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Codell L. Jackson
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        Account myAccount = new Account();// Create a new Account instance
        myAccount.Name = 'Codell Account'; 

        myAccount.Industry = 'Technology';// Set some fields on the Account
        myAccount.Phone = '404-777-9311';
        myAccount.BillingStreet = 'Jackson Street'; 
        myAccount.BillingCity = 'Atlanta';

        insert myAccount; // Insert the Account into the database

        // Return the Id of the newly created Account
        return myAccount.id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {

        Account myAccount = new Account (Name = name, Industry = industry);// Create a new Account and set the fields inline
        
        insert myAccount;// Insert the Account
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        
        Contact myContact = new Contact(); // Create a new Contact instance

        myContact.FirstName = 'Denise'; // Set some fields on the Contact
        myContact.LastName = 'Black';
        myContact.HomePhone = '205-777-9311';

        myContact.AccountId = accountId;// Set the AccountId field to the given accountId

        insert myContact;// Insert the Contact into the database

        return myContact.Id;// Return the Id of the newly created Contact
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        
        Contact contactRecord = [SELECT Id, LastName FROM Contact WHERE Id = : contactId LIMIT 1]; // Retrieve the Contact from the database// [SELECT Id FROM Contact WHERE Id = :contactId]
        
        contactRecord.LastName = newLastName;  // Update the Contact's last name

        update contactRecord; // Update the Contact in the database 
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        
        Opportunity oppRecord = [SELECT Id, StageName FROM Opportunity WHERE Id = : oppId LIMIT 1]; // Retrieve the Opportunity from the database// [SELECT Id FROM Opportunity WHERE Id = :oppId]
        
        oppRecord.StageName = newStage; // Update the Opportunity's stage

        update oppRecord; // Update the Opportunity in the database
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        
        Account accRecord = [SELECT Id, Name FROM Account WHERE Id = : accountId LIMIT 1]; // Query the account // [SELECT Id FROM Account WHERE Id = :accountId]
        
        accRecord.Name = newName;
        accRecord.Industry = newIndustry;

        update accRecord;// Update the Account with the given Id with the new name and industry
        
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {

        for (Opportunity myOpportunity : opportunities) {// Loop through each Opportunity in the list
            
        myOpportunity.StageName = 'Qualification'; // Set the Opportunity's Stage to Qualification
        myOpportunity.CloseDate = Date.today().addMonths(3);// Set the Opportunity's Close Date to 3 months from today
        myOpportunity.Amount = 50000;// Set the Opportunity's Amount to 50000
    }
        upsert opportunities; // Upsert the opportunities List so that records are either updated or created
    }
    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        
        List<Account> accList = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        Account acc = accList.isEmpty() ? new Account(Name = accountName) : accList[0]; 

        upsert acc; 

        List<Opportunity> existingOpps = [SELECT Id, Name FROM Opportunity WHERE Name IN : oppNames and AccountId = : acc.id];
        Set<String> existingOppNames = new Set<String>();

        for (Opportunity opp : existingOpps){
            existingOppNames.add(opp.Name); 
        }

        List<Opportunity> opportunityList = new List<Opportunity>();

        for (String oppName : oppNames){

        if (!existingOppNames.contains(oppName)){
            Opportunity newOpp = new Opportunity (// Create an Opportunity with the given name
            Name = oppName, 
            AccountId = acc.Id, 
            StageName = 'Qualification', 
            CloseDate = Date.today().addMonths(3), 
            Amount = 50000);
    
            opportunityList.add(newOpp); // Add the Opportunity to the list

    }
    }
        if (!OpportunityList.isEmpty()) {
            upsert opportunityList; 
    }
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];

		// if the Account exists, update the description

		// otherwise, create a new Account and set the description

		// Upsert the Account
		return null;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		// Loop through each Contact

		// Extract the Account Name from Contact's LastName

		// Get the account based on the name or create one if it doesn't exist

		// Link the Contact to its Account using the Account Id

		// Upsert the Contacts
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        // Loop through each Lead name

        // Insert the Leads

        // Delete the Leads
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        // Insert the cases

        // Delete the cases
    }
}