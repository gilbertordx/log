#!/usr/bin/env python3
"""
brain-clip.py — Dual-Mode Web Clipper for Second Brain
Fetches a webpage, saves full raw Markdown in ~/log/brain/raw/clippings/<slug>.md
AND creates an atomic summary node in ~/log/brain/wiki/<slug>.md with key takeaways.
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
        cleaned = re.sub(r'\n\s*\n\s*\n+', '\n\n', raw).strip()
        return cleaned

def slugify(text):
    text = re.sub(r'[^\w\s-]', '', text).strip().lower()
    return re.sub(r'[-\s]+', '-', text)[:40]

def extract_takeaways(markdown_text):
    lines = [line.strip() for line in markdown_text.split('\n') if len(line.strip()) > 30 and not line.startswith('#')]
    takeaways = lines[:4] if lines else ["Captured Web Article content."]
    return takeaways

def clip_url(url, output_dir):
    req = urllib.request.Request(
        url,
        headers={'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) SecondBrainClipper/2.0'}
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
    base_name = f"{slugify(domain)}-{slug}" if slug else f"{slugify(domain)}-clipping"

    now_iso = datetime.now().strftime("%Y-%m-%d %H:%M")

    # 1. Save Raw Clipping
    clippings_dir = os.path.join(output_dir, "raw", "clippings")
    os.makedirs(clippings_dir, exist_ok=True)
    raw_filename = f"{base_name}.md"
    raw_filepath = os.path.join(clippings_dir, raw_filename)

    raw_frontmatter = f"""---
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
    with open(raw_filepath, "w", encoding="utf-8") as f:
        f.write(raw_frontmatter)

    # 2. Save Dual-Mode Wiki Summary Node
    wiki_dir = os.path.join(output_dir, "wiki")
    os.makedirs(wiki_dir, exist_ok=True)
    wiki_filename = f"clip-{base_name}.md"
    wiki_filepath = os.path.join(wiki_dir, wiki_filename)

    takeaways = extract_takeaways(markdown_content)
    takeaway_bullets = "\n".join([f"- {t}" for t in takeaways])

    wiki_node_content = f"""# {parser.title}

- **Source Domain**: `{domain}` ([URL]({url}))
- **Captured**: {now_iso}
- **Raw Reference**: [[raw/clippings/{base_name}|Full Raw Content]]
- **Category**: [[second-brain]]

## Key Takeaways
{takeaway_bullets}
"""
    with open(wiki_filepath, "w", encoding="utf-8") as f:
        f.write(wiki_node_content)

    print(f"[OK] [Raw] Saved to {raw_filepath}")
    print(f"[OK] [Wiki] Atomic node created at {wiki_filepath}")
    return raw_filepath, wiki_filepath

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: brain-clip.py <URL> [output_brain_dir]")
        sys.exit(1)

    target_url = sys.argv[1]
    brain_dir = sys.argv[2] if len(sys.argv) > 2 else os.path.expanduser("~/log/brain")
    clip_url(target_url, brain_dir)
