#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
application="${project_root}/firmware/nrf52840/applications/signal-analyzer-static"
output="${project_root}/.build/contract-generated/spec-001/spi-tft-transport"
mkdir -p "${output}"

cc -std=c11 -Wall -Wextra -Werror \
    -I "${application}/tests/fake-zephyr" \
    -I "${application}/include" \
    "${application}/src/spi_tft.c" \
    "${application}/tests/spi_tft_transport_tests.c" \
    -o "${output}/spi-tft-transport-tests"
"${output}/spi-tft-transport-tests"
printf 'SPEC-001 direct-SPI TFT transport host tests passed.\n'
