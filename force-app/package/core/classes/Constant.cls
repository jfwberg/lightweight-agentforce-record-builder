/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains all constants used in the app
 */
public with sharing class Constant {

    // Schema Util Values
    public static final String DEFAULT_JSON_TYPE              = 'String';
    
    // Apex Unit Test Values
    public static final String VAL_FORCED_EXCEPTION           = 'FORCED_EXCEPTION';
    public static final String VAL_APEX_UNIT_TEST_JSON        = 'apex_unit_test_json';
    public static final String VAL_PERMISSION_SET_NAME        = 'lightweight_agentforce_record_builder_admin';

    // Action Platform Event Values
    public static final String VAL_TYPE_LOG_MESSAGE           = 'LOG_MESSAGE';
    public static final String VAL_TYPE_INSERT_PERM_SET       = 'INSERT_PERM_SET';
    public static final String VAL_TYPE_INSERT_INSTRUCTIONS   = 'VAL_TYPE_INSERT_INSTRUCTIONS';


    // Instruction Values
    public static final String DEFAULT_INSTRUCTION_NAME       = 'Default';
    public static final String DEFAULT_INSTRUCTIONS_SR_NAME   = 'DEFAULT_INSTRUCTIONS';
    public static final String VAL_INSTRUCTION_UUID           = '506be2ee-3a93-48a8-8e98-23a3e787ede1';
    public static final String VAL_INSTRUCTION_VERSION_UUID   = '2ef97c7e-1c73-4f54-8025-67fcfe266e3d';

    // Schema Mapping Values
    public static final String FIELD_OUTPUT_TEMPLATE          = '[DATA_TYPE]{0}[/DATA_TYPE][DATA_LENGTH]{1}[/DATA_LENGTH][PURPOSE]{2}[/PURPOSE]';
    public static final String PROMPT_OUTPUT_HEADERS_AND_BODY = '\n\n## SCHEMA MAPPING PURPOSE DESCRIPTION\n{0}\n\n## SCHEMA MAPPING JSON OUTPUT FORMAT\n```json\n{1}\n```';

    // Schema Mapping Messages
    public static final String MSG_NO_MAPPED_SOBJECTS         = 'No Mapped sObjects found for Schema Mapping Id "{0}"';
    
    // Schema Instruction Messages
    public static final String MSG_NO_DEFAULT_INSTRUCTION     = 'No default instruction record found.';
    
    // Schema Util Messages
    public static final String MSG_ID_SOBJECT_TYPE_MANDATORY  = 'Record Id and sObjectType are mandatory.';
    public static final String MSG_INVALID_ID                 = 'Record Id is not a valid Id';
    public static final String MSG_INVALID_ID_TYPE            = 'The sObjectType of the Record Id ("{0}") does not match the supplied sObjectType ("{1}")';
    public static final String MSG_NO_RECORDS_FOUND_FOR_ID    = 'No records found for Id "{0}"';
    
    // Util Messages
    public static final String MSG_STATIC_RESOURCE_ERROR      = 'No static resource with the name "{0}" found in the metadata';
    public static final String MSG_INVALID_PERMISSION_SET     = 'Permission Set "{0}" not found';   
}