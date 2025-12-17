trigger Schema_Mapping_VersionTrigger on Schema_Mapping_Version__c (before insert, before update, after insert, after update) {
    switch on Trigger.operationType {

        when BEFORE_INSERT {	
            // Populate the external Id if it is not a valid UUID (Basic check on 36 charcters)
            utl.Trg.populateExternalId(Trigger.new, Schema.Schema_Mapping_Version__c.External_Id__c);
            
            // Reset the Ignore Triggers flag on all records
            utl.Trg.resetIgnoreTriggersFlag(Trigger.new,Schema.Schema_Mapping_Version__c.Ignore_Triggers__c);
		}
		
        when BEFORE_UPDATE {	
            // Populate the external Id if it is not a valid UUID (Basic check on 36 charcters)
            utl.Trg.populateExternalId(Trigger.new, Schema.Schema_Mapping_Version__c.External_Id__c);
            
            // Reset the Ignore Triggers flag on all records
            utl.Trg.resetIgnoreTriggersFlag(Trigger.new,Schema.Schema_Mapping_Version__c.Ignore_Triggers__c);
		}
		
        when AFTER_INSERT {
            utl.Trg.updateSingleCheckboxAndUpdateParent(
                Trigger.new,
                Schema_Mapping_Version__c.Is_Latest__c,          // child checkbox field
                Schema_Mapping__c.Latest_Version__c,             // parent lookup-to-child field
                Schema_Mapping_Version__c.Schema_Mapping__c,     // child lookup-to-parent field
                Schema_Mapping__c.SObjectType                    // parent SObjectType
            );
		}
		
        when AFTER_UPDATE {
			utl.Trg.updateSingleCheckboxAndUpdateParent(
                Trigger.new,
                Schema_Mapping_Version__c.Is_Latest__c,          // child checkbox field
                Schema_Mapping__c.Latest_Version__c,             // parent lookup-to-child field
                Schema_Mapping_Version__c.Schema_Mapping__c,     // child lookup-to-parent field
                Schema_Mapping__c.SObjectType                    // parent SObjectType
            );
		}
	}
}