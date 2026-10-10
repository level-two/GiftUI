#!/usr/bin/env bash

# SPEC-002 / SPEC-013 RFC-014 selection. Never consult PATH or local overrides
# for the migration compiler, and never change the user's selected toolchain.
giftui_rfc014_select_compiler() {
    local root="$1" profile="$2"
    case "${profile}" in
        macos-dynamic | macos-static | raspberry-pi-armv6)
            GIFTUI_CONTRACT_SWIFTC="${root}/.toolchains/host/swift-6.3.2-RELEASE-osx/usr/bin/swiftc"
            ;;
        nrf52840-embedded)
            GIFTUI_CONTRACT_SWIFTC="${root}/.toolchains/nrf52840/swift/swift-6.3.2-RELEASE-osx/usr/bin/swiftc"
            ;;
        *) printf 'error: unknown migration profile: %s\n' "${profile}" >&2; return 1 ;;
    esac
    [[ -x "${GIFTUI_CONTRACT_SWIFTC}" ]] || {
        printf 'error: pinned RFC-014 compiler is missing: %s\n' "${GIFTUI_CONTRACT_SWIFTC}" >&2
        return 1
    }
    GIFTUI_CONTRACT_FEATURE_FLAGS=(
        -enable-experimental-feature LifetimeDependence
        -enable-experimental-feature Lifetimes
    )
}

giftui_rfc014_check_compiler() {
    local compiler="$1" fixture="$2" output_dir="$3"
    shift 3
    local version
    version="$("${compiler}" --version 2>&1)" || return 1
    [[ "${version}" == *'Apple Swift version 6.3.2 (swift-6.3.2-RELEASE)'* ]] || {
        printf 'error: RFC-014 compiler identity mismatch: %s\n' "${version}" >&2
        return 1
    }
    mkdir -p "${output_dir}"
    # This tests the required features and internal annotation in the selected
    # target configuration; accepting an unknown -enable flag is insufficient.
    "${compiler}" "$@" -typecheck "${fixture}" \
        >"${output_dir}/compiler-features.log" 2>&1 || {
        printf 'error: RFC-014 requires LifetimeDependence and Lifetimes; see %s/compiler-features.log\n' "${output_dir}" >&2
        return 1
    }
}
