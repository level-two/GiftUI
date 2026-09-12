#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
PROBE="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC013/Instrumentation/StaticProfileCompileProbe.swift"

fail() {
    printf 'SPEC-013 Static profile check failed: %s\n' "$*" >&2
    exit 1
}

profile=""
output_root=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile)
            [[ $# -ge 2 ]] || fail '--profile requires a value'
            profile="$2"
            shift 2
            ;;
        --output)
            [[ $# -ge 2 ]] || fail '--output requires a value'
            output_root="$2"
            shift 2
            ;;
        *) fail "unknown option: $1" ;;
    esac
done
case "${profile}" in
    macos-static | nrf52840-embedded) ;;
    "") fail '--profile is required' ;;
    *) fail "unsupported profile: ${profile}" ;;
esac

temporary_root=""
if [[ -z "${output_root}" ]]; then
    temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/giftui-spec013-static.XXXXXX")"
    output_root="${temporary_root}"
fi
trap '[[ -z "${temporary_root}" ]] || rm -rf "${temporary_root}"' EXIT
mkdir -p "${output_root}" "${output_root}/module-cache"
output_root="$(cd "${output_root}" && pwd -P)"
: >"${output_root}/commands.txt"
export CLANG_MODULE_CACHE_PATH="${output_root}/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${output_root}/module-cache"

record_command() {
    printf '%q ' "$@" >>"${output_root}/commands.txt"
    printf '\n' >>"${output_root}/commands.txt"
}

run_command() {
    record_command "$@"
    "$@"
}

record_layouts() {
    local ir="$1"
    local report="${output_root}/value-layouts.tsv"
    printf '# value\tbytes\n' >"${report}"
    local name symbol body bytes
    while read -r name symbol; do
        body="$(sed -n "/define.*@${symbol}(/,/^}/p" "${ir}")"
        bytes="$(printf '%s\n' "${body}" | sed -n 's/.*ret i32 \([0-9][0-9]*\).*/\1/p' | head -1)"
        [[ -n "${bytes}" ]] || fail "optimized layout value is missing: ${name}"
        printf '%s\t%s\n' "${name}" "${bytes}" >>"${report}"
    done <<'LAYOUTS'
RuntimeProfileLimits giftui_spec013_layout_limits
RuntimeStorageAudit giftui_spec013_layout_audit
StaticStructuralIdentity giftui_spec013_layout_identity
StaticCanvasOccurrence giftui_spec013_layout_occurrence
LAYOUTS
}

if [[ "${profile}" == "macos-static" ]]; then
    command=(swift test --disable-sandbox
        --package-path "${PROJECT_ROOT}"
        --scratch-path "${output_root}/swiftpm"
        --cache-path "${PROJECT_ROOT}/.build"
        -Xswiftc -DGIFTUI_STATIC_PROFILE
        --filter GiftUIRuntimeStaticTests)
    run_command "${command[@]}" >/dev/null
    compiler="$(xcrun --find swiftc)"
    sdk="$(xcrun --sdk macosx --show-sdk-path)"
    ir="${output_root}/static-profile-layouts.ll"
    run_command "${compiler}" -target arm64-apple-macosx15.0 -sdk "${sdk}" \
        -O -whole-module-optimization -DGIFTUI_STATIC_PROFILE -language-mode 6 \
        -package-name giftui -parse-as-library \
        -I "${output_root}/swiftpm/arm64-apple-macosx/debug/Modules" \
        -emit-ir -module-name GiftUIRuntimeStaticProbe "${PROBE}" -o "${ir}"
    record_layouts "${ir}"
    printf 'profile\tmacos-static\nartifact\t%s\n' \
        "${output_root}/swiftpm/arm64-apple-macosx/debug/GiftUIPackageTests.xctest" \
        >"${output_root}/result.tsv"
    printf 'SPEC-013 macOS Static profile passed: production target compiled and test image linked.\n'
    exit 0
fi

# shellcheck source=../nrf52840/common.sh
source "${PROJECT_ROOT}/scripts/nrf52840/common.sh"
giftui_nrf_require_environment
giftui_nrf_export_environment

