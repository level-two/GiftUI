#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC014"

fail() {
    printf 'SPEC-014 value profile check failed: %s\n' "$*" >&2
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
    temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/giftui-spec014-values.XXXXXX")"
    output_root="${temporary_root}"
fi
trap '[[ -z "${temporary_root}" ]] || rm -rf "${temporary_root}"' EXIT
mkdir -p \
    "${output_root}/modules" \
    "${output_root}/fixtures" \
    "${output_root}/module-cache"
commands_path="${output_root}/commands.txt"
results_path="${output_root}/compile-results.tsv"
identity_path="${output_root}/identity.tsv"
: >"${commands_path}"
printf '# case\texpectation\tresult\n' >"${results_path}"
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
target=""
optimization=""
flags=()
case "${profile}" in
    macos-dynamic | macos-static)
        compiler="$(xcrun --find swiftc)"
        sdk="$(xcrun --sdk macosx --show-sdk-path)"
        target="arm64-apple-macosx26.0"
        optimization="-O -whole-module-optimization"
        profile_flag=-DGIFTUI_DYNAMIC_PROFILE
        [[ "${profile}" != "macos-static" ]] || profile_flag=-DGIFTUI_STATIC_PROFILE
        flags=(
            -target "${target}" -sdk "${sdk}"
            -O -whole-module-optimization "${profile_flag}" -language-mode 6
        )
        ;;
    raspberry-pi-armv6)
        # shellcheck source=../raspberry-pi/common.sh
        source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
        swift_driver="$(giftui_pi_host_swift)"
        compiler="$(dirname "${swift_driver}")/swiftc"
        giftui_pi_require_sdk
        giftui_pi_prepare_build_environment
        target="${GIFTUI_PI_TARGET}"
        optimization="-O -whole-module-optimization"
        flags=(
            -target "${target}"
            -sdk "${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}"
            -resource-dir "${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr/lib/swift_static"
            -Xcc "--gcc-toolchain=${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr"
            -Xcc -march=armv6 -Xcc -mfpu=vfp -Xcc -mfloat-abi=hard
            -Xcc -D_FILE_OFFSET_BITS=64 -Xcc -fPIC
            -O -whole-module-optimization -DGIFTUI_DYNAMIC_PROFILE -language-mode 6
        )
        ;;
    nrf52840-embedded)
        # shellcheck source=../nrf52840/common.sh
        source "${PROJECT_ROOT}/scripts/nrf52840/common.sh"
        giftui_nrf_require_environment
        compiler="${GIFTUI_NRF_SWIFTC}"
        target="${GIFTUI_NRF_SWIFT_TARGET}"
        optimization="-Osize -whole-module-optimization"
        flags=(
            -target "${target}" -enable-experimental-feature Embedded
            -Osize -whole-module-optimization -DGIFTUI_STATIC_PROFILE
            -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
            -language-mode 6
        )
        ;;
esac

compiler_version="$("${compiler}" --version | tr '\n' ' ')"
printf 'profile\t%s\ncompiler\t%s\ncompiler_sha256\t%s\ncompiler_version\t%s\ntarget\t%s\noptimization\t%s\n' \
    "${profile}" "${compiler}" "$(shasum -a 256 "${compiler}" | awk '{print $1}')" \
    "${compiler_version}" "${target}" "${optimization}" >"${identity_path}"

run_command "${SCRIPT_DIR}/check-spec-014-storage.rb" >/dev/null

module_dir="${output_root}/modules"
module_flags=("${flags[@]}" -parse-as-library -package-name GiftUI -emit-module)
run_command "${compiler}" "${module_flags[@]}" -module-name GiftUI \
    "${PROJECT_ROOT}/Sources/GiftUI/GiftUI.swift" \
    "${PROJECT_ROOT}/Sources/GiftUI/Color.swift" \
    "${PROJECT_ROOT}/Sources/GiftUI/BoundedText.swift" \
    "${PROJECT_ROOT}/Sources/GiftUI/DrawingStyles.swift" \
    -emit-module-path "${module_dir}/GiftUI.swiftmodule" >/dev/null
