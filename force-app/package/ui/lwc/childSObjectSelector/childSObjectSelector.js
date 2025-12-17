import { api, track, LightningElement } from 'lwc';
import getSObjects from '@salesforce/apex/ChildSObjectSelectorCtrl.getSObjects';
import getFields from '@salesforce/apex/ChildSObjectSelectorCtrl.getFields';

export default class ChildSObjectSelector extends LightningElement {
    
    // Public API
    @api parentRecordId;
    @api label = 'Select sObject';
    @api placeholder = 'Select an object';
    @api value; // holds API name always
    @api includeStandard;
    @api includeCustom;

    // UI state
    @track _allObjects = []; // [{apiName,label,isCustom}]
    @track _filtered = [];
    searchKey = '';
    showLabel = false; // false = show API names; true = show Labels
    onlyCustom = false;

    // Fields datatable state
    fieldsLoaded = false;
    fieldRows = [];
    _allFieldRows = []; // master list to allow re-including previously excluded relationship fields
    selectedMandatoryRows = []; // array of apiName (key-field)
    
    // Relationship picklist state
    relationshipFieldValue = '';
    fieldOptions = [];
    purposeDescription = '';
    

    handleChangePurposeDescription(event) {
        this.purposeDescription = event.detail.value;
        this.dispatchSelectionChange();
    }


    handleRelationshipFieldChange(event){
        const previous = this.relationshipFieldValue;
        this.relationshipFieldValue = event.detail.value;

        // When relationship field changes, ensure the fields table excludes the selected relationship field
        // and re-includes any previously selected relationship field (if it was excluded).
        this.applyRelationshipExclusion(previous, this.relationshipFieldValue);

        this.dispatchSelectionChange();
    }

    get relationshipFieldLabel() {
        return this.showLabel ? 'Relationship Field Label' : 'Relationship Field API Name';
    }

    get relationshipFieldOptions() {
      return this.fieldOptions;
    }

    // Fields
    get fieldColumns() {
        return [
            { label: 'Name',        fieldName: 'apiName',   type: 'text'   , initialWidth : 275},
            { label: 'Label',       fieldName: 'label',     type: 'text'   , initialWidth : 275},
            { label: 'Data Type',   fieldName: 'dataType',  type: 'text'   , initialWidth : 120 },
            { label: 'Custom',      fieldName: 'isCustom',  type: 'boolean', initialWidth : 80, cellAttributes: { alignment: 'center' } },
            { label: 'Mandatory',   fieldName: 'mandatory', type: 'boolean', initialWidth : 90, cellAttributes: { alignment: 'center' } }
        ];
    }

    get computedPickerLabel() {
        // Move "viewing mode" into the picklist label as requested
        return this.showLabel ? 'sObject Label' : 'sObject API Name';
    }

    // Combobox options based on toggle + search
    get options() {
        const list = this._filtered.length ? this._filtered : this._allObjects;
        return list.map((o) => ({
            label: this.showLabel ? o.label : o.apiName,
            value: o.apiName
        }));
    }

    // Counts for "Showing X of Y"
    get totalCount() {
        return Array.isArray(this._allObjects) ? this._allObjects.length : 0;
    }
    
    get filteredCount() {
        // When no search key, show uses all objects; otherwise show filtered length
        if (!this.searchKey || !this.searchKey.trim()) {
            return this.totalCount;
        }
        return Array.isArray(this._filtered) ? this._filtered.length : 0;
    }

    connectedCallback() {
        this.loadObjects();
    }

    async loadObjects() {
        try {
            
            const data = await getSObjects({
                parentRecordId  : this.parentRecordId,
                includeStandard : this.resolveIncludeStandard(),
                includeCustom   : this.resolveIncludeCustom()
            });
            
            // Normalize and keep deterministic order (Apex already sorts by API name)
            this._allObjects = (data || []).map((d) => ({
                apiName: d.apiName,
                label: d.label,
                isCustom: d.isCustom
            }));

            this.applyFilter();
        } catch (e) {
            // eslint-disable-next-line no-console
            console.error('Failed to fetch sObjects', e);
        }
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value || '';
        this.applyFilter();
    }

    handleToggle(event) {
        this.showLabel = event.target.checked;
        // No need to refetch; just recompute display via getter
        this.applyFilter(); // re-run filter against new display basis for friendlier UX
    }

    handleOnlyCustomToggle(event) {
        this.onlyCustom = event.target.checked;
        // When onlyCustom is true, exclude standard by refetching from Apex with adjusted flags
        // We refetch to ensure we honor server-side visibility/exclusions consistently.
        this.loadObjects();
    }

