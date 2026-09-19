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
run_check ruby "${SCRIPT_DIR}/check-spec-011-boundaries.rb"
run_check ruby "${SCRIPT_DIR}/check-spec-011-diagnostic-isolation.rb"
run_check ruby "${SCRIPT_DIR}/check-spec-011-declaration-surface.rb"
run_check ruby "${SCRIPT_DIR}/check-spec-011-migration.rb"
run_check ruby "${SCRIPT_DIR}/check-spec-011-integration-audit.rb"

run_check swift test --disable-sandbox --scratch-path "${PROJECT_ROOT}/.build" \
    --filter GiftUIInteractionTests
run_check swift test --disable-sandbox --scratch-path "${PROJECT_ROOT}/.build" \
    --filter GiftUIInteractionFailureAdapterTests
run_check swift test --disable-sandbox --scratch-path "${PROJECT_ROOT}/.build" \
    --filter RuntimeInteraction
run_check swift test --disable-sandbox --scratch-path "${PROJECT_ROOT}/.build" \
    --filter ProfileDifferentialTests

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

run_check "${SCRIPT_DIR}/run-spec-013.sh" --profile "${profile}"
run_check env -u GIFTUI_IMMUTABLE_REPORT_INNER -u GIFTUI_CONTRACT_REPORT_DIR \
    -u GIFTUI_CONTRACT_RUN_ID "${SCRIPT_DIR}/run-spec-015.sh" --profile "${profile}"

spec013_latest="${PROJECT_ROOT}/.build/contract-reports/spec-013/latest-${profile}.txt"
spec015_latest="${PROJECT_ROOT}/.build/contract-reports/spec-015/latest-${profile}.txt"
[[ -f "${spec013_latest}" && -f "${spec015_latest}" ]]
spec013_run="$(cat "${spec013_latest}")"
spec015_run="$(cat "${spec015_latest}")"
spec013_report="${PROJECT_ROOT}/.build/contract-reports/spec-013/${spec013_run}/${profile}"
spec015_report="${PROJECT_ROOT}/.build/contract-reports/spec-015/${spec015_run}/${profile}"
run_check "${SCRIPT_DIR}/verify-contract-report.rb" "${spec013_report}"
run_check "${SCRIPT_DIR}/verify-contract-report.rb" "${spec015_report}"

{
    printf 'dependency\trun_id\treport_sha256\n'
    printf 'SPEC-013\t%s\t%s\n' "${spec013_run}" \
        "$(shasum -a 256 "${spec013_report}/metadata.txt" | awk '{print $1}')"
    printf 'SPEC-015\t%s\t%s\n' "${spec015_run}" \
        "$(shasum -a 256 "${spec015_report}/metadata.txt" | awk '{print $1}')"
} >"${report_dir}/composed-evidence.tsv"

{
    printf '# criterion\tstatus\tevidence\n'
    awk -F $'\t' '!/^#/ && NF { print $1 "\tcomplete\t" $3 }' \
        "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC011/required-evidence.tsv"
} >"${report_dir}/criterion-evidence.tsv"

cp "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC011/required-evidence.tsv" \
    "${report_dir}/required-evidence.tsv"
printf 'status=complete\nexit_code=0\nblocking_count=0\n' >>"${report_dir}/metadata.txt"
printf 'SPEC-011 %s complete; composed SPEC-013 resource and SPEC-015 artifact evidence: %s\n' \
    "${profile}" "${report_dir}"
