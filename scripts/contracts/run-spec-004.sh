#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC004"
SOURCE_ROOT="${PROJECT_ROOT}/Sources/GiftUICapabilities"
GENERATED_ROOT="${PROJECT_ROOT}/.build/contract-generated/spec-004"
REPORT_ROOT="${PROJECT_ROOT}/.build/contract-reports/spec-004"
EXPECTED_SOURCE="${SOURCE_ROOT}/GiftUICapabilities.swift"

usage() {
    printf '%s\n' \
        'Usage: scripts/contracts/run-spec-004.sh --profile <profile>' \
        '' \
        'Profiles:' \
        '  macos-dynamic' \
        '  macos-static' \
        '  raspberry-pi-armv6' \
        '  nrf52840-embedded'
}

fail() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

profile=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile)
            [[ $# -ge 2 ]] || fail '--profile requires a value'
            profile="$2"
            shift 2
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *) fail "unknown option: $1" ;;
    esac
done

case "${profile}" in
    macos-dynamic | macos-static | raspberry-pi-armv6 | nrf52840-embedded) ;;
    "") fail '--profile is required' ;;
    *) fail "unknown profile: ${profile}" ;;
esac

generated_dir="${GENERATED_ROOT}/${profile}"
report_dir="${REPORT_ROOT}/${profile}"
rm -rf "${generated_dir}" "${report_dir}"
mkdir -p \
    "${generated_dir}" \
    "${report_dir}/build/clang-cache" \
    "${report_dir}/build/swiftpm-cache" \
    "${report_dir}/fixtures" \
    "${report_dir}/semantics" \
    "${report_dir}/resources/baseline" \
    "${report_dir}/resources/candidate"

export CLANG_MODULE_CACHE_PATH="${report_dir}/build/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${report_dir}/build/swiftpm-cache"
metadata_path="${report_dir}/metadata.txt"
commands_path="${report_dir}/commands.txt"
inputs_path="${report_dir}/input-hashes.tsv"
images_path="${report_dir}/image-hashes.tsv"
log_path="${report_dir}/run.log"
: >"${commands_path}"
: >"${inputs_path}"
: >"${images_path}"
: >"${log_path}"

revision="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
if [[ -n "$(git -C "${PROJECT_ROOT}" status --porcelain --untracked-files=normal)" ]]; then
    dirty=true
else
    dirty=false
fi
{
    printf 'schema_version=1\n'
    printf 'spec=SPEC-004\n'
    printf 'profile=%s\n' "${profile}"
    printf 'repository_revision=%s\n' "${revision}"
    printf 'repository_dirty=%s\n' "${dirty}"
    printf 'generated_directory=.build/contract-generated/spec-004/%s\n' "${profile}"
    printf 'report_directory=.build/contract-reports/spec-004/%s\n' "${profile}"
    printf 'invocation=scripts/contracts/run-spec-004.sh --profile %s\n' "${profile}"
    printf 'remote_access=false\n'
    printf 'deployment=false\n'
    printf 'service_restart=false\n'
    printf 'flashing=false\n'
} >"${metadata_path}"

finish() {
    local result=$?
    printf 'exit_code=%s\n' "${result}" >>"${metadata_path}"
    if [[ "${result}" -eq 0 ]]; then
        printf 'SPEC-004 %s contract harness passed\n' "${profile}"
    else
        printf 'SPEC-004 %s contract harness failed; see %s\n' \
            "${profile}" "${report_dir}" >&2
    fi
}
trap finish EXIT

record_command() {
    printf '%q ' "$@" >>"${commands_path}"
    printf '\n' >>"${commands_path}"
}

record_block() {
    local key="$1"
    local value="$2"
    {
        printf '%s<<EOF\n' "${key}"
        printf '%s\n' "${value}"
        printf 'EOF\n'
    } >>"${metadata_path}"
}

require_exact_fragment() {
    local value="$1"
    local fragment="$2"
    local label="$3"
    [[ "${value}" == *"${fragment}"* ]] ||
        fail "${label} mismatch; expected ${fragment}, found ${value}"
}

hash_file() {
    shasum -a 256 "$1" | awk '{print $1}'
}

