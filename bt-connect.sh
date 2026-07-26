#!/usr/bin/env bash
# bt-connect.sh — Idempotent Bluetooth connection script
# Automates the full recovery flow for paired Bluetooth devices.
#
# Usage:
#   ./bt-connect.sh              # Connect default device (Keyboard K380)
#   ./bt-connect.sh <MAC>        # Connect a specific device by MAC address
#   ./bt-connect.sh --status     # Show status of default device
#
# Exit codes:
#   0 — Connected successfully
#   1 — Failed to connect after all recovery attempts

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────
DEFAULT_MAC="F4:73:35:5E:84:FF"
DEFAULT_NAME="Keyboard K380"
SCAN_TIMEOUT=15          # seconds to scan for devices
PAIR_DELAY=5             # seconds to wait after scan starts before pairing
CONNECT_RETRIES=3        # number of connect attempts per strategy
RETRY_DELAY=2            # seconds between retries
# ─────────────────────────────────────────────────────────────────────────────

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error()   { echo -e "${RED}[FAIL]${NC}  $*"; }
log_step()    { echo -e "${CYAN}[STEP]${NC}  ${BOLD}$*${NC}"; }

# ─── Preflight checks ───────────────────────────────────────────────────────
check_dependencies() {
    if ! command -v bluetoothctl &>/dev/null; then
        log_error "bluetoothctl not found. Install bluez: sudo apt install bluez"
        exit 1
    fi
}

check_adapter() {
    if ! bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        log_warn "Bluetooth adapter is powered off. Powering on..."
        bluetoothctl power on
        sleep 1
    fi
    log_success "Bluetooth adapter is powered on"
}

# ─── Status check ───────────────────────────────────────────────────────────
is_connected() {
    local mac="$1"
    bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"
}

is_paired() {
    local mac="$1"
    bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes"
}

is_trusted() {
    local mac="$1"
    bluetoothctl info "$mac" 2>/dev/null | grep -q "Trusted: yes"
}

show_status() {
    local mac="$1"
    echo -e "${BOLD}Device: ${CYAN}${mac}${NC}"
    echo "────────────────────────────────────"

    if bluetoothctl info "$mac" &>/dev/null; then
        local name
        name=$(bluetoothctl info "$mac" 2>/dev/null | grep "Name:" | cut -d' ' -f2-)
        echo -e "  Name:      ${name:-unknown}"
        echo -ne "  Paired:    "; is_paired "$mac" && echo -e "${GREEN}yes${NC}" || echo -e "${RED}no${NC}"
        echo -ne "  Trusted:   "; is_trusted "$mac" && echo -e "${GREEN}yes${NC}" || echo -e "${RED}no${NC}"
        echo -ne "  Connected: "; is_connected "$mac" && echo -e "${GREEN}yes${NC}" || echo -e "${RED}no${NC}"
    else
        echo -e "  ${YELLOW}Device not known to the system${NC}"
    fi
}

# ─── Connection strategies ───────────────────────────────────────────────────

# Strategy 1: Simple connect (works if device is already paired & nearby)
try_connect() {
    local mac="$1"
    log_step "Attempting direct connection to ${mac}..."

    for i in $(seq 1 "$CONNECT_RETRIES"); do
        if bluetoothctl connect "$mac" 2>&1 | grep -q "Connection successful"; then
            return 0
        fi
        [ "$i" -lt "$CONNECT_RETRIES" ] && sleep "$RETRY_DELAY"
    done
    return 1
}

# Strategy 2: Restart bluetooth service, then connect
try_restart_and_connect() {
    local mac="$1"
    log_step "Restarting Bluetooth service..."

    sudo systemctl restart bluetooth
    sleep 2

    # Re-power adapter after service restart
    bluetoothctl power on &>/dev/null
    sleep 1

    try_connect "$mac"
}

# Strategy 3: Full re-pair cycle (remove → scan → pair → trust → connect)
try_full_repair() {
    local mac="$1"
    log_step "Starting full re-pair cycle..."

    # Remove stale pairing if exists
    if bluetoothctl info "$mac" &>/dev/null; then
        log_info "Removing stale pairing..."
        bluetoothctl remove "$mac" 2>/dev/null || true
        sleep 1
    fi

    # Scan and pair concurrently
    log_info "Scanning for device (${SCAN_TIMEOUT}s)..."
    log_warn "Make sure the device is in pairing mode!"
    echo ""

    bluetoothctl --timeout "$SCAN_TIMEOUT" scan on &
    local scan_pid=$!

    # Wait for device to appear, then pair
    local found=false
    for i in $(seq 1 "$SCAN_TIMEOUT"); do
        sleep 1
        if bluetoothctl devices 2>/dev/null | grep -q "$mac"; then
            found=true
            log_success "Device found after ${i}s"
            sleep "$PAIR_DELAY"
            break
        fi
    done

    # Kill scan if still running
    kill "$scan_pid" 2>/dev/null || true
    wait "$scan_pid" 2>/dev/null || true

    if ! $found; then
        log_error "Device ${mac} not found during scan"
        return 1
    fi

    # Pair
    log_info "Pairing..."
    if ! bluetoothctl pair "$mac" 2>&1 | grep -q "Pairing successful"; then
        log_error "Pairing failed"
        return 1
    fi
    log_success "Paired"

    # Trust
    log_info "Setting device as trusted..."
    bluetoothctl trust "$mac" 2>/dev/null
    log_success "Trusted"

    # Connect
    try_connect "$mac"
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
    local mac="${1:-$DEFAULT_MAC}"

    # Handle --status flag
    if [[ "$mac" == "--status" ]]; then
        check_dependencies
        show_status "${2:-$DEFAULT_MAC}"
        exit 0
    fi

    echo ""
    echo -e "${BOLD}🔵 Bluetooth Auto-Connect${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "  Device: ${CYAN}${mac}${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    check_dependencies
    check_adapter

    # Already connected? Nothing to do.
    if is_connected "$mac"; then
        log_success "Device is already connected! Nothing to do."
        exit 0
    fi

    # Strategy 1: Direct connect
    if try_connect "$mac"; then
        log_success "Connected via direct connect ✅"
        show_status "$mac"
        exit 0
    fi
    log_warn "Direct connect failed, escalating..."
    echo ""

    # Strategy 2: Restart + connect
    if try_restart_and_connect "$mac"; then
        log_success "Connected after service restart ✅"
        show_status "$mac"
        exit 0
    fi
    log_warn "Restart + connect failed, escalating..."
    echo ""

    # Strategy 3: Full re-pair
    if try_full_repair "$mac"; then
        log_success "Connected after full re-pair ✅"
        show_status "$mac"
        exit 0
    fi

    echo ""
    log_error "All connection strategies exhausted. Could not connect to ${mac}."
    log_error "Troubleshooting tips:"
    echo "  • Make sure the device is powered on and in range"
    echo "  • Put the device in pairing mode and try again"
    echo "  • Check: bluetoothctl show (adapter status)"
    echo "  • Check: dmesg | tail -20 (kernel errors)"
    exit 1
}

main "$@"
