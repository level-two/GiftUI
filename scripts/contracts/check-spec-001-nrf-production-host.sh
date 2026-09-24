#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
application="${project_root}/firmware/nrf52840/applications/signal-analyzer-static"
output="${project_root}/.build/contract-generated/spec-001/nrf-production-host"
mkdir -p "${output}"
cc -std=c99 -Wall -Wextra -Werror \
    -I "${application}/tests/fake-zephyr" \
    -I "${application}/include" \
    "${application}/tests/production_host_tests.c" \
    -o "${output}/production-host-tests"
"${output}/production-host-tests"
printf 'SPEC-001 nRF production host passed: activation, input, due fact, replacement, failure cleanup.\n'
