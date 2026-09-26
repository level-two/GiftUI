#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
# shellcheck source=../lib/swiftpm.sh
source "${project_root}/scripts/lib/swiftpm.sh"
output="${project_root}/.build/contract-generated/spec-001/pi-host-native-rehearsal"

giftui_swiftpm \
    --package-path "${project_root}" \
    --cache-root "${output}" \
    --swift-flag -DGIFTUI_DYNAMIC_PROFILE \
    --disable-sandbox \
    -- run SignalAnalyzerRaspberryPiARMv6 --rehearse-host
