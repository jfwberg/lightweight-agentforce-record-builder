// Default LWC stuff
import { api }                        from 'lwc';
import LightningModal                 from 'lightning/modal';
import LightningAlert                 from 'lightning/alert';

// Apex Methods
import loadSchemaInstructionVersion   from '@salesforce/apex/SchemaInstructionCtrl.loadSchemaInstructionVersion';
import createSchemaInstructionVersion from '@salesforce/apex/SchemaInstructionCtrl.createSchemaInstructionVersion';

// Main class
export default class SchemaInstructionModal extends LightningModal {
    
    // The content (Abused here for the record Id)
    @api content;
    
    // view or edit
    @api type; 
    
    // Prevents reloading each time, only load the data on opening the modal 
    _loaded = false;
    loading = false;
    
    // The modal is not in the process of being closed
    _closing = false;

    // Instructions value
    instructions        = '';

    get headerText(){
        return this.type == 'view' ? 'View Schema Instruction Version' : 'Create / Edit Schema Instruction Version';
    }
    
    get editMode(){
        return this.type == 'edit';
    }

    get viewMode(){
        return this.type == 'view';
    }

    handleLoad() {
        if(!this._loaded){
            
            this.handleLoadSchemaInstructionVersion();

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
        this.handleCreateSchemaInstructionVersion();
    }

    /** **************************************************************************************************** **
     **                                            CHANGE HANDLERS                                           **
     ** **************************************************************************************************** **/
    handleInstructionsValueChanged(event){
        this.instructions        = event.detail.value;
        console.log(this.instructions);
    }


    /** **************************************************************************************************** **
     **                                        APEX RELATED HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleLoadSchemaInstructionVersion(){
        try{
            // Show spinner
            this.loading = true;

            // Execute Apex
            loadSchemaInstructionVersion({
                recordId : this.content
            })
            .then((apexResponse) => {

                // Load the instructions
                this.instructions = apexResponse;

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


    handleCreateSchemaInstructionVersion(){
        try{
            // Show spinner
            this.loading = true;

            // Execute Apex
            createSchemaInstructionVersion({
                recordId     : this.content,
                instructions : this.instructions
            })
            .then((apexResponse) => {

                LightningAlert.open({
                    message : 	'Successfully created a new Schema Mapping Version.\n' 								   + 
                                'The new version number is: "' + (apexResponse?.versionNumber     ?? 'Unknown') + '".\n' +
                                'The record Id is: "' 		   + (apexResponse?.versionRecordId   ?? 'Unknown') + '".\n' +
                                'The record name is:' 		   + (apexResponse?.versionRecordName ?? 'Unknown') + '".',
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