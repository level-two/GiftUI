#!/usr/bin/env bash

# Called after successful artifact construction. Keep native checks distinct
# from the compiler and SDK selected by the artifact's build entry point.
giftui_artifact_toolchain_metadata() (
    local profile="$1" root="$2" compiler sdk sdk_hash
    printf 'native_check_compiler_path=%s\n' "$(command -v swiftc)"
    printf 'native_check_compiler_identity=%s\n' "$(swiftc --version 2>&1 | tr '\n' ' ')"
    case "${profile}" in
        macos-dynamic | macos-static)
            compiler="$(command -v swiftc)"
            sdk="$(xcrun --sdk macosx --show-sdk-path)"
            sdk_hash="$(xcrun --sdk macosx --show-sdk-version)"
            ;;
        raspberry-pi-armv6)
            source "${root}/scripts/raspberry-pi/common.sh"
            compiler="$(giftui_pi_host_swift)"
            sdk="${GIFTUI_PI_STATIC_DESTINATION}"
            [[ -f "${sdk}" ]] || return 1
            sdk_hash="$(shasum -a 256 "${sdk}" | awk '{print $1}')"
            ;;
        nrf52840-embedded)
            source "${root}/scripts/nrf52840/common.sh"
            compiler="${GIFTUI_NRF_SWIFTC}"
            sdk="${GIFTUI_NRF_SDK_DIR}"
            [[ -d "${sdk}" ]] || return 1
            sdk_hash="$(cat "${sdk}/sdk_version")"
            printf 'zephyr_revision=%s\n' "$(git -C "${GIFTUI_NRF_ZEPHYR_BASE}" rev-parse HEAD)"
            ;;
        *) return 2 ;;
    esac
    [[ -x "${compiler}" ]] || return 1
    printf 'compiler_path=%s\ncompiler_identity=%s\n' "${compiler}" "$("${compiler}" --version 2>&1 | tr '\n' ' ')"
    printf 'sdk_identity=%s\nsdk_version_or_destination_sha256=%s\n' "${sdk}" "${sdk_hash}"
)
