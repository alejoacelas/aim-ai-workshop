# Workshop webpage and GDocs sync

Build a static webpage for the "Coding agents 101" workshop guide, generated from annotated markdown files. Also sync the content to Google Docs with colored formatting.

## Ground truth

The `content/*.md` files are the single source of truth. Each file represents one section of the guide, with YAML frontmatter (`title`, `id`, `time`, `order`) and custom `:::` directives for block types.

The build system reads these files and produces two outputs:
1. A single self-contained `index.html` — the webpage
2. A formatted Google Doc — via `gdoc push` followed by a formatting script

## Markdown annotation format

The `content/*.md` files use these directives:

```markdown
:::context[Title text]
Motivation, framing, "why this matters" content.
:::

:::aside[Title text]
Collapsible extra info, troubleshooting, tangents.
:::

:::prompt
Text the participant should copy-paste into their agent.
:::

:::tabs{id="agent"}
:::tab[Claude Code]
Claude-specific content...
:::
:::tab[Codex]
Codex-specific content...
:::
:::endtabs

Inline: Agents burn through :def[tokens]{A unit of text (~4 characters) that AI models process. More tokens = more cost.} fast.
```

YAML frontmatter per file:

```yaml
---
title: "T0: Install your AI agent"
id: "install"
time: "15 min"
order: 1
---
```

## Webpage design

### Page structure

Single long page with sticky sidebar navigation. All sections rendered on one scrollable page.

### Sidebar (fixed, left, ~220px)

- Workshop title at top
- Total time estimate
- List of all sections, each showing title + time estimate
- Current section highlighted (amber accent, based on scroll position)
- Progress bar at bottom

### Content area (max-width ~720px, centered)

- Each section starts with a label line (`T0 · 15 min`) and heading
- Sections separated by horizontal rules
- 14px body text, system font stack, dark theme

### Block type rendering

**`:::context[title]`** — amber/orange
- Background: `#1c1710`
- Left border: 3px solid `#e6a030`
- Title in amber (`#e6a030`), bold
- Body text in light gray
- Always visible (not collapsible)

**`:::aside[title]`** — teal
- Background: `#0d1a1e`
- Border: 1px solid `#2a4045`
- Title in teal (`#50b0b0`)
- **Collapsed by default** — click to expand
- Chevron indicator (▸ collapsed, ▾ expanded)

**`:::prompt`** — monospace code block
- Background: `#1a1a2e`
- Border: 1px solid `#2a2a40`
- Monospace font, 13px
- Copy-to-clipboard button (📋) in top-right corner

**`:::tabs{id="..."}`** — tabbed content switcher
- Tab bar with active tab highlighted (purple accent `#cc66cc`)
- Active tab has bottom border
- Inactive tabs in gray
- **Tab persistence**: choosing a tab carries across all tab groups with the same `id` (e.g., choosing "Mac" in one section selects "Mac" everywhere)
- Nested tabs supported (e.g., agent choice → OS choice within)

**`:def[term]{explanation}`** — inline jargon tooltip
- Dotted underline on the term, with a small `?` indicator
- Hover reveals a tooltip with the explanation (max ~12 words)
- On the webpage: `<span class="def" title="...">term<sup>?</sup></span>` with CSS dotted underline
- In GDocs: rendered as "term*" with a footnote-style explanation, or just the term with the explanation in parentheses

**Time estimates** — from frontmatter `time` field (no `:::time` directive needed)
- Displayed in sidebar next to section title
- Displayed as label above section heading in content area

### Theme

- Dark background: `#0d0d0d` (sidebar), `#111` (content area)
- Text: `#fff` headings, `#bbb` body, `#888` secondary
- Accent: amber `#e6a030` (primary), teal `#50b0b0` (asides), purple `#cc66cc` (tabs), blue-gray `#8888ee` (prompts)
- Border color: `#222` (dividers), `#333` (component borders)
- Border radius: 8px for blocks, 6px for inner elements

### Interactivity (vanilla JS, no framework)

