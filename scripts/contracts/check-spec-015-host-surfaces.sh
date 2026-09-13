#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC015/Fixtures"
OUTPUT_ROOT="${PROJECT_ROOT}/.build/spec-015/macos-dynamic/host-surfaces"

fail() {
    printf 'SPEC-015 host surface check failed: %s\n' "$*" >&2
    exit 1
}

if [[ $# -gt 0 ]]; then
    [[ $# -eq 2 && "$1" == "--output" ]] || fail 'expected --output <path>'
    OUTPUT_ROOT="$2"
fi

mkdir -p "${OUTPUT_ROOT}/module-cache"
export CLANG_MODULE_CACHE_PATH="${OUTPUT_ROOT}/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${OUTPUT_ROOT}/module-cache"

# shellcheck source=../lib/swiftpm.sh
source "${PROJECT_ROOT}/scripts/lib/swiftpm.sh"
giftui_swiftpm \
    --package-path "${PROJECT_ROOT}" \
    --scratch-path "${PROJECT_ROOT}/.build" \
    --cache-root "${PROJECT_ROOT}/.build/swiftpm-cache" \
    --disable-sandbox \
    -- build --target GiftUIHostConfiguration >/dev/null

module_file="$(find "${PROJECT_ROOT}/.build" -maxdepth 6 \
    -path '*/debug/Modules/GiftUIHostConfiguration.swiftmodule' -print -quit)"
[[ -n "${module_file}" ]] || fail 'built host configuration module was not found'
module_path="$(dirname "${module_file}")"
[[ -d "${module_path}" ]] || fail "missing built module path: ${module_path}"

compiler="$(xcrun --find swiftc)"
sdk="$(xcrun --sdk macosx --show-sdk-path)"
architecture="$(uname -m)"
common_flags=(
    -typecheck
    -swift-version 6
    -strict-concurrency=complete
    -target "${architecture}-apple-macosx15.0"
    -sdk "${sdk}"
    -I "${module_path}"
)

positive="${FIXTURE_ROOT}/Positive/host-configuration-surface/main.swift"
"${compiler}" "${common_flags[@]}" -package-name giftui "${positive}"

run_negative() {
    local case_name="$1"
    local expected="$2"
    shift 2
    local stderr_path="${OUTPUT_ROOT}/${case_name}.stderr.txt"
    set +e
    "${compiler}" "${common_flags[@]}" "$@" \
        "${FIXTURE_ROOT}/Negative/${case_name}/main.swift" \
        >"${OUTPUT_ROOT}/${case_name}.stdout.txt" 2>"${stderr_path}"
    local result=$?
    set -e
    [[ "${result}" -ne 0 ]] || fail "${case_name} unexpectedly compiled"
    grep -Fq "${expected}" "${stderr_path}" || {
        cat "${stderr_path}" >&2
        fail "${case_name} lacked expected diagnostic: ${expected}"
    }
}

run_negative external-package-access "cannot find 'MVPHostKind' in scope"
run_negative non-sendable-activation-failure \
    "does not conform to the 'Sendable' protocol" -package-name giftui

source_hash="$(shasum -a 256 \
    "${PROJECT_ROOT}/Sources/GiftUIHostConfiguration/HostConfigurationResults.swift" \
    "${positive}" | shasum -a 256 | awk '{print $1}')"
printf 'schema\t1\nsource_sha256\t%s\npositive_surface\tpass\nexternal_package_access\tpass\nnon_sendable_activation_failure\tpass\n' \
    "${source_hash}" >"${OUTPUT_ROOT}/report.tsv"

printf 'SPEC-015 host surfaces passed: exact package API, noncopyable conformers, Sendable values, and two negative compile cases.\n'
