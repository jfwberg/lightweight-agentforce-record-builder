/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC Controller Class for managing fields
 * 
 */
public with sharing class ManageFieldsCtrl {

    @AuraEnabled
    public static FieldData[] loadFields(String recordId){
        try {

            FieldData[] outputFields = new FieldData[]{};

            // Query fields
            Mapped_sObject_Field__c[] fields = [SELECT Id, Name, Purpose_Description__c FROM Mapped_sObject_Field__c WHERE Mapped_sObject__c = :recordId WITH SYSTEM_MODE];

            // Add fields to data structure
            for(Mapped_sObject_Field__c field : fields){
                FieldData outputField = new FieldData();
                outputField.id                  = field.Id;
                outputField.name                = field.Name;
                outputField.purposeDescription  = field.Purpose_Description__c;
                outputFields.add(outputField);
            }

            return outputFields;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void updateFields(String recordId, String fieldsJson, String deletedFieldsJson){
        try {

            // Create a list for new fields to insert
            Mapped_sObject_Field__c[] fieldsToUpdate = new Mapped_sObject_Field__c[]{};
            
            // New list of fields to delete
            Mapped_sObject_Field__c[] fieldsToDelete = new Mapped_sObject_Field__c[]{};

            // The joys of apex classes and LWC controllers
            FieldData[] fields = (FieldData[]) JSON.deserialize(
                fieldsJson ?? '[]',
                FieldData[].class
            );

            // The joys of apex classes and LWC controllers
            FieldData[] deletedFields = (FieldData[]) JSON.deserialize(
                deletedFieldsJson ?? '[]',
                FieldData[].class
            );

            // Create the fields for update
            for(FieldData field : fields){
                Mapped_sObject_Field__c fieldToUpdate = new Mapped_sObject_Field__c();
                fieldToUpdate.Id                     = field.Id;
                fieldToUpdate.Purpose_Description__c = field.purposeDescription;
                fieldsToUpdate.add(fieldToUpdate);
            }

            // Create the fields for update
            for(FieldData deletedField : deletedFields){
                Mapped_sObject_Field__c fieldToDelete = new Mapped_sObject_Field__c();
                fieldToDelete.Id                     = deletedField.Id;
                fieldsToDelete.add(fieldToDelete);
            }

            // Upsert the existing fields
            upsert as system fieldsToUpdate;
            
            // Delete fields that have been deleted
            delete as system fieldsToDelete;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class FieldData{
        @AuraEnabled
        public String id;

        @AuraEnabled
        public String name;

        @AuraEnabled
        public String purposeDescription;
    }
}