record_image() {
    local label="$1"
    local path="$2"
    [[ -f "${path}" ]] || fail "expected image is missing: ${path}"
    printf '%s\t%s\t%s\n' \
        "${label}" "${path#"${PROJECT_ROOT}/"}" "$(hash_file "${path}")" \
        >>"${images_path}"
}

verify_source_list() {
    local -a sources=()
    local source
    while IFS= read -r source; do
        sources+=("${source}")
    done < <(find "${SOURCE_ROOT}" -type f -name '*.swift' -print | LC_ALL=C sort)
    [[ "${#sources[@]}" -eq 1 ]] ||
        fail "expected one capability source, found ${#sources[@]}"
    [[ "${sources[0]}" == "${EXPECTED_SOURCE}" ]] ||
        fail "capability source list differs: ${sources[*]}"
    printf 'source_list=Sources/GiftUICapabilities/GiftUICapabilities.swift\n' \
        >>"${metadata_path}"
}

record_input_hashes() {
    local path relative
    while IFS= read -r path; do
        relative="${path#"${PROJECT_ROOT}/"}"
        printf '%s\t%s\n' "${relative}" "$(hash_file "${path}")" >>"${inputs_path}"
    done < <(
        {
            find "${SOURCE_ROOT}" "${FIXTURE_ROOT}" -type f -print
            printf '%s\n' \
                "${PROJECT_ROOT}/Package.swift" \
                "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/target-dependencies.yaml" \
                "${PROJECT_ROOT}/scripts/contracts/driver-registry.tsv" \
                "${PROJECT_ROOT}/scripts/contracts/run-spec-004.sh"
        } | LC_ALL=C sort -u
    )
}

record_compiler() {
    local compiler="$1"
    local version
    [[ -x "${compiler}" ]] || fail "compiler is not executable: ${compiler}"
    version="$("${compiler}" --version 2>&1)"
    printf 'compiler_path=%s\n' "${compiler}" >>"${metadata_path}"
    printf 'compiler_sha256=%s\n' "$(hash_file "${compiler}")" >>"${metadata_path}"
    record_block compiler_version "${version}"
}

