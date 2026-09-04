#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC005"
SOURCE_ROOT="${PROJECT_ROOT}/Sources/GiftUITextResources"
REFERENCE_SOURCE_ROOT="${PROJECT_ROOT}/Sources/GiftUIReferenceTextResources"
UNIT_TEST_ROOT="${PROJECT_ROOT}/Tests/GiftUITextResourcesTests"
FOUNDATION_SOURCE="${PROJECT_ROOT}/Sources/GiftUI/GiftUI.swift"
TEXT_RESOURCE_SOURCE="${SOURCE_ROOT}/GiftUITextResources.swift"
GENERATED_ROOT="${PROJECT_ROOT}/.build/contract-generated/spec-005"
REPORT_ROOT="${PROJECT_ROOT}/.build/contract-reports/spec-005"
# shellcheck source=../lib/swiftpm.sh
source "${PROJECT_ROOT}/scripts/lib/swiftpm.sh"

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

declared_inputs() {
    {
        find "${SOURCE_ROOT}" "${REFERENCE_SOURCE_ROOT}" \
            "${UNIT_TEST_ROOT}" "${FIXTURE_ROOT}" -type f -print
        find "${PROJECT_ROOT}/ThirdParty/Inter-4.1" \
            "${PROJECT_ROOT}/scripts/text-resources" -type f -print
        find "${PROJECT_ROOT}/firmware/nrf52840/applications/spec005-resource-probe" \
            -type f -print
        printf '%s\n' \
            "${FOUNDATION_SOURCE}" \
            "${PROJECT_ROOT}/Package.swift" \
            "${PROJECT_ROOT}/docs/engineering/GOVERNANCE_TOOLING_IMPROVEMENTS.md" \
            "${PROJECT_ROOT}/docs/specs/spec-005-text-resources.md" \
            "${PROJECT_ROOT}/docs/implementation-plans/spec-005-implementation-plan.md" \
            "${PROJECT_ROOT}/scripts/governance/task-evidence-schema.yaml" \
            "${PROJECT_ROOT}/scripts/governance/check-task-evidence.rb" \
            "${PROJECT_ROOT}/scripts/lib/swiftpm.sh" \
            "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/Instrumentation/AllocationInterposer.c" \
            "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC002/target-dependencies.yaml" \
            "${PROJECT_ROOT}/scripts/contracts/driver-registry.tsv" \
            "${SCRIPT_DIR}/check-spec-005-fixture-manifest.rb" \
            "${SCRIPT_DIR}/check-spec-005-corpus.rb" \
            "${SCRIPT_DIR}/check-spec-005-generated-assets.rb" \
            "${SCRIPT_DIR}/check-spec-005-adopted-inputs.rb" \
            "${SCRIPT_DIR}/check-spec-005-reference-generation.rb" \
            "${SCRIPT_DIR}/check-spec-005-reference-compositions.sh" \
            "${SCRIPT_DIR}/check-spec-005-owner-adapters.rb" \
            "${SCRIPT_DIR}/check-spec-005-synchronous-offer.rb" \
            "${SCRIPT_DIR}/check-spec-005-assembly-lifecycle.rb" \
            "${SCRIPT_DIR}/generate-spec-005-profile-semantics.rb" \
            "${SCRIPT_DIR}/compare-spec-005-profile-semantics.rb" \
            "${SCRIPT_DIR}/check-spec-005-dependencies.rb" \
            "${SCRIPT_DIR}/check-spec-005-boundaries.rb" \
            "${SCRIPT_DIR}/check-spec-005-surface.rb" \
            "${SCRIPT_DIR}/check-spec-005-canonical.rb" \
            "${SCRIPT_DIR}/check-spec-005-accessors.rb" \
            "${SCRIPT_DIR}/check-spec-005-payload-borrow.rb" \
            "${SCRIPT_DIR}/check-spec-005-target-layout.rb" \
            "${SCRIPT_DIR}/check-spec-005-bounds.rb" \
            "${SCRIPT_DIR}/check-spec-005-validator.rb" \
            "${SCRIPT_DIR}/check-spec-005-validation-corpus.rb" \
            "${SCRIPT_DIR}/check-spec-005-common-catalogue.rb" \
            "${SCRIPT_DIR}/check-spec-005-validated-behavior.rb" \
            "${SCRIPT_DIR}/check-spec-005-validator-instrumentation.rb" \
            "${SCRIPT_DIR}/check-spec-005-static-path.rb" \
            "${SCRIPT_DIR}/check-spec-005-timing.rb" \
            "${SCRIPT_DIR}/check-spec-005-nrf-resources.rb" \
            "${SCRIPT_DIR}/check-spec-005-armv6-resources.rb" \
            "${SCRIPT_DIR}/check-spec-005-pristine-rebuilds.sh" \
            "${SCRIPT_DIR}/compare-spec-005-pristine-rebuilds.rb" \
            "${SCRIPT_DIR}/check-spec-005-portable-source.rb" \
            "${SCRIPT_DIR}/report-input-identity.rb" \
            "${SCRIPT_DIR}/publish-contract-report.rb" \
            "${SCRIPT_DIR}/verify-contract-report.rb" \
            "${SCRIPT_DIR}/run-spec-005.sh"
    } | LC_ALL=C sort -u
}

