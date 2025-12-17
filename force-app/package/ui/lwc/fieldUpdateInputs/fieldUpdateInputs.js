import { LightningElement, api, track } from 'lwc';

export default class FieldUpdateInputs extends LightningElement {
    @track _fields = [];
    @track deletedFields = [];

    // Parent passes in List<FieldData> (id, name, purposeDescription)
    @api
    get fields() {
        return this._fields;
    }
    set fields(value) {
        // Make a shallow copy so we don't mutate the parent's data / wire result
        this._fields = Array.isArray(value)
            ? value.map(f => ({ ...f }))
            : [];
    }

    handlePurposeChange(event) {
        const recordId = event.target.dataset.id;
        const newValue = event.target.value;

        // Update our local copy immutably
        this._fields = this._fields.map(field =>
            field.id === recordId
                ? { ...field, purposeDescription: newValue }
                : field
        );

        // Let parent know what changed (and optionally the full list)
        this.dispatchEvent(
            new CustomEvent('purposechange', {
                detail: {
                    id: recordId,
                    purposeDescription: newValue,
                    fields: this._fields,
                    deletedFields: this.deletedFields
                }
            })
        );
    }

    handleDeleteField(event) {
        const recordId = event.currentTarget.dataset.id;

        // find the field in current list
        const toDelete = this._fields.find(f => f.id === recordId);
        if (!toDelete) {
            return;
        }

        // add to deletedFields (no duplicates)
        const exists = this.deletedFields.some(f => f.id === recordId);
        if (!exists) {
            this.deletedFields = [...this.deletedFields, { ...toDelete }];
        }

        // remove from active fields
        this._fields = this._fields.filter(f => f.id !== recordId);

        // notify parent of deletion with both lists
        this.dispatchEvent(
            new CustomEvent('purposechange', {
                detail: {
                    id: recordId,
                    purposeDescription: toDelete.purposeDescription,
                    fields: this._fields,
                    deletedFields: this.deletedFields
                }
            })
        );
    }
}
