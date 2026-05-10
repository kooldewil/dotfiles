#!/usr/bin/env python3
"""
fix_epub.py — diagnose and repair common EPUB problems.

Usage:
    python3 fix_epub.py <input.epub> [--deep]

Output: <name> (fixed).epub next to the input file.
"""

import os
import re
import sys
import shutil
import zipfile
import argparse
import tempfile
from collections import Counter
from pathlib import Path

try:
    from bs4 import BeautifulSoup, NavigableString
except ImportError:
    print("beautifulsoup4 is required. Install with: pip3 install beautifulsoup4 -q", file=sys.stderr)
    sys.exit(1)

HTML_EXTS = {'.html', '.xhtml', '.htm'}

LIGATURES = {
    'ﬀ': 'ff', 'ﬁ': 'fi', 'ﬂ': 'fl',
    'ﬃ': 'ffi', 'ﬄ': 'ffl', 'ﬅ': 'st', 'ﬆ': 'st',
}
LIGATURE_RE = re.compile('[' + ''.join(LIGATURES.keys()) + ']')

MOJIBAKE = [
    ('â\x80\x99', '’'),
    ('â\x80\x9c', '“'),
    ('â\x80\x9d', '”'),
    ('â\x80\x93', '–'),
    ('â\x80\x94', '—'),
    ('â\x80\xa6', '…'),
]

SENTENCE_END_RE = re.compile(r'[.!?”’\']\s*$')


def detect_fingerprint(soups):
    flags = {'pdf_rip': False, 'calibre': False, 'word_export': False, 'web_scrape': False}
    for soup in soups:
        gen = soup.find('meta', attrs={'name': 'generator'})
        if gen:
            c = (gen.get('content') or '').lower()
            if any(k in c for k in ('pdftohtml', 'pdf2html', 'pdf')):
                flags['pdf_rip'] = True
            if 'calibre' in c:
                flags['calibre'] = True
            if any(k in c for k in ('microsoft word', 'libreoffice')):
                flags['word_export'] = True
        if soup.find(style=re.compile(r'mso-')):
            flags['word_export'] = True
        if len(soup.find_all('div', style=True)) > 20:
            flags['web_scrape'] = True
    return flags


def audit_issues(soups):
    issues = {}
    for soup in soups:
        paras = soup.find_all('p')

        frag = sum(1 for p in paras
                   if p.get_text().rstrip()
                   and not SENTENCE_END_RE.search(p.get_text().rstrip()))
        if frag:
            issues['PDF/web line fragmentation'] = issues.get('PDF/web line fragmentation', 0) + frag

        hyph = sum(1 for p in paras if p.get_text().rstrip().endswith('-'))
        if hyph:
            issues['Hyphenated line breaks'] = issues.get('Hyphenated line breaks', 0) + hyph

        ds = sum(1 for p in paras if '  ' in p.get_text())
        if ds:
            issues['Double spaces'] = issues.get('Double spaces', 0) + ds

        ligs = sum(len(LIGATURE_RE.findall(p.get_text())) for p in paras)
        if ligs:
            issues['Ligature characters'] = issues.get('Ligature characters', 0) + ligs

        pnums = sum(1 for p in paras if re.fullmatch(r'\s*\d{1,4}\s*', p.get_text()))
        if pnums:
            issues['Embedded page numbers'] = issues.get('Embedded page numbers', 0) + pnums

        consecutive_brs = sum(
            1 for br in soup.find_all('br')
            if br.find_next_sibling() and br.find_next_sibling().name == 'br'
        )
        if consecutive_brs:
            issues['Excess blank lines'] = issues.get('Excess blank lines', 0) + consecutive_brs

        # Check <style> blocks AND inline style= attributes for hardcoded colors
        if issues.get('Hardcoded CSS colors') is not True:
            for tag in soup.find_all('style'):
                if re.search(r'\b(?:background-?color|color)\s*:', tag.string or ''):
                    issues['Hardcoded CSS colors'] = True
                    break
        if issues.get('Hardcoded CSS colors') is not True:
            for tag in soup.find_all(style=True):
                if re.search(r'\b(?:background-?color|color)\s*:', tag.get('style', '')):
                    issues['Hardcoded CSS colors'] = True
                    break

    return list(issues.items())


