#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
PROBE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC008/Instrumentation"

fail() {
    printf 'SPEC-008 ARMv6 render evidence failed: %s\n' "$*" >&2
    exit 1
}

[[ $# -eq 1 ]] || fail 'usage: collect-spec-008-armv6-render-evidence.sh OUTPUT'
output="$1"
mkdir -p "${output}" "${output}/module-cache"
commands="${output}/commands.txt"
: >"${commands}"
export CLANG_MODULE_CACHE_PATH="${output}/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${output}/module-cache"

record_command() {
    printf '%q ' "$@" >>"${commands}"
    printf '\n' >>"${commands}"
}

# shellcheck source=../raspberry-pi/common.sh
source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
giftui_pi_require_sdk
giftui_pi_prepare_build_environment
swift_driver="$(giftui_pi_host_swift)"
compiler="$(dirname "${swift_driver}")/swiftc"
sdk_root="${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}"
scratch="${output}/swiftpm"

build=("${swift_driver}" build --disable-sandbox --package-path "${PROJECT_ROOT}" \
    --scratch-path "${scratch}" --destination "${GIFTUI_PI_STATIC_DESTINATION}" \
    --configuration release --target GiftUIRenderLowering --static-swift-stdlib \
    -Xswiftc -whole-module-optimization -Xswiftc -DGIFTUI_DYNAMIC_PROFILE)
record_command "${build[@]}"
"${build[@]}" >/dev/null

module="$(find "${scratch}" -type f -path '*/release/Modules/GiftUIRenderLowering.swiftmodule' -print -quit)"
[[ -n "${module}" ]] || fail 'optimized Render Lowering module is missing'
bin="$(dirname "$(dirname "${module}")")"
module_dir="${bin}/Modules"
flags=(
    -target "${GIFTUI_PI_TARGET}"
    -use-ld=lld
    -Xcc "--gcc-toolchain=${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr"
    -resource-dir "${sdk_root}/usr/lib/swift_static"
    -sdk "${sdk_root}"
    -latomic
    -O -whole-module-optimization -DGIFTUI_DYNAMIC_PROFILE
    -language-mode 6 -package-name giftui
)

baseline="${output}/baseline"
baseline_map="${output}/baseline.map"
compile_baseline=("${compiler}" "${flags[@]}" -parse-as-library -static-executable \
    "${PROBE_ROOT}/RenderEvidenceBaseline.swift" \
    -Xlinker "-Map=${baseline_map}" -o "${baseline}")
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
compile_candidate=("${compiler}" "${flags[@]}" -I "${module_dir}" \
    -parse-as-library -static-executable \
    "${PROBE_ROOT}/RenderViewBorrowProbe.swift" \
    "${PROBE_ROOT}/RenderEvidenceCrossMain.swift" "${objects[@]}" \
    -Xlinker "-Map=${candidate_map}" -o "${candidate}")
record_command "${compile_candidate[@]}"
"${compile_candidate[@]}"
giftui_pi_verify_armv6_binary "${candidate}" >/dev/null

probe_ir="${output}/render-resource.ll"
workspace="${output}/concrete-workspace.tsv"
compile_ir=("${compiler}" "${flags[@]}" -I "${module_dir}" -parse-as-library \
    -emit-ir "${PROBE_ROOT}/RenderViewBorrowProbe.swift" -o "${probe_ir}")
record_command "${compile_ir[@]}"
"${compile_ir[@]}"
record_command "${SCRIPT_DIR}/check-spec-008-render-resource-ir.rb" "${probe_ir}" "${workspace}"
"${SCRIPT_DIR}/check-spec-008-render-resource-ir.rb" "${probe_ir}" "${workspace}" >/dev/null

probe_sil="${output}/render-resource.sil"
compile_sil=("${compiler}" "${flags[@]}" -I "${module_dir}" -parse-as-library \
    -emit-sil "${PROBE_ROOT}/RenderViewBorrowProbe.swift" -o "${probe_sil}")
record_command "${compile_sil[@]}"
"${compile_sil[@]}"
production_body="$(sed -n '/spec008StaticRenderProductionEntry/,/^}/p' "${probe_sil}")"
[[ -n "${production_body}" ]] || fail 'optimized production SIL body is missing'
if printf '%s\n' "${production_body}" | grep -Eq '\b(alloc_ref|alloc_box|swift_allocObject)\b'; then
    fail 'optimized production SIL contains a heap allocation instruction'
fi
printf 'measurement\tcount\tmethod\nproduction-entry-heap-allocation-instructions\t0\toptimized-target-sil\n' \
    >"${output}/allocation.tsv"

inspector="${GIFTUI_PI_HOST_BIN_DIR}/llvm-objdump"
sections="${output}/linked-section-deltas.tsv"
record_command "${SCRIPT_DIR}/report-spec-002-linked-sections.rb" elf "${inspector}" \
    "${baseline}" "${candidate}" "${baseline_map}" "${candidate_map}" "${sections}"
"${SCRIPT_DIR}/report-spec-002-linked-sections.rb" elf "${inspector}" \
    "${baseline}" "${candidate}" "${baseline_map}" "${candidate_map}" "${sections}" >/dev/null

nm="${GIFTUI_PI_HOST_BIN_DIR}/llvm-nm"
record_command "${nm}" --defined-only "${candidate}"
"${nm}" --defined-only "${candidate}" >"${output}/symbols.txt"

printf 'SPEC-008 ARMv6 render evidence passed: linked ARMv6 image, zero optimized allocation instructions, finite workspace, sections, symbols, and link maps.\n'
