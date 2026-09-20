#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
FIXTURE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC001"
REPORT_ROOT="${PROJECT_ROOT}/.build/contract-reports/spec-001"
export CLANG_MODULE_CACHE_PATH="${PROJECT_ROOT}/.build/clang-module-cache"
mkdir -p "${CLANG_MODULE_CACHE_PATH}"

usage() {
    printf '%s\n' \
        'Usage: scripts/contracts/run-spec-001.sh --profile <profile>' \
        '' \
        'Profiles: macos-dynamic, macos-static, raspberry-pi-armv6, nrf52840-embedded'
}

fail_usage() {
    printf 'error: %s\n' "$*" >&2
    usage >&2
    exit 2
}

profile=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile)
            [[ $# -ge 2 ]] || fail_usage '--profile requires a value'
            profile="$2"
            shift 2
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *) fail_usage "unknown option: $1" ;;
    esac
done

case "${profile}" in
    macos-dynamic)
        target_triple="arm64-apple-macosx"
        optimization="debug-dynamic"
        evidence_kind="macos-target-execution"
        ;;
    macos-static)
        target_triple="arm64-apple-macosx"
        optimization="debug-static"
        evidence_kind="macos-target-execution"
        ;;
    raspberry-pi-armv6)
        target_triple="armv6-unknown-linux-gnueabihf"
        optimization="release"
        evidence_kind="cross-build-inspection"
        ;;
    nrf52840-embedded)
        target_triple="armv7em-none-none-eabi"
        optimization="release-size"
        evidence_kind="cross-build-inspection"
        ;;
    "") fail_usage '--profile is required' ;;
    *) fail_usage "unknown profile: ${profile}" ;;
esac

revision="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
dirty=false
[[ -z "$(git -C "${PROJECT_ROOT}" status --porcelain --untracked-files=normal)" ]] || dirty=true
fixture_identity="$(find "${FIXTURE_ROOT}" -type f -print0 | sort -z | xargs -0 shasum -a 256 | shasum -a 256 | awk '{print $1}')"
source_paths=(
    "${PROJECT_ROOT}/Sources/SignalAnalyzerDomain"
    "${PROJECT_ROOT}/Sources/SignalAnalyzerData"
    "${PROJECT_ROOT}/Sources/SignalAnalyzerPresentation"
)
if [[ -d "${source_paths[0]}" && -d "${source_paths[1]}" && -d "${source_paths[2]}" ]]; then
    source_identity="$(find "${source_paths[@]}" -type f -print0 | sort -z | xargs -0 shasum -a 256 | shasum -a 256 | awk '{print $1}')"
else
    source_identity="missing"
fi
compiler_identity="$(swiftc --version 2>/dev/null | tr '\n' ' ')"
[[ -n "${compiler_identity}" ]] || compiler_identity="missing"
sdk_identity="missing"
if [[ "${profile}" == macos-* ]]; then
    sdk_identity="$(xcrun --sdk macosx --show-sdk-path 2>/dev/null || true)"
    [[ -n "${sdk_identity}" ]] || sdk_identity="missing"
fi
invocation="scripts/contracts/run-spec-001.sh --profile ${profile}"
command_identity="$(printf '%s' "${invocation}" | shasum -a 256 | awk '{print $1}')"
run_identity="$(date -u '+%Y%m%dT%H%M%SZ')-$$"
staging_report_dir="${REPORT_ROOT}/.tmp-${profile}-${run_identity}"
canonical_report_dir="${REPORT_ROOT}/${run_identity}/${profile}"
latest_report="${REPORT_ROOT}/latest-${profile}.txt"
mkdir -p "${staging_report_dir}"

ruby "${SCRIPT_DIR}/check-spec-001-harness.rb"
ruby "${SCRIPT_DIR}/check-spec-001-failure-matrix.rb"
ruby "${SCRIPT_DIR}/check-spec-001-diagnostic-matrix.rb"
ruby "${SCRIPT_DIR}/check-spec-001-revision-boundary.rb"
ruby "${SCRIPT_DIR}/check-spec-001-sustained-workload.rb"
ruby "${SCRIPT_DIR}/check-spec-001-nrf-static-canvas.rb"
"${SCRIPT_DIR}/check-spec-001-interface-audit.sh"
swift test --disable-sandbox --scratch-path "${PROJECT_ROOT}/.build" \
    -Xswiftc -DGIFTUI_DYNAMIC_PROFILE --filter SignalAnalyzer

