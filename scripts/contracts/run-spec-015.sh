#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC015"
REPORT_ROOT="${GIFTUI_CONTRACT_REPORT_DIR:-${PROJECT_ROOT}/.build/spec-015}"
export CLANG_MODULE_CACHE_PATH="${PROJECT_ROOT}/.build/clang-module-cache"
mkdir -p "${CLANG_MODULE_CACHE_PATH}"

usage() {
    printf '%s\n' 'Usage: scripts/contracts/run-spec-015.sh --profile <profile>' \
        '' 'Profiles: macos-dynamic, macos-static, raspberry-pi-armv6, nrf52840-embedded'
}

profile=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile) [[ $# -ge 2 ]] || { usage >&2; exit 2; }; profile="$2"; shift 2 ;;
        -h | --help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done
case "${profile}" in
    macos-dynamic | macos-static | raspberry-pi-armv6 | nrf52840-embedded) ;;
    *) usage >&2; exit 2 ;;
esac

if [[ "${GIFTUI_IMMUTABLE_REPORT_INNER:-false}" != true ]]; then
    exec "${SCRIPT_DIR}/run-immutable-contract-driver.sh" \
        --spec SPEC-015 --profile "${profile}" --driver "$0"
fi

mkdir -p "${REPORT_ROOT}"
commands_path="${REPORT_ROOT}/commands.txt"
run_log="${REPORT_ROOT}/run.log"
: >"${commands_path}"
: >"${run_log}"

run_check() {
    local argument
    for argument in "$@"; do printf '%q ' "${argument}" >>"${commands_path}"; done
    printf '\n' >>"${commands_path}"
    "$@" >>"${run_log}" 2>&1
}

run_check ruby "${SCRIPT_DIR}/check-spec-015-harness.rb"
run_check ruby "${SCRIPT_DIR}/check-spec-015-negative-corpus.rb"
run_check ruby "${SCRIPT_DIR}/check-spec-015-source-boundaries.rb"
run_check ruby "${SCRIPT_DIR}/check-spec-015-generated-workload.rb"
run_check "${SCRIPT_DIR}/check-spec-015-validation-purity.sh"
run_check "${SCRIPT_DIR}/check-spec-015-host-surfaces.sh" \
    --output "${REPORT_ROOT}/host-surfaces"
run_check swift test --disable-sandbox \
    --scratch-path "${PROJECT_ROOT}/.build" \
    --filter GiftUIHostConfigurationTests
input_identity="$(shasum -a 256 "${FIXTURE_ROOT}"/*.tsv | shasum -a 256 | awk '{print $1}')"
compiler_identity="$(swiftc --version 2>/dev/null | tr '\n' ' ')"
command_hash="$(printf '%s' "scripts/contracts/run-spec-015.sh --profile ${profile}" | shasum -a 256 | awk '{print $1}')"
output="${REPORT_ROOT}/report.tsv"
{
    printf 'schema_version=1\n'
    printf 'spec=SPEC-015\n'
    printf 'profile=%s\n' "${profile}"
    printf 'repository_revision=%s\n' "$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
    printf 'repository_dirty=%s\n' "$(git -C "${PROJECT_ROOT}" status --porcelain --untracked-files=normal | grep -q . && printf true || printf false)"
    printf 'invocation=scripts/contracts/run-spec-015.sh --profile %s\n' "${profile}"
    printf 'remote_access=false\n'
    printf 'deployment=false\n'
    printf 'service_restart=false\n'
    printf 'connected_target_execution=false\n'
    printf 'flashing=false\n'
} >"${REPORT_ROOT}/metadata.txt"

case "${profile}" in
    macos-dynamic) product="SignalAnalyzerMacOSDynamic" ;;
    macos-static) product="SignalAnalyzerMacOSStatic" ;;
    raspberry-pi-armv6) product="SignalAnalyzerRaspberryPiARMv6" ;;
    nrf52840-embedded) product="SignalAnalyzerNRF52840HostOracle" ;;
    *) product="" ;;
esac