revision="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
if [[ -n "$(git -C "${PROJECT_ROOT}" status --porcelain --untracked-files=normal)" ]]; then
    dirty=true
else
    dirty=false
fi
mkdir -p "${REPORT_ROOT}"
report_dir="${REPORT_ROOT}/.tmp-${profile}-$$"
[[ ! -e "${report_dir}" ]] || fail "temporary report directory already exists: ${report_dir}"
mkdir -p "${report_dir}"
inputs_path="${report_dir}/input-hashes.tsv"
identity_metadata="$(declared_inputs | "${SCRIPT_DIR}/report-input-identity.rb" \
    --root "${PROJECT_ROOT}" --revision "${revision}" --inventory "${inputs_path}")"
input_set_sha256="$(printf '%s\n' "${identity_metadata}" | awk -F= '$1 == "input_set_sha256" { print $2 }')"
run_id="$(printf '%s\n' "${identity_metadata}" | awk -F= '$1 == "run_id" { print $2 }')"
[[ -n "${input_set_sha256}" && -n "${run_id}" ]] || fail 'input identity calculation failed'
canonical_report_dir="${REPORT_ROOT}/${run_id}/${profile}"
latest_pointer="${REPORT_ROOT}/latest-${profile}.txt"
if [[ -d "${canonical_report_dir}" ]]; then
    "${SCRIPT_DIR}/verify-contract-report.rb" "${canonical_report_dir}"
    temporary_pointer="${REPORT_ROOT}/.latest-${profile}.tmp-$$"
    printf '%s\n' "${run_id}" >"${temporary_pointer}"
    mv "${temporary_pointer}" "${latest_pointer}"
    printf 'SPEC-005 %s contract harness idempotent match; run ID: %s\n' \
        "${profile}" "${run_id}"
    exit 0
fi
generated_dir="${GENERATED_ROOT}/${profile}"
rm -rf "${generated_dir}"
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
images_path="${report_dir}/image-hashes.tsv"
log_path="${report_dir}/run.log"
: >"${commands_path}"
: >"${images_path}"
: >"${log_path}"

