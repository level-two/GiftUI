#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
PROBE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC008/Instrumentation"

fail() {
    printf 'SPEC-008 macOS render evidence failed: %s\n' "$*" >&2
    exit 1
}

[[ $# -eq 2 ]] || fail 'usage: collect-spec-008-macos-render-evidence.sh PROFILE OUTPUT'
profile="$1"
output="$2"
case "${profile}" in
    macos-dynamic | macos-static) ;;
    *) fail "unsupported profile: ${profile}" ;;
esac

mkdir -p "${output}" "${output}/module-cache"
commands="${output}/commands.txt"
: >"${commands}"
export CLANG_MODULE_CACHE_PATH="${output}/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${output}/module-cache"

record_command() {
    printf '%q ' "$@" >>"${commands}"
    printf '\n' >>"${commands}"
}

compiler="$(xcrun --find swiftc)"
clang="$(xcrun --find clang)"
sdk="$(xcrun --sdk macosx --show-sdk-path)"
profile_flag=-DGIFTUI_DYNAMIC_PROFILE
[[ "${profile}" != "macos-static" ]] || profile_flag=-DGIFTUI_STATIC_PROFILE
scratch="${output}/swiftpm"

build=(swift build --disable-sandbox --package-path "${PROJECT_ROOT}" \
    --scratch-path "${scratch}" -c release --target GiftUIRenderLowering \
    -Xswiftc "${profile_flag}" -Xswiftc -whole-module-optimization \
    -Xswiftc -target -Xswiftc arm64-apple-macosx26.0)
record_command "${build[@]}"
"${build[@]}" >/dev/null

module="$(find "${scratch}" -type f -path '*/release/Modules/GiftUIRenderLowering.swiftmodule' -print -quit)"
[[ -n "${module}" ]] || fail 'optimized Render Lowering module is missing'
bin="$(dirname "$(dirname "${module}")")"
module_dir="${bin}/Modules"

interposer="${output}/libAllocation.dylib"
compile_interposer=("${clang}" -target arm64-apple-macosx26.0 -isysroot "${sdk}" \
    -O2 -dynamiclib \
    "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/Instrumentation/AllocationInterposer.c" \
    -install_name @rpath/libAllocation.dylib -o "${interposer}")
record_command "${compile_interposer[@]}"
"${compile_interposer[@]}"

baseline="${output}/baseline"
baseline_map="${output}/baseline.map"
compile_baseline=("${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk}" \
    -O -whole-module-optimization "${profile_flag}" -parse-as-library \
    "${PROBE_ROOT}/RenderEvidenceBaseline.swift" "${interposer}" \
    -Xlinker -rpath -Xlinker "${output}" -Xlinker -map -Xlinker "${baseline_map}" \
    -o "${baseline}")
record_command "${compile_baseline[@]}"
"${compile_baseline[@]}"

objects=(
    "${bin}"/GiftUI.build/*.swift.o
    "${bin}"/GiftUITextResources.build/*.swift.o
    "${bin}"/GiftUISemanticCore.build/*.swift.o
    "${bin}"/GiftUILayout.build/*.swift.o
    "${bin}"/GiftUIRenderCore.build/*.swift.o
    "${bin}"/GiftUIRenderLowering.build/*.swift.o
)
candidate="${output}/render-probe"
candidate_map="${output}/render-probe.map"
compile_candidate=("${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk}" \
    -O -whole-module-optimization "${profile_flag}" -parse-as-library -package-name giftui \
    -I "${module_dir}" "${PROBE_ROOT}/RenderViewBorrowProbe.swift" \
    "${PROBE_ROOT}/RenderEvidenceMain.swift" "${objects[@]}" "${interposer}" \
    -Xlinker -rpath -Xlinker "${output}" -Xlinker -map -Xlinker "${candidate_map}" \
    -o "${candidate}")
record_command "${compile_candidate[@]}"
"${compile_candidate[@]}"

runtime="${output}/runtime.txt"
record_command env "DYLD_LIBRARY_PATH=${output}" "${candidate}"
env "DYLD_LIBRARY_PATH=${output}" "${candidate}" >"${runtime}"
grep -Fxq 'allocation_count=0' "${runtime}" || fail 'production allocation count is nonzero'
[[ "$(grep -Ec '^sample_[1-9]_nanoseconds=[0-9]+$' "${runtime}")" -eq 9 ]] ||
    fail 'runtime did not record nine lowering samples'
grep -Fxq 'checksum=0' "${runtime}" || fail 'production probe result differs'
printf 'measurement\tcount\tmethod\nproduction-entry-heap-allocations\t0\tpost-warmup-runtime-interposition\n' \
    >"${output}/allocation.tsv"
{
    printf 'sample\tduration_nanoseconds\tmethod\n'
    sed -n 's/^sample_\([1-9]\)_nanoseconds=\([0-9][0-9]*\)$/\1\t\2\tSwift ContinuousClock/p' \
        "${runtime}"
} >"${output}/timing-samples.tsv"

probe_ir="${output}/render-resource.ll"
workspace="${output}/concrete-workspace.tsv"
compile_ir=("${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk}" \
    -O -whole-module-optimization "${profile_flag}" -package-name giftui \
    -I "${module_dir}" -parse-as-library -emit-ir \
    "${PROBE_ROOT}/RenderViewBorrowProbe.swift" -o "${probe_ir}")
record_command "${compile_ir[@]}"
"${compile_ir[@]}"
record_command "${SCRIPT_DIR}/check-spec-008-render-resource-ir.rb" "${probe_ir}" "${workspace}"
"${SCRIPT_DIR}/check-spec-008-render-resource-ir.rb" "${probe_ir}" "${workspace}" >/dev/null

inspector="$(xcrun --find size)"
sections="${output}/linked-section-deltas.tsv"
record_command "${SCRIPT_DIR}/report-spec-002-linked-sections.rb" macho "${inspector}" \
    "${baseline}" "${candidate}" "${baseline_map}" "${candidate_map}" "${sections}"
"${SCRIPT_DIR}/report-spec-002-linked-sections.rb" macho "${inspector}" \
    "${baseline}" "${candidate}" "${baseline_map}" "${candidate_map}" "${sections}" >/dev/null

nm="$(xcrun --find nm)"
record_command "${nm}" -U "${candidate}"
"${nm}" -U "${candidate}" >"${output}/symbols.txt"

printf 'SPEC-008 %s macOS render evidence passed: optimized image, zero post-warmup allocations, nine timing samples, finite workspace, sections, and link maps.\n' "${profile}"
