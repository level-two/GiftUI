#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
cd "${project_root}"
source scripts/nrf52840/common.sh
giftui_nrf_require_environment
output="${project_root}/.build/contract-reports/spec-001/milestone-10/owner-feasibility"
mkdir -p "${output}/modules" "${output}/clang-cache"
export CLANG_MODULE_CACHE_PATH="${output}/clang-cache"
"${GIFTUI_NRF_SWIFTC}" --version > "${output}/compiler.txt"
flags=(-target "${GIFTUI_NRF_SWIFT_TARGET}" -enable-experimental-feature Embedded
    -Osize -whole-module-optimization -package-name GiftUI -parse-as-library
    -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16)
for owner in GiftUI GiftUITextResources GiftUISemanticCore GiftUILayout; do
    "${GIFTUI_NRF_SWIFTC}" "${flags[@]}" -emit-module -module-name "${owner}" \
        -I "${output}/modules" Sources/"${owner}"/*.swift \
        -emit-module-path "${output}/modules/${owner}.swiftmodule" \
        > "${output}/${owner}.log" 2>&1
    printf '%s\tcanonical-module\tpass\n' "${owner}"
done
# Compile the maintained Layout implementation with a forbidden edge added.
# Only canonical lower owners are available to this compiler invocation.
cp Sources/GiftUILayout/LayoutEngine.swift "${output}/LayoutEngine.swift"
printf '\nimport GiftUIRuntimeDynamic\n' >> "${output}/LayoutEngine.swift"
layout_sources=()
for source in Sources/GiftUILayout/*.swift; do
    [[ "${source}" == Sources/GiftUILayout/LayoutEngine.swift ]] || layout_sources+=("${source}")
done
if "${GIFTUI_NRF_SWIFTC}" "${flags[@]}" -emit-module -module-name GiftUILayout \
    -I "${output}/modules" "${layout_sources[@]}" "${output}/LayoutEngine.swift" \
    -emit-module-path "${output}/forbidden.swiftmodule" > "${output}/forbidden-import.log" 2>&1; then
    printf 'forbidden Layout import compiled\n' >&2
    exit 1
fi
rg -q "no such module 'GiftUIRuntimeDynamic'" "${output}/forbidden-import.log"
printf 'GiftUILayout\tforbidden-runtime-import\tpass\n'
printf 'evidence=cross-build-declaration-check; firmware-integration=pending\n'
