#!/usr/bin/env bash
set -euo pipefail
# Run from repository root. Reuses the supported compiler/SDK; never flashes.
case "${1:-}" in
    iteration-002-startup-text | iteration-002-retention | iteration-002-file-selection | spike-009-hierarchy-roles | spike-010-bounded-declaration-traversal | spike-011-clean-topology-generation | spike-012-connected-packed | spike-012-connected-roles | spike-012-connected-snapshot | spike-013-connected-host-normal | spike-013-connected-host-refusal) ;;
    *) printf 'error: supply a prepared iteration-002 research name\n' >&2; exit 2 ;;
esac
source scripts/nrf52840/common.sh
giftui_nrf_export_environment
research_root="$PWD/.build/nrf52840/$1"
"${GIFTUI_NRF_WEST}" build -p always -b "${GIFTUI_NRF_BOARD}" \
    -d "${research_root}/firmware" "${research_root}/application" -- \
    "-DCMAKE_MAKE_PROGRAM=$(giftui_nrf_ninja)" \
    "-DCMAKE_Swift_COMPILER=${GIFTUI_NRF_SWIFTC}" \
    "-DGIFTUI_SWIFT_TARGET=${GIFTUI_NRF_SWIFT_TARGET}" \
    "-DDTC=$(giftui_nrf_dtc)" -DUSE_CCACHE=0
