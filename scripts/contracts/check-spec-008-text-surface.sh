#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC008"
SOURCE="${PROJECT_ROOT}/Sources/GiftUI/Text.swift"
temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/giftui-spec008-text.XXXXXX")"
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
done <"${FIXTURE_ROOT}/text-compile-fixtures.tsv"

declarations="$(rg -n 'public struct Text: View' "${PROJECT_ROOT}/Sources" || true)"
expected="${SOURCE}:14:public struct Text: View {"
[[ "${declarations}" == "${expected}" ]] || {
    printf 'Text declaration ownership differs:\n%s\n' "${declarations}" >&2
    exit 1
}

[[ "$(rg -c 'visitor\.visitPrimitive\(_giftUITextPayload\)' "${SOURCE}")" -eq 1 ]]
[[ "$(rg -c 'case invalidDeclaration' "${SOURCE}")" -eq 1 ]]
if rg -n '\b(String|Array|ContiguousArray|class|actor)\b' "${SOURCE}" >/dev/null; then
    printf 'Text source contains forbidden unbounded or reference storage\n' >&2
    exit 1
fi

printf 'SPEC-008 Text surface passed: primitive/invalid-marker audit and four client fixtures.\n'
