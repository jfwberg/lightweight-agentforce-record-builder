trigger Mapped_sObjectTrigger on Mapped_sObject__c (before insert, before update, after insert, after update, before delete) {
    
    switch on Trigger.operationType {

        when BEFORE_INSERT, BEFORE_UPDATE {
            
            // Error flag to prevent updates
            Boolean hasError = false;
            
            // Collect the schema mapping ids of the parents
            Set<Id> schemaMappingIds    = new Set<Id>{};

            // Collect the schema mapping ids where mapped objects are inserted or deleted (change in sObject hierarchy)
            Set<Id> hierarchyMappingIds = new Set<Id>{};

            // List of potential schema mappings we're going to update
            Schema_Mapping__c[] schemaMappingsToUpdate = new Schema_Mapping__c[]{};

            /**
             * POPULATE EXTERNAL ID
             */
            // Populate the external Id if it is not a valid UUID (Basic check on 36 charcters)
            utl.Trg.populateExternalId(Trigger.new,Schema.Mapped_sObject__c.External_Id__c);


            /**
             * FIELD VALIDATION
             */
            // Validate that if there is a parent record, that the metadata exists
            for(Mapped_sObject__c rec : trigger.new){

                // Skip triggers when flagged
                if(rec.Ignore_Triggers__c){continue;}

                // Add schema mappings
                schemaMappingIds.add(rec.Schema_Mapping__c);
                
                // New records (no id) need to be added for the hierarchy update
                if(String.isBlank(rec.Id)){
                    hierarchyMappingIds.add(rec.Schema_Mapping__c);
                }
                
                // Fetch sObject types for object validation
                Type mappedSObjectType = Type.forName(rec?.sObjectType__c?.trim() ?? '');

                // Validate the sObject exists
                if (mappedSObjectType == null) {
                    rec.sObjectType__c.addError('No sObject with the name: "' + rec.sObjectType__c + '" found in the metadata.');
                    hasError = true;
                    break;
                }

                // If there is no parent, we're done
                if(rec.Parent_sObject__c == null){
                    continue;
                }

                /**
                 * PARENT SOBJECT VALIDATIONS
                 */
                // Check blank fields
                if(String.isBlank(rec.Parent_sObjectType__c)){
                    rec.Parent_sObjectType__c.addError('The Parent sObjectType field cannot be blank if a Parent Mapped sObject is specified.');
                    hasError = true;
                    break;
                }

                // Check blank fields
                if(String.isBlank(rec.Relationship_Field__c)){
                    rec.Relationship_Field__c.addError('The (Parent) Relationship Field cannot be blank if a Parent Mapped sObject is specified.');
                    hasError = true;
                    break;
                }

                // Check the parent sObject Type exists
                Type parentSObjectType = Type.forName(rec.Parent_sObjectType__c?.trim() ?? '');

                // Check if the parent object exists in the metadata
                if (parentSObjectType == null) {
                    rec.Parent_sObjectType__c.addError('No sObject with the name: "' + rec.Parent_sObjectType__c + '" found in the metadata.');
                    hasError = true;
                    break;
                }

                // Error Tracking
                Boolean relationshipIsValid      = false;
                Boolean relationshipFieldIsValid = false;
                
                // Check the field and relationship (Done this way to cater for polymorphic fields)
                for(Schema.ChildRelationship cr : ((SObject) parentSObjectType.newInstance()).getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED).getChildRelationships()){
                    if(!String.isBlank(cr.getRelationshipName())){
                        if(cr.childsobject?.toString()?.equalsIgnoreCase(rec.sObjectType__c)){
                            
                            // All is valid and good
                            relationshipIsValid =  true;

                            // Check if the relationship field target lookup matches the parent sObject
                            if(cr.field?.toString()?.equalsIgnoreCase(rec.Relationship_Field__c)){

                                // All is good
                                relationshipFieldIsValid = true;

                                // Auto populate the relationship name
                                rec.Relationship_Name__c = cr.getRelationshipName();
                                
                                // Fixes any case / namespace issues and keeps it consistent
                                rec.Relationship_Field__c= cr.field?.toString();
                            }
                        }
                    }
                }

                // Add a warning if there are no relationships between the parent and child sObject
                if(!relationshipIsValid){
                    rec.Parent_sObjectType__c.addError('"' + rec.Parent_sObjectType__c + '" does not have any child relationship(s) to "' +rec.sObjectType__c+ '"');
                    hasError = true;
                    break;
                }

                // Add a warning that the field is not a valid lookup field for what we want to do
                if(!relationshipFieldIsValid){
                    rec.Relationship_Field__c.addError('The field "' + rec.Relationship_Field__c + '" on sObject "'+rec.sObjectType__c+'" does not lookup to sObject "' +rec.Parent_sObjectType__c+ '"');
                    hasError = true;
                    break;
                }
            }


            /**
             * SCHEMA UPDATED FLAG
             */
            if(!hasError && !schemaMappingIds.isEmpty()){
                
                // Create the new sObjects
                for(Id schemaMappingId : schemaMappingIds){
                    Schema_Mapping__c schemaMappingToUpdate = new Schema_Mapping__c();
                    schemaMappingToUpdate.Id                   = schemaMappingId;
                    schemaMappingToUpdate.Schema_Changed__c    = true;

                    // Update the hierarchy for inserted records
                    if(hierarchyMappingIds.contains(schemaMappingId)){
                        schemaMappingToUpdate.Hierarchy_Changed__c = true;
                    }
                    
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
            utl.Trg.resetIgnoreTriggersFlag(Trigger.new,Schema.Mapped_sObject__c.Ignore_Triggers__c);
        }


        when BEFORE_DELETE {
            
            /**
             * SCHEMA CHANGED + HIERARCHY SCHEMA FLAG UPDATE
             */
            // Unique set of schema mapping ids that we're going to update with a change flag
            Set<Id> schemaMappingIds    = new Set<Id>{};

            // List of potential schema mappings we're going to update
            Schema_Mapping__c[] schemaMappingsToUpdate = new Schema_Mapping__c[]{};

            // Validate that if there is a parent record, that the metadata exists
            for(Mapped_sObject__c rec : trigger.old){

                // Skip triggers when flagged, don't remove this as it will break the order update process
                if(rec.Ignore_Triggers__c){continue;}

                // Add schema mappings
                schemaMappingIds.add(rec.Schema_Mapping__c);
            }

            // When we have schema records to update, create record structure for upsert
            if(!schemaMappingIds.isEmpty()){
                
                // Create the new sObjects
                for(Id schemaMappingId : schemaMappingIds){
                    Schema_Mapping__c schemaMappingToUpdate = new Schema_Mapping__c();
                    schemaMappingToUpdate.Id                    = schemaMappingId;
                    schemaMappingToUpdate.Schema_Changed__c     = true;
                    schemaMappingToUpdate.Hierarchy_Changed__c  = true;
                    
                    // Add sObject to update list
                    schemaMappingsToUpdate.add(schemaMappingToUpdate);
                }

                // Update the schema mapping records
                update as system schemaMappingsToUpdate;
            }
        }
    }
}