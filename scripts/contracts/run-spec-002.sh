#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002"
REPORT_ROOT="${PROJECT_ROOT}/.build/contract-reports/spec-002"
FOUNDATION_SOURCE="${PROJECT_ROOT}/Sources/GiftUI/GiftUI.swift"
PROFILE_PROBE_ROOT="${FIXTURE_ROOT}/ProfileCorpusProbe"
SEMANTIC_CORPUS="${FIXTURE_ROOT}/SemanticCorpus/cases.tsv"

usage() {
    printf '%s\n' \
        'Usage: scripts/contracts/run-spec-002.sh --profile <profile>' \
        '' \
        'Profiles:' \
        '  macos-dynamic' \
        '  macos-static' \
        '  raspberry-pi-armv6' \
        '  nrf52840-embedded'
}

fail() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

profile=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile)
            [[ $# -ge 2 ]] || fail '--profile requires a value'
            profile="$2"
            shift 2
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            fail "unknown option: $1"
            ;;
    esac
done

case "${profile}" in
    macos-dynamic | macos-static | raspberry-pi-armv6 | nrf52840-embedded) ;;
    "") fail '--profile is required' ;;
    *) fail "unknown profile: ${profile}" ;;
esac

report_dir="${REPORT_ROOT}/${profile}"
rm -rf "${report_dir}"
mkdir -p \
    "${report_dir}/build/clang-cache" \
    "${report_dir}/build/swiftpm-cache" \
    "${report_dir}/fixtures"
export CLANG_MODULE_CACHE_PATH="${report_dir}/build/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${report_dir}/build/swiftpm-cache"
metadata_path="${report_dir}/metadata.txt"
commands_path="${report_dir}/commands.txt"
log_path="${report_dir}/run.log"

revision="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
{
    printf 'schema_version=1\n'
    printf 'spec=SPEC-002\n'
    printf 'profile=%s\n' "${profile}"
    printf 'repository_revision=%s\n' "${revision}"
    printf 'report_directory=.build/contract-reports/spec-002/%s\n' "${profile}"
    printf 'invocation=scripts/contracts/run-spec-002.sh --profile %s\n' "${profile}"
} >"${metadata_path}"
: >"${commands_path}"
: >"${log_path}"

finish() {
    local result=$?
    printf 'exit_code=%s\n' "${result}" >>"${metadata_path}"
    if [[ "${result}" -eq 0 ]]; then
        printf 'SPEC-002 %s contract surface passed\n' "${profile}"
    else
        printf 'SPEC-002 %s contract surface failed; see %s\n' \
            "${profile}" "${report_dir}" >&2
    fi
}
trap finish EXIT

record_command() {
    printf '%q ' "$@" >>"${commands_path}"
    printf '\n' >>"${commands_path}"
}

record_block() {
    local key="$1"
    local value="$2"
    {
        printf '%s<<EOF\n' "${key}"
        printf '%s\n' "${value}"
        printf 'EOF\n'
    } >>"${metadata_path}"
}

require_exact_fragment() {
    local value="$1"
    local fragment="$2"
    local label="$3"
    [[ "${value}" == *"${fragment}"* ]] ||
        fail "${label} mismatch; expected ${fragment}, found ${value}"
}