run_fixture_set() {
    local compiler="$1"
    local module_dir="$2"
    shift 2
    local -a common_flags=("$@")
    local id expectation access entry patterns fixture_dir diagnostic output_path result pattern

    while IFS=$'\t' read -r id expectation access entry patterns; do
        [[ -n "${id}" && "${id}" != \#* ]] || continue
        fixture_dir="${report_dir}/fixtures/${id}"
        mkdir -p "${fixture_dir}"
        output_path="${fixture_dir}/stdout.txt"
        diagnostic="${fixture_dir}/stderr.txt"
        local -a command=("${compiler}" "${common_flags[@]}" -I "${module_dir}")
        if [[ "${access}" == "package" ]]; then
            command+=(-package-name GiftUI)
        fi
        command+=(-typecheck "${FIXTURE_ROOT}/${entry}")
        record_command "${command[@]}"
        set +e
        "${command[@]}" >"${output_path}" 2>"${diagnostic}"
        result=$?
        set -e

        if [[ "${expectation}" == "pass" ]]; then
            [[ "${result}" -eq 0 ]] || fail "positive fixture ${id} failed"
            continue
        fi
        [[ "${result}" -ne 0 ]] || fail "negative fixture ${id} unexpectedly compiled"
        while IFS= read -r pattern; do
            [[ -n "${pattern}" && "${pattern}" != \#* ]] || continue
            grep -Fq "${pattern}" "${diagnostic}" ||
                fail "negative fixture ${id} lacked diagnostic pattern: ${pattern}"
        done <"${FIXTURE_ROOT}/${patterns}"
    done <"${FIXTURE_ROOT}/fixture-manifest.tsv"
}

run_dependency_checks() {
    command -v swift >/dev/null || fail 'swift is missing'
    local package_json="${report_dir}/package.json"
    record_command swift package dump-package
    swift package dump-package >"${package_json}" 2>>"${log_path}"
    record_command "${SCRIPT_DIR}/check-target-dependencies.rb"
    "${SCRIPT_DIR}/check-target-dependencies.rb" \
        <"${package_json}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-004-dependencies.rb"
    "${SCRIPT_DIR}/check-spec-004-dependencies.rb" \
        <"${package_json}" >>"${log_path}" 2>&1

    local regression_log="${report_dir}/dependency-regressions.log"
    set +e
    "${SCRIPT_DIR}/check-target-dependencies.rb" \
        "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/DependencyGraphCases/unknown-edge.yaml" \
        <"${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/DependencyGraphCases/two-target-package.json" \
        >"${regression_log}" 2>&1
    local unknown_result=$?
    "${SCRIPT_DIR}/check-target-dependencies.rb" \
        "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/DependencyGraphCases/cycle.yaml" \
        <"${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/DependencyGraphCases/cyclic-package.json" \
        >>"${regression_log}" 2>&1
    local cycle_result=$?
    set -e
    [[ "${unknown_result}" -ne 0 ]] || fail 'unknown dependency regression unexpectedly passed'
    [[ "${cycle_result}" -ne 0 ]] || fail 'dependency cycle regression unexpectedly passed'
    grep -Fq 'unknown dependencies' "${regression_log}" ||
        fail 'unknown dependency regression lacked its expected failure'
    grep -Fq 'cycle detected' "${regression_log}" ||
        fail 'dependency cycle regression lacked its expected failure'
}

run_portable_source_checks() {
    record_command "${SCRIPT_DIR}/check-spec-004-portable-source.rb"
    "${SCRIPT_DIR}/check-spec-004-portable-source.rb" >>"${log_path}" 2>&1

    local regression_log="${report_dir}/portable-source-regression.log"
    local regression_source="${FIXTURE_ROOT}/PortableSourceCases/forbidden-device-identity.swift"
    set +e
    "${SCRIPT_DIR}/check-spec-004-portable-source.rb" \
        "${regression_source}" >"${regression_log}" 2>&1
    local result=$?
    set -e
    [[ "${result}" -ne 0 ]] || fail 'portable identity regression unexpectedly passed'
    grep -Fq 'concrete identity token device' "${regression_log}" ||
        fail 'portable identity regression lacked its expected failure'
}

run_macos() {
    [[ "$(uname -s)" == "Darwin" ]] || fail 'macOS profile requires macOS'
    [[ "$(uname -m)" == "arm64" ]] || fail 'macOS evidence requires an arm64 host'
    command -v xcrun >/dev/null || fail 'xcrun is missing'

    local compiler compiler_version sdk_path sdk_version profile_flag extension image
    local giftui_dir giftui_module dependency_scan product_links
    compiler="$(xcrun --find swiftc)"
    compiler_version="$("${compiler}" --version 2>&1)"
    require_exact_fragment "${compiler_version}" 'Apple Swift version 6.3.3' 'macOS compiler'
    require_exact_fragment "${compiler_version}" 'swiftlang-6.3.3.1.3' 'macOS compiler build'
    sdk_path="$(xcrun --sdk macosx --show-sdk-path)"
    sdk_version="$(xcrun --sdk macosx --show-sdk-version)"
    [[ -d "${sdk_path}" ]] || fail "macOS SDK is missing: ${sdk_path}"

    if [[ "${profile}" == "macos-dynamic" ]]; then
        profile_flag='-DGIFTUI_DYNAMIC_PROFILE'
        extension='dylib'
    else
        profile_flag='-DGIFTUI_STATIC_PROFILE'
        extension='a'
    fi
    image="${report_dir}/resources/candidate/libGiftUICapabilities.${extension}"
    local -a command=(
        "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -O -whole-module-optimization "${profile_flag}"
        -language-mode 6 -parse-as-library -module-name GiftUICapabilities
        -enable-library-evolution -emit-library -emit-module
        -emit-module-path "${report_dir}/build/GiftUICapabilities.swiftmodule"
        -emit-module-interface-path "${report_dir}/build/GiftUICapabilities.swiftinterface"
    )
    if [[ "${profile}" == "macos-static" ]]; then
        command+=(-static)
    fi
    command+=("${EXPECTED_SOURCE}" -o "${image}")

    record_compiler "${compiler}"
    printf 'target=arm64-apple-macosx26.0\n' >>"${metadata_path}"
    printf 'sdk_path=%s\n' "${sdk_path}" >>"${metadata_path}"
    printf 'sdk_version=%s\n' "${sdk_version}" >>"${metadata_path}"
    printf 'optimization=-O -whole-module-optimization\n' >>"${metadata_path}"
    printf 'profile_flag=%s\n' "${profile_flag}" >>"${metadata_path}"
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    record_image candidate-module "${report_dir}/build/GiftUICapabilities.swiftmodule"
    record_image candidate-library "${image}"

    dependency_scan="${report_dir}/build/GiftUICapabilities.dependencies.json"
    local -a scan_command=(
        "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -O -whole-module-optimization "${profile_flag}"
        -language-mode 6 -module-name GiftUICapabilities
        -module-cache-path "${report_dir}/build/clang-cache"
        -scan-dependencies "${EXPECTED_SOURCE}"
    )
    record_command "${scan_command[@]}"
    "${scan_command[@]}" >"${dependency_scan}" 2>>"${log_path}"

    giftui_dir="${report_dir}/build/giftui"
    mkdir -p "${giftui_dir}"
    giftui_module="${giftui_dir}/GiftUI.swiftmodule"
    local -a giftui_command=(
        "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -O -whole-module-optimization "${profile_flag}"
        -language-mode 6 -package-name GiftUI -enable-library-evolution
        -parse-as-library -emit-module -module-name GiftUI
        "${PROJECT_ROOT}/Sources/GiftUI/GiftUI.swift"
        -emit-module-path "${giftui_module}"
        -emit-module-interface-path "${giftui_dir}/GiftUI.swiftinterface"
        -emit-package-module-interface-path "${giftui_dir}/GiftUI.package.swiftinterface"
    )
    record_command "${giftui_command[@]}"
    "${giftui_command[@]}" >>"${log_path}" 2>&1
    record_image giftui-module "${giftui_module}"

    product_links="${report_dir}/build/product-links.txt"
    record_command otool -L "${image}"
    otool -L "${image}" >"${product_links}"
    record_command "${SCRIPT_DIR}/check-spec-004-boundary.rb" \
        "${report_dir}/build/GiftUICapabilities.swiftinterface" \
        "${product_links}" "${dependency_scan}" \
        "${giftui_dir}/GiftUI.swiftinterface" \
        "${giftui_dir}/GiftUI.package.swiftinterface"
    "${SCRIPT_DIR}/check-spec-004-boundary.rb" \
        "${report_dir}/build/GiftUICapabilities.swiftinterface" \
        "${product_links}" "${dependency_scan}" \
        "${giftui_dir}/GiftUI.swiftinterface" \
        "${giftui_dir}/GiftUI.package.swiftinterface" \
        >>"${log_path}" 2>&1
    run_fixture_set "${compiler}" "${report_dir}/build" \
        -target arm64-apple-macosx26.0 -sdk "${sdk_path}" \
        -O -whole-module-optimization "${profile_flag}"
}

run_raspberry_pi() {
    # shellcheck source=../raspberry-pi/common.sh
    source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
    local swift_driver compiler compiler_version sdk_identity module
    swift_driver="$(giftui_pi_host_swift)"
    compiler="$(dirname "${swift_driver}")/swiftc"
    [[ -x "${swift_driver}" && -x "${compiler}" ]] ||
        fail 'pinned Raspberry Pi Swift compiler is missing; run scripts/raspberry-pi/setup-toolchain.sh'
    giftui_pi_require_sdk
    record_command "${PROJECT_ROOT}/scripts/raspberry-pi/doctor.sh"
    "${PROJECT_ROOT}/scripts/raspberry-pi/doctor.sh" >>"${log_path}" 2>&1
    compiler_version="$("${compiler}" --version 2>&1)"
    require_exact_fragment "${compiler_version}" "Swift version ${GIFTUI_PI_SWIFT_VERSION}" 'Raspberry Pi compiler'
    grep -Fq "\"target\":\"${GIFTUI_PI_TARGET}\"" "${GIFTUI_PI_STATIC_DESTINATION}" ||
        fail 'Raspberry Pi destination target does not match its pin'
    sdk_identity="$(<"${GIFTUI_PI_SDK_DIR}/.giftui-install")"

    record_compiler "${compiler}"
    record_block sdk_identity "${sdk_identity}"
    printf 'target=%s\n' "${GIFTUI_PI_TARGET}" >>"${metadata_path}"
    printf 'sdk_path=%s\n' "${GIFTUI_PI_SDK_DIR}" >>"${metadata_path}"
    printf 'destination=%s\n' "${GIFTUI_PI_STATIC_DESTINATION}" >>"${metadata_path}"
    printf 'optimization=-O -whole-module-optimization\n' >>"${metadata_path}"

    giftui_pi_prepare_build_environment
    local -a command=(
        "${swift_driver}" build --package-path "${PROJECT_ROOT}"
        --scratch-path "${report_dir}/build/swiftpm"
        --destination "${GIFTUI_PI_STATIC_DESTINATION}"
        --configuration release --product GiftUICapabilities --static-swift-stdlib
        -Xswiftc -whole-module-optimization
    )
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    local -a modules=()
    while IFS= read -r module; do
        modules+=("${module}")
    done < <(find "${report_dir}/build/swiftpm" -type f -name 'GiftUICapabilities.swiftmodule' -print)
    [[ "${#modules[@]}" -eq 1 ]] ||
        fail "expected one ARMv6 capability module, found ${#modules[@]}"
    record_image candidate-module "${modules[0]}"
}

run_nrf52840() {
    # shellcheck source=../nrf52840/common.sh
    source "${PROJECT_ROOT}/scripts/nrf52840/common.sh"
    giftui_nrf_require_environment
    record_command "${PROJECT_ROOT}/scripts/nrf52840/doctor.sh"
    "${PROJECT_ROOT}/scripts/nrf52840/doctor.sh" >>"${log_path}" 2>&1
    local compiler_version module
    compiler_version="$("${GIFTUI_NRF_SWIFTC}" --version 2>&1)"
    require_exact_fragment "${compiler_version}" "Swift version ${GIFTUI_NRF_SWIFT_VERSION}" 'nRF compiler'
    [[ "$(giftui_nrf_git_revision "${GIFTUI_NRF_ZEPHYR_BASE}")" == "${GIFTUI_NRF_ZEPHYR_REVISION}" ]] ||
        fail 'Zephyr revision does not match its pin'

    record_compiler "${GIFTUI_NRF_SWIFTC}"
    printf 'target=%s\n' "${GIFTUI_NRF_SWIFT_TARGET}" >>"${metadata_path}"
    printf 'board=%s\n' "${GIFTUI_NRF_BOARD}" >>"${metadata_path}"
    printf 'zephyr_version=%s\n' "${GIFTUI_NRF_ZEPHYR_VERSION}" >>"${metadata_path}"
    printf 'zephyr_revision=%s\n' "${GIFTUI_NRF_ZEPHYR_REVISION}" >>"${metadata_path}"
    printf 'zephyr_sdk_version=%s\n' "${GIFTUI_NRF_ZEPHYR_SDK_VERSION}" >>"${metadata_path}"
    printf 'sdk_path=%s\n' "${GIFTUI_NRF_SDK_DIR}" >>"${metadata_path}"
    printf 'optimization=-Osize -whole-module-optimization\n' >>"${metadata_path}"
    printf 'embedded_swift=-enable-experimental-feature Embedded\n' >>"${metadata_path}"
    printf 'float_abi=hard\n' >>"${metadata_path}"

    module="${report_dir}/build/GiftUICapabilities.swiftmodule"
    local -a command=(
        "${GIFTUI_NRF_SWIFTC}" -target "${GIFTUI_NRF_SWIFT_TARGET}"
        -enable-experimental-feature Embedded
        -Osize -whole-module-optimization
        -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
        -parse-as-library -emit-module -module-name GiftUICapabilities
        "${EXPECTED_SOURCE}" -emit-module-path "${module}"
    )
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    record_image candidate-module "${module}"
    run_fixture_set "${GIFTUI_NRF_SWIFTC}" "${report_dir}/build" \
        -target "${GIFTUI_NRF_SWIFT_TARGET}" \
        -enable-experimental-feature Embedded \
        -Osize -whole-module-optimization \
        -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
}

verify_source_list
record_input_hashes
record_command "${SCRIPT_DIR}/check-spec-004-fixture-manifest.rb"
"${SCRIPT_DIR}/check-spec-004-fixture-manifest.rb" >>"${log_path}" 2>&1
run_dependency_checks
run_portable_source_checks

case "${profile}" in
    macos-dynamic | macos-static) run_macos ;;
    raspberry-pi-armv6) run_raspberry_pi ;;
    nrf52840-embedded) run_nrf52840 ;;
esac
