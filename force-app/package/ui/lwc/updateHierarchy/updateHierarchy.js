import { LightningElement, api  } from 'lwc';
import LightningAlert             from 'lightning/alert';
import buildHierarchy             from '@salesforce/apex/UpdateHierarchyCtrl.buildHierarchy';

// Main class
export default class UpdateHierarchy extends LightningElement {
    
    // Loading flag
    loading = false;

    // Input schema mapping
    @api schemaMappingId;
    
    // Data
    ascii;
    

    /** **************************************************************************************************** **
     **                                          LIFECYCLE HANDLERS                                          **
     ** **************************************************************************************************** **/
    connectedCallback() {
        try{
            this.handleBuildHierarchy();
        }catch(error){
            this.handleError(error);
        }
    }

    
    /** **************************************************************************************************** **
     **                                        APEX RELATED HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleBuildHierarchy(){
        try{
            // Show spinner
            this.loading = true;

            // Execute Apex
            buildHierarchy({
                schemaMappingId: this.schemaMappingId
            })
            .then((apexResponse) => {

                // Get the tree
                this.ascii = apexResponse?.ascii || '';

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