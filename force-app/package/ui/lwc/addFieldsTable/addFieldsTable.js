import { LightningElement, api, track } from 'lwc';

/**
 * LWC: addFieldsTable
 * Renders a lightning-datatable that allows selecting FieldData rows.
 *
 * Input:
 *  @api fields: AddFieldsCtrl.FieldData[]
 *    Expected shape (best-effort, adjust mappings if Apex differs):
 *      {
 *        id: string (unique) OR composite id we derive,
 *        sObjectApiName: string,
 *        fieldApiName: string,
 *        fieldLabel: string,
 *        dataType: string,
 *        description?: string,
 *        selected?: boolean
 *      }
 *
 * Output:
 *  Dispatches 'selectionchange' CustomEvent with detail:
 *    {
 *      selected: AddFieldsCtrl.FieldData[]  // currently selected original records
 *    }
 */
export default class AddFieldsTable extends LightningElement {
    // Public API
    @api title = 'Select Fields';
    @api hideCheckboxColumn = false;
    @api maxRowSelection; // undefined means no limit
    @api
    get fields() {
        return this._fields || [];
    }
    set fields(value) {
        this._fields = Array.isArray(value) ? value : [];
        this._rebuildRows();
    }

    // Internal state
    _fields = [];
    @track rows = [];
    @track selectedRowKeys = [];

    // Define datatable columns using the precise field structure
    // name:string, label:string, dataType:string, isCustom:boolean, isMandatory:boolean
    columns = [
        { label: 'Name', fieldName: 'name', type: 'text', sortable: true },
        { label: 'Label', fieldName: 'label', type: 'text', sortable: true },
        { label: 'Data Type', fieldName: 'dataType', type: 'text', sortable: true },
        { label: 'Custom', fieldName: 'isCustom', type: 'boolean', sortable: true },
        { label: 'Mandatory', fieldName: 'isMandatory', type: 'boolean', sortable: true }
    ];

    connectedCallback() {
        this._rebuildRows();
    }

    // Map incoming FieldData records to datatable rows.
    _rebuildRows() {
        const makeKey = (rec) => {
            // Use field name as unique key as requested
            return rec.name || rec.fieldApiName || rec.apiName;
        };

        const rows = (this._fields || []).map((rec) => {
            // Only include the specified properties on the row object
            const name = rec.name || rec.fieldApiName || rec.apiName;
            const label = rec.label || rec.fieldLabel;
            const dataType = rec.dataType || rec.type;
            const isCustom = rec.isCustom;
            const isMandatory = rec.isMandatory;

            return {
                key: name,            // keep for any future internal use
                id: name,             // maintain 'id' equal to key-field 'name' for consistency
                name,
                label,
                dataType,
                isCustom,
                isMandatory,
                _orig: rec
            };
        });

        // Preserve selection when possible
        const previousKeys = new Set(this.selectedRowKeys);
        const initialSelected = rows
            .filter((r) => previousKeys.has(r.id) || r._orig?.selected === true)
            .map((r) => r.id);

        this.rows = rows;
        this.selectedRowKeys = initialSelected;
    }

    handleRowSelection(event) {
        const selected = event.detail.selectedRows || [];
        // key-field is 'name', so store names in selectedRowKeys
        this.selectedRowKeys = selected.map((r) => r.name);

        // Map back to original records in same order as current rows
        const selectedKeySet = new Set(this.selectedRowKeys);
        const selectedOriginals = this.rows
            .filter((r) => selectedKeySet.has(r.name))
            .map((r) => r._orig);

        this.dispatchEvent(
            new CustomEvent('selectionchange', {
                detail: { selected: selectedOriginals },
                bubbles: true,
                composed: true
            })
        );
    }
}
