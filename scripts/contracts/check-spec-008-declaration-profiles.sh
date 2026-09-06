#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC008"
SOURCES=(
    "${PROJECT_ROOT}/Sources/GiftUI/GiftUI.swift"
    "${PROJECT_ROOT}/Sources/GiftUI/DeclarativeView.swift"
    "${PROJECT_ROOT}/Sources/GiftUI/ObservableState.swift"
    "${PROJECT_ROOT}/Sources/GiftUI/Color.swift"
    "${PROJECT_ROOT}/Sources/GiftUI/BoundedText.swift"
    "${PROJECT_ROOT}/Sources/GiftUI/Text.swift"
    "${PROJECT_ROOT}/Sources/GiftUI/StyleModifiers.swift"
)
REGISTRIES=(
    "${FIXTURE_ROOT}/color-compile-fixtures.tsv"
    "${FIXTURE_ROOT}/bounded-text-compile-fixtures.tsv"
    "${FIXTURE_ROOT}/text-compile-fixtures.tsv"
    "${FIXTURE_ROOT}/style-compile-fixtures.tsv"
)

fail() {
    printf 'SPEC-008 declaration profile check failed: %s\n' "$*" >&2
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
    temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/giftui-spec008-declarations.XXXXXX")"
    output_root="${temporary_root}"
fi
trap '[[ -z "${temporary_root}" ]] || rm -rf "${temporary_root}"' EXIT
mkdir -p "${output_root}/modules" "${output_root}/fixtures" "${output_root}/module-cache"
commands_path="${output_root}/commands.txt"
results_path="${output_root}/results.tsv"
: >"${commands_path}"
printf '# id\texpectation\tresult\n' >"${results_path}"
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
module_dir="${output_root}/modules"
fixture_flags=()

case "${profile}" in
    macos-dynamic | macos-static)
        compiler="$(xcrun --find swiftc)"
        sdk="$(xcrun --sdk macosx --show-sdk-path)"
        profile_flag=-DGIFTUI_DYNAMIC_PROFILE
        extension=dylib
        if [[ "${profile}" == "macos-static" ]]; then
            profile_flag=-DGIFTUI_STATIC_PROFILE
            extension=a
        fi
        fixture_flags=(
            -target arm64-apple-macosx26.0 -sdk "${sdk}"
            -O -whole-module-optimization "${profile_flag}" -language-mode 6
        )
        module_command=("${compiler}" "${fixture_flags[@]}" -parse-as-library \
            -package-name GiftUI -emit-module -emit-library -module-name GiftUI \
            "${SOURCES[@]}")
        if [[ "${profile}" == "macos-static" ]]; then
            module_command+=(-static)
        fi
        module_command+=( \
            -emit-module-path "${module_dir}/GiftUI.swiftmodule" \
            -o "${output_root}/libGiftUI.${extension}")
        run_command "${module_command[@]}" >/dev/null
        ;;
    raspberry-pi-armv6)
        source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
        swift_driver="$(giftui_pi_host_swift)"
        compiler="$(dirname "${swift_driver}")/swiftc"
        giftui_pi_require_sdk
        giftui_pi_prepare_build_environment
        fixture_flags=(
            -target "${GIFTUI_PI_TARGET}"
            -sdk "${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}"
            -resource-dir "${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr/lib/swift_static"
            -Xcc "--gcc-toolchain=${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr"
            -Xcc -march=armv6 -Xcc -mfpu=vfp -Xcc -mfloat-abi=hard
            -Xcc -D_FILE_OFFSET_BITS=64 -Xcc -fPIC
            -DGIFTUI_DYNAMIC_PROFILE -language-mode 6
        )
        run_command "${compiler}" "${fixture_flags[@]}" \
            -O -whole-module-optimization -parse-as-library -package-name GiftUI \
            -emit-module -module-name GiftUI "${SOURCES[@]}" \
            -emit-module-path "${module_dir}/GiftUI.swiftmodule" >/dev/null
        ;;
    nrf52840-embedded)
        source "${PROJECT_ROOT}/scripts/nrf52840/common.sh"
        giftui_nrf_require_environment
        compiler="${GIFTUI_NRF_SWIFTC}"
        fixture_flags=(
            -target "${GIFTUI_NRF_SWIFT_TARGET}"
            -enable-experimental-feature Embedded
            -Osize -whole-module-optimization -DGIFTUI_STATIC_PROFILE
            -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
            -language-mode 6
        )
        run_command "${compiler}" "${fixture_flags[@]}" -parse-as-library \
            -package-name GiftUI -emit-module -module-name GiftUI "${SOURCES[@]}" \
            -emit-module-path "${module_dir}/GiftUI.swiftmodule" >/dev/null
        ;;
esac

fixture_count=0
for registry in "${REGISTRIES[@]}"; do
    while IFS=$'\t' read -r id expectation entry patterns; do
        [[ -n "${id}" && "${id}" != \#* ]] || continue
        fixture_count=$((fixture_count + 1))
        fixture_dir="${output_root}/fixtures/${id}"
        mkdir -p "${fixture_dir}"
        stdout_path="${fixture_dir}/stdout.txt"
        stderr_path="${fixture_dir}/stderr.txt"
        command=(
            "${compiler}" "${fixture_flags[@]}" -I "${module_dir}"
            -typecheck "${FIXTURE_ROOT}/${entry}"
        )
        record_command "${command[@]}"
        set +e
        "${command[@]}" >"${stdout_path}" 2>"${stderr_path}"
        result=$?
        set -e
        if [[ "${expectation}" == "pass" ]]; then
            [[ "${result}" -eq 0 ]] || {
                cat "${stderr_path}" >&2
                fail "positive fixture ${id} failed"
            }
        else
            [[ "${result}" -ne 0 ]] || fail "negative fixture ${id} unexpectedly compiled"
            while IFS= read -r pattern; do
                [[ -n "${pattern}" && "${pattern}" != \#* ]] || continue
                grep -Fq "${pattern}" "${stderr_path}" || {
                    cat "${stderr_path}" >&2
                    fail "negative fixture ${id} lacked diagnostic: ${pattern}"
                }
            done <"${FIXTURE_ROOT}/${patterns}"
        fi
        printf '%s\t%s\tpass\n' "${id}" "${expectation}" >>"${results_path}"
    done <"${registry}"
done

[[ "${fixture_count}" -eq 17 ]] || fail "expected 17 fixtures, found ${fixture_count}"
printf 'SPEC-008 %s declaration profiles passed: 17 positive/negative fixtures.\n' "${profile}"
