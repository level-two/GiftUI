#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
APPLICATION_ROOT="${PROJECT_ROOT}/firmware/nrf52840/applications/signal-analyzer-static"
TEMPORARY_ROOT="$(mktemp -d)"
trap 'rm -rf "${TEMPORARY_ROOT}"' EXIT

cc -std=c99 -Wall -Wextra -Werror \
    -I "${APPLICATION_ROOT}/include" \
    "${APPLICATION_ROOT}/src/touch_input.c" \
    "${APPLICATION_ROOT}/tests/touch_input_tests.c" \
    -o "${TEMPORARY_ROOT}/touch-input-tests"

"${TEMPORARY_ROOT}/touch-input-tests"
printf 'SPEC-001 nRF touch normalization passed: calibration, orientation, bounds, phases, and reset.\n'
