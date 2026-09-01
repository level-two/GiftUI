#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC005"
SOURCE_ROOT="${PROJECT_ROOT}/Sources/GiftUITextResources"
UNIT_TEST_ROOT="${PROJECT_ROOT}/Tests/GiftUITextResourcesTests"
FOUNDATION_SOURCE="${PROJECT_ROOT}/Sources/GiftUI/GiftUI.swift"
TEXT_RESOURCE_SOURCE="${SOURCE_ROOT}/GiftUITextResources.swift"
GENERATED_ROOT="${PROJECT_ROOT}/.build/contract-generated/spec-005"
REPORT_ROOT="${PROJECT_ROOT}/.build/contract-reports/spec-005"

usage() {
    printf '%s\n' \
        'Usage: scripts/contracts/run-spec-005.sh --profile <profile>' \
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
        *) fail "unknown option: $1" ;;
    esac
done

case "${profile}" in
    macos-dynamic | macos-static | raspberry-pi-armv6 | nrf52840-embedded) ;;
    "") fail '--profile is required' ;;
    *) fail "unknown profile: ${profile}" ;;
esac

generated_dir="${GENERATED_ROOT}/${profile}"
report_dir="${REPORT_ROOT}/${profile}"
rm -rf "${generated_dir}" "${report_dir}"
mkdir -p \
    "${generated_dir}" \
    "${report_dir}/build/clang-cache" \
    "${report_dir}/build/swiftpm-cache" \
    "${report_dir}/fixtures" \
    "${report_dir}/semantics" \
    "${report_dir}/resources/baseline" \
    "${report_dir}/resources/candidate"

export CLANG_MODULE_CACHE_PATH="${report_dir}/build/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${report_dir}/build/swiftpm-cache"
metadata_path="${report_dir}/metadata.txt"
commands_path="${report_dir}/commands.txt"
inputs_path="${report_dir}/input-hashes.tsv"
images_path="${report_dir}/image-hashes.tsv"
log_path="${report_dir}/run.log"
: >"${commands_path}"
: >"${inputs_path}"
: >"${images_path}"
: >"${log_path}"

revision="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
if [[ -n "$(git -C "${PROJECT_ROOT}" status --porcelain --untracked-files=normal)" ]]; then
    dirty=true
else
    dirty=false
fi
{
    printf 'schema_version=1\n'
    printf 'spec=SPEC-005\n'
    printf 'profile=%s\n' "${profile}"
    printf 'repository_revision=%s\n' "${revision}"
    printf 'repository_dirty=%s\n' "${dirty}"
    printf 'generated_directory=.build/contract-generated/spec-005/%s\n' "${profile}"
    printf 'report_directory=.build/contract-reports/spec-005/%s\n' "${profile}"
    printf 'invocation=scripts/contracts/run-spec-005.sh --profile %s\n' "${profile}"
    printf 'evidence=hardware-free\n'
    printf 'remote_access=false\n'
    printf 'deployment=false\n'
    printf 'service_restart=false\n'
    printf 'simulator_execution=false\n'
    printf 'connected_target_execution=false\n'
    printf 'flashing=false\n'
} >"${metadata_path}"

