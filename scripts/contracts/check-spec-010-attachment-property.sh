#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC010/CompilerCorrections/read-only-attachment-property/main.swift"
REPORT_DIR="${PROJECT_ROOT}/.build/contract-generated/spec-010/compiler-corrections/read-only-attachment-property"
COMPILER="$(xcrun --find swiftc)"
SDK="$(xcrun --sdk macosx --show-sdk-path)"

rm -rf "${REPORT_DIR}"
mkdir -p "${REPORT_DIR}/module-cache"
"${COMPILER}" --version >"${REPORT_DIR}/compiler-version.txt" 2>&1

"${COMPILER}" \
    -module-cache-path "${REPORT_DIR}/module-cache" \
    -target arm64-apple-macosx26.0 \
    -sdk "${SDK}" \
    -language-mode 6 \
    -typecheck "${FIXTURE}" \
    >"${REPORT_DIR}/stdout.txt" 2>"${REPORT_DIR}/stderr.txt"

printf 'SPEC-010 attachment-property correction compiled; report: %s\n' "${REPORT_DIR}"
