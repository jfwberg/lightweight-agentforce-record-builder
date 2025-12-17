@IsTest
public with sharing class AddFieldsCtrlTest {
    
    @IsTest
    static void loadFieldsTest(){

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

        Mapped_sObject_Field__c parentMsof = new Mapped_sObject_Field__c();
        parentMsof.Name              = 'Name';
        parentMsof.Mapped_sObject__c = parentMso.Id;
        insert parentMsof;

        // Mapped_sObject__c
        AddFieldsCtrl.FieldData[] fields = AddFieldsCtrl.loadFields(parentMso.Id);

        // Assert there are fields
        Assert.areEqual(true, fields.size() > 0, 'Unexpected number of fields');
    }
    

    @IsTest
    static void addFields(){
        
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

        // Fields
        AddFieldsCtrl.FieldData[] fields = new AddFieldsCtrl.FieldData[]{};
        AddFieldsCtrl.FieldData   field  = new AddFieldsCtrl.FieldData();
        field.name = 'Name';
        fields.add(field);

        // Execute logic
        AddFieldsCtrl.addFields(parentMso.Id, JSON.serialize(fields));

        // Assert field has been added
        Assert.areEqual(1, [SELECT COUNT() FROM Mapped_sObject_Field__c],'Unexpected number of fields');
    }

    
}