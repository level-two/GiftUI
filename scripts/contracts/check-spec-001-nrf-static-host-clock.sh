#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
APPLICATION_ROOT="${PROJECT_ROOT}/firmware/nrf52840/applications/signal-analyzer-static"
TEMPORARY_ROOT="$(mktemp -d)"
trap 'rm -rf "${TEMPORARY_ROOT}"' EXIT

cc -std=c99 -Wall -Wextra -Werror \
    -I "${APPLICATION_ROOT}/tests/stubs" \
    -I "${APPLICATION_ROOT}/include" \
    "${APPLICATION_ROOT}/src/static_host_clock.c" \
    "${APPLICATION_ROOT}/tests/static_host_clock_tests.c" \
    -o "${TEMPORARY_ROOT}/static-host-clock-tests"

"${TEMPORARY_ROOT}/static-host-clock-tests"
printf 'SPEC-001 nRF Static host clock passed: monotonic conversion and checked failures.\n'
