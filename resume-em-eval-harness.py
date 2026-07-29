#!/usr/bin/env python3
"""
resume-em-eval-harness.py — Rejection-Minded Engineering Manager Audit Harness
Simulates a skeptical Engineering Manager (EM) auditing candidate resume bullets for
quantifiable metrics, technical scope, action verb impact, and zero fluff.
"""

import sys
import os
import re
from pathlib import Path

DEFAULT_RESUME = Path(os.path.expanduser("~/log/brain/raw/resume/overview.md"))

BANNED_BUZZWORDS = [
    "spearheaded", "delve", "synergy", "testament", "tapestry",
    "transformative", "pivot", "beacon", "passionate", "rockstar",
    "guru", "ninja", "game-changer", "world-class", "results-driven"
]

STRONG_ACTION_VERBS = [
    "architected", "engineered", "built", "deployed", "implemented",
    "trained", "delivered", "conducted", "modeled", "automated",
    "designed", "reduced", "compressed", "scaled", "created",
    "desenvolvi", "executei", "automatizei", "estruturei", "implementei",
    "capacitei", "modelei", "realizei"
]

METRIC_PATTERNS = [
    r'\d+%',                                              # Percentage (e.g. 90%, 25%)
    r'\d+\s*(?:min|sec|sec|hours|h|m|s|minutes|seconds|segundos|minutos)\b', # Time metrics
    r'\$\d+|\bR\$\d+',                                    # Currency ($ or R$)
    r'\d+,\d+\+|\d+\+',                                   # Counts (e.g. 1,200+, 300+)
    r'\b\d+\s*(?:operators|clients|projects|components|models|operadores|projetos|lotes|projetos)\b', # Entity counts
    r'\b\d+\b'                                            # General numbers
]

def evaluate_resume(resume_path):
    print("👔 [EM Eval Harness] Initializing Skeptical Engineering Manager Audit...")
    print(f"📂 Target Resume: {resume_path}")

    if not resume_path.exists():
        print(f"❌ Error: Resume file {resume_path} does not exist.")
        sys.exit(1)

    content = resume_path.read_text(encoding="utf-8", errors="ignore")
    lines = [line.strip() for line in content.split("\n") if line.strip()]

    # Extract bullet points specifically under Technical Projects & Professional Experience
    in_target_section = False
    experience_bullets = []

    for line in lines:
        if line.startswith("## "):
            sec_name = line.replace("## ", "").strip().lower()
            if any(k in sec_name for k in ["project", "projetos", "experience", "experiência", "work"]):
                in_target_section = True
            else:
                in_target_section = False
        elif in_target_section and (line.startswith("- ") or line.startswith("* ")):
            experience_bullets.append(line)

    if not experience_bullets:
        experience_bullets = [l for l in lines if l.startswith("- ") or l.startswith("* ")]

    total_bullets = len(experience_bullets)
    bullets_with_metrics = 0
    bullets_with_banned_words = 0
    bullets_starting_with_strong_verbs = 0
    flagged_rejections = []

    for b in experience_bullets:
        clean_bullet = re.sub(r'^[-\*]\s*', '', b).strip()
        lower_bullet = clean_bullet.lower()

        # Check for metrics
        has_metric = any(re.search(pat, lower_bullet) for pat in METRIC_PATTERNS)
        if has_metric:
            bullets_with_metrics += 1

        # Check for banned buzzwords
        found_banned = [w for w in BANNED_BUZZWORDS if w in lower_bullet]
        if found_banned:
            bullets_with_banned_words += 1
            flagged_rejections.append((clean_bullet, f"Contains banned marketing fluff: {', '.join(found_banned)}"))

        # Check for strong action verbs at start
        first_word = lower_bullet.split()[0] if lower_bullet.split() else ""
        first_word_clean = re.sub(r'[^a-z]', '', first_word)
        if first_word_clean in STRONG_ACTION_VERBS:
            bullets_starting_with_strong_verbs += 1

        # EM Rejection check: Bullet lacks metrics AND lacks strong action verb
        if not has_metric and first_word_clean not in STRONG_ACTION_VERBS:
            flagged_rejections.append((clean_bullet, "Lacks quantifiable metrics & strong action verb"))

    # Calculate EM Pass Score (0-100)
    metric_pct = (bullets_with_metrics / total_bullets) if total_bullets > 0 else 0
    verb_pct = (bullets_starting_with_strong_verbs / total_bullets) if total_bullets > 0 else 0
    fluff_penalty = bullets_with_banned_words * 20

    em_score = max(0, min(100, int((metric_pct * 50) + (verb_pct * 50) - fluff_penalty)))

    print("\n----------------------------------------------------------------------")
    print("📊 Engineering Manager Audit Summary:")
    print(f"  • Experience Bullets Analyzed:   {total_bullets}")
    print(f"  • Quantified Metric Impact:      {bullets_with_metrics}/{total_bullets} ({int(metric_pct*100)}%)")
    print(f"  • Active Action Verb Starts:     {bullets_starting_with_strong_verbs}/{total_bullets} ({int(verb_pct*100)}%)")
    print(f"  • Banned AI Jargon Flagged:      {bullets_with_banned_words}")
    print(f"  • EM Pass Score:                 {em_score}/100")

    if flagged_rejections:
        print("\n⚠️ [EM Rejection Risk Flags]:")
        for b_text, reason in flagged_rejections[:5]:
            print(f"  • Bullet: \"{b_text[:70]}...\"")
            print(f"    Reason: {reason}")
    else:
        print("\n✨ Perfect Score! Zero EM rejection flags detected across all experience bullets.")

    print("----------------------------------------------------------------------")
    if em_score >= 80:
        print("✅ [EM Eval Harness] Audit PASSED! Resume ready for Engineering Manager review.")
    else:
        print("⚠️ [EM Eval Harness] Audit WARN: Add more metric deltas and active verbs.")

    return em_score

if __name__ == "__main__":
    target = Path(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].strip() and Path(sys.argv[1]).is_file() else DEFAULT_RESUME
    evaluate_resume(target)
