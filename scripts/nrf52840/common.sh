#!/usr/bin/env bash

if [[ -n "${ZSH_VERSION:-}" ]]; then
    GIFTUI_NRF_COMMON_SOURCE="${(%):-%N}"
else
    GIFTUI_NRF_COMMON_SOURCE="${BASH_SOURCE[0]}"
fi

GIFTUI_NRF_SCRIPT_DIR="$(cd "$(dirname "${GIFTUI_NRF_COMMON_SOURCE}")" && pwd -P)"
GIFTUI_NRF_PROJECT_ROOT="$(cd "${GIFTUI_NRF_SCRIPT_DIR}/../.." && pwd -P)"

# shellcheck source=toolchain.env
source "${GIFTUI_NRF_SCRIPT_DIR}/toolchain.env"
if [[ -f "${GIFTUI_NRF_SCRIPT_DIR}/local.env" ]]; then
    # shellcheck source=/dev/null
    source "${GIFTUI_NRF_SCRIPT_DIR}/local.env"
fi

GIFTUI_NRF_ROOT="${GIFTUI_NRF_PROJECT_ROOT}/.toolchains/nrf52840"
GIFTUI_NRF_DOWNLOADS_DIR="${GIFTUI_NRF_ROOT}/downloads"
GIFTUI_NRF_HOST_DIR="${GIFTUI_NRF_ROOT}/swift/${GIFTUI_NRF_SWIFT_TAG}-osx"
GIFTUI_NRF_SWIFT_PACKAGE_PATH="${GIFTUI_NRF_DOWNLOADS_DIR}/${GIFTUI_NRF_SWIFT_PACKAGE}"
GIFTUI_NRF_SWIFTC="${GIFTUI_NRF_HOST_DIR}/usr/bin/swiftc"
GIFTUI_NRF_VENV_DIR="${GIFTUI_NRF_ROOT}/python"
GIFTUI_NRF_PYTHON_BIN="${GIFTUI_NRF_VENV_DIR}/bin/python"
GIFTUI_NRF_WEST="${GIFTUI_NRF_VENV_DIR}/bin/west"
GIFTUI_NRF_WORKSPACE="${GIFTUI_NRF_ROOT}/workspace"
GIFTUI_NRF_MANIFEST_DIR="${GIFTUI_NRF_WORKSPACE}/manifest"
GIFTUI_NRF_ZEPHYR_BASE="${GIFTUI_NRF_WORKSPACE}/zephyr"
GIFTUI_NRF_SDK_DIR="${GIFTUI_NRF_ROOT}/zephyr-sdk-${GIFTUI_NRF_ZEPHYR_SDK_VERSION}"
GIFTUI_NRF_BUILD_ROOT="${GIFTUI_NRF_PROJECT_ROOT}/.build/nrf52840"
GIFTUI_NRF_CACHE_DIR="${GIFTUI_NRF_BUILD_ROOT}/cache"
GIFTUI_NRF_CLANG_MODULE_CACHE="${GIFTUI_NRF_CACHE_DIR}/clang-modules"
GIFTUI_NRF_APPLICATIONS_DIR="${GIFTUI_NRF_PROJECT_ROOT}/firmware/nrf52840/applications"

giftui_nrf_note() { printf '==> %s\n' "$*"; }
giftui_nrf_error() { printf 'error: %s\n' "$*" >&2; exit 1; }

giftui_nrf_host_arch() {
    case "$(uname -m)" in
        arm64 | aarch64) printf 'aarch64\n' ;;
        x86_64) printf 'x86_64\n' ;;
        *) giftui_nrf_error "unsupported macOS architecture: $(uname -m)" ;;
    esac
}

giftui_nrf_sdk_archive_name() {
    printf 'zephyr-sdk-%s_macos-%s_minimal.tar.xz\n' \
        "${GIFTUI_NRF_ZEPHYR_SDK_VERSION}" "$(giftui_nrf_host_arch)"
}

giftui_nrf_sdk_toolchain_archive_name() {
    printf 'toolchain_macos-%s_arm-zephyr-eabi.tar.xz\n' "$(giftui_nrf_host_arch)"
}

