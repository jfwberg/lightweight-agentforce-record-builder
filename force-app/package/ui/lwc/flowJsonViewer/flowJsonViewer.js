import { LightningElement, api } from 'lwc';

export default class FlowJsonViewer extends LightningElement {
    @api jsonString; // Flow-provided JSON string (assumed valid)

    renderedCallback() {
        // Build pretty, highlighted HTML and inject once per render
        const container = this.template.querySelector('.json-content');
        if (!container) return;

        let jsonObj;
        try {
            jsonObj = JSON.parse(this.jsonString ?? '{}');
        } catch (e) {
            // Per requirements, input is valid JSON, but add minimal fallback
            jsonObj = { error: 'Invalid JSON', original: this.jsonString };
        }

        const pretty = JSON.stringify(jsonObj, null, 2);
        container.innerHTML = this.highlight(pretty);
    }

    // Lightweight JSON syntax highlighter
    highlight(text) {
        // Escape HTML: convert raw characters to entities before token wrapping
        const esc = (s) =>
            s
                .replace(/&/g, '&')
                .replace(/</g, '<')
                .replace(/>/g, '>');

        let escaped = esc(text);

        // Replace quoted keys FIRST with a placeholder to avoid the generic string rule re-wrapping parts
        // Placeholder tokens are unlikely to appear in content
        const KEY_OPEN = '§§KEY_OPEN§§';
        const KEY_CLOSE = '§§KEY_CLOSE§§';

        // Keys: "key":  (work on the entity-escaped content, matching "...")
        escaped = escaped.replace(/(^|[\s{[])(\s*)(".*?")(\s*):/g, (_m, p1, p2, key, p4) => {
            return `${p1}${p2}${KEY_OPEN}${key}${KEY_CLOSE}${p4}:`;
        });

        // Strings (remaining non-keys) in escaped form
        escaped = escaped.replace(/(".*?")/g, '<span class="json-string">$1</span>');

        // Convert placeholders to actual span markup (safe because we operate in escaped text domain)
        escaped = escaped
            .replace(new RegExp(KEY_OPEN, 'g'), '<span class="json-key">')
            .replace(new RegExp(KEY_CLOSE, 'g'), '</span>');

        // Regex to wrap other tokens: numbers, booleans, null; punctuation left as-is
        return escaped
            // Numbers
            .replace(/\b(-?\d+(?:\.\d+)?(?:[eE][+\-]?\d+)?)\b/g, '<span class="json-number">$1</span>')
            // Booleans
            .replace(/\b(true|false)\b/g, '<span class="json-boolean">$1</span>')
            // Null
            .replace(/\b(null)\b/g, '<span class="json-null">$1</span>')
            // Keep punctuation unwrapped to avoid CSS injecting markers like ">"
            .replace(/([{}\[\],:])/g, '$1');
    }
}
