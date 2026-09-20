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
    "${APPLICATION_ROOT}/src/static_input_bridge.c" \
    "${APPLICATION_ROOT}/src/static_touch_pipeline.c" \
    "${APPLICATION_ROOT}/tests/static_touch_pipeline_tests.c" \
    -o "${TEMPORARY_ROOT}/static-touch-pipeline-tests"

"${TEMPORARY_ROOT}/static-touch-pipeline-tests"
printf 'SPEC-001 nRF Static touch pipeline passed: normalization, handoff, and release-proven resynchronization.\n'
