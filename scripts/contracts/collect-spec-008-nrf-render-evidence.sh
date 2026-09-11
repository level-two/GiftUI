#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
PROBE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC008/Instrumentation"

fail() {
    printf 'SPEC-008 nRF render evidence failed: %s\n' "$*" >&2
    exit 1
}

[[ $# -eq 1 ]] || fail 'usage: collect-spec-008-nrf-render-evidence.sh OUTPUT'
output="$1"
module_dir="${output}/modules"
mkdir -p "${output}" "${module_dir}" "${output}/module-cache"
commands="${output}/commands.txt"
: >"${commands}"
export CLANG_MODULE_CACHE_PATH="${output}/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${output}/module-cache"

record_command() {
    printf '%q ' "$@" >>"${commands}"
    printf '\n' >>"${commands}"
}

# shellcheck source=../nrf52840/common.sh
source "${PROJECT_ROOT}/scripts/nrf52840/common.sh"
giftui_nrf_require_environment
giftui_nrf_export_environment
compiler="${GIFTUI_NRF_SWIFTC}"
flags=(
    -target "${GIFTUI_NRF_SWIFT_TARGET}"
    -enable-experimental-feature Embedded
    -Osize -whole-module-optimization -DGIFTUI_STATIC_PROFILE
    -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
    -Xcc -fshort-enums -Xcc -fno-pic -Xcc -fno-pie
    -Xfrontend -function-sections -Xfrontend -disable-stack-protector
    -language-mode 6 -package-name giftui -parse-as-library
)

compile_module() {
    local name="$1"
    shift
    local object="${output}/${name}.o"
    local -a command=("${compiler}" "${flags[@]}" -I "${module_dir}" \
        -emit-module -emit-object -module-name "${name}" "$@" \
        -emit-module-path "${module_dir}/${name}.swiftmodule" -o "${object}")
    record_command "${command[@]}"
    "${command[@]}"
}

compile_module GiftUI "${PROJECT_ROOT}"/Sources/GiftUI/*.swift
compile_module GiftUITextResources "${PROJECT_ROOT}"/Sources/GiftUITextResources/*.swift
compile_module GiftUISemanticCore "${PROJECT_ROOT}"/Sources/GiftUISemanticCore/*.swift
compile_module GiftUILayout "${PROJECT_ROOT}"/Sources/GiftUILayout/*.swift
compile_module GiftUIRenderCore "${PROJECT_ROOT}"/Sources/GiftUIRenderCore/*.swift
compile_module GiftUIRenderLowering "${PROJECT_ROOT}"/Sources/GiftUIRenderLowering/*.swift
compile_module GiftUIRenderEvidenceProbe "${PROBE_ROOT}/RenderViewBorrowProbe.swift"

probe_ir="${output}/render-resource.ll"
workspace="${output}/concrete-workspace.tsv"
compile_ir=("${compiler}" "${flags[@]}" -I "${module_dir}" -emit-ir \
    -module-name GiftUIRenderEvidenceIR "${PROBE_ROOT}/RenderViewBorrowProbe.swift" \
    -o "${probe_ir}")
record_command "${compile_ir[@]}"
"${compile_ir[@]}"
record_command "${SCRIPT_DIR}/check-spec-008-render-resource-ir.rb" "${probe_ir}" "${workspace}"
"${SCRIPT_DIR}/check-spec-008-render-resource-ir.rb" "${probe_ir}" "${workspace}" >/dev/null

probe_sil="${output}/render-resource.sil"
compile_sil=("${compiler}" "${flags[@]}" -I "${module_dir}" -emit-sil \
    -module-name GiftUIRenderEvidenceSIL "${PROBE_ROOT}/RenderViewBorrowProbe.swift" \
    -o "${probe_sil}")
record_command "${compile_sil[@]}"
"${compile_sil[@]}"
production_body="$(sed -n '/spec008StaticRenderProductionEntry/,/^}/p' "${probe_sil}")"
[[ -n "${production_body}" ]] || fail 'optimized production SIL body is missing'
if printf '%s\n' "${production_body}" | grep -Eq '\b(alloc_ref|alloc_box|swift_allocObject)\b'; then
    fail 'optimized production SIL contains a heap allocation instruction'
fi
printf 'measurement\tcount\tmethod\nproduction-entry-heap-allocation-instructions\t0\toptimized-target-sil\n' \
    >"${output}/allocation.tsv"

objects=(
    "${output}/GiftUI.o"
    "${output}/GiftUITextResources.o"
    "${output}/GiftUISemanticCore.o"
    "${output}/GiftUILayout.o"
    "${output}/GiftUIRenderCore.o"
    "${output}/GiftUIRenderLowering.o"
    "${output}/GiftUIRenderEvidenceProbe.o"
)
object_list="$(IFS=';'; printf '%s' "${objects[*]}")"
application="${PROJECT_ROOT}/firmware/nrf52840/applications/spec008-render-probe"
for variant in baseline candidate; do
    build="${output}/zephyr-${variant}"
    candidate_flag=OFF
    [[ "${variant}" != candidate ]] || candidate_flag=ON
    command=("${GIFTUI_NRF_WEST}" build -p always -b "${GIFTUI_NRF_BOARD}" \
        -d "${build}" "${application}" -- \
        "-DCMAKE_MAKE_PROGRAM=$(giftui_nrf_ninja)" \
        "-DCMAKE_Swift_COMPILER=${compiler}" \
        "-DGIFTUI_SWIFT_TARGET=${GIFTUI_NRF_SWIFT_TARGET}" \
        "-DGIFTUI_SPEC008_CANDIDATE=${candidate_flag}" \
        "-DGIFTUI_MODULE_DIR=${module_dir}" \
        "-DGIFTUI_PREBUILT_OBJECTS=${object_list}" \
        "-DDTC=$(giftui_nrf_dtc)" -DUSE_CCACHE=0)
    record_command "${command[@]}"
    "${command[@]}" >/dev/null
    cp "${build}/zephyr/zephyr.elf" "${output}/${variant}"
    cp "${build}/zephyr/zephyr.map" "${output}/${variant}.map"
done

readelf="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf"
record_command "${readelf}" -A "${output}/candidate"
"${readelf}" -A "${output}/candidate" >"${output}/arm-attributes.txt"
grep -Fq 'Tag_CPU_arch: v7E-M' "${output}/arm-attributes.txt" || fail 'ELF lacks ARMv7E-M'
grep -Fq 'Tag_FP_arch: VFPv4-D16' "${output}/arm-attributes.txt" || fail 'ELF lacks VFPv4-D16'
grep -Fq 'Tag_ABI_VFP_args: VFP registers' "${output}/arm-attributes.txt" ||
    fail 'ELF lacks the hard-float VFP calling convention'

inspector="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-objdump"
sections="${output}/linked-section-deltas.tsv"
record_command "${SCRIPT_DIR}/report-spec-002-linked-sections.rb" elf "${inspector}" \
    "${output}/baseline" "${output}/candidate" \
    "${output}/baseline.map" "${output}/candidate.map" "${sections}"
"${SCRIPT_DIR}/report-spec-002-linked-sections.rb" elf "${inspector}" \
    "${output}/baseline" "${output}/candidate" \
    "${output}/baseline.map" "${output}/candidate.map" "${sections}" >/dev/null

nm="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-nm"
record_command "${nm}" --defined-only "${output}/candidate"
"${nm}" --defined-only "${output}/candidate" >"${output}/symbols.txt"

printf 'SPEC-008 nRF render evidence passed: linked hard-float Cortex-M4F ELF, zero optimized allocation instructions, finite workspace, sections, symbols, and link maps.\n'
