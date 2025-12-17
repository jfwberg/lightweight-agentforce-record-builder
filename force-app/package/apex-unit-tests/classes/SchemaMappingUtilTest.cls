@IsTest
private with sharing class SchemaMappingUtilTest {
    
    @IsTest
    static void createNewSchemaMappingVersionTest(){
        
        // Create the default instructions
        SchemaInstructionUtil.insertDefaultInstructions();

        // Create a schema
        Schema_Mapping__c sm = new Schema_Mapping__c();
        sm.Name = 'Test Schema';
        sm.Schema_Instruction__c = [SELECT Id FROM Schema_Instruction__c WHERE Name = :Constant.DEFAULT_INSTRUCTION_NAME WITH SYSTEM_MODE LIMIT 1]?.Id;        
        insert sm;

        try{
            // No sObject yet
            Map<String,Object> newVersionMap = SchemaMappingUtil.createNewSchemaMappingVersion(sm.Id);

            // The method will throw an exception. Place this method in your test class after 
            // the code that should throw an exception.If your code does not throw an exception, the test fails.
            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(SchemaMappingUtil.SchemaMappingException e){
            utl.Tst.assertExceptionMessage(Constant.MSG_NO_MAPPED_SOBJECTS, sm.Id, e);
        }

        Mapped_sObject__c parentMso = new Mapped_sObject__c();
        parentMso.Name              = 'utl__Parent_Test_sObject__c';
        parentMso.sObjectType__c    = 'utl__Parent_Test_sObject__c';
        parentMso.Schema_Mapping__c = sm.Id;
        insert parentMso;

        Mapped_sObject_Field__c parentMsof = new Mapped_sObject_Field__c();
        parentMsof.Name              = 'Name';
        parentMsof.Mapped_sObject__c = parentMso.Id;
        insert parentMsof;

        Mapped_sObject__c childMso = new Mapped_sObject__c();
        childMso.Name                   = 'utl__Child_Test_sObject__c';
        childMso.sObjectType__c         = 'utl__Child_Test_sObject__c';
        childMso.Parent_sObjectType__c  = 'utl__Parent_Test_sObject__c';
        childMso.Relationship_Field__c  = 'utl__Parent_Test_sObject__c';
        childMso.Schema_Mapping__c      = sm.Id;
        childMso.Parent_sObject__c      = parentMso.Id;
        insert childMso;

        // Add field
        Mapped_sObject_Field__c childMsof = new Mapped_sObject_Field__c();
        childMsof.Name              = 'Name';
        childMsof.Mapped_sObject__c = childMso.Id;
        insert childMsof;
 
        // Now with sObjects
        Map<String,Object> newVersionMap = SchemaMappingUtil.createNewSchemaMappingVersion(sm.Id);

        // Schema has no changes
        Map<String,Object> newerVersionMap = SchemaMappingUtil.createNewSchemaMappingVersion(sm.Id);

        // Check the version number is 1 for both as it should not have been updated
        Assert.areEqual((Decimal) 1, (Decimal) newVersionMap.get('versionNumber'),   'Unexpected version number');
        Assert.areEqual((Decimal) 1, (Decimal) newerVersionMap.get('versionNumber'), 'Unexpected version number');
    }
}