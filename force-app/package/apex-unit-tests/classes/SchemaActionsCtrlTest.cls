@IsTest
private with sharing class SchemaActionsCtrlTest {
    
    @IsTest
    static void getActiveSchemaPromptOutputTest(){

        // Create the default instructions
        SchemaInstructionUtil.insertDefaultInstructions();

        // Create a schema
        Schema_Mapping__c sm = new Schema_Mapping__c();
        sm.Name = 'Test Schema';
        sm.Schema_Instruction__c = [SELECT Id FROM Schema_Instruction__c WHERE Name = :Constant.DEFAULT_INSTRUCTION_NAME WITH SYSTEM_MODE LIMIT 1]?.Id;        
        insert sm;
        
        // Create the new mapping
        Schema_Mapping_Version__c smv = new Schema_Mapping_Version__c(
            Is_Latest__c            = true,
            Schema_Mapping__c       = sm.Id,
            Version_Number__c       = 1,
            Prompt_Output__c        = 'ABC',
            Prompt_Output_Length__c = 3,
            Prompt_Output_Hash__c   = Util.sha1('ABC')
        );
        insert smv;

        // Execute test
        Map<String,String> result = SchemaActionsCtrl.getActiveSchemaPromptOutput(sm.Id);

    }


    @IsTest
    static void createNewSchemaMappingVersionTest(){
        
        // Create the default instructions
        SchemaInstructionUtil.insertDefaultInstructions();

        // Create a schema
        Schema_Mapping__c sm = new Schema_Mapping__c();
        sm.Name = 'Test Schema';
        sm.Schema_Instruction__c = [SELECT Id FROM Schema_Instruction__c WHERE Name = :Constant.DEFAULT_INSTRUCTION_NAME WITH SYSTEM_MODE LIMIT 1]?.Id;        
        insert sm;
        
        // Create the new mapping
        Schema_Mapping_Version__c smv = new Schema_Mapping_Version__c(
            Is_Latest__c            = true,
            Schema_Mapping__c       = sm.Id,
            Version_Number__c       = 1,
            Prompt_Output__c        = 'ABC',
            Prompt_Output_Length__c = 3,
            Prompt_Output_Hash__c   = Util.sha1('ABC')
        );
        insert smv;

        Mapped_sObject__c parentMso = new Mapped_sObject__c();
        parentMso.Name              = 'utl__Parent_Test_sObject__c';
        parentMso.sObjectType__c    = 'utl__Parent_Test_sObject__c';
        parentMso.Schema_Mapping__c = sm.Id;
        insert parentMso;

        // Execute test
        SchemaActionsCtrl.createNewSchemaMappingVersion(sm.Id);

    }


    @IsTest
    static void addSObjectAndFieldsTest(){
        
        // Create the default instructions
        SchemaInstructionUtil.insertDefaultInstructions();

        // Create a schema
        Schema_Mapping__c sm = new Schema_Mapping__c();
        sm.Name = 'Test Schema';
        sm.Schema_Instruction__c = [SELECT Id FROM Schema_Instruction__c WHERE Name = :Constant.DEFAULT_INSTRUCTION_NAME WITH SYSTEM_MODE LIMIT 1]?.Id;        
        insert sm;

        // Create the new mapping
        Schema_Mapping_Version__c smv = new Schema_Mapping_Version__c(
            Is_Latest__c            = true,
            Schema_Mapping__c       = sm.Id,
            Version_Number__c       = 1,
            Prompt_Output__c        = 'ABC',
            Prompt_Output_Length__c = 3,
            Prompt_Output_Hash__c   = Util.sha1('ABC')
        );
        insert smv;

        SchemaActionsCtrl.addSObjectAndFields(sm.Id, 'utl__Parent_Test_sObject__c', 'SObject Purpose', new String[]{'Name'});
    }


    @IsTest
    static void addChildSObjectAndFieldsTest(){
        
    // Create the default instructions
        SchemaInstructionUtil.insertDefaultInstructions();

        // Create a schema
        Schema_Mapping__c sm = new Schema_Mapping__c();
        sm.Name = 'Test Schema';
        sm.Schema_Instruction__c = [SELECT Id FROM Schema_Instruction__c WHERE Name = :Constant.DEFAULT_INSTRUCTION_NAME WITH SYSTEM_MODE LIMIT 1]?.Id;        
        insert sm;

        // Create the new mapping
        Schema_Mapping_Version__c smv = new Schema_Mapping_Version__c(
            Is_Latest__c            = true,
            Schema_Mapping__c       = sm.Id,
            Version_Number__c       = 1,
            Prompt_Output__c        = 'ABC',
            Prompt_Output_Length__c = 3,
            Prompt_Output_Hash__c   = Util.sha1('ABC')
        );
        insert smv;

        Mapped_sObject__c parentMso = new Mapped_sObject__c();
        parentMso.Name              = 'utl__Parent_Test_sObject__c';
        parentMso.sObjectType__c    = 'utl__Parent_Test_sObject__c';
        parentMso.Schema_Mapping__c = sm.Id;
        insert parentMso;

        Mapped_sObject_Field__c parentMsof = new Mapped_sObject_Field__c();
        parentMsof.Name              = 'Name';
        parentMsof.Mapped_sObject__c = parentMso.Id;
        insert parentMsof;

        // Add child fields
        SchemaActionsCtrl.addChildSObjectAndFields(
            parentMso.Id, 
            'utl__Child_Test_sObject__c', 
            'utl__Parent_Test_sObject__c', 
            'SObject Purpose',
            new String[]{'Name'}
        );
    }
}