if [[ "${profile}" == "macos-dynamic" || "${profile}" == "macos-static" ]]; then
    "${SCRIPT_DIR}/run-spec-015.sh" --profile "${profile}"
    spec015_run_id="$(cat "${PROJECT_ROOT}/.build/contract-reports/spec-015/latest-${profile}.txt")"
    spec015_report_dir="${PROJECT_ROOT}/.build/contract-reports/spec-015/${spec015_run_id}/${profile}"
    product="SignalAnalyzerMacOSDynamic"
    [[ "${profile}" == "macos-static" ]] && product="SignalAnalyzerMacOSStatic"
    binary_dir="$(swift build --disable-sandbox --show-bin-path)"
    artifact="${binary_dir}/${product}"
    artifact_identity="$(shasum -a 256 "${artifact}" | awk '{print $1}')"
    cp "${spec015_report_dir}/semantic.tsv" \
        "${staging_report_dir}/host-transcript.tsv"
    {
        printf 'schema_version=1\n'
        printf 'spec=SPEC-001\nprofile=%s\n' "${profile}"
        printf 'evidence_kind=%s\n' "${evidence_kind}"
        printf 'repository_revision=%s\nrepository_dirty=%s\n' "${revision}" "${dirty}"
        printf 'source_identity=%s\nfixture_identity=%s\n' "${source_identity}" "${fixture_identity}"
        printf 'compiler_identity=%s\nsdk_identity=%s\n' "${compiler_identity}" "${sdk_identity}"
        printf 'target_triple=%s\noptimization=%s\n' "${target_triple}" "${optimization}"
        printf 'invocation=%s\ncommand_identity=%s\n' "${invocation}" "${command_identity}"
        printf 'artifact_path=%s\nartifact_identity=%s\n' "${artifact}" "${artifact_identity}"
        printf 'remote_access=false\ndeployment=false\nservice_restart=false\n'
        printf 'hardware_probe=false\nflashing=false\nnetwork_access=false\n'
        printf 'status=complete\nblocking_reason=none\n'
    } >"${staging_report_dir}/metadata.txt"
    "${SCRIPT_DIR}/publish-contract-report.rb" \
        --report-root "${REPORT_ROOT}" \
        --staging "${staging_report_dir}" \
        --destination "${canonical_report_dir}" \
        --latest "${latest_report}" \
        --run-id "${run_identity}" >/dev/null
    printf 'SPEC-001 %s complete: %s\n' "${profile}" "${canonical_report_dir}"
    exit 0
fi

if [[ "${profile}" == "raspberry-pi-armv6" ]]; then
    "${SCRIPT_DIR}/run-spec-015.sh" --profile "${profile}"
    spec015_run_id="$(cat "${PROJECT_ROOT}/.build/contract-reports/spec-015/latest-${profile}.txt")"
    spec015_report_dir="${PROJECT_ROOT}/.build/contract-reports/spec-015/${spec015_run_id}/${profile}"
    product="SignalAnalyzerRaspberryPiARMv6"
    artifact="${PROJECT_ROOT}/.build/raspberry-pi/artifacts/${product}"
    artifact_identity="$(shasum -a 256 "${artifact}" | awk '{print $1}')"
    cp "${spec015_report_dir}/semantic.tsv" \
        "${staging_report_dir}/host-transcript.tsv"
    {
        printf 'schema_version=1\n'
        printf 'spec=SPEC-001\nprofile=%s\n' "${profile}"
        printf 'evidence_kind=%s\n' "${evidence_kind}"
        printf 'repository_revision=%s\nrepository_dirty=%s\n' "${revision}" "${dirty}"
        printf 'source_identity=%s\nfixture_identity=%s\n' "${source_identity}" "${fixture_identity}"
        printf 'compiler_identity=%s\nsdk_identity=raspios-bookworm-armv6\n' "${compiler_identity}"
        printf 'target_triple=%s\noptimization=%s\n' "${target_triple}" "${optimization}"
        printf 'invocation=%s\ncommand_identity=%s\n' "${invocation}" "${command_identity}"
        printf 'artifact_path=%s\nartifact_identity=%s\n' "${artifact}" "${artifact_identity}"
        printf 'remote_access=false\ndeployment=false\nservice_restart=false\n'
        printf 'hardware_probe=false\nflashing=false\nnetwork_access=false\n'
        printf 'status=complete\nblocking_reason=connected-execution-not-collected\n'
    } >"${staging_report_dir}/metadata.txt"
    "${SCRIPT_DIR}/publish-contract-report.rb" \
        --report-root "${REPORT_ROOT}" \
        --staging "${staging_report_dir}" \
        --destination "${canonical_report_dir}" \
        --latest "${latest_report}" \
        --run-id "${run_identity}" >/dev/null
    printf 'SPEC-001 %s complete (cross-build only): %s\n' "${profile}" "${canonical_report_dir}"
    exit 0
