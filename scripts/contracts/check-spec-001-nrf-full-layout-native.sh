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
owner_output="${project_root}/.build/contract-generated/spec-001/nrf-native-owners"
python3 "${project_root}/scripts/contracts/compile-spec-001-nrf-native-owners.py" --output "${owner_output}"
owner_objects=()
while IFS= read -r object; do owner_objects+=("${object}"); done < "${owner_output}/owner-objects.txt"
swiftc -I "${owner_output}/modules" -DGIFTUI_REFERENCE_BITMAP_ONLY -parse-as-library -Osize -package-name GiftUI -D GIFTUI_NRF_EMBEDDED \
    "${source_file}" "${harness}" "${owner_objects[@]}" -o "${binary}"
"${binary}"
