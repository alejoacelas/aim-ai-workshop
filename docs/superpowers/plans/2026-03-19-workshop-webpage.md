# Workshop webpage implementation plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a static webpage from annotated markdown files, plus a GDocs sync pipeline with colored formatting.

**Architecture:** Node.js build script reads `content/*.md` files with custom `:::` directives, renders them into a single self-contained `index.html` with dark theme, sticky sidebar, and interactive elements (tabs, collapsible asides, copy buttons). A separate sync pipeline pushes content to Google Docs and applies color formatting via the Docs API.

**Tech Stack:** Node.js (markdown-it, gray-matter), vanilla JS/CSS, Python (google-api-python-client via uv), gdoc CLI

---

## File structure

```
workshop-guide/
├── package.json              # dependencies: markdown-it, gray-matter
├── build.js                  # main build script → dist/index.html
├── lib/
│   ├── parse-directives.js   # markdown-it plugin for :::context, :::aside, :::prompt, :::tabs, :def
│   ├── template.js           # HTML shell (head, sidebar, CSS, JS) as template literals
│   └── read-content.js       # reads content/*.md, parses frontmatter, sorts by order
├── sync-gdoc.js              # strips directives → plain markdown → gdoc push
├── format-gdoc.py            # applies colors via Docs API batchUpdate
└── dist/
    └── index.html            # build output (self-contained, all CSS/JS inlined)

skills/
└── deploy-workshop/
    └── SKILL.md              # /deploy-workshop skill
```

Source files stay at `content/*.md` in the repo root.

---

## Chunk 1: Project setup and markdown parsing

### Task 1: Initialize the project

**Files:**
- Create: `workshop-guide/package.json`

- [ ] **Step 1: Create package.json**

```json
{
  "name": "workshop-guide",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "node build.js"
  },
  "dependencies": {
    "markdown-it": "^14.0.0",
    "gray-matter": "^4.0.3"
  }
}
```

- [ ] **Step 2: Install dependencies**

Run: `cd workshop-guide && yarn install`
Expected: `node_modules/` created, no errors

- [ ] **Step 3: Commit**

```bash
git add workshop-guide/package.json workshop-guide/yarn.lock
git commit -m "feat: initialize workshop-guide project with markdown-it and gray-matter"
```

---

### Task 2: Content reader module

**Files:**
- Create: `workshop-guide/lib/read-content.js`

- [ ] **Step 1: Write a test**

Create `workshop-guide/test-read-content.js`:

```js
import { readContent } from './lib/read-content.js';

const sections = readContent();
console.assert(sections.length >= 2, 'Should find at least two content files');
console.assert(sections[0].order <= sections[1].order, 'Should be sorted by order');
console.assert(sections[0].title, 'Each section should have a title');
console.assert(sections[0].id, 'Each section should have an id');
console.assert(sections[0].time, 'Each section should have a time');
console.assert(sections[0].body, 'Each section should have a body');
console.log(`✓ Found ${sections.length} sections, sorted by order`);
sections.forEach(s => console.log(`  ${s.order}: ${s.title} (${s.time})`));
```

- [ ] **Step 2: Run it to verify it fails**

Run: `cd workshop-guide && node test-read-content.js`
Expected: Error — module not found

- [ ] **Step 3: Implement read-content.js**

```js
import fs from 'fs';
import path from 'path';
import matter from 'gray-matter';

const CONTENT_DIR = path.resolve(import.meta.dirname, '..', 'content');

export function readContent() {
  const files = fs.readdirSync(CONTENT_DIR)
    .filter(f => f.endsWith('.md'))
    .map(f => {
      const raw = fs.readFileSync(path.join(CONTENT_DIR, f), 'utf-8');
      const { data, content } = matter(raw);
      return {
        title: data.title,
        id: data.id,
        time: data.time || '',
        order: data.order ?? 99,
        body: content.trim(),
        filename: f,
      };
    });
  files.sort((a, b) => a.order - b.order);
  return files;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd workshop-guide && node test-read-content.js`
Expected: Lists all sections in order, no assertion errors

- [ ] **Step 5: Commit**

```bash
git add workshop-guide/lib/read-content.js workshop-guide/test-read-content.js
git commit -m "feat: add content reader module — reads and sorts content/*.md by order"
```

---

### Task 3: Custom markdown-it plugin for directives

This is the core parsing logic. It handles `:::context`, `:::aside`, `:::prompt`, `:::tabs`/`:::tab`/`:::endtabs`, and inline `:def[term]{explanation}`.

