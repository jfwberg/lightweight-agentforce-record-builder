// Default LWC stuff
import { api }                        from 'lwc';
import LightningModal                 from 'lightning/modal';

// Main class
export default class HierarchyModal extends LightningModal {
    
    // The content (Abused here for the record Id)
    @api content;
    
    // Prevents reloading each time, only load the data on opening the modal 
    _loaded = false;
    loading = false;
    
    // The modal is not in the process of being closed
    _closing = false;

    handleLoad() {
        if(!this._loaded){
            
            this._loaded = true;            
        }
    }

    handleClose() {
        this.close({ refresh: true });
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


}