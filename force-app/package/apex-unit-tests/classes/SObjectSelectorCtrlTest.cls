@IsTest
private with sharing class SObjectSelectorCtrlTest {
    

    @IsTest
    static void getSObjectsTest(){
        
        SObjectSelectorCtrl.SObjectInfo[] sobjInfo = SObjectSelectorCtrl.getSObjects(true,true);


    }


    @IsTest
    static void getFieldsTest(){

        SObjectSelectorCtrl.FieldInfo[] fldInfo = SObjectSelectorCtrl.getFields(Schema.utl__Parent_Test_sObject__c.getSObjectType().toString());

    }

    
}