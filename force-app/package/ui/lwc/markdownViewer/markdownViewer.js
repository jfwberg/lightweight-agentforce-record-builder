import { api, LightningElement } from 'lwc';

/**
 * Lightweight Markdown Viewer
 * - Single public property: markdownText
 * - Renders only one wrapper div (see HTML). No extra controls/targets.
 * - Supports features present in the provided sample:
 *    # Headings (H1-H3 used in sample)
 *    Horizontal rules (--- or --- lines)
 *    Bold **text** and italic *text*
 *    Paragraphs with hard line breaks using backslash at EOL
 *    Inline code `code` and fenced code ``` lang ... ```
 *    Unordered lists (-, *, +) and ordered lists (1.)
 *    Blockquotes starting with >
 *    Links [text](url)
 * - Preserves literal @{ref} and curly braces without stripping or escaping them away.
 * - Sanitizes by removing script/style tags and on* event attributes.
 */
export default class MarkdownViewer extends LightningElement {
  _markdownText = '';

  @api
  get markdownText() {
    return this._markdownText;
  }
  set markdownText(val) {
    this._markdownText = val ?? '';
    this.renderMarkdown();
  }

  renderedCallback() {
    // Ensure initial render if set programmatically after connect
    this.renderMarkdown();
  }

  get _container() {
    return this.template.querySelector('.md-content');
  }

  renderMarkdown() {
    const host = this._container;
    if (!host) return;
    const src = this._markdownText || '';

    // Convert markdown to HTML (subset required by sample)
    const html = this.markdownToHtml(src);

    // Basic sanitization (keep @{...} and curly braces intact)
    const safe = this.sanitize(html);

    // Inject
    host.innerHTML = safe;

    // Post-process links: open in new tab safely
    host.querySelectorAll('a').forEach((a) => {
      a.setAttribute('target', '_blank');
      a.setAttribute('rel', 'noopener noreferrer');
    });
  }

  markdownToHtml(md) {
    if (!md) return '';

    // Normalize newlines
    let text = md.replace(/\r\n/g, '\n');

    // Handle fenced code blocks ```lang?\n...\n```
    // We replace them with placeholders during inline processing to avoid accidental formatting.
    const fences = [];
    text = text.replace(/```([a-zA-Z0-9_-]*)\n([\s\S]*?)```/g, (m, lang, code) => {
      const idx = fences.length;
      fences.push({ lang: (lang || '').trim(), code });
      return `\u0000FENCED_${idx}\u0000`;
    });

    // Split into lines for block parsing
    const lines = text.split('\n');

    const out = [];
    let inTable = false;
    let tableHeader = null;
    let tableAlign = null;
    let tableRows = [];
    const isTableSeparator = (l) => /^\s*\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)+\|?\s*$/.test(l);
    const splitTableRow = (l) => {
      // Trim outer pipes and split, preserving code spans/backticks by not stripping backticks
      const trimmed = l.trim().replace(/^\|/, '').replace(/\|$/, '');
      return trimmed.split('|').map((c) => c.trim());
    };
    let inList = false;
    let listType = null; // 'ul' or 'ol'
    let listIndentStack = []; // track nested list indents
    let inBlockquote = false;
    let blockquoteBuffer = [];
    let inParagraph = false;
    let paragraphBuffer = [];

    const flushParagraph = () => {
      if (!inParagraph) return;
      const paragraph = paragraphBuffer.join('\n').trim();
      if (paragraph) {
        out.push(`<p>${this.inline(paragraph)}</p>`);
      }
      inParagraph = false;
      paragraphBuffer = [];
    };

    const flushTable = () => {
      if (!inTable) return;
      // Build table HTML
      const headerCells = tableHeader.map((h) => `<th>${this.inline(h.trim())}</th>`).join('');
      const bodyRows = tableRows
        .map((row) => {
          const tds = row.map((c) => `<td>${this.inline(String(c).trim())}</td>`).join('');
          return `<tr>${tds}</tr>`;
        })
        .join('');
      out.push(`<table><thead><tr>${headerCells}</tr></thead><tbody>${bodyRows}</tbody></table>`);
      inTable = false;
      tableHeader = null;
      tableAlign = null;
      tableRows = [];
    };

