#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

force=0
verify=1
offline=0

usage() {
    cat <<'USAGE'
Usage: scripts/nrf52840/setup-toolchain.sh [options]

Options:
  --force       Recreate generated project-local toolchain state.
  --no-verify   Skip doctor.sh --probe after setup.
  --offline     Use only already verified downloads and source checkouts.
  -h, --help    Show this help.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force) force=1 ;;
        --no-verify) verify=0 ;;
        --offline) offline=1 ;;
        -h | --help) usage; exit 0 ;;
        *) giftui_nrf_error "unknown option: $1" ;;
    esac
    shift
done

[[ "$(uname -s)" == "Darwin" ]] || giftui_nrf_error "setup currently supports macOS only"
for command in curl git shasum tar; do
    command -v "${command}" >/dev/null 2>&1 || giftui_nrf_error "required command is missing: ${command}"
done
if [[ "${force}" -eq 1 && "${offline}" -eq 1 ]]; then
    giftui_nrf_error "--force and --offline cannot be combined"
fi
[[ -x /usr/sbin/pkgutil ]] || giftui_nrf_error "required command is missing: /usr/sbin/pkgutil"
[[ -n "$(giftui_nrf_cmake)" ]] || giftui_nrf_error "CMake >=${GIFTUI_NRF_CMAKE_MIN_VERSION} is required"
[[ -n "$(giftui_nrf_ninja)" ]] || giftui_nrf_error "Ninja >=${GIFTUI_NRF_NINJA_MIN_VERSION} is required"
[[ -n "$(giftui_nrf_dtc)" ]] || giftui_nrf_error "Devicetree compiler >=${GIFTUI_NRF_DTC_MIN_VERSION} is required"

mkdir -p "${GIFTUI_NRF_DOWNLOADS_DIR}" "${GIFTUI_NRF_ROOT}/swift" "${GIFTUI_NRF_WORKSPACE}"

download_verified() {
    local url="$1" destination="$2" expected_sha="$3" label="$4"
    local actual_sha temporary
    if [[ -f "${destination}" ]]; then
        actual_sha="$(shasum -a 256 "${destination}" | awk '{print $1}')"
        if [[ "${actual_sha}" == "${expected_sha}" ]]; then
            giftui_nrf_note "using verified ${label}"
            return
        fi
        [[ "${offline}" -eq 0 ]] || giftui_nrf_error "cached ${label} checksum is invalid"
    fi
    [[ "${offline}" -eq 0 ]] || giftui_nrf_error "offline setup requires cached ${label}"
    temporary="${destination}.download"
    giftui_nrf_note "downloading ${label}"
    curl -fL --retry 3 --progress-bar "${url}" -o "${temporary}"
    actual_sha="$(shasum -a 256 "${temporary}" | awk '{print $1}')"
    [[ "${actual_sha}" == "${expected_sha}" ]] || giftui_nrf_error "${label} checksum does not match the pin"
    mv -f "${temporary}" "${destination}"
}

# Reuse the Raspberry Pi cache when it contains the identical signed Swift.org package.
shared_swift_package="${GIFTUI_NRF_PROJECT_ROOT}/.toolchains/downloads/${GIFTUI_NRF_SWIFT_PACKAGE}"
if [[ ! -f "${GIFTUI_NRF_SWIFT_PACKAGE_PATH}" && -f "${shared_swift_package}" ]]; then
    shared_sha="$(shasum -a 256 "${shared_swift_package}" | awk '{print $1}')"
    if [[ "${shared_sha}" == "${GIFTUI_NRF_SWIFT_PACKAGE_SHA256}" ]]; then
        giftui_nrf_note "reusing verified project Swift package cache"
        cp -c "${shared_swift_package}" "${GIFTUI_NRF_SWIFT_PACKAGE_PATH}" 2>/dev/null ||
            cp "${shared_swift_package}" "${GIFTUI_NRF_SWIFT_PACKAGE_PATH}"
    fi
fi

