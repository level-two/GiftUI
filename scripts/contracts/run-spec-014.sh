#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC014"
REPORT_ROOT="${PROJECT_ROOT}/.build/spec-014/reports"
# shellcheck source=../lib/swiftpm.sh
source "${PROJECT_ROOT}/scripts/lib/swiftpm.sh"

usage() {
    printf '%s\n' \
        'Usage: scripts/contracts/run-spec-014.sh --profile <profile>' \
        '' \
        'Profiles: macos-dynamic, macos-static, raspberry-pi-armv6, nrf52840-embedded'
}

fail_usage() {
    printf 'error: %s\n' "$*" >&2
    usage >&2
    exit 2
}

profile=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile)
            [[ $# -ge 2 ]] || fail_usage '--profile requires a value'
            profile="$2"
            shift 2
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *) fail_usage "unknown option: $1" ;;
    esac
done

case "${profile}" in
    macos-dynamic | macos-static | raspberry-pi-armv6 | nrf52840-embedded) ;;
    "") fail_usage '--profile is required' ;;
    *) fail_usage "unknown profile: ${profile}" ;;
esac

declared_inputs() {
    {
        find "${FIXTURE_ROOT}" -type f -print
        find \
            "${PROJECT_ROOT}/Sources/GiftUISurfaceCore" \
            "${PROJECT_ROOT}/Sources/GiftUIRasterCore" \
            "${PROJECT_ROOT}/Sources/GiftUIDisplayCore" \
            "${PROJECT_ROOT}/Sources/GiftUIBackendIntegration" \
            "${PROJECT_ROOT}/Tests/GiftUISurfaceCoreTests" \
            "${PROJECT_ROOT}/Tests/GiftUIRasterCoreTests" \
            "${PROJECT_ROOT}/Tests/GiftUIDisplayCoreTests" \
            "${PROJECT_ROOT}/Tests/GiftUIBackendIntegrationTests" \
            -type f -print
        printf '%s\n' \
            "${PROJECT_ROOT}/Package.swift" \
            "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/target-dependencies.yaml" \
            "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC004/SemanticCorpus/cases.tsv" \
            "${PROJECT_ROOT}/docs/specs/spec-002-portable-foundation.md" \
            "${PROJECT_ROOT}/docs/specs/spec-014-backend-integration.md" \
            "${PROJECT_ROOT}/docs/implementation-plans/spec-014-implementation-plan.md" \
            "${SCRIPT_DIR}/check-driver-registry.rb" \
            "${SCRIPT_DIR}/check-spec-014-fixtures.rb" \
            "${SCRIPT_DIR}/check-spec-014-frame-work.rb" \
            "${SCRIPT_DIR}/check-spec-014-contributors.rb" \
            "${SCRIPT_DIR}/check-spec-014-capability-fixtures.rb" \
            "${SCRIPT_DIR}/check-spec-014-migration.rb" \
            "${SCRIPT_DIR}/check-spec-014-module-contract.rb" \
            "${SCRIPT_DIR}/check-spec-014-storage.rb" \
            "${SCRIPT_DIR}/check-spec-014-startup-validator.rb" \
            "${SCRIPT_DIR}/check-spec-014-text-resource.rb" \
            "${SCRIPT_DIR}/check-spec-014-transactions.rb" \
            "${SCRIPT_DIR}/check-spec-014-value-layouts.rb" \
            "${SCRIPT_DIR}/check-spec-014-value-profiles.sh" \
            "${SCRIPT_DIR}/check-target-dependencies.rb" \
            "${SCRIPT_DIR}/finalize-contract-metadata.rb" \
            "${SCRIPT_DIR}/publish-contract-report.rb" \
            "${SCRIPT_DIR}/report-input-identity.rb" \
            "${SCRIPT_DIR}/run-spec-014.sh" \
            "${SCRIPT_DIR}/verify-contract-report.rb"
    } | LC_ALL=C sort -u
}

