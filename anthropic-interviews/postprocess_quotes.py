# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
Post-process reports to extract quotes and find their locations in transcripts.
Writes viewer/quotes.json with {report, transcript_id, quote, start, end} entries.
"""

import json
import re
import difflib
from pathlib import Path

BASE = Path(__file__).parent
REPORTS_DIR = BASE / "reports"
VIEWER_DIR = BASE / "viewer"

REPORT_FILES = {
    "coding": "coding-agents-for-nonprogrammers.md",
    "time": "time-saving-patterns.md",
    "delegation": "delegation-vs-collaboration.md",
}

def extract_quotes(md_text, report_key):
    """Extract quotes from markdown blockquotes in format:
    > "quote text"
    > — transcript_id
    """
    quotes = []
    # Match blockquote patterns - could be multi-line
    # Pattern: one or more > "..." lines followed by > — id
    lines = md_text.split("\n")
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        # Look for blockquote lines starting a quote
        if line.startswith(">") and ('"' in line or "\u201c" in line):
            quote_lines = []
            tid = None
            # Collect quote lines
            while i < len(lines):
                l = lines[i].strip()
                if not l.startswith(">"):
                    break
                content = l.lstrip(">").strip()
                # Check if this is the attribution line
                attr_match = re.match(r'[—\-–]+\s*(work_\d+|crea_\d+|sci_\d+)', content)
                if attr_match:
                    tid = attr_match.group(1)
                    i += 1
                    break
                quote_lines.append(content)
                i += 1

            if tid and quote_lines:
                # Join and clean quote text
                raw_quote = " ".join(quote_lines)
                # Remove surrounding quotes (straight or curly)
                raw_quote = re.sub(r'^[\u201c"]+|[\u201d"]+$', '', raw_quote).strip()
                quotes.append({
                    "report": report_key,
                    "transcript_id": tid,
                    "quote": raw_quote,
                })
        else:
            i += 1
    return quotes


def find_quote_in_transcript(quote, transcript):
    """Find the best match for a quote in a transcript. Returns (start, end) or None."""
    # Try exact match first
    idx = transcript.find(quote)
    if idx != -1:
        return (idx, idx + len(quote))

    # Try with normalized whitespace
    norm_quote = " ".join(quote.split())
    norm_transcript = " ".join(transcript.split())
    idx = norm_transcript.find(norm_quote)
    if idx != -1:
        # Map back to original positions (approximate)
        idx_orig = transcript.find(norm_quote[:40])
        if idx_orig != -1:
            # Find the end by searching for the last chunk
            end_chunk = norm_quote[-40:]
            end_idx = transcript.find(end_chunk, idx_orig)
            if end_idx != -1:
                return (idx_orig, end_idx + len(end_chunk))

    # Try progressively shorter prefixes for partial match
    for trim in [0, 10, 20, 40, 60]:
        search = quote[trim:] if trim else quote
        if len(search) < 30:
            break
        # Try finding a 50-char window
        window = search[:50]
        idx = transcript.find(window)
        if idx != -1:
            # Found start, now find end
            end_window = search[-50:] if len(search) > 50 else search
            end_idx = transcript.find(end_window, idx)
            if end_idx != -1:
                return (idx - trim if trim == 0 else idx, end_idx + len(end_window))
            return (idx, idx + len(search))

    # Fuzzy matching as last resort - find best matching window
    if len(quote) < 20:
        return None

    best_ratio = 0
    best_pos = None
    window_size = len(quote)
    step = max(1, window_size // 4)

    # Search with sliding window
    for start in range(0, len(transcript) - min(window_size, len(transcript)), step):
        end = min(start + window_size + 50, len(transcript))
        window = transcript[start:end]
        ratio = difflib.SequenceMatcher(None, quote[:100], window[:100]).ratio()
        if ratio > best_ratio:
            best_ratio = ratio
            best_pos = start

    if best_ratio > 0.6 and best_pos is not None:
        # Refine the match
        end = min(best_pos + window_size + 20, len(transcript))
        return (best_pos, end)

    return None


def main():
    # Load transcripts
    with open(VIEWER_DIR / "transcripts.json") as f:
        transcripts = json.load(f)

    all_quotes = []
    unresolved = []

    for report_key, filename in REPORT_FILES.items():
        report_path = REPORTS_DIR / filename
        if not report_path.exists():
            print(f"  SKIP {filename} (not found)")
            continue

        md_text = report_path.read_text()
        quotes = extract_quotes(md_text, report_key)
        print(f"  {filename}: {len(quotes)} quotes extracted")

        resolved = 0
        for q in quotes:
            tid = q["transcript_id"]
            if tid not in transcripts:
                unresolved.append(q)
                continue

            result = find_quote_in_transcript(q["quote"], transcripts[tid])
            if result:
                q["start"] = result[0]
                q["end"] = result[1]
                all_quotes.append(q)
                resolved += 1
            else:
                unresolved.append(q)

        print(f"    Resolved: {resolved}/{len(quotes)}")

    # Write quotes.json
    with open(VIEWER_DIR / "quotes.json", "w") as f:
        json.dump(all_quotes, f, indent=2)

    print(f"\nTotal quotes resolved: {len(all_quotes)}")
    if unresolved:
        print(f"Unresolved quotes: {len(unresolved)}")
        for q in unresolved:
            print(f"  [{q['report']}] {q['transcript_id']}: {q['quote'][:60]}...")

    return len(unresolved)


if __name__ == "__main__":
    main()
