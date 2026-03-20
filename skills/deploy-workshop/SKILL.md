---
name: deploy-workshop
description: Build the workshop webpage, scan for missing jargon definitions, and sync to Google Docs with colored formatting
---

# Deploy workshop guide

Run the full publish pipeline: definition scan, webpage build, and GDocs sync.

## Step 1: Definition scan

Read all `content/*.md` files. For each file:

1. Identify words or phrases that are technical jargon a non-technical nonprofit founder might not know. Examples: "tokens", "terminal", "CLI", "API", "repo", "markdown", "agent context", "prompt", "OAuth", "webhook", "deploy", "localhost", "dependencies", "environment variable".
2. Check which already have `:def[...]{}` annotations.
3. For any jargon that doesn't have a definition yet, suggest an annotation with a short (<12 word) explanation. Format: `:def[term]{Brief explanation here}`
4. Show the suggestions grouped by file and ask for confirmation before applying.
5. Apply confirmed definitions by editing the content files.

**Guidelines for definitions:**
- Only annotate the FIRST occurrence of each term across all files
- Keep explanations under 12 words, plain language
- Don't define terms that are explained in the surrounding text
- Don't over-annotate — if a term is used dozens of times, just define it once
- Example: `:def[tokens]{Units of text (~4 characters) that AI models process}`

## Step 2: Build webpage

Run the build script:

```bash
cd workshop-guide && node build.js
```

Report the output file size. If the build fails, show the error and stop.

## Step 3: Sync to Google Docs

Run the sync pipeline:

```bash
cd workshop-guide && node sync-gdoc.js
```

Then apply formatting:

```bash
cd workshop-guide && uv run format-gdoc.py
```

If `WORKSHOP_GDOC_URL` is not set, skip this step and note it in the report.

## Step 4: Report

Summarize what was done:
- Number of new definitions added (and which terms)
- Build output size
- GDocs sync status (pushed + formatted, or skipped)
- Any warnings or issues encountered