giftui_nrf_sdk_minimal_sha256() {
    if [[ "$(giftui_nrf_host_arch)" == "aarch64" ]]; then
        printf '%s\n' "${GIFTUI_NRF_SDK_MINIMAL_SHA256_AARCH64}"
    else
        printf '%s\n' "${GIFTUI_NRF_SDK_MINIMAL_SHA256_X86_64}"
    fi
}

giftui_nrf_sdk_arm_sha256() {
    if [[ "$(giftui_nrf_host_arch)" == "aarch64" ]]; then
        printf '%s\n' "${GIFTUI_NRF_SDK_ARM_SHA256_AARCH64}"
    else
        printf '%s\n' "${GIFTUI_NRF_SDK_ARM_SHA256_X86_64}"
    fi
}

giftui_nrf_cmake() { printf '%s\n' "${GIFTUI_NRF_CMAKE:-$(command -v cmake || true)}"; }
giftui_nrf_ninja() { printf '%s\n' "${GIFTUI_NRF_NINJA:-$(command -v ninja || true)}"; }
giftui_nrf_dtc() { printf '%s\n' "${GIFTUI_NRF_DTC:-$(command -v dtc || true)}"; }
giftui_nrf_jlink() { printf '%s\n' "${GIFTUI_NRF_JLINK_EXE:-$(command -v JLinkExe || true)}"; }

giftui_nrf_version_at_least() {
    local actual="$1" minimum="$2"
    [[ "$(printf '%s\n%s\n' "${minimum}" "${actual}" | sort -V | head -1)" == "${minimum}" ]]
}

giftui_nrf_find_bootstrap_python() {
    local candidate version
    if [[ -n "${GIFTUI_NRF_PYTHON:-}" ]]; then
        candidates=("${GIFTUI_NRF_PYTHON}")
    else
        candidates=(python3.12 python3.13 python3.11 python3.10 python3)
    fi
    for candidate in "${candidates[@]}"; do
        command -v "${candidate}" >/dev/null 2>&1 || continue
        version="$("${candidate}" -c 'import platform; print(platform.python_version())')"
        if giftui_nrf_version_at_least "${version}" "${GIFTUI_NRF_PYTHON_MIN_VERSION}" &&
            ! giftui_nrf_version_at_least "${version}" "${GIFTUI_NRF_PYTHON_MAX_VERSION}"; then
            command -v "${candidate}"
            return
        fi
    done
    giftui_nrf_error "Python >=${GIFTUI_NRF_PYTHON_MIN_VERSION} and <${GIFTUI_NRF_PYTHON_MAX_VERSION} is required; set GIFTUI_NRF_PYTHON in local.env"
}

giftui_nrf_require_environment() {
    [[ -x "${GIFTUI_NRF_SWIFTC}" ]] || giftui_nrf_error "Swift toolchain is missing; run scripts/nrf52840/setup-toolchain.sh"
    [[ -x "${GIFTUI_NRF_WEST}" ]] || giftui_nrf_error "Python environment is missing; run scripts/nrf52840/setup-toolchain.sh"
    [[ -x "${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf" ]] || giftui_nrf_error "Zephyr ARM SDK is missing; run scripts/nrf52840/setup-toolchain.sh"
    [[ -d "${GIFTUI_NRF_ZEPHYR_BASE}" ]] || giftui_nrf_error "Zephyr workspace is missing; run scripts/nrf52840/setup-toolchain.sh"
}

giftui_nrf_export_environment() {
    giftui_nrf_require_environment
    mkdir -p "${GIFTUI_NRF_CLANG_MODULE_CACHE}"
    export ZEPHYR_BASE="${GIFTUI_NRF_ZEPHYR_BASE}"
    export ZEPHYR_SDK_INSTALL_DIR="${GIFTUI_NRF_SDK_DIR}"
    export ZEPHYR_TOOLCHAIN_VARIANT="zephyr"
    export CMAKE_GENERATOR="Ninja"
    export CLANG_MODULE_CACHE_PATH="${GIFTUI_NRF_CLANG_MODULE_CACHE}"
    export PATH="${GIFTUI_NRF_VENV_DIR}/bin:${GIFTUI_NRF_HOST_DIR}/usr/bin:${PATH}"
}

giftui_nrf_git_revision() {
    git -C "$1" rev-parse HEAD 2>/dev/null || true
}
