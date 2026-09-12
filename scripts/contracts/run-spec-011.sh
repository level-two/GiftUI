#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"

profile=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile) profile="${2:-}"; shift 2 ;;
        -h | --help)
            printf 'Usage: scripts/contracts/run-spec-011.sh --profile <profile>\n'
            exit 0
            ;;
        *) printf 'error: unknown option: %s\n' "$1" >&2; exit 2 ;;
    esac
done

case "${profile}" in
    macos-dynamic | macos-static | raspberry-pi-armv6 | nrf52840-embedded) ;;
    "") printf 'error: --profile is required\n' >&2; exit 2 ;;
    *) printf 'error: unknown profile: %s\n' "${profile}" >&2; exit 2 ;;
esac

if [[ "${GIFTUI_IMMUTABLE_REPORT_INNER:-false}" != true ]]; then
    exec "${SCRIPT_DIR}/run-immutable-contract-driver.sh" \
        --spec SPEC-011 --profile "${profile}" --driver "$0"
fi

report_dir="${GIFTUI_CONTRACT_REPORT_DIR:?missing report staging directory}"
run_id="${GIFTUI_CONTRACT_RUN_ID:?missing report run identity}"
mkdir -p "${report_dir}"
revision="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
dirty=false
[[ -z "$(git -C "${PROJECT_ROOT}" status --porcelain --untracked-files=normal)" ]] || dirty=true

{
    printf 'schema_version=1\nspec=SPEC-011\nprofile=%s\n' "${profile}"
    printf 'repository_revision=%s\nrepository_dirty=%s\nrun_id=%s\n' "${revision}" "${dirty}" "${run_id}"
    printf 'status=collecting\nexit_code=1\n'
    printf 'host_execution=%s\n' "$([[ "${profile}" == macos-* ]] && printf true || printf false)"
    printf 'cross_build_inspection=%s\n' "$([[ "${profile}" != macos-* ]] && printf true || printf false)"
    printf 'simulator_execution=false\nconnected_target_execution=false\nflashing=false\n'
} >"${report_dir}/metadata.txt"
: >"${report_dir}/commands.txt"

run_check() {
    printf '%q ' "$@" >>"${report_dir}/commands.txt"
    printf '\n' >>"${report_dir}/commands.txt"
    "$@" >>"${report_dir}/run.log" 2>&1
}

run_check ruby "${SCRIPT_DIR}/check-spec-011-harness.rb"
run_check ruby "${SCRIPT_DIR}/check-spec-011-declaration-surface.rb"
run_check ruby "${SCRIPT_DIR}/check-spec-011-migration.rb"

case "${profile}" in
    macos-dynamic | macos-static)
        run_check xcrun --find swiftc
        run_check xcrun --sdk macosx --show-sdk-path
        ;;
    raspberry-pi-armv6)
        run_check "${PROJECT_ROOT}/scripts/raspberry-pi/doctor.sh"
        ;;
    nrf52840-embedded)
        run_check "${PROJECT_ROOT}/scripts/nrf52840/doctor.sh"
        ;;
esac

cp "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC011/required-evidence.tsv" \
    "${report_dir}/required-evidence.tsv"
printf 'SPEC-011 %s remains fail-closed: T5-T9 profile evidence is pending; staging report: %s\n' \
    "${profile}" "${report_dir}" >&2
exit 1
