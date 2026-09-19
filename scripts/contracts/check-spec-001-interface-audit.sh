#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
export CLANG_MODULE_CACHE_PATH="${PROJECT_ROOT}/.build/clang-module-cache"
mkdir -p "${CLANG_MODULE_CACHE_PATH}"

swift package --disable-sandbox --package-path "${PROJECT_ROOT}" dump-package |
    ruby "${SCRIPT_DIR}/check-spec-001-boundaries.rb"
ruby "${SCRIPT_DIR}/check-spec-001-portable-presentation.rb"
ruby "${SCRIPT_DIR}/check-spec-001-domain-contract.rb"
swift package --disable-sandbox --package-path "${PROJECT_ROOT}" dump-package |
    ruby "${SCRIPT_DIR}/check-target-dependencies.rb"
ruby "${SCRIPT_DIR}/check-spec-015-generated-workload.rb"

generated="${PROJECT_ROOT}/Sources/GiftUIHostConfiguration/Generated/SignalAnalyzerPresets.generated.swift"
grep -Fq 'package enum GeneratedSignalAnalyzerPresets' "${generated}"
grep -Fq 'staticRoot:' "${generated}"

action_source="${PROJECT_ROOT}/Sources/SignalAnalyzerPresentation/SignalAnalyzerPresentationValues.swift"
for action in start stop clear selectOneSecond selectTwoSeconds selectFiveSeconds; do
    grep -Eq "case ${action}( =|$)" "${action_source}"
done
[[ "$(grep -Ec '^    case (start|stop|clear|selectOneSecond|selectTwoSeconds|selectFiveSeconds)' "${action_source}")" -eq 6 ]]

failure_source="${PROJECT_ROOT}/Sources/SignalAnalyzerDomain/SignalCapturePublication.swift"
grep -Fq 'case terminalFailure(' "${failure_source}"
! grep -Eq 'String|Foundation|Error' "${failure_source}"

printf '%s\n' 'SPEC-001 interface audit passed: package graph, generated presets, portable imports, six actions, structural failure, and dependency negatives.'