    const flushList = (toDepth = 0) => {
      // Close lists down to desired depth
      while (listIndentStack.length > toDepth) {
        out.push(`</${listType}>`);
        listIndentStack.pop();
        // Update listType based on remaining stack (if any). We don't know type per depth, so reset.
        listType = listIndentStack.length ? listIndentStack[listIndentStack.length - 1].type : null;
        inList = listIndentStack.length > 0;
      }
      if (!toDepth && inList && listIndentStack.length === 1) {
        // if requested to fully flush
        out.push(`</${listType}>`);
        inList = false;
        listType = null;
        listIndentStack = [];
      }
    };

    const flushBlockquote = () => {
      if (!inBlockquote) return;
      // Recursively parse the inner markdown for blockquote content
      const inner = blockquoteBuffer.join('\n');
      // Allow headings, lists etc inside blockquote by calling markdownToHtml on inner,
      // then strip the outer container that method would add by joining blocks.
      const innerHtml = this.blockOnlyToHtml(inner);
      out.push(`<blockquote>${innerHtml}</blockquote>`);
      inBlockquote = false;
      blockquoteBuffer = [];
    };

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      // Horizontal rule (three or more dashes)
      if (/^\s*-{3,}\s*$/.test(line)) {
        flushParagraph();
        flushList();
        flushBlockquote();
        flushTable();
        out.push('<hr />');
        continue;
      }

