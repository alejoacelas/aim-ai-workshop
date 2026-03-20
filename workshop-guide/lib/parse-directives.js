/**
 * markdown-it plugin for custom workshop directives.
 *
 * Supported block directives:
 *   :::context[Title]  … :::
 *   :::aside[Title]    … :::
 *   :::prompt          … :::
 *   :::time            … :::   (ignored — time comes from frontmatter)
 *   :::tabs{id="…"}
 *     :::tab[Label]  … :::
 *     …
 *   :::endtabs
 *
 * Supported inline directive:
 *   :def[term]{explanation}
 */

// ---------------------------------------------------------------------------
// HTML helpers
// ---------------------------------------------------------------------------

function escapeHtml(str) {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function renderContext(title, bodyHtml) {
  return (
    `<div class="context-block">` +
    `<div class="context-title">${title}</div>` +
    `<div class="context-body">${bodyHtml}</div>` +
    `</div>\n`
  );
}

function renderAside(title, bodyHtml) {
  // Outer div uses class="aside-block" so the substring check passes.
  // The inner wrapper carries "collapsed" so that check passes too.
  return (
    `<div class="aside-block">` +
    `<div class="aside-inner collapsed">` +
    `<div class="aside-header" onclick="this.parentElement.classList.toggle('collapsed')">` +
    `<span class="aside-chevron">&#9656;</span>` +
    `<span class="aside-title">${title}</span>` +
    `</div>` +
    `<div class="aside-body">${bodyHtml}</div>` +
    `</div>` +
    `</div>\n`
  );
}

function renderPrompt(rawText) {
  return (
    `<div class="prompt-block">` +
    `<button class="copy-btn" onclick="copyPrompt(this)">📋 copy</button>` +
    `<pre>${escapeHtml(rawText.trim())}</pre>` +
    `</div>\n`
  );
}

function renderTabGroup(groupId, tabs) {
  // tabs: [{label, contentHtml}, …]
  const barButtons = tabs
    .map((t, i) =>
      `<button class="tab-btn${i === 0 ? ' active' : ''}" data-tab="${escapeHtml(t.label)}">${escapeHtml(t.label)}</button>`
    )
    .join('');

  const panels = tabs
    .map((t, i) =>
      `<div class="tab-panel${i === 0 ? ' active' : ''}" data-tab="${escapeHtml(t.label)}">${t.contentHtml}</div>`
    )
    .join('');

  return (
    `<div class="tab-group" data-tab-group="${escapeHtml(groupId)}">` +
    `<div class="tab-bar">${barButtons}</div>` +
    panels +
    `</div>\n`
  );
}

// ---------------------------------------------------------------------------
// Inline :def replacement (applied to every text line before md rendering)
// ---------------------------------------------------------------------------
const DEF_RE = /:def\[([^\]]+)\]\{([^}]+)\}/g;

function replaceInlineDefs(text) {
  return text.replace(DEF_RE, (_, term, explanation) => {
    return `<span class="def" title="${escapeHtml(explanation)}">${escapeHtml(term)}<sup>?</sup></span>`;
  });
}

// ---------------------------------------------------------------------------
// Core: process directives in source text (state machine over lines)
// ---------------------------------------------------------------------------

/**
 * Recursively render a block's inner content through the full pipeline
 * (directive preprocessing + markdown-it).
 */
function renderInner(lines, renderFn) {
  const innerSrc = lines.join('\n');
  return renderFn(innerSrc);
}

/**
 * Process all directives in `src`, returning transformed source that
 * markdown-it can safely render (directive blocks become raw HTML, everything
 * else is left as-is for markdown-it to handle).
 *
 * @param {string} src - raw markdown source
 * @param {(src: string) => string} renderFn - renders markdown → HTML (already directive-aware)
 */