run_command "${compiler}" "${module_flags[@]}" -module-name GiftUICapabilities \
    "${PROJECT_ROOT}/Sources/GiftUICapabilities/GiftUICapabilities.swift" \
    -emit-module-path "${module_dir}/GiftUICapabilities.swiftmodule" >/dev/null
run_command "${compiler}" "${module_flags[@]}" -module-name GiftUIFailureCore \
    "${PROJECT_ROOT}/Sources/GiftUIFailureCore/GiftUIFailureCore.swift" \
    -emit-module-path "${module_dir}/GiftUIFailureCore.swiftmodule" >/dev/null
run_command "${compiler}" "${module_flags[@]}" -I "${module_dir}" \
    -module-name GiftUITextResources \
    "${PROJECT_ROOT}/Sources/GiftUITextResources/GiftUITextResources.swift" \
    -emit-module-path "${module_dir}/GiftUITextResources.swiftmodule" >/dev/null
run_command "${compiler}" "${module_flags[@]}" -I "${module_dir}" \
    -module-name GiftUIRenderCore \
    "${PROJECT_ROOT}/Sources/GiftUIRenderCore/RenderValues.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRenderCore/RenderOperationSink.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRenderCore/DrawingOperationSink.swift" \
    -emit-module-path "${module_dir}/GiftUIRenderCore.swiftmodule" >/dev/null
run_command "${compiler}" "${module_flags[@]}" -I "${module_dir}" \
    -module-name GiftUIExecution \
    "${PROJECT_ROOT}/Sources/GiftUIExecution/ExecutionValues.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIExecution/FrameHandoffValues.swift" \
    -emit-module-path "${module_dir}/GiftUIExecution.swiftmodule" >/dev/null
run_command "${compiler}" "${module_flags[@]}" -I "${module_dir}" \
    -module-name GiftUISurfaceCore \
    "${PROJECT_ROOT}/Sources/GiftUISurfaceCore/SurfaceValues.swift" \
    "${PROJECT_ROOT}/Sources/GiftUISurfaceCore/RasterSurface.swift" \
    -emit-module-path "${module_dir}/GiftUISurfaceCore.swiftmodule" >/dev/null
run_command "${compiler}" "${module_flags[@]}" -I "${module_dir}" \
    -module-name GiftUIRasterCore \
    "${PROJECT_ROOT}/Sources/GiftUIRasterCore/RasterPayloadLimits.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRasterCore/RasterFrameSink.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRasterCore/RasterBackendContributionAdapter.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRasterCore/RasterFrameWork.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRasterCore/FullSurfaceRGBA8888Buffer.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRasterCore/FullSurfaceRGB565Framebuffer.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRasterCore/RasterFillCoverage.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRasterCore/RasterGlyphCoverage.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRasterCore/RasterStrokeCoverage.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIRasterCore/RasterWorkTracker.swift" \
    -emit-module-path "${module_dir}/GiftUIRasterCore.swiftmodule" >/dev/null
run_command "${compiler}" "${module_flags[@]}" -I "${module_dir}" \
    -module-name GiftUIDisplayCore \
    "${PROJECT_ROOT}/Sources/GiftUIDisplayCore/DisplayContracts.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIDisplayCore/SurfaceDisplayContributionAdapter.swift" \
    -emit-module-path "${module_dir}/GiftUIDisplayCore.swiftmodule" >/dev/null
run_command "${compiler}" "${module_flags[@]}" -I "${module_dir}" \
    -module-name GiftUIBackendIntegration \
    "${PROJECT_ROOT}/Sources/GiftUIBackendIntegration/RasterBackendEndpoint.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIBackendIntegration/FullSurfacePayloadEmitter.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIBackendIntegration/RasterBackendStartupValidator.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIBackendIntegration/RasterFrameWorkAdmission.swift" \
    "${PROJECT_ROOT}/Sources/GiftUIBackendIntegration/RasterTextResourceValidation.swift" \
    -emit-module-path "${module_dir}/GiftUIBackendIntegration.swiftmodule" >/dev/null

positive_source="${FIXTURE_ROOT}/Fixtures/Positive/compile-surface/main.swift"
run_command "${compiler}" "${flags[@]}" -package-name GiftUI -I "${module_dir}" \
    -typecheck "${positive_source}" >/dev/null