shared_signature_marker="${shared_swift_package}.signature-ok"
if [[ ! -f "${GIFTUI_NRF_SWIFT_PACKAGE_PATH}.signature-ok" &&
    -f "${shared_signature_marker}" ]] &&
    grep -Fq "sha256=${GIFTUI_NRF_SWIFT_PACKAGE_SHA256}" "${shared_signature_marker}" &&
    grep -Fq "signer=${GIFTUI_NRF_SWIFT_PACKAGE_SIGNER}" "${shared_signature_marker}"; then
    cp "${shared_signature_marker}" "${GIFTUI_NRF_SWIFT_PACKAGE_PATH}.signature-ok"
fi

download_verified \
    "${GIFTUI_NRF_SWIFT_PACKAGE_URL}" \
    "${GIFTUI_NRF_SWIFT_PACKAGE_PATH}" \
    "${GIFTUI_NRF_SWIFT_PACKAGE_SHA256}" \
    "Swift ${GIFTUI_NRF_SWIFT_VERSION} package"

signature_marker="${GIFTUI_NRF_SWIFT_PACKAGE_PATH}.signature-ok"
if [[ -f "${signature_marker}" ]] &&
    grep -Fq "sha256=${GIFTUI_NRF_SWIFT_PACKAGE_SHA256}" "${signature_marker}" &&
    grep -Fq "signer=${GIFTUI_NRF_SWIFT_PACKAGE_SIGNER}" "${signature_marker}"; then
    giftui_nrf_note "using checksum-bound Swift.org signature verification record"
else
    signature_output="$(/usr/sbin/pkgutil --check-signature "${GIFTUI_NRF_SWIFT_PACKAGE_PATH}" || true)"
    if [[ "${signature_output}" == *"${GIFTUI_NRF_SWIFT_PACKAGE_SIGNER}"* ]]; then
        printf '%s\n' \
            "sha256=${GIFTUI_NRF_SWIFT_PACKAGE_SHA256}" \
            "signer=${GIFTUI_NRF_SWIFT_PACKAGE_SIGNER}" \
            >"${signature_marker}"
    else
        printf 'warning: macOS could not validate the Swift installer signature; continuing because the package matches the pinned SHA-256\n' >&2
    fi
fi

if [[ "${force}" -eq 1 || ! -x "${GIFTUI_NRF_SWIFTC}" ]]; then
    extraction_root="$(mktemp -d "${GIFTUI_NRF_ROOT}/swift-extract.XXXXXX")"
    cleanup_swift() { rm -rf "${extraction_root}"; }
    trap cleanup_swift EXIT
    giftui_nrf_note "unpacking Swift inside .toolchains/nrf52840"
    /usr/sbin/pkgutil --expand-full "${GIFTUI_NRF_SWIFT_PACKAGE_PATH}" "${extraction_root}/expanded"
    extracted_swift="$(
        find "${extraction_root}/expanded" \
            \( -type f -o -type l \) \
            -path '*/Payload/usr/bin/swiftc' \
            -print \
            -quit
    )"
    [[ -n "${extracted_swift}" ]] || giftui_nrf_error "Swift package did not contain usr/bin/swiftc"
    extracted_payload="$(dirname "$(dirname "$(dirname "${extracted_swift}")")")"
    rm -rf "${GIFTUI_NRF_HOST_DIR}"
    mv "${extracted_payload}" "${GIFTUI_NRF_HOST_DIR}"
    trap - EXIT
    cleanup_swift
fi

sdk_minimal_archive="$(giftui_nrf_sdk_archive_name)"
sdk_toolchain_archive="$(giftui_nrf_sdk_toolchain_archive_name)"
sdk_release_url="https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${GIFTUI_NRF_ZEPHYR_SDK_VERSION}"
download_verified \
    "${sdk_release_url}/${sdk_minimal_archive}" \
    "${GIFTUI_NRF_DOWNLOADS_DIR}/${sdk_minimal_archive}" \
    "$(giftui_nrf_sdk_minimal_sha256)" \
    "Zephyr SDK ${GIFTUI_NRF_ZEPHYR_SDK_VERSION} bootstrap"
