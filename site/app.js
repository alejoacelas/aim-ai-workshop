/* ─── Configuration ─────────────────────────────────────────────────────────── */

// When served from the project root (npx serve . from the project root),
// the content dir is at /content/ and the site is at /site/.
// CONTENT_BASE is relative to the location of index.html.
const CONTENT_BASE = '../content/';

/* ─── Marked configuration ──────────────────────────────────────────────────── */

marked.setOptions({
  breaks: true,
  gfm: true,
});

/* ─── Frontmatter stripper ──────────────────────────────────────────────────── */

function stripFrontmatter(text) {
  if (!text.startsWith('---')) return text;
  const end = text.indexOf('\n---', 3);
  if (end === -1) return text;
  return text.slice(end + 4).trimStart();
}

/* ─── ::: block preprocessor ───────────────────────────────────────────────── */
/*
  Converts custom ::: blocks into HTML placeholder tokens before marked.js sees
  the markdown. We use placeholder tokens (BASE64-ish markers) to prevent marked
  from mangling the HTML inside.

  Supported block types:
    :::context[Optional Title]  ... :::
    :::prompt                   ... :::
    :::terminal                 ... :::
    :::aside[Title]             ... :::
    :::tabs{id="uid"}           :::tab[Label] ... ::: ... :::endtabs
    :::time                     ... :::
*/

const PLACEHOLDER_PREFIX = '<!--XBLOCK';
const PLACEHOLDER_SUFFIX = 'XEND-->';
let _placeholderIndex = 0;
const _placeholders = {};

function makePlaceholder(html) {
  const key = `${PLACEHOLDER_PREFIX}${_placeholderIndex++}${PLACEHOLDER_SUFFIX}`;
  _placeholders[key] = html;
  return key;
}

function restorePlaceholders(html) {
  const re = new RegExp(`${PLACEHOLDER_PREFIX.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\d+${PLACEHOLDER_SUFFIX.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}`, 'g');
  // Restore iteratively since restored HTML may contain more placeholders
  let prev;
  do {
    prev = html;
    html = html.replace(re, (m) => _placeholders[m] || m);
  } while (html !== prev);
  return html;
}

/**
 * Parse a block body that may contain nested ::: blocks.
 * Returns { type, args, body, rest } where rest is the remaining text.
 */
function parseBlock(text) {
  // Match opening ::: line
  const openRe = /^:::(\w+)(?:\[([^\]]*)\])?(?:\{([^}]*)\})?\s*\n/;
  const m = text.match(openRe);
  if (!m) return null;

  const type = m[1];
  const titleArg = m[2] || null;
  const attrArg = m[3] || null;
  let pos = m[0].length;
  let depth = 1;
  let body = '';

  while (pos < text.length && depth > 0) {
    // Peek ahead for ::: lines
    const remaining = text.slice(pos);
    const nextOpen = remaining.match(/^:::(\w+)/);
    const nextClose = remaining.match(/^:::/);
    const lineEnd = remaining.indexOf('\n');
    const lineLen = lineEnd === -1 ? remaining.length : lineEnd + 1;
    const line = remaining.slice(0, lineLen);

    if (nextOpen && nextOpen[1] !== 'endtabs' && nextOpen[1] !== 'tab') {
      // It might be a nested block opener — let it be included in body
      depth++;
      body += line;
      pos += lineLen;
    } else if (nextClose && !nextOpen) {
      // Closing :::
      depth--;
      if (depth > 0) {
        body += line;
      }
      pos += lineLen;
    } else {
      body += line;
      pos += lineLen;
    }
  }

  return { type, titleArg, attrArg, body, rest: text.slice(pos) };
}

/**
 * Pre-process the full markdown string, replacing ::: blocks with HTML placeholders.
 * Handles nesting correctly.
 */
function preprocessBlocks(text) {
  // Normalize: strip leading whitespace from ::: directive lines so that
  // indented blocks (e.g. inside list items) are still recognised.
  const normalized = text.replace(/^[ \t]+(:::)/gm, '$1');
  // Replace inline :def[term]{explanation} with tooltip spans
  const withDefs = normalized.replace(/:def\[([^\]]+)\]\{([^}]+)\}/g,
    (_, term, explanation) => `<span class="def" tabindex="0">${escapeHtml(term)}<sup>?</sup><span class="def-tooltip">${escapeHtml(explanation)}</span></span>`);
  return _preprocessBlocks(withDefs);
}

