#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
REGISTRY="${PROJECT_ROOT}/scripts/contracts/driver-registry.tsv"
usage() { printf 'Usage: scripts/check-spec.sh --spec SPEC-NNN (--profile PROFILE | --all-hardware-free)\n'; }
spec=""; selection=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --spec) spec="$2"; shift 2 ;;
        --profile) selection="$2"; shift 2 ;;
        --all-hardware-free) selection=all-hardware-free; shift ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'error: unknown option: %s\n' "$1" >&2; exit 2 ;;
    esac
done
[[ "${spec}" =~ ^SPEC-[0-9]{3}$ && -n "${selection}" ]] || { usage >&2; exit 2; }
row="$(awk -F '\t' -v wanted="${spec}" '$1 == wanted { print; exit }' "${REGISTRY}")"
[[ -n "${row}" ]] || { printf 'error: unregistered Specification: %s\n' "${spec}" >&2; exit 2; }
IFS=$'\t' read -r _ driver profile_list <<<"${row}"
IFS=',' read -ra profiles <<<"${profile_list}"
spec_slug="$(printf '%s' "${spec}" | tr '[:upper:]' '[:lower:]')"
if [[ "${selection}" == all-hardware-free ]]; then selected_profiles=("${profiles[@]}"); else selected_profiles=("${selection}"); fi
printf 'gate-level=%s spec=%s selection=%s\n' "$([[ "${selection}" == all-hardware-free ]] && printf specification || printf profile)" "${spec}" "${selection}"
failures=0
for profile in "${selected_profiles[@]}"; do
    case ",${profile_list}," in *",${profile},"*) ;; *) printf 'fail: unsupported profile %s\n' "${profile}" >&2; failures=$((failures + 1)); continue ;; esac
    printf 'command: %s --profile %s\n' "${driver}" "${profile}"
    if "${PROJECT_ROOT}/${driver}" --profile "${profile}"; then
        pointer="${PROJECT_ROOT}/.build/contract-reports/${spec_slug}/latest-${profile}.txt"
        run_id="-"; [[ ! -f "${pointer}" ]] || run_id="$(tr -d '\n' <"${pointer}")"
        printf 'pass: %s run-id=%s\n' "${profile}" "${run_id}"
    else printf 'fail: %s\n' "${profile}" >&2; failures=$((failures + 1)); fi
done
if [[ "${failures}" -eq 0 && "${selection}" == all-hardware-free ]]; then
    comparator="${PROJECT_ROOT}/scripts/contracts/compare-${spec_slug}-profile-semantics.rb"
    if [[ -x "${comparator}" ]]; then
        printf 'command: %s\n' "${comparator#"${PROJECT_ROOT}/"}"
        "${comparator}" || failures=$((failures + 1))
    else printf 'skipped: no registered cross-profile comparator\n'; fi
fi
printf 'specification-summary failed=%s\n' "${failures}"
[[ "${failures}" -eq 0 ]]
