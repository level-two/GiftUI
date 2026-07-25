#!/usr/bin/env bash

if [[ -n "${ZSH_VERSION:-}" ]]; then
    GIFTUI_PI_COMMON_SOURCE="${(%):-%N}"
else
    GIFTUI_PI_COMMON_SOURCE="${BASH_SOURCE[0]}"
fi

GIFTUI_PI_SCRIPT_DIR="$(
    cd "$(dirname "${GIFTUI_PI_COMMON_SOURCE}")"
    pwd -P
)"
GIFTUI_PI_PROJECT_ROOT="$(
    cd "${GIFTUI_PI_SCRIPT_DIR}/../.."
    pwd -P
)"

# shellcheck source=toolchain.env
source "${GIFTUI_PI_SCRIPT_DIR}/toolchain.env"

if [[ -f "${GIFTUI_PI_SCRIPT_DIR}/local.env" ]]; then
    # shellcheck source=/dev/null
    source "${GIFTUI_PI_SCRIPT_DIR}/local.env"
fi

GIFTUI_PI_TOOLCHAINS_ROOT="${GIFTUI_PI_PROJECT_ROOT}/.toolchains"
GIFTUI_PI_DOWNLOADS_DIR="${GIFTUI_PI_TOOLCHAINS_ROOT}/downloads"
GIFTUI_PI_HOST_PARENT="${GIFTUI_PI_TOOLCHAINS_ROOT}/host"
GIFTUI_PI_HOST_TOOLCHAIN_DIR="${GIFTUI_PI_HOST_PARENT}/${GIFTUI_PI_HOST_TOOLCHAIN_NAME}"
GIFTUI_PI_HOST_PACKAGE_PATH="${GIFTUI_PI_DOWNLOADS_DIR}/${GIFTUI_PI_HOST_PACKAGE}"
GIFTUI_PI_HOST_BIN_DIR="${GIFTUI_PI_HOST_TOOLCHAIN_DIR}/usr/bin"
GIFTUI_PI_SDK_PARENT="${GIFTUI_PI_TOOLCHAINS_ROOT}/sdk"
GIFTUI_PI_SDK_DIR="${GIFTUI_PI_SDK_PARENT}/${GIFTUI_PI_SDK_NAME}"
GIFTUI_PI_ARCHIVE_PATH="${GIFTUI_PI_DOWNLOADS_DIR}/${GIFTUI_PI_SDK_ARCHIVE}"
GIFTUI_PI_STATIC_DESTINATION="${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}-static.json"
GIFTUI_PI_DYNAMIC_DESTINATION="${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}.json"
GIFTUI_PI_BUILD_ROOT="${GIFTUI_PI_PROJECT_ROOT}/.build/raspberry-pi"
GIFTUI_PI_ARTIFACTS_DIR="${GIFTUI_PI_BUILD_ROOT}/artifacts"
GIFTUI_PI_CACHE_DIR="${GIFTUI_PI_BUILD_ROOT}/cache"
GIFTUI_PI_CLANG_MODULE_CACHE="${GIFTUI_PI_CACHE_DIR}/clang-modules"
GIFTUI_PI_SWIFTPM_MODULE_CACHE="${GIFTUI_PI_CACHE_DIR}/swiftpm-modules"
GIFTUI_PI_PROBE_PACKAGE="${GIFTUI_PI_SCRIPT_DIR}/probe"
GIFTUI_PI_PROBE_PRODUCT="GiftUIToolchainProbe"

giftui_pi_note() {
    printf '==> %s\n' "$*"
}

giftui_pi_error() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

giftui_pi_host_swift() {
    if [[ -n "${GIFTUI_PI_SWIFT_BIN:-}" ]]; then
        printf '%s\n' "${GIFTUI_PI_SWIFT_BIN}"
        return
    fi

    printf '%s\n' "${GIFTUI_PI_HOST_BIN_DIR}/swift"
}

giftui_pi_host_swift_version_line() {
    "$(giftui_pi_host_swift)" --version | sed -n '/Swift version/{p;q;}'
}

giftui_pi_require_sdk() {
    [[ -f "${GIFTUI_PI_STATIC_DESTINATION}" ]] ||
        giftui_pi_error "ARMv6 SDK is not installed; run scripts/raspberry-pi/setup-toolchain.sh"
}

giftui_pi_verify_armv6_binary() {
    local binary_path="$1"
    local file_description
    local attributes_hex
    local llvm_objdump="${GIFTUI_PI_HOST_BIN_DIR}/llvm-objdump"

    [[ -f "${binary_path}" ]] ||
        giftui_pi_error "binary not found: ${binary_path}"
    [[ -x "${llvm_objdump}" ]] ||
        giftui_pi_error "ARM attribute inspector is missing: ${llvm_objdump}"

    file_description="$(file "${binary_path}")"
    [[ "${file_description}" == *"ELF 32-bit"* &&
        "${file_description}" == *"ARM"* ]] ||
        giftui_pi_error "expected a 32-bit ARM ELF binary: ${file_description}"

    attributes_hex="$(
        "${llvm_objdump}" -s -j .ARM.attributes "${binary_path}" |
            awk '
                /^[[:space:]]+[[:xdigit:]]+[[:space:]]/ {
                    for (i = 2; i <= NF; i++) {
                        if ($i ~ /^[0-9A-Fa-f]+$/ && length($i) <= 8) {
                            printf "%s", $i
                        }
                    }
                }
                END { print "" }
            '
    )"
    [[ "${attributes_hex}" == *"0536000606"* ]] ||
        giftui_pi_error "binary does not declare ARMv6 CPU architecture attributes"
    [[ "${attributes_hex}" == *"1c01"* ]] ||
        giftui_pi_error "binary does not declare the ARM hard-float calling convention"

    printf '%s\n' "${file_description}"
}

giftui_pi_prepare_build_environment() {
    mkdir -p \
        "${GIFTUI_PI_CLANG_MODULE_CACHE}" \
        "${GIFTUI_PI_SWIFTPM_MODULE_CACHE}"
    export CLANG_MODULE_CACHE_PATH="${GIFTUI_PI_CLANG_MODULE_CACHE}"
    export SWIFTPM_MODULECACHE_OVERRIDE="${GIFTUI_PI_SWIFTPM_MODULE_CACHE}"
}

giftui_pi_absolute_path() {
    local input="$1"
    local parent
    local name

    parent="$(dirname "${input}")"
    name="$(basename "${input}")"
    (
        cd "${parent}"
        printf '%s/%s\n' "$(pwd -P)" "${name}"
    )
}
