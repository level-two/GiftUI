#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC003"
SOURCE_ROOT="${PROJECT_ROOT}/Sources/GiftUIFailureCore"
DIAGNOSTICS_ROOT="${PROJECT_ROOT}/Sources/GiftUIFailureDiagnostics"
CAPABILITY_SOURCE="${PROJECT_ROOT}/Sources/GiftUICapabilities/GiftUICapabilities.swift"
CAPABILITY_ADAPTER_SOURCE="${PROJECT_ROOT}/Sources/GiftUICapabilityFailureAdapterFixture/CapabilityFailureAdapter.swift"
PROFILE_PROBE_ROOT="${FIXTURE_ROOT}/ProfileCorpusProbe"
GENERATED_ROOT="${PROJECT_ROOT}/.build/contract-generated/spec-003"
REPORT_ROOT="${PROJECT_ROOT}/.build/contract-reports/spec-003"
# shellcheck source=report-path.sh
source "${SCRIPT_DIR}/report-path.sh"

usage() {
    printf '%s\n' \
        'Usage: scripts/contracts/run-spec-003.sh --profile <profile>' \
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

if [[ "${GIFTUI_IMMUTABLE_REPORT_INNER:-false}" != true ]]; then
    exec "${SCRIPT_DIR}/run-immutable-contract-driver.sh" \
        --spec SPEC-003 --profile "${profile}" --driver "$0"
fi
generated_dir="${GENERATED_ROOT}/${profile}"
report_dir="${GIFTUI_CONTRACT_REPORT_DIR:-"${REPORT_ROOT}/${profile}"}"
rm -rf "${generated_dir}" "${report_dir}"
mkdir -p \
    "${generated_dir}" \
    "${report_dir}/build/clang-cache" \
    "${report_dir}/build/swiftpm-cache" \
    "${report_dir}/fixtures" \
    "${report_dir}/semantics" \
    "${report_dir}/resources/build-1/baseline" \
    "${report_dir}/resources/build-1/candidate" \
    "${report_dir}/resources/build-2/baseline" \
    "${report_dir}/resources/build-2/candidate"

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
    printf 'spec=SPEC-003\n'
    printf 'profile=%s\n' "${profile}"
    printf 'repository_revision=%s\n' "${revision}"
    printf 'repository_dirty=%s\n' "${dirty}"
    printf 'generated_directory=.build/contract-generated/spec-003/%s\n' "${profile}"
    printf 'report_directory=.build/contract-reports/spec-003/%s\n' "${profile}"
    printf 'invocation=scripts/contracts/run-spec-003.sh --profile %s\n' "${profile}"
    printf 'remote_access=false\n'
    printf 'deployment=false\n'
    printf 'service_restart=false\n'
    printf 'flashing=false\n'
} >"${metadata_path}"

