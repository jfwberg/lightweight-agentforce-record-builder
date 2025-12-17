import { LightningElement, api }    from 'lwc';
import LightningAlert 				from 'lightning/alert';
import { RefreshEvent } 			from 'lightning/refresh';

// Modals
import AddChildSObjectToSchemaModal from 'c/addChildSObjectToSchemaModal';
import AddFieldsModal               from 'c/addFieldsModal';
import ManageFieldsModal            from 'c/manageFieldsModal';


export default class MappedSObjectActions extends LightningElement {

    @api recordId;
    @api objectApiName;

    /** **************************************************************************************************** **
     **                                            CLICK HANDLERS                                            **
     ** **************************************************************************************************** **/
    async handleClickOpenAddChildSObjectModal(){
        const result = await AddChildSObjectToSchemaModal.open({
            size		: 'medium',
            description	: 'Add child sObject To Schema Mapping Modal',
            content		: this.recordId
        });

        // Refresh the related lists
        if (result?.refresh) {
            this.dispatchEvent(new RefreshEvent());
        }
    }

    
    async handleClickOpenAddFieldsModal(){
        const result = await AddFieldsModal.open({
            size		: 'medium',
            description	: 'Add fields to the sObject',
            content		: this.recordId
        });

        // Refresh the related lists
        if (result?.refresh) {
            this.dispatchEvent(new RefreshEvent());
        }
    }


    async handleClickOpenManageFieldsModal(){
        const result = await ManageFieldsModal.open({
            size		: 'medium',
            description	: 'Manage the field data input modal',
            content		: this.recordId
        });

        // Refresh the related lists
        if (result?.refresh) {
            this.dispatchEvent(new RefreshEvent());
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