function _preprocessBlocks(text) {
  let result = '';
  let pos = 0;

  while (pos < text.length) {
    // Find the next ::: opener
    const nextBlockIdx = text.indexOf('\n:::', pos);
    const startIdx = (pos === 0 && text.startsWith(':::')) ? 0
      : nextBlockIdx === -1 ? -1
      : nextBlockIdx + 1; // +1 to skip the \n

    if (startIdx === -1) {
      result += text.slice(pos);
      break;
    }

    // Text before the block
    if (startIdx > pos) {
      result += text.slice(pos, startIdx);
    }

    const blockText = text.slice(startIdx);

    // Detect :::endtabs — shouldn't appear at top level normally, skip
    if (blockText.startsWith(':::endtabs')) {
      result += '\n';
      pos = startIdx + ':::endtabs'.length;
      // skip to end of line
      const eol = text.indexOf('\n', pos);
      pos = eol === -1 ? text.length : eol + 1;
      continue;
    }

    // Detect :::tabs
    const tabsMatch = blockText.match(/^:::tabs\{id="([^"]+)"\}\s*\n/);
    if (tabsMatch) {
      const tabGroupId = tabsMatch[1];
      pos = startIdx + tabsMatch[0].length;
      const html = parseTabsBlock(tabGroupId, text, pos);
      result += '\n' + makePlaceholder(html.html) + '\n';
      pos = html.endPos;
      continue;
    }

    // Parse generic block
    const parsed = parseGenericBlock(blockText);
    if (!parsed) {
      // Not a valid block, emit as-is and advance
      result += blockText[0];
      pos = startIdx + 1;
      continue;
    }

    result += '\n' + makePlaceholder(parsed.html) + '\n';
    pos = startIdx + parsed.consumed;
  }

  return result;
}

function parseGenericBlock(text) {
  const openRe = /^:::(context|prompt|terminal|aside|time|tab)(?:\[([^\]]*)\])?(?:\{([^}]*)\})?\s*\n/;
  const m = text.match(openRe);
  if (!m) return null;

  const type = m[1];
  const titleArg = m[2] || null;
  let pos = m[0].length;
  let depth = 1;
  let body = '';

  while (pos < text.length && depth > 0) {
    const remaining = text.slice(pos);
    const lineEnd = remaining.indexOf('\n');
    const lineLen = lineEnd === -1 ? remaining.length : lineEnd + 1;
    const line = remaining.slice(0, lineLen);
    const trimmed = line.trim();

    // Any ::: opener increases nesting depth
    if (/^:::(?!endtabs)(\w)/.test(trimmed)) {
      depth++;
      body += line;
      pos += lineLen;
    } else if (/^:::endtabs/.test(trimmed)) {
      // :::endtabs decreases depth (matches a :::tabs opener)
      depth--;
      if (depth > 0) {
        body += line;
      }
      pos += lineLen;
    } else if (trimmed === ':::') {
      depth--;
      if (depth > 0) {
        body += line;
      }
      pos += lineLen;
    } else {
      body += line;
      pos += lineLen;
    }
  }

  const html = renderBlock(type, titleArg, body.trim());
  return { html, consumed: pos };
}

