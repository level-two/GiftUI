#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

force=0
verify=1
offline=0

usage() {
    cat <<'USAGE'
Usage: scripts/raspberry-pi/setup-toolchain.sh [options]

Options:
  --force       Re-extract the pinned host toolchain and ARMv6 SDK.
  --no-verify   Skip the cross-compiled probe build.
  --offline     Require both verified archives to already exist.
  -h, --help    Show this help.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force)
            force=1
            ;;
        --no-verify)
            verify=0
            ;;
        --offline)
            offline=1
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

[[ "$(uname -s)" == "Darwin" ]] ||
    giftui_pi_error "the project-local host toolchain setup currently supports macOS only"

for command in curl shasum tar sed; do
    command -v "${command}" >/dev/null 2>&1 ||
        giftui_pi_error "required command is missing: ${command}"
done
[[ -x /usr/sbin/pkgutil ]] ||
    giftui_pi_error "required command is missing: /usr/sbin/pkgutil"

mkdir -p \
    "${GIFTUI_PI_DOWNLOADS_DIR}" \
    "${GIFTUI_PI_HOST_PARENT}" \
    "${GIFTUI_PI_SDK_PARENT}"

host_package_is_valid=0
if [[ -f "${GIFTUI_PI_HOST_PACKAGE_PATH}" ]]; then
    actual_sha="$(shasum -a 256 "${GIFTUI_PI_HOST_PACKAGE_PATH}" | awk '{print $1}')"
    if [[ "${actual_sha}" == "${GIFTUI_PI_HOST_PACKAGE_SHA256}" ]]; then
        host_package_is_valid=1
        giftui_pi_note "using verified cached macOS Swift package"
    elif [[ "${offline}" -eq 1 ]]; then
        giftui_pi_error "cached macOS Swift package checksum does not match the pinned digest"
    fi
fi

if [[ "${host_package_is_valid}" -eq 0 ]]; then
    [[ "${offline}" -eq 0 ]] ||
        giftui_pi_error "offline setup requested but no verified macOS Swift package is available"

    temporary_host_package="${GIFTUI_PI_HOST_PACKAGE_PATH}.download"
    giftui_pi_note "downloading ${GIFTUI_PI_HOST_PACKAGE}"
    curl -fL --retry 3 --progress-bar \
        "${GIFTUI_PI_HOST_PACKAGE_URL}" \
        -o "${temporary_host_package}"

    actual_sha="$(shasum -a 256 "${temporary_host_package}" | awk '{print $1}')"
    [[ "${actual_sha}" == "${GIFTUI_PI_HOST_PACKAGE_SHA256}" ]] ||
        giftui_pi_error "downloaded macOS Swift package checksum does not match the pinned digest"

    mv -f "${temporary_host_package}" "${GIFTUI_PI_HOST_PACKAGE_PATH}"
fi

signature_marker="${GIFTUI_PI_HOST_PACKAGE_PATH}.signature-ok"
signature_is_verified=0
if [[ -f "${signature_marker}" ]] &&
    grep -Fq "sha256=${GIFTUI_PI_HOST_PACKAGE_SHA256}" "${signature_marker}" &&
    grep -Fq "signer=${GIFTUI_PI_HOST_PACKAGE_SIGNER}" "${signature_marker}"; then
    signature_is_verified=1
    giftui_pi_note "using cached Swift.org installer signature verification"
fi

if [[ "${signature_is_verified}" -eq 0 ]]; then
    signature_output="$(/usr/sbin/pkgutil --check-signature "${GIFTUI_PI_HOST_PACKAGE_PATH}")"
    [[ "${signature_output}" == *"${GIFTUI_PI_HOST_PACKAGE_SIGNER}"* ]] ||
        giftui_pi_error "macOS Swift package does not have the expected Swift.org installer signature"
    printf '%s\n' \
        "sha256=${GIFTUI_PI_HOST_PACKAGE_SHA256}" \
        "signer=${GIFTUI_PI_HOST_PACKAGE_SIGNER}" \
        >"${signature_marker}"
fi

host_toolchain_is_ready=0
if [[ -x "${GIFTUI_PI_HOST_BIN_DIR}/swift" &&
    -x "${GIFTUI_PI_HOST_BIN_DIR}/swift-autolink-extract" ]]; then
    installed_host_version="$("${GIFTUI_PI_HOST_BIN_DIR}/swift" --version | sed -n '/Swift version/{p;q;}')"
    if [[ "${installed_host_version}" == *"Swift version ${GIFTUI_PI_SWIFT_VERSION}"* ]]; then
        host_toolchain_is_ready=1
    fi
fi

if [[ "${force}" -eq 1 || "${host_toolchain_is_ready}" -eq 0 ]]; then
    host_extraction_root="$(mktemp -d "${GIFTUI_PI_HOST_PARENT}/.extract.XXXXXX")"
    cleanup_host() {
        rm -rf "${host_extraction_root}"
    }
    trap cleanup_host EXIT

    giftui_pi_note "unpacking the macOS Swift toolchain into the project"
    /usr/sbin/pkgutil --expand-full \
        "${GIFTUI_PI_HOST_PACKAGE_PATH}" \
        "${host_extraction_root}/expanded"

    extracted_swift="$(
        find "${host_extraction_root}/expanded" \
            \( -type f -o -type l \) \
            -path '*/Payload/usr/bin/swift' \
            -print \
            -quit
    )"
    [[ -n "${extracted_swift}" ]] ||
        giftui_pi_error "macOS Swift package did not contain Payload/usr/bin/swift"
    extracted_payload="$(dirname "$(dirname "$(dirname "${extracted_swift}")")")"
    [[ -x "${extracted_payload}/usr/bin/swift-autolink-extract" ]] ||
        giftui_pi_error "macOS Swift package did not contain swift-autolink-extract"

    rm -rf "${GIFTUI_PI_HOST_TOOLCHAIN_DIR}"
    mv "${extracted_payload}" "${GIFTUI_PI_HOST_TOOLCHAIN_DIR}"

    trap - EXIT
    cleanup_host
