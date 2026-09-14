#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"

fail() {
    printf 'SPEC-014 macOS profile collection failed: %s\n' "$*" >&2
    exit 1
}

[[ $# -eq 2 ]] || fail 'usage: collect-spec-014-macos-profile.sh PROFILE OUTPUT'
profile="$1"
output="$2"
case "${profile}" in
    macos-dynamic) profile_flag=-DGIFTUI_DYNAMIC_PROFILE ;;
    macos-static) profile_flag=-DGIFTUI_STATIC_PROFILE ;;
    *) fail "unsupported profile: ${profile}" ;;
esac

mkdir -p "${output}" "${output}/module-cache"
output="$(cd "${output}" && pwd -P)"
export CLANG_MODULE_CACHE_PATH="${output}/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${output}/module-cache"
commands="${output}/commands.txt"
log="${output}/run.log"
: >"${commands}"
: >"${log}"

record_command() {
    printf '%q ' "$@" >>"${commands}"
    printf '\n' >>"${commands}"
}

for suite in GiftUISurfaceCoreTests GiftUIRasterCoreTests GiftUIDisplayCoreTests GiftUIBackendIntegrationTests; do
    command=(swift test --disable-sandbox --package-path "${PROJECT_ROOT}" \
        --scratch-path "${output}/swiftpm" --cache-path "${PROJECT_ROOT}/.build" \
        -Xswiftc "${profile_flag}" \
        --filter "${suite}")
    record_command "${command[@]}"
    "${command[@]}" >>"${log}" 2>&1
done

record_command "${SCRIPT_DIR}/check-spec-014-capability-fixtures.rb"
"${SCRIPT_DIR}/check-spec-014-capability-fixtures.rb" >>"${log}" 2>&1
record_command "${SCRIPT_DIR}/report-spec-014-normalized-fixtures.rb" \
    "${profile}" "${output}/normalized-fixtures.tsv"
"${SCRIPT_DIR}/report-spec-014-normalized-fixtures.rb" \
    "${profile}" "${output}/normalized-fixtures.tsv" >>"${log}" 2>&1

printf 'profile\tflag\ttest_suites\n%s\t%s\t4\n' \
    "${profile}" "${profile_flag}" >"${output}/summary.tsv"
printf 'SPEC-014 %s macOS corpus passed: four production-owner suites and normalized shared fixtures.\n' \
    "${profile}"
