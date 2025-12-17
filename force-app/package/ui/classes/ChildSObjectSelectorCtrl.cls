/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC Controller Class for selecting child sObjects
 * 
 */
public with sharing class ChildSObjectSelectorCtrl {
    
    public class SObjectInfo {
        @AuraEnabled public String apiName;
        @AuraEnabled public String label;
        @AuraEnabled public Boolean isCustom;
    }

    @AuraEnabled(cacheable=true)
    public static List<SObjectInfo> getSObjects(String parentRecordId, Boolean includeStandard, Boolean includeCustom) {

        if(String.isBlank(parentRecordId)){
            throw new StringException('The parent record Id cannot be empty.');
        }

        // Fetch the schema mapping from the parent record
        // This is a mandatory field
        Mapped_sObject__c[] parentMsos = [SELECT Id, Schema_Mapping__c, sObjectType__c FROM Mapped_sObject__c WHERE Id =:parentRecordId LIMIT 1];
        
        // Validate a parent is found
        if (parentMsos?.isEmpty() != false) {
            throw new StringException('No parent Mapped sObject found for Id "'+parentRecordId+'"');
        }

        List<SObjectInfo> results = new List<SObjectInfo>();
        Set<Schema.SObjectType> childSObjectTypes = new Set<Schema.SObjectType>{};
        Schema.DescribeSObjectResult dsor = ((SObject)Type.forName(parentMsos[0].sObjectType__c).newInstance()).getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED);

        // Defaults if not provided
        includeStandard = includeStandard == null ? true : includeStandard;
        includeCustom   = includeCustom   == null ? true : includeCustom;

        for(Schema.ChildRelationship cr : dsor.getChildRelationships()){
            if(!String.isBlank(cr.getRelationshipName())){
                childSObjectTypes.add(cr.getChildSObject());
            }
        }

        for (Schema.SObjectType sot : childSObjectTypes) {
            
            Schema.DescribeSObjectResult d = sot.getDescribe();

            // Only include sObjects that are accessible and writable (createable)
            if (!d.isAccessible() || !d.isCreateable()) {
                continue;
            }


            // Exclude some system/helper objects that rarely make sense to show
            String name = d.getName();
            if (
                name.endsWith('History') ||
                name.endsWith('Share') ||
                name.endsWith('ChangeEvent') ||
                name.endsWith('Feed') ||
                name.endsWith('FeedComment') ||
                name.endsWith('EventStream') ||
                name.endsWith('Tag') ||
                name.endsWith('TagHistory') ||
                name.endsWith('Log') ||
                name.startsWith('Auth') ||
                name.startsWith('ApexTest') ||
                name == 'ActivityHistory' ||
                name == 'NoteAndAttachment'
            ) {
                continue;
            }

            
            Boolean isCustom = d.isCustom();
            if ((isCustom && !includeCustom) || (!isCustom && !includeStandard)) {
                continue;
            }

            SObjectInfo info = new SObjectInfo();
            info.apiName     = d.getName();
            info.label       = d.getLabel();
            info.isCustom    = isCustom;
            results.add(info);
        }

        // Since Apex doesn't support custom comparator inline for non-primitive, perform simple bubble into map and sort keys
        // Workaround: sort by apiName using a TreeSet of api names and rebuild list
        Map<String, SObjectInfo> byApi = new Map<String, SObjectInfo>();
        for (SObjectInfo i : results) {
            byApi.put(i.apiName, i);
        }
        List<String> keys = new List<String>(byApi.keySet());
        keys.sort();
        List<SObjectInfo> sorted = new List<SObjectInfo>();
        for (String k : keys) {
            sorted.add(byApi.get(k));
        }
        return sorted;
    }

    public class FieldInfo {
        @AuraEnabled public String apiName;
        @AuraEnabled public String label;
        @AuraEnabled public String dataType;
        @AuraEnabled public Boolean isCustom;
        @AuraEnabled public Boolean mandatory;
        @AuraEnabled public Boolean lookupToParent = false;
    }

    @AuraEnabled(cacheable=true)
    public static List<FieldInfo> getFields(String parentRecordId, String sObjectApiName) {
        
        if(String.isBlank(parentRecordId)){
            throw new StringException('The parent record Id cannot be empty.');
        }

        if (String.isBlank(sObjectApiName)) {
            throw new StringException('sObjectApiName cannot be blank');
        }

        // Fetch the schema mapping from the parent record
        Mapped_sObject__c[] parentMsos = [SELECT Id, Schema_Mapping__c, sObjectType__c FROM Mapped_sObject__c WHERE Id =:parentRecordId WITH SYSTEM_MODE LIMIT 1];
        

        Schema.SObjectType parentSObjectType = ((SObject)Type.forName(parentMsos[0].sObjectType__c).newInstance()).getSObjectType();
       

        // Validate a parent is found
        if (parentMsos?.isEmpty() != false) {
            throw new StringException('No parent Mapped sObject found for Id "'+parentRecordId+'"');
        }

        Map<String, Schema.SObjectField> fields = ((SObject)Type.forName(sObjectApiName)?.newInstance())?.getSObjectType()?.getDescribe(SObjectDescribeOptions.DEFERRED)?.fields?.getMap();

        if (fields == null) {
            throw new StringException('Invalid sObjectApiName. sObject "'+sObjectApiName+'" not found in the metadata.');
        }


        List<FieldInfo> out = new List<FieldInfo>();

        for (Schema.SObjectField f : fields.values()) {
            Schema.DescribeFieldResult fd = f.getDescribe();

            // Only include fields that are createable, and skip deprecated/hidden fields
            if((fd.isDeprecatedAndHidden() || (!fd.isCreateable() && !fd.isUpdateable()))   && fd.getName() != 'Id' ){
                continue;
            }

            
            FieldInfo info = new FieldInfo();
            info.apiName = fd.getName();
            info.label = fd.getLabel();
            info.isCustom = fd.isCustom();
            info.dataType = String.valueOf(fd.getType());
            // Mandatory if not nillable and not defaulted on create and not auto-generated
            Boolean autoGen = fd.isAutoNumber() || fd.isCalculated() || fd.isDefaultedOnCreate();
            info.mandatory = !fd.isNillable() && !autoGen;

            // Check the relationship
            if(fd.getType() == Schema.DisplayType.REFERENCE){
                for(Schema.SObjectType sot :  fd.referenceto){
                    if(sot == parentSObjectType){
                        info.lookupToParent = true;
                        break;
                    }
                }
            }

            out.add(info);
        }

        // deterministic order by apiName (cannot sort complex types directly)
        Map<String, FieldInfo> byName = new Map<String, FieldInfo>();
        for (FieldInfo fi : out) {
            byName.put(fi.apiName, fi);
        }
        List<String> names = new List<String>(byName.keySet());
        names.sort();
        List<FieldInfo> sorted = new List<FieldInfo>();
        for (String n : names) {
            sorted.add(byName.get(n));
        }
        return sorted;
    }
}
