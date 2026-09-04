#!/usr/bin/env bash

# Shared host-side SwiftPM invocation. Cross-compilation setup remains owned by
# scripts/raspberry-pi and scripts/nrf52840.
giftui_swiftpm() {
    local package_path="" scratch_path="" cache_root="" configuration=""
    local target="" product="" disable_sandbox=false
    # Bash 3.2 treats expansion of an empty local array as an unbound variable
    # under `set -u`, so retain and skip one private sentinel.
    local -a swift_flags=("__giftui_no_swift_flag__")
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --package-path) package_path="$2"; shift 2 ;;
            --scratch-path) scratch_path="$2"; shift 2 ;;
            --cache-root) cache_root="$2"; shift 2 ;;
            --configuration) configuration="$2"; shift 2 ;;
            --target) target="$2"; shift 2 ;;
            --product) product="$2"; shift 2 ;;
            --swift-flag) swift_flags+=("$2"); shift 2 ;;
            --disable-sandbox) disable_sandbox=true; shift ;;
            --) shift; break ;;
            *) printf 'error: unknown giftui_swiftpm option: %s\n' "$1" >&2; return 2 ;;
        esac
    done
    [[ -n "${package_path}" && -n "${cache_root}" && $# -gt 0 ]] || {
        printf 'error: giftui_swiftpm requires --package-path, --cache-root, and a command after --\n' >&2
        return 2
    }
    mkdir -p "${cache_root}/manifest-cache" "${cache_root}/module-cache" "${cache_root}/clang-cache"
    local swift_executable="${GIFTUI_SWIFT_EXECUTABLE:-swift}"
    local -a command=("${swift_executable}" "$1")
    shift
    command+=(--package-path "${package_path}")
    [[ -z "${scratch_path}" ]] || command+=(--scratch-path "${scratch_path}")
    [[ -z "${configuration}" ]] || command+=(--configuration "${configuration}")
    [[ -z "${target}" ]] || command+=(--target "${target}")
    [[ -z "${product}" ]] || command+=(--product "${product}")
    [[ "${disable_sandbox}" == false ]] || command+=(--disable-sandbox)
    local flag
    for flag in "${swift_flags[@]}"; do
        [[ "${flag}" == "__giftui_no_swift_flag__" ]] || command+=(-Xswiftc "${flag}")
    done
    command+=("$@")
    printf 'swiftpm-command:' >&2
    printf ' %q' "${command[@]}" >&2
    printf '\n' >&2
    local diagnostic
    diagnostic="$(mktemp /private/tmp/giftui-swiftpm-diagnostic.XXXXXX)" || return 1
    local result
    if CLANG_MODULE_CACHE_PATH="${cache_root}/clang-cache" \
        SWIFTPM_MODULECACHE_OVERRIDE="${cache_root}/module-cache" \
        SWIFTPM_TESTS_MODULECACHE="${cache_root}/manifest-cache" \
        "${command[@]}" 2>"${diagnostic}"; then
        result=0
    else
        result=$?
    fi
    cat "${diagnostic}" >&2
    if [[ "${result}" -ne 0 ]]; then
        if grep -Eiq 'sandbox-exec|sandbox_apply|operation not permitted|permission denied' "${diagnostic}"; then
            printf 'swiftpm-failure-class=host-permission-or-sandbox\n' >&2
        else
            printf 'swiftpm-failure-class=compiler-or-test\n' >&2
        fi
    fi
    rm -f "${diagnostic}"
    return "${result}"
}