else
    giftui_pi_note "project-local macOS Swift toolchain is already installed"
fi

host_version="$(giftui_pi_host_swift_version_line)"
[[ "${host_version}" == *"Swift version ${GIFTUI_PI_SWIFT_VERSION}"* ]] ||
    giftui_pi_error "project-local Swift ${GIFTUI_PI_SWIFT_VERSION} is required; found: ${host_version}"
host_toolchain_bin="${GIFTUI_PI_HOST_BIN_DIR}"

archive_is_valid=0
if [[ -f "${GIFTUI_PI_ARCHIVE_PATH}" ]]; then
    actual_sha="$(shasum -a 256 "${GIFTUI_PI_ARCHIVE_PATH}" | awk '{print $1}')"
    if [[ "${actual_sha}" == "${GIFTUI_PI_SDK_SHA256}" ]]; then
        archive_is_valid=1
        giftui_pi_note "using verified cached SDK archive"
    elif [[ "${offline}" -eq 1 ]]; then
        giftui_pi_error "cached SDK archive checksum does not match the pinned digest"
    fi
fi

if [[ "${archive_is_valid}" -eq 0 ]]; then
    [[ "${offline}" -eq 0 ]] ||
        giftui_pi_error "offline setup requested but no verified SDK archive is available"

    temporary_archive="${GIFTUI_PI_ARCHIVE_PATH}.download"
    giftui_pi_note "downloading ${GIFTUI_PI_SDK_ARCHIVE}"
    curl -fL --retry 3 --progress-bar \
        "${GIFTUI_PI_SDK_URL}" \
        -o "${temporary_archive}"

    actual_sha="$(shasum -a 256 "${temporary_archive}" | awk '{print $1}')"
    [[ "${actual_sha}" == "${GIFTUI_PI_SDK_SHA256}" ]] ||
        giftui_pi_error "downloaded SDK checksum does not match the pinned digest"

    mv -f "${temporary_archive}" "${GIFTUI_PI_ARCHIVE_PATH}"
fi

sdk_is_local=0
if [[ -f "${GIFTUI_PI_STATIC_DESTINATION}" ]] &&
    grep -Fq "\"sdk\":\"${GIFTUI_PI_SDK_DIR}/" "${GIFTUI_PI_STATIC_DESTINATION}" &&
    grep -Fq "\"toolchain-bin-dir\":\"${host_toolchain_bin}\"" "${GIFTUI_PI_STATIC_DESTINATION}"; then
    sdk_is_local=1
fi

if [[ "${force}" -eq 1 || "${sdk_is_local}" -eq 0 ]]; then
    extraction_root="$(mktemp -d "${GIFTUI_PI_SDK_PARENT}/.extract.XXXXXX")"
    cleanup() {
        rm -rf "${extraction_root}"
    }
    trap cleanup EXIT

    giftui_pi_note "extracting SDK into the project"
    tar -xzf "${GIFTUI_PI_ARCHIVE_PATH}" -C "${extraction_root}"
    extracted_sdk="${extraction_root}/${GIFTUI_PI_SDK_NAME}"
    [[ -d "${extracted_sdk}" ]] ||
        giftui_pi_error "SDK archive did not contain ${GIFTUI_PI_SDK_NAME}"

    rm -rf "${GIFTUI_PI_SDK_DIR}"
    mv "${extracted_sdk}" "${GIFTUI_PI_SDK_DIR}"

    for destination in \
        "${GIFTUI_PI_STATIC_DESTINATION}" \
        "${GIFTUI_PI_DYNAMIC_DESTINATION}"; do
        localized="${destination}.localized"
        sed \
            -e "s#/opt/${GIFTUI_PI_SDK_NAME}#${GIFTUI_PI_SDK_DIR}#g" \
            -e "s#\"toolchain-bin-dir\":\"/usr/bin\"#\"toolchain-bin-dir\":\"${host_toolchain_bin}\"#g" \
            "${destination}" >"${localized}"
        mv -f "${localized}" "${destination}"
    done

    printf '%s\n' \
        "swift_version=${GIFTUI_PI_SWIFT_VERSION}" \
        "target=${GIFTUI_PI_TARGET}" \
        "distribution=${GIFTUI_PI_DISTRIBUTION}" \
        "sha256=${GIFTUI_PI_SDK_SHA256}" \
        >"${GIFTUI_PI_SDK_DIR}/.giftui-install"

    trap - EXIT
    cleanup
else
    giftui_pi_note "project-local SDK is already installed"
fi

if [[ "${verify}" -eq 1 ]]; then
    exec "${SCRIPT_DIR}/doctor.sh" --probe
else
    exec "${SCRIPT_DIR}/doctor.sh"
fi
