// Default LWC stuff
import { api }          from 'lwc';
import LightningModal   from 'lightning/modal';
import LightningAlert   from 'lightning/alert';

// Apex Methods
import loadFields       from '@salesforce/apex/AddFieldsCtrl.loadFields';
import addFields        from '@salesforce/apex/AddFieldsCtrl.addFields';

// Main class
export default class AddFieldsModal extends LightningModal {
    
    // The content (Abused here for the record Id)
    @api content;
    @api fields;

    // Prevents reloading each time, only load the data on opening the modal 
    _loaded = false;
    loading = false;
    
    // The modal is not in the process of being closed
    _closing = false;

    selectedFields = [];

    handleLoad() {
        if(!this._loaded){
            
            this.handleLoadFields();

            this._loaded = true;            
        }
    }

    handleClose() {
        this.close(); 
        this._closing = true;
        this._loaded  = false;
    }

    get loading(){
        return this._closing === false && this._loaded === false;
    }

    get loaded(){
        return this._loaded === true;
    }

    connectedCallback(){
        this.handleLoad();
    }



    /** **************************************************************************************************** **
     **                                            CLICK HANDLERS                                            **
     ** **************************************************************************************************** **/
    handleClickSave(){
        this.handleAddFields();
    }


    /** **************************************************************************************************** **
     **                                            CHANGE HANDLERS                                           **
     ** **************************************************************************************************** **/
    handleSelectionChange(event){
        this.selectedFields = event.detail.selected;
    }


    /** **************************************************************************************************** **
     **                                        APEX RELATED HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleLoadFields(){
        try{
            // Show spinner
            this.loading = true;

            // Execute Apex
            loadFields({
                recordId : this.content
            })
            .then((apexResponse) => {

                console.log(apexResponse);

                // Load the instructions
                this.fields = apexResponse;

                // Close spinner
                this.loading = false;
            })
            .catch((error) => {
                this.handleError(error);
            })
        }catch(error){
            this.handleError(error);
        }
    }


    handleAddFields(){
        try{
            // Show spinner
            this.loading = true;

            // Execute Apex
            addFields({
                recordId    : this.content,
                fieldsJson  : JSON.stringify(this.selectedFields)
            })
            .then((apexResponse) => {

                LightningAlert.open({
                    message : 	'Successfully add the new fields',
                    label   : 	'Success',
                    theme   : 	'success'
                });

                // Close modal and force refresh
                this.close({ refresh: true });
                this._closing = true;
                this._loaded  = false;

                // Close spinner
                this.loading = false;
            })
            .catch((error) => {
                this.handleError(error);
            })
        }catch(error){
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
        
        // Close spinner
        this.loading = false;

        LightningAlert.open({
            message : (error.body) ? error.body.message : error.message,
            label   : 'Error',
            theme   : 'error'
        });
    }
}