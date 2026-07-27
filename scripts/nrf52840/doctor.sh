#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

run_probe=0
case "${1:-}" in
    --probe) run_probe=1 ;;
    -h | --help)
        printf 'Usage: scripts/nrf52840/doctor.sh [--probe]\n'
        exit 0
        ;;
    "") ;;
    *) giftui_nrf_error "unknown option: $1" ;;
esac
[[ $# -le 1 ]] || giftui_nrf_error "too many arguments"

failures=0
check() {
    local description="$1"
    shift
    if "$@"; then
        printf 'ok:    %s\n' "${description}"
    else
        printf 'fail:  %s\n' "${description}" >&2
        failures=$((failures + 1))
    fi
}

cmake_bin="$(giftui_nrf_cmake)"
ninja_bin="$(giftui_nrf_ninja)"
cmake_version="missing"
ninja_version="missing"
dtc_version="missing"
python_version="missing"
swift_version="missing"
west_version="missing"

[[ -n "${cmake_bin}" ]] && cmake_version="$("${cmake_bin}" --version | awk 'NR == 1 {print $3}')"
[[ -n "${ninja_bin}" ]] && ninja_version="$("${ninja_bin}" --version)"
dtc_bin="$(giftui_nrf_dtc)"
[[ -n "${dtc_bin}" ]] && dtc_version="$("${dtc_bin}" --version 2>&1 | sed -n 's/.*Version: DTC //p')"
[[ -x "${GIFTUI_NRF_PYTHON_BIN}" ]] && python_version="$("${GIFTUI_NRF_PYTHON_BIN}" -c 'import platform; print(platform.python_version())')"
[[ -x "${GIFTUI_NRF_SWIFTC}" ]] && swift_version="$("${GIFTUI_NRF_SWIFTC}" --version | sed -n '/Swift version/{p;q;}')"
[[ -x "${GIFTUI_NRF_WEST}" ]] && west_version="$("${GIFTUI_NRF_WEST}" --version)"

check "running on macOS" test "$(uname -s)" = Darwin
check "host architecture is supported" bash -c '[[ "$1" == arm64 || "$1" == x86_64 ]]' _ "$(uname -m)"
check "CMake is installed" test -x "${cmake_bin}"
[[ "${cmake_version}" == "missing" ]] || check "CMake is >=${GIFTUI_NRF_CMAKE_MIN_VERSION}" giftui_nrf_version_at_least "${cmake_version}" "${GIFTUI_NRF_CMAKE_MIN_VERSION}"
check "Ninja is installed" test -x "${ninja_bin}"
[[ "${ninja_version}" == "missing" ]] || check "Ninja is >=${GIFTUI_NRF_NINJA_MIN_VERSION}" giftui_nrf_version_at_least "${ninja_version}" "${GIFTUI_NRF_NINJA_MIN_VERSION}"
check "Devicetree compiler is installed" test -x "${dtc_bin}"
[[ "${dtc_version}" == "missing" ]] || check "Devicetree compiler is >=${GIFTUI_NRF_DTC_MIN_VERSION}" giftui_nrf_version_at_least "${dtc_version}" "${GIFTUI_NRF_DTC_MIN_VERSION}"
check "project Python environment exists" test -x "${GIFTUI_NRF_PYTHON_BIN}"
check "west is installed in the project environment" test -x "${GIFTUI_NRF_WEST}"
check "project-local Swift compiler exists" test -x "${GIFTUI_NRF_SWIFTC}"
check "Swift compiler is ${GIFTUI_NRF_SWIFT_VERSION}" bash -c '[[ "$1" == *"Swift version $2"* ]]' _ "${swift_version}" "${GIFTUI_NRF_SWIFT_VERSION}"
check "Zephyr SDK ARM compiler exists" test -x "${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-gcc"
check "Zephyr SDK ELF inspector exists" test -x "${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf"
check "Zephyr checkout matches ${GIFTUI_NRF_ZEPHYR_VERSION}" test "$(giftui_nrf_git_revision "${GIFTUI_NRF_ZEPHYR_BASE}")" = "${GIFTUI_NRF_ZEPHYR_REVISION}"
check "CMSIS checkout matches pin" test "$(giftui_nrf_git_revision "${GIFTUI_NRF_WORKSPACE}/modules/hal/cmsis")" = "${GIFTUI_NRF_CMSIS_REVISION}"
check "CMSIS 6 checkout matches pin" test "$(giftui_nrf_git_revision "${GIFTUI_NRF_WORKSPACE}/modules/hal/cmsis_6")" = "${GIFTUI_NRF_CMSIS_6_REVISION}"
check "Nordic HAL checkout matches pin" test "$(giftui_nrf_git_revision "${GIFTUI_NRF_WORKSPACE}/modules/hal/nordic")" = "${GIFTUI_NRF_HAL_NORDIC_REVISION}"
check "SEGGER module checkout matches pin" test "$(giftui_nrf_git_revision "${GIFTUI_NRF_WORKSPACE}/modules/debug/segger")" = "${GIFTUI_NRF_SEGGER_MODULE_REVISION}"

printf '\nResolved version set\n'
printf '  Swift:       %s\n' "${swift_version}"
printf '  Swift target: %s\n' "${GIFTUI_NRF_SWIFT_TARGET}"
printf '  Board:       %s\n' "${GIFTUI_NRF_BOARD}"
printf '  Zephyr:      %s (%s)\n' "${GIFTUI_NRF_ZEPHYR_VERSION}" "$(giftui_nrf_git_revision "${GIFTUI_NRF_ZEPHYR_BASE}")"
printf '  Zephyr SDK:  %s\n' "${GIFTUI_NRF_ZEPHYR_SDK_VERSION}"
printf '  Python:      %s (lock baseline %s)\n' "${python_version}" "${GIFTUI_NRF_PYTHON_LOCK_VERSION}"
printf '  west:        %s\n' "${west_version}"
printf '  CMake:       %s\n' "${cmake_version}"
printf '  Ninja:       %s\n' "${ninja_version}"
printf '  DTC:         %s\n' "${dtc_version}"
if [[ -n "$(giftui_nrf_jlink)" ]]; then
    jlink_output="$("$(giftui_nrf_jlink)" '-?' 2>&1 || true)"
    jlink_version="$(printf '%s\n' "${jlink_output}" | sed -n '1{s/.* V\([0-9.]*\).*/\1/p;}')"
    printf '  J-Link:      %s (tested %s; needed only for flash)\n' "${jlink_version:-detected}" "${GIFTUI_NRF_JLINK_TESTED_VERSION}"
else
    printf '  J-Link:      not installed (optional until flash)\n'
fi

if [[ "${failures}" -ne 0 ]]; then
    printf '\n%d environment check(s) failed\n' "${failures}" >&2
    exit 1
fi

if [[ "${run_probe}" -eq 1 ]]; then
    printf '\n'
    exec "${SCRIPT_DIR}/build.sh" --application probe
fi

printf '\nGiftUI nRF52840 development environment is ready\n'