fi

if [[ "${profile}" == "nrf52840-embedded" ]]; then
    "${SCRIPT_DIR}/check-spec-001-nrf-touch-input.sh"
    "${SCRIPT_DIR}/check-spec-001-nrf-static-input-bridge.sh"
    "${SCRIPT_DIR}/check-spec-001-nrf-static-touch-pipeline.sh"
    "${SCRIPT_DIR}/check-spec-001-nrf-input-storage-ownership.sh"
    "${SCRIPT_DIR}/run-spec-015.sh" --profile "${profile}"
    spec015_run_id="$(cat "${PROJECT_ROOT}/.build/contract-reports/spec-015/latest-${profile}.txt")"
    spec015_report_dir="${PROJECT_ROOT}/.build/contract-reports/spec-015/${spec015_run_id}/${profile}"
    artifact="${PROJECT_ROOT}/.build/nrf52840/signal-analyzer-static/zephyr/zephyr.elf"
    artifact_identity="$(shasum -a 256 "${artifact}" | awk '{print $1}')"
    cp "${spec015_report_dir}/semantic.tsv" \
        "${staging_report_dir}/host-transcript.tsv"
    cp "${spec015_report_dir}/memory-summary.txt" \
        "${staging_report_dir}/resource-report.txt"
    {
        printf 'schema_version=1\n'
        printf 'spec=SPEC-001\nprofile=%s\n' "${profile}"
        printf 'evidence_kind=%s\n' "${evidence_kind}"
        printf 'repository_revision=%s\nrepository_dirty=%s\n' "${revision}" "${dirty}"
        printf 'source_identity=%s\nfixture_identity=%s\n' "${source_identity}" "${fixture_identity}"
        printf 'compiler_identity=Swift-6.3.2\nsdk_identity=Zephyr-4.3.0-SDK-0.17.4\n'
        printf 'target_triple=%s\noptimization=%s\n' "${target_triple}" "${optimization}"
        printf 'invocation=%s\ncommand_identity=%s\n' "${invocation}" "${command_identity}"
        printf 'artifact_path=%s\nartifact_identity=%s\n' "${artifact}" "${artifact_identity}"
        printf 'remote_access=false\ndeployment=false\nservice_restart=false\n'
        printf 'hardware_probe=false\nflashing=false\nnetwork_access=false\n'
        printf 'status=complete\nblocking_reason=connected-execution-not-collected\n'
    } >"${staging_report_dir}/metadata.txt"
    "${SCRIPT_DIR}/publish-contract-report.rb" \
        --report-root "${REPORT_ROOT}" \
        --staging "${staging_report_dir}" \
        --destination "${canonical_report_dir}" \
        --latest "${latest_report}" \
        --run-id "${run_identity}" >/dev/null
    printf 'SPEC-001 %s complete (cross-build only): %s\n' "${profile}" "${canonical_report_dir}"
    exit 0
fi

{
    printf 'schema_version=1\n'
    printf 'spec=SPEC-001\nprofile=%s\n' "${profile}"
    printf 'evidence_kind=%s\n' "${evidence_kind}"
    printf 'repository_revision=%s\nrepository_dirty=%s\n' "${revision}" "${dirty}"
    printf 'source_identity=%s\nfixture_identity=%s\n' "${source_identity}" "${fixture_identity}"
    printf 'compiler_identity=%s\nsdk_identity=%s\n' "${compiler_identity}" "${sdk_identity}"
    printf 'target_triple=%s\noptimization=%s\n' "${target_triple}" "${optimization}"
    printf 'invocation=%s\ncommand_identity=%s\n' "${invocation}" "${command_identity}"
    printf 'artifact_path=missing\nartifact_identity=missing\n'
    printf 'remote_access=false\ndeployment=false\nservice_restart=false\n'
    printf 'hardware_probe=false\nflashing=false\nnetwork_access=false\n'
    printf 'status=blocked\nblocking_reason=profile-implementation-evidence-missing\n'
} >"${staging_report_dir}/metadata.txt"

"${SCRIPT_DIR}/publish-contract-report.rb" \
    --report-root "${REPORT_ROOT}" \
    --staging "${staging_report_dir}" \
    --destination "${canonical_report_dir}" \
    --latest "${latest_report}" \
    --run-id "${run_identity}" >/dev/null

printf 'SPEC-001 %s remains fail-closed until profile implementation evidence lands; see %s\n' \
    "${profile}" "${canonical_report_dir}" >&2
exit 1
