#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
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
        '' \
        'With no argument, runs the fast macos-dynamic gate.' \
        'Profiles:' \
        '  macos-dynamic' \
        '  macos-static' \
        '  raspberry-pi-armv6' \
        '  nrf52840-embedded' \
        '  all-hardware-free'
}

selection="${1:-macos-dynamic}"
if [[ $# -gt 1 ]]; then
    usage >&2
    exit 2
fi
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

report_dir="${REPORT_ROOT}/${selection}"
rm -rf "${report_dir}"
mkdir -p \
    "${report_dir}/logs" \
    "${report_dir}/swiftpm-cache" \
    "${report_dir}/clang-cache"
results_path="${report_dir}/results.tsv"
metadata_path="${report_dir}/metadata.txt"
: >"${results_path}"

if [[ "${selection}" == "all-hardware-free" ]]; then
    selected_profiles=("${ALL_PROFILES[@]}")
else
    selected_profiles=("${selection}")
fi

{
    printf 'schema_version=1\n'
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
    printf '==> %s\n' "${id}"
    "$@" >"${log}" 2>&1
    result=$?
    printf '%s\t%s\t%s\n' "${id}" "${result}" "${log#"${PROJECT_ROOT}/"}" >>"${results_path}"
    if [[ "${result}" -ne 0 ]]; then
        failures=$((failures + 1))
        printf 'fail: %s (exit %s; %s)\n' "${id}" "${result}" "${log}" >&2
    else
        printf 'pass: %s\n' "${id}"
    fi
}

run_check governance "${PROJECT_ROOT}/scripts/validate-governance.rb"
run_check driver-registry "${PROJECT_ROOT}/scripts/contracts/check-driver-registry.rb"

export CLANG_MODULE_CACHE_PATH="${report_dir}/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${report_dir}/swiftpm-cache"
run_check root-tests swift test --package-path "${PROJECT_ROOT}" \
    --scratch-path "${report_dir}/swiftpm"

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
if [[ "${failures}" -ne 0 ]]; then
    printf '%s check(s) failed; see %s\n' "${failures}" "${report_dir}" >&2
    exit 1
fi

printf 'All %s checks passed; reports: %s\n' "${selection}" "${report_dir}"
