#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC014/CompilerBlockers/borrowing-property/main.swift"
OUTPUT_ROOT="${PROJECT_ROOT}/.build/spec-014/compiler-blockers/borrowing-property"
DIAGNOSTIC="${OUTPUT_ROOT}/diagnostic.txt"

mkdir -p "${OUTPUT_ROOT}"
mkdir -p "${OUTPUT_ROOT}/clang-cache"
if CLANG_MODULE_CACHE_PATH="${OUTPUT_ROOT}/clang-cache" \
    xcrun swiftc -typecheck -parse-as-library "${FIXTURE}" >"${DIAGNOSTIC}" 2>&1; then
    printf '%s\n' 'SPEC-014 borrowing-property blocker unexpectedly compiled; review the Specification and fixture.' >&2
    exit 1
fi
grep -Fq "'borrowing' may only be used on 'func' declarations" "${DIAGNOSTIC}" || {
    printf '%s\n' 'SPEC-014 borrowing-property blocker produced a different compiler diagnostic.' >&2
    exit 1
}
printf '%s\n' 'SPEC-014 borrowing-property blocker reproduced under the pinned compiler.'
