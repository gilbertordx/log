#!/usr/bin/env bash
# agy-second-brain.sh — Auto-launch AGY as a "Second Brain LLM"
# Scans ~/log/ for .md files and feeds them as context to AGY.
#
# Usage:
#   ./agy-second-brain.sh              # Interactive mode (default)
#   ./agy-second-brain.sh --print "Q"  # One-shot: ask a question against your notes
#   ./agy-second-brain.sh --list       # Just list discovered .md files
#
# The script:
#   1. Finds all .md files in ~/log/
#   2. Concatenates their content into a context block
#   3. Opens AGY in ~/log/ with a prompt instructing it to act as your
#      "second-brain-llm" — an AI that knows your personal notes

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────
LOG_DIR="$HOME/log"
MAX_FILES=50           # safety cap on number of .md files to ingest
MAX_FILE_SIZE=102400   # skip files larger than 100KB individually
# ─────────────────────────────────────────────────────────────────────────────

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log_info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error()   { echo -e "${RED}[FAIL]${NC}  $*" >&2; }

# ─── Discover .md files ─────────────────────────────────────────────────────
discover_md_files() {
    local -a files=()
    while IFS= read -r -d '' f; do
        files+=("$f")
    done < <(find "$LOG_DIR" -maxdepth 2 -name '*.md' -type f -print0 2>/dev/null | sort -z)

    if [[ ${#files[@]} -eq 0 ]]; then
        echo ""
        return
    fi

    # Cap the list
    if [[ ${#files[@]} -gt $MAX_FILES ]]; then
        log_warn "Found ${#files[@]} .md files, capping at $MAX_FILES"
        files=("${files[@]:0:$MAX_FILES}")
    fi

    printf '%s\n' "${files[@]}"
}

# ─── Build context block from .md files ──────────────────────────────────────
build_context() {
    local files_list="$1"
    local context=""
    local count=0

    while IFS= read -r filepath; do
        [[ -z "$filepath" ]] && continue

        local filesize
        filesize=$(stat --printf='%s' "$filepath" 2>/dev/null || echo 0)

        if [[ $filesize -gt $MAX_FILE_SIZE ]]; then
            log_warn "Skipping $(basename "$filepath") (${filesize} bytes > ${MAX_FILE_SIZE} limit)"
            continue
        fi

        local relpath="${filepath#"$LOG_DIR"/}"
        local content
        content=$(<"$filepath")

        context+="
--- FILE: ${relpath} ---
${content}
--- END: ${relpath} ---
"
        ((count++))
    done <<< "$files_list"

    if [[ $count -eq 0 ]]; then
        echo ""
        return
    fi

    log_success "Loaded ${count} .md file(s) as context"
    echo "$context"
}

# ─── Build the second-brain system prompt ────────────────────────────────────
build_prompt() {
    local context="$1"
    local user_query="${2:-}"

    local prompt="You are my **Second Brain LLM**. Your role:

- You have access to my personal notes and logs from ~/log/
- Use them as your knowledge base to answer questions, find patterns, recall decisions, and surface insights
- When referencing information, cite which file it came from
- If you don't find relevant info in the notes, say so clearly, then help with general knowledge
- Be concise but thorough

Here are my notes:

${context}"

    if [[ -n "$user_query" ]]; then
        prompt+="

Based on the above notes, answer this question:
${user_query}"
    fi

    echo "$prompt"
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
    echo ""
    echo -e "${BOLD}🧠 AGY Second Brain${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "  Workspace: ${CYAN}${LOG_DIR}${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Preflight: check agy is installed
    if ! command -v agy &>/dev/null; then
        log_error "agy not found in PATH. Install it first."
        exit 1
    fi

    # Handle --list flag
    if [[ "${1:-}" == "--list" ]]; then
        log_info "Markdown files in ${LOG_DIR}:"
        local files
        files=$(discover_md_files)
        if [[ -z "$files" ]]; then
            log_warn "No .md files found in ${LOG_DIR}"
        else
            echo "$files" | while IFS= read -r f; do
                local size
                size=$(stat --printf='%s' "$f" 2>/dev/null || echo "?")
                echo -e "  ${DIM}•${NC} ${f#"$LOG_DIR"/}  ${DIM}(${size} bytes)${NC}"
            done
        fi
        exit 0
    fi

    # Discover markdown files
    log_info "Scanning for .md files..."
    local files_list
    files_list=$(discover_md_files)

    if [[ -z "$files_list" ]]; then
        log_warn "No .md files found in ${LOG_DIR}"
        log_info "Launching AGY without note context..."
        echo ""
        cd "$LOG_DIR"
        exec agy --prompt-interactive "You are my Second Brain LLM. I haven't added any markdown notes to ~/log/ yet. Help me get started — suggest what kinds of notes I should keep here."
    fi

    # Show discovered files
    echo -e "  ${BOLD}Discovered notes:${NC}"
    echo "$files_list" | while IFS= read -r f; do
        echo -e "    ${DIM}📄${NC} ${f#"$LOG_DIR"/}"
    done
    echo ""

    # Build context
    local context
    context=$(build_context "$files_list")

    if [[ -z "$context" ]]; then
        log_error "Failed to build context from .md files"
        exit 1
    fi

    # Handle --print mode (one-shot question)
    if [[ "${1:-}" == "--print" ]]; then
        local question="${2:-}"
        if [[ -z "$question" ]]; then
            log_error "Usage: $0 --print \"your question\""
            exit 1
        fi
        local full_prompt
        full_prompt=$(build_prompt "$context" "$question")
        log_info "Asking one-shot question..."
        echo ""
        cd "$LOG_DIR"
        exec agy --print "$full_prompt"
    fi

    # Default: interactive mode
    local full_prompt
    full_prompt=$(build_prompt "$context")

    log_info "Launching AGY as Second Brain..."
    echo ""
    cd "$LOG_DIR"
    exec agy --prompt-interactive "$full_prompt"
}

main "$@"