revision="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
dirty=false
[[ -z "$(git -C "${PROJECT_ROOT}" status --porcelain --untracked-files=normal)" ]] || dirty=true
mkdir -p "${REPORT_ROOT}"
staging="${REPORT_ROOT}/.tmp-${profile}-$$"
[[ ! -e "${staging}" ]] || fail_usage "temporary report directory exists: ${staging}"
mkdir -p "${staging}"
inputs_path="${staging}/input-hashes.tsv"
identity_metadata="$(declared_inputs | "${SCRIPT_DIR}/report-input-identity.rb" \
    --root "${PROJECT_ROOT}" --revision "${revision}" --inventory "${inputs_path}")"
input_set_sha256="$(printf '%s\n' "${identity_metadata}" | awk -F= '$1 == "input_set_sha256" { print $2 }')"
run_id="$(printf '%s\n' "${identity_metadata}" | awk -F= '$1 == "run_id" { print $2 }')"
[[ -n "${input_set_sha256}" && -n "${run_id}" ]] || fail_usage 'input identity calculation failed'

destination="${REPORT_ROOT}/${run_id}/${profile}"
latest="${REPORT_ROOT}/latest-${profile}.txt"
metadata_path="${staging}/metadata.txt"
commands_path="${staging}/commands.txt"
prerequisites_path="${staging}/prerequisites.tsv"
evidence_path="${staging}/required-evidence.tsv"
log_path="${staging}/run.log"
: >"${commands_path}"
: >"${log_path}"
{
    printf 'spec=SPEC-014\nprofile=%s\n' "${profile}"
    printf 'repository_revision=%s\nrepository_dirty=%s\n' "${revision}" "${dirty}"
    printf 'input_set_sha256=%s\nrun_id=%s\n' "${input_set_sha256}" "${run_id}"
    printf 'invocation=scripts/contracts/run-spec-014.sh --profile %s\n' "${profile}"
    printf 'output_root=.build/spec-014\n'
    printf 'remote_access=false\ndeployment=false\nservice_restart=false\n'
    printf 'simulator_execution=false\nconnected_target_execution=false\nflashing=false\n'
} >"${metadata_path}"
printf '# item\tstatus\treason\n' >"${prerequisites_path}"
{
    printf '# criterion\tstatus\treason\n'
    awk -F $'\t' '!/^#/ && NF { print $1 "\tmissing\t" $3 }' \
        "${FIXTURE_ROOT}/required-evidence.tsv"
} >"${evidence_path}"

failures=0
record_command() {
    printf '%q ' "$@" >>"${commands_path}"
    printf '\n' >>"${commands_path}"
}

run_required() {
    local item="$1"
    shift
    local result
    record_command "$@"
    "$@" >>"${log_path}" 2>&1
    result=$?
    if [[ "${result}" -eq 0 ]]; then
        printf '%s\tcomplete\tcommand passed\n' "${item}" >>"${prerequisites_path}"
    else
        failures=$((failures + 1))
        printf '%s\tblocked\tcommand failed with exit %s\n' \
            "${item}" "${result}" >>"${prerequisites_path}"
    fi
}

require_path() {
    local item="$1"
    local path="$2"
    if [[ -e "${path}" ]]; then
        printf '%s\tcomplete\t%s\n' "${item}" "${path#"${PROJECT_ROOT}/"}" >>"${prerequisites_path}"
    else
        failures=$((failures + 1))
        printf '%s\tmissing\t%s\n' "${item}" "${path#"${PROJECT_ROOT}/"}" >>"${prerequisites_path}"
    fi
}

