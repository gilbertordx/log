#!/usr/bin/env python3
"""
brain-clip.py — Web Clipper for Second Brain
Fetches a webpage, extracts article title and text, converts to clean Markdown,
and saves into ~/log/brain/raw/clippings/<domain>-<title>.md
"""

import sys
import os
import re
import urllib.request
import urllib.parse
from datetime import datetime
from html.parser import HTMLParser

class SimpleHTMLToMarkdownParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.text_parts = []
        self.title = "Untitled Clipping"
        self.in_title = False
        self.in_script_or_style = False
        self.heading_level = 0

    def handle_starttag(self, tag, attrs):
        tag_lower = tag.lower()
        if tag_lower in ['script', 'style', 'noscript', 'head', 'svg', 'nav', 'footer']:
            self.in_script_or_style = True
        elif tag_lower == 'title':
            self.in_title = True
        elif tag_lower in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']:
            self.heading_level = int(tag_lower[1])
            self.text_parts.append(f"\n\n{'#' * self.heading_level} ")
        elif tag_lower in ['p', 'div', 'br', 'li']:
            self.text_parts.append("\n\n")

    def handle_endtag(self, tag):
        tag_lower = tag.lower()
        if tag_lower in ['script', 'style', 'noscript', 'head', 'svg', 'nav', 'footer']:
            self.in_script_or_style = False
        elif tag_lower == 'title':
            self.in_title = False
        elif tag_lower in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']:
            self.heading_level = 0
            self.text_parts.append("\n\n")

    def handle_data(self, data):
        if self.in_script_or_style:
            return
        if self.in_title:
            self.title = data.strip()
            return
        cleaned = data.strip()
        if cleaned:
            self.text_parts.append(cleaned + " ")

    def get_markdown(self):
        raw = "".join(self.text_parts)
        # Collapse multiple blank lines
        cleaned = re.sub(r'\n\s*\n\s*\n+', '\n\n', raw).strip()
        return cleaned

def slugify(text):
    text = re.sub(r'[^\w\s-]', '', text).strip().lower()
    return re.sub(r'[-\s]+', '-', text)[:50]

def clip_url(url, output_dir):
    req = urllib.request.Request(
        url,
        headers={'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) SecondBrainClipper/1.0'}
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as response:
            html = response.read().decode('utf-8', errors='ignore')
    except Exception as e:
        print(f"[ERROR] Failed to fetch URL {url}: {e}", file=sys.stderr)
        sys.exit(1)

    parser = SimpleHTMLToMarkdownParser()
    parser.feed(html)
    markdown_content = parser.get_markdown()

    parsed_url = urllib.parse.urlparse(url)
    domain = parsed_url.netloc.replace('www.', '')
    slug = slugify(parser.title if parser.title != "Untitled Clipping" else parsed_url.path)
    filename = f"{slugify(domain)}-{slug}.md" if slug else f"{slugify(domain)}-clipping.md"

    clippings_dir = os.path.join(output_dir, "raw", "clippings")
    os.makedirs(clippings_dir, exist_ok=True)
    filepath = os.path.join(clippings_dir, filename)

    now_iso = datetime.now().strftime("%Y-%m-%d %H:%M")
    frontmatter = f"""---
title: "{parser.title}"
source: "{url}"
captured: "{now_iso}"
tags: [clipping, web]
---

# {parser.title}

*Source: [{domain}]({url}) — Captured on {now_iso}*

---

{markdown_content}
"""

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(frontmatter)

    print(f"[OK] Clipped web page into {filepath}")
    return filepath

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: brain-clip.py <URL> [output_brain_dir]")
        sys.exit(1)

    target_url = sys.argv[1]
    brain_dir = sys.argv[2] if len(sys.argv) > 2 else os.path.expanduser("~/log/brain")
    clip_url(target_url, brain_dir)