def fix_text(text):
    for bad, good in MOJIBAKE:
        text = text.replace(bad, good)
    text = LIGATURE_RE.sub(lambda m: LIGATURES[m.group()], text)
    return re.sub(r'  +', ' ', text)


def ends_sentence(text):
    t = text.rstrip()
    return not t or bool(SENTENCE_END_RE.search(t))


def merge_fragmented_paragraphs(soup):
    """Merge mid-sentence <p> lines back into proper paragraphs."""
    count = 0
    changed = True
    while changed:
        changed = False
        paras = soup.find_all('p')
        for i, p in enumerate(paras[:-1]):
            s = p.get_text().rstrip()
            if not s:
                continue
            if s.endswith('-'):
                nxt = paras[i + 1]
                merged = s[:-1] + nxt.get_text().lstrip()
                p.clear()
                p.append(NavigableString(merged))
                nxt.decompose()
                count += 1
                changed = True
                break
            if not ends_sentence(s):
                nxt = paras[i + 1]
                merged = s + ' ' + nxt.get_text().lstrip()
                p.clear()
                p.append(NavigableString(merged))
                nxt.decompose()
                count += 1
                changed = True
                break
    return count


def remove_page_numbers(soup):
    removed = 0
    for p in soup.find_all('p'):
        if re.fullmatch(r'\s*\d{1,4}\s*', p.get_text()):
            p.decompose()
            removed += 1
    return removed


def remove_running_headers(soup, threshold=3):
    paras = soup.find_all('p')
    texts = [p.get_text().strip() for p in paras]
    counts = Counter(t for t in texts if 0 < len(t) < 80)
    headers = {t for t, c in counts.items() if c >= threshold}
    removed = 0
    for p in soup.find_all('p'):
        if p.get_text().strip() in headers:
            p.decompose()
            removed += 1
    return removed


def fix_excess_br_spacing(soup):
    """Collapse runs of 2+ consecutive <br> tags down to one."""
    removed = 0
    changed = True
    while changed:
        changed = False
        for br in soup.find_all('br'):
            nxt = br.find_next_sibling()
            if nxt and nxt.name == 'br':
                nxt.decompose()
                removed += 1
                changed = True
                break
    return removed


def fix_css_colors(soup):
    fixed = 0
    for tag in soup.find_all('style'):
        orig = tag.string or ''
        cleaned = re.sub(r'\bcolor\s*:[^;}\n]+[;]?', '', orig)
        cleaned = re.sub(r'\bbackground(?:-color)?\s*:[^;}\n]+[;]?', '', cleaned)
        if cleaned != orig:
            tag.string = cleaned
            fixed += 1
    for tag in soup.find_all(style=True):
        orig = tag['style']
        cleaned = re.sub(r'\bcolor\s*:[^;]+;?', '', orig)
        cleaned = re.sub(r'\bbackground(?:-color)?\s*:[^;]+;?', '', cleaned).strip().rstrip(';')
        if cleaned != orig:
            if cleaned:
                tag['style'] = cleaned
            else:
                del tag['style']
            fixed += 1
    return fixed


def apply_text_fixes(soup):
    for node in soup.find_all(string=True):
        fixed = fix_text(str(node))
        if fixed != str(node):
            node.replace_with(NavigableString(fixed))


def process_html(content, issue_names):
    soup = BeautifulSoup(content, 'html.parser')
    if not soup.find('body'):
        return content
    # Run fragmentation fix whenever detected — not gated on fingerprint
    if 'PDF/web line fragmentation' in issue_names:
        merge_fragmented_paragraphs(soup)
        remove_page_numbers(soup)
        remove_running_headers(soup)
    if 'Excess blank lines' in issue_names:
        fix_excess_br_spacing(soup)
    if 'Hardcoded CSS colors' in issue_names:
        fix_css_colors(soup)
    apply_text_fixes(soup)
    return str(soup)


DEEP_SYSTEM = (
    "You are an ebook formatter. Clean up HTML while preserving ALL text exactly. "
    "Remove inline styles, replace layout divs with semantic elements, remove font tags "
    "(keep their text). Output only body content. No class attributes unless already meaningful."
)


