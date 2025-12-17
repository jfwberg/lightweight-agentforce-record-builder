@IsTest
private with sharing class UpdateHierarchyCtrlTest {
    
    @IsTest
    static void buildHierarchyTest(){

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

        HierarchyUtil.TreeResult result = UpdateHierarchyCtrl.buildHierarchy(sm.Id);

        try{
            
            HierarchyUtil.TreeResult exceptionResult = UpdateHierarchyCtrl.buildHierarchy(null);

        }catch(AuraHandledException e){
            Assert.areEqual('Script-thrown exception', e.getMessage());
        }
    }
}