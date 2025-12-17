trigger Mapped_sObject_FieldTrigger on Mapped_sObject_Field__c (before insert, before update, before delete) {

    switch on Trigger.operationType {

        when BEFORE_INSERT, BEFORE_UPDATE {

            // Collect the schema mapping ids of the parents
            Set<Id> schemaMappingIds    = new Set<Id>{};

            // List of potential schema mappings we're going to update
            Schema_Mapping__c[] schemaMappingsToUpdate = new Schema_Mapping__c[]{};

            /**
             * POPULATE EXTERNAL ID
             */
            // Populate the external Id if it is not a valid UUID (Basic check on 36 charcters)
            utl.Trg.populateExternalId(Trigger.new,Schema.Mapped_sObject_Field__c.External_Id__c);

            // Mapping between the parent object object and the list of fields this object has
            Map<Id, Map<String, Schema.SObjectField>> parentIdSot = new Map<Id, Map<String, Schema.SObjectField>>();

            // Get all the parent SObjects
            for(Mapped_sObject_Field__c record : Trigger.new) {
                parentIdSot.put(record.Mapped_sObject__c, null);
            }

            // Extract the SObjectTypes so we can get the field describes
            for(Mapped_sObject__c mappedSObj : [SELECT Id, Name, sObjectType__c, Schema_Mapping__c FROM Mapped_sObject__c WHERE Id IN :parentIdSot.keySet() WITH SYSTEM_MODE]) {

                // Add schema mappings
                schemaMappingIds.add(mappedSObj.Schema_Mapping__c);

                // Only extract the list of fields once
                // Try to read this beautifull one liner...
                if(parentIdSot.containsKey(mappedSObj.Id)){
                    parentIdSot.put(
                        mappedSObj.Id,
                        ((SObject)Type.forName(mappedSObj.sObjectType__c)?.newInstance())?.getSObjectType()?.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap()
                    );
                }
            }

            // Let's check the fields
            for(Mapped_sObject_Field__c record : Trigger.new) {
                //if(!parentIdSot.get(record.Mapped_sObject__c)?.containsKey(record.name?.toLowerCase())){
                  //  record.Name.addError('The Field Named "' + record.name + '" does not exist in the metadata. Check the name and validate the namespace.');
                //}else{

                    // Describe the field to get the proper name and the field type
                    DescribeFieldResult dfr = parentIdSot.get(record.Mapped_sObject__c).get(record.name?.toLowerCase()).getDescribe();

                    // Update the name so all the cases are fixed (namespace has to be included or it will break)
                    record.Name         = dfr.getName();
                    record.Type__c      = dfr.getType().toString();
                    record.JSON_Type__c = SchemaUtil.DISPLAY_TYPE_TO_JSON_TYPE_MAP.get(dfr.getType()) ?? Constant.DEFAULT_JSON_TYPE;
                    record.Length__c    = dfr.getLength();
                //}
            }


            /**
             * SCHEMA UPDATED FLAG
             */
            if(!schemaMappingIds.isEmpty()){

                
                
                // Create the new sObjects
                for(Id schemaMappingId : schemaMappingIds){
                    Schema_Mapping__c schemaMappingToUpdate = new Schema_Mapping__c();
                    schemaMappingToUpdate.Id                   = schemaMappingId;
                    schemaMappingToUpdate.Schema_Changed__c    = true;
                    
                    // Add sObject to update list
                    schemaMappingsToUpdate.add(schemaMappingToUpdate);
                }

                // Update the schema mapping records
                update as system schemaMappingsToUpdate;
            }


            /**
             * IGNORE TRIGGER FLAG
             */
            // Reset the Ignore Triggers flag on all records
            utl.Trg.resetIgnoreTriggersFlag(Trigger.new,Schema.Mapped_sObject_Field__c.Ignore_Triggers__c);
        }


        when BEFORE_DELETE {
            
            /**
             * SCHEMA CHANGED FLAG UPDATE
             */
            // Unique set of schema mapping ids that we're going to update with a change flag
            Set<Id> schemaMappingIds = new Set<Id>{};

            // Unique set of mapped sObjects that we need to query for the parent info
            Set<Id> mappedSObjectIds = new Set<Id>{};

            // List of potential schema mappings we're going to update
            Schema_Mapping__c[] schemaMappingsToUpdate = new Schema_Mapping__c[]{};

            // Get all the parent Maaped SObject Ids
            for(Mapped_sObject_Field__c record : Trigger.old) {
                mappedSObjectIds.add(record.Mapped_sObject__c);
            }

            // Query the parent sObject's Schema mapping Ids and add them to the list of Schema Mapping recods we are going to update
            for(Mapped_sObject__c mappedSObj : [SELECT Id, Schema_Mapping__c FROM Mapped_sObject__c WHERE Id IN :mappedSObjectIds WITH SYSTEM_MODE]) {
                schemaMappingIds.add(mappedSObj.Schema_Mapping__c);
            }

            // When we have schema records to update, create record structure for upsert
            if(!schemaMappingIds.isEmpty()){
                
                // Create the new sObjects
                for(Id schemaMappingId : schemaMappingIds){
                    Schema_Mapping__c schemaMappingToUpdate = new Schema_Mapping__c();
                    schemaMappingToUpdate.Id                    = schemaMappingId;
                    schemaMappingToUpdate.Schema_Changed__c     = true;
                    
                    // Add sObject to update list
                    schemaMappingsToUpdate.add(schemaMappingToUpdate);
                }

                // Update the schema mapping records
                update as system schemaMappingsToUpdate;
            }
        }
    }
}