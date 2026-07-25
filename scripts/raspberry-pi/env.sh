#!/usr/bin/env bash

if [[ -n "${ZSH_VERSION:-}" ]]; then
    GIFTUI_PI_ENV_SOURCE="${(%):-%N}"
else
    GIFTUI_PI_ENV_SOURCE="${BASH_SOURCE[0]}"
fi

SCRIPT_DIR="$(
    cd "$(dirname "${GIFTUI_PI_ENV_SOURCE}")"
    pwd -P
)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

giftui_pi_require_sdk

GIFTUI_PI_SWIFT_BIN="$(giftui_pi_host_swift)"
export GIFTUI_PI_PROJECT_ROOT
export GIFTUI_PI_SWIFT_BIN
export GIFTUI_PI_TARGET
export GIFTUI_PI_SDK_DIR
export GIFTUI_PI_STATIC_DESTINATION
export GIFTUI_PI_DYNAMIC_DESTINATION
export GIFTUI_PI_BUILD_ROOT
export GIFTUI_PI_ARTIFACTS_DIR
export GIFTUI_PI_PRODUCT
export GIFTUI_PI_HOST
export GIFTUI_PI_USER
export GIFTUI_PI_REMOTE_DIR

if [[ -n "${BASH_VERSION:-}" && "${BASH_SOURCE[0]}" == "$0" ]]; then
    printf 'This script is intended to be sourced:\n'
    printf '  source scripts/raspberry-pi/env.sh\n\n'
fi

printf 'GiftUI Pi environment\n'
printf '  Swift:       %s\n' "${GIFTUI_PI_SWIFT_BIN}"
printf '  Target:      %s\n' "${GIFTUI_PI_TARGET}"
printf '  Destination: %s\n' "${GIFTUI_PI_STATIC_DESTINATION}"
printf '  Build root:  %s\n' "${GIFTUI_PI_BUILD_ROOT}"
printf '  Remote:      %s@%s:%s\n' \
    "${GIFTUI_PI_USER}" "${GIFTUI_PI_HOST}" "${GIFTUI_PI_REMOTE_DIR}"
