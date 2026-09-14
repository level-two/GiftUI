#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC013"
REPORT_ROOT="${PROJECT_ROOT}/.build/contract-reports/spec-013"

usage() {
    printf '%s\n' \
        'Usage: scripts/contracts/run-spec-013.sh --profile <profile>' \
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
    find "${FIXTURE_ROOT}" -type f -print
    find \
        "${PROJECT_ROOT}/Sources/GiftUIRuntimeCore" \
        "${PROJECT_ROOT}/Sources/GiftUIRuntimeDynamic" \
        "${PROJECT_ROOT}/Sources/GiftUIRuntimeStatic" \
        "${PROJECT_ROOT}/Tests/GiftUIRuntimeCoreTests" \
        "${PROJECT_ROOT}/Tests/GiftUIRuntimeDynamicTests" \
        "${PROJECT_ROOT}/Tests/GiftUIRuntimeStaticTests" \
        "${PROJECT_ROOT}/Tests/GiftUIRuntimeConformanceTests" \
        -type f -print
    find "${SCRIPT_DIR}" -maxdepth 1 -type f -name '*spec-013*' -print
    printf '%s\n' \
        "${PROJECT_ROOT}/Package.swift" \
        "${PROJECT_ROOT}/docs/specs/spec-013-runtime-profiles.md" \
        "${PROJECT_ROOT}/docs/implementation-plans/spec-013-implementation-plan.md" \
        "${SCRIPT_DIR}/finalize-contract-metadata.rb" \
        "${SCRIPT_DIR}/publish-contract-report.rb" \
        "${SCRIPT_DIR}/report-input-identity.rb" \
        "${SCRIPT_DIR}/verify-contract-report.rb"
}

revision="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
dirty=false
[[ -z "$(git -C "${PROJECT_ROOT}" status --porcelain --untracked-files=normal)" ]] || dirty=true
mkdir -p "${REPORT_ROOT}"
staging="${REPORT_ROOT}/.tmp-${profile}-$$"
mkdir -p "${staging}"
inputs_path="${staging}/input-hashes.tsv"
identity_metadata="$(declared_inputs | LC_ALL=C sort -u | "${SCRIPT_DIR}/report-input-identity.rb" \
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
    printf 'spec=SPEC-013\nprofile=%s\n' "${profile}"
    printf 'repository_revision=%s\nrepository_dirty=%s\n' "${revision}" "${dirty}"
    printf 'input_set_sha256=%s\nrun_id=%s\n' "${input_set_sha256}" "${run_id}"
    printf 'invocation=scripts/contracts/run-spec-013.sh --profile %s\n' "${profile}"
    printf 'remote_access=false\ndeployment=false\nservice_restart=false\n'
    printf 'simulator_execution=false\nconnected_target_execution=false\nflashing=false\n'
} >"${metadata_path}"
printf '# item\tstatus\treason\n' >"${prerequisites_path}"
{
    printf '# criterion\tstatus\treason\n'
    awk -F $'\t' '!/^#/ && NF { print $1 "\tmissing\t" $3 }' "${FIXTURE_ROOT}/required-evidence.tsv"
} >"${evidence_path}"

failures=0
record_command() {
    local argument
    for argument in "$@"; do
        if [[ "${argument}" == "${staging}" ]]; then
            argument='<report-staging>'
        fi
        printf '%q ' "${argument}" >>"${commands_path}"
    done
    printf '\n' >>"${commands_path}"
}
run_required() {
    local item="$1"
    shift
    local command_output
    record_command "$@"
    if command_output="$("$@" 2>&1)"; then
        printf '%s\tcomplete\tcommand passed\n' "${item}" >>"${prerequisites_path}"
    else
        local result=$?
        failures=$((failures + 1))
        printf '%s\tblocked\tcommand failed with exit %s\n' "${item}" "${result}" >>"${prerequisites_path}"
        printf '[%s]\n%s\n' "${item}" "${command_output}" >>"${log_path}"
    fi
}

run_required fixture-schema "${SCRIPT_DIR}/check-spec-013-harness.rb"
run_required report-driver "${SCRIPT_DIR}/check-spec-013-report-driver.rb"
run_required resource-instrumentation "${SCRIPT_DIR}/check-spec-013-resource-instrumentation.sh"
run_required migration-inventory "${SCRIPT_DIR}/check-spec-013-migration.rb"
run_required module-contract "${SCRIPT_DIR}/check-spec-013-module-contract.sh"
run_required storage-boundaries "${SCRIPT_DIR}/check-spec-013-storage-boundaries.rb"
run_required startup-corpus "${SCRIPT_DIR}/check-spec-013-startup-corpus.rb"
run_required cycle-failures "${SCRIPT_DIR}/check-spec-013-cycle-failures.rb"
run_required handoff-recovery "${SCRIPT_DIR}/check-spec-013-handoff-recovery.rb"
run_required borrow-boundaries "${SCRIPT_DIR}/check-spec-013-borrow-boundaries.rb"
run_required equivalence "${SCRIPT_DIR}/check-spec-013-equivalence.rb"

