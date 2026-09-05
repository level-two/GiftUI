#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC010"
REPORT_ROOT="${PROJECT_ROOT}/.build/contract-reports/spec-010"

usage() {
    printf '%s\n' \
        'Usage: scripts/contracts/run-spec-010.sh --profile <profile>' \
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
        find "${PROJECT_ROOT}/Sources/GiftUI" -type f -name '*.swift' -print
        printf '%s\n' \
            "${PROJECT_ROOT}/Package.swift" \
            "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/target-dependencies.yaml" \
            "${PROJECT_ROOT}/scripts/contracts/driver-registry.tsv" \
            "${SCRIPT_DIR}/check-spec-010-attachment-property.sh" \
            "${SCRIPT_DIR}/check-spec-010-harness.rb" \
            "${SCRIPT_DIR}/check-spec-010-migration.rb" \
            "${SCRIPT_DIR}/report-input-identity.rb" \
            "${SCRIPT_DIR}/publish-contract-report.rb" \
            "${SCRIPT_DIR}/verify-contract-report.rb" \
            "${SCRIPT_DIR}/run-spec-010.sh"
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
mkdir -p "${report_dir}/build/module-cache"
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
    printf 'SPEC-010 %s harness idempotent match; run ID: %s\n' "${profile}" "${run_id}"
    exit 0
fi

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
    printf 'spec=SPEC-010\n'
    printf 'profile=%s\n' "${profile}"
    printf 'repository_revision=%s\n' "${revision}"
    printf 'repository_dirty=%s\n' "${dirty}"
    printf 'input_set_sha256=%s\n' "${input_set_sha256}"
    printf 'run_id=%s\n' "${run_id}"
    printf 'invocation=scripts/contracts/run-spec-010.sh --profile %s\n' "${profile}"
    printf 'public_contract_compile=pending\n'
    printf 'evidence_complete=false\n'
    printf 'remote_access=false\n'
    printf 'deployment=false\n'
    printf 'service_restart=false\n'
    printf 'simulator_execution=false\n'
    printf 'connected_target_execution=false\n'
    printf 'flashing=false\n'
} >"${metadata_path}"

finish() {
    local result=$?
    printf 'exit_code=%s\n' "${result}" >>"${metadata_path}"
    if [[ "${result}" -ne 0 ]]; then
        printf 'SPEC-010 %s harness failed; see %s\n' "${profile}" "${report_dir}" >&2
    fi
}
trap finish EXIT

record_command() {
    printf '%q ' "$@" >>"${commands_path}"
    printf '\n' >>"${commands_path}"
}

hash_file() {
    shasum -a 256 "$1" | awk '{print $1}'
}

record_compiler() {
    local compiler="$1"
    local version
    version="$("${compiler}" --version 2>&1)"
    printf 'compiler_path=%s\n' "${compiler}" >>"${metadata_path}"
    printf 'compiler_sha256=%s\n' "$(hash_file "${compiler}")" >>"${metadata_path}"
    {
        printf 'compiler_version<<EOF\n'
        printf '%s\n' "${version}"
        printf 'EOF\n'
    } >>"${metadata_path}"
}

record_image() {
    local label="$1"
    local artifact="$2"
    [[ -f "${artifact}" ]] || fail "expected artifact is missing: ${artifact}"
    printf '%s\t%s\t%s\n' \
        "${label}" "${artifact#"${PROJECT_ROOT}/"}" "$(hash_file "${artifact}")" \
        >>"${images_path}"
}

record_required_evidence() {
    {
        printf '# criterion\tstatus\n'
        awk -F $'\t' '!/^#/ && NF { print $1 "\tmissing" }' \
            "${FIXTURE_ROOT}/required-evidence.tsv"
    } >"${evidence_path}"
}