download_verified \
    "${sdk_release_url}/${sdk_toolchain_archive}" \
    "${GIFTUI_NRF_DOWNLOADS_DIR}/${sdk_toolchain_archive}" \
    "$(giftui_nrf_sdk_arm_sha256)" \
    "Zephyr SDK ARM toolchain"

if [[ "${force}" -eq 1 || ! -x "${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-gcc" ]]; then
    sdk_extraction_root="$(mktemp -d "${GIFTUI_NRF_ROOT}/sdk-extract.XXXXXX")"
    cleanup_sdk() { rm -rf "${sdk_extraction_root}"; }
    trap cleanup_sdk EXIT
    tar -xJf "${GIFTUI_NRF_DOWNLOADS_DIR}/${sdk_minimal_archive}" -C "${sdk_extraction_root}"
    extracted_sdk="${sdk_extraction_root}/zephyr-sdk-${GIFTUI_NRF_ZEPHYR_SDK_VERSION}"
    [[ -d "${extracted_sdk}" ]] || giftui_nrf_error "Zephyr SDK bootstrap layout is unexpected"
    tar -xJf "${GIFTUI_NRF_DOWNLOADS_DIR}/${sdk_toolchain_archive}" -C "${extracted_sdk}"
    rm -rf "${GIFTUI_NRF_SDK_DIR}"
    mv "${extracted_sdk}" "${GIFTUI_NRF_SDK_DIR}"
    trap - EXIT
    cleanup_sdk
fi

bootstrap_python="$(giftui_nrf_find_bootstrap_python)"
if [[ "${force}" -eq 1 || ! -x "${GIFTUI_NRF_PYTHON_BIN}" ]]; then
    rm -rf "${GIFTUI_NRF_VENV_DIR}"
    giftui_nrf_note "creating the locked project Python environment"
    "${bootstrap_python}" -m venv "${GIFTUI_NRF_VENV_DIR}"
fi
if [[ "${offline}" -eq 0 ]]; then
    "${GIFTUI_NRF_PYTHON_BIN}" -m pip install --disable-pip-version-check \
        -r "${GIFTUI_NRF_SCRIPT_DIR}/requirements.lock"
else
    "${GIFTUI_NRF_PYTHON_BIN}" -m pip check >/dev/null ||
        giftui_nrf_error "offline Python environment is incomplete; rerun setup online"
fi

mkdir -p "${GIFTUI_NRF_MANIFEST_DIR}"
cp "${GIFTUI_NRF_SCRIPT_DIR}/west.yml" "${GIFTUI_NRF_MANIFEST_DIR}/west.yml"
if [[ ! -f "${GIFTUI_NRF_WORKSPACE}/.west/config" ]]; then
    [[ "${offline}" -eq 0 ]] || giftui_nrf_error "offline setup requires an initialized Zephyr workspace"
    giftui_nrf_note "initializing the project-local Zephyr workspace"
    (
        cd "${GIFTUI_NRF_WORKSPACE}"
        "${GIFTUI_NRF_WEST}" init -l manifest
    )
fi

if [[ "${offline}" -eq 0 ]]; then
    giftui_nrf_note "checking out pinned Zephyr and Nordic modules"
    (
        cd "${GIFTUI_NRF_WORKSPACE}"
        "${GIFTUI_NRF_WEST}" update --narrow -o=--depth=1
    )
else
    [[ "$(giftui_nrf_git_revision "${GIFTUI_NRF_ZEPHYR_BASE}")" == "${GIFTUI_NRF_ZEPHYR_REVISION}" ]] ||
        giftui_nrf_error "offline Zephyr checkout does not match the pin"
fi

if [[ "${verify}" -eq 1 ]]; then
    exec "${SCRIPT_DIR}/doctor.sh" --probe
else
    exec "${SCRIPT_DIR}/doctor.sh"
fi
