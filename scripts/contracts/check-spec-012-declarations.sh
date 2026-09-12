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
    macos-dynamic | macos-static | raspberry-pi-armv6 | nrf52840-embedded) ;;
    "") fail '--profile is required' ;;
    *) fail "unknown profile: ${profile}" ;;
esac

temporary_root=""
if [[ -z "${output_root}" ]]; then
    temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/giftui-spec012-declarations.XXXXXX")"
    output_root="${temporary_root}"
fi
trap '[[ -z "${temporary_root}" ]] || rm -rf "${temporary_root}"' EXIT
mkdir -p \
    "${output_root}/modules" \
    "${output_root}/fixtures" \
    "${output_root}/artifacts" \
    "${output_root}/module-cache"
commands_path="${output_root}/commands.txt"
results_path="${output_root}/results.tsv"
audit_path="${output_root}/audit.tsv"
: >"${commands_path}"
printf '# case\texpectation\tmode\tresult\n' >"${results_path}"
printf '# audit\tresult\n' >"${audit_path}"
export CLANG_MODULE_CACHE_PATH="${output_root}/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${output_root}/module-cache"

record_command() {
    printf '%q ' "$@" >>"${commands_path}"
    printf '\n' >>"${commands_path}"
}

compiler=""
flags=()
case "${profile}" in
    macos-dynamic | macos-static)
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
        ;;
    raspberry-pi-armv6)
        source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
        swift_driver="$(giftui_pi_host_swift)"
        compiler="$(dirname "${swift_driver}")/swiftc"
        giftui_pi_require_sdk
        giftui_pi_prepare_build_environment
        flags=(
            -target "${GIFTUI_PI_TARGET}"
            -sdk "${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}"
            -resource-dir "${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr/lib/swift_static"
            -Xcc "--gcc-toolchain=${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr"
            -Xcc -march=armv6 -Xcc -mfpu=vfp -Xcc -mfloat-abi=hard
            -Xcc -D_FILE_OFFSET_BITS=64 -Xcc -fPIC
            -O -whole-module-optimization -DGIFTUI_DYNAMIC_PROFILE
            -language-mode 6
        )
        ;;
    nrf52840-embedded)
        source "${PROJECT_ROOT}/scripts/nrf52840/common.sh"
        giftui_nrf_require_environment
        compiler="${GIFTUI_NRF_SWIFTC}"
        flags=(
            -target "${GIFTUI_NRF_SWIFT_TARGET}"
            -enable-experimental-feature Embedded
            -Osize -whole-module-optimization -DGIFTUI_STATIC_PROFILE
            -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4
            -Xcc -mfpu=fpv4-sp-d16
            -language-mode 6
        )
        ;;
esac

sources=()
while IFS= read -r source; do
    sources+=("${source}")
done < <(find "${PROJECT_ROOT}/Sources/GiftUI" -type f -name '*.swift' -print | LC_ALL=C sort)

module_path="${output_root}/modules/GiftUI.swiftmodule"
interface_path="${output_root}/modules/GiftUI.swiftinterface"
module_command=(
    "${compiler}" "${flags[@]}" -parse-as-library
    -package-name GiftUI -emit-module -module-name GiftUI
    "${sources[@]}" -emit-module-path "${module_path}"
    -emit-module-interface-path "${interface_path}"
)
record_command "${module_command[@]}"
"${module_command[@]}" >/dev/null

for fragment in \
    'public struct Canvas :' \
    'public typealias Body = Swift.Never' \
    'throws(GiftUI.DrawingError)' \
    'public struct GraphicsContext : ~Swift.Copyable' \
    'public mutating func withPath<Result>' \
    'public struct Path : ~Swift.Copyable' \
    'public struct Shading :' \
    'public struct StrokeStyle :' \
    'public enum LineCap : Swift.UInt8' \
    'public enum LineJoin : Swift.UInt8' \
    'public enum DrawingError : Swift.Error'; do
    grep -Fq "${fragment}" "${interface_path}" ||
        fail "emitted interface lacks: ${fragment}"
done
for forbidden in 'any Error' 'Foundation.'; do
    ! grep -Fq "${forbidden}" "${interface_path}" ||
        fail "emitted interface contains forbidden dependency: ${forbidden}"
done
if [[ "${profile}" == macos-dynamic || "${profile}" == raspberry-pi-armv6 ]]; then
    grep -Fq 'private let draw:' "${interface_path}" ||
        fail 'dynamic profile omitted bounded Canvas closure storage'
