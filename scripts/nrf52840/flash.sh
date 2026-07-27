#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

application=""
build_first=1

usage() {
    cat <<'USAGE'
Usage: scripts/nrf52840/flash.sh --application NAME [--no-build]

Flashes one explicitly named firmware build through the nRF52840-DK J-Link
runner. This command changes connected hardware; build.sh never invokes it.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --application)
            [[ $# -ge 2 ]] || giftui_nrf_error "--application requires a value"
            application="$2"
            shift
            ;;
        --no-build) build_first=0 ;;
        -h | --help) usage; exit 0 ;;
        *) giftui_nrf_error "unknown option: $1" ;;
    esac
    shift
done

[[ -n "${application}" ]] || giftui_nrf_error "--application is required for every flash"
[[ "${application}" =~ ^[a-z0-9][a-z0-9_-]*$ ]] || giftui_nrf_error "invalid application name: ${application}"

if [[ "${build_first}" -eq 1 ]]; then
    "${SCRIPT_DIR}/build.sh" --application "${application}"
fi

giftui_nrf_export_environment
build_dir="${GIFTUI_NRF_BUILD_ROOT}/${application}"
hex="${build_dir}/zephyr/zephyr.hex"
elf="${build_dir}/zephyr/zephyr.elf"
[[ -f "${hex}" && -f "${elf}" ]] || giftui_nrf_error "explicit firmware artifacts are missing under ${build_dir}"
[[ -n "$(giftui_nrf_jlink)" ]] || giftui_nrf_error "SEGGER J-Link tools are required to flash"

export PATH="$(dirname "$(giftui_nrf_jlink)"):${PATH}"
giftui_nrf_note "flashing ${hex} with the nRF52840-DK J-Link runner"
"${GIFTUI_NRF_WEST}" flash -d "${build_dir}" -r jlink --skip-rebuild
printf 'FLASHED=%s\n' "${hex}"
