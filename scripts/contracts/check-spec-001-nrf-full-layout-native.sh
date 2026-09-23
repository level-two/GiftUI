#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
source_file="${project_root}/.build/nrf52840/signal-analyzer-static/SignalAnalyzerStatic.swift"
harness="${project_root}/firmware/nrf52840/applications/signal-analyzer-static/tests/full_layout_native.swift"
binary="${project_root}/.build/nrf52840/signal-analyzer-static/full-layout-native"

[[ -f "${source_file}" ]] || {
    printf 'nRF amalgamated Swift source missing; build signal-analyzer-static first\n' >&2
    exit 1
}
mkdir -p "${project_root}/.build/clang-module-cache"
export CLANG_MODULE_CACHE_PATH="${project_root}/.build/clang-module-cache"
swiftc -parse-as-library -Osize -package-name GiftUI -D GIFTUI_NRF_EMBEDDED \
    "${source_file}" "${harness}" -o "${binary}"
"${binary}"
