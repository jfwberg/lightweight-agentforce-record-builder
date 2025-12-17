/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC Controller Class for managing schema instructions
 * 
 */
public with sharing class SchemaInstructionCtrl {

    @AuraEnabled
    public static Boolean isDefaultInstruction(String recordId){
        try {
            // Validate record exists
            SchemaUtil.validateRecordId(recordId, Schema.Schema_Instruction__c.getSObjectType());

            // Fetch the latest version
            return [
                SELECT
                    Id
                FROM Schema_Instruction__c
                WHERE Is_Default__c = true
                AND Name = :Constant.DEFAULT_INSTRUCTION_NAME
                WITH SYSTEM_MODE
                LIMIT 1
            ]?.Id == recordId;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static String loadSchemaInstructionVersion(String recordId){
        try {
            // Validate record exists
            SchemaUtil.validateRecordId(recordId, Schema.Schema_Instruction__c.getSObjectType());

            // Fetch the latest version
            return SchemaInstructionUtil.getDefaultRecord()?.Latest_Version__r.Prompt_Output__c;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled 
    public static Map<String,Object> resetDefaultInstruction(){
        try{
            return createSchemaInstructionVersion(
                SchemaInstructionUtil.getDefaultRecord()?.Id,
                SchemaInstructionUtil.getDefaultInstruction()
            );
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }   
    }


    @AuraEnabled
    public static Map<String,Object> createSchemaInstructionVersion(String recordId, String instructions){
        try {
            
            // Validate record exists
            SchemaUtil.validateRecordId(recordId, Schema.Schema_Instruction__c.getSObjectType());

            Schema_Instruction_Version__c siv = new Schema_Instruction_Version__c(
                Is_Latest__c            = true,
                Schema_Instruction__c   = recordId,
                Version_Number__c       = ([SELECT Version_Number__c FROM Schema_Instruction_Version__c WHERE Schema_Instruction__c = :recordId AND Version_Number__c != NULL WITH SYSTEM_MODE ORDER BY Version_Number__c DESC LIMIT 1]?.Version_Number__c ?? 0) + 1,
                Prompt_Output__c        = instructions,
                External_Id__c          = UUID.randomUUID().toString(),
                Prompt_Output_Length__c = instructions?.length(),
                Prompt_Output_Hash__c   = EncodingUtil.convertToHex(Crypto.generateDigest('SHA1', Blob.valueOf(instructions)))
            );

            // Create the new version
            insert as system siv;

            // Return the version details
            return new Map<String,Object>{
                'versionRecordId'   => siv.Id,
                'versionRecordName' => [SELECT Name FROM Schema_Instruction_Version__c WHERE Id=:siv.Id WITH SYSTEM_MODE LIMIT 1 ]?.Name,
                'versionNumber'     => String.valueOf(siv.Version_Number__c)
            };

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}