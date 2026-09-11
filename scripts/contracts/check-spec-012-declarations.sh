#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC012"

fail() {
    printf 'SPEC-012 declaration check failed: %s\n' "$*" >&2
    exit 1
}

profile=""
output_root=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile)
            [[ $# -ge 2 ]] || fail '--profile requires a value'
            profile="$2"
            shift 2
            ;;
        --output)
            [[ $# -ge 2 ]] || fail '--output requires a value'
            output_root="$2"
            shift 2
            ;;
        *) fail "unknown option: $1" ;;
    esac
done
case "${profile}" in
    macos-dynamic | macos-static) ;;
    "") fail '--profile is required' ;;
    *) fail "T1.4 supports macOS profiles only: ${profile}" ;;
esac

temporary_root=""
if [[ -z "${output_root}" ]]; then
    temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/giftui-spec012-declarations.XXXXXX")"
    output_root="${temporary_root}"
fi
trap '[[ -z "${temporary_root}" ]] || rm -rf "${temporary_root}"' EXIT
mkdir -p "${output_root}/modules" "${output_root}/fixtures" "${output_root}/module-cache"
commands_path="${output_root}/commands.txt"
results_path="${output_root}/results.tsv"
: >"${commands_path}"
printf '# case\texpectation\tmode\tresult\n' >"${results_path}"
export CLANG_MODULE_CACHE_PATH="${output_root}/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${output_root}/module-cache"

record_command() {
    printf '%q ' "$@" >>"${commands_path}"
    printf '\n' >>"${commands_path}"
}

compiler="$(xcrun --find swiftc)"
sdk="$(xcrun --sdk macosx --show-sdk-path)"
profile_flag=-DGIFTUI_DYNAMIC_PROFILE
[[ "${profile}" != "macos-static" ]] || profile_flag=-DGIFTUI_STATIC_PROFILE
flags=(
    -target arm64-apple-macosx26.0
    -sdk "${sdk}"
    -O -whole-module-optimization
    "${profile_flag}"
    -language-mode 6
)

sources=()
while IFS= read -r source; do
    sources+=("${source}")
done < <(find "${PROJECT_ROOT}/Sources/GiftUI" -type f -name '*.swift' -print | LC_ALL=C sort)

module_path="${output_root}/modules/GiftUI.swiftmodule"
module_command=(
    "${compiler}" "${flags[@]}" -parse-as-library
    -package-name GiftUI -emit-module -module-name GiftUI
    "${sources[@]}" -emit-module-path "${module_path}"
)
record_command "${module_command[@]}"
"${module_command[@]}" >/dev/null

fixture_count=0
while IFS=$'\t' read -r case_name _family _expected _criteria _status; do
    [[ -n "${case_name}" && "${case_name}" != \#* ]] || continue
    fixture_count=$((fixture_count + 1))
    fixture_dir="${output_root}/fixtures/${case_name}"
    mkdir -p "${fixture_dir}"
    source="${FIXTURE_ROOT}/Fixtures/Positive/${case_name}/main.swift"
    command=("${compiler}" "${flags[@]}" -I "${output_root}/modules" -typecheck "${source}")
    record_command "${command[@]}"
    "${command[@]}" >"${fixture_dir}/stdout.txt" 2>"${fixture_dir}/stderr.txt" || {
        cat "${fixture_dir}/stderr.txt" >&2
        fail "positive fixture ${case_name} failed"
    }
    printf '%s\tpass\timported-module\tpass\n' "${case_name}" >>"${results_path}"
done <"${FIXTURE_ROOT}/declaration-compile-fixtures.tsv"

focused_sources=(
    "${PROJECT_ROOT}/Sources/GiftUI/GiftUI.swift"
    "${PROJECT_ROOT}/Sources/GiftUI/Color.swift"
    "${PROJECT_ROOT}/Sources/GiftUI/DrawingStyles.swift"
    "${PROJECT_ROOT}/Sources/GiftUI/DrawingSurface.swift"
)
while IFS=$'\t' read -r case_name _family _expected _criteria _status; do
    [[ -n "${case_name}" && "${case_name}" != \#* ]] || continue
    fixture_count=$((fixture_count + 1))
    fixture_dir="${output_root}/fixtures/${case_name}"
    mkdir -p "${fixture_dir}"
    source="${FIXTURE_ROOT}/Fixtures/Negative/${case_name}/main.swift"
    mode=imported-module
    command=("${compiler}" "${flags[@]}" -I "${output_root}/modules" -typecheck "${source}")
    if [[ "${case_name}" == path-consume || "${case_name}" == captured-outer-context ]]; then
        mode=whole-module-ownership
        command=(
            "${compiler}" "${flags[@]}" -parse-as-library
            -package-name GiftUI -module-name GiftUI
            "${focused_sources[@]}" "${source}" -emit-library
            -o "${fixture_dir}/forbidden.dylib"
        )
    fi
    record_command "${command[@]}"
    set +e
    "${command[@]}" >"${fixture_dir}/stdout.txt" 2>"${fixture_dir}/stderr.txt"
    result_code=$?
    set -e
    [[ "${result_code}" -ne 0 ]] || fail "negative fixture ${case_name} unexpectedly compiled"
    while IFS= read -r pattern; do
        [[ -n "${pattern}" && "${pattern}" != \#* ]] || continue
        grep -Fq "${pattern}" "${fixture_dir}/stderr.txt" || {
            cat "${fixture_dir}/stderr.txt" >&2
            fail "negative fixture ${case_name} lacked diagnostic: ${pattern}"
        }
    done <"${FIXTURE_ROOT}/Fixtures/Negative/${case_name}/expected-diagnostic-patterns.txt"
    printf '%s\tfail\t%s\tpass\n' "${case_name}" "${mode}" >>"${results_path}"
done <"${FIXTURE_ROOT}/negative-compile-fixtures.tsv"

[[ "${fixture_count}" -eq 16 ]] || fail "expected 16 fixtures, found ${fixture_count}"
printf 'SPEC-012 %s declarations passed: 7 positive and 9 negative fixtures.\n' "${profile}"
