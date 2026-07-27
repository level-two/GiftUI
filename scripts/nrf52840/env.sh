#!/usr/bin/env bash

if [[ -n "${ZSH_VERSION:-}" ]]; then
    GIFTUI_NRF_ENV_SOURCE="${(%):-%N}"
else
    GIFTUI_NRF_ENV_SOURCE="${BASH_SOURCE[0]}"
fi
SCRIPT_DIR="$(cd "$(dirname "${GIFTUI_NRF_ENV_SOURCE}")" && pwd -P)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"
giftui_nrf_export_environment

export GIFTUI_NRF_PROJECT_ROOT GIFTUI_NRF_ROOT GIFTUI_NRF_BUILD_ROOT
export GIFTUI_NRF_BOARD GIFTUI_NRF_SWIFT_TARGET GIFTUI_NRF_SWIFTC

printf 'GiftUI nRF52840 environment\n'
printf '  Swift:     %s\n' "${GIFTUI_NRF_SWIFTC}"
printf '  Target:    %s\n' "${GIFTUI_NRF_SWIFT_TARGET}"
printf '  Board:     %s\n' "${GIFTUI_NRF_BOARD}"
printf '  Zephyr:    %s\n' "${GIFTUI_NRF_ZEPHYR_BASE}"
printf '  SDK:       %s\n' "${GIFTUI_NRF_SDK_DIR}"
printf '  Build root: %s\n' "${GIFTUI_NRF_BUILD_ROOT}"
