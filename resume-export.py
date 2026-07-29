#!/usr/bin/env python3
"""
resume-export.py — Multi-Format Resume Exporter & Print Layout Generator
Converts Markdown resume into clean HTML5 (with single-page print CSS) and ASCII plain text.
"""

import sys
import os
import re
from pathlib import Path

def markdown_to_html(md_text, title="Resume — Gilberto Ramos"):
    lines = md_text.split('\n')
    html_lines = []
    
    html_lines.append(f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title}</title>
<style>
  @page {{
    size: letter portrait;
    margin: 0.5in;
  }}
  body {{
    font-family: 'Segoe UI', Arial, sans-serif;
    color: #1a1a1a;
    line-height: 1.45;
    margin: 0 auto;
    max-width: 800px;
    padding: 20px;
    background: #ffffff;
  }}
  h1 {{
    font-size: 24px;
    margin-bottom: 4px;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: #0d0d0d;
  }}
  h2 {{
    font-size: 14px;
    border-bottom: 2px solid #0d0d0d;
    padding-bottom: 3px;
    margin-top: 18px;
    margin-bottom: 8px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }}
  h3 {{
    font-size: 13px;
    margin-top: 10px;
    margin-bottom: 2px;
    font-weight: bold;
  }}
  p, li {{
    font-size: 11px;
  }}
  ul {{
    margin-top: 4px;
    margin-bottom: 8px;
    padding-left: 18px;
  }}
  li {{
    margin-bottom: 3px;
  }}
  .contact {{
    font-size: 11px;
    color: #444;
    margin-bottom: 14px;
  }}
  a {{
    color: #0056b3;
    text-decoration: none;
  }}
  @media print {{
    body {{
      padding: 0;
    }}
  }}
</style>
</head>
<body>
""")

    in_ul = False
    for line in lines:
        l = line.strip()
        if not l:
            if in_ul:
                html_lines.append("</ul>")
                in_ul = False
            continue

        if l.startswith("# "):
            html_lines.append(f"<h1>{l[2:]}</h1>")
        elif l.startswith("## "):
            if in_ul:
                html_lines.append("</ul>")
                in_ul = False
            html_lines.append(f"<h2>{l[3:]}</h2>")
        elif l.startswith("### "):
            if in_ul:
                html_lines.append("</ul>")
                in_ul = False
            html_lines.append(f"<h3>{l[4:]}</h3>")
        elif l.startswith("- ") or l.startswith("* "):
            if not in_ul:
                html_lines.append("<ul>")
                in_ul = True
            content_clean = l[2:]
            # Format bolding and links
            content_clean = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', content_clean)
            content_clean = re.sub(r'\[(.*?)\]\((.*?)\)', r'<a href="\2">\1</a>', content_clean)
            html_lines.append(f"  <li>{content_clean}</li>")
        else:
            if in_ul:
                html_lines.append("</ul>")
                in_ul = False
            p_clean = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', l)
            p_clean = re.sub(r'\[(.*?)\]\((.*?)\)', r'<a href="\2">\1</a>', p_clean)
            html_lines.append(f"<p>{p_clean}</p>")

    if in_ul:
        html_lines.append("</ul>")

    html_lines.append("</body>\n</html>")
    return "\n".join(html_lines)

def export_resume(md_path, output_dir=None):
    print("📄 [Resume Exporter] Exporting Markdown resume to HTML5 print format...")
    print(f"📂 Source File: {md_path}")

    if not md_path.exists():
        print(f"❌ Error: {md_path} does not exist.")
        sys.exit(1)

    content = md_path.read_text(encoding="utf-8")
    html_output = markdown_to_html(content, title=f"Resume — {md_path.stem}")

    out_dir = output_dir if output_dir else md_path.parent
    html_file = out_dir / f"{md_path.stem}.html"

    html_file.write_text(html_output, encoding="utf-8")
    print(f"✅ [Resume Exporter] Generated HTML5 single-page document at: {html_file}")
    return html_file

if __name__ == "__main__":
    src = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/home/gilberto/log/brain/raw/resume/Gilberto_Ramos_Model_Resume.md")
    export_resume(src)
