@IsTest
private with sharing class HierarchyUtilTest {

    @IsTest
    static void buildHierarchyTest() {

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

        Mapped_sObject__c childMso = new Mapped_sObject__c();
        childMso.Name                   = 'utl__Child_Test_sObject__c';
        childMso.sObjectType__c         = 'utl__Child_Test_sObject__c';
        childMso.Parent_sObjectType__c  = 'utl__Parent_Test_sObject__c';
        childMso.Relationship_Field__c  = 'utl__Parent_Test_sObject__c';
        childMso.Schema_Mapping__c      = sm.Id;
        childMso.Parent_sObject__c      = parentMso.Id;
        insert childMso;

        Mapped_sObject__c secondParentMso = new Mapped_sObject__c();
        secondParentMso.Name              = 'utl__Parent_Test_sObject__c 02';
        secondParentMso.sObjectType__c    = 'utl__Parent_Test_sObject__c';
        secondParentMso.Schema_Mapping__c = sm.Id;
        insert secondParentMso;


        Mapped_sObject__c secondChildMso = new Mapped_sObject__c();
        secondChildMso.Name                   = 'utl__Child_Test_sObject__c 02';
        secondChildMso.sObjectType__c         = 'utl__Child_Test_sObject__c';
        secondChildMso.Parent_sObjectType__c  = 'utl__Parent_Test_sObject__c';
        secondChildMso.Relationship_Field__c  = 'utl__Parent_Test_sObject__c';
        secondChildMso.Schema_Mapping__c      = sm.Id;
        secondChildMso.Parent_sObject__c      = secondParentMso.Id;
        insert secondChildMso;

        Mapped_sObject__c thirdParentMso = new Mapped_sObject__c();
        thirdParentMso.Name              = 'utl__Parent_Test_sObject__c 03';
        thirdParentMso.sObjectType__c    = 'utl__Parent_Test_sObject__c';
        thirdParentMso.Schema_Mapping__c = sm.Id;
        insert thirdParentMso;

        // Execute logic
        HierarchyUtil.TreeResult result = HierarchyUtil.buildHierarchy(sm.Id);

        // Assert
        Assert.areEqual(5, result.totalNodes, 'Unexpected number of sOBject in the hierarchy');

    }
}