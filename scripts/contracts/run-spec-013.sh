#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC013"
REPORT_ROOT="${PROJECT_ROOT}/.build/contract-reports/spec-013"
# shellcheck source=../lib/swiftpm.sh
source "${PROJECT_ROOT}/scripts/lib/swiftpm.sh"

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

revision="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
dirty=false
[[ -z "$(git -C "${PROJECT_ROOT}" status --porcelain --untracked-files=normal)" ]] || dirty=true
mkdir -p "${REPORT_ROOT}"
report_dir="${REPORT_ROOT}/.tmp-${profile}-$$"
mkdir -p "${report_dir}"
metadata_path="${report_dir}/metadata.txt"
commands_path="${report_dir}/commands.txt"
prerequisites_path="${report_dir}/prerequisites.tsv"
evidence_path="${report_dir}/required-evidence.tsv"
log_path="${report_dir}/run.log"
: >"${commands_path}"
: >"${log_path}"

{
    printf 'schema_version=1\nspec=SPEC-013\nprofile=%s\n' "${profile}"
    printf 'repository_revision=%s\nrepository_dirty=%s\n' "${revision}" "${dirty}"
    printf 'invocation=scripts/contracts/run-spec-013.sh --profile %s\n' "${profile}"
    printf 'status=collecting\n'
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
        printf '%s\tblocked\tmissing %s\n' "${item}" "${path#"${PROJECT_ROOT}/"}" >>"${prerequisites_path}"
    fi
}

run_required fixture-schema "${SCRIPT_DIR}/check-spec-013-harness.rb"
run_required migration-inventory "${SCRIPT_DIR}/check-spec-013-migration.rb"
run_required package-manifest giftui_swiftpm \
    --package-path "${PROJECT_ROOT}" \
    --scratch-path "${report_dir}/swiftpm" \
    --cache-root "${report_dir}" \
    --disable-sandbox \
    -- package dump-package
run_required module-contract "${SCRIPT_DIR}/check-spec-013-module-contract.sh"
run_required storage-boundaries "${SCRIPT_DIR}/check-spec-013-storage-boundaries.rb"

for target in GiftUIRuntimeCore GiftUIRuntimeDynamic GiftUIRuntimeStatic GiftUIRuntimeFailureAdapterFixture; do
    require_path "target-${target}" "${PROJECT_ROOT}/Sources/${target}"
done
for target in GiftUIRuntimeCoreTests GiftUIRuntimeDynamicTests GiftUIRuntimeStaticTests GiftUIRuntimeConformanceTests GiftUIRuntimeFailureAdapterTests; do
    require_path "test-target-${target}" "${PROJECT_ROOT}/Tests/${target}"
done

case "${profile}" in
    macos-dynamic | macos-static)
        run_required toolchain xcrun --find swiftc
        run_required sdk xcrun --sdk macosx --show-sdk-path
        ;;
    raspberry-pi-armv6)
        run_required toolchain "${PROJECT_ROOT}/scripts/raspberry-pi/doctor.sh"
        ;;
    nrf52840-embedded)
        run_required toolchain "${PROJECT_ROOT}/scripts/nrf52840/doctor.sh"
        ;;
esac

case_count="$(awk '/^cases:/ { if ($2 != "[]") populated += 1 } END { print populated + 0 }' "${FIXTURE_ROOT}"/*.yaml)"
if [[ "${case_count}" -eq 0 ]]; then
    failures=$((failures + 1))
    printf 'fixture-corpus\tblocked\tall canonical case lists are empty\n' >>"${prerequisites_path}"
else
    printf 'fixture-corpus\tcomplete\tcanonical cases are populated\n' >>"${prerequisites_path}"
fi

if [[ "${failures}" -ne 0 ]]; then
    printf 'status=blocked\nexit_code=1\nblocking_count=%s\n' "${failures}" >>"${metadata_path}"
    printf 'SPEC-013 %s harness blocked with %s prerequisite failure(s); see %s\n' \
        "${profile}" "${failures}" "${report_dir}" >&2
    exit 1
fi

printf 'status=ready-for-implementation-evidence\nexit_code=1\nblocking_count=1\n' >>"${metadata_path}"
printf 'profile-evidence\tblocked\tT1 through T7 evidence commands are not yet implemented\n' >>"${prerequisites_path}"
printf 'SPEC-013 %s harness remains fail-closed until implementation evidence lands; see %s\n' \
    "${profile}" "${report_dir}" >&2
exit 1