      // Headings: #, ##, ###
      const hMatch = line.match(/^(#{1,6})\s+(.*)$/);
      if (hMatch) {
        const level = hMatch[1].length;
        const content = hMatch[2].trim();
        flushParagraph();
        flushList();
        flushBlockquote();
        flushTable();
        out.push(`<h${level}>${this.inline(content)}</h${level}>`);
        continue;
      }

      // Blockquote line
      if (/^\s*>\s?/.test(line)) {
        flushParagraph();
        flushList();
        flushTable();
        if (!inBlockquote) {
          inBlockquote = true;
          blockquoteBuffer = [];
        }
        blockquoteBuffer.push(line.replace(/^\s*>\s?/, ''));
        continue;
      } else {
        // If we exit a blockquote
        if (inBlockquote && line.trim() === '') {
          // Blank line terminates blockquote
          flushBlockquote();
          continue;
        }
      }

      // Ordered list item: captures "1. " pattern (allows for spacing variations)
      const olMatch = line.match(/^(\s*)(\d+)\.\s+(.*)$/);
      if (olMatch) {
        const indent = olMatch[1].length;
        const num = olMatch[2];
        const item = olMatch[3];

        flushParagraph();
        flushBlockquote();
        flushTable();

        // Determine nesting level by indent (every 2 spaces increments a level)
        const depth = Math.floor(indent / 2);

        // Close lists if current depth is less than stack
        if (listIndentStack.length > depth) {
          flushList(depth);
        }

        // If we need to open a new list or switch type at this depth
        if (listIndentStack.length === depth) {
          if (!inList || listType !== 'ol') {
            // open new ol at this level
            out.push('<ol>');
            listIndentStack.push({ indent, type: 'ol' });
            inList = true;
            listType = 'ol';
          }
        }

        // If deeper indent than current stack, open nested list(s)
        while (listIndentStack.length < depth + 1) {
          out.push('<ol>');
          listIndentStack.push({ indent: (listIndentStack.length + 1) * 2, type: 'ol' });
          inList = true;
          listType = 'ol';
        }

        out.push(`<li>${this.inline(item)}</li>`);
        continue;
      }

      // Unordered list item: captures " -, *, or + " pattern
      const ulMatch = line.match(/^(\s*)([-*+])\s+(.*)$/);
      if (ulMatch) {
        const indent = ulMatch[1].length;
        const bullet = ulMatch[2];
        const item = ulMatch[3];

        flushParagraph();
        flushBlockquote();
        flushTable();

        const depth = Math.floor(indent / 2);

        if (listIndentStack.length > depth) {
          flushList(depth);
        }

        if (listIndentStack.length === depth) {
          if (!inList || listType !== 'ul') {
            out.push('<ul>');
            listIndentStack.push({ indent, type: 'ul' });
            inList = true;
            listType = 'ul';
          }
        }

        while (listIndentStack.length < depth + 1) {
          out.push('<ul>');
          listIndentStack.push({ indent: (listIndentStack.length + 1) * 2, type: 'ul' });
          inList = true;
          listType = 'ul';
        }

        out.push(`<li>${this.inline(item)}</li>`);
        continue;
      }

      // Table detection: header |---|---| separator sequence
      if (!inParagraph && !inList && !inBlockquote) {
        // Potential table start if current line and next lines form header + separator
        const cur = line;
        const next = lines[i + 1];
        if (cur && next && /\|/.test(cur) && isTableSeparator(next)) {
          // Start table
          flushParagraph();
          flushList();
          flushBlockquote();
          flushTable();
          inTable = true;
          tableHeader = splitTableRow(cur);
          tableRows = [];
          i++; // consume separator line
          continue;
        } else if (inTable && /\|/.test(line)) {
          // Continuation row
          tableRows.push(splitTableRow(line));
          continue;
        } else if (inTable && line.trim() === '') {
          // End table on blank line
          flushTable();
          continue;
        } else if (inTable && !/\|/.test(line)) {
          // End table on non-table content
          flushTable();
          // fall through to normal processing of this line
        }
      }

      // Blank line: flush blocks
      if (line.trim() === '') {
        flushParagraph();
        flushList(0);
        flushBlockquote();
        flushTable();
        continue;
      }

      // Paragraph accumulation; preserve explicit line breaks indicated by backslash at EOL
      if (!inParagraph) {
        inParagraph = true;
        paragraphBuffer = [];
      }
      // Replace trailing " \\" with <br/> marker to be processed in inline()
      paragraphBuffer.push(line.replace(/\\\s*$/, '  ')); // two spaces cues <br/> in inline()
    }

    // Flush remaining structures
    flushBlockquote();
    flushList(0);
    flushParagraph();
    flushTable();

    // Reinsert fenced code blocks with minimal styling and language label as data-attr
    let html = out.join('\n');
    html = html.replace(/\u0000FENCED_(\d+)\u0000/g, (_m, idxStr) => {
      const idx = Number(idxStr);
      const entry = fences[idx];
      let code = entry.code;
      // JSON highlighting (very lightweight): if language is json, pretty-print and colorize keys/strings/numbers/booleans/null
      if ((entry.lang || '').toLowerCase() === 'json') {
        try {
          const parsed = JSON.parse(code);
          code = JSON.stringify(parsed, null, 2);
        } catch (e) {
          // leave as-is if not valid JSON
        }
        const highlighted = this.highlightJson(code);
        const langAttr = ` data-lang="json"`;
        return `<pre class="md-codeblock"${langAttr}><code>${highlighted}</code></pre>`;
      }
      const codeEsc = this.escapeHtml(code);
      const langAttr = entry.lang ? ` data-lang="${this.escapeHtml(entry.lang)}"` : '';
      return `<pre class="md-codeblock"${langAttr}><code>${codeEsc}</code></pre>`;
    });

    return html;
  }

  /**
   * Parse only block-level constructs inside blockquotes (reuse main parser features
   * without causing infinite recursion). This function is referenced earlier.
   */
  blockOnlyToHtml(src) {
    return this.markdownToHtml(src);
  }