if [[ "${profile}" == "raspberry-pi-armv6" ]]; then
    compiler_identity="$(.toolchains/host/swift-6.3.2-RELEASE-osx/usr/bin/swiftc --version | tr '\n' ' ')"
    build_log="${REPORT_ROOT}/build.log"
    run_check scripts/raspberry-pi/doctor.sh
    scripts/raspberry-pi/build.sh --product "${product}" >"${build_log}" 2>&1
    artifact="${PROJECT_ROOT}/.build/raspberry-pi/artifacts/${product}"
    [[ -x "${artifact}" ]] || { printf 'missing ARMv6 preset executable: %s\n' "${artifact}" >&2; exit 1; }
    swift build --disable-sandbox --scratch-path "${PROJECT_ROOT}/.build" \
        --product "${product}" >>"${build_log}" 2>&1
    binary_dir="$(swift build --disable-sandbox --scratch-path "${PROJECT_ROOT}/.build" --show-bin-path)"
    semantic_report="${REPORT_ROOT}/semantic.tsv"
    "${binary_dir}/${product}" >"${semantic_report}"
    grep -Fq $'status=complete' "${semantic_report}" || {
        printf 'incomplete preset report: %s\n' "${semantic_report}" >&2
        exit 1
    }
    inspector="${PROJECT_ROOT}/.toolchains/host/swift-6.3.2-RELEASE-osx/usr/bin/llvm-objdump"
    "${inspector}" -p -h "${artifact}" >"${REPORT_ROOT}/elf.txt"
    grep -Fq 'file format elf32-littlearm' "${REPORT_ROOT}/elf.txt"
    output_hash="$(shasum -a 256 "${semantic_report}" | awk '{print $1}')"
    artifact_hash="$(shasum -a 256 "${artifact}" | awk '{print $1}')"
    {
        printf '# schema_version\tprofile\tinput_identity\tcompiler_identity\ttoolchain_identity\toptimization\tcommand_hash\toutput_hash\tstatus\tevidence_kind\n'
        printf '1\t%s\t%s\t%s\tswift-6.3.2-armv6\trelease\t%s\t%s\tcomplete\tcross-build\n' \
            "${profile}" "${input_identity}" "${compiler_identity}" "${command_hash}" "${output_hash}"
        printf '# artifact_identity\t%s\n' "${artifact_hash}"
        printf '# artifact_bytes\t%s\n' "$(stat -f '%z' "${artifact}")"
        printf '# connected_execution\tnot-collected\n'
    } >"${output}"
    printf 'SPEC-015 %s complete (cross-build only): %s\n' "${profile}" "${output}"
    exit 0
fi