run_package_checks() {
    local package_json="${staging}/package.json"
    record_command giftui_swiftpm package dump-package
    giftui_swiftpm \
        --package-path "${PROJECT_ROOT}" \
        --scratch-path "${PROJECT_ROOT}/.build/spec-014/swiftpm/${profile}" \
        --cache-root "${PROJECT_ROOT}/.build/spec-014/cache/${profile}" \
        --disable-sandbox -- package dump-package >"${package_json}" 2>>"${log_path}"
    local result=$?
    if [[ "${result}" -ne 0 ]]; then
        failures=$((failures + 1))
        printf 'package-manifest\tblocked\tpackage dump failed with exit %s\n' "${result}" >>"${prerequisites_path}"
        return
    fi

    if "${SCRIPT_DIR}/check-target-dependencies.rb" <"${package_json}" >>"${log_path}" 2>&1 && \
        "${SCRIPT_DIR}/check-spec-014-module-contract.rb" <"${package_json}" >>"${log_path}" 2>&1; then
        printf 'package-graph\tcomplete\texact and reserved dependency graphs passed\n' >>"${prerequisites_path}"
    else
        failures=$((failures + 1))
        printf 'package-graph\tblocked\tdependency graph check failed\n' >>"${prerequisites_path}"
    fi
}

record_toolchain() {
    local result=0
    case "${profile}" in
        macos-dynamic | macos-static)
            record_command xcrun --find swiftc
            compiler="$(xcrun --find swiftc 2>>"${log_path}")" || result=$?
            if [[ "${result}" -eq 0 ]]; then
                version="$("${compiler}" --version 2>&1)" || result=$?
                sdk="$(xcrun --sdk macosx --show-sdk-path 2>>"${log_path}")" || result=$?
            fi
            if [[ "${result}" -eq 0 && "${version}" == *'Apple Swift version 6.3.3'* && \
                "${version}" == *'swiftlang-6.3.3.1.3'* && -d "${sdk}" ]]; then
                printf 'compiler_path=%s\ncompiler_version=%s\nsdk_path=%s\n' \
                    "${compiler}" "${version//$'\n'/ }" "${sdk}" >>"${metadata_path}"
                printf 'target=arm64-apple-macosx26.0\noptimization=-O -whole-module-optimization\n' >>"${metadata_path}"
                printf 'toolchain\tcomplete\tpinned Apple Swift and macOS SDK recorded\n' >>"${prerequisites_path}"
            else
                failures=$((failures + 1))
                printf 'toolchain\tblocked\tpinned Apple Swift 6.3.3 or macOS SDK unavailable\n' >>"${prerequisites_path}"
            fi
            ;;
        raspberry-pi-armv6)
            record_command "${PROJECT_ROOT}/scripts/raspberry-pi/doctor.sh"
            if "${PROJECT_ROOT}/scripts/raspberry-pi/doctor.sh" >>"${log_path}" 2>&1; then
                # shellcheck source=../raspberry-pi/common.sh
                source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
                printf 'compiler_version=%s\ntarget=%s\nsdk_path=%s\noptimization=-O -whole-module-optimization\n' \
                    "${GIFTUI_PI_SWIFT_VERSION}" "${GIFTUI_PI_TARGET}" "${GIFTUI_PI_SDK_DIR}" >>"${metadata_path}"
                printf 'toolchain\tcomplete\tpinned Raspberry Pi ARMv6 toolchain recorded\n' >>"${prerequisites_path}"
            else
                failures=$((failures + 1))
                printf 'toolchain\tblocked\tpinned Raspberry Pi ARMv6 toolchain unavailable\n' >>"${prerequisites_path}"
            fi
            ;;
        nrf52840-embedded)
            record_command "${PROJECT_ROOT}/scripts/nrf52840/doctor.sh"
            if "${PROJECT_ROOT}/scripts/nrf52840/doctor.sh" >>"${log_path}" 2>&1; then
                # shellcheck source=../nrf52840/common.sh
                source "${PROJECT_ROOT}/scripts/nrf52840/common.sh"
                printf 'compiler_version=%s\ntarget=%s\nboard=%s\nsdk_path=%s\noptimization=-Osize -whole-module-optimization\nfloat_abi=hard\n' \
                    "${GIFTUI_NRF_SWIFT_VERSION}" "${GIFTUI_NRF_SWIFT_TARGET}" \
                    "${GIFTUI_NRF_BOARD}" "${GIFTUI_NRF_SDK_DIR}" >>"${metadata_path}"
                printf 'toolchain\tcomplete\tpinned nRF52840 toolchain recorded\n' >>"${prerequisites_path}"
            else
                failures=$((failures + 1))
                printf 'toolchain\tblocked\tpinned nRF52840 toolchain unavailable\n' >>"${prerequisites_path}"
            fi
            ;;
    esac
}

