/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains a set of shared utilities
 */
public with sharing class Util {

    /** **************************************************************************************************** **
     **                                       PUBLIC UTILITY METHODS                                         **
     ** **************************************************************************************************** **/
    /**
     * @description Method to create a SHA1 hash
     * @param dataToHash The data to be hashed
     * @return      The hashed data
     */
    public static String sha1(String dataToHash){
        return EncodingUtil.convertToHex(Crypto.generateDigest('SHA1', Blob.valueOf(dataToHash)));
    }


    /**
     * @description Method to get a text body from a static resource
     *              Ideal if you have stored cert data (temporarily) in a static resource or during
     *              apex tests
     * @param       staticResourceName   The developer name of the static resource you want the body
     *                                   value from
     * @return      Static resource body
     * @throws      InvalidDataException There is an issue with the static resource
     */
    public static String getStaticResourceBody(String staticResourceName){
        try{
            return ([SELECT Body FROM StaticResource WHERE Name = :staticResourceName WITH SYSTEM_MODE LIMIT 1].Body)?.toString();
        }catch(System.QueryException e){
            throw new InvalidDataException(String.format(Constant.MSG_STATIC_RESOURCE_ERROR, new String[]{staticResourceName}));
        }
    }

    @future
    public static void assignPermissionSetAsync(Id installingUserId, String permissionSetApiName){
        assignPermissionSet(installingUserId,permissionSetApiName);
    }
    
    /**
     * @description Method to assign the default permission set to the running user
     * @param installingUserId The Id of the user currently installing the package
     */
    public static void assignPermissionSet(Id installingUserId, String permissionSetApiName){

        // Potential new permission set assignment
        PermissionSetAssignment newPsa;

        // Some funky stuff happens with the namespace, so add a wildcard to solve the issue
        String permsetNameInQuery = '%' + permissionSetApiName;

        // Query the new permission set Id
        PermissionSet[] psList        = [
            SELECT Id FROM PermissionSet
            WHERE Name LIKE :permsetNameInQuery
            WITH SYSTEM_MODE LIMIT 1
        ];

        // Validate the permission set exist
        if(psList.isEmpty()){throw new StringException( String.format(
            Constant.MSG_INVALID_PERMISSION_SET,
            new String[]{permsetNameInQuery}
        ));}

        // Check if the installing user has the permission set
        PermissionSetAssignment[] psa = [
                                            SELECT Id FROM PermissionSetAssignment
                                            WHERE   AssigneeId      = :installingUserId
                                            AND     PermissionSetId = :psList[0].Id
                                            WITH SYSTEM_MODE
                                        ];

        // Create the permission set assignment if it does not exist
        if(psa.isEmpty()){
            newPsa =  new PermissionSetAssignment(
                AssigneeId      = installingUserId,
                PermissionSetId = psList[0].Id
            );
            insert as system newPsa;
        }
    }


    /** **************************************************************************************************** **
     **                                     PRIVATE EXCEPTION CLASSES                                        **
     ** **************************************************************************************************** **/
    /**
     * @description An exception that is thrown when something goes wrong retrieving
     *              any (meta) data
     * @note        This class is private and test visible as it should only be ever caught
     *              when an Apex Unit Test is running and never from normal code
     */
    @TestVisible
    private with sharing class InvalidDataException extends Exception{}
}