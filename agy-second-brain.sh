#!/usr/bin/env bash
# agy-second-brain.sh — Auto-launch AGY as a "Second Brain LLM"
# Scans ~/log/brain/ for .md files (recursively) and feeds them as context to AGY.
#
# Usage:
#   ./agy-second-brain.sh              # Interactive mode (default)
#   ./agy-second-brain.sh --print "Q"  # One-shot: ask a question against your notes
#   ./agy-second-brain.sh --list       # List all discovered .md files
#   ./agy-second-brain.sh --clip <URL> # Clip a web page into raw/clippings/
#   ./agy-second-brain.sh --lint       # Run vault schema & link linter
#   ./agy-second-brain.sh --sync       # Commit & push vault to GitHub
#   ./agy-second-brain.sh --help       # Print usage help

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────
LOG_DIR="$HOME/log/brain"
SCRIPT_DIR="$HOME/log"
MAX_FILES=60           # safety cap on number of .md files to ingest
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

show_help() {
    echo -e "${BOLD}🧠 Second Brain CLI (${LOG_DIR})${NC}"
    echo ""
    echo "Usage:"
    echo "  ./agy-second-brain.sh              Interactive AGY session with full notes context"
    echo "  ./agy-second-brain.sh --print \"Q\"  Ask a one-shot question against notes"
    echo "  ./agy-second-brain.sh --list       List all loaded .md note files"
    echo "  ./agy-second-brain.sh --clip <URL> Clip web page article into raw/clippings/"
    echo "  ./agy-second-brain.sh --lint       Run vault broken link & schema diagnostic linter"
    echo "  ./agy-second-brain.sh --sync       Git add, commit, and push vault to GitHub"
    echo "  ./agy-second-brain.sh --help       Show this help menu"
    echo ""
}

# ─── Discover .md files (Recursive, excluding .obsidian & .git) ──────────────
discover_md_files() {
    local -a files=()
    while IFS= read -r -d '' f; do
        files+=("$f")
    done < <(find "$LOG_DIR" \( -name '.obsidian' -o -name '.git' \) -prune -o -name '*.md' -type f -print0 2>/dev/null | sort -z)

    if [[ ${#files[@]} -eq 0 ]]; then
        echo ""
        return
    fi

    # Cap the list if necessary
    if [[ ${#files[@]} -gt $MAX_FILES ]]; then
        log_warn "Found ${#files[@]} .md files, capping context at $MAX_FILES"
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

# ─── Build prompt ────────────────────────────────────────────────────────────
build_prompt() {
    local context="$1"
    local user_query="${2:-}"

    local prompt="You are my Second Brain assistant.

- Knowledge base: ~/log/brain/
- Review active goals and next actions.
- Adhere strictly to ~/log/brain/schema.md rules.
- Be concise and direct.

Active Notes Context:
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
    local cmd="${1:-}"

    case "$cmd" in
        --help|-h)
            show_help
            exit 0
            ;;

        --clip)
            local url="${2:-}"
            if [[ -z "$url" ]]; then
                log_error "Usage: $0 --clip <URL>"
                exit 1
            fi
            python3 "$SCRIPT_DIR/brain-clip.py" "$url" "$LOG_DIR"
            exit 0
            ;;

        --lint)
            bash "$SCRIPT_DIR/brain-linter.sh" "$LOG_DIR"
            exit 0
            ;;

        --sync)
            log_info "Synchronizing vault to GitHub..."
            cd "$SCRIPT_DIR"
            git add brain/
            if git diff --cached --quiet; then
                log_info "No changes to commit."
            else
                git commit -m "docs(brain): auto-sync vault state [$(date +'%Y-%m-%d %H:%M')]"
            fi
            git push origin main
            log_success "Vault synchronized with GitHub (gilbertordx/log)."
            exit 0
            ;;
    esac

    echo ""
    echo -e "${BOLD}🧠 AGY Second Brain${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "  Workspace: ${CYAN}${LOG_DIR}${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if ! command -v agy &>/dev/null; then
        log_error "agy not found in PATH."
        exit 1
    fi

    # Handle --list flag
    if [[ "$cmd" == "--list" ]]; then
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
        cd "$LOG_DIR"
        exec agy --prompt-interactive "You are my Second Brain LLM. Help me get started — suggest what kinds of notes I should keep here."
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

    # Handle --print mode
    if [[ "$cmd" == "--print" ]]; then
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
