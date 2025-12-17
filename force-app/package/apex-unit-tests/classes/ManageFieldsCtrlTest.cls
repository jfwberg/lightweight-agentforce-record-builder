@IsTest
public with sharing class ManageFieldsCtrlTest {

    // Create a test uses with the test util permission set
    private static User runAsUser = utl.Tst.createRunAsUser(
        utl.Tst.STANDARD_USER_PROFILE,
        utl.Tst.TEST_SR_NAME  
    ); 


    @IsTest
    static void loadFieldsTest(){
        
        ManageFieldsCtrl.FieldData[] fieldData;
        
        System.runAs(runAsUser){
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

            // Execute logic
            Test.startTest();
            fieldData = ManageFieldsCtrl.loadFields(parentMso.Id);
            Test.stopTest();
        }

        // Assert there are sobjects
        Assert.areEqual(1, fieldData.size(), 'Unexpected number of fields');
    }

    @IsTest
    static void updateFieldsTest(){
        
        System.runAs(runAsUser){
            
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
            
            Mapped_sObject_Field__c parentMsof2 = new Mapped_sObject_Field__c();
            parentMsof2.Name              = 'utl__Text__c';
            parentMsof2.Mapped_sObject__c = parentMso.Id;
            insert parentMsof2;
        
            Test.startTest();

            ManageFieldsCtrl.FieldData[] fields  = new ManageFieldsCtrl.FieldData[]{};
            ManageFieldsCtrl.FieldData field     = new ManageFieldsCtrl.FieldData();
            field.id = parentMsof.Id;
            field.name = 'Name';
            fields.add(field);
            
            ManageFieldsCtrl.FieldData[] fieldsToDelete = new ManageFieldsCtrl.FieldData[]{};
            ManageFieldsCtrl.FieldData fieldToDelete    = new ManageFieldsCtrl.FieldData();
            fieldToDelete.id = parentMsof2.Id;
            fieldToDelete.name = 'utl__Text__c';
            fieldsToDelete.add(fieldToDelete);

            // Execute logic
            ManageFieldsCtrl.updateFields(parentMso.Id, json.serialize(fields), JSON.serialize(fieldsToDelete));
            
            Test.stopTest();

            // Assert there are sobjects
            Assert.areEqual(1, [SELECT COUNT() FROM Mapped_sObject_Field__c],'Unexpected number of fields');
        }

    }
}