  // Inline formatting for: bold, italic, inline code, links, line breaks
  inline(s) {
    if (!s) return '';

    // Convert two trailing spaces to <br/>
    // We'll replace double spaces followed by EOL with <br/>
    // Do it safely across lines by appending a sentinel newline
    s = s.replace(/ {2}(\n|$)/g, '<br/>$1');

    // Protect inline code spans first: `code`
    const codes = [];
    s = s.replace(/`([^`]+)`/g, (_m, code) => {
      const idx = codes.length;
      codes.push(code);
      return `\u0000CODE_${idx}\u0000`;
    });

    // Links: [text](url)
    s = s.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (_m, text, url) => {
      const safeText = this.escapeHtml(text);
      const safeUrl = this.escapeUrl(url);
      return `<a href="${safeUrl}">${safeText}</a>`;
    });

    // Simple table cell inline pipes handling inside inline context is not needed here
    // because table parsing is done at block level above.

    // Bold: **text**
    s = s.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');

    // Italic: *text*
    s = s.replace(/\*([^*]+)\*/g, '<em>$1</em>');

    // Restore inline code
    s = s.replace(/\u0000CODE_(\d+)\u0000/g, (_m, idxStr) => {
      const idx = Number(idxStr);
      return `<code>${this.escapeHtml(codes[idx])}</code>`;
    });

    return s;
  }

  // Very small JSON highlighter (span tags with classes for styling)
  // Robust against embedded @{ref} and only highlights inside fenced ```json blocks.
  highlightJson(code) {
    // Strategy: token-based highlighter to avoid corrupt HTML and avoid
    // accidental matches that produce visible class text in output.
    // We tokenize the already-escaped string and then wrap tokens.
    const esc = this.escapeHtml(code);

    // Simple tokenizer for JSON: strings, numbers, booleans, null, punctuation, whitespace
    const tokens = [];
    const re = /"(?:\\.|[^"\\])*"|-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|\btrue\b|\bfalse\b|\bnull\b|[{}\[\]:,]|\s+/g;
    let m;
    while ((m = re.exec(esc)) !== null) {
      tokens.push(m[0]);
    }

    // Helper to detect a "key": a string token followed by optional whitespace and then a colon
    const isKeyAt = (idx) => {
      if (!/^"/.test(tokens[idx])) return false;
      let j = idx + 1;
      // skip whitespace
      while (j < tokens.length && /^\s+$/.test(tokens[j])) j++;
      return j < tokens.length && tokens[j] === ':';
    };

    const outParts = [];
    for (let i = 0; i < tokens.length; i++) {
      const t = tokens[i];

      if (/^\s+$/.test(t)) {
        outParts.push(t);
        continue;
      }

      if (t === '{' || t === '}' || t === '[' || t === ']' || t === ':' || t === ',') {
        outParts.push(t);
        continue;
      }

      if (/^"/.test(t)) {
        // string: check if it's a key
        if (isKeyAt(i)) {
          outParts.push(`<span class="md-json-key">${t}</span>`);
        } else {
          outParts.push(`<span class="md-json-string">${t}</span>`);
        }
        continue;
      }

      if (/^-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?$/.test(t)) {
        outParts.push(`<span class="md-json-number">${t}</span>`);
        continue;
      }

      if (t === 'true' || t === 'false') {
        outParts.push(`<span class="md-json-boolean">${t}</span>`);
        continue;
      }

      if (t === 'null') {
        outParts.push(`<span class="md-json-null">${t}</span>`);
        continue;
      }

      // Fallback
      outParts.push(t);
    }

    return outParts.join('');
  }

  escapeHtml(str) {
    // Properly escape HTML special characters
    return String(str)
      .replace(/&/g, '&')
      .replace(/</g, '<')
      .replace(/>/g, '>');
  }

  escapeUrl(str) {
    try {
      // Basic URL sanitation
      const url = String(str).trim();
      // Disallow javascript: and data: (except data:image for images which we don't render here)
      if (/^\s*javascript:/i.test(url)) return '#';
      if (/^\s*data:/i.test(url)) return '#';
      return url;
    } catch (e) {
      return '#';
    }
  }

  sanitize(html) {
    // Remove script and style tags completely
    let safe = html.replace(/<\/?(script|style)[^>]*>/gi, '');
    // Remove on* event handler attributes
    safe = safe.replace(/\son[a-z]+\s*=\s*"(?:[^"]*)"/gi, '');
    safe = safe.replace(/\son[a-z]+\s*=\s*'(?:[^']*)'/gi, '');
    safe = safe.replace(/\son[a-z]+\s*=\s*[^\s>]+/gi, '');
    // Allow @{...} and curly braces to remain as plain text already in content.
    return safe;
  }
}
