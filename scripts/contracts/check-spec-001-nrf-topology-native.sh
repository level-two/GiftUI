#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
output="${root}/.build/contract-generated/spec-001/topology-native"
owners="${root}/.build/contract-generated/spec-001/nrf-native-owners"
mkdir -p "${output}" "${output}/clang-cache"
export CLANG_MODULE_CACHE_PATH="${output}/clang-cache"
objects=()
while IFS= read -r object; do objects+=("${object}"); done < "${owners}/owner-objects.txt"
swiftc -I "${owners}/modules" -DGIFTUI_REFERENCE_BITMAP_ONLY -DGIFTUI_NRF_EMBEDDED \
    -parse-as-library -Osize -package-name GiftUI \
    "${root}/.build/nrf52840/signal-analyzer-static/SignalAnalyzerStatic.swift" \
    "${root}/Tests/ContractFixtures/SPEC001/TopologySemanticProbe.swift" \
    "${objects[@]}" -o "${output}/corpus"
"${output}/corpus" >"${output}/transcript.txt"
python3 - "${root}" "${output}/transcript.txt" <<'PY'
import gzip
from pathlib import Path
import sys
root, transcript = map(Path, sys.argv[1:])
if transcript.read_bytes() != gzip.decompress((root / 'Tests/ContractFixtures/SPEC001/topology-semantic-transcript.txt.gz').read_bytes()):
    raise SystemExit('42-case production semantic transcript differs')
print('nRF topology native passed: 42 semantic cases, 84 size/variant refusals, 42 retirements, exact maintained transcript.')
PY