run_fixture_set() {
    local compiler="$1"
    local module_dir="$2"
    shift 2
    local -a common_flags=("$@")
    local id expectation access entry patterns fixture_dir diagnostic output_path result pattern

    while IFS=$'\t' read -r id expectation access entry patterns; do
        [[ -n "${id}" && "${id}" != \#* ]] || continue
        fixture_dir="${report_dir}/fixtures/${id}"
        mkdir -p "${fixture_dir}"
        output_path="${fixture_dir}/stdout.txt"
        diagnostic="${fixture_dir}/stderr.txt"
        local -a command=(
            "${compiler}" "${common_flags[@]}" -I "${module_dir}"
        )
        if [[ "${access}" == "package" ]]; then
            command+=(-package-name GiftUI)
        fi
        command+=(-typecheck "${FIXTURE_ROOT}/${entry}")
        record_command "${command[@]}"
        set +e
        "${command[@]}" >"${output_path}" 2>"${diagnostic}"
        result=$?
        set -e

        if [[ "${expectation}" == "pass" ]]; then
            [[ "${result}" -eq 0 ]] || fail "positive fixture ${id} failed"
            continue
        fi
        [[ "${result}" -ne 0 ]] || fail "negative fixture ${id} unexpectedly compiled"
        while IFS= read -r pattern; do
            [[ -n "${pattern}" && "${pattern}" != \#* ]] || continue
            grep -Fq "${pattern}" "${diagnostic}" ||
                fail "negative fixture ${id} lacked diagnostic pattern: ${pattern}"
        done <"${FIXTURE_ROOT}/${patterns}"
    done <"${FIXTURE_ROOT}/fixture-manifest.tsv"
}

record_semantic_contract() {
    mkdir -p "${report_dir}/semantics"
    awk 'NF && $0 !~ /^#/' "${SEMANTIC_CORPUS}" \
        >"${report_dir}/semantics/semantic-contract.tsv"
    local corpus_sha256
    corpus_sha256="$(shasum -a 256 "${SEMANTIC_CORPUS}" | awk '{print $1}')"
    printf 'semantic_corpus_sha256=%s\n' "${corpus_sha256}" >>"${metadata_path}"
}

run_macos() {
    [[ "$(uname -s)" == "Darwin" ]] || fail 'macOS profile requires macOS'
    [[ "$(uname -m)" == "arm64" ]] || fail 'macOS evidence requires an arm64 host'
    command -v swiftc >/dev/null || fail 'swiftc is missing'
    command -v swift >/dev/null || fail 'swift is missing'
    command -v xcrun >/dev/null || fail 'xcrun is missing'

    local compiler_version sdk_path sdk_version profile_flag module_dir extension image
    compiler_version="$(swiftc --version 2>&1)"
    require_exact_fragment "${compiler_version}" 'Apple Swift version 6.3.3' 'macOS compiler'
    require_exact_fragment "${compiler_version}" 'swiftlang-6.3.3.1.3' 'macOS compiler build'
    sdk_path="$(xcrun --sdk macosx --show-sdk-path)"
    sdk_version="$(xcrun --sdk macosx --show-sdk-version)"
    [[ -d "${sdk_path}" ]] || fail "macOS SDK is missing: ${sdk_path}"

    if [[ "${profile}" == "macos-dynamic" ]]; then
        profile_flag='-DGIFTUI_DYNAMIC_PROFILE'
        extension='dylib'
    else
        profile_flag='-DGIFTUI_STATIC_PROFILE'
        extension='a'
    fi
    local -a flags=(
        -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -O -whole-module-optimization "${profile_flag}"
    )
    module_dir="${report_dir}/build/modules"
    mkdir -p "${module_dir}"
    image="${report_dir}/build/libGiftUI.${extension}"

    record_block compiler_version "${compiler_version}"
    printf 'target=arm64-apple-macosx26.0\n' >>"${metadata_path}"
    printf 'sdk_path=%s\n' "${sdk_path}" >>"${metadata_path}"
    printf 'sdk_version=%s\n' "${sdk_version}" >>"${metadata_path}"
    printf 'optimization=-O -whole-module-optimization\n' >>"${metadata_path}"
    printf 'profile_flag=%s\n' "${profile_flag}" >>"${metadata_path}"

    local -a module_command=(
        swiftc "${flags[@]}" -language-mode 6 -package-name GiftUI
        -enable-library-evolution -parse-as-library -emit-module
        -emit-library
        -emit-module-interface-path "${module_dir}/GiftUI.swiftinterface"
        -emit-package-module-interface-path "${module_dir}/GiftUI.package.swiftinterface"
        -module-name GiftUI "${PROJECT_ROOT}/Sources/GiftUI/GiftUI.swift"
        -emit-module-path "${module_dir}/GiftUI.swiftmodule"
    )
    if [[ "${profile}" == "macos-static" ]]; then
        module_command+=(-static)
    fi
    module_command+=(-o "${image}")
    record_command "${module_command[@]}"
    "${module_command[@]}" >>"${log_path}" 2>&1

    record_command "${SCRIPT_DIR}/check-foundation-surface.rb" \
        "${module_dir}/GiftUI.swiftinterface" \
        "${module_dir}/GiftUI.package.swiftinterface"
    "${SCRIPT_DIR}/check-foundation-surface.rb" \
        "${module_dir}/GiftUI.swiftinterface" \
        "${module_dir}/GiftUI.package.swiftinterface" >>"${log_path}" 2>&1

    record_command swift package dump-package
    CLANG_MODULE_CACHE_PATH="${report_dir}/build/clang-cache" \
        SWIFTPM_MODULECACHE_OVERRIDE="${report_dir}/build/swiftpm-cache" \
        swift package dump-package >"${report_dir}/package.json" 2>>"${log_path}"
    record_command "${SCRIPT_DIR}/check-target-dependencies.rb"
    "${SCRIPT_DIR}/check-target-dependencies.rb" \
        <"${report_dir}/package.json" >>"${log_path}" 2>&1

    local dependency_scan="${report_dir}/build/GiftUI.dependencies.json"
    local -a scan_command=(
        swiftc "${flags[@]}" -language-mode 6 -package-name GiftUI
        -module-name GiftUI -module-cache-path "${report_dir}/build/clang-cache"
        -scan-dependencies "${PROJECT_ROOT}/Sources/GiftUI/GiftUI.swift"
    )
    record_command "${scan_command[@]}"
    "${scan_command[@]}" >"${dependency_scan}" 2>>"${log_path}"

    local product_links="${report_dir}/build/product-links.txt"
    record_command otool -L "${image}"
    otool -L "${image}" >"${product_links}"
    record_command "${SCRIPT_DIR}/check-spec-002-boundaries.rb" \
        "${report_dir}/package.json" \
        "${module_dir}/GiftUI.swiftinterface" \
        "${module_dir}/GiftUI.package.swiftinterface" \
        "${dependency_scan}" "${product_links}"
    "${SCRIPT_DIR}/check-spec-002-boundaries.rb" \
        "${report_dir}/package.json" \
        "${module_dir}/GiftUI.swiftinterface" \
        "${module_dir}/GiftUI.package.swiftinterface" \
        "${dependency_scan}" "${product_links}" >>"${log_path}" 2>&1

    run_fixture_set swiftc "${module_dir}" "${flags[@]}"

    local probe="${report_dir}/build/profile-corpus-probe"
    local transcript="${report_dir}/semantics/profile-corpus.txt"
    local -a probe_command=(
        swiftc "${flags[@]}" -language-mode 6 -package-name GiftUI
        -module-cache-path "${report_dir}/build/clang-cache"
        -module-name GiftUIFoundationProfileCorpusProbe
        "${FOUNDATION_SOURCE}"
        "${PROFILE_PROBE_ROOT}/ProfileCorpusProbe.swift"
        "${PROFILE_PROBE_ROOT}/main.swift" -o "${probe}"
    )
    record_command "${probe_command[@]}"
    "${probe_command[@]}" >>"${log_path}" 2>&1
    record_command "${probe}"
    "${probe}" >"${transcript}" 2>>"${log_path}"
    grep -Fxq 'profile_corpus_checksum=28' "${transcript}" ||
        fail 'macOS profile corpus transcript differs from checksum 28'

    local counterpart_profile counterpart comparison
    if [[ "${profile}" == 'macos-dynamic' ]]; then
        counterpart_profile='macos-static'
    else
        counterpart_profile='macos-dynamic'
    fi
    counterpart="${REPORT_ROOT}/${counterpart_profile}/semantics/profile-corpus.txt"
    comparison="${report_dir}/semantics/macos-profile-equivalence.txt"
    if [[ -f "${counterpart}" ]]; then
        record_command cmp "${counterpart}" "${transcript}"
        cmp "${counterpart}" "${transcript}" ||
            fail "${profile} semantic transcript differs from ${counterpart_profile}"
        printf 'counterpart=%s\nstatus=byte-for-byte-equal\n' \
            "${counterpart_profile}" >"${comparison}"
    else
        printf 'counterpart=%s\nstatus=not-yet-generated\n' \
            "${counterpart_profile}" >"${comparison}"
    fi

    local layout_ir="${report_dir}/build/foundation-layout.ll"
    local layout_report="${report_dir}/semantics/layout.tsv"
    local -a layout_command=(
        swiftc "${flags[@]}" -language-mode 6 -package-name GiftUI
        -module-cache-path "${report_dir}/build/clang-cache"
        -module-name GiftUIFoundationLayoutProbe -emit-ir
        "${FOUNDATION_SOURCE}" "${FIXTURE_ROOT}/Instrumentation/LayoutProbe.swift"
        -o "${layout_ir}"
    )
    record_command "${layout_command[@]}"
    "${layout_command[@]}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-002-layout.rb" \
        "${layout_ir}" "${layout_report}"
    "${SCRIPT_DIR}/check-spec-002-layout.rb" \
        "${layout_ir}" "${layout_report}" >>"${log_path}" 2>&1

    local resource_dir="${report_dir}/build/resource-probe"
    local clang interposer operation_object undefined_symbols allocation_probe
    mkdir -p "${resource_dir}"
    clang="$(xcrun --find clang)"
    interposer="${resource_dir}/libGiftUIAllocationInterposer.dylib"
    operation_object="${resource_dir}/GiftUIFoundationOperationProbe.o"
    undefined_symbols="${report_dir}/semantics/operation-undefined-symbols.txt"
    allocation_probe="${resource_dir}/allocation-probe"
    local -a interposer_command=(
        "${clang}" -target arm64-apple-macosx26.0 -isysroot "${sdk_path}"
        -O2 -dynamiclib "${FIXTURE_ROOT}/Instrumentation/AllocationInterposer.c"
        -install_name @rpath/libGiftUIAllocationInterposer.dylib
        -o "${interposer}"
    )
    record_command "${interposer_command[@]}"
    "${interposer_command[@]}" >>"${log_path}" 2>&1
    local -a object_command=(
        swiftc "${flags[@]}" -language-mode 6 -package-name GiftUI
        -module-cache-path "${report_dir}/build/clang-cache"
        -module-name GiftUIFoundationOperationProbe -parse-as-library
        -I "${module_dir}" -emit-object
        "${FIXTURE_ROOT}/Instrumentation/OperationProbe.swift"
        -o "${operation_object}"
    )
    record_command "${object_command[@]}"
    "${object_command[@]}" >>"${log_path}" 2>&1
    record_command nm -u "${operation_object}"
    nm -u "${operation_object}" >"${undefined_symbols}"
    record_command "${SCRIPT_DIR}/check-spec-002-resource-boundary.rb" \
        "${undefined_symbols}"
    "${SCRIPT_DIR}/check-spec-002-resource-boundary.rb" \
        "${undefined_symbols}" >>"${log_path}" 2>&1
    local -a allocation_command=(
        swiftc "${flags[@]}" -language-mode 6 -package-name GiftUI
        -module-cache-path "${report_dir}/build/clang-cache"
        -module-name GiftUIFoundationAllocationProbe
        -L "${resource_dir}" -lGiftUIAllocationInterposer
        -Xlinker -rpath -Xlinker "${resource_dir}"
        "${FOUNDATION_SOURCE}"
        "${FIXTURE_ROOT}/Instrumentation/OperationProbe.swift"
        "${FIXTURE_ROOT}/Instrumentation/AllocationProbe/main.swift"
        -o "${allocation_probe}"
    )
    record_command "${allocation_command[@]}"
    "${allocation_command[@]}" >>"${log_path}" 2>&1
    record_command env "DYLD_LIBRARY_PATH=${resource_dir}" "${allocation_probe}"
    env "DYLD_LIBRARY_PATH=${resource_dir}" "${allocation_probe}" \
        >"${report_dir}/semantics/allocation-probe.txt" 2>>"${log_path}"
    grep -Fxq 'allocation_count=0' \
        "${report_dir}/semantics/allocation-probe.txt" ||
        fail 'Foundation construction/arithmetic allocation probe reported heap activity'
}

run_raspberry_pi() {
    # shellcheck source=../raspberry-pi/common.sh
    source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
    local compiler swiftc compiler_version sdk_identity sdk_root probe_module
    compiler="$(giftui_pi_host_swift)"
    swiftc="$(dirname "${compiler}")/swiftc"
    [[ -x "${compiler}" ]] || fail 'pinned Raspberry Pi Swift compiler is missing; run scripts/raspberry-pi/setup-toolchain.sh'
    giftui_pi_require_sdk
    record_command "${PROJECT_ROOT}/scripts/raspberry-pi/doctor.sh"
    "${PROJECT_ROOT}/scripts/raspberry-pi/doctor.sh" >>"${log_path}" 2>&1
    compiler_version="$("${compiler}" --version 2>&1)"
    require_exact_fragment "${compiler_version}" "Swift version ${GIFTUI_PI_SWIFT_VERSION}" 'Raspberry Pi compiler'
    grep -Fq "\"target\":\"${GIFTUI_PI_TARGET}\"" "${GIFTUI_PI_STATIC_DESTINATION}" ||
        fail 'Raspberry Pi destination target does not match its pin'
    sdk_identity="$(<"${GIFTUI_PI_SDK_DIR}/.giftui-install")"

    record_block compiler_version "${compiler_version}"
    record_block sdk_identity "${sdk_identity}"
    printf 'target=%s\n' "${GIFTUI_PI_TARGET}" >>"${metadata_path}"
    printf 'sdk_path=%s\n' "${GIFTUI_PI_SDK_DIR}" >>"${metadata_path}"
    printf 'destination=%s\n' "${GIFTUI_PI_STATIC_DESTINATION}" >>"${metadata_path}"
    printf 'optimization=-O -whole-module-optimization\n' >>"${metadata_path}"

    giftui_pi_prepare_build_environment
    local -a command=(
        "${compiler}" build --package-path "${PROJECT_ROOT}"
        --scratch-path "${report_dir}/build/swiftpm"
        --destination "${GIFTUI_PI_STATIC_DESTINATION}"
        --configuration release --product GiftUI --static-swift-stdlib
        -Xswiftc -whole-module-optimization
    )
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1

    sdk_root="${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}"
    probe_module="${report_dir}/build/GiftUIFoundationProfileCorpusProbe.swiftmodule"
    local -a probe_command=(
        "${swiftc}" -target "${GIFTUI_PI_TARGET}"
        -use-ld=lld -Xcc "--gcc-toolchain=${sdk_root}/usr"
        -resource-dir "${sdk_root}/usr/lib/swift_static"
        -sdk "${sdk_root}" -latomic
        -O -whole-module-optimization -language-mode 6 -package-name GiftUI
        -parse-as-library -emit-module
        -module-name GiftUIFoundationProfileCorpusProbe
        "${FOUNDATION_SOURCE}" "${PROFILE_PROBE_ROOT}/ProfileCorpusProbe.swift"
        -emit-module-path "${probe_module}"
    )
    record_command "${probe_command[@]}"
    "${probe_command[@]}" >>"${log_path}" 2>&1
    printf 'profile_corpus_checksum=28\nexecution=cross-build-only\n' \
        >"${report_dir}/semantics/profile-corpus.txt"

    local layout_ir="${report_dir}/build/foundation-layout.ll"
    local -a layout_command=(
        "${swiftc}" -target "${GIFTUI_PI_TARGET}"
        -use-ld=lld -Xcc "--gcc-toolchain=${sdk_root}/usr"
        -resource-dir "${sdk_root}/usr/lib/swift_static"
        -sdk "${sdk_root}" -latomic
        -O -whole-module-optimization -language-mode 6 -package-name GiftUI
        -module-name GiftUIFoundationLayoutProbe -emit-ir
        "${FOUNDATION_SOURCE}" "${FIXTURE_ROOT}/Instrumentation/LayoutProbe.swift"
        -o "${layout_ir}"
    )
    record_command "${layout_command[@]}"
    "${layout_command[@]}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-002-layout.rb" \
        "${layout_ir}" "${report_dir}/semantics/layout.tsv"
    "${SCRIPT_DIR}/check-spec-002-layout.rb" \
        "${layout_ir}" "${report_dir}/semantics/layout.tsv" >>"${log_path}" 2>&1

    local operation_ir="${report_dir}/build/foundation-operation.ll"
    local -a object_command=(
        "${swiftc}" -target "${GIFTUI_PI_TARGET}"
        -use-ld=lld -Xcc "--gcc-toolchain=${sdk_root}/usr"
        -resource-dir "${sdk_root}/usr/lib/swift_static"
        -sdk "${sdk_root}" -latomic
        -O -whole-module-optimization -language-mode 6 -package-name GiftUI
        -module-name GiftUIFoundationOperationProbe -emit-ir
        "${FOUNDATION_SOURCE}" "${FIXTURE_ROOT}/Instrumentation/OperationProbe.swift"
        -o "${operation_ir}"
    )
    record_command "${object_command[@]}"
    "${object_command[@]}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-002-resource-boundary.rb" \
        --ir "${operation_ir}"
    "${SCRIPT_DIR}/check-spec-002-resource-boundary.rb" \
        --ir "${operation_ir}" >>"${log_path}" 2>&1
}

run_nrf52840() {
    # shellcheck source=../nrf52840/common.sh
    source "${PROJECT_ROOT}/scripts/nrf52840/common.sh"
    giftui_nrf_require_environment
    record_command "${PROJECT_ROOT}/scripts/nrf52840/doctor.sh"
    "${PROJECT_ROOT}/scripts/nrf52840/doctor.sh" >>"${log_path}" 2>&1
    local compiler_version module_dir
    compiler_version="$("${GIFTUI_NRF_SWIFTC}" --version 2>&1)"
    require_exact_fragment "${compiler_version}" "Swift version ${GIFTUI_NRF_SWIFT_VERSION}" 'nRF compiler'
    [[ "$(giftui_nrf_git_revision "${GIFTUI_NRF_ZEPHYR_BASE}")" == "${GIFTUI_NRF_ZEPHYR_REVISION}" ]] ||
        fail 'Zephyr revision does not match its pin'

    record_block compiler_version "${compiler_version}"
    printf 'target=%s\n' "${GIFTUI_NRF_SWIFT_TARGET}" >>"${metadata_path}"
    printf 'board=%s\n' "${GIFTUI_NRF_BOARD}" >>"${metadata_path}"
    printf 'zephyr_version=%s\n' "${GIFTUI_NRF_ZEPHYR_VERSION}" >>"${metadata_path}"
    printf 'zephyr_revision=%s\n' "${GIFTUI_NRF_ZEPHYR_REVISION}" >>"${metadata_path}"
    printf 'zephyr_sdk_version=%s\n' "${GIFTUI_NRF_ZEPHYR_SDK_VERSION}" >>"${metadata_path}"
    printf 'sdk_path=%s\n' "${GIFTUI_NRF_SDK_DIR}" >>"${metadata_path}"
    printf 'optimization=-Osize -whole-module-optimization\n' >>"${metadata_path}"
    printf 'embedded_swift=-enable-experimental-feature Embedded\n' >>"${metadata_path}"
    printf 'float_abi=hard\n' >>"${metadata_path}"

    module_dir="${report_dir}/build/modules"
    mkdir -p "${module_dir}" "${report_dir}/build/clang-cache"
    export CLANG_MODULE_CACHE_PATH="${report_dir}/build/clang-cache"
    local -a flags=(
        -target "${GIFTUI_NRF_SWIFT_TARGET}"
        -enable-experimental-feature Embedded
        -Osize -whole-module-optimization
        -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
    )
    local -a command=(
        "${GIFTUI_NRF_SWIFTC}" "${flags[@]}" -package-name GiftUI
        -parse-as-library -emit-module
        -module-name GiftUI "${PROJECT_ROOT}/Sources/GiftUI/GiftUI.swift"
        -emit-module-path "${module_dir}/GiftUI.swiftmodule"
    )
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    local probe_module="${module_dir}/GiftUIFoundationProfileCorpusProbe.swiftmodule"
    local -a probe_command=(
        "${GIFTUI_NRF_SWIFTC}" "${flags[@]}" -package-name GiftUI
        -parse-as-library -emit-module
        -module-name GiftUIFoundationProfileCorpusProbe
        "${FOUNDATION_SOURCE}" "${PROFILE_PROBE_ROOT}/ProfileCorpusProbe.swift"
        -emit-module-path "${probe_module}"
    )
    record_command "${probe_command[@]}"
    "${probe_command[@]}" >>"${log_path}" 2>&1
    printf 'profile_corpus_checksum=28\nexecution=cross-build-only\n' \
        >"${report_dir}/semantics/profile-corpus.txt"

    local layout_ir="${report_dir}/build/foundation-layout.ll"
    local -a layout_command=(
        "${GIFTUI_NRF_SWIFTC}" "${flags[@]}" -package-name GiftUI
        -module-name GiftUIFoundationLayoutProbe -emit-ir
        "${FOUNDATION_SOURCE}" "${FIXTURE_ROOT}/Instrumentation/LayoutProbe.swift"
        -o "${layout_ir}"
    )
    record_command "${layout_command[@]}"
    "${layout_command[@]}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-002-layout.rb" \
        "${layout_ir}" "${report_dir}/semantics/layout.tsv"
    "${SCRIPT_DIR}/check-spec-002-layout.rb" \
        "${layout_ir}" "${report_dir}/semantics/layout.tsv" >>"${log_path}" 2>&1

    local operation_ir="${report_dir}/build/foundation-operation.ll"
    local -a object_command=(
        "${GIFTUI_NRF_SWIFTC}" "${flags[@]}" -package-name GiftUI
        -module-name GiftUIFoundationOperationProbe -emit-ir
        "${FOUNDATION_SOURCE}" "${FIXTURE_ROOT}/Instrumentation/OperationProbe.swift"
        -o "${operation_ir}"
    )
    record_command "${object_command[@]}"
    "${object_command[@]}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-002-resource-boundary.rb" \
        --ir "${operation_ir}"
    "${SCRIPT_DIR}/check-spec-002-resource-boundary.rb" \
        --ir "${operation_ir}" >>"${log_path}" 2>&1
    run_fixture_set "${GIFTUI_NRF_SWIFTC}" "${module_dir}" "${flags[@]}"
}

record_command "${SCRIPT_DIR}/check-fixture-manifest.rb"
"${SCRIPT_DIR}/check-fixture-manifest.rb" >>"${log_path}" 2>&1
record_command "${SCRIPT_DIR}/check-spec-002-profile-corpus.rb"
"${SCRIPT_DIR}/check-spec-002-profile-corpus.rb" >>"${log_path}" 2>&1
record_semantic_contract

case "${profile}" in
    macos-dynamic | macos-static) run_macos ;;
    raspberry-pi-armv6) run_raspberry_pi ;;
    nrf52840-embedded) run_nrf52840 ;;
esac