**Files:**
- Create: `workshop-guide/lib/parse-directives.js`

- [ ] **Step 1: Write a test**

Create `workshop-guide/test-parse-directives.js`:

```js
import MarkdownIt from 'markdown-it';
import { directivesPlugin } from './lib/parse-directives.js';

const md = new MarkdownIt({ html: true }).use(directivesPlugin);

// Test context block
const ctx = md.render(':::context[My Title]\nSome content.\n:::');
console.assert(ctx.includes('class="context-block"'), 'context block class');
console.assert(ctx.includes('My Title'), 'context title');
console.assert(ctx.includes('Some content.'), 'context body');

// Test aside block
const aside = md.render(':::aside[Tip]\nHelpful info.\n:::');
console.assert(aside.includes('class="aside-block"'), 'aside block class');
console.assert(aside.includes('Tip'), 'aside title');
console.assert(aside.includes('collapsed'), 'aside starts collapsed');

// Test prompt block
const prompt = md.render(':::prompt\nDo the thing\n:::');
console.assert(prompt.includes('class="prompt-block"'), 'prompt block class');
console.assert(prompt.includes('Do the thing'), 'prompt text');
console.assert(prompt.includes('copy'), 'prompt has copy button');

// Test tabs
const tabs = md.render(':::tabs{id="os"}\n:::tab[Mac]\nMac stuff\n:::\n:::tab[Windows]\nWin stuff\n:::\n:::endtabs');
console.assert(tabs.includes('data-tab-group="os"'), 'tab group id');
console.assert(tabs.includes('Mac'), 'tab label');
console.assert(tabs.includes('Mac stuff'), 'tab content');

// Test inline :def
const def = md.render('Use :def[tokens]{Units of text for AI} wisely.');
console.assert(def.includes('class="def"'), 'def class');
console.assert(def.includes('tokens'), 'def term');
console.assert(def.includes('Units of text for AI'), 'def tooltip');

console.log('✓ All directive tests passed');
```

- [ ] **Step 2: Run it to verify it fails**

Run: `cd workshop-guide && node test-parse-directives.js`
Expected: Error — module not found

- [ ] **Step 3: Implement parse-directives.js**

The plugin has two parts:

**Part 1: Block-level rule** — a `core` ruler that runs after markdown-it tokenizes the document. It walks the token stream and:

1. Finds `paragraph_open`/`paragraph_close` token pairs where the inline content starts with `:::`.
2. Parses the directive type and arguments using these regexes:
   - `:::context\[(.+?)\]` → context block with title in capture group 1
   - `:::aside\[(.+?)\]` → aside block with title in capture group 1
   - `:::prompt` → prompt block (no title)
   - `:::tabs\{id="(.+?)"\}` → tab group with ID in capture group 1
   - `:::tab\[(.+?)\]` → tab panel with label in capture group 1
   - `:::endtabs` → close tab group
   - `:::` (bare) → close current block
3. Replaces matched tokens with `html_block` tokens containing the appropriate HTML. Uses a stack to track nesting depth (tabs contain other directives, and tabs can nest within tabs).
4. Content between an opening directive and its closing `:::` is collected as raw markdown, then rendered with `md.render()` recursively for the body content.

**Part 2: Inline rule** — an `inline` ruler that finds `:def[term]{explanation}` using the regex `:def\[([^\]]+)\]\{([^}]+)\}` and replaces the match with an `html_inline` token: `<span class="def" title="${explanation}">${term}<sup>?</sup></span>`.

**Function signature:**

```js
export function directivesPlugin(md) {
  md.core.ruler.push('directives', state => { /* block processing */ });
  md.inline.ruler.push('def', (state, silent) => { /* inline :def */ });
}
```

The key HTML output patterns:

**Context:**
```html
<div class="context-block">
  <div class="context-title">Title</div>
  <div class="context-body">...rendered markdown...</div>
</div>
```

**Aside:**
```html
<div class="aside-block collapsed">
  <div class="aside-header" onclick="this.parentElement.classList.toggle('collapsed')">
    <span class="aside-chevron">▸</span>
    <span class="aside-title">Title</span>
  </div>
  <div class="aside-body">...rendered markdown...</div>
</div>
```

**Prompt:**
```html
<div class="prompt-block">
  <button class="copy-btn" onclick="copyPrompt(this)">📋 copy</button>
  <pre>Text to copy</pre>
</div>
```

