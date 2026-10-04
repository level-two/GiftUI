#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
# Serialize shared build/cache writers; nested checks inherit the owner.
if [[ -z "${GIFTUI_VALIDATION_LOCK_OWNER:-}" ]]; then
    exec ruby "${PROJECT_ROOT}/scripts/lib/serialize-validation.rb" "$0" "$@"
fi
# shellcheck source=lib/swiftpm.sh
source "${PROJECT_ROOT}/scripts/lib/swiftpm.sh"
REGISTRY="${PROJECT_ROOT}/scripts/contracts/driver-registry.tsv"
REPORT_ROOT="${PROJECT_ROOT}/.build/test-reports"
ALL_PROFILES=(
    macos-dynamic
    macos-static
    raspberry-pi-armv6
    nrf52840-embedded
)

usage() {
    printf '%s\n' \
        'Usage: scripts/test.sh [profile]' \
        '       scripts/test.sh --profile <profile>' \
        '' \
        'With no argument, runs the fast macos-dynamic gate.' \
        'Profiles:' \
        '  macos-dynamic' \
        '  macos-static' \
        '  raspberry-pi-armv6' \
        '  nrf52840-embedded' \
        '  all-hardware-free'
}

selection="macos-dynamic"
case $# in
    0) ;;
    1) selection="$1" ;;
    2)
        if [[ "$1" != "--profile" ]]; then
            usage >&2
            exit 2
        fi
        selection="$2"
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac
case "${selection}" in
    -h | --help)
        usage
        exit 0
        ;;
    macos-dynamic | macos-static | raspberry-pi-armv6 | nrf52840-embedded | all-hardware-free) ;;
    *)
        printf 'error: unknown test profile: %s\n' "${selection}" >&2
        usage >&2
        exit 2
        ;;
esac

mkdir -p "${REPORT_ROOT}/${selection}"
report_dir="$(mktemp -d "${REPORT_ROOT}/${selection}/run-XXXXXXXX")"
invocation_id="${report_dir##*/}"
mkdir -p \
    "${report_dir}/logs" \
    "${report_dir}/swiftpm-cache" \
    "${report_dir}/clang-cache"
results_path="${report_dir}/results.tsv"
metadata_path="${report_dir}/metadata.txt"
: >"${results_path}"
child_ledger="${report_dir}/child-reports.tsv"
: >"${child_ledger}"
export GIFTUI_TEST_CHILD_REPORT_LEDGER="${child_ledger}"
status="running"
active_check="none"
finish_run() {
    local exit_code=$?
    printf 'status=%s\nexit_code=%s\nactive_check=%s\n' "${status}" "${exit_code}" "${active_check}" >>"${metadata_path}"
    if [[ "${status}" == interrupted ]]; then
        printf '%s\t%s\t%s\n' "${active_check}" "${exit_code}" "interrupted" >>"${results_path}"
    fi
    for staging in "${PROJECT_ROOT}"/.build/contract-reports/*/.tmp-* "${PROJECT_ROOT}"/.build/spec-014/reports/.tmp-*; do
        [[ -d "${staging}" ]] || continue
        printf 'retained-staging\t%s\t%s\n' "${staging#"${PROJECT_ROOT}/"}" "incomplete" >>"${child_ledger}"
    done
    local pointer="${REPORT_ROOT}/latest-${selection}.txt"
    printf '%s\n' "${report_dir#"${REPORT_ROOT}/"}" >"${pointer}.tmp-$$"
    mv "${pointer}.tmp-$$" "${pointer}"
}
trap finish_run EXIT
trap 'status=interrupted; exit 130' INT
trap 'status=interrupted; exit 143' TERM
trap 'status=interrupted; exit 129' HUP

if [[ "${selection}" == "all-hardware-free" ]]; then
    selected_profiles=("${ALL_PROFILES[@]}")
else
    selected_profiles=("${selection}")
fi

{
    printf 'schema_version=1\n'
    printf 'invocation_id=%s\n' "${invocation_id}"
    printf 'selection=%s\n' "${selection}"
    printf 'repository_revision=%s\n' "$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
    printf 'profiles=%s\n' "$(IFS=,; printf '%s' "${selected_profiles[*]}")"
    printf 'contract_report_root=.build/contract-reports\n'
} >"${metadata_path}"

failures=0
run_check() {
    local id="$1"
    shift
    local log="${report_dir}/logs/${id}.log"
    local result
    active_check="${id}"
    printf '==> %s\n' "${id}"
    "$@" >"${log}" 2>&1
    result=$?
    last_check_status="${result}"
    for pointer in "${PROJECT_ROOT}"/.build/contract-reports/*/latest-*.txt "${PROJECT_ROOT}"/.build/spec-014/reports/latest-*.txt; do
        [[ -f "${pointer}" ]] || continue
        printf '%s\t%s\t%s\n' "${id}" "${pointer#"${PROJECT_ROOT}/"}" "$(cat "${pointer}")" >>"${child_ledger}"
    done
    printf '%s\t%s\t%s\n' "${id}" "${result}" "${log#"${PROJECT_ROOT}/"}" >>"${results_path}"
    active_check="none"
    if [[ "${result}" -ne 0 ]]; then
        failures=$((failures + 1))
        printf 'fail: %s (exit %s; %s)\n' "${id}" "${result}" "${log}" >&2
    else
        printf 'pass: %s\n' "${id}"
    fi
}

