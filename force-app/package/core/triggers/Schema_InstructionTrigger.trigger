trigger Schema_InstructionTrigger on Schema_Instruction__c (before insert, before update, before delete) {
    switch on Trigger.operationType {
        
        when BEFORE_INSERT {    
            // Populate the external Id if it is not a valid UUID (Basic check on 36 charcters)
            utl.Trg.populateExternalId(Trigger.new, Schema.Schema_Instruction__c.External_Id__c);
            
            // Enforce single immutable Default record (parametrized util)
            utl.Trg.preventDefaultChange(Trigger.new, Schema.Schema_Instruction__c.Name, Schema.Schema_Instruction__c.Is_Default__c, Constant.DEFAULT_INSTRUCTION_NAME, Schema.Schema_Instruction__c.Allow_Delete__c);

            // Reset the Ignore Triggers flag on all records
            utl.Trg.resetIgnoreTriggersFlag(Trigger.new,Schema.Schema_Instruction__c.Ignore_Triggers__c);
        }
        
        when BEFORE_UPDATE {    
            // Populate the external Id if it is not a valid UUID (Basic check on 36 charcters)
            utl.Trg.populateExternalId(Trigger.new, Schema.Schema_Instruction__c.External_Id__c);
            
            // Enforce single immutable Default record (parametrized util)
            utl.Trg.preventDefaultChange(Trigger.new, Schema.Schema_Instruction__c.Name, Schema.Schema_Instruction__c.Is_Default__c, Constant.DEFAULT_INSTRUCTION_NAME, Schema.Schema_Instruction__c.Allow_Delete__c);

            // Reset the Ignore Triggers flag on all records
            utl.Trg.resetIgnoreTriggersFlag(Trigger.new,Schema.Schema_Instruction__c.Ignore_Triggers__c);
        }

        when BEFORE_DELETE {
            // Enforce single immutable Default record (parametrized util)
            utl.Trg.preventDefaultChange(Trigger.old, Schema.Schema_Instruction__c.Name, Schema.Schema_Instruction__c.Is_Default__c, Constant.DEFAULT_INSTRUCTION_NAME, Schema.Schema_Instruction__c.Allow_Delete__c);
        }
    }   
}