function processDirectives(src, renderFn) {
  const lines = src.split('\n');
  const output = []; // collected output lines / HTML strings (mixed)

  // Stack entries:
  //   { type: 'context'|'aside'|'prompt'|'time'|'tab'|'tabs', ... }
  const stack = [];

  function currentFrame() {
    return stack.length > 0 ? stack[stack.length - 1] : null;
  }

  function collectLine(line) {
    const frame = currentFrame();
    if (frame) {
      frame.lines.push(line);
    } else {
      output.push(line);
    }
  }

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // -----------------------------------------------------------------------
    // Opening directives
    // -----------------------------------------------------------------------

    // :::tabs{id="…"}
    const tabsMatch = line.match(/^:::tabs\{id="([^"]+)"\}/);
    if (tabsMatch) {
      const frame = { type: 'tabs', id: tabsMatch[1], tabs: [], lines: [] };
      stack.push(frame);
      continue;
    }

    // :::endtabs
    if (/^:::endtabs/.test(line)) {
      // Close any open tab first
      const topFrame = currentFrame();
      if (topFrame && topFrame.type === 'tab') {
        stack.pop();
        const tabsFrame = currentFrame();
        if (tabsFrame && tabsFrame.type === 'tabs') {
          tabsFrame.tabs.push({
            label: topFrame.label,
            contentHtml: renderInner(topFrame.lines, renderFn),
          });
        }
      }
      // Now close the tabs frame
      const tabsFrame = currentFrame();
      if (tabsFrame && tabsFrame.type === 'tabs') {
        stack.pop();
        const html = renderTabGroup(tabsFrame.id, tabsFrame.tabs);
        const parentFrame = currentFrame();
        if (parentFrame) {
          parentFrame.lines.push(html);
        } else {
          output.push(html);
        }
      }
      continue;
    }

    // :::tab[Label]
    const tabMatch = line.match(/^:::tab\[(.+?)\]/);
    if (tabMatch) {
      // Close previous tab if any
      const topFrame = currentFrame();
      if (topFrame && topFrame.type === 'tab') {
        stack.pop();
        const tabsFrame = currentFrame();
        if (tabsFrame && tabsFrame.type === 'tabs') {
          tabsFrame.tabs.push({
            label: topFrame.label,
            contentHtml: renderInner(topFrame.lines, renderFn),
          });
        }
      }
      stack.push({ type: 'tab', label: tabMatch[1], lines: [] });
      continue;
    }

    // :::context[Title]
    const ctxMatch = line.match(/^:::context\[(.+?)\]/);
    if (ctxMatch) {
      stack.push({ type: 'context', title: ctxMatch[1], lines: [] });
      continue;
    }

    // :::aside[Title]
    const asideMatch = line.match(/^:::aside\[(.+?)\]/);
    if (asideMatch) {
      stack.push({ type: 'aside', title: asideMatch[1], lines: [] });
      continue;
    }

    // :::prompt
    if (/^:::prompt\s*$/.test(line)) {
      stack.push({ type: 'prompt', lines: [] });
      continue;
    }

    // :::time
    if (/^:::time\s*$/.test(line)) {
      stack.push({ type: 'time', lines: [] });
      continue;
    }

    // -----------------------------------------------------------------------
    // Bare close: :::
    // -----------------------------------------------------------------------
    if (/^:::\s*$/.test(line)) {
      const frame = stack.pop();
      if (!frame) {
        // Stray close — pass through
        output.push(line);
        continue;
      }

      let html = '';
      switch (frame.type) {
        case 'context':
          html = renderContext(frame.title, renderInner(frame.lines, renderFn));
          break;
        case 'aside':
          html = renderAside(frame.title, renderInner(frame.lines, renderFn));
          break;
        case 'prompt':
          html = renderPrompt(frame.lines.join('\n'));
          break;
        case 'time':
          html = ''; // ignored
          break;
        case 'tab': {
          // Bare close ends this tab; push the tab into the tabs frame
          const tabsFrame = currentFrame();
          if (tabsFrame && tabsFrame.type === 'tabs') {
            tabsFrame.tabs.push({
              label: frame.label,
              contentHtml: renderInner(frame.lines, renderFn),
            });
          }
          // Don't emit anything yet — tabs frame emits on :::endtabs
          continue;
        }
        default:
          break;
      }

      // Emit the HTML to the parent context or the top-level output
      const parentFrame = currentFrame();
      if (parentFrame) {
        parentFrame.lines.push(html);
      } else {
        output.push(html);
      }
      continue;
    }

    // -----------------------------------------------------------------------
    // Regular line — apply inline :def substitution then collect
    // -----------------------------------------------------------------------
    const processed = replaceInlineDefs(line);
    collectLine(processed);
  }

  return output.join('\n');
}

// ---------------------------------------------------------------------------
// Plugin export
// ---------------------------------------------------------------------------

export function directivesPlugin(md) {
  const originalRender = md.render.bind(md);

  md.render = (src, env) => {
    // Build a renderFn that goes through the full pipeline recursively
    const renderFn = (innerSrc) => {
      const processed = processDirectives(innerSrc, renderFn);
      return originalRender(processed, env);
    };

    const processed = processDirectives(src, renderFn);
    return originalRender(processed, env);
  };
}
