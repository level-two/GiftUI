#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC015"
REPORT_ROOT="${PROJECT_ROOT}/.build/spec-015"

usage() {
    printf '%s\n' 'Usage: scripts/contracts/run-spec-015.sh --profile <profile>' \
        '' 'Profiles: macos-dynamic, macos-static, raspberry-pi-armv6, nrf52840-embedded'
}

profile=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile) [[ $# -ge 2 ]] || { usage >&2; exit 2; }; profile="$2"; shift 2 ;;
        -h | --help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done
case "${profile}" in
    macos-dynamic | macos-static | raspberry-pi-armv6 | nrf52840-embedded) ;;
    *) usage >&2; exit 2 ;;
esac

mkdir -p "${REPORT_ROOT}/${profile}"
input_identity="$(shasum -a 256 "${FIXTURE_ROOT}"/*.tsv | shasum -a 256 | awk '{print $1}')"
compiler_identity="$(swiftc --version 2>/dev/null | tr '\n' ' ')"
command_hash="$(printf '%s' "scripts/contracts/run-spec-015.sh --profile ${profile}" | shasum -a 256 | awk '{print $1}')"
output="${REPORT_ROOT}/${profile}/report.tsv"
{
    printf '# schema_version\tprofile\tinput_identity\tcompiler_identity\ttoolchain_identity\toptimization\tcommand_hash\toutput_hash\tstatus\tevidence_kind\n'
    printf '1\t%s\t%s\t%s\tlocal-pinned\tnone\t%s\tmissing\tmissing\thost-execution\n' \
        "${profile}" "${input_identity}" "${compiler_identity}" "${command_hash}"
} >"${output}"
printf 'SPEC-015 %s is fail-closed: implementation evidence is missing (%s)\n' "${profile}" "${output}" >&2
exit 1

