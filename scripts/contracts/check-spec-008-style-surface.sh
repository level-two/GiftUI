#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC008"
SOURCE="${PROJECT_ROOT}/Sources/GiftUI/StyleModifiers.swift"
temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/giftui-spec008-style.XXXXXX")"
trap 'rm -rf "${temporary_root}"' EXIT
export CLANG_MODULE_CACHE_PATH="${temporary_root}/clang-module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${temporary_root}/swiftpm-module-cache"

swift build --package-path "${PROJECT_ROOT}" --target GiftUI >/dev/null
module_dir="$(swift build --package-path "${PROJECT_ROOT}" --show-bin-path)/Modules"
compiler="$(xcrun --find swiftc)"
sdk="$(xcrun --sdk macosx --show-sdk-path)"

while IFS=$'\t' read -r id expectation entry patterns; do
    [[ -n "${id}" && "${id}" != \#* ]] || continue
    stdout_path="${temporary_root}/${id}.stdout"
    stderr_path="${temporary_root}/${id}.stderr"
    set +e
    "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk}" \
        -I "${module_dir}" -typecheck "${FIXTURE_ROOT}/${entry}" \
        >"${stdout_path}" 2>"${stderr_path}"
    result=$?
    set -e
    if [[ "${expectation}" == "pass" ]]; then
        [[ "${result}" -eq 0 ]] || {
            cat "${stderr_path}" >&2
            exit 1
        }
    else
        [[ "${result}" -ne 0 ]] || {
            printf 'negative fixture %s unexpectedly compiled\n' "${id}" >&2
            exit 1
        }
        while IFS= read -r pattern; do
            [[ -n "${pattern}" && "${pattern}" != \#* ]] || continue
            grep -Fq "${pattern}" "${stderr_path}" || {
                cat "${stderr_path}" >&2
                exit 1
            }
        done <"${FIXTURE_ROOT}/${patterns}"
    fi
done <"${FIXTURE_ROOT}/style-compile-fixtures.tsv"

[[ "$(rg -c '^    func foregroundStyle\(_ color: Color\) -> some View' "${SOURCE}")" -eq 1 ]]
[[ "$(rg -c '^    func background\(_ color: Color\) -> some View' "${SOURCE}")" -eq 1 ]]
[[ "$(rg -c 'visitor\.visitModifier\(content: content, payload: payload\)' "${SOURCE}")" -eq 1 ]]
[[ "$(rg -c 'package let color: Color' "${SOURCE}")" -eq 2 ]]
if rg -n '\b(Render|Backend|Layout|String|Array|class|actor)\b' "${SOURCE}" >/dev/null; then
    printf 'Style modifier source contains rendering, backend, or dynamic storage\n' >&2
    exit 1
fi

printf 'SPEC-008 style surface passed: typed modifier audit and three client fixtures.\n'
