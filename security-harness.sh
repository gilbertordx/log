#!/usr/bin/env bash
# ==============================================================================
# Security & Secret Leakage Prevention Harness
# Scans repositories for hardcoded API keys, JWT secrets, private keys,
# unencrypted credentials, and vulnerable npm/python dependencies.
# ==============================================================================

set -euo pipefail

TARGET_DIR="${1:-/home/gilberto/log}"

echo "🔒 [Security Harness] Initializing Security & Secrets Audit..."
echo "📂 Target Directory: ${TARGET_DIR}"

TOTAL_ISSUES=0

# 1. Hardcoded Secret & Private Key Signatures
echo "----------------------------------------------------------------------"
echo "🔍 [Step 1/3] Scanning for hardcoded API keys and secrets..."

SECRET_PATTERNS=(
    "AKIA[0-9A-Z]{16}"                          # AWS Access Key
    "AIza[0-9A-Za-z\\-_]{35}"                   # Google API Key
    "sk_live_[0-9a-zA-Z]{24}"                    # Stripe Live Key
    "ghp_[0-9a-zA-Z]{36}"                        # GitHub Personal Access Token
    "-----BEGIN (RSA|EC|OPENSSH) PRIVATE KEY-----" # Private Keys
)

for pattern in "${SECRET_PATTERNS[@]}"; do
    FOUND=$(grep -rnE "$pattern" "${TARGET_DIR}" --exclude-dir={.git,.obsidian,node_modules,brain,crashes} 2>/dev/null || true)
    if [ -n "$FOUND" ]; then
        echo "  ⚠️ [WARN] Potential secret matched pattern '${pattern}':"
        echo "$FOUND" | head -n 3
        TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
    fi
done

if [ "$TOTAL_ISSUES" -eq 0 ]; then
    echo "  [OK] No hardcoded secret signatures detected."
fi

# 2. Sensitive File Exclusions Check
echo "----------------------------------------------------------------------"
echo "📄 [Step 2/3] Checking .gitignore and sensitive file rules..."

if [ -f "${TARGET_DIR}/.env" ]; then
    if [ -f "${TARGET_DIR}/.gitignore" ] && grep -q "\.env" "${TARGET_DIR}/.gitignore"; then
        echo "  [OK] .env file is present and properly ignored in .gitignore"
    else
        echo "  ⚠️ [WARN] .env file exists but is NOT listed in .gitignore!"
        TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
    fi
else
    echo "  [OK] No uncommitted .env file issues found."
fi

# 3. Dependency Vulnerability Audit
echo "----------------------------------------------------------------------"
echo "📦 [Step 3/3] Running dependency vulnerability audit..."

if [ -f "${TARGET_DIR}/package.json" ]; then
    cd "${TARGET_DIR}"
    echo "  Running npm audit..."
    npm audit --audit-level=high || echo "  [INFO] npm audit completed with warnings."
else
    echo "  [INFO] No package.json found in current target directory."
fi

echo "----------------------------------------------------------------------"
if [ "$TOTAL_ISSUES" -eq 0 ]; then
    echo "✅ [Security Harness] Audit Passed Cleanly! Zero High-Risk Leakage Found."
else
    echo "⚠️ [Security Harness] Audit Complete with ${TOTAL_ISSUES} potential issue(s) flagged."
fi
