#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
source "${PROJECT_ROOT}/scripts/lib/swiftpm.sh"

usage() {
    printf '%s\n' 'Usage: scripts/contracts/check-spec-013-workloads.sh --profile <profile> --output <path>'
}

profile=""
output=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile) profile="$2"; shift 2 ;;
        --output) output="$2"; shift 2 ;;
        -h | --help) usage; exit 0 ;;
        *) printf 'error: unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
done

case "${profile}" in
    macos-dynamic | macos-static | raspberry-pi-armv6 | nrf52840-embedded) ;;
    *) printf 'error: invalid or missing profile\n' >&2; exit 2 ;;
esac
[[ -n "${output}" ]] || { printf 'error: --output is required\n' >&2; exit 2; }

scratch="${PROJECT_ROOT}/.build/spec-013-workload"
cache="${PROJECT_ROOT}/.build/spec-013-workload-cache"
run_log="$(mktemp "${TMPDIR:-/tmp}/giftui-spec013-workload.XXXXXX")"
trap 'rm -f "${run_log}"' EXIT

giftui_swiftpm \
    --package-path "${PROJECT_ROOT}" \
    --scratch-path "${scratch}" \
    --cache-root "${cache}" \
    --disable-sandbox \
    -- test --filter spec013SmallFixtureWorkloadCycleTiming >"${run_log}" 2>&1
giftui_swiftpm \
    --package-path "${PROJECT_ROOT}" \
    --scratch-path "${scratch}" \
    --cache-root "${cache}" \
    --disable-sandbox \
    -- test --skip-build --filter spec013SignalAnalyzerWorkloadCycleTiming >>"${run_log}" 2>&1

small="$(sed -n 's/^.*SPEC013_WORKLOAD[[:space:]]small-fixture[[:space:]]\([0-9][0-9]*\)[[:space:]]1000[[:space:]]8000.*$/\1/p' "${run_log}" | tail -1)"
analyzer="$(sed -n 's/^.*SPEC013_WORKLOAD[[:space:]]signal-analyzer[[:space:]]\([0-9][0-9]*\)[[:space:]]100[[:space:]]3600.*$/\1/p' "${run_log}" | tail -1)"
[[ -n "${small}" && -n "${analyzer}" ]] || {
    printf 'error: SPEC-013 workload timing output is incomplete\n' >&2
    cat "${run_log}" >&2
    exit 1
}

mkdir -p "$(dirname "${output}")"
{
    printf '# workload\ttotalNanoseconds\titerations\tresultChecksum\tevidenceClass\tprofileBinding\n'
    printf 'small-fixture\t%s\t1000\t8000\thost-execution\tprofile-neutral\n' "${small}"
    printf 'signal-analyzer\t%s\t100\t3600\thost-execution\tdynamic-and-static\n' "${analyzer}"
} >"${output}"

printf 'SPEC-013 %s workload evidence passed: small=%s ns, signal-analyzer=%s ns.\n' \
    "${profile}" "${small}" "${analyzer}"