else
    ! grep -Fq 'private let draw:' "${interface_path}" ||
        fail 'static profile retained Canvas closure storage'
fi
printf 'public-interface\tpass\nprofile-canvas-storage\tpass\n' >>"${audit_path}"

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

probe_source="${FIXTURE_ROOT}/Fixtures/Positive/typed-trailing-closures/main.swift"
baseline_source="${FIXTURE_ROOT}/Instrumentation/DeclarationBaseline.swift"
sil_path="${output_root}/artifacts/declaration-client.sil"
object_path="${output_root}/artifacts/declaration-client.o"
baseline_sil_path="${output_root}/artifacts/declaration-baseline.sil"
baseline_object_path="${output_root}/artifacts/declaration-baseline.o"
sil_command=(
    "${compiler}" "${flags[@]}" -I "${output_root}/modules"
    -emit-sil "${probe_source}" -o "${sil_path}"
)
record_command "${sil_command[@]}"
"${sil_command[@]}" >/dev/null
baseline_sil_command=(
    "${compiler}" "${flags[@]}" -I "${output_root}/modules"
    -emit-sil "${baseline_source}" -o "${baseline_sil_path}"
)
record_command "${baseline_sil_command[@]}"
"${baseline_sil_command[@]}" >/dev/null
object_command=(
    "${compiler}" "${flags[@]}" -I "${output_root}/modules"
    -c "${probe_source}" -o "${object_path}"
)
record_command "${object_command[@]}"
"${object_command[@]}" >/dev/null
baseline_object_command=(
    "${compiler}" "${flags[@]}" -I "${output_root}/modules"
    -c "${baseline_source}" -o "${baseline_object_path}"
)
record_command "${baseline_object_command[@]}"
"${baseline_object_command[@]}" >/dev/null
nm_tool="$(dirname "${compiler}")/llvm-nm"
[[ -x "${nm_tool}" ]] || fail "llvm-nm is missing beside compiler: ${nm_tool}"
record_command "${nm_tool}" -u "${object_path}"
"${nm_tool}" -u "${object_path}" >"${output_root}/artifacts/undefined-symbols.txt"
record_command "${nm_tool}" -u "${baseline_object_path}"
"${nm_tool}" -u "${baseline_object_path}" >"${output_root}/artifacts/baseline-undefined-symbols.txt"
for artifact_kind in sil symbols; do
    candidate_artifact="${sil_path}"
    baseline_artifact="${baseline_sil_path}"
    if [[ "${artifact_kind}" == symbols ]]; then
        candidate_artifact="${output_root}/artifacts/undefined-symbols.txt"
        baseline_artifact="${output_root}/artifacts/baseline-undefined-symbols.txt"
    fi
    grep -Eo \
        'any Error|swift_allocObject|swift_getTypeByMangledName|swift_task_[A-Za-z0-9_]*|objc_[A-Za-z0-9_]*|__cxa_[A-Za-z0-9_]*|posix_memalign|(^|[[:space:]])free$' \
        "${candidate_artifact}" | LC_ALL=C sort -u >"${output_root}/artifacts/candidate-${artifact_kind}-forbidden.txt" || true
    grep -Eo \
        'any Error|swift_allocObject|swift_getTypeByMangledName|swift_task_[A-Za-z0-9_]*|objc_[A-Za-z0-9_]*|__cxa_[A-Za-z0-9_]*|posix_memalign|(^|[[:space:]])free$' \
        "${baseline_artifact}" | LC_ALL=C sort -u >"${output_root}/artifacts/baseline-${artifact_kind}-forbidden.txt" || true
    comm -13 \
        "${output_root}/artifacts/baseline-${artifact_kind}-forbidden.txt" \
        "${output_root}/artifacts/candidate-${artifact_kind}-forbidden.txt" \
        >"${output_root}/artifacts/introduced-${artifact_kind}-forbidden.txt"
    [[ ! -s "${output_root}/artifacts/introduced-${artifact_kind}-forbidden.txt" ]] || {
        cat "${output_root}/artifacts/introduced-${artifact_kind}-forbidden.txt" >&2
        fail "declaration ${artifact_kind} introduced a forbidden artifact"
    }
done
printf 'declaration-sil\tpass\nundefined-symbols\tpass\n' >>"${audit_path}"

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
            "${focused_sources[@]}" "${source}" -c
            -o "${fixture_dir}/forbidden.o"
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