{
    printf 'schema_version=2\n'
    printf 'spec=SPEC-005\n'
    printf 'profile=%s\n' "${profile}"
    printf 'repository_revision=%s\n' "${revision}"
    printf 'repository_dirty=%s\n' "${dirty}"
    printf 'input_set_sha256=%s\n' "${input_set_sha256}"
    printf 'run_id=%s\n' "${run_id}"
    printf 'generated_directory=.build/contract-generated/spec-005/%s\n' "${profile}"
    printf 'report_directory=.build/contract-reports/spec-005/%s/%s\n' "${run_id}" "${profile}"
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
    if [[ "${result}" -ne 0 ]]; then
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
    local id expectation access entry patterns allowed_modules fixture_dir
    local diagnostic output_path result pattern order line module source copied
    local -a rows=()
    while IFS= read -r line; do
        [[ -n "${line}" && "${line}" != \#* ]] || continue
        rows+=("${line}")
    done <"${FIXTURE_ROOT}/fixture-manifest.tsv"

    for order in forward reverse; do
      local results="${report_dir}/fixtures/${order}-results.tsv"
      : >"${results}"
      local start end increment index
      if [[ "${order}" == forward ]]; then
          start=0; end=${#rows[@]}; increment=1
      else
          start=$((${#rows[@]} - 1)); end=-1; increment=-1
      fi
      for ((index = start; index != end; index += increment)); do
        IFS=$'\t' read -r id expectation access entry patterns allowed_modules <<<"${rows[index]}"
        fixture_dir="${report_dir}/fixtures/${order}/${id}"
        local fixture_module_dir="${fixture_dir}/modules"
        mkdir -p "${fixture_module_dir}"
        printf '%s\n' "${allowed_modules}" >"${fixture_dir}/allowed-modules.txt"
        : >"${fixture_dir}/module-hashes.tsv"
        IFS=',' read -ra fixture_modules <<<"${allowed_modules}"
        for module in "${fixture_modules[@]}"; do
            copied=0
            while IFS= read -r source; do
                cp -R "${source}" "${fixture_module_dir}/"
                if [[ -f "${source}" ]]; then
                    printf '%s\t%s\n' "$(basename "${source}")" "$(hash_file "${source}")" \
                        >>"${fixture_dir}/module-hashes.tsv"
                else
                    while IFS= read -r copied_file; do
                        printf '%s\t%s\n' \
                            "${copied_file#"${source}/"}" "$(hash_file "${copied_file}")" \
                            >>"${fixture_dir}/module-hashes.tsv"
                    done < <(find "${source}" -type f -print | LC_ALL=C sort)
                fi
                copied=$((copied + 1))
            done < <(find "${module_dir}" -maxdepth 1 \
                \( -name "${module}.swiftmodule" -o -name "${module}.swiftinterface" \
                   -o -name "${module}.package.swiftinterface" -o -name "${module}.swiftdoc" \
                   -o -name "${module}.swiftsourceinfo" \) -print | LC_ALL=C sort)
            [[ "${copied}" -gt 0 ]] || fail "fixture ${id} allowed module is unavailable: ${module}"
        done
        output_path="${fixture_dir}/stdout.txt"
        diagnostic="${fixture_dir}/stderr.txt"
        local -a command=("${compiler}" "${common_flags[@]}" -I "${fixture_module_dir}")
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
            printf '%s\t%s\t%s\n' "${id}" "${expectation}" "${result}" >>"${results}"
            continue
        fi
        [[ "${result}" -ne 0 ]] || fail "negative fixture ${id} unexpectedly compiled"
        while IFS= read -r pattern; do
            [[ -n "${pattern}" && "${pattern}" != \#* ]] || continue
            grep -Fq "${pattern}" "${diagnostic}" ||
                fail "negative fixture ${id} lacked diagnostic pattern: ${pattern}"
        done <"${FIXTURE_ROOT}/${patterns}"
        printf '%s\t%s\t%s\n' "${id}" "${expectation}" "${result}" >>"${results}"
      done
      LC_ALL=C sort -o "${results}" "${results}"
    done
    cmp -s "${report_dir}/fixtures/forward-results.tsv" \
        "${report_dir}/fixtures/reverse-results.tsv" ||
        fail 'fixture results changed when build order was reversed'
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
    [[ -s "${inputs_path}" ]] || fail 'input hash inventory is empty'
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
    record_command "${SCRIPT_DIR}/check-spec-005-reference-generation.rb"
    "${SCRIPT_DIR}/check-spec-005-reference-generation.rb" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-owner-adapters.rb"
    "${SCRIPT_DIR}/check-spec-005-owner-adapters.rb" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-synchronous-offer.rb"
    "${SCRIPT_DIR}/check-spec-005-synchronous-offer.rb" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-assembly-lifecycle.rb"
    "${SCRIPT_DIR}/check-spec-005-assembly-lifecycle.rb" >>"${log_path}" 2>&1
    command -v swift >/dev/null || fail 'swift is missing'
    record_command giftui_swiftpm --package-path "${PROJECT_ROOT}" \
        --cache-root "${report_dir}/build" -- package dump-package
    giftui_swiftpm --package-path "${PROJECT_ROOT}" \
        --cache-root "${report_dir}/build" -- package dump-package \
        >"${package_json}" 2>>"${log_path}"
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
    record_command "${SCRIPT_DIR}/check-spec-005-validator.rb" \
        "${TEXT_RESOURCE_SOURCE}"
    "${SCRIPT_DIR}/check-spec-005-validator.rb" \
        "${TEXT_RESOURCE_SOURCE}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-validation-corpus.rb" \
        "${FIXTURE_ROOT}/SemanticCorpus/cases.tsv" \
        "${UNIT_TEST_ROOT}"
    "${SCRIPT_DIR}/check-spec-005-validation-corpus.rb" \
        "${FIXTURE_ROOT}/SemanticCorpus/cases.tsv" \
        "${UNIT_TEST_ROOT}" >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-common-catalogue.rb" \
        "${UNIT_TEST_ROOT}/CommonCatalogueValidationTests.swift"
    "${SCRIPT_DIR}/check-spec-005-common-catalogue.rb" \
        "${UNIT_TEST_ROOT}/CommonCatalogueValidationTests.swift" \
        >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-validated-behavior.rb" \
        "${UNIT_TEST_ROOT}/ValidatedBehaviorTests.swift"
    "${SCRIPT_DIR}/check-spec-005-validated-behavior.rb" \
        "${UNIT_TEST_ROOT}/ValidatedBehaviorTests.swift" \
        >>"${log_path}" 2>&1
    record_command "${SCRIPT_DIR}/check-spec-005-validator-instrumentation.rb" \
        "${FIXTURE_ROOT}/Instrumentation/AllocationProbe/main.swift" \
        "${UNIT_TEST_ROOT}/ValidatorCoreTests.swift" \
        "${UNIT_TEST_ROOT}/WorkBoundTests.swift"
    "${SCRIPT_DIR}/check-spec-005-validator-instrumentation.rb" \
        "${FIXTURE_ROOT}/Instrumentation/AllocationProbe/main.swift" \
        "${UNIT_TEST_ROOT}/ValidatorCoreTests.swift" \
        "${UNIT_TEST_ROOT}/WorkBoundTests.swift" \
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
    record_command "${SCRIPT_DIR}/check-spec-005-static-path.rb" \
        "${output}" "${TEXT_RESOURCE_SOURCE}" \
        "${FIXTURE_ROOT}/Instrumentation/AllocationProbe/main.swift"
    "${SCRIPT_DIR}/check-spec-005-static-path.rb" \
        "${output}" "${TEXT_RESOURCE_SOURCE}" \
        "${FIXTURE_ROOT}/Instrumentation/AllocationProbe/main.swift" \
        >>"${log_path}" 2>&1
    record_image allocation-probe "${probe}"
    record_image allocation-interposer "${interposer}"
    record_image allocation-text-library "${text_library}"
}

run_reference_composition_probe() {
    local compiler="$1"
    local sdk_path="$2"
    local composition_root="${report_dir}/resources/candidate/compositions"
    record_command env \
        "GIFTUI_SPEC005_SWIFTC=${compiler}" \
        "GIFTUI_SPEC005_SDK=${sdk_path}" \
        'GIFTUI_SPEC005_TARGET=arm64-apple-macosx26.0' \
        "${SCRIPT_DIR}/check-spec-005-reference-compositions.sh" \
        "${composition_root}"
    env \
        GIFTUI_SPEC005_SWIFTC="${compiler}" \
        GIFTUI_SPEC005_SDK="${sdk_path}" \
        GIFTUI_SPEC005_TARGET=arm64-apple-macosx26.0 \
        "${SCRIPT_DIR}/check-spec-005-reference-compositions.sh" \
        "${composition_root}" >>"${log_path}" 2>&1
    local composition
    for composition in complete bitmap-only outline-only; do
        record_image \
            "reference-${composition}-library" \
            "${composition_root}/${composition}/libraries/libGiftUIReferenceTextResources.dylib"
        record_image \
            "reference-${composition}-probe" \
            "${composition_root}/${composition}/probe"
    done
}

run_resource_timing_probe() {
    local compiler="$1"
    local sdk_path="$2"
    local composition_root="${report_dir}/resources/candidate/compositions"
    local probe="${report_dir}/build/resource-timing-probe"
    local output="${report_dir}/semantics/resource-timing.txt"
    local -a command=(
        "${compiler}" -target arm64-apple-macosx26.0 -sdk "${sdk_path}"
        -O -whole-module-optimization -language-mode 6 -package-name GiftUI
        -module-cache-path "${report_dir}/build/clang-cache"
        -I "${composition_root}/base/modules" -I "${composition_root}/complete/modules"
        -L "${composition_root}/base/libraries" -L "${composition_root}/complete/libraries"
        -lGiftUI -lGiftUITextResources -lGiftUIReferenceTextResources
        -Xlinker -rpath -Xlinker "${composition_root}/base/libraries"
        -Xlinker -rpath -Xlinker "${composition_root}/complete/libraries"
        "${FIXTURE_ROOT}/Instrumentation/TimingProbe.swift" -o "${probe}"
    )
    record_command "${command[@]}"
    "${command[@]}" >>"${log_path}" 2>&1
    record_command env "DYLD_LIBRARY_PATH=${composition_root}/base/libraries:${composition_root}/complete/libraries" "${probe}"
    env "DYLD_LIBRARY_PATH=${composition_root}/base/libraries:${composition_root}/complete/libraries" \
        "${probe}" >"${output}" 2>>"${log_path}"
    record_command "${SCRIPT_DIR}/check-spec-005-timing.rb" "${output}" \
        "${FIXTURE_ROOT}/Instrumentation/TimingProbe.swift"
    "${SCRIPT_DIR}/check-spec-005-timing.rb" "${output}" \
        "${FIXTURE_ROOT}/Instrumentation/TimingProbe.swift" >>"${log_path}" 2>&1
    record_image resource-timing-probe "${probe}"
}

run_profile_semantic_report() {
    local output="${report_dir}/semantics/profile-semantics.tsv"
    record_command "${SCRIPT_DIR}/generate-spec-005-profile-semantics.rb" \
        "${profile}" "${output}"
    "${SCRIPT_DIR}/generate-spec-005-profile-semantics.rb" \
        "${profile}" "${output}" >>"${log_path}" 2>&1
    printf 'required_realization_ids=%s\n' \
        "$(awk -F '\t' '$2 == "availability" && $3 == "required-realizations" { print $4 }' "${output}")" \
        >>"${metadata_path}"
    printf 'available_realization_ids=%s\n' \
        "$(awk -F '\t' '$2 == "availability" && $3 == "available-realizations" { print $4 }' "${output}")" \
        >>"${metadata_path}"
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
    run_reference_composition_probe "${compiler}" "${sdk_path}"
    run_resource_timing_probe "${compiler}" "${sdk_path}"
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
    local -a reference_command=(
        "${swift_driver}" build --package-path "${PROJECT_ROOT}"
        --scratch-path "${report_dir}/build/swiftpm"
        --destination "${GIFTUI_PI_STATIC_DESTINATION}"
        --configuration release --target GiftUIReferenceTextResources
        --static-swift-stdlib -Xswiftc -whole-module-optimization
    )
    record_command "${reference_command[@]}"
    "${reference_command[@]}" >>"${log_path}" 2>&1
    local -a reference_modules=()
    while IFS= read -r module; do
        reference_modules+=("${module}")
    done < <(find "${report_dir}/build/swiftpm" -type f -name 'GiftUIReferenceTextResources.swiftmodule' -print)
    [[ "${#reference_modules[@]}" -eq 1 ]] ||
        fail "expected one ARMv6 reference-resource module, found ${#reference_modules[@]}"
    record_image reference-resource-module "${reference_modules[0]}"
    run_armv6_resource_pair "${compiler}" "${sdk_root}"
}

run_armv6_resource_pair() {
    local compiler="$1"
    local sdk_root="$2"
    local pair_root="${generated_dir}/armv6-resource-pair"
    local kind source image map destination candidate_flag file_description attributes_hex
    local objdump="${GIFTUI_PI_HOST_BIN_DIR}/llvm-objdump"
    local nm="${GIFTUI_PI_HOST_BIN_DIR}/llvm-nm"
    mkdir -p "${pair_root}"
    for kind in baseline candidate; do
        source="${pair_root}/${kind}.swift"
        cp "${FOUNDATION_SOURCE}" "${source}"
        if [[ "${kind}" == candidate ]]; then
            for input in \
                "${TEXT_RESOURCE_SOURCE}" \
                "${REFERENCE_SOURCE_ROOT}/Generated/ReferenceCatalogue.generated.swift" \
                "${REFERENCE_SOURCE_ROOT}/Generated/ReferenceBitmapPayload.generated.swift" \
                "${REFERENCE_SOURCE_ROOT}/GiftUIReferenceTextResources.swift"; do
                sed -e '/^import GiftUI$/d' -e '/^import GiftUITextResources$/d' \
                    "${input}" >>"${source}"
            done
            candidate_flag=-DGIFTUI_SPEC005_CANDIDATE
        else
            candidate_flag=-DGIFTUI_SPEC005_BASELINE
        fi
        sed -e '/^import GiftUI$/d' -e '/^import GiftUITextResources$/d' \
            "${FIXTURE_ROOT}/ResourceHarness/ResourceProbe.swift" >>"${source}"
        image="${pair_root}/${kind}"
        map="${pair_root}/${kind}.map"
        local -a command=(
            "${compiler}" -target "${GIFTUI_PI_TARGET}" -use-ld=lld
            -Xcc "--gcc-toolchain=${sdk_root}/usr"
            -resource-dir "${sdk_root}/usr/lib/swift_static"
            -sdk "${sdk_root}" -latomic -static-stdlib
            -O -whole-module-optimization -language-mode 6 -package-name GiftUI
            "${candidate_flag}" -DGIFTUI_REFERENCE_BITMAP_ONLY
            "${source}" "${FIXTURE_ROOT}/ResourceHarness/ARMv6Main.swift"
            -Xlinker -Map -Xlinker "${map}" -o "${image}"
        )
        record_command "${command[@]}"
        "${command[@]}" >>"${log_path}" 2>&1
        destination="${report_dir}/resources/armv6/${kind}"
        mkdir -p "${destination}"
        record_command file "${image}"
        file_description="$(file "${image}")"
        printf '%s\n' "${file_description}" >"${destination}/file.txt"
        [[ "${file_description}" == *'ELF 32-bit LSB'*ARM*EABI5* ]] ||
            fail "SPEC-005 ${kind} ARMv6 resource image has the wrong ELF identity: ${file_description}"
        record_command "${objdump}" -h "${image}"
        "${objdump}" -h "${image}" >"${destination}/sections.txt"
        "${objdump}" -s -j .ARM.attributes "${image}" >"${destination}/arm-attributes.txt"
        attributes_hex="$(
            "${objdump}" -s -j .ARM.attributes "${image}" |
                awk '
                    /^[[:space:]]+[[:xdigit:]]+[[:space:]]/ {
                        for (i = 2; i <= NF; i++) {
                            if ($i ~ /^[0-9A-Fa-f]+$/ && length($i) <= 8) {
                                printf "%s", $i
                            }
                        }
                    }
                    END { print "" }
                '
        )"
        [[ "${attributes_hex}" == *'0536000606'* ]] ||
            fail "SPEC-005 ${kind} ARMv6 resource image does not declare ARMv6 architecture"
        [[ "${attributes_hex}" == *'1c01'* ]] ||
            fail "SPEC-005 ${kind} ARMv6 resource image does not declare hard-float ABI"
        "${nm}" -S --size-sort "${image}" >"${destination}/named-symbols.txt"
        cp "${map}" "${destination}/link.map"
        cp "${image}" "${destination}/resource-probe"
        record_image "armv6-resource-${kind}" "${destination}/resource-probe"
    done
    local summary="${report_dir}/resources/armv6/armv6-resource-summary.tsv"
    record_command "${SCRIPT_DIR}/check-spec-005-armv6-resources.rb" \
        "${report_dir}/resources/armv6/baseline" \
        "${report_dir}/resources/armv6/candidate" "${summary}"
    "${SCRIPT_DIR}/check-spec-005-armv6-resources.rb" \
        "${report_dir}/resources/armv6/baseline" \
        "${report_dir}/resources/armv6/candidate" "${summary}" \
        >>"${log_path}" 2>&1
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
    local -a reference_command=(
        "${GIFTUI_NRF_SWIFTC}" "${compile_flags[@]}"
        -DGIFTUI_REFERENCE_BITMAP_ONLY -emit-module -I "${module_dir}"
        -module-name GiftUIReferenceTextResources
        "${REFERENCE_SOURCE_ROOT}/Generated/ReferenceCatalogue.generated.swift"
        "${REFERENCE_SOURCE_ROOT}/Generated/ReferenceBitmapPayload.generated.swift"
        "${REFERENCE_SOURCE_ROOT}/GiftUIReferenceTextResources.swift"
        -emit-module-path "${module_dir}/GiftUIReferenceTextResources.swiftmodule"
    )
    record_command "${reference_command[@]}"
    "${reference_command[@]}" >>"${log_path}" 2>&1
    record_image reference-resource-module \
        "${module_dir}/GiftUIReferenceTextResources.swiftmodule"

    run_nrf_resource_pair
}

run_nrf_resource_pair() {
    local application_dir="${PROJECT_ROOT}/firmware/nrf52840/applications/spec005-resource-probe"
    local pair_root="${generated_dir}/resource-pair"
    local build_index kind build_dir candidate_flag elf destination
    local readelf="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf"
    local objdump="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-objdump"
    local nm="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-nm"
    giftui_nrf_export_environment
    for build_index in 1 2; do
        for kind in baseline candidate; do
            build_dir="${pair_root}/${kind}"
            if [[ "${kind}" == candidate ]]; then
                candidate_flag=ON
            else
                candidate_flag=OFF
            fi
            local -a build_command=(
                "${GIFTUI_NRF_WEST}" build -p always -b "${GIFTUI_NRF_BOARD}"
                -d "${build_dir}" "${application_dir}" --
                "-DCMAKE_MAKE_PROGRAM=$(giftui_nrf_ninja)"
                "-DCMAKE_Swift_COMPILER=${GIFTUI_NRF_SWIFTC}"
                "-DGIFTUI_SWIFT_TARGET=${GIFTUI_NRF_SWIFT_TARGET}"
                "-DGIFTUI_SPEC005_CANDIDATE=${candidate_flag}"
                "-DDTC=$(giftui_nrf_dtc)" -DUSE_CCACHE=0
            )
            record_command "${build_command[@]}"
            "${build_command[@]}" >>"${log_path}" 2>&1
            elf="${build_dir}/zephyr/zephyr.elf"
            [[ -f "${elf}" ]] || fail "missing SPEC-005 ${kind} resource ELF"
            destination="${report_dir}/resources/build-${build_index}/${kind}"
            mkdir -p "${destination}"
            record_command "${readelf}" -lWSA "${elf}"
            "${readelf}" -lW "${elf}" >"${destination}/program-headers.txt"
            "${readelf}" -SW "${elf}" >"${destination}/sections.txt"
            "${readelf}" -A "${elf}" >"${destination}/arm-attributes.txt"
            "${readelf}" -sW "${elf}" >"${destination}/symbols.txt"
            record_command "${objdump}" -d "${elf}"
            "${objdump}" -d "${elf}" >"${destination}/disassembly.txt"
            record_command "${nm}" -S --size-sort "${elf}"
            "${nm}" -S --size-sort "${elf}" >"${destination}/named-symbols.txt"
            cp "${build_dir}/zephyr/zephyr.map" "${destination}/zephyr.map"
            cp "${elf}" "${destination}/zephyr.elf"
            grep -Fq 'Tag_CPU_arch: v7E-M' "${destination}/arm-attributes.txt" ||
                fail 'SPEC-005 resource ELF does not declare ARMv7E-M'
            grep -Fq 'Tag_FP_arch: VFPv4-D16' "${destination}/arm-attributes.txt" ||
                fail 'SPEC-005 resource ELF does not declare VFPv4-D16'
            grep -Fq 'Tag_ABI_VFP_args: VFP registers' "${destination}/arm-attributes.txt" ||
                fail 'SPEC-005 resource ELF does not declare VFP-register calling convention'
            record_image "resource-build-${build_index}-${kind}-elf" "${destination}/zephyr.elf"
        done
        local summary="${report_dir}/resources/build-${build_index}/nrf-resource-summary.tsv"
        record_command "${SCRIPT_DIR}/check-spec-005-nrf-resources.rb" \
            "${report_dir}/resources/build-${build_index}/baseline" \
            "${report_dir}/resources/build-${build_index}/candidate" "${summary}"
        "${SCRIPT_DIR}/check-spec-005-nrf-resources.rb" \
            "${report_dir}/resources/build-${build_index}/baseline" \
            "${report_dir}/resources/build-${build_index}/candidate" \
            "${summary}" >>"${log_path}" 2>&1
    done
    for kind in baseline candidate; do
        cmp "${report_dir}/resources/build-1/${kind}/zephyr.elf" \
            "${report_dir}/resources/build-2/${kind}/zephyr.elf" ||
            fail "SPEC-005 ${kind} resource ELF is not repeatable"
    done
    cmp "${report_dir}/resources/build-1/nrf-resource-summary.tsv" \
        "${report_dir}/resources/build-2/nrf-resource-summary.tsv" ||
        fail 'SPEC-005 normalized nRF resource metrics are not repeatable'
    cmp "${report_dir}/resources/build-1/nrf-validation-call-graph.tsv" \
        "${report_dir}/resources/build-2/nrf-validation-call-graph.tsv" ||
        fail 'SPEC-005 normalized validation call graph is not repeatable'
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
        input_set_sha256 run_id generated_directory report_directory invocation evidence remote_access \
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
run_profile_semantic_report
verify_report
printf 'exit_code=0\n' >>"${metadata_path}"
trap - EXIT
"${SCRIPT_DIR}/publish-contract-report.rb" \
    --report-root "${REPORT_ROOT}" \
    --staging "${report_dir}" \
    --destination "${canonical_report_dir}" \
    --latest "${latest_pointer}" \
    --run-id "${run_id}"
printf 'SPEC-005 %s contract harness passed; run ID: %s\n' "${profile}" "${run_id}"
