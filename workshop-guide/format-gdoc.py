#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["google-api-python-client", "google-auth"]
# ///

"""
Apply colored formatting to the workshop Google Doc.

Reads the doc via the Docs API, finds text markers left by sync-gdoc.js,
and applies background colors and text styles via batchUpdate.

Usage:
  uv run format-gdoc.py              # apply formatting
  uv run format-gdoc.py --dry-run    # print what would be done

Requires WORKSHOP_GDOC_URL env var.
"""

import os
import sys
import re
from pathlib import Path


def get_doc_id(url):
    """Extract Google Doc ID from URL."""
    m = re.search(r'/d/([a-zA-Z0-9_-]+)', url)
    if not m:
        raise ValueError(f"Could not extract doc ID from: {url}")
    return m.group(1)


def find_credentials():
    """Find Google OAuth credentials, checking common locations."""
    for config_dir in [
        Path.home() / '.config' / 'gws',
        Path.home() / '.config' / 'gdoc',
    ]:
        token_path = config_dir / 'token.json'
        if token_path.exists():
            return str(config_dir)
    return None


def build_service(config_dir):
    """Build Google Docs API service using stored credentials."""
    from google.oauth2.credentials import Credentials
    from googleapiclient.discovery import build

    token_path = Path(config_dir) / 'token.json'
    creds = Credentials.from_authorized_user_file(str(token_path))
    return build('docs', 'v1', credentials=creds)


def find_marker_ranges(content, marker_pattern):
    """Find text ranges matching a marker pattern in the doc body."""
    ranges = []
    body = content.get('body', {})

    for element in body.get('content', []):
        para = element.get('paragraph', {})
        for pe in para.get('elements', []):
            text_run = pe.get('textRun', {})
            text = text_run.get('content', '')
            if marker_pattern.search(text):
                start = pe.get('startIndex', 0)
                end = pe.get('endIndex', start)
                ranges.append((start, end, text.strip()))

    return ranges


def find_block_ranges(doc, start_pattern, end_indicators):
    """
    Find ranges of blocks that start with a marker line and extend
    until one of the end indicators is found or a new section starts.

    Returns list of (start_index, end_index, marker_text) tuples.
    """
    blocks = []
    body = doc.get('body', {})
    elements = body.get('content', [])

    in_block = False
    block_start = None
    marker_text = None

    for element in elements:
        para = element.get('paragraph', {})
        full_text = ''
        for pe in para.get('elements', []):
            full_text += pe.get('textRun', {}).get('content', '')
        full_text = full_text.strip()

        if not in_block and start_pattern.search(full_text):
            in_block = True
            block_start = element.get('startIndex', 0)
            marker_text = full_text
            continue

        if in_block:
            is_end = False
            for end_ind in end_indicators:
                if isinstance(end_ind, str) and full_text.startswith(end_ind):
                    is_end = True
                elif isinstance(end_ind, re.Pattern) and end_ind.search(full_text):
                    is_end = True

            # Also end at new section headings
            style = para.get('paragraphStyle', {}).get('namedStyleType', '')
            if style in ('HEADING_1', 'HEADING_2') and not start_pattern.search(full_text):
                is_end = True

            if is_end:
                block_end = element.get('startIndex', block_start)
                if block_end > block_start:
                    blocks.append((block_start, block_end, marker_text))
                in_block = False
                # Check if this line starts a new block
                if start_pattern.search(full_text):
                    in_block = True
                    block_start = element.get('startIndex', 0)
                    marker_text = full_text

    # Close final open block
    if in_block and block_start is not None and elements:
        block_end = elements[-1].get('endIndex', block_start)
        blocks.append((block_start, block_end, marker_text))

    return blocks


def rgb(hex_color):
    """Convert hex color to Google Docs RGB dict."""
    h = hex_color.lstrip('#')
    return {
        'red': int(h[0:2], 16) / 255,
        'green': int(h[2:4], 16) / 255,
        'blue': int(h[4:6], 16) / 255,
    }


def make_bg_request(start, end, bg_color):
    """Create a paragraph background color request."""
    return {
        'updateParagraphStyle': {
            'range': {'startIndex': start, 'endIndex': end},
            'paragraphStyle': {
                'shading': {
                    'backgroundColor': {'color': {'rgbColor': rgb(bg_color)}}
                }
            },
            'fields': 'shading.backgroundColor',
        }
    }