finish() {
    local result=$?
    printf 'exit_code=%s\n' "${result}" >>"${metadata_path}"
    if [[ "${result}" -eq 0 ]]; then
        printf 'SPEC-005 %s contract harness passed\n' "${profile}"
    else
        printf 'SPEC-005 %s contract harness failed; see %s\n' \
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

hash_file() {
    shasum -a 256 "$1" | awk '{print $1}'
}

record_compiler() {
    local compiler="$1"
    local version
    [[ -x "${compiler}" ]] || fail "compiler is not executable: ${compiler}"
    version="$("${compiler}" --version 2>&1)"
    printf 'compiler_path=%s\n' "${compiler}" >>"${metadata_path}"
    printf 'compiler_sha256=%s\n' "$(hash_file "${compiler}")" >>"${metadata_path}"
    record_block compiler_version "${version}"
}

record_image() {
    local label="$1"
    local path="$2"
    [[ -f "${path}" ]] || fail "expected image is missing: ${path}"
    printf '%s\t%s\t%s\n' \
        "${label}" "${path#"${PROJECT_ROOT}/"}" "$(hash_file "${path}")" \
        >>"${images_path}"
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
        local -a command=("${compiler}" "${common_flags[@]}" -I "${module_dir}")
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

verify_source_list() {
    local -a sources=()
    local source
    while IFS= read -r source; do
        sources+=("${source}")
    done < <(find "${SOURCE_ROOT}" -type f -name '*.swift' -print | LC_ALL=C sort)
    [[ "${#sources[@]}" -eq 1 ]] ||
        fail "expected one text-resource source, found ${#sources[@]}"
    [[ "${sources[0]}" == "${TEXT_RESOURCE_SOURCE}" ]] ||
        fail "text-resource source list differs: ${sources[*]}"
    printf 'source_list=Sources/GiftUITextResources/GiftUITextResources.swift\n' \
        >>"${metadata_path}"
}

record_input_hashes() {
    local path relative
    while IFS= read -r path; do
        relative="${path#"${PROJECT_ROOT}/"}"
        printf '%s\t%s\n' "${relative}" "$(hash_file "${path}")" >>"${inputs_path}"
    done < <(
        {
            find "${SOURCE_ROOT}" "${UNIT_TEST_ROOT}" "${FIXTURE_ROOT}" \
                -type f -print
            printf '%s\n' \
                "${FOUNDATION_SOURCE}" \
                "${PROJECT_ROOT}/Package.swift" \
                "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/Instrumentation/AllocationInterposer.c" \
                "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/target-dependencies.yaml" \
                "${PROJECT_ROOT}/scripts/contracts/driver-registry.tsv" \
                "${SCRIPT_DIR}/check-spec-005-fixture-manifest.rb" \
                "${SCRIPT_DIR}/check-spec-005-corpus.rb" \
                "${SCRIPT_DIR}/check-spec-005-generated-assets.rb" \
                "${SCRIPT_DIR}/check-spec-005-adopted-inputs.rb" \
                "${SCRIPT_DIR}/check-spec-005-dependencies.rb" \
                "${SCRIPT_DIR}/check-spec-005-boundaries.rb" \
                "${SCRIPT_DIR}/check-spec-005-surface.rb" \
                "${SCRIPT_DIR}/check-spec-005-canonical.rb" \
                "${SCRIPT_DIR}/check-spec-005-accessors.rb" \
                "${SCRIPT_DIR}/check-spec-005-payload-borrow.rb" \
                "${SCRIPT_DIR}/check-spec-005-target-layout.rb" \
                "${SCRIPT_DIR}/check-spec-005-bounds.rb" \
                "${SCRIPT_DIR}/check-spec-005-portable-source.rb" \
                "${SCRIPT_DIR}/run-spec-005.sh"
        } | LC_ALL=C sort -u
    )
}

run_preflight() {
    local package_json="${report_dir}/package.json"
    verify_source_list
    record_input_hashes
    record_command "${SCRIPT_DIR}/check-spec-005-fixture-manifest.rb"
    "${SCRIPT_DIR}/check-spec-005-fixture-manifest.rb" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-corpus.rb"
    "${SCRIPT_DIR}/check-spec-005-corpus.rb" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-generated-assets.rb"
    "${SCRIPT_DIR}/check-spec-005-generated-assets.rb" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-adopted-inputs.rb"
    "${SCRIPT_DIR}/check-spec-005-adopted-inputs.rb" >>"${log_path}" 2>&1
    command -v swift >/dev/null || fail 'swift is missing'
    record_command swift package dump-package
    swift package dump-package >"${package_json}" 2>>"${log_path}"
    record_command "${SCRIPT_DIR}/check-target-dependencies.rb"
    "${SCRIPT_DIR}/check-target-dependencies.rb" \
        <"${package_json}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-dependencies.rb"
    "${SCRIPT_DIR}/check-spec-005-dependencies.rb" \
        <"${package_json}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-portable-source.rb"
    "${SCRIPT_DIR}/check-spec-005-portable-source.rb" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-canonical.rb" "${TEXT_RESOURCE_SOURCE}"
    "${SCRIPT_DIR}/check-spec-005-canonical.rb" \
        "${TEXT_RESOURCE_SOURCE}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-accessors.rb" "${TEXT_RESOURCE_SOURCE}"
    "${SCRIPT_DIR}/check-spec-005-accessors.rb" \
        "${TEXT_RESOURCE_SOURCE}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-payload-borrow.rb" "${TEXT_RESOURCE_SOURCE}"
    "${SCRIPT_DIR}/check-spec-005-payload-borrow.rb" \
        "${TEXT_RESOURCE_SOURCE}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-bounds.rb" \
        "${TEXT_RESOURCE_SOURCE}" \
        "${UNIT_TEST_ROOT}/BoundaryAndLayoutTests.swift"
    "${SCRIPT_DIR}/check-spec-005-bounds.rb" \
        "${TEXT_RESOURCE_SOURCE}" \
        "${UNIT_TEST_ROOT}/BoundaryAndLayoutTests.swift" \
        >>"${log_path}" 2>&1
}

run_target_layout_probe() {
    local compiler="$1"
    shift
    local probe_dir="${report_dir}/build/layout-probe"
    local module_dir="${probe_dir}/modules"
    local layout_ir="${report_dir}/semantics/type-layout.ll"
    local layout_report="${report_dir}/semantics/type-layout.tsv"
    mkdir -p "${module_dir}"
    local -a foundation_command=(
        "${compiler}" "$@" -parse-as-library -package-name GiftUI
        -emit-module -module-name GiftUI "${FOUNDATION_SOURCE}"
        -emit-module-path "${module_dir}/GiftUI.swiftmodule"
    )
    record_command "${foundation_command[@]}"
    "${foundation_command[@]}" >>"${log_path}" 2>&1
    local -a layout_command=(
        "${compiler}" "$@" -parse-as-library -package-name GiftUI
        -DGIFTUI_LAYOUT_PROBE_LOCAL -I "${module_dir}" -emit-ir
        -module-name GiftUITextResources
        "${TEXT_RESOURCE_SOURCE}"
        "${FIXTURE_ROOT}/Instrumentation/LayoutProbe.swift"
        -o "${layout_ir}"
    )
    record_command "${layout_command[@]}"
    "${layout_command[@]}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-target-layout.rb" \
        "${layout_ir}" "${layout_report}"
    "${SCRIPT_DIR}/check-spec-005-target-layout.rb" \
        "${layout_ir}" "${layout_report}" >>"${log_path}" 2>&1
    record_image layout-ir "${layout_ir}"
}

run_allocation_probe() {
    local compiler="$1"
    local sdk_path="$2"
    local profile_flag="$3"
    local probe_dir="${report_dir}/build/allocation-probe"
    local module_dir="${probe_dir}/modules"
    local clang interposer foundation_library text_library probe output
    mkdir -p "${module_dir}"
    clang="$(xcrun --find clang)"
    [[ -x "${clang}" ]] || fail 'clang is missing for allocation instrumentation'
    interposer="${probe_dir}/libGiftUIAllocationInterposer.dylib"
    foundation_library="${probe_dir}/libGiftUI.dylib"
    text_library="${probe_dir}/libGiftUITextResources.dylib"
    probe="${probe_dir}/allocation-probe"
    output="${report_dir}/semantics/allocation-probe.txt"

    local -a foundation_command=(
        "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -module-cache-path "${report_dir}/build/clang-cache"
        -O -whole-module-optimization "${profile_flag}" -language-mode 6
        -package-name GiftUI -emit-library -emit-module -module-name GiftUI
        "${FOUNDATION_SOURCE}"
        -emit-module-path "${module_dir}/GiftUI.swiftmodule"
        -o "${foundation_library}"
    )
    record_command "${foundation_command[@]}"
    "${foundation_command[@]}" >>"${log_path}" 2>&1
    local -a text_command=(
        "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -module-cache-path "${report_dir}/build/clang-cache"
        -O -whole-module-optimization "${profile_flag}" -language-mode 6
        -package-name GiftUI -I "${module_dir}" -L "${probe_dir}" -lGiftUI
        -emit-library -emit-module -module-name GiftUITextResources
        "${TEXT_RESOURCE_SOURCE}"
        -emit-module-path "${module_dir}/GiftUITextResources.swiftmodule"
        -o "${text_library}"
    )
    record_command "${text_command[@]}"
    "${text_command[@]}" >>"${log_path}" 2>&1
    local -a interposer_command=(
        "${clang}" -target arm64-apple-macosx26.0 -isysroot "${sdk_path}"
        -O2 -dynamiclib
        "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/Instrumentation/AllocationInterposer.c"
        -install_name @rpath/libGiftUIAllocationInterposer.dylib
        -o "${interposer}"
    )
    record_command "${interposer_command[@]}"
    "${interposer_command[@]}" >>"${log_path}" 2>&1
    local -a probe_command=(
        "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -module-cache-path "${report_dir}/build/clang-cache"
        -O -whole-module-optimization "${profile_flag}" -language-mode 6
        -package-name GiftUI -I "${module_dir}" -L "${probe_dir}"
        -lGiftUI -lGiftUITextResources -lGiftUIAllocationInterposer
        -Xlinker -rpath -Xlinker "${probe_dir}"
        "${FIXTURE_ROOT}/Instrumentation/AllocationProbe/main.swift"
        -o "${probe}"
    )
    record_command "${probe_command[@]}"
    "${probe_command[@]}" >>"${log_path}" 2>&1
    record_command env "DYLD_LIBRARY_PATH=${probe_dir}" "${probe}"
    env "DYLD_LIBRARY_PATH=${probe_dir}" "${probe}" \
        >"${output}" 2>>"${log_path}"
    grep -Fxq 'allocation_count=0' "${output}" ||
        fail 'text-resource hot-path allocation probe reported heap activity'
    record_image allocation-probe "${probe}"
    record_image allocation-interposer "${interposer}"
    record_image allocation-text-library "${text_library}"
}

run_macos() {
    [[ "$(uname -s)" == "Darwin" ]] || fail 'macOS profile requires macOS'
    [[ "$(uname -m)" == "arm64" ]] || fail 'macOS evidence requires an arm64 host'
    command -v xcrun >/dev/null || fail 'xcrun is missing'

    local compiler compiler_version sdk_path sdk_version profile_flag module_dir
    local text_scan giftui_scan
    compiler="$(xcrun --find swiftc)"
    compiler_version="$("${compiler}" --version 2>&1)"
    require_exact_fragment "${compiler_version}" 'Apple Swift version 6.3.3' 'macOS compiler'
    require_exact_fragment "${compiler_version}" 'swiftlang-6.3.3.1.3' 'macOS compiler build'
    sdk_path="$(xcrun --sdk macosx --show-sdk-path)"
    sdk_version="$(xcrun --sdk macosx --show-sdk-version)"
    [[ -d "${sdk_path}" ]] || fail "macOS SDK is missing: ${sdk_path}"
    if [[ "${profile}" == "macos-dynamic" ]]; then
        profile_flag='-DGIFTUI_DYNAMIC_PROFILE'
    else
        profile_flag='-DGIFTUI_STATIC_PROFILE'
    fi

    record_compiler "${compiler}"
    printf 'target=arm64-apple-macosx26.0\n' >>"${metadata_path}"
    printf 'sdk_path=%s\n' "${sdk_path}" >>"${metadata_path}"
    printf 'sdk_version=%s\n' "${sdk_version}" >>"${metadata_path}"
    printf 'optimization=-O -whole-module-optimization\n' >>"${metadata_path}"
    printf 'profile_flag=%s\n' "${profile_flag}" >>"${metadata_path}"

    module_dir="${report_dir}/build/modules"
    mkdir -p "${module_dir}"
    local -a compile_flags=(
        -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -O -whole-module-optimization "${profile_flag}"
        -language-mode 6 -package-name GiftUI -parse-as-library
    )
    local -a foundation_command=(
        "${compiler}" "${compile_flags[@]}" -enable-library-evolution
        -emit-module -module-name GiftUI "${FOUNDATION_SOURCE}"
        -emit-module-path "${module_dir}/GiftUI.swiftmodule"
        -emit-module-interface-path "${module_dir}/GiftUI.swiftinterface"
        -emit-package-module-interface-path "${module_dir}/GiftUI.package.swiftinterface"
    )
    record_command "${foundation_command[@]}"
    "${foundation_command[@]}" >>"${log_path}" 2>&1
    local -a text_command=(
        "${compiler}" "${compile_flags[@]}" -enable-library-evolution
        -emit-module -I "${module_dir}"
        -module-name GiftUITextResources "${TEXT_RESOURCE_SOURCE}"
        -emit-module-path "${module_dir}/GiftUITextResources.swiftmodule"
        -emit-module-interface-path "${module_dir}/GiftUITextResources.swiftinterface"
        -emit-package-module-interface-path "${module_dir}/GiftUITextResources.package.swiftinterface"
    )
    record_command "${text_command[@]}"
    "${text_command[@]}" >>"${log_path}" 2>&1
    record_image giftui-module "${module_dir}/GiftUI.swiftmodule"
    record_image text-resource-module "${module_dir}/GiftUITextResources.swiftmodule"

    giftui_scan="${report_dir}/build/GiftUI.dependencies.json"
    local -a giftui_scan_command=(
        "${compiler}" "${compile_flags[@]}" -module-name GiftUI
        -module-cache-path "${report_dir}/build/clang-cache"
        -scan-dependencies "${FOUNDATION_SOURCE}"
    )
    record_command "${giftui_scan_command[@]}"
    "${giftui_scan_command[@]}" >"${giftui_scan}" 2>>"${log_path}"
    text_scan="${report_dir}/build/GiftUITextResources.dependencies.json"
    local -a text_scan_command=(
        "${compiler}" "${compile_flags[@]}" -I "${module_dir}"
        -module-name GiftUITextResources
        -module-cache-path "${report_dir}/build/clang-cache"
        -scan-dependencies "${TEXT_RESOURCE_SOURCE}"
    )
    record_command "${text_scan_command[@]}"
    "${text_scan_command[@]}" >"${text_scan}" 2>>"${log_path}"
    record_command "${SCRIPT_DIR}/check-spec-005-boundaries.rb" \
        "${module_dir}/GiftUITextResources.swiftinterface" \
        "${module_dir}/GiftUITextResources.package.swiftinterface" \
        "${module_dir}/GiftUI.swiftinterface" \
        "${module_dir}/GiftUI.package.swiftinterface" \
        "${text_scan}" "${giftui_scan}"
    "${SCRIPT_DIR}/check-spec-005-boundaries.rb" \
        "${module_dir}/GiftUITextResources.swiftinterface" \
        "${module_dir}/GiftUITextResources.package.swiftinterface" \
        "${module_dir}/GiftUI.swiftinterface" \
        "${module_dir}/GiftUI.package.swiftinterface" \
        "${text_scan}" "${giftui_scan}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-surface.rb" \
        "${module_dir}/GiftUITextResources.swiftinterface" \
        "${module_dir}/GiftUITextResources.package.swiftinterface"
    "${SCRIPT_DIR}/check-spec-005-surface.rb" \
        "${module_dir}/GiftUITextResources.swiftinterface" \
        "${module_dir}/GiftUITextResources.package.swiftinterface" \
        >>"${log_path}" 2>&1
    run_fixture_set "${compiler}" "${module_dir}" \
        -target arm64-apple-macosx26.0 -sdk "${sdk_path}" \
        -O -whole-module-optimization "${profile_flag}" -language-mode 6
    run_target_layout_probe "${compiler}" \
        -target arm64-apple-macosx26.0 -sdk "${sdk_path}" \
        -O -whole-module-optimization "${profile_flag}" -language-mode 6 \
        -module-cache-path "${report_dir}/build/clang-cache"
    run_allocation_probe "${compiler}" "${sdk_path}" "${profile_flag}"
}

run_raspberry_pi() {
    # shellcheck source=../raspberry-pi/common.sh
    source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
    local swift_driver compiler compiler_version sdk_identity module sdk_root module_dir
    swift_driver="$(giftui_pi_host_swift)"
    compiler="$(dirname "${swift_driver}")/swiftc"
    [[ -x "${swift_driver}" && -x "${compiler}" ]] ||
        fail 'pinned Raspberry Pi Swift compiler is missing; run scripts/raspberry-pi/setup-toolchain.sh'
    giftui_pi_require_sdk
    record_command "${PROJECT_ROOT}/scripts/raspberry-pi/doctor.sh"
    "${PROJECT_ROOT}/scripts/raspberry-pi/doctor.sh" >>"${log_path}" 2>&1
    compiler_version="$("${compiler}" --version 2>&1)"
    require_exact_fragment "${compiler_version}" "Swift version ${GIFTUI_PI_SWIFT_VERSION}" 'Raspberry Pi compiler'
    grep -Fq "\"target\":\"${GIFTUI_PI_TARGET}\"" "${GIFTUI_PI_STATIC_DESTINATION}" ||
        fail 'Raspberry Pi destination target does not match its pin'
    sdk_identity="$(<"${GIFTUI_PI_SDK_DIR}/.giftui-install")"

    record_compiler "${compiler}"
    record_block sdk_identity "${sdk_identity}"
    printf 'target=%s\n' "${GIFTUI_PI_TARGET}" >>"${metadata_path}"
    printf 'sdk_path=%s\n' "${GIFTUI_PI_SDK_DIR}" >>"${metadata_path}"
    printf 'destination=%s\n' "${GIFTUI_PI_STATIC_DESTINATION}" >>"${metadata_path}"
    printf 'optimization=release -O -whole-module-optimization\n' >>"${metadata_path}"

    giftui_pi_prepare_build_environment
    local -a command=(
        "${swift_driver}" build --package-path "${PROJECT_ROOT}"
        --scratch-path "${report_dir}/build/swiftpm"
        --destination "${GIFTUI_PI_STATIC_DESTINATION}"
        --configuration release --target GiftUITextResources --static-swift-stdlib
        -Xswiftc -whole-module-optimization
    )
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    local -a modules=()
    while IFS= read -r module; do
        modules+=("${module}")
    done < <(find "${report_dir}/build/swiftpm" -type f -name 'GiftUITextResources.swiftmodule' -print)
    [[ "${#modules[@]}" -eq 1 ]] ||
        fail "expected one ARMv6 text-resource module, found ${#modules[@]}"
    record_image text-resource-module "${modules[0]}"
    sdk_root="${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}"
    module_dir="$(dirname "${modules[0]}")"
    run_fixture_set "${compiler}" "${module_dir}" \
        -target "${GIFTUI_PI_TARGET}" -use-ld=lld \
        -Xcc "--gcc-toolchain=${sdk_root}/usr" \
        -resource-dir "${sdk_root}/usr/lib/swift_static" \
        -sdk "${sdk_root}" -latomic \
        -O -whole-module-optimization -language-mode 6
    run_target_layout_probe "${compiler}" \
        -target "${GIFTUI_PI_TARGET}" -use-ld=lld \
        -Xcc "--gcc-toolchain=${sdk_root}/usr" \
        -resource-dir "${sdk_root}/usr/lib/swift_static" \
        -sdk "${sdk_root}" -latomic \
        -O -whole-module-optimization -language-mode 6 \
        -module-cache-path "${report_dir}/build/clang-cache"
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

    record_compiler "${GIFTUI_NRF_SWIFTC}"
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
    mkdir -p "${module_dir}"
    local -a compile_flags=(
        -target "${GIFTUI_NRF_SWIFT_TARGET}"
        -enable-experimental-feature Embedded
        -Osize -whole-module-optimization
        -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
        -package-name GiftUI -parse-as-library
    )
    local -a foundation_command=(
        "${GIFTUI_NRF_SWIFTC}" "${compile_flags[@]}" -emit-module
        -module-name GiftUI "${FOUNDATION_SOURCE}"
        -emit-module-path "${module_dir}/GiftUI.swiftmodule"
    )
    record_command "${foundation_command[@]}"
    "${foundation_command[@]}" >>"${log_path}" 2>&1
    local -a text_command=(
        "${GIFTUI_NRF_SWIFTC}" "${compile_flags[@]}" -emit-module -I "${module_dir}"
        -module-name GiftUITextResources "${TEXT_RESOURCE_SOURCE}"
        -emit-module-path "${module_dir}/GiftUITextResources.swiftmodule"
    )
    record_command "${text_command[@]}"
    "${text_command[@]}" >>"${log_path}" 2>&1
    record_image giftui-module "${module_dir}/GiftUI.swiftmodule"
    record_image text-resource-module "${module_dir}/GiftUITextResources.swiftmodule"
    run_fixture_set "${GIFTUI_NRF_SWIFTC}" "${module_dir}" \
        -target "${GIFTUI_NRF_SWIFT_TARGET}" \
        -enable-experimental-feature Embedded -Osize -whole-module-optimization \
        -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
    run_target_layout_probe "${GIFTUI_NRF_SWIFTC}" \
        -target "${GIFTUI_NRF_SWIFT_TARGET}" \
        -enable-experimental-feature Embedded -Osize -whole-module-optimization \
        -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16 \
        -module-cache-path "${report_dir}/build/clang-cache"
}

verify_report() {
    local required key
    for required in "${metadata_path}" "${commands_path}" "${inputs_path}" \
        "${images_path}" "${log_path}" "${report_dir}/package.json"; do
        [[ -f "${required}" ]] || fail "incomplete report: missing ${required}"
    done
    [[ -s "${commands_path}" ]] || fail 'incomplete report: commands are empty'
    [[ -s "${inputs_path}" ]] || fail 'incomplete report: input hashes are empty'
    [[ -s "${images_path}" ]] || fail 'incomplete report: image hashes are empty'
    for key in schema_version spec profile repository_revision repository_dirty \
        generated_directory report_directory invocation evidence remote_access \
        deployment service_restart simulator_execution connected_target_execution \
        flashing source_list compiler_path compiler_sha256 target optimization; do
        grep -q "^${key}=" "${metadata_path}" ||
            fail "incomplete report: metadata lacks ${key}"
    done
}

run_preflight
case "${profile}" in
    macos-dynamic | macos-static) run_macos ;;
    raspberry-pi-armv6) run_raspberry_pi ;;
    nrf52840-embedded) run_nrf52840 ;;
esac
verify_report
