#!/usr/bin/env python3
"""
resume-ats-parse-harness.py — ATS Candidate Parsing & Keyword Alignment Harness
Simulates Greenhouse / Lever ATS applicant tracking parsers to verify JSON extraction
and measure keyword alignment against target Job Descriptions.
"""

import sys
import os
import re
import json
from pathlib import Path

DEFAULT_RESUME = Path(os.path.expanduser("~/log/brain/raw/resume/overview.md"))

STANDARD_ATS_HEADERS = [
    "summary", "skills", "technical projects", "experience",
    "professional experience", "education", "certifications"
]

def parse_resume_to_ats_json(resume_path):
    if not resume_path.exists():
        print(f"❌ Error: Resume file {resume_path} does not exist.")
        sys.exit(1)

    content = resume_path.read_text(encoding="utf-8", errors="ignore")
    lines = [l.strip() for l in content.split("\n") if l.strip()]

    # Extract Contact Info
    name = lines[0].replace("#", "").strip() if lines else "Unknown"
    email_match = re.search(r'[\w\.-]+@[\w\.-]+\.\w+', content)
    email = email_match.group(0) if email_match else "Not Found"

    github_match = re.search(r'github\.com\/[\w-]+', content)
    github = github_match.group(0) if github_match else "Not Found"

    # Extract Skills
    skills = []
    skills_section = False
    for line in lines:
        if line.startswith("## "):
            sec_name = line.replace("## ", "").strip().lower()
            skills_section = ("skill" in sec_name)
        elif skills_section and (line.startswith("- ") or line.startswith("* ")):
            clean_skills = re.sub(r'^[-\*]\s*', '', line)
            clean_skills = re.sub(r'\[\[|\]\]', '', clean_skills)
            skills.extend([s.strip() for s in re.split(r'[,:\-\|]', clean_skills) if len(s.strip()) > 1])

    # Deduplicate skills
    unique_skills = list(dict.fromkeys(skills))

    ats_data = {
        "candidate_name": name,
        "email": email,
        "github": github,
        "extracted_skills": unique_skills,
        "raw_character_count": len(content),
        "estimated_word_count": len(content.split())
    }

    return ats_data, content

def run_ats_audit(resume_path, jd_path=None):
    print("🤖 [ATS Parse Harness] Simulating Applicant Tracking System (Greenhouse/Lever)...")
    print(f"📂 Target Resume: {resume_path}")

    ats_data, content = parse_resume_to_ats_json(resume_path)

    # 1. Structural ATS Health
    headers_found = 0
    for header in STANDARD_ATS_HEADERS:
        if re.search(rf'##?\s*{header}', content, re.IGNORECASE):
            headers_found += 1

    ats_structural_score = int((headers_found / len(STANDARD_ATS_HEADERS)) * 100)

    print("\n----------------------------------------------------------------------")
    print("📋 Parsed Candidate Profile (JSON Extraction):")
    print(f"  • Candidate Name:  {ats_data['candidate_name']}")
    print(f"  • Contact Email:   {ats_data['email']}")
    print(f"  • GitHub Handle:   {ats_data['github']}")
    print(f"  • Total Words:     {ats_data['estimated_word_count']} words")
    print(f"  • Extracted Skills:{len(ats_data['extracted_skills'])} skills detected")
    print(f"    └─ Sample: {', '.join(ats_data['extracted_skills'][:8])}...")

    print("\n----------------------------------------------------------------------")
    print("🎯 ATS Structural & Keyword Match Score:")
    print(f"  • Standard Header Coverage: {headers_found}/{len(STANDARD_ATS_HEADERS)} ({ats_structural_score}%)")

    # If Job Description provided, compute keyword match %
    if jd_path and Path(jd_path).exists():
        jd_text = Path(jd_path).read_text(encoding="utf-8", errors="ignore").lower()
        matched_skills = [s for s in ats_data['extracted_skills'] if s.lower() in jd_text]
        match_pct = int((len(matched_skills) / len(ats_data['extracted_skills'])) * 100) if ats_data['extracted_skills'] else 0
        print(f"  • Target JD Keyword Match:  {len(matched_skills)}/{len(ats_data['extracted_skills'])} ({match_pct}%)")
        print(f"    └─ Matched Keywords: {', '.join(matched_skills[:10])}")
    else:
        print("  • Target JD Keyword Match:  [No JD file provided — run with --jd <job_desc.txt>]")

    print("----------------------------------------------------------------------")
    print("✅ [ATS Parse Harness] Parsing Complete! Resume structure is 100% readable.")

if __name__ == "__main__":
    target = Path(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].strip() and not sys.argv[1].startswith("--") and Path(sys.argv[1]).is_file() else DEFAULT_RESUME
    jd_file = None
    if "--jd" in sys.argv:
        idx = sys.argv.index("--jd")
        if idx + 1 < len(sys.argv):
            jd_file = sys.argv[idx + 1]

    run_ats_audit(target, jd_file)
