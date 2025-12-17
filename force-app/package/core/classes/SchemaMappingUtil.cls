/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains the actions that are required to
 *                 generate schema mapping prompt outputs
 */
public with sharing class SchemaMappingUtil {

    /**
     * @description Creates a new Schema Mapping Version record and prompt output for the provided Schema_Mapping__c.
     *              - Validates the input record Id against Schema_Mapping__c
     *              - Gathers mapped sObjects and fields
     *              - Builds a normalized JSON structure for prompt output
     *              - Upserts a new Schema_Mapping_Version__c when changes are detected
     *              - Returns version metadata and change state
     * @param recordId The Id of the Schema_Mapping__c record to generate a new version for.
     * @return Map containing:
     *         - versionRecordId   (Id): The Id of the Schema_Mapping_Version__c record (existing latest if unchanged)
     *         - versionRecordName (String): The Name of the version record
     *         - versionNumber     (Decimal): The numeric version
     *         - isChanged         (Boolean): True if a new version was created; false if no changes detected
     */
    public static Map<String,Object> createNewSchemaMappingVersion(String recordId){
       
        // Validate we have a valid record Id
        SchemaUtil.validateRecordId(recordId, Schema.Schema_Mapping__c.getSObjectType());

        // Query the purpose description so it can be added to the prompt
        String schemaMappingPurposeDescription = [SELECT Purpose_Description__c FROM Schema_Mapping__c WHERE Id = :recordId WITH SYSTEM_MODE LIMIT 1]?.Purpose_Description__c;

        // Query all the required data for the sObjects and The fields
        Map<Id,Mapped_sObject__c> sObjectMap = new Map<Id,Mapped_sObject__c>([
            SELECT
                Name, Parent_sObject__c, Relationship_Name__c, Schema_Mapping__c, sObjectType__c,Purpose_Description__c,
                (SELECT Id FROM Child_sObjects__r),
                (SELECT Id, Name, JSON_Type__c, Type__c, Length__c, Purpose_Description__c FROM Mapped_Fields__r)
            FROM
                Mapped_sObject__c
            WHERE
                Schema_Mapping__c = :recordId
            WITH SYSTEM_MODE
        ]);

        // Validate the record id exists
        if (sObjectMap.isEmpty()) {
            throw new SchemaMappingException(
                String.format(Constant.MSG_NO_MAPPED_SOBJECTS, new String[]{recordId})    
            );
        }

        // Create a new JSON Structure
        List<Map<String,Object>> sObjectMapForJSON = new List<Map<String,Object>>();

        // Start at the top level with the sObject that does not have any parents
        for(Integer i=0, max=sObjectMap.values().size(); i<max; i++){

            if(String.isBlank(sObjectMap.values()[i].Parent_sObject__c)){

                Map<String,Object> parent = new Map<String,Object>();

                traverse(sObjectMap.values()[i], parent, sObjectMap);

                sObjectMapForJSON.add(parent);
            }
        }

        // Create the records and return the created record details
        return createSchemaMappingVersion(
            recordId, 
            schemaMappingPurposeDescription,
            new Map<String,List<Map<String,Object>>>{'records' => sObjectMapForJSON}
        );
    }


    /**
     * @description Creates or returns the latest Schema Mapping Version for a given Schema_Mapping__c record.
     *              Compares a SHA1 hash of the constructed prompt output against the last stored version to
     *              determine whether a new version should be created. If no changes are detected, it returns
     *              the previous version metadata and ensures the parent Schema_Mapping__c.Schema_Changed__c is false.
     * @param parentId The Id of the parent Schema_Mapping__c record.
     * @param schemaMappingPurposeDescription A purpose description to include at the top of the prompt output.
     * @param sObjectMapForJSON A normalized structure representing mapped sObjects and their fields to serialize into JSON.
     * @return Map containing:
     *         - versionRecordId   (Id): The Id of the created (or existing) Schema_Mapping_Version__c record
     *         - versionRecordName (String): The Name of the version record
     *         - versionNumber     (Decimal): The numeric version
     *         - isChanged         (Boolean): True if a new version was created; false if no changes detected
     */
    private static Map<String,Object> createSchemaMappingVersion(String parentId, String schemaMappingPurposeDescription, Map<String, List<Map<String,Object>>> sObjectMapForJSON){
        
        // Query previous version details
        Schema_Mapping_Version__c[] previousVersion = [ SELECT Id, Name, Version_Number__c , Prompt_Output_Hash__c 
                                                        FROM Schema_Mapping_Version__c 
                                                        WHERE Schema_Mapping__c = :parentId AND Version_Number__c != NULL 
                                                        WITH SYSTEM_MODE ORDER BY Version_Number__c DESC LIMIT 1];
        
        // Check if a previous version has found
        Boolean hasPrevious = !previousVersion.isEmpty();

        // Create the new prompt output
        String  promptOutput = String.format(
            Constant.PROMPT_OUTPUT_HEADERS_AND_BODY,
            new String[]{
                schemaMappingPurposeDescription,
                JSON.serializePretty(sObjectMapForJSON)
            }
        );
        
        // Create a hash for version matching purposes
        String hash = Util.sha1(promptOutput);

        // Check if the has has changed, if not we dont require any updates
        Boolean isChanged = hash != (hasPrevious ? previousVersion[0]?.Prompt_Output_Hash__c : null);

        // If there ar eno changes the is nothing we have to do
        if(!isChanged){
            
            // Update the parent schema mapping and untick the schema change flag
            // If there are no schema changes, there is no schema change. Bit of an edge case, but occurs
            Schema_Mapping__c schemaMappingToUpdate = new Schema_Mapping__c();
            schemaMappingToUpdate.Id                    = parentId;
            schemaMappingToUpdate.Schema_Changed__c     = false;
            
            // Update the parent
            update as system schemaMappingToUpdate;
            
            return new Map<String,Object>{
                'versionRecordId'   => previousVersion[0].Id,
                'versionRecordName' => previousVersion[0].Name,
                'versionNumber'     => previousVersion[0].Version_Number__c,
                'isChanged'         => false
            };
        }

        // Update the version 
        Decimal versionNumber = hasPrevious ? previousVersion[0]?.Version_Number__c : 0;
        
        // Create the new mapping
        Schema_Mapping_Version__c smv = new Schema_Mapping_Version__c(
            Is_Latest__c            = true,
            Schema_Mapping__c       = parentId,
            Version_Number__c       = versionNumber + 1,
            Prompt_Output__c        = promptOutput,
            External_Id__c          = UUID.randomUUID().toString(),
            Prompt_Output_Length__c = promptOutput?.length(),
            Prompt_Output_Hash__c   = hash
        );

        // Create the new version
        insert as system smv;

        // Update the parent schema mapping and untick the schema change flag
        Schema_Mapping__c schemaMappingToUpdate = new Schema_Mapping__c();
        schemaMappingToUpdate.Id                = parentId;
        schemaMappingToUpdate.Schema_Changed__c = false;
        
        // Update the parent
        update as system schemaMappingToUpdate;

        // Return the version details
        return new Map<String,Object>{
            'versionRecordId'   => smv.Id,
            'versionRecordName' => [SELECT Name FROM Schema_Mapping_Version__c WHERE Id=:smv.Id WITH SYSTEM_MODE LIMIT 1 ]?.Name,
            'versionNumber'     => smv.Version_Number__c,
            'isChanged'         => false
        };
    }


    /**
     * @description Recursively builds the JSON structure for a mapped sObject and its child relationships.
     *              Populates attribute metadata and field output templates, and appends child records into
     *              relationship lists based on the configured Relationship_Name__c.
     * @param record The current Mapped_sObject__c record to render.
     * @param outputJSON The Map reference that will be populated with attributes, fields, and child relationship records.
     * @param sObjectMap Lookup of all Mapped_sObject__c records by Id for quick traversal and child resolution.
     * @return Void. Mutates outputJSON in place to include the hierarchical structure.
     */
    private static void traverse(Mapped_sObject__c record, Map<String,Object> outputJSON, Map<Id,Mapped_sObject__c> sObjectMap){

        outputJSON.put(
            'attributes', 
            new Map<String,Object>{
                'type'               => record.sObjectType__c,
                'referenceId'        => '[Replace with the referenceId]',
                'purposeDescription' => record.Purpose_Description__c
            }
        );

        // Create the field output String
        for(Mapped_sObject_Field__c field : record.Mapped_Fields__r){
            outputJSON.put(
                field.Name,
                '{{' + String.format(
                    Constant.FIELD_OUTPUT_TEMPLATE,
                    new Object[]{
                        field.JSON_Type__c,
                        field.Length__c,
                        field.Purpose_Description__c
                    }
                ) + '}}'
            );
        }

        // Handle child records
        if (record.Child_sObjects__r.size() > 0) {
            for (Mapped_sObject__c childRecord : record.Child_sObjects__r) {
                String relName = sObjectMap.get(childRecord.Id).Relationship_Name__c;

                // Ensure relationship list exists
                if (!outputJSON.containsKey(relName)) {
                    outputJSON.put(relName, new Map<String,List<Map<String, Object>>>{'records' => new List<Map<String, Object>>()});
                }
                List<Map<String, Object>> relList =  ((Map<String,List<Map<String, Object>>>)outputJSON.get(relName)).get('records');

                // Build child JSON by reusing traverse
                Map<String, Object> child = new Map<String, Object>();
                traverse(sObjectMap.get(childRecord.Id), child, sObjectMap);

                // Append to relationship list
                relList.add(child);
            }
        }
    }

    /**
     * @description Exception thrown when there is an input exception
     */
    public class SchemaMappingException extends Exception{}
}