def deep_clean(html_body):
    try:
        import anthropic
    except ImportError:
        print("pip3 install anthropic -q", file=sys.stderr)
        return html_body
    client = anthropic.Anthropic()
    msg = client.messages.create(
        model='claude-haiku-4-5-20251001',
        max_tokens=8192,
        system=DEEP_SYSTEM,
        messages=[{'role': 'user', 'content': html_body}],
    )
    return msg.content[0].text


def repack_epub(work_dir, output_path):
    if os.path.exists(output_path):
        os.remove(output_path)
    mp = os.path.join(work_dir, 'mimetype')
    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_STORED) as z:
        if os.path.exists(mp):
            z.write(mp, 'mimetype')
    with zipfile.ZipFile(output_path, 'a', zipfile.ZIP_DEFLATED) as z:
        for root, _, files in os.walk(work_dir):
            for f in sorted(files):
                if f == 'mimetype':
                    continue
                full = os.path.join(root, f)
                z.write(full, os.path.relpath(full, work_dir))


def main():
    parser = argparse.ArgumentParser(description='Fix common EPUB problems')
    parser.add_argument('input', help='Path to input .epub file')
    parser.add_argument('--deep', action='store_true',
                        help='Use Claude AI for deep HTML cleanup (best for web-scraped files)')
    args = parser.parse_args()

    inp = Path(args.input).expanduser().resolve()
    if not inp.exists():
        print(f"Not found: {inp}", file=sys.stderr)
        sys.exit(1)

    out = inp.parent / (inp.stem + ' (fixed)' + inp.suffix)
    work = tempfile.mkdtemp(prefix='fix_epub_')

    try:
        with zipfile.ZipFile(inp, 'r') as z:
            z.extractall(work)

        html_files = [
            os.path.join(r, f)
            for r, _, fs in os.walk(work)
            for f in fs
            if Path(f).suffix.lower() in HTML_EXTS
        ]

        soups = []
        contents = {}
        for path in html_files:
            with open(path, 'r', encoding='utf-8', errors='replace') as f:
                raw = f.read()
            contents[path] = raw
            soups.append(BeautifulSoup(raw, 'html.parser'))

        flags = detect_fingerprint(soups)
        issues = audit_issues(soups)
        issue_names = {n for n, _ in issues}

        if 'PDF/web line fragmentation' in issue_names and not any(flags.values()):
            src = 'Unknown origin (fragmentation pattern suggests PDF or web conversion)'
        else:
            parts = [
                'PDF rip (pdftohtml)' if flags['pdf_rip'] else None,
                'Calibre conversion' if flags['calibre'] else None,
                'Word/Docs export' if flags['word_export'] else None,
                'Web scrape' if flags['web_scrape'] else None,
            ]
            src = ', '.join(x for x in parts if x) or 'Unknown / clean'

        print('\n══ EPUB Diagnosis ═' * 3 + '═' * 5)
        print(f'  Source fingerprint : {src}')
        print(f'  HTML files found   : {len(html_files)}')
        if issues:
            print('  Issues detected:')
            for n, v in issues:
                print(f'    • {n}: {v if isinstance(v, int) else "yes"}')
        else:
            print('  No common issues detected.')
        print('═' * 52 + '\n')

        if not issues and not args.deep:
            print('No fixable issues found. The EPUB looks clean already.')
            return

        for path in html_files:
            fixed = process_html(contents[path], issue_names)
            if args.deep:
                soup = BeautifulSoup(fixed, 'html.parser')
                body = soup.find('body')
                if body:
                    print(f'  [deep] {Path(path).name} …')
                    body.replace_with(BeautifulSoup(deep_clean(str(body)), 'html.parser'))
                fixed = str(soup)
            with open(path, 'w', encoding='utf-8') as f:
                f.write(fixed)

        repack_epub(work, str(out))
        print(f'✓ Fixed EPUB saved to:\n  {out}')

        if not args.deep and (flags.get('web_scrape') or len(html_files) > 50):
            print('\n\U0001f4a1 Tip: Run with --deep to use Claude AI for a deeper HTML cleanup pass.')

    finally:
        shutil.rmtree(work, ignore_errors=True)


if __name__ == '__main__':
    main()
