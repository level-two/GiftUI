#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

run_probe=0

usage() {
    cat <<'USAGE'
Usage: scripts/raspberry-pi/doctor.sh [--probe]

Checks the pinned macOS host compiler and project-local ARMv6 SDK. With
--probe, also cross-compiles a small static Linux executable.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --probe)
            run_probe=1
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            giftui_pi_error "unknown option: $1"
            ;;
    esac
    shift
done

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

host_swift="$(giftui_pi_host_swift)"
host_version="$(giftui_pi_host_swift_version_line)"

check "running on macOS" test "$(uname -s)" = "Darwin"
check "host Swift executable exists" test -x "${host_swift}"
check "host Swift is project-local" \
    bash -c '[[ "$1" == "$2/"* ]]' _ \
    "${host_swift}" "${GIFTUI_PI_HOST_TOOLCHAIN_DIR}"
check "host swift-autolink-extract exists" \
    test -x "${GIFTUI_PI_HOST_BIN_DIR}/swift-autolink-extract"
check "host llvm-objdump exists" \
    test -x "${GIFTUI_PI_HOST_BIN_DIR}/llvm-objdump"
check "host llvm-objcopy exists" \
    test -x "${GIFTUI_PI_HOST_BIN_DIR}/llvm-objcopy"
check "host Swift is ${GIFTUI_PI_SWIFT_VERSION}" \
    bash -c '[[ "$1" == *"Swift version $2"* ]]' _ \
    "${host_version}" "${GIFTUI_PI_SWIFT_VERSION}"
check "static ARMv6 destination exists" test -f "${GIFTUI_PI_STATIC_DESTINATION}"
check "dynamic ARMv6 destination exists" test -f "${GIFTUI_PI_DYNAMIC_DESTINATION}"

if [[ -f "${GIFTUI_PI_STATIC_DESTINATION}" ]]; then
    check "destination targets ${GIFTUI_PI_TARGET}" \
        grep -Fq "\"target\":\"${GIFTUI_PI_TARGET}\"" \
        "${GIFTUI_PI_STATIC_DESTINATION}"
    check "destination uses the project-local SDK" \
        grep -Fq "${GIFTUI_PI_SDK_DIR}" \
        "${GIFTUI_PI_STATIC_DESTINATION}"
    check "destination uses the project-local host tools" \
        grep -Fq "\"toolchain-bin-dir\":\"$(dirname "${host_swift}")\"" \
        "${GIFTUI_PI_STATIC_DESTINATION}"
    check "destination contains no /opt SDK path" \
        bash -c '! grep -Fq "/opt/$1" "$2"' _ \
        "${GIFTUI_PI_SDK_NAME}" "${GIFTUI_PI_STATIC_DESTINATION}"
fi

if [[ -f "${GIFTUI_PI_ARCHIVE_PATH}" ]]; then
    actual_sha="$(shasum -a 256 "${GIFTUI_PI_ARCHIVE_PATH}" | awk '{print $1}')"
    check "cached SDK archive checksum" \
        test "${actual_sha}" = "${GIFTUI_PI_SDK_SHA256}"
fi

if [[ -f "${GIFTUI_PI_HOST_PACKAGE_PATH}" ]]; then
    actual_host_sha="$(shasum -a 256 "${GIFTUI_PI_HOST_PACKAGE_PATH}" | awk '{print $1}')"
    check "cached macOS Swift package checksum" \
        test "${actual_host_sha}" = "${GIFTUI_PI_HOST_PACKAGE_SHA256}"
fi

printf '\nHost:   %s\n' "${host_version}"
printf 'Tools:  %s\n' "${GIFTUI_PI_HOST_TOOLCHAIN_DIR}"
printf 'Target: %s\n' "${GIFTUI_PI_TARGET}"
printf 'SDK:    %s\n' "${GIFTUI_PI_SDK_DIR}"

if [[ "${failures}" -ne 0 ]]; then
    printf '\n%d toolchain check(s) failed\n' "${failures}" >&2
    exit 1
fi

if [[ "${run_probe}" -eq 1 ]]; then
    printf '\n'
    exec "${SCRIPT_DIR}/build.sh" --probe
fi

printf '\nGiftUI Raspberry Pi cross-compilation environment is ready\n'