    async handleChange(event) {
        this.value = event.detail.value;

        // Reset fields and selections when object changes
        this.fieldsLoaded = false;
        this.fieldRows = [];
        this.selectedMandatoryRows = [];
        // Reset relationship field state to avoid stale selection/options
        this.relationshipFieldValue = '';
        this.fieldOptions = [];

        // Load fields for selected sObject
        await this.loadFieldsForObject();

        // Emit change including only the selected row keys (api names)
        this.dispatchSelectionChange();
    }
    
    // Helpers to satisfy LWC rule for Boolean @api defaults while still defaulting to true when not set
    resolveIncludeStandard() {
        // If onlyCustom is true, force false
        if (this.onlyCustom) return false;
        // If user passed the attribute (boolean presence prop) return true, else default true
        return this.includeStandard !== false;
    }
    resolveIncludeCustom() {
        // OnlyCustom still needs custom true
        if (this.onlyCustom) return true;
        return this.includeCustom !== false;
    }

    async loadFieldsForObject() {
        const apiName = this.value;
        if (!apiName) {
            this.fieldsLoaded = false;
            this.fieldRows = [];
            this.selectedMandatoryRows = [];
            this.fieldOptions = [];
            return;
        }
        try {
            const fields = await getFields({ 
                parentRecordId : this.parentRecordId,
                sObjectApiName : apiName 
            });

            // Normalize rows and capture a master copy for reinclusion logic
            this._allFieldRows = (fields || []).map((f) => ({
                apiName: f.apiName,
                label: f.label,
                dataType: f.dataType,
                isCustom: f.isCustom,
                mandatory: f.mandatory
            }));
            // Start visible set from master
            this.fieldRows = [...this._allFieldRows];

            // Fix the reference field
            this.fieldOptions = (fields || [])
            .filter(f => f.dataType === 'REFERENCE' && f.lookupToParent === true)
            .map(f => ({
                value: f.apiName,
                label: this.showLabel ? f.label : f.apiName
            }));

            // Apply exclusion of currently selected relationship field from the fields table
            this.applyRelationshipExclusion(null, this.relationshipFieldValue);

            // Preselect mandatory fields by apiName
            this.selectedMandatoryRows = this.fieldRows.filter((r) => r.mandatory).map((r) => r.apiName);
            this.fieldsLoaded = true;
            
        } catch (e) {
            // eslint-disable-next-line no-console
            console.error('Failed to fetch fields for', apiName, e);
            this.fieldsLoaded = false;
            this.fieldRows = [];
            this.selectedMandatoryRows = [];
        }
    }

    // Handle row selection changes from the datatable
    handleRowSelection(event) {
        const selected = event.detail.selectedRows || [];
        // Keep only the key-field values (apiName)
        this.selectedMandatoryRows = selected.map((r) => r.apiName);
        
        // Emit change including only selected rows
        this.dispatchSelectionChange();

    }

    /**
     * Exclude the selected relationship field from the visible fields list (fieldRows),
     * and re-include any previously selected relationship field when the value changes.
     * @param {string|null} previous - previous relationship api name
     * @param {string} current - current relationship api name
     */
    applyRelationshipExclusion(previous, current) {
        // Rebuild visible rows from master so we can re-include the previous relationship field
        if (Array.isArray(this._allFieldRows) && this._allFieldRows.length) {
            this.fieldRows = [...this._allFieldRows];
            // Exclude the currently selected relationship field
            if (current) {
                this.fieldRows = this.fieldRows.filter(r => r.apiName !== current);
            }
        }

        // If the previous relationship field was selected in the datatable, remove it from selected rows
        if (previous) {
            this.selectedMandatoryRows = (this.selectedMandatoryRows || []).filter(key => key !== previous);
        }
        // Also safeguard: if the current relationship field was somehow selected, remove it too
        if (current) {
            this.selectedMandatoryRows = (this.selectedMandatoryRows || []).filter(key => key !== current);
        }
    }

    // Unified event dispatch containing only selected row keys
    dispatchSelectionChange() {
        this.dispatchEvent(
            new CustomEvent('valuechanged', {
                detail: {
                    sobjectApiName        : this.value,
                    selectedFieldApiNames : this.selectedMandatoryRows,
                    relationshipField     : this.relationshipFieldValue,
                    purposeDescription    : this.purposeDescription
                    
                },
                bubbles: true,
                composed: true
            })
        );
    }

    applyFilter() {
        const key = (this.searchKey || '').trim().toLowerCase();
        if (!key) {
            this._filtered = [];
            return;
        }
        // Friendly search: match start and contains on both API Name and Label for convenience
        const src = this._allObjects;
        this._filtered = src.filter((o) => {
            const api = (o.apiName || '').toLowerCase();
            const lbl = (o.label || '').toLowerCase();
            // prioritize startsWith but include contains for flexibility
            return (
                api.startsWith(key) ||
                lbl.startsWith(key) ||
                api.includes(key) ||
                lbl.includes(key)
            );
        });
    }
}