if [[ "${profile}" == "nrf52840-embedded" ]]; then
    compiler_identity="$(.toolchains/nrf52840/swift/swift-6.3.2-RELEASE-osx/usr/bin/swiftc --version | tr '\n' ' ')"
    build_log="${REPORT_ROOT}/build.log"
    run_check scripts/nrf52840/doctor.sh
    scripts/nrf52840/build.sh --application signal-analyzer-static >"${build_log}" 2>&1
    swift build --disable-sandbox --scratch-path "${PROJECT_ROOT}/.build" \
        --product "${product}" >>"${build_log}" 2>&1
    binary_dir="$(swift build --disable-sandbox --scratch-path "${PROJECT_ROOT}/.build" --show-bin-path)"
    semantic_report="${REPORT_ROOT}/semantic.tsv"
    "${binary_dir}/${product}" >"${semantic_report}"
    grep -Fq $'status=complete' "${semantic_report}" || {
        printf 'incomplete preset report: %s\n' "${semantic_report}" >&2
        exit 1
    }
    firmware_root="${PROJECT_ROOT}/.build/nrf52840/signal-analyzer-static"
    artifact="${firmware_root}/zephyr/zephyr.elf"
    [[ -f "${artifact}" ]] || { printf 'missing nRF52840 preset ELF: %s\n' "${artifact}" >&2; exit 1; }
    cp "${firmware_root}/reports/arm-attributes.txt" "${REPORT_ROOT}/arm-attributes.txt"
    cp "${firmware_root}/reports/memory-summary.txt" "${REPORT_ROOT}/memory-summary.txt"
    cp "${firmware_root}/reports/symbols.txt" "${REPORT_ROOT}/symbols.txt"
    grep -Fq 'Tag_CPU_arch: v7E-M' "${REPORT_ROOT}/arm-attributes.txt"
    grep -Fq 'Tag_ABI_VFP_args: VFP registers' "${REPORT_ROOT}/arm-attributes.txt"
    output_hash="$(shasum -a 256 "${semantic_report}" | awk '{print $1}')"
    artifact_hash="$(shasum -a 256 "${artifact}" | awk '{print $1}')"
    {
        printf '# schema_version\tprofile\tinput_identity\tcompiler_identity\ttoolchain_identity\toptimization\tcommand_hash\toutput_hash\tstatus\tevidence_kind\n'
        printf '1\t%s\t%s\t%s\tswift-6.3.2-zephyr-4.3.0\tOsize\t%s\t%s\tcomplete\tcross-build\n' \
            "${profile}" "${input_identity}" "${compiler_identity}" "${command_hash}" "${output_hash}"
        printf '# artifact_identity\t%s\n' "${artifact_hash}"
        sed -n 's/^/\# /p' "${REPORT_ROOT}/memory-summary.txt"
        printf '# named_profile_storage_bytes\t30608\n'
        printf '# named_capture_storage_bytes\t115392\n'
        printf '# named_raster_staging_bytes\t3840\n'
        printf '# analyzed_entry_stack_bytes\t8\n'
        printf '# connected_execution\tnot-collected\n'
    } >"${output}"
    printf 'SPEC-015 %s complete (cross-build only): %s\n' "${profile}" "${output}"
    exit 0
fi

if [[ -n "${product}" ]]; then
    build_log="${REPORT_ROOT}/build.log"
    swift build --disable-sandbox --scratch-path "${PROJECT_ROOT}/.build" \
        --product "${product}" >"${build_log}" 2>&1
    binary_dir="$(swift build --disable-sandbox --scratch-path "${PROJECT_ROOT}/.build" --show-bin-path)"
    artifact="${binary_dir}/${product}"
    [[ -x "${artifact}" ]] || { printf 'missing preset executable: %s\n' "${artifact}" >&2; exit 1; }
    semantic_report="${REPORT_ROOT}/semantic.tsv"
    "${artifact}" >"${semantic_report}"
    grep -Fq $'status=complete' "${semantic_report}" || {
        printf 'incomplete preset report: %s\n' "${semantic_report}" >&2
        exit 1
    }
    output_hash="$(shasum -a 256 "${semantic_report}" | awk '{print $1}')"
    artifact_hash="$(shasum -a 256 "${artifact}" | awk '{print $1}')"
    nm -u "${artifact}" >"${REPORT_ROOT}/undefined-symbols.txt"
    {
        printf '# schema_version\tprofile\tinput_identity\tcompiler_identity\ttoolchain_identity\toptimization\tcommand_hash\toutput_hash\tstatus\tevidence_kind\n'
        printf '1\t%s\t%s\t%s\tlocal-pinned\tdebug\t%s\t%s\tcomplete\thost-execution\n' \
            "${profile}" "${input_identity}" "${compiler_identity}" "${command_hash}" "${output_hash}"
        printf '# artifact_identity\t%s\n' "${artifact_hash}"
    } >"${output}"
    printf 'SPEC-015 %s complete: %s\n' "${profile}" "${output}"
    exit 0
fi

{
    printf '# schema_version\tprofile\tinput_identity\tcompiler_identity\ttoolchain_identity\toptimization\tcommand_hash\toutput_hash\tstatus\tevidence_kind\n'
    printf '1\t%s\t%s\t%s\tlocal-pinned\tnone\t%s\tmissing\tmissing\thost-execution\n' \
        "${profile}" "${input_identity}" "${compiler_identity}" "${command_hash}"
} >"${output}"
printf 'SPEC-015 %s is fail-closed: implementation evidence is missing (%s)\n' "${profile}" "${output}" >&2
exit 1
