/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC Controller Class updating the hierarcy
 * 
 */
public with sharing class UpdateHierarchyCtrl {

    @AuraEnabled
    public static HierarchyUtil.TreeResult buildHierarchy(Id schemaMappingId) {
        try{
            // Validate record exists
            SchemaUtil.validateRecordId(schemaMappingId, Schema.Schema_Mapping__c.getSObjectType());

            // Execute the logic
            return HierarchyUtil.buildHierarchy(schemaMappingId);

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}