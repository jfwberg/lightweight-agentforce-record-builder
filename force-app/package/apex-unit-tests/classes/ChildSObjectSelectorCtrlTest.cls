@IsTest
public with sharing class ChildSObjectSelectorCtrlTest {


    @IsTest
    static void getSObjectsTest(){
        
        // Create the default instructions
        SchemaInstructionUtil.insertDefaultInstructions();

        // Create a schema
        Schema_Mapping__c sm = new Schema_Mapping__c();
        sm.Name = 'Test Schema';
        sm.Schema_Instruction__c = [SELECT Id FROM Schema_Instruction__c WHERE Name = :Constant.DEFAULT_INSTRUCTION_NAME WITH SYSTEM_MODE LIMIT 1]?.Id;        
        insert sm;

        Mapped_sObject__c parentMso = new Mapped_sObject__c();
        parentMso.Name              = 'utl__Parent_Test_sObject__c';
        parentMso.sObjectType__c    = 'utl__Parent_Test_sObject__c';
        parentMso.Schema_Mapping__c = sm.Id;
        insert parentMso;

        // Execute logic
        ChildSObjectSelectorCtrl.SObjectInfo[] objectInfos = ChildSObjectSelectorCtrl.getSObjects(parentMso.Id, true, true);

        // Assert there are sobjects
        Assert.areEqual(true, objectInfos.size() > 0, 'Unexpected number of sObjects');
    }


    @IsTest
    static void getFieldsTest(){
        
        // Create the default instructions
        SchemaInstructionUtil.insertDefaultInstructions();

        // Create a schema
        Schema_Mapping__c sm = new Schema_Mapping__c();
        sm.Name = 'Test Schema';
        sm.Schema_Instruction__c = [SELECT Id FROM Schema_Instruction__c WHERE Name = :Constant.DEFAULT_INSTRUCTION_NAME WITH SYSTEM_MODE LIMIT 1]?.Id;        
        insert sm;

        Mapped_sObject__c parentMso = new Mapped_sObject__c();
        parentMso.Name              = 'utl__Parent_Test_sObject__c';
        parentMso.sObjectType__c    = 'utl__Parent_Test_sObject__c';
        parentMso.Schema_Mapping__c = sm.Id;
        insert parentMso;

        // Execute logic
        ChildSObjectSelectorCtrl.FieldInfo[] fieldInfos = ChildSObjectSelectorCtrl.getFields(parentMso.Id, 'utl__Parent_Test_sObject__c');

        // Assert there are fields
        Assert.areEqual(true, fieldInfos.size() > 0, 'Unexpected number of fields');
    }
}