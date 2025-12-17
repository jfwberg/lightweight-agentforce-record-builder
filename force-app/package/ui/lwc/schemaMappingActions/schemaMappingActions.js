// Standard LWC
import { LightningElement, api } 		 from "lwc";
import LightningAlert 					 from 'lightning/alert';
import LightningConfirm 				 from 'lightning/confirm';
import { RefreshEvent } 				 from 'lightning/refresh';

// Modals
import AddSObjectModal 					 from 'c/addSobjectToSchemaModal';
import SObjectHierachyModal 			 from 'c/hierarchyModal';
import ShowActiveSchemaPromptOutputModal from 'c/showActiveSchemaPromptOutputModal';
import TestSchemaMappingModal 			 from 'c/testSchemaMappingModal';

// Apex
import createNewSchemaMappingVersion     from '@salesforce/apex/SchemaActionsCtrl.createNewSchemaMappingVersion';

// Main class
export default class SchemaMappingActions extends LightningElement {

	@api recordId;
	@api objectApiName;

	/** **************************************************************************************************** **
	 **                                            CLICK HANDLERS                                            **
	 ** **************************************************************************************************** **/
	async handleClickAddSObjectToSchema(){
		const result = await AddSObjectModal.open({
			size		: 'small',
			description	: 'Add sObject To Schema Mapping Modal',
			content		: this.recordId
		});

		// Refresh the related lists
		if (result?.refresh) {
      		this.dispatchEvent(new RefreshEvent());
    	}
	}


	async handleClickOpenUpdateSObjectHierarchyModal(){
		const result = await SObjectHierachyModal.open({
			size		: 'small',
			description	: 'Update the sObject Hierarchy',
			content		: this.recordId
		});

		// Refresh the related lists
		if (result?.refresh) {
      		this.dispatchEvent(new RefreshEvent());
    	}
	}
	

	async handleClickCreateNewSchemaVersion(){

		const result = await LightningConfirm.open({
            message	: 'Are you sure you want to create a new Schema Version?',
            variant	: 'header',
            label	: 'Confirm New Schema Version Create',
			theme	: 'warning'
        });

		if(result){
			this.handleCreateNewSchemaMappingVersion();
		}
	}


	async handleClickShowActiveSchemaPromptOutput(){
		const result = await ShowActiveSchemaPromptOutputModal.open({
			size		: 'small',
			description	: 'Add sObject To Schema Mapping Modal',
			content		: this.recordId,
		});
	}


	async handleClickOpenTestSchemaModal(){
		const result = await TestSchemaMappingModal.open({
			size		: 'medium',
			description	: 'Test Schema Mapping',
			content		: this.recordId
		});
	}


	/** **************************************************************************************************** **
	 **                                        APEX RELATED HANDLERS                                         **
	 ** **************************************************************************************************** **/
	handleCreateNewSchemaMappingVersion(){
		try{
			this.loading = true;

			// Execute Apex
			createNewSchemaMappingVersion({
				recordId : this.recordId
			})
			.then((apexResponse) => {

				if(apexResponse?.isChanged === true){

					LightningAlert.open({
						message : 	'Successfully created a new Schema Mapping Version.\n' 								   + 
									'The new version number is: "' + (apexResponse?.versionNumber     ?? 'Unknown') + '".\n' +
									'The record Id is: "' 		   + (apexResponse?.versionRecordId   ?? 'Unknown') + '".\n' +
									'The record name is:' 		   + (apexResponse?.versionRecordName ?? 'Unknown') + '".',
						label   : 	'Success',
						theme   : 	'success'
					});
				}else{
					LightningAlert.open({
						message : 	'No changed found, no new version is required.' 								   + 
									'The latest version number is: "' + (apexResponse?.versionNumber     ?? 'Unknown') + '".\n' +
									'The record Id is: "' 	  		  + (apexResponse?.versionRecordId   ?? 'Unknown') + '".\n' +
									'The record name is:' 	  		  + (apexResponse?.versionRecordName ?? 'Unknown') + '".',
						label   : 	'Success',
						theme   : 	'success'
					});
				}

				// Turn of spinners
				this._loaded = true;
				this.loading = false;
			})
			.finally(()=>{
				console.log('refresshingggggg');
				// Refresh the related lists and the parent record
				// Not ideal, but the only thing that works 
				this.dispatchEvent(new RefreshEvent());
			})
			.catch((error) => {
				this.loading = false;
				this.handleError(error);
			})
		}catch(error){
			this.loading = false;
			this.handleError(error);
		}
	}


	/** **************************************************************************************************** **
	 **                                           SUPPORT METHODS                                            **
	 ** **************************************************************************************************** **/
	/**
	 * Basic error handling method for both javscript and apex errors
	 */
	handleError(error){
		LightningAlert.open({
			message : (error.body) ? error.body.message : error.message,
			label   : 'Error',
			theme   : 'error'
		});
	}
}