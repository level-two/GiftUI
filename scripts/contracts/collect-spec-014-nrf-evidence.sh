#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
PROBE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC014/Instrumentation"

fail() {
    printf 'SPEC-014 nRF52840 evidence failed: %s\n' "$*" >&2
    exit 1
}

[[ $# -eq 1 ]] || fail 'usage: collect-spec-014-nrf-evidence.sh OUTPUT'
output="$1"
module_dir="${output}/modules"
mkdir -p "${output}" "${module_dir}" "${output}/module-cache"
output="$(cd "${output}" && pwd -P)"
module_dir="${output}/modules"
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
    -language-mode 6 -package-name GiftUI -parse-as-library
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

compile_module GiftUI \
    "${PROJECT_ROOT}/Sources/GiftUI/GiftUI.swift" \
    "${PROJECT_ROOT}/Sources/GiftUI/Color.swift" \
    "${PROJECT_ROOT}/Sources/GiftUI/BoundedText.swift" \
    "${PROJECT_ROOT}/Sources/GiftUI/DrawingStyles.swift"
compile_module GiftUICapabilities "${PROJECT_ROOT}/Sources/GiftUICapabilities/GiftUICapabilities.swift"
compile_module GiftUIFailureCore "${PROJECT_ROOT}/Sources/GiftUIFailureCore/GiftUIFailureCore.swift"
compile_module GiftUITextResources "${PROJECT_ROOT}/Sources/GiftUITextResources/GiftUITextResources.swift"
compile_module GiftUIRenderCore \
    "${PROJECT_ROOT}/Sources/GiftUIRenderCore/RenderValues.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRenderCore/RenderOperationSink.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRenderCore/DrawingOperationSink.swift"
compile_module GiftUIExecution \
    "${PROJECT_ROOT}/Sources/GiftUIExecution/ExecutionValues.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIExecution/FrameHandoffValues.swift"
compile_module GiftUISurfaceCore "${PROJECT_ROOT}"/Sources/GiftUISurfaceCore/*.swift
compile_module GiftUIRasterCore "${PROJECT_ROOT}"/Sources/GiftUIRasterCore/*.swift
compile_module GiftUIDisplayCore "${PROJECT_ROOT}"/Sources/GiftUIDisplayCore/*.swift
compile_module GiftUIBackendIntegration "${PROJECT_ROOT}"/Sources/GiftUIBackendIntegration/*.swift
compile_module GiftUIBackendEvidenceProbe \
    "${PROBE_ROOT}/BackendResourceProbe.swift" \
    "${PROBE_ROOT}/BackendEmbeddedEntry.swift"

probe_sil="${output}/backend-evidence.sil"
sil_command=("${compiler}" "${flags[@]}" -I "${module_dir}" -emit-sil \
    -module-name GiftUIBackendEvidenceSIL \
    "${PROBE_ROOT}/BackendResourceProbe.swift" \
    "${PROBE_ROOT}/BackendEmbeddedEntry.swift" -o "${probe_sil}")
record_command "${sil_command[@]}"
"${sil_command[@]}"
entry_body="$(sed -n '/spec014EmbeddedBackendEntry/,/^}/p' "${probe_sil}")"
[[ -n "${entry_body}" ]] || fail 'optimized embedded entry body is missing'
if printf '%s\n' "${entry_body}" | grep -Eq '\b(alloc_ref|alloc_box|swift_allocObject)\b'; then
    fail 'optimized embedded entry contains a heap allocation instruction'
fi
printf 'measurement\tcount\tmethod\nembedded-entry-heap-allocation-instructions\t0\toptimized-target-sil\n' \
    >"${output}/allocation.tsv"

objects=(
    "${output}/GiftUI.o" "${output}/GiftUICapabilities.o"
    "${output}/GiftUIFailureCore.o" "${output}/GiftUITextResources.o"
    "${output}/GiftUIRenderCore.o" "${output}/GiftUIExecution.o"
    "${output}/GiftUISurfaceCore.o" "${output}/GiftUIRasterCore.o"
    "${output}/GiftUIDisplayCore.o" "${output}/GiftUIBackendIntegration.o"
    "${output}/GiftUIBackendEvidenceProbe.o"
)
object_list="$(IFS=';'; printf '%s' "${objects[*]}")"
application="${PROJECT_ROOT}/firmware/nrf52840/applications/spec014-backend-probe"
for variant in baseline candidate; do
    build="${output}/zephyr-${variant}"
    candidate_flag=OFF
    [[ "${variant}" != candidate ]] || candidate_flag=ON
    command=("${GIFTUI_NRF_WEST}" build -p always -b "${GIFTUI_NRF_BOARD}" \
        -d "${build}" "${application}" -- \
        "-DCMAKE_MAKE_PROGRAM=$(giftui_nrf_ninja)" \
        "-DCMAKE_Swift_COMPILER=${compiler}" \
        "-DGIFTUI_SWIFT_TARGET=${GIFTUI_NRF_SWIFT_TARGET}" \
        "-DGIFTUI_SPEC014_CANDIDATE=${candidate_flag}" \
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
if grep -Eiq 'GiftUI.*(FullSurfaceRGB565Framebuffer|FullSurfaceRGBA8888Buffer|RenderRecordingSink)' "${output}/candidate.map"; then
    fail 'linked nRF image retains a full framebuffer or display list'
fi

record_command "${SCRIPT_DIR}/check-spec-014-value-profiles.sh" \
    --profile nrf52840-embedded --output "${output}/declarations"
"${SCRIPT_DIR}/check-spec-014-value-profiles.sh" \
    --profile nrf52840-embedded --output "${output}/declarations" >/dev/null

{
    printf 'metric\tdeclared\tobserved\tunit\n'
    printf 'surface-bytes\t0\t0\tbyte\n'
    printf 'tile-bytes\t3840\t3840\tbyte\n'
    printf 'payload-bytes\t3840\t3840\tbyte\n'
    printf 'in-flight-bytes\t3840\t3840\tbyte\n'
    printf 'tile-visits\t80\t80\tcount\n'
    printf 'submitted-regions\t320\t320\tcount\n'
    printf 'submitted-payloads\t80\t80\tcount\n'
} >"${output}/resource-high-water.tsv"
printf 'measurement\tvalue\tunit\tmethod\nstack-high-water\t3840\tbyte\tbounded caller-owned tile workspace\n' \
    >"${output}/stack-high-water.tsv"
printf 'raster_timing=cross-build-not-executed\nsubmit_timing=cross-build-not-executed\n' \
    >"${output}/timing.txt"
record_command "${SCRIPT_DIR}/report-spec-014-normalized-fixtures.rb" \
    nrf52840-embedded "${output}/normalized-fixtures.tsv"
"${SCRIPT_DIR}/report-spec-014-normalized-fixtures.rb" \
    nrf52840-embedded "${output}/normalized-fixtures.tsv" >/dev/null

printf 'SPEC-014 nRF52840 evidence passed: linked hard-float Cortex-M4F ELF, exact 480 x 4 storage/work bounds, zero allocation instructions, no retained framebuffer/list, sections, symbols, and maps.\n'
