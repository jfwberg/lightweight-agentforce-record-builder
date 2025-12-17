trigger Schema_Instruction_VersionTrigger on Schema_Instruction_Version__c (before insert, before update, after insert, after update){
    switch on Trigger.operationType {

        when BEFORE_INSERT {
            // Populate the external Id if it is not a valid UUID (Basic check on 36 charcters)
            utl.Trg.populateExternalId(Trigger.new, Schema.Schema_Instruction_Version__c.External_Id__c);

            // Reset the Ignore Triggers flag on all records
            utl.Trg.resetIgnoreTriggersFlag(Trigger.new,Schema.Schema_Instruction_Version__c.Ignore_Triggers__c);
		}

        when BEFORE_UPDATE {
            // Populate the external Id if it is not a valid UUID (Basic check on 36 charcters)
            utl.Trg.populateExternalId(Trigger.new, Schema.Schema_Instruction_Version__c.External_Id__c);

            // Reset the Ignore Triggers flag on all records
            utl.Trg.resetIgnoreTriggersFlag(Trigger.new,Schema.Schema_Instruction_Version__c.Ignore_Triggers__c);
		}

        when AFTER_INSERT {
            utl.Trg.updateSingleCheckboxAndUpdateParent(
                Trigger.new,
                Schema_Instruction_Version__c.Is_Latest__c,
                Schema_Instruction__c.Latest_Version__c,
                Schema_Instruction_Version__c.Schema_Instruction__c,
                Schema_Instruction__c.SObjectType
            );
		}

        when AFTER_UPDATE {
			utl.Trg.updateSingleCheckboxAndUpdateParent(
                Trigger.new,
                Schema_Instruction_Version__c.Is_Latest__c,
                Schema_Instruction__c.Latest_Version__c,
                Schema_Instruction_Version__c.Schema_Instruction__c,
                Schema_Instruction__c.SObjectType
            );
		}
	}
}
