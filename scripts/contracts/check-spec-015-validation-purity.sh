#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
VALIDATOR="${PROJECT_ROOT}/Sources/GiftUIHostConfiguration/CheckedMVPHostConfigurationValidator.swift"

fail() {
    printf 'SPEC-015 validation purity check failed: %s\n' "$*" >&2
    exit 1
}

expected_stages='graph runtimeProfile textResources workload capability endpoint actionAndModel inputAndWake policy '
actual_stages="$(sed -n 's/.*guard enter(\.\([A-Za-z]*\)).*/\1/p' "${VALIDATOR}" | tr '\n' ' ')"
[[ "${actual_stages}" == "${expected_stages}" ]] ||
    fail "unexpected validation stage order: ${actual_stages}"

for forbidden in \
    '.decide(' \
    '.disposition(' \
    '.activate(' \
    '.runOpportunity(' \
    '.teardown(' \
    'Diagnostic' \
    'Clock' \
    'Scheduler'
do
    if grep -Fq "${forbidden}" "${VALIDATOR}"; then
        fail "validator contains forbidden live-behavior reference: ${forbidden}"
    fi
done

source_hash="$(shasum -a 256 "${VALIDATOR}" | awk '{print $1}')"
printf 'SPEC-015 validation purity passed: nine ordered stages, no policy decision, owner lifecycle, diagnostic, clock, or scheduler invocation (%s).\n' \
    "${source_hash}"
