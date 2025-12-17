trigger ActionEventTrigger on Action__e (after insert) {
    for(Action__e action : trigger.new){

        // Create a log entry
        if(action.Type__c == Constant.VAL_TYPE_LOG_MESSAGE){
            insert as system new Log__c(
                User_Id__c     = action.User_Id__c,
                Message__c     = action.Message__c,
                Stack_Trace__c = action.Stack_Trace__c,
                Error_Code__c  = action.Error_Code__c
            );
        }

        // Create the default instruction
        if(action.Type__c == Constant.VAL_TYPE_INSERT_PERM_SET){
            SchemaInstructionUtil.insertDefaultInstructionsAsync();
        }

        // Assign the permission set to the running user
        if(action.Type__c == Constant.VAL_TYPE_INSERT_PERM_SET){
            Util.assignPermissionSetAsync(
                action.User_Id__c,
                Constant.VAL_PERMISSION_SET_NAME
            );
        }
    }
}