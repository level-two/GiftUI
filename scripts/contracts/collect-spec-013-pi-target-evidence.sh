#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"

[[ $# -eq 1 ]] || {
    printf 'Usage: collect-spec-013-pi-target-evidence.sh OUTPUT-DIRECTORY\n' >&2
    exit 2
}
output_root="$1"
mkdir -p "${output_root}/modules" "${output_root}/module-cache"
output_root="$(cd "${output_root}" && pwd -P)"

# shellcheck source=../raspberry-pi/common.sh
source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
giftui_pi_require_sdk
giftui_pi_prepare_build_environment

swift_driver="$(giftui_pi_host_swift)"
compiler="$(dirname "${swift_driver}")/swiftc"
module_dir="${output_root}/modules"
flags=(
    -target "${GIFTUI_PI_TARGET}"
    -sdk "${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}"
    -resource-dir "${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr/lib/swift_static"
    -Xcc "--gcc-toolchain=${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr"
    -Xcc -march=armv6 -Xcc -mfpu=vfp -Xcc -mfloat-abi=hard
    -Xcc -D_FILE_OFFSET_BITS=64 -Xcc -fPIC
    -O -whole-module-optimization -DGIFTUI_DYNAMIC_PROFILE
    -language-mode 6 -package-name giftui -parse-as-library
)
export CLANG_MODULE_CACHE_PATH="${output_root}/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${output_root}/module-cache"

compile_module() {
    local name="$1"
    shift
    "${compiler}" "${flags[@]}" -I "${module_dir}" \
        -emit-module -emit-object -module-name "${name}" "$@" \
        -emit-module-path "${module_dir}/${name}.swiftmodule" \
        -o "${output_root}/${name}.o" >/dev/null
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
compile_module GiftUIRuntimeDynamic "${PROJECT_ROOT}"/Sources/GiftUIRuntimeDynamic/*.swift

"${compiler}" "${flags[@]}" -I "${module_dir}" -emit-ir \
    -module-name GiftUIRuntimeDynamicTargetProbe \
    "${PROJECT_ROOT}"/Sources/GiftUIRuntimeDynamic/*.swift \
    -o "${output_root}/runtime-dynamic.ll"
grep -Fxq 'target triple = "armv6-unknown-linux-gnueabihf"' \
    "${output_root}/runtime-dynamic.ll" || {
    printf 'SPEC-013 Pi target evidence failed: LLVM target triple differs\n' >&2
    exit 1
}

object="${output_root}/GiftUIRuntimeDynamic.o"
file "${object}" >"${output_root}/object-file.txt"
"${GIFTUI_PI_HOST_BIN_DIR}/llvm-objdump" -f "${object}" >"${output_root}/object-header.txt"
grep -Fq 'file format elf32-littlearm' "${output_root}/object-header.txt" || {
    printf 'SPEC-013 Pi target evidence failed: object is not 32-bit little-endian ARM ELF\n' >&2
    exit 1
}
if grep -Eiq 'armv7|aarch64' "${output_root}/runtime-dynamic.ll" \
    "${output_root}/object-file.txt" "${output_root}/object-header.txt"; then
    printf 'SPEC-013 Pi target evidence failed: ARMv7 or AArch64 substitution detected\n' >&2
    exit 1
fi
printf 'profile\traspberry-pi-armv6\ntarget\t%s\nartifact\t%s\n' \
    "${GIFTUI_PI_TARGET}" "${object}" >"${output_root}/result.tsv"
printf 'SPEC-013 Raspberry Pi target evidence passed: Runtime Dynamic is armv6-unknown-linux-gnueabihf ELF.\n'
