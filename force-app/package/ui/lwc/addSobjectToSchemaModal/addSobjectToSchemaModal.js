import { api }             from 'lwc';
import LightningModal      from 'lightning/modal';
import LightningAlert      from 'lightning/alert';
import addSObjectAndFields from '@salesforce/apex/SchemaActionsCtrl.addSObjectAndFields';


export default class AddSObjectModal extends LightningModal {
    
    // The content (Abused here for the record Id)
    @api content;
    
    // Prevents reloading each time, only load the data on opening the modal 
    _loaded = false;
    loading = false;
    
    // The modal is not in the process of being closed
    _closing = false;

    sobjectApiName        = '';
    purposeDescription    = '';
    selectedFieldApiNames = [];

    handleLoad() {
        if(!this._loaded){
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

    handleClickAdd(){
        this.handleAddSObjectAndFields();
    }

    handleValueChanged(event){
        this.purposeDescription    = event.detail.purposeDescription;
        this.sobjectApiName        = event.detail.sobjectApiName;
        this.selectedFieldApiNames = event.detail.selectedFieldApiNames;
    }

    /** **************************************************************************************************** **
     **                                        APEX RELATED HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleAddSObjectAndFields(){
        try{
            // Show spinner
            this.loading = true;

            // Execute Apex
            addSObjectAndFields({
                recordId              : this.content,
                sobjectApiName        : this.sobjectApiName,
                purposeDescription    : this.purposeDescription,
                selectedFieldApiNames : this.selectedFieldApiNames
            })
            .then((apexResponse) => {

                // Close modal
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