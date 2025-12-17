/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC Controller Class for managing schema actions
 * 
 */
public with sharing class SchemaActionsCtrl {

    @AuraEnabled
    public static Map<String,String> getActiveSchemaPromptOutput(String recordId){
        try {
            // Validate record exists
            SchemaUtil.validateRecordId(recordId,Schema.Schema_Mapping__c.getSObjectType());

            // recordId is Schema_Mapping__c. Latest_Version__c is a lookup to Schema_Mapping_Version__c.
            // Return Latest_Version__r.Prompt_Output__c.
            Schema_Mapping__c sm = [
                SELECT
                    Latest_Version__r.Prompt_Output__c,
                    Latest_Version__r.Version_Number__c
                FROM Schema_Mapping__c
                WHERE Id = :recordId
                WITH SYSTEM_MODE
                LIMIT 1
            ];

            return new Map<String,String>{
                'label'         => 'Prompt Output Version: ' + (sm.Latest_Version__r != null ? sm.Latest_Version__r.Version_Number__c : null) ?.toString(),
                'promptOutput'  => (sm.Latest_Version__r != null ? sm.Latest_Version__r.Prompt_Output__c :  null )
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Map<String,Object> createNewSchemaMappingVersion(String recordId){
        try {
            // Create the records and return the created record details
            return SchemaMappingUtil.createNewSchemaMappingVersion(recordId);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void addSObjectAndFields(String recordId, String sobjectApiName, String purposeDescription, String[] selectedFieldApiNames){
        try {
            // Validate record exists
            SchemaUtil.validateRecordId(recordId, Schema.Schema_Mapping__c.getSObjectType());

            if(String.isBlank(sobjectApiName)){
                throw new StringException('Please select an sObject before you continue.');
            }

            if ((selectedFieldApiNames?.isEmpty() == true) || selectedFieldApiNames == null) {
                throw new StringException('Please select at least one sObject field to add to the Schema Mapping.');
            }

            Mapped_sObject__c mso = new Mapped_sObject__c(
                Schema_Mapping__c       = recordId,
                Name                    = sobjectApiName,
                sObjectType__c          = sobjectApiName,
                Purpose_Description__c  = purposeDescription
            );
            insert as system mso;


            Mapped_sObject_Field__c[] msofs = new Mapped_sObject_Field__c[]{};

            for(String fieldName : selectedFieldApiNames){
                msofs.add( new Mapped_sObject_Field__c(
                    Mapped_sObject__c = mso.Id,
                    Name              = fieldName
                ));
            }

            insert as system msofs;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void addChildSObjectAndFields(String recordId, String sobjectApiName, String relationshipField, String purposeDescription, String[] selectedFieldApiNames){
        try {

            // Validate the record id is not blank
            SchemaUtil.validateRecordId(recordId, SChema.Mapped_sObject__c.getSObjectType());

            // Fetch the schema mapping from the parent record
            // This is a mandatory field
            Mapped_sObject__c[] parentMsos = [SELECT Id, Schema_Mapping__c, sObjectType__c FROM Mapped_sObject__c WHERE Id =:recordId LIMIT 1];

            // Validate a parent is found
            if (parentMsos?.isEmpty() != false) {
                throw new StringException('No parent Mapped sObject found for Id "'+recordId+'"');
            }

            // Create a new (child) mapped sObject
            Mapped_sObject__c mso = new Mapped_sObject__c(
                Schema_Mapping__c       = parentMsos[0].Schema_Mapping__c,
                Name                    = sobjectApiName,
                sObjectType__c          = sobjectApiName,
                Purpose_Description__c  = purposeDescription,
                Parent_SObject__c       = parentMsos[0].Id,
                Parent_SObjectType__c   = parentMsos[0].sObjectType__c,
                Relationship_Field__c   = relationshipField
            );
            insert as system mso;


            Mapped_sObject_Field__c[] msofs = new Mapped_sObject_Field__c[]{};

            for(String fieldName : selectedFieldApiNames){
                msofs.add( new Mapped_sObject_Field__c(
                    Mapped_sObject__c = mso.Id,
                    Name              = fieldName
                ));
            }

            insert as system msofs;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}