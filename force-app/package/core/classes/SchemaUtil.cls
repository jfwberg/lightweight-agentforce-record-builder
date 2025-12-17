/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains the a set of common Schema utilities
 */
public with sharing class SchemaUtil {

    // Map that converts the display types to the corresponding JSON types
    public static final Map<Schema.DisplayType, String> DISPLAY_TYPE_TO_JSON_TYPE_MAP = new Map<Schema.DisplayType,String> { 
        Schema.DisplayType.Time                         => 'Time',
        Schema.DisplayType.Date                         => 'Date',
        Schema.DisplayType.DateTime                     => 'Datetime',
        Schema.DisplayType.Address                      => 'Object',
        Schema.DisplayType.Location                     => 'Object',
        Schema.DisplayType.Boolean                      => 'Boolean',
        Schema.DisplayType.Integer                      => 'Number',
        Schema.DisplayType.Double                       => 'Number',
        Schema.DisplayType.Currency                     => 'Number',
        Schema.DisplayType.Percent                      => 'Number',
        Schema.DisplayType.Long                         => 'Number',
        Schema.DisplayType.FloatArray                   => 'Array',
        Schema.DisplayType.String                       => 'String',
        Schema.DisplayType.TextArea                     => 'String',
        Schema.DisplayType.EncryptedString              => 'String',
        Schema.DisplayType.Phone                        => 'String',
        Schema.DisplayType.Email                        => 'String',
        Schema.DisplayType.Url                          => 'String',
        Schema.DisplayType.Picklist                     => 'String',
        Schema.DisplayType.ComboBox                     => 'String',
        Schema.DisplayType.Id                           => 'String',
        Schema.DisplayType.Reference                    => 'REFERENCE',
        Schema.DisplayType.Base64                       => 'String',
        Schema.DisplayType.Json                         => 'String',
        Schema.DisplayType.TextArray                    => 'Array',
        Schema.DisplayType.MultiPicklist                => 'Array',
        Schema.DisplayType.DataCategoryGroupReference   => 'String',
        Schema.DisplayType.sObject                      => 'Object',
        Schema.DisplayType.ComplexValue                 => 'Object',
        Schema.DisplayType.AnyType                      => 'Object'
    };


    /**
     * @description Method to validate if a record Id is valid and exists
     * @param  recordId       The record id to check
     * @param  sObjectType    The sObject type of the record Id to check against
     * @throws InputException Throws an input exception if there are any issues
     */
    public static void validateRecordId(String recordId, Schema.SObjectType sObjectType){

        // Basic input validation
        if(String.isBlank(recordId) || sObjectType == null){
            throw new  InputException(Constant.MSG_ID_SOBJECT_TYPE_MANDATORY);
        }

        // Check that the Id is valid
        try{
            Id myId = recordId;
        }catch(Exception e){
            throw new  InputException(Constant.MSG_INVALID_ID);
        }

        // Check the sObject type of the Id matches the one of the input record
        if(Id.valueOf(recordId).getSobjectType() != sObjectType ){
            throw new  InputException(
                String.format(
                    Constant.MSG_INVALID_ID_TYPE,
                    new Object[]{Id.valueOf(recordId).getSobjectType(), sObjectType}
                )
            );
        }

        // Query the record to validate it exists
        if(Database.query('SELECT Id FROM ' +sObjectType?.toString() + ' WHERE Id = \'' +recordId+ '\'').isEmpty()){
            throw new InputException(
                String.format(
                    Constant.MSG_NO_RECORDS_FOUND_FOR_ID,
                    new Object[]{recordId}
                )
            );            
        }
    }


    /**
     * @description Exception thrown when there is an input exception
     */
    public class InputException extends Exception{}
}
