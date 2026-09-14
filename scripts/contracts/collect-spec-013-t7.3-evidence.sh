#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"

[[ $# -eq 1 ]] || {
    printf 'Usage: collect-spec-013-t7.3-evidence.sh OUTPUT-DIRECTORY\n' >&2
    exit 2
}
output_root="$1"
mkdir -p "${output_root}"
output_root="$(cd "${output_root}" && pwd -P)"

"${SCRIPT_DIR}/check-spec-013-static-storage.rb"
"${SCRIPT_DIR}/check-spec-013-borrow-boundaries.rb"
"${SCRIPT_DIR}/check-spec-013-static-profiles.sh" \
    --profile macos-static --output "${output_root}/macos-static"
"${SCRIPT_DIR}/check-spec-013-static-profiles.sh" \
    --profile nrf52840-embedded --output "${output_root}/nrf52840-embedded"
"${SCRIPT_DIR}/collect-spec-013-pi-target-evidence.sh" \
    "${output_root}/raspberry-pi-armv6"
"${SCRIPT_DIR}/check-spec-013-target-evidence.rb" "${output_root}"