**Tabs:**
```html
<div class="tab-group" data-tab-group="os">
  <div class="tab-bar">
    <button class="tab-btn active" data-tab="Mac">Mac</button>
    <button class="tab-btn" data-tab="Windows">Windows</button>
  </div>
  <div class="tab-panel active" data-tab="Mac">...content...</div>
  <div class="tab-panel" data-tab="Windows">...content...</div>
</div>
```

**Def:**
```html
<span class="def" title="Units of text for AI">tokens<sup>?</sup></span>
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd workshop-guide && node test-parse-directives.js`
Expected: All assertions pass

- [ ] **Step 5: Test with real content**

Create a quick integration check:

```js
import { readContent } from './lib/read-content.js';
import MarkdownIt from 'markdown-it';
import { directivesPlugin } from './lib/parse-directives.js';

const md = new MarkdownIt({ html: true }).use(directivesPlugin);
const sections = readContent();
sections.forEach(s => {
  const html = md.render(s.body);
  console.log(`✓ ${s.filename}: ${html.length} chars HTML`);
});
```

Run: `cd workshop-guide && node test-integration.js`
Expected: All files render without errors, each producing non-trivial HTML output

- [ ] **Step 6: Commit**

```bash
git add workshop-guide/lib/parse-directives.js workshop-guide/test-parse-directives.js workshop-guide/test-integration.js
git commit -m "feat: add markdown-it directive plugin — context, aside, prompt, tabs, inline defs"
```

---

## Chunk 2: HTML template and build script

### Task 4: HTML template module

**Files:**
- Create: `workshop-guide/lib/template.js`

- [ ] **Step 1: Write template.js**

This module exports a function `renderPage(sections, renderedSections)` that returns a complete HTML string. It takes:
- `sections`: array of `{ title, id, time, order }` for sidebar generation
- `renderedSections`: array of `{ id, title, time, html }` for the content area

The template includes:
- Full `<!DOCTYPE html>` wrapper
- All CSS inlined in `<style>` — dark theme, sidebar, block types, responsive (laptop-only, no mobile)
- Sidebar HTML with section links, time estimates, progress bar
- Content area with all sections — each section starts with a label line (`T0 · 15 min`) above the heading, generated from the section's order and time frontmatter fields
- All JS inlined in `<script>` — scroll tracking, tab switching, aside toggle, copy button, tab persistence, smooth scroll

CSS specifications from the design spec:
- Sidebar: `#0d0d0d` background, 220px wide, fixed position
- Content: `#111` background, max-width 720px
- Context blocks: `#1c1710` bg, `#e6a030` border/title
- Aside blocks: `#0d1a1e` bg, `#2a4045` border, `#50b0b0` title
- Prompt blocks: `#1a1a2e` bg, `#2a2a40` border, monospace
- Tab bars: `#cc66cc` active accent
- Def tooltips: dotted underline, `?` superscript, native `title` attribute
- System font stack, 14px body

JS specifications:
- `IntersectionObserver` on each `<section>` to update sidebar active state
- `localStorage` for tab group persistence (key: `tab-{groupId}`, value: tab label)
- On page load, restore saved tab selections
- Tab click handler: update all tab groups with same ID, save to localStorage
- Aside click toggles `.collapsed` class
- Copy button: `navigator.clipboard.writeText()` with brief "✓ copied" feedback
- Smooth scroll: sidebar link clicks use `element.scrollIntoView({ behavior: 'smooth' })` with `scroll-behavior: smooth` on `html`

- [ ] **Step 2: Write a smoke test**

Create `workshop-guide/test-template.js`:

```js
import { renderPage } from './lib/template.js';

const sections = [
  { title: 'Start here', id: 'start', time: '5 min', order: 0 },
  { title: 'Install', id: 'install', time: '15 min', order: 1 },
];
const rendered = [
  { id: 'start', title: 'Start here', time: '5 min', html: '<p>Hello</p>' },
  { id: 'install', title: 'Install', time: '15 min', html: '<p>World</p>' },
];

const html = renderPage(sections, rendered);
console.assert(html.includes('<!DOCTYPE html>'), 'has doctype');
console.assert(html.includes('Start here'), 'sidebar has section');
console.assert(html.includes('15 min'), 'sidebar has time');
console.assert(html.includes('id="start"'), 'content has section id');
console.assert(html.includes('<p>Hello</p>'), 'content has rendered HTML');
console.assert(html.includes('IntersectionObserver'), 'has scroll tracking JS');
console.assert(html.includes('localStorage'), 'has tab persistence JS');
console.log(`✓ Template renders ${html.length} chars`);
```

Run: `cd workshop-guide && node test-template.js`
Expected: All assertions pass

- [ ] **Step 3: Commit**

