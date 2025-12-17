/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains a set of utilities for generating Instruction records
 */
public with sharing class SchemaInstructionUtil {
    
    public static Boolean getDefaultRecordExists(){
        
        // Return true if the default record exists
        return String.isNotBlank([
            SELECT Id FROM Schema_Instruction__c 
            WHERE Is_Default__c = true 
            AND Name = :Constant.DEFAULT_INSTRUCTION_NAME 
            WITH SYSTEM_MODE 
            LIMIT 1
        ]?.Id);
    }
    
    
    public static Schema_Instruction__c getDefaultRecord(){

        Schema_Instruction__c[] defaultRecords = [
                SELECT
                    Id,
                    Name,
                    Latest_Version__c,
                    Latest_Version__r.Prompt_Output__c
                FROM Schema_Instruction__c
                WHERE Is_Default__c = true
                AND Name = :Constant.DEFAULT_INSTRUCTION_NAME
                WITH SYSTEM_MODE
                LIMIT 1
        ];

        if(defaultRecords.isEmpty()){
            throw new SchemaInstructionException(Constant.MSG_NO_DEFAULT_INSTRUCTION);
        }

        // Return the default instruction record
        return defaultRecords[0];
    }


    public static String getDefaultInstruction(){
        // Return the default instruction value
        return Util.getStaticResourceBody(Constant.DEFAULT_INSTRUCTIONS_SR_NAME);
    }

    @future
    public static void insertDefaultInstructionsAsync(){
        insertDefaultInstructions();
    }

    /**
     * @description Method that inserts the default instructions based on the Static Resource
     */
    public static void insertDefaultInstructions() {

        if(getDefaultRecordExists()){
            return;
        }

        // Create instructions
        Schema_Instruction__c instructionRecord = new Schema_Instruction__c();
        instructionRecord.Name           = Constant.DEFAULT_INSTRUCTION_NAME;
        instructionRecord.Is_Default__c  = true;
        instructionRecord.External_Id__c = Constant.VAL_INSTRUCTION_UUID;
        insert as system instructionRecord;

        // Create default instructions based on the static resource body
        Schema_Instruction_Version__c instructionVersionRecord = new Schema_Instruction_Version__c();
        instructionVersionRecord.Schema_Instruction__c   = instructionRecord.Id;
        instructionVersionRecord.Prompt_Output__c        = getDefaultInstruction();
        instructionVersionRecord.Prompt_Output_Length__c = (instructionVersionRecord.Prompt_Output__c ?? '')?.length();
        instructionVersionRecord.Prompt_Output_Hash__c   = Util.sha1((instructionVersionRecord.Prompt_Output__c ?? ''));
        instructionVersionRecord.Is_Latest__c            = true;
        instructionVersionRecord.External_Id__c          = Constant.VAL_INSTRUCTION_VERSION_UUID;
        instructionVersionRecord.Version_Number__c       = 1;
        insert as system instructionVersionRecord;

        // Update the parent version with the latest
        instructionRecord.Latest_Version__c = instructionVersionRecord.Id;
        update as system instructionRecord;
    }


    /** **************************************************************************************************** **
     **                                     PRIVATE EXCEPTION CLASSES                                        **
     ** **************************************************************************************************** **/
    /**
     * @description An exception that is thrown when something goes wrong related to the schema instruction
     */
    public class SchemaInstructionException extends Exception{}
}