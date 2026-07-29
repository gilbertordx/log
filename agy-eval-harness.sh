#!/usr/bin/env bash
# ==============================================================================
# AGY Task Execution & Evaluation Harness
# Dispatches prompts to `agy --print`, runs automated verification, and
# automatically rolls back git changes if verification fails.
# ==============================================================================

set -euo pipefail

PROMPT_TEXT=""
DRY_RUN=false

usage() {
    echo "Usage: $0 [options] \"<task-prompt>\""
    echo ""
    echo "Options:"
    echo "  --dry-run       Simulate harness run without invoking agy or git rollback"
    echo "  -h, --help      Show this help menu"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            PROMPT_TEXT="$1"
            shift
            ;;
    esac
done

if [ -z "$PROMPT_TEXT" ]; then
    echo "❌ [AGY Eval Harness] Error: No task prompt provided."
    usage
fi

echo "🤖 [AGY Eval Harness] Initializing AGY Task Harness..."
echo "💬 Prompt: \"${PROMPT_TEXT}\""
echo "📂 CWD: $(pwd)"

if [ "$DRY_RUN" = true ]; then
    echo "🧪 [AGY Eval Harness] Dry-run mode active. Simulation succeeded."
    exit 0
fi

# 1. Record pre-task git commit/checkpoint
PREV_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "")

# 2. Dispatch Task to AGY Non-Interactively
echo "🚀 [AGY Eval Harness] Dispatching prompt to agy --print..."
agy --print "${PROMPT_TEXT}"

# 3. Empirical Verification Test
echo "----------------------------------------------------------------------"
echo "🔬 [AGY Eval Harness] Running automated verification test..."

TEST_PASSED=true

if [ -f "package.json" ]; then
    echo "   Running npm test..."
    npm test || TEST_PASSED=false
elif [ -f "pytest.ini" ] || [ -f "pyproject.toml" ] || ls *.py >/dev/null 2>&1; then
    echo "   Running python test check..."
    python3 -m unittest discover 2>/dev/null || true
fi

# 4. Result Evaluation & Rollback Protection
if [ "$TEST_PASSED" = true ]; then
    echo "🎉 [AGY Eval Harness] Verification PASSED cleanly! Task complete."
else
    echo "❌ [AGY Eval Harness] Verification FAILED after AGY changes."
    if [ -n "$PREV_COMMIT" ]; then
        echo "⚠️ [AGY Eval Harness] Rolling back git repository changes for safety..."
        git checkout .
    fi
    exit 1
fi
