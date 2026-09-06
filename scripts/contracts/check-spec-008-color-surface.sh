#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC008"

swift build --package-path "${PROJECT_ROOT}" --target GiftUI >/dev/null
module_dir="$(swift build --package-path "${PROJECT_ROOT}" --show-bin-path)/Modules"
compiler="$(xcrun --find swiftc)"
sdk="$(xcrun --sdk macosx --show-sdk-path)"
temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/giftui-spec008-color.XXXXXX")"
trap 'rm -rf "${temporary_root}"' EXIT

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
done <"${FIXTURE_ROOT}/color-compile-fixtures.tsv"

declarations="$(rg -n 'public struct Color' "${PROJECT_ROOT}/Sources" || true)"
expected="${PROJECT_ROOT}/Sources/GiftUI/Color.swift:1:public struct Color: Equatable, Hashable, Sendable {"
[[ "${declarations}" == "${expected}" ]] || {
    printf 'Color declaration ownership differs:\n%s\n' "${declarations}" >&2
    exit 1
}

printf 'SPEC-008 Color surface passed: exact layout tests and five client fixtures.\n'