function renderBlock(type, titleArg, body) {
  // Recursively preprocess nested blocks in the body
  const processedBody = _preprocessBlocks(body);

  switch (type) {
    case 'context': {
      const titleHtml = titleArg
        ? `<div class="block-context-title">${escapeHtml(titleArg)}</div>`
        : '';
      return `<div class="block-context">${titleHtml}${marked.parse(processedBody)}</div>`;
    }
    case 'prompt': {
      const escaped = escapeHtml(body); // raw body, no markdown processing
      return `<div class="block-prompt"><pre><code>${escaped}</code></pre><button class="copy-btn" data-text="${escapeAttr(body)}">Copy</button></div>`;
    }
    case 'terminal': {
      const escaped = escapeHtml(body); // raw body, no markdown processing
      return `<div class="block-terminal"><pre><code>${escaped}</code></pre><button class="copy-btn" data-text="${escapeAttr(body)}">Copy</button></div>`;
    }
    case 'aside': {
      const summary = titleArg ? escapeHtml(titleArg) : 'More details';
      return `<details class="block-aside"><summary>${summary}</summary><div class="aside-body">${marked.parse(processedBody)}</div></details>`;
    }
    case 'time': {
      // Rendered inline at section header level; suppress here
      return `<div class="block-time" data-time="${escapeAttr(body.trim())}"></div>`;
    }
    default:
      return `<div class="block-${escapeHtml(type)}">${marked.parse(processedBody)}</div>`;
  }
}

function parseTabsBlock(tabGroupId, text, startPos) {
  const tabs = [];
  let pos = startPos;

  while (pos < text.length) {
    const remaining = text.slice(pos);

    // Check for :::endtabs
    if (/^:::endtabs/.test(remaining)) {
      const eol = remaining.indexOf('\n');
      pos += eol === -1 ? remaining.length : eol + 1;
      break;
    }

    // Check for :::tab[Label]
    const tabMatch = remaining.match(/^:::tab\[([^\]]+)\]\s*\n/);
    if (tabMatch) {
      const label = tabMatch[1];
      pos += tabMatch[0].length;
      // Collect tab body until next sibling :::tab[ or :::endtabs at depth 0.
      // Track nesting depth for ALL ::: openers so that :::prompt ... :::
      // or :::aside ... ::: inside a tab don't prematurely end the tab body.
      let tabBody = '';
      let depth = 0; // depth 0 = inside this tab at the top level

      while (pos < text.length) {
        const rem = text.slice(pos);
        const lineEnd = rem.indexOf('\n');
        const lineLen = lineEnd === -1 ? rem.length : lineEnd + 1;
        const line = rem.slice(0, lineLen);
        const trimmed = line.trim();

        // At depth 0, sibling :::tab[ or :::endtabs signal end of this tab
        if (depth === 0 && (/^:::tab\[/.test(trimmed) || /^:::endtabs/.test(trimmed))) {
          break;
        }

        // Any ::: opener (tabs, tab, prompt, aside, context, time, etc.) increases depth
        if (/^:::(?!endtabs)(\w)/.test(trimmed)) {
          depth++;
          tabBody += line;
          pos += lineLen;
        } else if (/^:::endtabs/.test(trimmed)) {
          // :::endtabs decreases depth (matches the :::tabs opener)
          if (depth > 0) {
            depth--;
            tabBody += line;
          }
          pos += lineLen;
        } else if (trimmed === ':::') {
          // Closing ::: — at depth 0 inside a tab this shouldn't appear unless
          // there's a stray closer; handle gracefully
          if (depth > 0) {
            depth--;
            tabBody += line;
          }
          pos += lineLen;
        } else {
          tabBody += line;
          pos += lineLen;
        }
      }

      tabs.push({ label, body: tabBody.trim() });
    } else {
      // Skip unexpected content
      const lineEnd = remaining.indexOf('\n');
      pos += lineEnd === -1 ? remaining.length : lineEnd + 1;
    }
  }

  if (tabs.length === 0) {
    return { html: '', endPos: pos };
  }

  const savedIndex = localStorage.getItem(`tab:${tabGroupId}`) || null;
  const defaultActive = savedIndex && tabs.some(t => t.label === savedIndex)
    ? savedIndex : tabs[0].label;

  const tabBtns = tabs.map(t => {
    const active = t.label === defaultActive ? ' active' : '';
    return `<button class="tab-btn${active}" data-group="${escapeAttr(tabGroupId)}" data-tab="${escapeAttr(t.label)}">${escapeHtml(t.label)}</button>`;
  }).join('');

  const tabPanels = tabs.map(t => {
    const active = t.label === defaultActive ? ' active' : '';
    const processedBody = _preprocessBlocks(t.body);
    return `<div class="tab-panel${active}" data-group="${escapeAttr(tabGroupId)}" data-tab="${escapeAttr(t.label)}">${marked.parse(processedBody)}</div>`;
  }).join('');

  const html = `<div class="block-tabs" data-group="${escapeAttr(tabGroupId)}"><div class="tab-bar">${tabBtns}</div>${tabPanels}</div>`;
  return { html, endPos: pos };
}

