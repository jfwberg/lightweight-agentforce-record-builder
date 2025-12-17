/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC Controller Class for selecting sObjects
 * 
 * @todo           Tidy the whole thing up
 */
public with sharing class SObjectSelectorCtrl {
    
    public class SObjectInfo {
        @AuraEnabled public String apiName;
        @AuraEnabled public String label;
        @AuraEnabled public Boolean isCustom;
    }

    @AuraEnabled(cacheable=true)
    public static List<SObjectInfo> getSObjects(Boolean includeStandard, Boolean includeCustom) {
        // Defaults if not provided
        includeStandard = includeStandard == null ? true : includeStandard;
        includeCustom = includeCustom == null ? true : includeCustom;

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        List<SObjectInfo> results = new List<SObjectInfo>();

        for (Schema.SObjectType sot : gd.values()) {
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
            info.apiName = name;
            info.label = d.getLabel();
            info.isCustom = isCustom;
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
    }

    @AuraEnabled(cacheable=true)
    public static List<FieldInfo> getFields(String sobjectApiName) {
        if (String.isBlank(sobjectApiName)) {
            return new List<FieldInfo>();
        }
        Schema.SObjectType sot = Schema.getGlobalDescribe().get(sobjectApiName);
        if (sot == null) {
            return new List<FieldInfo>();
        }
        Schema.DescribeSObjectResult d = sot.getDescribe();
        Map<String, Schema.SObjectField> fields = d.fields.getMap();

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
