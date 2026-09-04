#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
spec=""; profile=""; driver=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --spec) spec="$2"; shift 2 ;;
        --profile) profile="$2"; shift 2 ;;
        --driver) driver="$2"; shift 2 ;;
        *) printf 'error: unknown immutable-driver option: %s\n' "$1" >&2; exit 2 ;;
    esac
done
[[ "${spec}" =~ ^SPEC-[0-9]{3}$ && -n "${profile}" && -x "${driver}" ]] || {
    printf 'error: --spec, --profile, and executable --driver are required\n' >&2; exit 2;
}
spec_slug="$(printf '%s' "${spec}" | tr '[:upper:]' '[:lower:]')"
report_root="${PROJECT_ROOT}/.build/contract-reports/${spec_slug}"
revision="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
mkdir -p "${report_root}"
preflight_inventory="${report_root}/.input-${profile}-$$.tsv"
{
    git -C "${PROJECT_ROOT}" ls-files
    printf '%s\n' \
        "scripts/contracts/report-input-identity.rb" \
        "scripts/contracts/publish-contract-report.rb" \
        "scripts/contracts/verify-contract-report.rb" \
        "scripts/contracts/finalize-contract-metadata.rb" \
        "scripts/contracts/run-immutable-contract-driver.sh" \
        "scripts/contracts/report-path.sh"
} | LC_ALL=C sort -u | "${SCRIPT_DIR}/report-input-identity.rb" \
    --root "${PROJECT_ROOT}" --revision "${revision}" --inventory "${preflight_inventory}" \
    >"${preflight_inventory}.identity"
input_hash="$(awk -F= '$1 == "input_set_sha256" { print $2 }' "${preflight_inventory}.identity")"
run_id="$(awk -F= '$1 == "run_id" { print $2 }' "${preflight_inventory}.identity")"
destination="${report_root}/${run_id}/${profile}"
latest="${report_root}/latest-${profile}.txt"
if [[ -d "${destination}" ]]; then
    "${SCRIPT_DIR}/verify-contract-report.rb" "${destination}"
    temporary_pointer="${report_root}/.latest-${profile}.tmp-$$"
    printf '%s\n' "${run_id}" >"${temporary_pointer}"
    mv "${temporary_pointer}" "${latest}"
    rm -f "${preflight_inventory}" "${preflight_inventory}.identity"
    printf '%s %s contract driver idempotent match; run ID: %s\n' "${spec}" "${profile}" "${run_id}"
    exit 0
fi
staging="${report_root}/.tmp-${profile}-$$"
[[ ! -e "${staging}" ]] || { printf 'error: staging path exists: %s\n' "${staging}" >&2; exit 1; }
if ! GIFTUI_IMMUTABLE_REPORT_INNER=true \
    GIFTUI_CONTRACT_REPORT_DIR="${staging}" \
    GIFTUI_CONTRACT_RUN_ID="${run_id}" \
    "${driver}" --profile "${profile}"; then
    rm -f "${preflight_inventory}" "${preflight_inventory}.identity"
    exit 1
fi
mv "${preflight_inventory}" "${staging}/input-hashes.tsv"
rm -f "${preflight_inventory}.identity"
relative_report=".build/contract-reports/${spec_slug}/${run_id}/${profile}"
"${SCRIPT_DIR}/finalize-contract-metadata.rb" \
    --path "${staging}/metadata.txt" --run-id "${run_id}" \
    --input-hash "${input_hash}" --report-directory "${relative_report}"
"${SCRIPT_DIR}/publish-contract-report.rb" \
    --report-root "${report_root}" --staging "${staging}" \
    --destination "${destination}" --latest "${latest}" --run-id "${run_id}"
printf '%s %s immutable report published; run ID: %s\n' "${spec}" "${profile}" "${run_id}"