```bash
git add workshop-guide/lib/template.js workshop-guide/test-template.js
git commit -m "feat: add HTML template — dark theme, sidebar, CSS, JS all inlined"
```

---

### Task 5: Build script

**Files:**
- Create: `workshop-guide/build.js`

- [ ] **Step 1: Write build.js**

```js
import fs from 'fs';
import path from 'path';
import MarkdownIt from 'markdown-it';
import { directivesPlugin } from './lib/parse-directives.js';
import { readContent } from './lib/read-content.js';
import { renderPage } from './lib/template.js';

const md = new MarkdownIt({ html: true, linkify: true }).use(directivesPlugin);

const sections = readContent();
const renderedSections = sections.map(s => ({
  id: s.id,
  title: s.title,
  time: s.time,
  html: md.render(s.body),
}));

const distDir = path.resolve(import.meta.dirname, 'dist');
fs.mkdirSync(distDir, { recursive: true });

const html = renderPage(sections, renderedSections);
fs.writeFileSync(path.join(distDir, 'index.html'), html);
console.log(`Built dist/index.html (${(html.length / 1024).toFixed(1)} KB)`);
```

- [ ] **Step 2: Run the build**

Run: `cd workshop-guide && node build.js`
Expected: `Built dist/index.html (X KB)` — file created successfully

- [ ] **Step 3: Open the output and verify visually**

Run: `open workshop-guide/dist/index.html`

Verify:
- Dark theme loads
- Sidebar shows all 6 sections with time estimates
- Scrolling highlights the correct section in the sidebar
- Context blocks have amber styling
- Aside blocks are collapsed, click to expand
- Prompt blocks have copy buttons that work
- Tabs switch correctly, nested tabs work
- Tab choice persists across sections (e.g., pick Mac once → Mac everywhere)

- [ ] **Step 4: Commit**

Add `workshop-guide/dist/` to `.gitignore` (generated artifact, rebuild on demand).

```bash
echo "workshop-guide/dist/" >> .gitignore
git add .gitignore workshop-guide/build.js
git commit -m "feat: add build script — produces self-contained index.html from content/*.md"
```

---

## Chunk 3: GDocs sync pipeline

### Task 6: GDocs sync script

**Files:**
- Create: `workshop-guide/sync-gdoc.js`

- [ ] **Step 1: Write sync-gdoc.js**

This script:
1. Reads all `content/*.md` files via `readContent()`
2. Strips `:::` directives, converting them to plain-text equivalents:
   - `:::context[Title]...:::` → blockquote with `**[Context: Title]**` prefix
   - `:::aside[Title]...:::` → blockquote with `**[ℹ️ Title]**` prefix
   - `:::prompt...:::` → fenced code block
   - `:::tabs{id="..."}`/`:::tab[Label]`/`:::endtabs` → `**🖥 Label**` headers with content below each
   - `:def[term]{explanation}` → `term (explanation)`
3. Concatenates all sections with `---` separators and section headings
4. Adds `gdoc` frontmatter (doc URL, tab) to the output file
5. Writes to a temp file and runs `gdoc push`

The Google Doc URL should be configurable — read from an env var `WORKSHOP_GDOC_URL` or a config in the markdown frontmatter.

- [ ] **Step 2: Test with a dry run**

Add a `--dry-run` flag that writes the transformed markdown to stdout instead of pushing:

Run: `cd workshop-guide && node sync-gdoc.js --dry-run`
Expected: Prints transformed markdown with all directives replaced by plain-text equivalents

- [ ] **Step 3: Commit**

```bash
git add workshop-guide/sync-gdoc.js
git commit -m "feat: add GDocs sync script — strips directives and pushes via gdoc CLI"
```

---

### Task 7: GDocs formatting script

**Files:**
- Create: `workshop-guide/format-gdoc.py`

- [ ] **Step 1: Write format-gdoc.py**

PEP 723 inline metadata script (runs with `uv run`):

```python
# /// script
# requires-python = ">=3.11"
# dependencies = ["google-api-python-client", "google-auth"]
# ///
```

The script reads the doc URL from the `WORKSHOP_GDOC_URL` env var (same as `sync-gdoc.js`). It:
1. Authenticates using the same credentials as `gdoc` CLI (reads from `~/.config/gdoc/` or `~/.config/gws/`)
2. Reads the Google Doc content via `docs.documents.get()`
3. Scans for marker text patterns:
   - `**[Context: ...]**` → apply amber background (`#FFF8E1`) to the paragraph range
   - `**[ℹ️ ...]**` → apply teal background (`#E0F2F1`)
   - Fenced code blocks (from prompts) → apply gray background (`#F5F5F5`) + monospace font
   - `**🖥 ...**` / `**🪟 ...**` tab headers → apply purple background (`#F0E8F0`)