run_required fixture-schema "${SCRIPT_DIR}/check-spec-014-fixtures.rb"
run_required migration-inventory "${SCRIPT_DIR}/check-spec-014-migration.rb"
run_required contributor-boundaries "${SCRIPT_DIR}/check-spec-014-contributors.rb"
run_required capability-fixtures \
    "${SCRIPT_DIR}/check-spec-014-capability-fixtures.rb"
run_required startup-validation-boundaries \
    "${SCRIPT_DIR}/check-spec-014-startup-validator.rb"
run_required frame-work-arithmetic "${SCRIPT_DIR}/check-spec-014-frame-work.rb"
run_required text-resource-boundary "${SCRIPT_DIR}/check-spec-014-text-resource.rb"
run_required transaction-oracle "${SCRIPT_DIR}/check-spec-014-transactions.rb"
run_required driver-registry "${SCRIPT_DIR}/check-driver-registry.rb"
run_package_checks
record_toolchain
run_required declaration-layout-and-imports \
    "${SCRIPT_DIR}/check-spec-014-value-profiles.sh" \
    --profile "${profile}" --output "${staging}/declarations"

for target in GiftUISurfaceCore GiftUIRasterCore GiftUIDisplayCore GiftUIBackendIntegration; do
    require_path "target-${target}" "${PROJECT_ROOT}/Sources/${target}"
done
for target in GiftUISurfaceCoreTests GiftUIRasterCoreTests GiftUIDisplayCoreTests GiftUIBackendIntegrationTests GiftUIBackendFailureAdapterTests; do
    require_path "test-target-${target}" "${PROJECT_ROOT}/Tests/${target}"
done
require_path target-GiftUIBackendFailureAdapterFixture \
    "${PROJECT_ROOT}/Sources/GiftUIBackendFailureAdapterFixture"

case_count="$(awk '/^cases:/ { if ($2 != "[]") populated += 1 } END { print populated + 0 }' \
    "${FIXTURE_ROOT}"/*.yaml)"
if [[ "${case_count}" -eq 0 ]]; then
    failures=$((failures + 1))
    printf 'fixture-corpus\tmissing\tall canonical case lists are empty\n' >>"${prerequisites_path}"
else
    printf 'fixture-corpus\tcomplete\tcanonical cases are populated\n' >>"${prerequisites_path}"
fi

missing_evidence="$(awk -F $'\t' '!/^#/ && $2 != "complete" { count += 1 } END { print count + 0 }' \
    "${evidence_path}")"
failures=$((failures + missing_evidence))
printf 'acceptance-evidence\tmissing\t%s criterion rows are incomplete\n' \
    "${missing_evidence}" >>"${prerequisites_path}"

if [[ "${failures}" -eq 0 ]]; then
    status=passed
    exit_code=0
else
    status=blocked
    exit_code=1
fi
printf 'status=%s\nexit_code=%s\nblocking_count=%s\n' \
    "${status}" "${exit_code}" "${failures}" >>"${metadata_path}"

relative_report=".build/spec-014/reports/${run_id}/${profile}"
"${SCRIPT_DIR}/finalize-contract-metadata.rb" \
    --path "${metadata_path}" --run-id "${run_id}" \
    --input-hash "${input_set_sha256}" --report-directory "${relative_report}"
"${SCRIPT_DIR}/publish-contract-report.rb" \
    --report-root "${REPORT_ROOT}" --staging "${staging}" \
    --destination "${destination}" --latest "${latest}" --run-id "${run_id}"

if [[ "${exit_code}" -ne 0 ]]; then
    printf 'SPEC-014 %s driver blocked with %s explicit incomplete assertion(s); see %s\n' \
        "${profile}" "${failures}" "${destination}" >&2
else
    printf 'SPEC-014 %s driver passed; run ID: %s\n' "${profile}" "${run_id}"
fi
exit "${exit_code}"
