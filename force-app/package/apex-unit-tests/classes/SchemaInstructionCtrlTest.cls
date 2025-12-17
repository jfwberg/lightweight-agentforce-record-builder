@IsTest
private with sharing class SchemaInstructionCtrlTest {
    
    @IsTest
    static void isDefaultInstructionTest(){
        // Create the default instructions
        SchemaInstructionUtil.insertDefaultInstructions();

        Boolean result = SchemaInstructionCtrl.isDefaultInstruction(
            [SELECT Id FROM Schema_Instruction__c WHERE Name = :Constant.DEFAULT_INSTRUCTION_NAME WITH SYSTEM_MODE LIMIT 1]?.Id
        );

        Assert.areEqual(true, result,'Expected Default instructions');
    }

    @IsTest
    static void loadSchemaInstructionVersionTest(){
        // Create the default instructions
        SchemaInstructionUtil.insertDefaultInstructions();

        String result = SchemaInstructionCtrl.loadSchemaInstructionVersion(
            [SELECT Id FROM Schema_Instruction__c WHERE Name = :Constant.DEFAULT_INSTRUCTION_NAME WITH SYSTEM_MODE LIMIT 1]?.Id
        );
    }


    @IsTest
    static void resetDefaultInstructionTest(){
        // Create the default instructions
        SchemaInstructionUtil.insertDefaultInstructions();

        Map<String,Object> result = SchemaInstructionCtrl.resetDefaultInstruction();

        Assert.areEqual(true, !result.isEmpty(),'Expected results in the version map');
    }


    @IsTest
    static void createSchemaInstructionVersionTest(){

        // Create the default instructions
        SchemaInstructionUtil.insertDefaultInstructions();

        Map<String,Object> result = SchemaInstructionCtrl.createSchemaInstructionVersion(
            [SELECT Id FROM Schema_Instruction__c WHERE Name = :Constant.DEFAULT_INSTRUCTION_NAME WITH SYSTEM_MODE LIMIT 1]?.Id,
            'new instructions'
        );
        
        Assert.areEqual(
            'new instructions',
            [SELECT Prompt_Output__c FROM Schema_Instruction_Version__c WHERE Id = :((String)result.get('versionRecordId')) LIMIT 1 ]?.Prompt_Output__c,
            'Unexpected instructions...'
        );
    }
}