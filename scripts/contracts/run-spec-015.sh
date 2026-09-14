#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC015"
REPORT_ROOT="${PROJECT_ROOT}/.build/spec-015"
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

mkdir -p "${REPORT_ROOT}/${profile}"
input_identity="$(shasum -a 256 "${FIXTURE_ROOT}"/*.tsv | shasum -a 256 | awk '{print $1}')"
compiler_identity="$(swiftc --version 2>/dev/null | tr '\n' ' ')"
command_hash="$(printf '%s' "scripts/contracts/run-spec-015.sh --profile ${profile}" | shasum -a 256 | awk '{print $1}')"
output="${REPORT_ROOT}/${profile}/report.tsv"

case "${profile}" in
    macos-dynamic) product="SignalAnalyzerMacOSDynamic" ;;
    macos-static) product="SignalAnalyzerMacOSStatic" ;;
    raspberry-pi-armv6) product="SignalAnalyzerRaspberryPiARMv6" ;;
    *) product="" ;;
esac

if [[ "${profile}" == "raspberry-pi-armv6" ]]; then
    compiler_identity="$(.toolchains/host/swift-6.3.2-RELEASE-osx/usr/bin/swiftc --version | tr '\n' ' ')"
    build_log="${REPORT_ROOT}/${profile}/build.log"
    scripts/raspberry-pi/build.sh --product "${product}" >"${build_log}" 2>&1
    artifact="${PROJECT_ROOT}/.build/raspberry-pi/artifacts/${product}"
    [[ -x "${artifact}" ]] || { printf 'missing ARMv6 preset executable: %s\n' "${artifact}" >&2; exit 1; }
    swift build --disable-sandbox --product "${product}" >>"${build_log}" 2>&1
    binary_dir="$(swift build --disable-sandbox --show-bin-path)"
    semantic_report="${REPORT_ROOT}/${profile}/semantic.tsv"
    "${binary_dir}/${product}" >"${semantic_report}"
    grep -Fq $'status=complete' "${semantic_report}" || {
        printf 'incomplete preset report: %s\n' "${semantic_report}" >&2
        exit 1
    }
    inspector="${PROJECT_ROOT}/.toolchains/host/swift-6.3.2-RELEASE-osx/usr/bin/llvm-objdump"
    "${inspector}" -p -h "${artifact}" >"${REPORT_ROOT}/${profile}/elf.txt"
    grep -Fq 'file format elf32-littlearm' "${REPORT_ROOT}/${profile}/elf.txt"
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

if [[ -n "${product}" ]]; then
    build_log="${REPORT_ROOT}/${profile}/build.log"
    swift build --disable-sandbox --product "${product}" >"${build_log}" 2>&1
    binary_dir="$(swift build --disable-sandbox --show-bin-path)"
    artifact="${binary_dir}/${product}"
    [[ -x "${artifact}" ]] || { printf 'missing preset executable: %s\n' "${artifact}" >&2; exit 1; }
    semantic_report="${REPORT_ROOT}/${profile}/semantic.tsv"
    "${artifact}" >"${semantic_report}"
    grep -Fq $'status=complete' "${semantic_report}" || {
        printf 'incomplete preset report: %s\n' "${semantic_report}" >&2
        exit 1
    }
    output_hash="$(shasum -a 256 "${semantic_report}" | awk '{print $1}')"
    artifact_hash="$(shasum -a 256 "${artifact}" | awk '{print $1}')"
    nm -u "${artifact}" >"${REPORT_ROOT}/${profile}/undefined-symbols.txt"
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
