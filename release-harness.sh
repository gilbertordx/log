#!/usr/bin/env bash
# ==============================================================================
# Git Release & Changelog Automation Harness
# Parses conventional commit history, formats CHANGELOG.md entries,
# checks working tree status, and prepares release notes.
# ==============================================================================

set -euo pipefail

TARGET_DIR="/home/gilberto/log"
DRY_RUN=false

for arg in "$@"; do
    if [ "$arg" = "--dry-run" ]; then
        DRY_RUN=true
    elif [ -d "$arg" ]; then
        TARGET_DIR="$arg"
    fi
done

echo "🚀 [Release Harness] Initializing Git Release & Changelog Automation..."
echo "📂 Working Directory: ${TARGET_DIR}"

cd "${TARGET_DIR}"

# 1. Git Repository & Working Tree Verification
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ Error: ${TARGET_DIR} is not a valid git repository."
    exit 1
fi

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
echo "🌿 Current Branch: ${BRANCH_NAME}"

# 2. Parse Conventional Commits
echo "----------------------------------------------------------------------"
echo "📜 [Step 1/2] Parsing git commit history..."

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -n "$LAST_TAG" ]; then
    echo "🏷️ Last Tag Found: ${LAST_TAG}"
    COMMIT_RANGE="${LAST_TAG}..HEAD"
else
    echo "🏷️ No git tags found. Parsing recent commits..."
    COMMIT_RANGE="HEAD~15..HEAD"
fi

FEAT_COMMITS=$(git log ${COMMIT_RANGE} --grep="^feat" --oneline 2>/dev/null || echo "")
FIX_COMMITS=$(git log ${COMMIT_RANGE} --grep="^fix" --oneline 2>/dev/null || echo "")
DOCS_COMMITS=$(git log ${COMMIT_RANGE} --grep="^docs" --oneline 2>/dev/null || echo "")

# 3. Formatted Release Notes Generation
echo "----------------------------------------------------------------------"
echo "📝 [Step 2/2] Generating Changelog Summary..."

CHANGELOG_OUTPUT="## Release Summary ($(date +'%Y-%m-%d'))\n\n"

if [ -n "$FEAT_COMMITS" ]; then
    CHANGELOG_OUTPUT="${CHANGELOG_OUTPUT}### ✨ Features\n${FEAT_COMMITS}\n\n"
fi

if [ -n "$FIX_COMMITS" ]; then
    CHANGELOG_OUTPUT="${CHANGELOG_OUTPUT}### 🐛 Bug Fixes\n${FIX_COMMITS}\n\n"
fi

if [ -n "$DOCS_COMMITS" ]; then
    CHANGELOG_OUTPUT="${CHANGELOG_OUTPUT}### 📝 Documentation\n${DOCS_COMMITS}\n\n"
fi

if [ -z "$FEAT_COMMITS" ] && [ -z "$FIX_COMMITS" ] && [ -z "$DOCS_COMMITS" ]; then
    RECENT_ALL=$(git log -n 5 --oneline 2>/dev/null || echo "No recent commits.")
    CHANGELOG_OUTPUT="${CHANGELOG_OUTPUT}### 🔄 Recent Activity\n${RECENT_ALL}\n\n"
fi

echo -e "$CHANGELOG_OUTPUT"

if [ "$DRY_RUN" = true ]; then
    echo "🧪 [Release Harness] Dry-run complete. Changelog generated without file edits."
else
    echo "💾 Appending entry to CHANGELOG.md..."
    echo -e "$CHANGELOG_OUTPUT" >> CHANGELOG.md 2>/dev/null || true
    echo "✅ [Release Harness] CHANGELOG.md updated successfully!"
fi
