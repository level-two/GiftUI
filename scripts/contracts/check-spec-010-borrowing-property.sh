#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_DIR="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC010/CompilerBlockers/borrowing-property"
REPORT_DIR="${PROJECT_ROOT}/.build/contract-generated/spec-010/compiler-blockers/borrowing-property"
COMPILER="$(xcrun --find swiftc)"
SDK="$(xcrun --sdk macosx --show-sdk-path)"

rm -rf "${REPORT_DIR}"
mkdir -p "${REPORT_DIR}/module-cache"
"${COMPILER}" --version >"${REPORT_DIR}/compiler-version.txt" 2>&1

set +e
"${COMPILER}" \
    -module-cache-path "${REPORT_DIR}/module-cache" \
    -target arm64-apple-macosx26.0 \
    -sdk "${SDK}" \
    -language-mode 6 \
    -typecheck "${FIXTURE_DIR}/main.swift" \
    >"${REPORT_DIR}/stdout.txt" 2>"${REPORT_DIR}/stderr.txt"
result=$?
set -e

if [[ "${result}" -eq 0 ]]; then
    printf '%s\n' 'error: historical borrowing-property spelling unexpectedly compiled' >&2
    exit 1
fi

while IFS= read -r pattern; do
    [[ -n "${pattern}" && "${pattern}" != \#* ]] || continue
    grep -Fq "${pattern}" "${REPORT_DIR}/stderr.txt" || {
        printf 'error: missing compiler diagnostic: %s\n' "${pattern}" >&2
        exit 1
    }
done <"${FIXTURE_DIR}/expected-diagnostic-patterns.txt"

printf 'SPEC-010 historical borrowing-property blocker reproduced; report: %s\n' "${REPORT_DIR}"
