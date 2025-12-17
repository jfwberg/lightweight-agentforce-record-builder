/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains a set of shared utilities
 *
 * @false-positive PMD.AvoidGlobalModifier This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                         Implementation, so global is the way to open up this
 *                                         utility for global use.
 * @note           This class is to be used in a managed package and contains Global methods that
 *                 should be made public or private in org based implementations or unlocked
 *                 packages
 */
@SuppressWarnings('PMD.AvoidGlobalModifier,PMD.OperationWithLimitsInLoop')
global with sharing class AgentforceRecordCreatorFlow {

    /**
     * @description Request for the Flow
     * @param jsonString JSON string of the hierarchy
     */
    global class Request {
        @InvocableVariable(required=false)
        global String schemaMappingRecordId;

        @InvocableVariable(required=true)
        global String jsonString;
    }


    /**
     * @description ApexResponseType with record creation details
     */
    global class Response {
        @InvocableVariable global String upsertResultRecordId;
        @InvocableVariable global String errorMessage;
    }


    /**
     * @description Main Flow entry
     * @param requests List of Request objects
     * @return      List of Response objects
     */
    @InvocableMethod(
        label       = 'Agentforce: Build Records from a Prompt Template JSON Output'
        description = 'Creates an sObject JSON hierarchy based on a pre-defined Schema Mapping that inserts parent-child records, returning the created record and parent IDs.'
        category    = 'Agentforce Record Builder'
    )
    global static List<Response> run(List<Request> requests) {

        // List of responses to return
        List<Response> outputs = new List<Response>();

        // Handle all requests
        for (Request req : requests) {

            // New response object
            Response response = new Response();

            try {
                // Force an exception for Unit Test Purposes
                utl.Tst.forceException(Constant.VAL_FORCED_EXCEPTION);
                
                // Create the records based on the JSON result
                response.upsertResultRecordId = record.Tree.upsertAndReturnResultRecordId(req.jsonString);

                // Update the result
                record__Upsert_Result__c result = new record__Upsert_Result__c(
                    Id                = response.upsertResultRecordId,
                    Schema_Mapping__c = req.schemaMappingRecordId
                );
                update as system result;

            } catch (Exception e) {
                response.errorMessage = e.getMessage();
            }

            // Add resposne to the output
            outputs.add(response);

            // There should always be one record, but just in case
            break;
        }
        return outputs;
    }
}