compile_macos() {
    local compiler sdk profile_flag module
    compiler="$(xcrun --find swiftc)"
    sdk="$(xcrun --sdk macosx --show-sdk-path)"
    if [[ "${profile}" == "macos-dynamic" ]]; then
        profile_flag=-DGIFTUI_DYNAMIC_PROFILE
    else
        profile_flag=-DGIFTUI_STATIC_PROFILE
    fi
    record_compiler "${compiler}"
    printf 'target=arm64-apple-macosx26.0\n' >>"${metadata_path}"
    printf 'sdk_path=%s\n' "${sdk}" >>"${metadata_path}"
    printf 'optimization=-O -whole-module-optimization\n' >>"${metadata_path}"
    module="${report_dir}/build/GiftUI.swiftmodule"
    local -a sources=("${PROJECT_ROOT}"/Sources/GiftUI/*.swift)
    local -a command=("${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk}" -O -whole-module-optimization "${profile_flag}" -language-mode 6 -package-name GiftUI -module-cache-path "${report_dir}/build/module-cache" -parse-as-library -emit-module -module-name GiftUI "${sources[@]}" -emit-module-path "${module}")
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    record_image portable-module "${module}"
}

compile_raspberry_pi() {
    source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
    local swift_driver compiler module
    swift_driver="$(giftui_pi_host_swift)"
    compiler="$(dirname "${swift_driver}")/swiftc"
    giftui_pi_require_sdk
    record_compiler "${compiler}"
    printf 'target=%s\n' "${GIFTUI_PI_TARGET}" >>"${metadata_path}"
    printf 'destination=%s\n' "${GIFTUI_PI_STATIC_DESTINATION}" >>"${metadata_path}"
    printf 'optimization=-O -whole-module-optimization\n' >>"${metadata_path}"
    giftui_pi_prepare_build_environment
    local -a command=("${swift_driver}" build --disable-sandbox --package-path "${PROJECT_ROOT}" --scratch-path "${report_dir}/build/swiftpm" --destination "${GIFTUI_PI_STATIC_DESTINATION}" --configuration release --target GiftUI --static-swift-stdlib -Xswiftc -whole-module-optimization)
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    module="$(find "${report_dir}/build/swiftpm" -type f -name 'GiftUI.swiftmodule' -print -quit)"
    [[ -n "${module}" ]] || fail 'ARMv6 GiftUI module is missing'
    record_image portable-module "${module}"
}

compile_nrf52840() {
    source "${PROJECT_ROOT}/scripts/nrf52840/common.sh"
    giftui_nrf_require_environment
    record_compiler "${GIFTUI_NRF_SWIFTC}"
    printf 'target=%s\n' "${GIFTUI_NRF_SWIFT_TARGET}" >>"${metadata_path}"
    printf 'board=%s\n' "${GIFTUI_NRF_BOARD}" >>"${metadata_path}"
    printf 'optimization=-Osize -whole-module-optimization\n' >>"${metadata_path}"
    local module="${report_dir}/build/GiftUI.swiftmodule"
    local -a sources=("${PROJECT_ROOT}"/Sources/GiftUI/*.swift)
    local -a command=("${GIFTUI_NRF_SWIFTC}" -target "${GIFTUI_NRF_SWIFT_TARGET}" -enable-experimental-feature Embedded -Osize -whole-module-optimization -module-cache-path "${report_dir}/build/module-cache" -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16 -package-name GiftUI -parse-as-library -emit-module -module-name GiftUI "${sources[@]}" -emit-module-path "${module}")
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    record_image portable-module "${module}"
}

record_command "${SCRIPT_DIR}/check-spec-010-harness.rb"
"${SCRIPT_DIR}/check-spec-010-harness.rb" >>"${log_path}" 2>&1
record_command "${SCRIPT_DIR}/check-spec-010-migration.rb"
"${SCRIPT_DIR}/check-spec-010-migration.rb" >>"${log_path}" 2>&1
if [[ "${profile}" == "macos-dynamic" || "${profile}" == "macos-static" ]]; then
    record_command "${SCRIPT_DIR}/check-spec-010-attachment-property.sh"
    "${SCRIPT_DIR}/check-spec-010-attachment-property.sh" >>"${log_path}" 2>&1
fi

case "${profile}" in
    macos-dynamic | macos-static) compile_macos ;;
    raspberry-pi-armv6) compile_raspberry_pi ;;
    nrf52840-embedded) compile_nrf52840 ;;
esac

record_required_evidence
record_command "${SCRIPT_DIR}/check-spec-010-harness.rb" "${report_dir}"
"${SCRIPT_DIR}/check-spec-010-harness.rb" "${report_dir}" >>"${log_path}" 2>&1
printf 'exit_code=0\n' >>"${metadata_path}"
trap - EXIT
"${SCRIPT_DIR}/publish-contract-report.rb" \
    --report-root "${REPORT_ROOT}" \
    --staging "${report_dir}" \
    --destination "${canonical_report_dir}" \
    --latest "${latest_pointer}" \
    --run-id "${run_id}"
printf 'SPEC-010 %s harness passed; public contract implementation pending; run ID: %s\n' \
    "${profile}" "${run_id}"