compiler="${GIFTUI_NRF_SWIFTC}"
module_dir="${output_root}/modules"
mkdir -p "${module_dir}"
flags=(
    -target "${GIFTUI_NRF_SWIFT_TARGET}"
    -enable-experimental-feature Embedded
    -Osize -whole-module-optimization -DGIFTUI_STATIC_PROFILE
    -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
    -Xcc -fshort-enums -Xcc -fno-pic -Xcc -fno-pie
    -Xfrontend -function-sections -Xfrontend -disable-stack-protector
    -language-mode 6 -package-name GiftUI -parse-as-library
)
objects=()
compile_module() {
    local name="$1"
    shift
    local object="${output_root}/${name}.o"
    local -a command=("${compiler}" "${flags[@]}" -I "${module_dir}"
        -emit-module -emit-object -module-name "${name}" "$@"
        -emit-module-path "${module_dir}/${name}.swiftmodule" -o "${object}")
    run_command "${command[@]}" >/dev/null
    objects+=("${object}")
}

compile_module GiftUI "${PROJECT_ROOT}"/Sources/GiftUI/*.swift
compile_module GiftUITextResources "${PROJECT_ROOT}"/Sources/GiftUITextResources/*.swift
compile_module GiftUISemanticCore "${PROJECT_ROOT}"/Sources/GiftUISemanticCore/*.swift
compile_module GiftUILayout "${PROJECT_ROOT}"/Sources/GiftUILayout/*.swift
compile_module GiftUIRenderCore "${PROJECT_ROOT}"/Sources/GiftUIRenderCore/*.swift
compile_module GiftUIExecution "${PROJECT_ROOT}"/Sources/GiftUIExecution/*.swift
compile_module GiftUIObservableState "${PROJECT_ROOT}"/Sources/GiftUIObservableState/*.swift
compile_module GiftUIInteraction "${PROJECT_ROOT}"/Sources/GiftUIInteraction/*.swift
compile_module GiftUIRenderLowering "${PROJECT_ROOT}"/Sources/GiftUIRenderLowering/*.swift
compile_module GiftUIDrawing "${PROJECT_ROOT}"/Sources/GiftUIDrawing/*.swift
compile_module GiftUIRuntimeCore "${PROJECT_ROOT}"/Sources/GiftUIRuntimeCore/*.swift
compile_module GiftUIRuntimeStatic "${PROJECT_ROOT}"/Sources/GiftUIRuntimeStatic/*.swift
compile_module GiftUIRuntimeStaticProbe "${PROBE}"
probe_ir="${output_root}/static-profile-layouts.ll"
run_command "${compiler}" "${flags[@]}" -I "${module_dir}" -emit-ir \
    -module-name GiftUIRuntimeStaticProbeIR "${PROBE}" -o "${probe_ir}"
record_layouts "${probe_ir}"

object_list="$(IFS=';'; printf '%s' "${objects[*]}")"
application="${PROJECT_ROOT}/firmware/nrf52840/applications/spec013-static-profile-probe"
build="${output_root}/zephyr"
command=("${GIFTUI_NRF_WEST}" build -p always -b "${GIFTUI_NRF_BOARD}"
    -d "${build}" "${application}" --
    "-DCMAKE_MAKE_PROGRAM=$(giftui_nrf_ninja)"
    "-DCMAKE_Swift_COMPILER=${compiler}"
    "-DGIFTUI_SWIFT_TARGET=${GIFTUI_NRF_SWIFT_TARGET}"
    "-DGIFTUI_MODULE_DIR=${module_dir}"
    "-DGIFTUI_PREBUILT_OBJECTS=${object_list}"
    "-DDTC=$(giftui_nrf_dtc)" -DUSE_CCACHE=0)
run_command "${command[@]}" >/dev/null

elf="${build}/zephyr/zephyr.elf"
readelf="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf"
run_command "${readelf}" -A "${elf}" >"${output_root}/arm-attributes.txt"
grep -Fq 'Tag_CPU_arch: v7E-M' "${output_root}/arm-attributes.txt" || fail 'ELF lacks ARMv7E-M'
grep -Fq 'Tag_FP_arch: VFPv4-D16' "${output_root}/arm-attributes.txt" || fail 'ELF lacks VFPv4-D16'
grep -Fq 'Tag_ABI_VFP_args: VFP registers' "${output_root}/arm-attributes.txt" ||
    fail 'ELF lacks hard-float calling convention'

nm="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-nm"
run_command "${nm}" "${elf}" >"${output_root}/symbols.txt"
grep -Fq 'giftui_spec013_static_profile_probe' "${output_root}/symbols.txt" ||
    fail 'linked image lacks Static profile probe entry'
printf 'profile\tnrf52840-embedded\ntarget\t%s\nboard\t%s\nartifact\t%s\n' \
    "${GIFTUI_NRF_SWIFT_TARGET}" "${GIFTUI_NRF_BOARD}" "${elf}" \
    >"${output_root}/result.tsv"
printf 'SPEC-013 nRF Static profile passed: production owner graph linked as Cortex-M4F hard-float.\n'