/* ─── HTML escape helpers ───────────────────────────────────────────────────── */

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function escapeAttr(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;');
}

/* ─── Tab interaction ───────────────────────────────────────────────────────── */

function activateTab(groupId, label) {
  // Save preference
  localStorage.setItem(`tab:${groupId}`, label);

  // Update all tab groups with this id across the page
  document.querySelectorAll(`.tab-btn[data-group="${groupId}"]`).forEach(btn => {
    btn.classList.toggle('active', btn.dataset.tab === label);
  });
  document.querySelectorAll(`.tab-panel[data-group="${groupId}"]`).forEach(panel => {
    panel.classList.toggle('active', panel.dataset.tab === label);
  });
}

document.addEventListener('click', e => {
  const btn = e.target.closest('.tab-btn');
  if (btn) {
    activateTab(btn.dataset.group, btn.dataset.tab);
  }

  const copyBtn = e.target.closest('.copy-btn');
  if (copyBtn) {
    const text = copyBtn.dataset.text;
    navigator.clipboard.writeText(text).then(() => {
      copyBtn.textContent = 'Copied!';
      copyBtn.classList.add('copied');
      setTimeout(() => {
        copyBtn.textContent = 'Copy';
        copyBtn.classList.remove('copied');
      }, 1800);
    }).catch(() => {
      // Fallback
      const ta = document.createElement('textarea');
      ta.value = text;
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      document.body.removeChild(ta);
      copyBtn.textContent = 'Copied!';
      copyBtn.classList.add('copied');
      setTimeout(() => {
        copyBtn.textContent = 'Copy';
        copyBtn.classList.remove('copied');
      }, 1800);
    });
  }
});

/* ─── Hamburger / sidebar toggle ───────────────────────────────────────────── */

const hamburger = document.getElementById('hamburger');
const sidebar = document.getElementById('sidebar');

hamburger.addEventListener('click', () => {
  hamburger.classList.toggle('open');
  sidebar.classList.toggle('open');
});

// Close sidebar when clicking a nav link on mobile
sidebar.addEventListener('click', e => {
  if (e.target.closest('a') && window.innerWidth <= 768) {
    hamburger.classList.remove('open');
    sidebar.classList.remove('open');
  }
});

/* ─── Progress bar ──────────────────────────────────────────────────────────── */

const progressBar = document.getElementById('progress-bar');

function updateProgress() {
  const scrollTop = window.scrollY || document.documentElement.scrollTop;
  const docHeight = document.documentElement.scrollHeight - window.innerHeight;
  const progress = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
  progressBar.style.width = `${Math.min(progress, 100)}%`;
}

window.addEventListener('scroll', updateProgress, { passive: true });

/* ─── Scroll spy ────────────────────────────────────────────────────────────── */

let sectionAnchors = [];

function setupScrollSpy() {
  sectionAnchors = Array.from(document.querySelectorAll('.section-block'))
    .map(el => ({ id: el.id, top: el.offsetTop }));
}

function updateActiveSection() {
  const scrollTop = window.scrollY + 100;
  let activeId = sectionAnchors.length ? sectionAnchors[0].id : '';
  for (const s of sectionAnchors) {
    if (scrollTop >= s.top) activeId = s.id;
  }
  document.querySelectorAll('#nav-list a').forEach(a => {
    a.classList.toggle('active', a.dataset.section === activeId);
  });
}

window.addEventListener('scroll', updateActiveSection, { passive: true });

/* ─── Build sidebar ─────────────────────────────────────────────────────────── */

