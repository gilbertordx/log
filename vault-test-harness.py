#!/usr/bin/env python3
"""
Second-Brain Obsidian Vault Health & Link Test Harness
Scans Markdown notes in your vault, verifies internal wiki-links [[note]],
validates YAML frontmatter, and reports vault health.
"""

import os
import re
import sys
from pathlib import Path

VAULT_DIR = Path("/home/gilberto/log")
BRAIN_DIR = VAULT_DIR / "brain"

def scan_vault():
    print("🧠 [Vault Harness] Scanning Obsidian Second-Brain Vault...")
    print(f"📂 Target Directory: {VAULT_DIR}")

    if not VAULT_DIR.exists():
        print(f"❌ Error: Vault directory {VAULT_DIR} does not exist.")
        sys.exit(1)

    md_files = list(VAULT_DIR.rglob("*.md"))
    print(f"📄 Found {len(md_files)} Markdown note files.")

    wiki_link_pattern = re.compile(r'\[\[([^\]\|]+)(?:\|[^\]]+)?\]\]')

    existing_note_names = {f.stem.lower() for f in md_files}
    existing_note_names.update({f.name.lower() for f in md_files})
    for f in md_files:
        try:
            existing_note_names.add(f.relative_to(VAULT_DIR).with_suffix('').as_posix().lower())
            existing_note_names.add(f.relative_to(BRAIN_DIR).with_suffix('').as_posix().lower())
        except Exception:
            pass

    total_links = 0
    broken_links = []
    notes_with_frontmatter = 0

    for md_file in md_files:
        try:
            content = md_file.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue

        if content.startswith("---"):
            notes_with_frontmatter += 1

        links = wiki_link_pattern.findall(content)
        for link in links:
            total_links += 1
            clean_link = link.strip().lower()
            if clean_link and clean_link not in existing_note_names and not clean_link.startswith("http"):
                broken_links.append((md_file.name, link))

    print("\n----------------------------------------------------------------------")
    print("📊 Vault Health Audit Summary:")
    print(f"  • Total Markdown Notes:      {len(md_files)}")
    print(f"  • Notes with Frontmatter:    {notes_with_frontmatter}")
    print(f"  • Total Internal Wiki-Links: {total_links}")
    print(f"  • Potential Unresolved Links:{len(broken_links)}")

    if broken_links:
        print("\n🔍 Unresolved Wiki-Link Preview (Top 5):")
        for file_name, target in broken_links[:5]:
            print(f"  ⚠️  In '{file_name}': [[{target}]]")
    else:
        print("\n✨ All internal wiki-links resolved cleanly!")

    print("----------------------------------------------------------------------")
    print("✅ [Vault Harness] Obsidian Vault Audit Complete!")

if __name__ == "__main__":
    scan_vault()