printf 'compile-surface\tpass\tpass\n' >>"${results_path}"

copy_module() {
    local name="$1"
    local destination="$2"
    local artifact
    for artifact in "${module_dir}/${name}.swiftmodule" \
        "${module_dir}/${name}.swiftdoc" \
        "${module_dir}/${name}.swiftsourceinfo"; do
        [[ ! -e "${artifact}" ]] || cp "${artifact}" "${destination}/"
    done
}

visibility_for() {
    case "$1" in
        GiftUI) printf '%s\n' GiftUI ;;
        GiftUISurfaceCore)
            printf '%s\n' GiftUI GiftUICapabilities GiftUITextResources GiftUIRenderCore GiftUISurfaceCore
            ;;
        GiftUIRasterCore)
            printf '%s\n' GiftUI GiftUICapabilities GiftUITextResources GiftUIRenderCore GiftUISurfaceCore GiftUIRasterCore
            ;;
        GiftUIDisplayCore)
            printf '%s\n' GiftUI GiftUICapabilities GiftUIFailureCore GiftUITextResources GiftUIRenderCore GiftUISurfaceCore GiftUIDisplayCore
            ;;
        GiftUIBackendIntegration)
            printf '%s\n' GiftUI GiftUICapabilities GiftUIFailureCore GiftUITextResources GiftUIRenderCore GiftUIExecution GiftUISurfaceCore GiftUIRasterCore GiftUIDisplayCore GiftUIBackendIntegration
            ;;
        *) fail "no visibility closure for $1" ;;
    esac
}

negative_count=0
while IFS=$'\t' read -r case_name from_module forbidden_module expected_diagnostic; do
    [[ -n "${case_name}" && "${case_name}" != \#* ]] || continue
    negative_count=$((negative_count + 1))
    fixture_dir="${output_root}/fixtures/${case_name}"
    visible_dir="${fixture_dir}/modules"
    mkdir -p "${visible_dir}"
    while IFS= read -r visible_module; do
        [[ "${visible_module}" != "${forbidden_module}" ]] || \
            fail "negative fixture ${case_name} includes forbidden module"
        copy_module "${visible_module}" "${visible_dir}"
    done < <(visibility_for "${from_module}")
    source="${FIXTURE_ROOT}/Fixtures/Negative/${case_name}/main.swift"
    command=("${compiler}" "${flags[@]}" -package-name GiftUI -I "${visible_dir}" -typecheck "${source}")
    record_command "${command[@]}"
    set +e
    "${command[@]}" >"${fixture_dir}/stdout.txt" 2>"${fixture_dir}/stderr.txt"
    result_code=$?
    set -e
    [[ "${result_code}" -ne 0 ]] || fail "negative fixture ${case_name} unexpectedly compiled"
    grep -Fq "${expected_diagnostic}" "${fixture_dir}/stderr.txt" || {
        cat "${fixture_dir}/stderr.txt" >&2
        fail "negative fixture ${case_name} lacked diagnostic: ${expected_diagnostic}"
    }
    printf '%s\tfail\tpass\n' "${case_name}" >>"${results_path}"
done <"${FIXTURE_ROOT}/declaration-compile-fixtures.tsv"
[[ "${negative_count}" -eq 5 ]] || fail "expected 5 negative fixtures, found ${negative_count}"

layout_ir="${output_root}/backend-value-layouts.ll"
layout_report="${output_root}/backend-value-layouts.tsv"
run_command "${compiler}" "${flags[@]}" -parse-as-library -package-name GiftUI \
    -I "${module_dir}" -emit-ir -module-name GiftUIBackendValueLayoutProbe \
    "${FIXTURE_ROOT}/Instrumentation/BackendValueLayoutProbe.swift" \
    -o "${layout_ir}" >/dev/null
run_command "${SCRIPT_DIR}/check-spec-014-value-layouts.rb" \
    "${layout_ir}" "${layout_report}" >/dev/null

printf 'SPEC-014 %s declarations passed: 8 layouts, 5 protocol conformers, 8 Sendable values, and 5 negative imports.\n' \
    "${profile}"
