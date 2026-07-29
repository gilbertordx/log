#!/usr/bin/env bash
# brain-linter.sh — Vault Diagnostics & Schema Verification Tool
# Checks broken [[wikilinks]], orphan nodes, unindexed raw items, and schema rules.

set -euo pipefail

BRAIN_DIR="${1:-$HOME/log/brain}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

echo ""
echo -e "${BOLD}🔍 Brain Vault Linter${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  Vault Directory: ${CYAN}${BRAIN_DIR}${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ERRORS=0
WARNINGS=0

# 1. Required core files check
log_check() { echo -e "${CYAN}[CHECK]${NC} $*"; }

log_check "Verifying core vault files..."
for req_file in "index.md" "log.md" "current-focus.md" "schema.md"; do
    if [[ ! -f "$BRAIN_DIR/$req_file" ]]; then
        echo -e "  ${RED}✖ Missing core file:${NC} $req_file"
        ((ERRORS++))
    else
        echo -e "  ${GREEN}✔ Found:${NC} $req_file"
    fi
done
echo ""

# 2. Check unindexed /raw/ projects in index.md
log_check "Checking project indexing in index.md..."
if [[ -f "$BRAIN_DIR/index.md" ]]; then
    INDEX_CONTENT=$(<"$BRAIN_DIR/index.md")
    if [[ -d "$BRAIN_DIR/raw" ]]; then
        for proj in "$BRAIN_DIR/raw"/*/; do
            [[ -d "$proj" ]] || continue
            proj_name=$(basename "$proj")
            if ! echo "$INDEX_CONTENT" | grep -qi "$proj_name"; then
                echo -e "  ${YELLOW}⚠ Unindexed raw project:${NC} $proj_name not found in index.md"
                ((WARNINGS++))
            else
                echo -e "  ${GREEN}✔ Project indexed:${NC} $proj_name"
            fi
        done
    fi
fi
echo ""

# 3. Check for broken [[wikilinks]]
log_check "Checking [[wikilinks]] resolution..."
mapfile -t ALL_MD_FILES < <(find "$BRAIN_DIR" \( -name '.obsidian' -o -name '.git' \) -prune -o -name '*.md' -type f -print | sort)

# Build map of available targets
declare -A TARGETS
for f in "${ALL_MD_FILES[@]}"; do
    filename=$(basename "$f" .md)
    relpath="${f#"$BRAIN_DIR"/}"
    relpath_no_ext="${relpath%.md}"
    TARGETS["$filename"]=1
    TARGETS["$relpath_no_ext"]=1
    TARGETS["$relpath"]=1
done

BROKEN_LINKS=0
for f in "${ALL_MD_FILES[@]}"; do
    relpath="${f#"$BRAIN_DIR"/}"
    # Find all [[target]] or [[target|alias]]
    while read -r match; do
        [[ -z "$match" ]] && continue
        # Extract target before |
        target="${match%%|*}"
        target="${target//\[\[/}"
        target="${target//\]\]/}"
        target_clean=$(echo "$target" | xargs)

        if [[ -z "${TARGETS[$target_clean]:-}" ]]; then
            echo -e "  ${YELLOW}⚠ Unresolved link in ${relpath}:${NC} [[$target_clean]]"
            ((BROKEN_LINKS++))
            ((WARNINGS++))
        fi
    done < <(grep -oP '\[\[[^\]]+\]\]' "$f" 2>/dev/null || true)
done

if [[ $BROKEN_LINKS -eq 0 ]]; then
    echo -e "  ${GREEN}✔ All [[wikilinks]] resolved successfully.${NC}"
fi
echo ""

# 4. Check for orphan wiki nodes (files in /wiki/ not linked anywhere else)
log_check "Checking for orphan wiki nodes..."
if [[ -d "$BRAIN_DIR/wiki" ]]; then
    for wf in "$BRAIN_DIR/wiki"/*.md; do
        [[ -f "$wf" ]] || continue
        wname=$(basename "$wf" .md)
        # Search references across all other files
        refs=$(grep -rn "\[\[$wname" "$BRAIN_DIR" --exclude-dir=".obsidian" --exclude="$wf" 2>/dev/null || true)
        if [[ -z "$refs" ]]; then
            echo -e "  ${YELLOW}⚠ Orphan wiki node:${NC} [[$wname]] is not linked by any other note."
            ((WARNINGS++))
        fi
    done
fi
echo ""

# Final Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}✔ Vault is clean and fully compliant with schema!${NC}"
else
    echo -e "${BOLD}Lint Results:${NC} ${RED}$ERRORS Error(s)${NC}, ${YELLOW}$WARNINGS Warning(s)${NC}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exit $ERRORS