def make_text_color_request(start, end, color):
    """Create a text foreground color request."""
    return {
        'updateTextStyle': {
            'range': {'startIndex': start, 'endIndex': end},
            'textStyle': {
                'foregroundColor': {'color': {'rgbColor': rgb(color)}}
            },
            'fields': 'foregroundColor',
        }
    }


def make_font_request(start, end, font_family):
    """Create a font family request."""
    return {
        'updateTextStyle': {
            'range': {'startIndex': start, 'endIndex': end},
            'textStyle': {
                'weightedFontFamily': {
                    'fontFamily': font_family,
                }
            },
            'fields': 'weightedFontFamily',
        }
    }


def collect_requests(doc, dry_run=False):
    """
    Inspect the document and build a list of batchUpdate requests.

    Color scheme:
      Context blocks  bg #FFF8E1, title color #8A6000
      Aside blocks    bg #E0F2F1, title color #2A6060
      Code blocks     bg #F5F5F5, Courier New font
      Tab headers     bg #F0E8F0, title color #8A4A8A
    """
    requests = []

    # Context blocks: > **[Context: ...]**
    context_pattern = re.compile(r'\*\*\[Context:.*?\]\*\*')
    context_ranges = find_block_ranges(doc, context_pattern,
                                       [re.compile(r'^> \*\*\['), '---', '```'])
    for start, end, text in context_ranges:
        requests.append(make_bg_request(start, end, '#FFF8E1'))
        if dry_run:
            print(f"  Context block ({start}-{end}): {text[:60]}")

    # Aside blocks: > **[ℹ️ ...]**
    aside_pattern = re.compile(r'\*\*\[ℹ️.*?\]\*\*')
    aside_ranges = find_block_ranges(doc, aside_pattern,
                                     [re.compile(r'^> \*\*\['), '---', '```'])
    for start, end, text in aside_ranges:
        requests.append(make_bg_request(start, end, '#E0F2F1'))
        if dry_run:
            print(f"  Aside block ({start}-{end}): {text[:60]}")

    # Code blocks: between ``` markers
    body = doc.get('body', {})
    in_code = False
    code_start = None
    for element in body.get('content', []):
        para = element.get('paragraph', {})
        full_text = ''
        for pe in para.get('elements', []):
            full_text += pe.get('textRun', {}).get('content', '')
        if full_text.strip() == '```':
            if not in_code:
                in_code = True
                code_start = element.get('startIndex', 0)
            else:
                code_end = element.get('endIndex', code_start)
                requests.append(make_bg_request(code_start, code_end, '#F5F5F5'))
                requests.append(make_font_request(code_start, code_end, 'Courier New'))
                if dry_run:
                    print(f"  Code block ({code_start}-{code_end})")
                in_code = False

    # Tab headers: **🖥 ...** or **🪟 ...**
    tab_pattern = re.compile(r'\*\*(🖥|🪟)\s+.*?\*\*')
    tab_ranges = find_marker_ranges(doc, tab_pattern)
    for start, end, text in tab_ranges:
        requests.append(make_bg_request(start, end, '#F0E8F0'))
        requests.append(make_text_color_request(start, end, '#8A4A8A'))
        if dry_run:
            print(f"  Tab header ({start}-{end}): {text[:60]}")

    return requests


def main():
    dry_run = '--dry-run' in sys.argv

    gdoc_url = os.environ.get('WORKSHOP_GDOC_URL')
    if not gdoc_url:
        print("Error: WORKSHOP_GDOC_URL env var is required", file=sys.stderr)
        sys.exit(1)

    doc_id = get_doc_id(gdoc_url)

    if dry_run:
        print(f"Would format Google Doc: {doc_id}")

    config_dir = find_credentials()
    if not config_dir:
        if dry_run:
            print("(Dry run — no credentials found; skipping API call)")
            return
        print("Error: No Google credentials found. Run gws auth login first.", file=sys.stderr)
        sys.exit(1)

    service = build_service(config_dir)
    doc = service.documents().get(documentId=doc_id).execute()

    if dry_run:
        print("Scanning document for formatting markers...")

    requests = collect_requests(doc, dry_run=dry_run)

    if dry_run:
        print(f"\nTotal formatting requests: {len(requests)}")
        return

    if requests:
        service.documents().batchUpdate(
            documentId=doc_id,
            body={'requests': requests}
        ).execute()
        print(f"Applied {len(requests)} formatting changes to Google Doc")
    else:
        print("No formatting markers found in the document")


if __name__ == '__main__':
    main()