function buildSidebar(sections, siteTitle) {
  document.getElementById('site-title').textContent = siteTitle || 'Workshop';

  // Total time
  const totalMinutes = sections.reduce((sum, s) => {
    const m = parseInt(s.time, 10);
    return sum + (isNaN(m) ? 0 : m);
  }, 0);
  const totalEl = document.getElementById('total-time');
  if (totalEl && totalMinutes > 0) {
    totalEl.textContent = `${totalMinutes} min total`;
  }

  const list = document.getElementById('nav-list');
  list.innerHTML = sections.map(s => `
    <li>
      <a href="#${s.id}" data-section="${s.id}">
        <span class="nav-title">${escapeHtml(s.title)}</span>
        ${s.time ? `<span class="nav-time">${escapeHtml(s.time)}</span>` : ''}
      </a>
    </li>
  `).join('');
}

/* ─── Render a single section ───────────────────────────────────────────────── */

function renderSection(section, rawMarkdown) {
  // Strip YAML frontmatter
  const md = stripFrontmatter(rawMarkdown);

  // Reset placeholders per section
  _placeholderIndex = 0;
  Object.keys(_placeholders).forEach(k => delete _placeholders[k]);

  // Pre-process ::: blocks → HTML placeholders
  const preprocessed = preprocessBlocks(md);

  // Run marked
  let html = marked.parse(preprocessed);

  // Restore placeholders
  html = restorePlaceholders(html);

  // Wrap in section block
  const wrapper = document.createElement('div');
  wrapper.className = 'section-block';
  wrapper.id = section.id;
  wrapper.innerHTML = html;

  // Inject time badge next to first h1
  const h1 = wrapper.querySelector('h1');
  if (h1 && section.time) {
    const headerDiv = document.createElement('div');
    headerDiv.className = 'section-header';
    h1.parentNode.insertBefore(headerDiv, h1);
    headerDiv.appendChild(h1);
    const badge = document.createElement('span');
    badge.className = 'time-badge';
    badge.textContent = section.time;
    headerDiv.appendChild(badge);
  }

  return wrapper;
}

/* ─── Main loader ───────────────────────────────────────────────────────────── */

async function loadSite() {
  const contentEl = document.getElementById('content');

  let manifest;
  try {
    const res = await fetch('manifest.json');
    if (!res.ok) throw new Error(`manifest.json: ${res.status}`);
    manifest = await res.json();
  } catch (err) {
    contentEl.innerHTML = `<div class="block-context"><div class="block-context-title">Error</div><p>Could not load manifest.json: ${escapeHtml(err.message)}</p><p>Make sure you're serving this directory (e.g. <code>npx serve .</code>) rather than opening index.html directly.</p></div>`;
    return;
  }

  const sections = manifest.sections || [];
  buildSidebar(sections, manifest.title);

  // Fetch all markdown files in parallel
  const results = await Promise.allSettled(
    sections.map(s =>
      fetch(CONTENT_BASE + s.file)
        .then(r => {
          if (!r.ok) throw new Error(`${s.file}: ${r.status}`);
          return r.text();
        })
    )
  );

  for (let i = 0; i < sections.length; i++) {
    const section = sections[i];
    const result = results[i];
    if (result.status === 'fulfilled') {
      const el = renderSection(section, result.value);
      contentEl.appendChild(el);
    } else {
      const errEl = document.createElement('div');
      errEl.className = 'section-block block-context';
      errEl.id = section.id;
      errEl.innerHTML = `<div class="block-context-title">Could not load "${escapeHtml(section.title)}"</div><p>${escapeHtml(result.reason.message)}</p>`;
      contentEl.appendChild(errEl);
    }
  }

  // Restore saved tab preferences across all tab groups
  document.querySelectorAll('.block-tabs').forEach(tabs => {
    const groupId = tabs.dataset.group;
    const saved = localStorage.getItem(`tab:${groupId}`);
    if (saved) activateTab(groupId, saved);
  });

  // Add hover previews to GIF links
  document.querySelectorAll('a[href$=".gif"], a[href$=".gifv"]').forEach(a => {
    a.classList.add('gif-preview');
    const tip = document.createElement('span');
    tip.className = 'gif-tooltip';
    tip.innerHTML = `<img src="${escapeAttr(a.href)}" alt="Preview">`;
    a.appendChild(tip);
  });

  // Set up scroll spy
  setupScrollSpy();
  updateActiveSection();
  updateProgress();
}

loadSite();
