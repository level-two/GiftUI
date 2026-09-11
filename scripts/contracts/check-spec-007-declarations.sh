#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC007"

swift build --package-path "${PROJECT_ROOT}" --target GiftUI >/dev/null
module_dir="$(swift build --package-path "${PROJECT_ROOT}" --show-bin-path)/Modules"
compiler="$(xcrun --find swiftc)"
sdk="$(xcrun --sdk macosx --show-sdk-path)"
temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/giftui-spec007-declarations.XXXXXX")"
trap 'rm -rf "${temporary_root}"' EXIT

while IFS=$'\t' read -r id entry; do
    [[ -n "${id}" && "${id}" != \#* ]] || continue
    "${compiler}" -target arm64-apple-macosx15.0 -sdk "${sdk}" \
        -I "${module_dir}" -typecheck "${FIXTURE_ROOT}/${entry}" \
        >"${temporary_root}/${id}.stdout" 2>"${temporary_root}/${id}.stderr" || {
        cat "${temporary_root}/${id}.stderr" >&2
        exit 1
    }
done <"${FIXTURE_ROOT}/public-compile-fixtures.tsv"

layout_sources=(
    "${PROJECT_ROOT}/Sources/GiftUI/LayoutValues.swift"
    "${PROJECT_ROOT}/Sources/GiftUI/LayoutContainers.swift"
    "${PROJECT_ROOT}/Sources/GiftUI/LayoutModifiers.swift"
)

if rg -n '^(@_exported )?import ' "${layout_sources[@]}"; then
    printf 'SPEC-007 declarations must not import another module\n' >&2
    exit 1
fi

if rg -n '\b(measure|measurement|place|placement|CanonicalText|GiftUILayout|GiftUIRender|GiftUIRuntime|backend|capability)\b' \
    "${layout_sources[@]}"; then
    printf 'SPEC-007 client declarations contain layout execution or forbidden ownership\n' >&2
    exit 1
fi

container_source="${PROJECT_ROOT}/Sources/GiftUI/LayoutContainers.swift"
[[ "$(rg -c 'visitor\.visitPrimitive\(content: content, payload: payload\)' "${container_source}")" -eq 3 ]]
[[ "$(rg -c 'visitor\.visitPrimitive\(payload\)' "${container_source}")" -eq 1 ]]

printf 'SPEC-007 declaration surface passed: two public-client fixtures and four typed primitive witnesses.\n'
