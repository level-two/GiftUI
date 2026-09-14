#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
INSTRUMENTATION="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC013/Instrumentation"
OUTPUT="$(mktemp -d "${TMPDIR:-/tmp}/giftui-spec013-resource.XXXXXX")"
trap 'rm -rf "${OUTPUT}"' EXIT

"${SCRIPT_DIR}/check-spec-013-resource-instrumentation.rb"
xcrun clang -std=c11 -Wall -Wextra -Werror \
    -dynamiclib "${INSTRUMENTATION}/AllocationInterposer.c" \
    -o "${OUTPUT}/libGiftUIRuntimeAllocationInterposer.dylib"
xcrun clang -std=c11 -Wall -Wextra -Werror \
    "${INSTRUMENTATION}/AllocationInterposerProbe.c" \
    -L "${OUTPUT}" -lGiftUIRuntimeAllocationInterposer \
    -Wl,-rpath,"${OUTPUT}" \
    -o "${OUTPUT}/allocation-probe"
"${OUTPUT}/allocation-probe"
xcrun swiftc -module-cache-path "${OUTPUT}/module-cache" \
    -parse-as-library -package-name giftui -whole-module-optimization -emit-object \
    "${INSTRUMENTATION}/RuntimeProfileResourceProbe.swift" \
    "${INSTRUMENTATION}/RuntimeProfileTimingProbe.swift" \
    -o "${OUTPUT}/RuntimeProfileResourceProbe.o"

printf 'SPEC-013 resource instrumentation execution passed: allocation interposition and bounded Swift snapshot compiled.\n'
