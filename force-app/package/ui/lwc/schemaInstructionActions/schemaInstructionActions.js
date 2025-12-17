
// Standard LWC
import { LightningElement, api } from "lwc";
import   LightningAlert 		 from 'lightning/alert';
import   LightningConfirm 	     from 'lightning/confirm';
import { RefreshEvent } 		 from 'lightning/refresh';


// Modals
import SchemaInstructionModal 	 from 'c/schemaInstructionModal';

// Apex
import isDefaultInstruction      from '@salesforce/apex/SchemaInstructionCtrl.isDefaultInstruction';
import resetDefaultInstruction   from '@salesforce/apex/SchemaInstructionCtrl.resetDefaultInstruction';

// Main class
export default class SchemaInstructionActions extends LightningElement {

    @api recordId;
    @api objectApiName;
    
    // Indicator that 
    isDefault = false;

    /** **************************************************************************************************** **
     **                                          LIFECYCLE HANDLERS                                          **
     ** **************************************************************************************************** **/
    connectedCallback(){
        this.handleIsDefaultInstruction();
    }


    /** **************************************************************************************************** **
     **                                        APEX RELATED HANDLERS                                         **
    ** **************************************************************************************************** **/
    handleIsDefaultInstruction(){
        try{
            this.loading = true;

            // Execute Apex
            isDefaultInstruction({
                recordId : this.recordId
            })
            .then((apexResponse) => {

                this.isDefault = apexResponse;

                // Turn of spinners
                this._loaded = true;
                this.loading = false;
            })
            .finally(()=>{
                
                // Refresh the related lists and the parent record
                // Not ideal, but the only thing that works 
                //this.dispatchEvent(new RefreshEvent());
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


    handleResetDefaultInstruction(){
        try{
            this.loading = true;

            // Execute Apex
            resetDefaultInstruction()
            .then((apexResponse) => {

                LightningAlert.open({
                    message : 	'Successfully created a new Schema Mapping Version.\n' 								   + 
                                'The new version number is: "' + (apexResponse?.versionNumber     ?? 'Unknown') + '".\n' +
                                'The record Id is: "' 		   + (apexResponse?.versionRecordId   ?? 'Unknown') + '".\n' +
                                'The record name is:' 		   + (apexResponse?.versionRecordName ?? 'Unknown') + '".',
                    label   : 	'Success',
                    theme   : 	'success'
                });

                // Refresh the screen
                this.dispatchEvent(new RefreshEvent());
                
                // Turn of spinners
                this._loaded = true;
                this.loading = false;
            })
            .finally(()=>{
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
     **                                            CLICK HANDLERS                                            **
     ** **************************************************************************************************** **/
    async handleClickOpenViewSchemaInstructionModal(){
        const result = await SchemaInstructionModal.open({
            size        : 'medium',
            description : 'Edit Schema Instruction',
            content     : this.recordId,
            type        : 'view'
        });
    }

    async handleClickOpenEditSchemaInstructionModal(){
        const result = await SchemaInstructionModal.open({
            size        : 'medium',
            description : 'Edit Schema Instruction',
            content     : this.recordId,
            type        : 'edit'
        });

        // Refresh the related lists when a new version is created
        if (result?.refresh) {
            this.dispatchEvent(new RefreshEvent());
        }
    }


    async handleClickReset(){
        const result = await LightningConfirm.open({
            message	: 'Are you sure you want to reset the default instructions to factory settings?',
            variant	: 'header',
            label	: 'Confirm Default Instructions Reset',
			theme	: 'warning'
        });

		if(result){
			this.handleResetDefaultInstruction();
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