4. Builds a list of `batchUpdate` requests (UpdateParagraphStyle, UpdateTextStyle)
5. Applies them all in one API call

- [ ] **Step 2: Test with a dry run**

Add a `--dry-run` flag that prints the formatting requests it would make instead of applying them:

Run: `cd workshop-guide && WORKSHOP_GDOC_URL="https://docs.google.com/document/d/1wmQ6FF69QjExQOTemE0kFMHqkHofh1cUCSP_aSq2anU/edit" uv run format-gdoc.py --dry-run`
Expected: Prints a list of formatting operations (paragraph ranges, colors). Requires the GDoc to have been synced first (Task 6). If no Google credentials are available, skip this task.

- [ ] **Step 3: Commit**

```bash
git add workshop-guide/format-gdoc.py
git commit -m "feat: add GDocs formatting script — applies colored backgrounds via Docs API"
```

---

## Chunk 4: Deploy skill and cleanup

### Task 8: Deploy workshop skill

**Files:**
- Create: `skills/deploy-workshop/SKILL.md`

- [ ] **Step 1: Write the skill file**

The skill instructs the agent to:
1. **Definition scan**: Read all `content/*.md` files. For each file, identify words/phrases that are technical jargon a non-technical nonprofit founder might not know. Check if they already have `:def[...]{...}` annotations. For any that don't, suggest an annotation with a <12 word explanation. Show the suggestions and apply after user confirms.
2. **Build webpage**: Run `cd workshop-guide && node build.js`. Report success/failure.
3. **Sync GDocs**: Run `cd workshop-guide && node sync-gdoc.js` then `cd workshop-guide && uv run format-gdoc.py`. Report success/failure.
4. **Report**: Summarize what was done — definitions added, build size, GDocs sync status.

The skill should have frontmatter:
```yaml
---
name: deploy-workshop
description: Build the workshop webpage, scan for missing jargon definitions, and sync to Google Docs with colored formatting
---
```

- [ ] **Step 2: Test the skill loads**

Start a new Claude Code session and type `/deploy-workshop` — verify it appears in the skill list and loads correctly.

- [ ] **Step 3: Commit**

```bash
git add skills/deploy-workshop/SKILL.md
git commit -m "feat: add /deploy-workshop skill — definition scan + build + GDocs sync"
```

---

### Task 9: Clean up test files

**Files:**
- Remove: `workshop-guide/test-read-content.js`
- Remove: `workshop-guide/test-parse-directives.js`
- Remove: `workshop-guide/test-integration.js`
- Remove: `workshop-guide/test-template.js`

- [ ] **Step 1: Remove test files**

These were verification scripts, not a test suite. Remove them to keep the directory clean.

Run: `cd workshop-guide && trash test-*.js`

- [ ] **Step 2: Final build and verify**

Run: `cd workshop-guide && node build.js && open dist/index.html`

Full checklist:
- [ ] Sidebar shows all sections with times
- [ ] Scroll tracking highlights current section
- [ ] Progress bar updates
- [ ] Context blocks: amber left border, warm background
- [ ] Aside blocks: collapsed by default, teal, expand on click
- [ ] Prompt blocks: monospace, copy button works
- [ ] Tabs: switch correctly, persist choice via localStorage
- [ ] Nested tabs: agent → OS nesting works
- [ ] Links work (internal anchors)
- [ ] All content from all content/*.md files renders

- [ ] **Step 3: Commit**

```bash
git add -A workshop-guide/
git commit -m "chore: remove test scripts, final build verification"
```

---

### Task 10: End-to-end GDocs sync test

- [ ] **Step 1: Run the full sync pipeline**

Run: `cd workshop-guide && node sync-gdoc.js`
Expected: Content pushed to the Google Doc

- [ ] **Step 2: Run the formatting script**

Run: `cd workshop-guide && uv run format-gdoc.py`
Expected: Colors applied — context blocks amber, asides teal, prompts gray, tab headers purple

- [ ] **Step 3: Verify in browser**

Open the Google Doc and check:
- Context blocks have amber/cream backgrounds
- Aside blocks have teal backgrounds
- Prompt blocks have gray backgrounds with monospace text
- Tab sections have purple headers
- Defined terms show explanation in parentheses
- Section structure and headings are correct

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "feat: complete workshop webpage and GDocs sync pipeline"
```
