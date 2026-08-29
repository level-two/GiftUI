#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
BUILD_ROOT="${PROJECT_ROOT}/.build/contract-generated/spec-003/diagnostic-buffer"

ruby "${SCRIPT_DIR}/generate-spec-003-diagnostic-buffer.rb" --check
rm -rf "${BUILD_ROOT}"
mkdir -p "${BUILD_ROOT}/clang-cache" "${BUILD_ROOT}/swiftpm-cache"

export CLANG_MODULE_CACHE_PATH="${BUILD_ROOT}/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${BUILD_ROOT}/swiftpm-cache"

for capacity in ZERO 8 16 64; do
    swift test \
        --package-path "${PROJECT_ROOT}" \
        --scratch-path "${BUILD_ROOT}/capacity-${capacity}" \
        --filter GiftUIFailureDiagnosticsTests \
        -Xswiftc "-DGIFTUI_DIAGNOSTICS_CAPACITY_${capacity}"
done

conflict_log="${BUILD_ROOT}/conflicting-selection.log"
set +e
swift build \
    --package-path "${PROJECT_ROOT}" \
    --scratch-path "${BUILD_ROOT}/conflicting-selection" \
    --target GiftUIFailureDiagnostics \
    -Xswiftc -DGIFTUI_DIAGNOSTICS_CAPACITY_8 \
    -Xswiftc -DGIFTUI_DIAGNOSTICS_CAPACITY_16 \
    >"${conflict_log}" 2>&1
conflict_result=$?
set -e
[[ "${conflict_result}" -ne 0 ]] || {
    printf '%s\n' 'error: conflicting diagnostic capacities unexpectedly compiled' >&2
    exit 1
}
grep -Fq 'select exactly one GiftUI diagnostic-buffer capacity' "${conflict_log}" || {
    printf '%s\n' 'error: conflicting diagnostic capacities lacked fail-closed diagnostic' >&2
    exit 1
}

printf '%s\n' 'SPEC-003 diagnostic buffer branches passed: 0, 8, 16, and 64 records.'
