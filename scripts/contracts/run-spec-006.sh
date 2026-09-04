#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC006"
FOUNDATION_SOURCE="${PROJECT_ROOT}/Sources/GiftUI/GiftUI.swift"
SEMANTIC_SOURCE="${PROJECT_ROOT}/Sources/GiftUISemanticCore/GiftUISemanticCore.swift"
GENERATED_ROOT="${PROJECT_ROOT}/.build/contract-generated/spec-006"
REPORT_ROOT="${PROJECT_ROOT}/.build/contract-reports/spec-006"

usage() {
    printf '%s\n' \
        'Usage: scripts/contracts/run-spec-006.sh --profile <profile>' \
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

declared_inputs() {
    {
        find "${FIXTURE_ROOT}" -type f -print
        printf '%s\n' \
            "${FOUNDATION_SOURCE}" \
            "${SEMANTIC_SOURCE}" \
            "${PROJECT_ROOT}/Package.swift" \
            "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/target-dependencies.yaml" \
            "${PROJECT_ROOT}/scripts/contracts/driver-registry.tsv" \
            "${SCRIPT_DIR}/check-spec-006-harness.rb" \
            "${SCRIPT_DIR}/report-input-identity.rb" \
            "${SCRIPT_DIR}/publish-contract-report.rb" \
            "${SCRIPT_DIR}/verify-contract-report.rb" \
            "${SCRIPT_DIR}/run-spec-006.sh"
    } | LC_ALL=C sort -u
}

revision="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
if [[ -n "$(git -C "${PROJECT_ROOT}" status --porcelain --untracked-files=normal)" ]]; then
    dirty=true
else
    dirty=false
fi
mkdir -p "${REPORT_ROOT}"
report_dir="${REPORT_ROOT}/.tmp-${profile}-$$"
[[ ! -e "${report_dir}" ]] || fail "temporary report directory exists: ${report_dir}"
mkdir -p "${report_dir}"
inputs_path="${report_dir}/input-hashes.tsv"
identity_metadata="$(declared_inputs | "${SCRIPT_DIR}/report-input-identity.rb" \
    --root "${PROJECT_ROOT}" --revision "${revision}" --inventory "${inputs_path}")"
input_set_sha256="$(printf '%s\n' "${identity_metadata}" | awk -F= '$1 == "input_set_sha256" { print $2 }')"
run_id="$(printf '%s\n' "${identity_metadata}" | awk -F= '$1 == "run_id" { print $2 }')"
[[ -n "${input_set_sha256}" && -n "${run_id}" ]] || fail 'input identity calculation failed'
canonical_report_dir="${REPORT_ROOT}/${run_id}/${profile}"
latest_pointer="${REPORT_ROOT}/latest-${profile}.txt"
if [[ -d "${canonical_report_dir}" ]]; then
    "${SCRIPT_DIR}/verify-contract-report.rb" "${canonical_report_dir}"
    rm -rf "${report_dir}"
    temporary_pointer="${REPORT_ROOT}/.latest-${profile}.tmp-$$"
    printf '%s\n' "${run_id}" >"${temporary_pointer}"
    mv "${temporary_pointer}" "${latest_pointer}"
    printf 'SPEC-006 %s harness idempotent match; run ID: %s\n' "${profile}" "${run_id}"
    exit 0
fi

generated_dir="${GENERATED_ROOT}/${profile}"
rm -rf "${generated_dir}"
mkdir -p \
    "${generated_dir}" \
    "${report_dir}/build/clang-cache" \
    "${report_dir}/build/swiftpm-cache" \
    "${report_dir}/fixtures"

export CLANG_MODULE_CACHE_PATH="${report_dir}/build/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${report_dir}/build/swiftpm-cache"
metadata_path="${report_dir}/metadata.txt"
commands_path="${report_dir}/commands.txt"
images_path="${report_dir}/image-hashes.tsv"
evidence_path="${report_dir}/required-evidence.tsv"
log_path="${report_dir}/run.log"
: >"${commands_path}"
: >"${images_path}"
: >"${log_path}"

{
    printf 'schema_version=1\n'
    printf 'spec=SPEC-006\n'
    printf 'profile=%s\n' "${profile}"
    printf 'repository_revision=%s\n' "${revision}"
    printf 'repository_dirty=%s\n' "${dirty}"
    printf 'input_set_sha256=%s\n' "${input_set_sha256}"
    printf 'run_id=%s\n' "${run_id}"
    printf 'generated_directory=.build/contract-generated/spec-006/%s\n' "${profile}"
    printf 'report_directory=.build/contract-reports/spec-006/%s/%s\n' "${run_id}" "${profile}"
    printf 'invocation=scripts/contracts/run-spec-006.sh --profile %s\n' "${profile}"
    printf 'evidence=hardware-free\n'
    printf 'remote_access=false\n'
    printf 'deployment=false\n'
    printf 'service_restart=false\n'
    printf 'simulator_execution=false\n'
    printf 'connected_target_execution=false\n'
    printf 'flashing=false\n'
    printf 'evidence_complete=false\n'
} >"${metadata_path}"

finish() {
    local result=$?
    printf 'exit_code=%s\n' "${result}" >>"${metadata_path}"
    if [[ "${result}" -ne 0 ]]; then
        printf 'SPEC-006 %s harness failed; see %s\n' "${profile}" "${report_dir}" >&2
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

hash_file() {
    shasum -a 256 "$1" | awk '{print $1}'
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
    printf '%s\t%s\t%s\n' \
        "${label}" "${path#"${PROJECT_ROOT}/"}" "$(hash_file "${path}")" \
        >>"${images_path}"
}

record_required_evidence() {
    local nrf_status=not-applicable
    if [[ "${profile}" == "nrf52840-embedded" ]]; then
        nrf_status=missing
    fi
    {
        printf '# item\tstatus\n'
        printf 'compiler-identity\tcomplete\n'
        printf 'target-pin\tcomplete\n'
        printf 'optimization\tcomplete\n'
        printf 'command-transcript\tcomplete\n'
        printf 'repository-revision\tcomplete\n'
        printf 'portable-module\tcomplete\n'
        printf 'ordered-corpus\tmissing\n'
        printf 'normalized-results\tmissing\n'
        printf 'allocation-record\tmissing\n'
        printf 'owned-value-layouts\tmissing\n'
        printf 'summary-counters\tmissing\n'
        printf 'maximum-observed-depth\tmissing\n'
        printf 'underscored-reference-inventory\tmissing\n'
        printf 'nrf-elf-inspection\t%s\n' "${nrf_status}"
    } >"${evidence_path}"
}

run_fixture_set() {
    local compiler="$1"
    local module_dir="$2"
    shift 2
    local -a common_flags=("$@")
    local id expectation access entry patterns allowed_modules result pattern
    while IFS=$'\t' read -r id expectation access entry patterns allowed_modules; do
        [[ -n "${id}" && "${id}" != \#* ]] || continue
        local fixture_dir="${report_dir}/fixtures/${id}"
        mkdir -p "${fixture_dir}"
        local -a command=("${compiler}" "${common_flags[@]}" -I "${module_dir}")
        if [[ "${access}" == "package" ]]; then
            command+=(-package-name GiftUI)
        fi
        command+=(-typecheck "${FIXTURE_ROOT}/${entry}")
        record_command "${command[@]}"
        set +e
        "${command[@]}" >"${fixture_dir}/stdout.txt" 2>"${fixture_dir}/stderr.txt"
        result=$?
        set -e
        if [[ "${expectation}" == "pass" ]]; then
            [[ "${result}" -eq 0 ]] || fail "positive fixture ${id} failed"
        else
            [[ "${result}" -ne 0 ]] || fail "negative fixture ${id} unexpectedly compiled"
            while IFS= read -r pattern; do
                [[ -n "${pattern}" && "${pattern}" != \#* ]] || continue
                grep -Fq "${pattern}" "${fixture_dir}/stderr.txt" ||
                    fail "negative fixture ${id} lacked diagnostic pattern: ${pattern}"
            done <"${FIXTURE_ROOT}/${patterns}"
        fi
    done <"${FIXTURE_ROOT}/fixture-manifest.tsv"
}

run_macos() {
    [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "arm64" ]] ||
        fail 'macOS profiles require an arm64 macOS host'
    local compiler version sdk profile_flag extension module_dir image
    compiler="$(xcrun --find swiftc)"
    version="$("${compiler}" --version 2>&1)"
    [[ "${version}" == *'Apple Swift version 6.3.3'* && "${version}" == *'swiftlang-6.3.3.1.3'* ]] ||
        fail 'macOS compiler identity differs from SPEC-002'
    sdk="$(xcrun --sdk macosx --show-sdk-path)"
    if [[ "${profile}" == "macos-dynamic" ]]; then
        profile_flag=-DGIFTUI_DYNAMIC_PROFILE
        extension=dylib
    else
        profile_flag=-DGIFTUI_STATIC_PROFILE
        extension=a
    fi
    module_dir="${report_dir}/build/modules"
    image="${report_dir}/build/libGiftUISemanticCore.${extension}"
    mkdir -p "${module_dir}"
    record_compiler "${compiler}"
    printf 'target=arm64-apple-macosx26.0\n' >>"${metadata_path}"
    printf 'sdk_path=%s\n' "${sdk}" >>"${metadata_path}"
    printf 'optimization=-O -whole-module-optimization\n' >>"${metadata_path}"
    local -a flags=(-target arm64-apple-macosx26.0 -sdk "${sdk}" -O -whole-module-optimization "${profile_flag}" -language-mode 6 -package-name GiftUI)
    local -a foundation=("${compiler}" "${flags[@]}" -parse-as-library -emit-module -module-name GiftUI "${FOUNDATION_SOURCE}" -emit-module-path "${module_dir}/GiftUI.swiftmodule")
    record_command "${foundation[@]}"
    "${foundation[@]}" >>"${log_path}" 2>&1
    local -a semantic=("${compiler}" "${flags[@]}" -parse-as-library -emit-module -emit-library -module-name GiftUISemanticCore -I "${module_dir}" "${SEMANTIC_SOURCE}" -emit-module-path "${module_dir}/GiftUISemanticCore.swiftmodule")
    if [[ "${profile}" == "macos-static" ]]; then
        semantic+=(-static)
    fi
    semantic+=(-o "${image}")
    record_command "${semantic[@]}"
    "${semantic[@]}" >>"${log_path}" 2>&1
    record_image semantic-module "${module_dir}/GiftUISemanticCore.swiftmodule"
    record_image semantic-library "${image}"
    run_fixture_set "${compiler}" "${module_dir}" "${flags[@]}"
}

run_raspberry_pi() {
    source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
    local swift_driver compiler version module
    swift_driver="$(giftui_pi_host_swift)"
    compiler="$(dirname "${swift_driver}")/swiftc"
    giftui_pi_require_sdk
    version="$("${compiler}" --version 2>&1)"
    [[ "${version}" == *"Swift version ${GIFTUI_PI_SWIFT_VERSION}"* ]] ||
        fail 'Raspberry Pi compiler identity differs from SPEC-002'
    grep -Fq "\"target\":\"${GIFTUI_PI_TARGET}\"" "${GIFTUI_PI_STATIC_DESTINATION}" ||
        fail 'Raspberry Pi destination target differs from its pin'
    record_compiler "${compiler}"
    printf 'target=%s\n' "${GIFTUI_PI_TARGET}" >>"${metadata_path}"
    printf 'destination=%s\n' "${GIFTUI_PI_STATIC_DESTINATION}" >>"${metadata_path}"
    printf 'optimization=-O -whole-module-optimization\n' >>"${metadata_path}"
    giftui_pi_prepare_build_environment
    local -a command=("${swift_driver}" build --disable-sandbox --package-path "${PROJECT_ROOT}" --scratch-path "${report_dir}/build/swiftpm" --destination "${GIFTUI_PI_STATIC_DESTINATION}" --configuration release --target GiftUISemanticCore --static-swift-stdlib -Xswiftc -whole-module-optimization)
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    module="$(find "${report_dir}/build/swiftpm" -type f -name 'GiftUISemanticCore.swiftmodule' -print -quit)"
    [[ -n "${module}" ]] || fail 'ARMv6 semantic module is missing'
    record_image semantic-module "${module}"
    run_fixture_set "${compiler}" "$(dirname "${module}")" -target "${GIFTUI_PI_TARGET}" -sdk "${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}" -resource-dir "${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr/lib/swift_static" -Xcc "--gcc-toolchain=${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr"
}

run_nrf52840() {
    source "${PROJECT_ROOT}/scripts/nrf52840/common.sh"
    giftui_nrf_require_environment
    local version module_dir
    version="$("${GIFTUI_NRF_SWIFTC}" --version 2>&1)"
    [[ "${version}" == *"Swift version ${GIFTUI_NRF_SWIFT_VERSION}"* ]] ||
        fail 'nRF compiler identity differs from SPEC-002'
    [[ "$(giftui_nrf_git_revision "${GIFTUI_NRF_ZEPHYR_BASE}")" == "${GIFTUI_NRF_ZEPHYR_REVISION}" ]] ||
        fail 'Zephyr revision differs from its pin'
    record_compiler "${GIFTUI_NRF_SWIFTC}"
    printf 'target=%s\n' "${GIFTUI_NRF_SWIFT_TARGET}" >>"${metadata_path}"
    printf 'board=%s\n' "${GIFTUI_NRF_BOARD}" >>"${metadata_path}"
    printf 'optimization=-Osize -whole-module-optimization\n' >>"${metadata_path}"
    module_dir="${report_dir}/build/modules"
    mkdir -p "${module_dir}"
    local -a flags=(-target "${GIFTUI_NRF_SWIFT_TARGET}" -enable-experimental-feature Embedded -Osize -whole-module-optimization -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16 -package-name GiftUI)
    local -a foundation=("${GIFTUI_NRF_SWIFTC}" "${flags[@]}" -parse-as-library -emit-module -module-name GiftUI "${FOUNDATION_SOURCE}" -emit-module-path "${module_dir}/GiftUI.swiftmodule")
    record_command "${foundation[@]}"
    "${foundation[@]}" >>"${log_path}" 2>&1
    local -a semantic=("${GIFTUI_NRF_SWIFTC}" "${flags[@]}" -parse-as-library -emit-module -module-name GiftUISemanticCore -I "${module_dir}" "${SEMANTIC_SOURCE}" -emit-module-path "${module_dir}/GiftUISemanticCore.swiftmodule")
    record_command "${semantic[@]}"
    "${semantic[@]}" >>"${log_path}" 2>&1
    record_image semantic-module "${module_dir}/GiftUISemanticCore.swiftmodule"
    run_fixture_set "${GIFTUI_NRF_SWIFTC}" "${module_dir}" "${flags[@]}"
}

record_command "${SCRIPT_DIR}/check-spec-006-harness.rb"
"${SCRIPT_DIR}/check-spec-006-harness.rb" >>"${log_path}" 2>&1

case "${profile}" in
    macos-dynamic | macos-static) run_macos ;;
    raspberry-pi-armv6) run_raspberry_pi ;;
    nrf52840-embedded) run_nrf52840 ;;
esac

record_required_evidence
record_command "${SCRIPT_DIR}/check-spec-006-harness.rb" "${report_dir}"
"${SCRIPT_DIR}/check-spec-006-harness.rb" "${report_dir}" >>"${log_path}" 2>&1
printf 'exit_code=0\n' >>"${metadata_path}"
trap - EXIT
"${SCRIPT_DIR}/publish-contract-report.rb" \
    --report-root "${REPORT_ROOT}" \
    --staging "${report_dir}" \
    --destination "${canonical_report_dir}" \
    --latest "${latest_pointer}" \
    --run-id "${run_id}"
printf 'SPEC-006 %s harness passed; conformance evidence remains incomplete; run ID: %s\n' \
    "${profile}" "${run_id}"