finish() {
    local result=$?
    printf 'exit_code=%s\n' "${result}" >>"${metadata_path}"
    if [[ "${result}" -eq 0 ]]; then
        printf 'SPEC-003 %s contract harness passed\n' "${profile}"
    else
        printf 'SPEC-003 %s contract harness failed; see %s\n' \
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

record_input_hashes() {
    local path relative
    while IFS= read -r path; do
        relative="${path#"${PROJECT_ROOT}/"}"
        printf '%s\t%s\n' "${relative}" "$(hash_file "${path}")" >>"${inputs_path}"
    done < <(
        {
            find "${SOURCE_ROOT}" "${FIXTURE_ROOT}" -type f -print
            printf '%s\n' \
                "${CAPABILITY_SOURCE}" \
                "${CAPABILITY_ADAPTER_SOURCE}" \
                "${SCRIPT_DIR}/run-spec-003.sh" \
                "${SCRIPT_DIR}/normalize-spec-003-semantic-suite.rb" \
                "${SCRIPT_DIR}/check-spec-003-layout.rb"
        } | LC_ALL=C sort
    )
}

compile_macos_capability_adapter() {
    local compiler="$1"
    local sdk_path="$2"
    local profile_flag="$3"
    local adapter_dir="${report_dir}/build/capability-adapter"
    local capability_module="${adapter_dir}/GiftUICapabilities.swiftmodule"
    local adapter_module="${adapter_dir}/GiftUICapabilityFailureAdapterFixture.swiftmodule"
    mkdir -p "${adapter_dir}"

    local -a capability_command=(
        "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -O -whole-module-optimization "${profile_flag}" -language-mode 6
        -parse-as-library -emit-module -module-name GiftUICapabilities
        "${CAPABILITY_SOURCE}" -emit-module-path "${capability_module}"
    )
    record_command "${capability_command[@]}"
    "${capability_command[@]}" >>"${log_path}" 2>&1

    local -a adapter_command=(
        "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -O -whole-module-optimization "${profile_flag}" -language-mode 6
        -I "${report_dir}/build" -I "${adapter_dir}"
        -parse-as-library -emit-module
        -module-name GiftUICapabilityFailureAdapterFixture
        "${CAPABILITY_ADAPTER_SOURCE}" -emit-module-path "${adapter_module}"
    )
    record_command "${adapter_command[@]}"
    "${adapter_command[@]}" >>"${log_path}" 2>&1
    record_image capability-adapter-module "${adapter_module}"
}

run_profile_corpus_probe_macos() {
    local compiler="$1"
    local sdk_path="$2"
    local profile_flag="$3"
    local image="$4"
    local probe_dir="${report_dir}/build/profile-corpus-probe"
    local probe="${probe_dir}/profile-corpus-probe"
    local output="${report_dir}/semantics/profile-corpus.txt"
    mkdir -p "${probe_dir}"

    local -a command=(
        "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -O -whole-module-optimization "${profile_flag}" -language-mode 6
        -module-name GiftUIFailureProfileCorpusProbe
        -I "${report_dir}/build"
        -L "$(dirname "${image}")" -lGiftUIFailureCore
        -Xlinker -rpath -Xlinker "$(dirname "${image}")"
        "${PROFILE_PROBE_ROOT}/ProfileCorpusProbe.swift"
        "${PROFILE_PROBE_ROOT}/main.swift"
        -o "${probe}"
    )
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    record_command "${probe}"
    "${probe}" >"${output}" 2>>"${log_path}"
    grep -Fxq 'profile_corpus_checksum=69' "${output}" ||
        fail 'profile corpus probe did not produce its expected checksum'
    record_image profile-corpus-probe "${probe}"
}

run_complete_semantic_suite_macos() {
    local compiler="$1"
    local profile_flag="$2"
    local capacity_flag="$3"
    local swift_driver
    local suite_dir="${report_dir}/build/complete-semantic-suite"
    local raw_output="${report_dir}/semantics/complete-suite.raw.txt"
    local transcript="${report_dir}/semantics/complete-suite.tsv"
    local comparison="${report_dir}/semantics/static-dynamic-comparison.txt"
    local counterpart_profile counterpart_dir
    swift_driver="$(dirname "${compiler}")/swift"
    [[ -x "${swift_driver}" ]] || fail "Swift package driver is missing: ${swift_driver}"

    local filter='GiftUIFailureCoreTests|GiftUIFailureDiagnosticsTests|GiftUIFoundationFailureAdapterTests|GiftUICapabilityFailureAdapterTests'
    local -a command=(
        "${swift_driver}" test --package-path "${PROJECT_ROOT}"
        --scratch-path "${suite_dir}"
        --configuration release
        -Xswiftc -whole-module-optimization
        -Xswiftc "${profile_flag}"
        -Xswiftc "${capacity_flag}"
        --filter "${filter}"
    )
    record_command "${command[@]}"
    "${command[@]}" >"${raw_output}" 2>&1
    record_command "${SCRIPT_DIR}/normalize-spec-003-semantic-suite.rb" \
        "${raw_output}" "${transcript}"
    "${SCRIPT_DIR}/normalize-spec-003-semantic-suite.rb" \
        "${raw_output}" "${transcript}" >>"${log_path}" 2>&1

    if [[ "${profile}" == "macos-dynamic" ]]; then
        counterpart_profile='macos-static'
    else
        counterpart_profile='macos-dynamic'
    fi
    counterpart_dir="$(giftui_contract_profile_report "${REPORT_ROOT}" "${counterpart_profile}" || true)"
    if [[ -f "${counterpart_dir}/semantics/complete-suite.tsv" ]] && \
        cmp -s "${inputs_path}" "${counterpart_dir}/input-hashes.tsv"; then
        record_command cmp "${transcript}" \
            "${counterpart_dir}/semantics/complete-suite.tsv"
        cmp "${transcript}" "${counterpart_dir}/semantics/complete-suite.tsv" ||
            fail "portable semantic transcript differs from ${counterpart_profile}"
        printf 'result=passed\ncounterpart=%s\n' "${counterpart_profile}" >"${comparison}"
    else
        printf 'result=awaiting-matched-counterpart\ncounterpart=%s\n' \
            "${counterpart_profile}" >"${comparison}"
    fi
}

run_layout_probe() {
    local compiler="$1"
    local _existing_core_module_dir="$2"
    local capacity_flag="$3"
    shift 3
    local -a common_flags=("$@")
    local core_ir="${report_dir}/semantics/core-layout.ll"
    local diagnostics_ir="${report_dir}/semantics/diagnostics-layout.ll"
    local layout_report="${report_dir}/semantics/layout.tsv"
    local layout_module_dir="${report_dir}/build/layout-probe"
    local core_module="${layout_module_dir}/GiftUIFailureCore.swiftmodule"
    mkdir -p "${layout_module_dir}"
    local -a core_module_command=(
        "${compiler}" "${common_flags[@]}" -package-name GiftUI
        -parse-as-library -emit-module -module-name GiftUIFailureCore
        "${SOURCE_ROOT}/GiftUIFailureCore.swift" -emit-module-path "${core_module}"
    )
    record_command "${core_module_command[@]}"
    "${core_module_command[@]}" >>"${log_path}" 2>&1
    local -a core_command=(
        "${compiler}" "${common_flags[@]}" -package-name GiftUI
        -parse-as-library -emit-ir -module-name GiftUIFailureCoreLayoutProbe
        "${SOURCE_ROOT}/GiftUIFailureCore.swift"
        "${FIXTURE_ROOT}/Instrumentation/CoreLayoutProbe.swift"
        -o "${core_ir}"
    )
    record_command "${core_command[@]}"
    "${core_command[@]}" >>"${log_path}" 2>&1

    local -a diagnostics_command=(
        "${compiler}" "${common_flags[@]}" "${capacity_flag}"
        -I "${layout_module_dir}" -package-name GiftUI
        -parse-as-library -emit-ir -module-name GiftUIFailureDiagnosticsLayoutProbe
        "${DIAGNOSTICS_ROOT}/GiftUIDiagnosticProjector.swift"
        "${DIAGNOSTICS_ROOT}/GiftUIFixedDiagnosticBuffer.swift"
        "${FIXTURE_ROOT}/Instrumentation/DiagnosticsLayoutProbe.swift"
        -o "${diagnostics_ir}"
    )
    record_command "${diagnostics_command[@]}"
    "${diagnostics_command[@]}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-003-layout.rb" \
        "${core_ir}" "${diagnostics_ir}" "${layout_report}" "${profile}"
    "${SCRIPT_DIR}/check-spec-003-layout.rb" \
        "${core_ir}" "${diagnostics_ir}" "${layout_report}" "${profile}" \
        >>"${log_path}" 2>&1
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

record_image() {
    local label="$1"
    local path="$2"
    [[ -f "${path}" ]] || fail "expected image is missing: ${path}"
    printf '%s\t%s\t%s\n' "${label}" "${path#"${PROJECT_ROOT}/"}" "$(hash_file "${path}")" >>"${images_path}"
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
    "${SCRIPT_DIR}/check-target-dependencies.rb" <"${package_json}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-003-dependencies.rb"
    "${SCRIPT_DIR}/check-spec-003-dependencies.rb" <"${package_json}" >>"${log_path}" 2>&1

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

run_allocation_probe() {
    local compiler="$1"
    local sdk_path="$2"
    local profile_flag="$3"
    local probe_dir="${report_dir}/build/allocation-probe"
    local clang interposer core_library probe output
    mkdir -p "${probe_dir}"
    clang="$(xcrun --find clang)"
    [[ -x "${clang}" ]] || fail 'clang is missing for allocation instrumentation'
    interposer="${probe_dir}/libGiftUIAllocationInterposer.dylib"
    if [[ "${profile}" == "macos-static" ]]; then
        core_library="${probe_dir}/libGiftUIFailureCore.a"
    else
        core_library="${probe_dir}/libGiftUIFailureCore.dylib"
    fi
    probe="${probe_dir}/allocation-probe"
    output="${report_dir}/semantics/allocation-probe.txt"

    local -a interposer_command=(
        "${clang}" -target arm64-apple-macosx26.0 -isysroot "${sdk_path}"
        -O2 -dynamiclib
        "${FIXTURE_ROOT}/Instrumentation/AllocationInterposer.c"
        -install_name @rpath/libGiftUIAllocationInterposer.dylib
        -o "${interposer}"
    )
    record_command "${interposer_command[@]}"
    "${interposer_command[@]}" >>"${log_path}" 2>&1

    local -a core_command=(
        "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -O -whole-module-optimization "${profile_flag}"
        -language-mode 6 -parse-as-library -enable-testing
        -module-name GiftUIFailureCore -emit-library -emit-module
        -emit-module-path "${probe_dir}/GiftUIFailureCore.swiftmodule"
    )
    if [[ "${profile}" == "macos-static" ]]; then
        core_command+=(-static)
    fi
    core_command+=("${SOURCE_ROOT}/GiftUIFailureCore.swift" -o "${core_library}")
    record_command "${core_command[@]}"
    "${core_command[@]}" >>"${log_path}" 2>&1

    local -a probe_command=(
        "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -O -whole-module-optimization "${profile_flag}" -language-mode 6
        -I "${probe_dir}" -L "${probe_dir}"
        -lGiftUIFailureCore -lGiftUIAllocationInterposer
        -Xlinker -rpath -Xlinker "${probe_dir}"
        "${FIXTURE_ROOT}/Instrumentation/AllocationProbe/main.swift"
        -o "${probe}"
    )
    record_command "${probe_command[@]}"
    "${probe_command[@]}" >>"${log_path}" 2>&1
    record_command env "DYLD_LIBRARY_PATH=${probe_dir}" "${probe}"
    env "DYLD_LIBRARY_PATH=${probe_dir}" "${probe}" >"${output}" 2>>"${log_path}"
    record_command nm -u "${probe}"
    nm -u "${probe}" >"${report_dir}/semantics/allocation-probe-symbols.txt"
    grep -Fxq 'allocation_count=0' "${output}" || fail 'allocation probe reported heap activity'
    grep -Eq '^maximum_counted_steps=([0-9]|[1-5][0-9]|6[0-4])$' "${output}" ||
        fail 'correctness-path step count exceeds 64'
    grep -Eq '^maximum_normalization_counted_steps=([0-8])$' "${output}" ||
        fail 'containment-normalization step count exceeds 8'
    grep -Eq '^maximum_diagnostic_selection_counted_steps=([0-8])$' "${output}" ||
        fail 'diagnostic-selection step count exceeds 8'
    record_image allocation-probe "${probe}"
    record_image allocation-interposer "${interposer}"
}

run_macos() {
    [[ "$(uname -s)" == "Darwin" ]] || fail 'macOS profile requires macOS'
    [[ "$(uname -m)" == "arm64" ]] || fail 'macOS evidence requires an arm64 host'
    command -v xcrun >/dev/null || fail 'xcrun is missing'

    local compiler compiler_version sdk_path sdk_version profile_flag capacity_flag image extension
    compiler="$(xcrun --find swiftc)"
    compiler_version="$("${compiler}" --version 2>&1)"
    require_exact_fragment "${compiler_version}" 'Apple Swift version 6.3.3' 'macOS compiler'
    require_exact_fragment "${compiler_version}" 'swiftlang-6.3.3.1.3' 'macOS compiler build'
    sdk_path="$(xcrun --sdk macosx --show-sdk-path)"
    sdk_version="$(xcrun --sdk macosx --show-sdk-version)"
    [[ -d "${sdk_path}" ]] || fail "macOS SDK is missing: ${sdk_path}"

    if [[ "${profile}" == "macos-dynamic" ]]; then
        profile_flag='-DGIFTUI_DYNAMIC_PROFILE'
        capacity_flag='-DGIFTUI_DIAGNOSTICS_CAPACITY_64'
        extension='dylib'
    else
        profile_flag='-DGIFTUI_STATIC_PROFILE'
        capacity_flag='-DGIFTUI_DIAGNOSTICS_CAPACITY_16'
        extension='a'
    fi
    image="${report_dir}/resources/build-1/candidate/libGiftUIFailureCore.${extension}"
    local -a command=(
        "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -O -whole-module-optimization "${profile_flag}"
        -language-mode 6 -parse-as-library -module-name GiftUIFailureCore
        -enable-library-evolution
        -emit-library -emit-module
        -emit-module-path "${report_dir}/build/GiftUIFailureCore.swiftmodule"
        -emit-module-interface-path "${report_dir}/build/GiftUIFailureCore.swiftinterface"
    )
    if [[ "${profile}" == "macos-static" ]]; then
        command+=(-static)
    fi
    command+=("${SOURCE_ROOT}/GiftUIFailureCore.swift" -o "${image}")

    record_compiler "${compiler}"
    printf 'target=arm64-apple-macosx26.0\n' >>"${metadata_path}"
    printf 'sdk_path=%s\n' "${sdk_path}" >>"${metadata_path}"
    printf 'sdk_version=%s\n' "${sdk_version}" >>"${metadata_path}"
    printf 'optimization=-O -whole-module-optimization\n' >>"${metadata_path}"
    printf 'profile_flag=%s\n' "${profile_flag}" >>"${metadata_path}"
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    record_image candidate-module "${report_dir}/build/GiftUIFailureCore.swiftmodule"
    record_image candidate-library "${image}"
    record_command otool -L "${image}"
    otool -L "${image}" >"${report_dir}/build/product-links.txt"
    record_command nm -u "${image}"
    nm -u "${image}" >"${report_dir}/build/undefined-symbols.txt"
    record_command "${SCRIPT_DIR}/check-spec-003-core-boundary.rb" \
        "${report_dir}/build/GiftUIFailureCore.swiftinterface" \
        "${report_dir}/build/product-links.txt" \
        "${report_dir}/build/undefined-symbols.txt"
    "${SCRIPT_DIR}/check-spec-003-core-boundary.rb" \
        "${report_dir}/build/GiftUIFailureCore.swiftinterface" \
        "${report_dir}/build/product-links.txt" \
        "${report_dir}/build/undefined-symbols.txt" >>"${log_path}" 2>&1
    compile_macos_capability_adapter "${compiler}" "${sdk_path}" "${profile_flag}"
    run_fixture_set "${compiler}" "${report_dir}/build" \
        -target arm64-apple-macosx26.0 -sdk "${sdk_path}" \
        -O -whole-module-optimization "${profile_flag}"
    run_profile_corpus_probe_macos \
        "${compiler}" "${sdk_path}" "${profile_flag}" "${image}"
    run_complete_semantic_suite_macos "${compiler}" "${profile_flag}" "${capacity_flag}"
    run_layout_probe "${compiler}" "${report_dir}/build" "${capacity_flag}" \
        -target arm64-apple-macosx26.0 -sdk "${sdk_path}" \
        -O -whole-module-optimization "${profile_flag}" -language-mode 6
    run_allocation_probe "${compiler}" "${sdk_path}" "${profile_flag}"
}

run_raspberry_pi() {
    # shellcheck source=../raspberry-pi/common.sh
    source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
    local swift_driver compiler compiler_version sdk_identity module core_module
    local core_object object_attributes file_description attributes_hex llvm_objdump
    local probe_module sdk_root
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
        --configuration release --target GiftUICapabilityFailureAdapterFixture
        --static-swift-stdlib
        -Xswiftc -whole-module-optimization
    )
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    modules=()
    while IFS= read -r module; do
        modules+=("${module}")
    done < <(find "${report_dir}/build/swiftpm" -type f -name 'GiftUIFailureCore.swiftmodule' -print)
    [[ "${#modules[@]}" -eq 1 ]] || fail "expected one ARMv6 module image, found ${#modules[@]}"
    module="${modules[0]}"
    core_module="${module}"
    record_image candidate-module "${module}"
    modules=()
    while IFS= read -r module; do
        modules+=("${module}")
    done < <(find "${report_dir}/build/swiftpm" -type f \
        -name 'GiftUICapabilityFailureAdapterFixture.swiftmodule' -print)
    [[ "${#modules[@]}" -eq 1 ]] ||
        fail "expected one ARMv6 capability adapter module, found ${#modules[@]}"
    record_image capability-adapter-module "${modules[0]}"

    core_object="${report_dir}/build/swiftpm/${GIFTUI_PI_TARGET}/release/GiftUIFailureCore.build/GiftUIFailureCore.swift.o"
    object_attributes="${report_dir}/resources/build-1/candidate/arm-attributes.txt"
    file_description="$(file "${core_object}")"
    [[ "${file_description}" == *'ELF 32-bit LSB relocatable, ARM, EABI5'* ]] ||
        fail "expected an ARM EABI5 Core object: ${file_description}"
    llvm_objdump="${GIFTUI_PI_HOST_BIN_DIR}/llvm-objdump"
    record_command file "${core_object}"
    record_command "${llvm_objdump}" -s -j .ARM.attributes "${core_object}"
    {
        printf '%s\n' "${file_description}"
        "${llvm_objdump}" -s -j .ARM.attributes "${core_object}"
    } >"${object_attributes}"
    attributes_hex="$(
        "${llvm_objdump}" -s -j .ARM.attributes "${core_object}" |
            awk '
                /^[[:space:]]+[[:xdigit:]]+[[:space:]]/ {
                    for (i = 2; i <= NF; i++) {
                        if ($i ~ /^[0-9A-Fa-f]+$/ && length($i) <= 8) {
                            printf "%s", $i
                        }
                    }
                }
                END { print "" }
            '
    )"
    [[ "${attributes_hex}" == *'61726d313133366a662d7300'* ]] ||
        fail 'ARMv6 Core object does not declare the arm1136jf-s CPU'
    [[ "${attributes_hex}" == *'1c01'* ]] ||
        fail 'ARMv6 Core object does not declare the hard-float calling convention'
    record_image candidate-object "${core_object}"

    sdk_root="${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}"
    probe_module="${report_dir}/build/GiftUIFailureProfileCorpusProbe.swiftmodule"
    local -a probe_command=(
        "${compiler}" -target "${GIFTUI_PI_TARGET}"
        -use-ld=lld
        -Xcc "--gcc-toolchain=${sdk_root}/usr"
        -resource-dir "${sdk_root}/usr/lib/swift_static"
        -sdk "${sdk_root}" -latomic
        -O -whole-module-optimization -language-mode 6
        -I "$(dirname "${core_module}")"
        -parse-as-library -emit-module
        -module-name GiftUIFailureProfileCorpusProbe
        "${PROFILE_PROBE_ROOT}/ProfileCorpusProbe.swift"
        -emit-module-path "${probe_module}"
    )
    record_command "${probe_command[@]}"
    "${probe_command[@]}" >>"${log_path}" 2>&1
    record_image profile-corpus-module "${probe_module}"
    run_layout_probe "${compiler}" "$(dirname "${core_module}")" \
        -DGIFTUI_DIAGNOSTICS_CAPACITY_16 \
        -target "${GIFTUI_PI_TARGET}" -use-ld=lld \
        -Xcc "--gcc-toolchain=${sdk_root}/usr" \
        -resource-dir "${sdk_root}/usr/lib/swift_static" \
        -sdk "${sdk_root}" -latomic -O -whole-module-optimization -language-mode 6
}

run_nrf52840() {
    # shellcheck source=../nrf52840/common.sh
    source "${PROJECT_ROOT}/scripts/nrf52840/common.sh"
    giftui_nrf_require_environment
    record_command "${PROJECT_ROOT}/scripts/nrf52840/doctor.sh"
    "${PROJECT_ROOT}/scripts/nrf52840/doctor.sh" >>"${log_path}" 2>&1
    local compiler_version module core_object object_attributes probe_module readelf
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

    module="${report_dir}/build/GiftUIFailureCore.swiftmodule"
    local -a command=(
        "${GIFTUI_NRF_SWIFTC}" -target "${GIFTUI_NRF_SWIFT_TARGET}"
        -enable-experimental-feature Embedded
        -Osize -whole-module-optimization
        -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
        -parse-as-library -emit-module -module-name GiftUIFailureCore
        "${SOURCE_ROOT}/GiftUIFailureCore.swift" -emit-module-path "${module}"
    )
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    record_image candidate-module "${module}"

    core_object="${report_dir}/build/GiftUIFailureCore.swift.o"
    local -a object_command=(
        "${GIFTUI_NRF_SWIFTC}" -target "${GIFTUI_NRF_SWIFT_TARGET}"
        -enable-experimental-feature Embedded
        -Osize -whole-module-optimization
        -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
        -parse-as-library -emit-object -module-name GiftUIFailureCore
        "${SOURCE_ROOT}/GiftUIFailureCore.swift" -o "${core_object}"
    )
    record_command "${object_command[@]}"
    "${object_command[@]}" >>"${log_path}" 2>&1
    readelf="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf"
    object_attributes="${report_dir}/resources/build-1/candidate/arm-attributes.txt"
    record_command "${readelf}" -A "${core_object}"
    "${readelf}" -A "${core_object}" >"${object_attributes}"
    grep -Fq 'Tag_CPU_name: "cortex-m4"' "${object_attributes}" ||
        fail 'nRF Core object does not declare cortex-m4'
    grep -Fq 'Tag_CPU_arch: v7E-M' "${object_attributes}" ||
        fail 'nRF Core object does not declare ARMv7E-M'
    grep -Fq 'Tag_FP_arch: VFPv4-D16' "${object_attributes}" ||
        fail 'nRF Core object does not declare VFPv4-D16'
    grep -Fq 'Tag_ABI_VFP_args: VFP registers' "${object_attributes}" ||
        fail 'nRF Core object does not declare the hard-float calling convention'
    record_image candidate-object "${core_object}"

    probe_module="${report_dir}/build/GiftUIFailureProfileCorpusProbe.swiftmodule"
    local -a probe_command=(
        "${GIFTUI_NRF_SWIFTC}" -target "${GIFTUI_NRF_SWIFT_TARGET}"
        -enable-experimental-feature Embedded
        -Osize -whole-module-optimization
        -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
        -I "${report_dir}/build"
        -parse-as-library -emit-module
        -module-name GiftUIFailureProfileCorpusProbe
        "${PROFILE_PROBE_ROOT}/ProfileCorpusProbe.swift"
        -emit-module-path "${probe_module}"
    )
    record_command "${probe_command[@]}"
    "${probe_command[@]}" >>"${log_path}" 2>&1
    record_image profile-corpus-module "${probe_module}"

    local adapter_dir="${report_dir}/build/capability-adapter"
    local capability_module="${adapter_dir}/GiftUICapabilities.swiftmodule"
    local adapter_module="${adapter_dir}/GiftUICapabilityFailureAdapterFixture.swiftmodule"
    mkdir -p "${adapter_dir}"
    local -a capability_command=(
        "${GIFTUI_NRF_SWIFTC}" -target "${GIFTUI_NRF_SWIFT_TARGET}"
        -enable-experimental-feature Embedded
        -Osize -whole-module-optimization
        -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
        -parse-as-library -emit-module -module-name GiftUICapabilities
        "${CAPABILITY_SOURCE}" -emit-module-path "${capability_module}"
    )
    record_command "${capability_command[@]}"
    "${capability_command[@]}" >>"${log_path}" 2>&1
    local -a adapter_command=(
        "${GIFTUI_NRF_SWIFTC}" -target "${GIFTUI_NRF_SWIFT_TARGET}"
        -enable-experimental-feature Embedded
        -Osize -whole-module-optimization
        -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
        -I "${report_dir}/build" -I "${adapter_dir}"
        -parse-as-library -emit-module
        -module-name GiftUICapabilityFailureAdapterFixture
        "${CAPABILITY_ADAPTER_SOURCE}" -emit-module-path "${adapter_module}"
    )
    record_command "${adapter_command[@]}"
    "${adapter_command[@]}" >>"${log_path}" 2>&1
    record_image capability-adapter-module "${adapter_module}"
    run_layout_probe "${GIFTUI_NRF_SWIFTC}" "${report_dir}/build" \
        -DGIFTUI_DIAGNOSTICS_CAPACITY_8 \
        -target "${GIFTUI_NRF_SWIFT_TARGET}" \
        -enable-experimental-feature Embedded -Osize -whole-module-optimization \
        -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
}

record_input_hashes
record_command "${SCRIPT_DIR}/check-spec-003-fixture-manifest.rb"
"${SCRIPT_DIR}/check-spec-003-fixture-manifest.rb" >>"${log_path}" 2>&1
record_command "${SCRIPT_DIR}/check-spec-003-profile-corpus.rb"
"${SCRIPT_DIR}/check-spec-003-profile-corpus.rb" >>"${log_path}" 2>&1
run_dependency_checks

case "${profile}" in
    macos-dynamic | macos-static) run_macos ;;
    raspberry-pi-armv6) run_raspberry_pi ;;
    nrf52840-embedded) run_nrf52840 ;;
esac
