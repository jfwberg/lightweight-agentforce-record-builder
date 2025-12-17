trigger Schema_MappingTrigger on Schema_Mapping__c (before insert, before update) {
    
    /**
     * POPULATE EXTERNAL ID
     */
    // Populate the external Id if it is not a valid UUID (Basic check on 36 charcters)
    utl.Trg.populateExternalId(Trigger.new,Schema.Schema_Mapping__c.External_Id__c);


    /**
     * IGNORE TRIGGER FLAG
     */
    // Reset the Ignore Triggers flag on all records
    utl.Trg.resetIgnoreTriggersFlag(Trigger.new,Schema.Schema_Mapping__c.Ignore_Triggers__c);
}