run_check governance "${PROJECT_ROOT}/scripts/validate-governance.rb"
run_check governance-tooling "${PROJECT_ROOT}/scripts/governance/test.sh"
run_check swift-format "${PROJECT_ROOT}/scripts/format-swift.sh" --lint
run_check driver-registry "${PROJECT_ROOT}/scripts/contracts/check-driver-registry.rb"
run_check nrf-topology python3 "${PROJECT_ROOT}/scripts/contracts/check-spec-001-nrf-topology.py"
run_check nrf-source-selection python3 "${PROJECT_ROOT}/scripts/contracts/check-nrf-source-selection.py"
run_check spec-013-migration "${PROJECT_ROOT}/scripts/contracts/check-spec-013-migration.rb"
run_check spec-013-dynamic-binding "${PROJECT_ROOT}/scripts/contracts/check-spec-013-dynamic-binding.rb"
run_check spec-013-static-generated-fixture "${PROJECT_ROOT}/scripts/contracts/check-spec-013-static-generated-fixture.rb"
run_check spec-013-static-storage "${PROJECT_ROOT}/scripts/contracts/check-spec-013-static-storage.rb"
run_check spec-013-macos-static \
    "${PROJECT_ROOT}/scripts/contracts/check-spec-013-static-profiles.sh" \
    --profile macos-static --output "${report_dir}/spec-013-macos-static"
run_check spec-013-nrf-static \
    "${PROJECT_ROOT}/scripts/contracts/check-spec-013-static-profiles.sh" \
    --profile nrf52840-embedded --output "${report_dir}/spec-013-nrf-static"

run_check root-tests giftui_swiftpm \
    --package-path "${PROJECT_ROOT}" \
    --scratch-path "${report_dir}/swiftpm" \
    --cache-root "${report_dir}" \
    --swift-flag -DGIFTUI_DYNAMIC_PROFILE \
    -- test
# The two complete macOS reference corpora run in root-tests. Reuse that
# successful shared check across profile drivers; standalone drivers run them.
if [[ "${last_check_status}" -eq 0 ]]; then
    export GIFTUI_SHARED_REFERENCE_ALREADY_TESTED=1
fi
run_check spec-003-diagnostic-buffer \
    "${PROJECT_ROOT}/scripts/contracts/check-spec-003-diagnostic-buffer.sh"

for selected_profile in "${selected_profiles[@]}"; do
    matched=0
    while IFS=$'\t' read -r id driver profile_list; do
        [[ -n "${id}" && "${id}" != \#* ]] || continue
        case ",${profile_list}," in
            *,"${selected_profile}",*)
                matched=$((matched + 1))
                run_check "${id}-${selected_profile}" \
                    "${PROJECT_ROOT}/${driver}" --profile "${selected_profile}"
                ;;
        esac
    done <"${REGISTRY}"
    if [[ "${matched}" -eq 0 ]]; then
        failures=$((failures + 1))
        printf 'missing-driver-%s\t1\t-\n' "${selected_profile}" >>"${results_path}"
        printf 'fail: no registered contract driver supports %s\n' "${selected_profile}" >&2
    fi
done

printf 'failure_count=%s\n' "${failures}" >>"${metadata_path}"
status="complete"
if [[ "${failures}" -ne 0 ]]; then
    status="failed"
    printf '%s check(s) failed; see %s\n' "${failures}" "${report_dir}" >&2
    exit 1
fi

printf 'All %s checks passed; reports: %s\n' "${selection}" "${report_dir}"