- Sidebar scroll tracking (IntersectionObserver)
- Tab switching with localStorage persistence
- Aside collapse/expand toggle
- Copy-to-clipboard on prompt blocks
- Smooth scroll on sidebar link click

## GDocs sync

### Push flow

1. A build script strips `:::` directives from the markdown, converting them to plain-text markers (e.g., context blocks become blockquotes with a title prefix)
2. `gdoc push` uploads the content
3. A Python formatting script uses the Google Docs API `batchUpdate` to apply colors:
   - Context blocks: amber background (`#FFF8E1`), amber left border
   - Aside blocks: teal background (`#E0F2F1`), teal left border
   - Prompt blocks: light gray background (`#F5F5F5`), monospace font
   - Tab sections: labeled with colored headers

### GDocs color mapping

| Block type | Background | Left border | Title color |
|-----------|-----------|-------------|-------------|
| `:::context` | `#FFF8E1` (warm cream) | `#E6A030` (amber) | `#8A6000` (dark amber) |
| `:::aside` | `#E0F2F1` (light teal) | `#50B0B0` (teal) | `#2A6060` (dark teal) |
| `:::prompt` | `#F5F5F5` (light gray) | none | n/a (monospace) |
| `:::tabs` | Sections shown sequentially with colored headers (`#F0E8F0`) | none | `#8A4A8A` (purple) |

### Tab handling in GDocs

Since GDocs doesn't support interactive tabs, all tab options are shown sequentially with labeled headers (e.g., "🖥 Mac", "🪟 Windows"). Each option is a distinct section.

## Build system

### Directory structure

```
workshop-guide/           # new folder for the webpage project
├── build.js              # Node.js build script
├── sync-gdoc.js          # GDocs sync script (strips directives + pushes)
├── format-gdoc.py        # Python script for Docs API color formatting
├── package.json          # markdown-it dependency
└── dist/
    └── index.html        # generated output (self-contained)
```

The `content/*.md` source files stay where they are in the repo root.

### Build script (`build.js`)

- Uses `markdown-it` with a custom plugin to parse `:::` directives
- Reads all `content/*.md` files, sorts by `order` field
- Parses YAML frontmatter for metadata
- Renders each section's markdown to HTML with the custom block types
- Wraps everything in a single HTML page with inlined CSS and JS
- Outputs `dist/index.html`

### GDocs sync (`sync-gdoc.js` + `format-gdoc.py`)

- `sync-gdoc.js`: transforms `content/*.md` into a single markdown file suitable for `gdoc push`, with markers for the formatting script to find
- `format-gdoc.py`: reads the Google Doc via API, finds the markers, applies paragraph background colors and text styles via `batchUpdate`

### Dependencies

- `markdown-it` (npm) — markdown parsing
- `gray-matter` (npm) — YAML frontmatter parsing
- `google-api-python-client`, `google-auth` (Python, via uv) — Docs API formatting

## Deploy skill

A single local skill (`/deploy-workshop`) that handles the full publish pipeline: definition scan, webpage build, and GDocs sync. Lives at `skills/deploy-workshop/SKILL.md`.

Steps the skill runs in order:

1. **Definition scan** — read all `content/*.md` files, identify jargon terms a non-technical reader might not know (e.g., "tokens", "terminal", "markdown", "CLI", "API", "repo"), check which already have `:def[...]{}` annotations, suggest annotations with short (<12 word) explanations for any that don't, apply after user confirmation
2. **Build webpage** — run `node workshop-guide/build.js` to produce `dist/index.html`
3. **Sync GDocs** — run `node workshop-guide/sync-gdoc.js` to push content, then `uv run workshop-guide/format-gdoc.py` to apply colored formatting via Docs API
4. **Report** — summarize what changed (new definitions added, sections updated, build status)

## Writing quality

When filling in `[bracketed notes]` or incomplete sections from the GDoc, match the existing voice: concise, informal, direct. No jargon. Respect the reader's intelligence. See the best examples in `content/01-install.md` and `content/02-clean-downloads.md` for tone.
