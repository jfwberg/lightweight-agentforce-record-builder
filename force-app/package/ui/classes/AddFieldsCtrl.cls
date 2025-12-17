/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC Controller Class for adding fields
 * 
 */
public with sharing class AddFieldsCtrl {
    
    @AuraEnabled
    public static FieldData[] loadFields(String recordId){
        try {
            // Create a list of fields to output
            FieldData[] outputFields = new FieldData[]{};

            // List of fields that are already added so we can filter accordingly
            Set<String> existingFieldNames = new Set<String>{};

            // Query the sObject Type
            Mapped_sObject__c[] mappedSObjects = [SELECT Id, Relationship_Field__c, sObjectType__c FROM Mapped_sObject__c WHERE Id = :recordId WITH SYSTEM_MODE LIMIT 1];

            // Query the already added fields and create a list of names
            for(Mapped_sObject_Field__c existingField : [SELECT Id, Name, Purpose_Description__c FROM Mapped_sObject_Field__c WHERE Mapped_sObject__c = :recordId WITH SYSTEM_MODE]){
                existingFieldNames.add(existingField?.Name?.toLowerCase());
            }

            // Fetch the field Data
            Map<String, Schema.SObjectField> fields = ((SObject)Type.forName(mappedSObjects[0]?.sObjectType__c)?.newInstance())?.getSObjectType()?.getDescribe(SObjectDescribeOptions.DEFERRED)?.fields?.getMap();
            
            // Iterate the fields
            for (Schema.SObjectField f : fields.values()) {
                
                // Skip fields that are already added
                if(existingFieldNames.contains(f?.toString()?.toLowerCase())){
                    continue;
                }

                // Filter out the lookup field as this is mapped based on the relationship and always populated
                if(f?.toString()?.toLowerCase() == mappedSObjects[0]?.Relationship_Field__c?.toLowerCase() ){
                    continue;
                }

                // Describe to field to get the info we need.
                Schema.DescribeFieldResult fd = f.getDescribe();

                // Only include fields that are createable, and skip deprecated/hidden fields, make an exception for the Id field
                // Because we need ids fields for updates
                if((fd.isDeprecatedAndHidden() || (!fd.isCreateable() && !fd.isUpdateable())) && fd.name != 'Id'){
                    continue;
                }

                // Mandatory if not nillable and not defaulted on create and not auto-generated
                Boolean autoGen = fd.isAutoNumber() || fd.isCalculated() || fd.isDefaultedOnCreate();

                // Create new output object
                FieldData outputField = new FieldData();
                outputField.name        =  fd.getName();
                outputField.label       =  fd.getLabel();
                outputField.dataType    =  fd.getType()?.name();
                outputField.isCustom    =  fd.isCustom();
                outputField.isMandatory = !fd.isNillable() && !autoGen;

                // Add field to list
                outputFields.add(outputField);             
            }

            // Return field data
            return outputFields;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void addFields(String recordId, String fieldsJson){
        try {

            // Create a list for new fields to insert
            Mapped_sObject_Field__c[] fieldsToAdd = new Mapped_sObject_Field__c[]{};

            // The joys of apex classes and LWC controllers
            FieldData[] fields = (FieldData[]) JSON.deserialize(
                fieldsJson,
                FieldData[].class
            );

            // Create the new fields
            for(FieldData field : fields){
                Mapped_sObject_Field__c fieldToAdd = new Mapped_sObject_Field__c();
                fieldToAdd.Name              = field.name;
                fieldToAdd.Mapped_sObject__c = recordId;
                fieldsToAdd.add(fieldToAdd);
            }

            // Upsert the new fields
            insert as system fieldsToAdd;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class FieldData{

        @AuraEnabled
        public String  name;

        @AuraEnabled
        public String  label;

        @AuraEnabled
        public String  dataType;

        @AuraEnabled
        public Boolean isCustom;

        @AuraEnabled
        public Boolean isMandatory;
    }
}