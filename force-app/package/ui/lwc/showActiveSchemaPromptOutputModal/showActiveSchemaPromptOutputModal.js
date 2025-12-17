import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import LightningAlert from 'lightning/alert';

import getActiveSchemaPromptOutput from '@salesforce/apex/SchemaActionsCtrl.getActiveSchemaPromptOutput';


export default class ShowActiveSchemaPromptOutputModal extends LightningModal {

	// The content (Abused here for the record Id)
	@api content;

	// Prevents reloading each time, only load the data on opening the modal
	_loaded = false;

	// The modal is not in the process of being closed
	_closing = false;

	// Response from Apex Controllers
	label = '';
	promptOutput  = '';

	// Backing field for loading state
	_loading = false;


	handleLoad() {
		if(!this._loaded){
			this.handleGetActiveSchemaPromptOutput();
			this._loaded = true;
		}
	}

	handleClose() {
		this.close();
		this._closing = true;
		this._loaded  = false;
    }

	get loading(){
		// Computed loading if not explicitly set: when not closing and not yet loaded
		return this._loading || (this._closing === false && this._loaded === false);
	}

	set loading(value){
		this._loading = Boolean(value);
	}

	get loaded(){
		return this._loaded === true;
	}

	connectedCallback(){
		this.handleLoad();
	}


	/** **************************************************************************************************** **
     **                                        APEX RELATED HANDLERS                                         **
     ** **************************************************************************************************** **/
	handleGetActiveSchemaPromptOutput(){
		try{
			this.loading = true;

			// Execute Apex
			getActiveSchemaPromptOutput({
				recordId : this.content
			})
			.then((apexResponse) => {

				this.label 		  = apexResponse?.label ?? 'Unknown';
				this.promptOutput = apexResponse?.promptOutput  ?? 'Unknown';

				this._loaded = true;
				this.loading = false;
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
