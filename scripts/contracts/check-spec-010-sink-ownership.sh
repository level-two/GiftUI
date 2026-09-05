#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC010/Fixtures/Negative/sink-copy/main.swift"
PATTERNS="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC010/Fixtures/Negative/sink-copy/expected-diagnostic-patterns.txt"
REPORT_DIR="${PROJECT_ROOT}/.build/contract-generated/spec-010/compiler-negative/sink-copy"
COMPILER="$(xcrun --find swiftc)"
SDK="$(xcrun --sdk macosx --show-sdk-path)"

rm -rf "${REPORT_DIR}"
mkdir -p "${REPORT_DIR}/module-cache"
"${COMPILER}" --version >"${REPORT_DIR}/compiler-version.txt" 2>&1

sources=("${PROJECT_ROOT}"/Sources/GiftUI/*.swift)
set +e
"${COMPILER}" \
    -module-cache-path "${REPORT_DIR}/module-cache" \
    -target arm64-apple-macosx26.0 \
    -sdk "${SDK}" \
    -language-mode 6 \
    -package-name GiftUI \
    -parse-as-library \
    -module-name GiftUI \
    -whole-module-optimization \
    -emit-sil \
    "${sources[@]}" \
    "${FIXTURE}" \
    -o "${REPORT_DIR}/unexpected.sil" \
    >"${REPORT_DIR}/stdout.txt" 2>"${REPORT_DIR}/stderr.txt"
result=$?
set -e

if [[ "${result}" -eq 0 ]]; then
    printf '%s\n' 'error: noncopyable sink was accepted by two consuming uses' >&2
    exit 1
fi

while IFS= read -r pattern; do
    [[ -n "${pattern}" && "${pattern}" != \#* ]] || continue
    grep -Fq "${pattern}" "${REPORT_DIR}/stderr.txt" || {
        printf 'error: sink ownership diagnostic lacked pattern: %s\n' "${pattern}" >&2
        exit 1
    }
done <"${PATTERNS}"

printf 'SPEC-010 noncopyable sink ownership rejected; report: %s\n' "${REPORT_DIR}"
