---
name: fix-ebooks
description: >
  Fixes common problems in EPUB files downloaded from the internet — use this skill
  whenever the user mentions an EPUB, ebook, or .epub file that has reading problems,
  formatting issues, broken layout, weird spacing, words cut across lines, garbled
  characters, dark-mode issues, or just "looks bad" in their reader. Also trigger when
  the user says they downloaded a book and something is off, or asks how to clean up or
  repair an ebook. A single command diagnoses the file, reports what it found, and fixes
  everything automatically. Optionally accepts --deep to use Claude AI for deeper HTML
  cleanup of web-scraped or heavily formatted files.
---

# fix-ebooks

Fix common problems in downloaded EPUB files with a single command. The skill
diagnoses the EPUB, shows the user what it found, then applies all safe fixes
automatically.

## Workflow

1. **Find the file.** If the user did not give a path, search `~/Downloads` and
   `~/Desktop` for `.epub` files. Pick the most recently modified one as a smart
   default — tell the user which you chose and why so they can redirect if needed.

2. **Run the fixer script.**
   ```bash
   python3 <skill_dir>/scripts/fix_epub.py "<input.epub>" [--deep]
   ```
   `<skill_dir>` is the directory containing this SKILL.md file.

3. **Show the diagnosis report** the script prints (fingerprint + issues found).

4. **Confirm the output file path** and offer to run `epubcheck <output>` if available.

---

## What the script fixes (always applied when detected)

| Fix | What it corrects |
|-----|-----------------|
| Line fragmentation | Merges mid-sentence `<p>` breaks into real paragraphs — runs whenever fragmentation is detected, regardless of source fingerprint |
| Hyphenated line breaks | word- + next line -> merged word |
| Double/triple spaces | Collapsed to single space |
| Ligature characters | fi, fl, ff, ffi, ffl unicode ligatures expanded |
| Encoding / mojibake | Garbled smart quotes and dashes -> correct Unicode |
| Embedded page numbers | Isolated numeric `<p>` elements removed |
| Running headers | Short phrases repeated 3+ times (PDF header echoes) removed |
| Hardcoded CSS colors | Both `<style>` blocks and inline `style=` attributes stripped for dark mode |
| mimetype integrity | Ensures `mimetype` is first in zip and stored uncompressed |

## Deep mode (--deep)

Sends each chapter through `claude-haiku-4-5-20251001` to rewrite spaghetti markup
(inline styles, nested divs, font tags) into clean semantic HTML while preserving all
text. Most useful for web-scraped EPUBs or Word/Docs exports. The script proactively
suggests this flag when it detects heavy formatting (50+ HTML files).

## Source fingerprints

- **PDF rip** -- pdftohtml or similar generator meta tag
- **Calibre conversion** -- Calibre generator meta tag
- **Word/Docs export** -- mso- CSS or o:p tags
- **Web scrape** -- many inline-style divs
- **Unknown origin (fragmentation pattern)** -- no generator tag but heavy fragmentation

## Dependencies

- Python 3 + beautifulsoup4: `pip3 install beautifulsoup4 -q`
- anthropic SDK (only for --deep): `pip3 install anthropic -q`
- epubcheck (optional, for post-fix validation)
