#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

for profile in macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded; do
    "${SCRIPT_DIR}/run-spec-015.sh" --profile "${profile}"
done

"${SCRIPT_DIR}/compare-spec-015-presets.rb"
