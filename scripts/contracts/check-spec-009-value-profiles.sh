#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC009"

fail() {
    printf 'SPEC-009 value profile check failed: %s\n' "$*" >&2
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
    macos-dynamic | macos-static | raspberry-pi-armv6 | nrf52840-embedded) ;;
    "") fail '--profile is required' ;;
    *) fail "unknown profile: ${profile}" ;;
esac

temporary_root=""
if [[ -z "${output_root}" ]]; then
    temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/giftui-spec009-values.XXXXXX")"
    output_root="${temporary_root}"
fi
trap '[[ -z "${temporary_root}" ]] || rm -rf "${temporary_root}"' EXIT
mkdir -p "${output_root}/modules" "${output_root}/module-cache"
commands_path="${output_root}/commands.txt"
: >"${commands_path}"
export CLANG_MODULE_CACHE_PATH="${output_root}/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${output_root}/module-cache"

record_command() {
    printf '%q ' "$@" >>"${commands_path}"
    printf '\n' >>"${commands_path}"
}

run_command() {
    record_command "$@"
    "$@"
}

compiler=""
flags=()
case "${profile}" in
    macos-dynamic | macos-static)
        compiler="$(xcrun --find swiftc)"
        sdk="$(xcrun --sdk macosx --show-sdk-path)"
        profile_flag=-DGIFTUI_DYNAMIC_PROFILE
        [[ "${profile}" != "macos-static" ]] || profile_flag=-DGIFTUI_STATIC_PROFILE
        flags=(
            -target arm64-apple-macosx26.0 -sdk "${sdk}"
            -O -whole-module-optimization "${profile_flag}" -language-mode 6
        )
        ;;
    raspberry-pi-armv6)
        source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
        swift_driver="$(giftui_pi_host_swift)"
        compiler="$(dirname "${swift_driver}")/swiftc"
        giftui_pi_require_sdk
        giftui_pi_prepare_build_environment
        flags=(
            -target "${GIFTUI_PI_TARGET}"
            -sdk "${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}"
            -resource-dir "${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr/lib/swift_static"
            -Xcc "--gcc-toolchain=${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr"
            -Xcc -march=armv6 -Xcc -mfpu=vfp -Xcc -mfloat-abi=hard
            -Xcc -D_FILE_OFFSET_BITS=64 -Xcc -fPIC
            -O -whole-module-optimization -DGIFTUI_DYNAMIC_PROFILE -language-mode 6
        )
        ;;
    nrf52840-embedded)
        source "${PROJECT_ROOT}/scripts/nrf52840/common.sh"
        giftui_nrf_require_environment
        compiler="${GIFTUI_NRF_SWIFTC}"
        flags=(
            -target "${GIFTUI_NRF_SWIFT_TARGET}"
            -enable-experimental-feature Embedded
            -Osize -whole-module-optimization -DGIFTUI_STATIC_PROFILE
            -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
            -language-mode 6
        )
        ;;
esac

module_dir="${output_root}/modules"
common_module_flags=("${flags[@]}" -parse-as-library -package-name GiftUI -emit-module)
run_command "${compiler}" "${common_module_flags[@]}" -module-name GiftUI \
    "${PROJECT_ROOT}/Sources/GiftUI/GiftUI.swift" \
    "${PROJECT_ROOT}/Sources/GiftUI/Color.swift" \
    -emit-module-path "${module_dir}/GiftUI.swiftmodule" >/dev/null
run_command "${compiler}" "${common_module_flags[@]}" -I "${module_dir}" \
    -module-name GiftUITextResources \
    "${PROJECT_ROOT}/Sources/GiftUITextResources/GiftUITextResources.swift" \
    -emit-module-path "${module_dir}/GiftUITextResources.swiftmodule" >/dev/null
run_command "${compiler}" "${common_module_flags[@]}" -I "${module_dir}" \
    -module-name GiftUIRenderCore \
    "${PROJECT_ROOT}/Sources/GiftUIRenderCore/RenderValues.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRenderCore/RenderOperationSink.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRenderCore/RenderRecordingSink.swift" \
    -emit-module-path "${module_dir}/GiftUIRenderCore.swiftmodule" >/dev/null
run_command "${compiler}" "${common_module_flags[@]}" -I "${module_dir}" \
    -module-name GiftUIExecution \
    "${PROJECT_ROOT}/Sources/GiftUIExecution/ExecutionValues.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIExecution/WakeValues.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIExecution/FrameHandoffValues.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIExecution/AdmissionValues.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIExecution/RunCycleValues.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIExecution/IdentityAllocators.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIExecution/ExecutionPhaseMachine.swift" \
    -emit-module-path "${module_dir}/GiftUIExecution.swiftmodule" >/dev/null

layout_ir="${output_root}/execution-value-layouts.ll"
layout_report="${output_root}/execution-value-layouts.tsv"
run_command "${compiler}" "${flags[@]}" -parse-as-library -package-name GiftUI \
    -I "${module_dir}" -emit-ir -module-name GiftUIExecutionValueLayoutProbe \
    "${FIXTURE_ROOT}/Instrumentation/ExecutionValueLayoutProbe.swift" \
    "${FIXTURE_ROOT}/Instrumentation/ExecutionResourceProbe.swift" \
    -o "${layout_ir}" >/dev/null
run_command "${SCRIPT_DIR}/check-spec-009-value-layouts.rb" \
    "${layout_ir}" "${layout_report}" >/dev/null

printf 'SPEC-009 %s value profiles passed: complete module and 31 layouts.\n' "${profile}"
