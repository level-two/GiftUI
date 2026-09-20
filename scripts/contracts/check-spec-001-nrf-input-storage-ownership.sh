#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC001/Fixtures/Negative/nrf-firmware-input-storage-copy"
REPORT_ROOT="${PROJECT_ROOT}/.build/contract-generated/spec-001/nrf-input-storage-ownership"

fail() {
    printf 'SPEC-001 nRF input storage ownership check failed: %s\n' "$*" >&2
    exit 1
}

mkdir -p "${REPORT_ROOT}/module-cache"
export CLANG_MODULE_CACHE_PATH="${REPORT_ROOT}/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${REPORT_ROOT}/module-cache"

# shellcheck source=../lib/swiftpm.sh
source "${PROJECT_ROOT}/scripts/lib/swiftpm.sh"
giftui_swiftpm \
    --package-path "${PROJECT_ROOT}" \
    --scratch-path "${PROJECT_ROOT}/.build" \
    --cache-root "${PROJECT_ROOT}/.build/swiftpm-cache" \
    --disable-sandbox \
    -- build --target SignalAnalyzerTargetHost >/dev/null

module_file="$(find "${PROJECT_ROOT}/.build" -maxdepth 6 \
    -path '*/debug/Modules/SignalAnalyzerTargetHost.swiftmodule' -print -quit)"
[[ -n "${module_file}" ]] || fail 'built target-host module was not found'
module_path="$(dirname "${module_file}")"

compiler="$(xcrun --find swiftc)"
sdk="$(xcrun --sdk macosx --show-sdk-path)"
architecture="$(uname -m)"
stderr_path="${REPORT_ROOT}/stderr.txt"
set +e
"${compiler}" \
    -typecheck \
    -swift-version 6 \
    -strict-concurrency=complete \
    -target "${architecture}-apple-macosx15.0" \
    -sdk "${sdk}" \
    -I "${module_path}" \
    -package-name giftui \
    "${FIXTURE_ROOT}/main.swift" \
    >"${REPORT_ROOT}/stdout.txt" 2>"${stderr_path}"
result=$?
set -e
[[ "${result}" -ne 0 ]] || fail 'firmware input storage unexpectedly copied'

while IFS= read -r pattern; do
    [[ -n "${pattern}" && "${pattern}" != \#* ]] || continue
    grep -Fq "${pattern}" "${stderr_path}" || {
        cat "${stderr_path}" >&2
        fail "compiler diagnostic lacked pattern: ${pattern}"
    }
done <"${FIXTURE_ROOT}/expected-diagnostic-patterns.txt"

printf 'SPEC-001 nRF firmware input storage ownership rejected copying.\n'