compiler_id=unavailable
sdk_id=none
target_id=unknown
evidence_class=inspection
case "${profile}" in
    macos-dynamic | macos-static)
        compiler_path="$(xcrun --find swiftc 2>>"${log_path}")" || compiler_path=""
        sdk_id="$(xcrun --sdk macosx --show-sdk-path 2>>"${log_path}")" || sdk_id=none
        if [[ -n "${compiler_path}" ]]; then
            compiler_id="${compiler_path} :: $("${compiler_path}" --version 2>&1 | tr '\n' ' ')"
            target_id=arm64-apple-macosx26.0
            evidence_class=host-execution
            printf 'toolchain\tcomplete\tApple Swift and macOS SDK recorded\n' >>"${prerequisites_path}"
        else
            failures=$((failures + 1))
            printf 'toolchain\tblocked\tApple Swift unavailable\n' >>"${prerequisites_path}"
        fi
        ;;
    raspberry-pi-armv6)
        if toolchain_output="$("${PROJECT_ROOT}/scripts/raspberry-pi/doctor.sh" 2>&1)"; then
            source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
            compiler_path="$(giftui_pi_host_swift)"
            compiler_id="${compiler_path} :: $("${compiler_path}" --version 2>&1 | tr '\n' ' ')"
            sdk_id="${GIFTUI_PI_SDK_DIR}"
            target_id="${GIFTUI_PI_TARGET}"
            evidence_class=cross-build
            printf 'toolchain\tcomplete	Raspberry Pi ARMv6 toolchain recorded\n' >>"${prerequisites_path}"
        else
            failures=$((failures + 1))
            printf 'toolchain\tblocked	Raspberry Pi ARMv6 toolchain unavailable\n' >>"${prerequisites_path}"
        fi
        ;;
    nrf52840-embedded)
        if toolchain_output="$("${PROJECT_ROOT}/scripts/nrf52840/doctor.sh" 2>&1)"; then
            source "${PROJECT_ROOT}/scripts/nrf52840/common.sh"
            compiler_id="${GIFTUI_NRF_SWIFTC} :: $("${GIFTUI_NRF_SWIFTC}" --version 2>&1 | tr '\n' ' ')"
            sdk_id="${GIFTUI_NRF_SDK_DIR}"
            target_id="${GIFTUI_NRF_SWIFT_TARGET}"
            evidence_class=cross-build
            printf 'toolchain\tcomplete	nRF52840 toolchain recorded\n' >>"${prerequisites_path}"
        else
            failures=$((failures + 1))
            printf 'toolchain\tblocked	nRF52840 toolchain unavailable\n' >>"${prerequisites_path}"
        fi
        ;;
esac

fixture_result=pass
[[ "${failures}" -eq 0 ]] || fixture_result=fail
run_required normalized-report "${SCRIPT_DIR}/report-spec-013-profile.rb" \
    --root "${PROJECT_ROOT}" --output "${staging}" --profile "${profile}" \
    --revision "${revision}" --dirty "${dirty}" --evidence-class "${evidence_class}" \
    --compiler "${compiler_id}" --sdk "${sdk_id}" --target "${target_id}" \
    --fixture-result "${fixture_result}" \
    --command "scripts/contracts/run-spec-013.sh --profile ${profile}"

failures=$((failures + 1))
printf 'resource-collection\tblocked\tT7.3 scans and T7.4 pristine profile collection are not complete\n' >>"${prerequisites_path}"
printf 'status=blocked\nexit_code=1\nblocking_count=%s\n' "${failures}" >>"${metadata_path}"

relative_report=".build/contract-reports/spec-013/${run_id}/${profile}"
"${SCRIPT_DIR}/finalize-contract-metadata.rb" \
    --path "${metadata_path}" --run-id "${run_id}" \
    --input-hash "${input_set_sha256}" --report-directory "${relative_report}"
if ! "${SCRIPT_DIR}/publish-contract-report.rb" \
    --report-root "${REPORT_ROOT}" --staging "${staging}" \
    --destination "${destination}" --latest "${latest}" --run-id "${run_id}"; then
    printf 'error: SPEC-013 %s report publication failed\n' "${profile}" >&2
    exit 1
fi
printf 'SPEC-013 %s report finalized with T7.3/T7.4 collection blocked; run ID: %s\n' "${profile}" "${run_id}" >&2
exit 1
