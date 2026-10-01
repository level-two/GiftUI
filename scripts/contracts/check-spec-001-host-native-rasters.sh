#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
profile=""
candidate_only=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile) profile="$2"; shift 2 ;;
        --candidate-only) candidate_only=true; shift ;;
        *) printf 'unknown argument: %s\n' "$1" >&2; exit 2 ;;
    esac
done
case "${profile}" in
    raspberry-pi-armv6) target=pi ;;
    nrf52840-embedded) target=nrf ;;
    *) printf 'invalid host-native profile: %s\n' "${profile}" >&2; exit 2 ;;
esac

output="${project_root}/.build/contract-generated/spec-001/${target}-raster-gate"
captures="${output}/captures"
images="${output}/images"
references="${project_root}/Tests/ContractFixtures/SPEC001/PixelReferences"
evidence="${project_root}/Tests/ContractFixtures/SPEC001/Evidence/milestone-7"
if [[ "${candidate_only}" == false ]]; then
    states=(idle running-four-traces stopped cleared window-one-second
        window-five-seconds window-two-seconds diagnostic)
    expected_bytes=153600
    [[ "${target}" == pi ]] && expected_bytes=115200
    for state in "${states[@]}"; do
        reference="${references}/${target}-${state}.rgb565"
        [[ -f "${reference}" ]] || {
            printf 'reviewed SPEC-001 pixel reference missing: %s\n' "${reference}" >&2
            exit 1
        }
        actual_bytes="$(wc -c < "${reference}" | tr -d '[:space:]')"
        [[ "${actual_bytes}" == "${expected_bytes}" ]] || {
            printf 'reviewed SPEC-001 pixel reference has %s bytes, expected %s: %s\n' \
                "${actual_bytes}" "${expected_bytes}" "${reference}" >&2
            exit 1
        }
    done
fi
mkdir -p "${captures}" "${images}"

if [[ "${target}" == pi ]]; then
    GIFTUI_REHEARSAL_RASTERS="${captures}" \
        "${project_root}/scripts/contracts/check-spec-001-pi-host-native-rehearsal.sh" \
        > "${output}/normal-trace.tsv"
    GIFTUI_REHEARSAL_FAULT=diagnostic GIFTUI_REHEARSAL_RASTERS="${captures}" \
        "${project_root}/scripts/contracts/check-spec-001-pi-host-native-rehearsal.sh" \
        > "${output}/diagnostic-trace.tsv"
    bash "${project_root}/scripts/contracts/check-spec-001-pi-host-native-faults.sh" \
        > "${output}/fault-results.txt"
    mkdir -p "${output}/faults"
    rm -f "${output}/faults/"*.tsv
    cp "${project_root}/.build/contract-generated/spec-001/pi-host-native-rehearsal/"fault-*.tsv \
        "${output}/faults/"
    ruby "${project_root}/scripts/contracts/compare-spec-001-dynamic-reference.rb" \
        "${evidence}/macos-dynamic-reference-trace.tsv" \
        "${output}/normal-trace.tsv" > "${output}/behavior-comparison.txt"
else
    GIFTUI_REHEARSAL_RASTERS="${captures}" \
        "${project_root}/scripts/contracts/check-spec-001-nrf-host-native-rehearsal.sh" \
        > "${output}/normal-trace.tsv"
    GIFTUI_REHEARSAL_DIAGNOSTIC=1 GIFTUI_REHEARSAL_RASTERS="${captures}" \
        "${project_root}/.build/contract-generated/spec-001/nrf-host-native-rehearsal/host-native-rehearsal" \
        > "${output}/diagnostic-trace.tsv"
    bash "${project_root}/scripts/contracts/check-spec-001-nrf-host-native-faults.sh" \
        > "${output}/fault-results.txt"
    mkdir -p "${output}/faults"
    rm -f "${output}/faults/"*.tsv
    cp "${project_root}/.build/contract-generated/spec-001/nrf-host-native-rehearsal/"fault-*.tsv \
        "${output}/faults/"
    ruby "${project_root}/scripts/contracts/compare-spec-001-static-reference.rb" \
        "${evidence}/macos-static-reference-trace.tsv" \
        "${output}/normal-trace.tsv" > "${output}/behavior-comparison.txt"
fi

arguments=(
    --profile "${target}" --captures "${captures}" --images "${images}"
    --include-diagnostic
)
if [[ "${candidate_only}" == false ]]; then
    arguments+=(--references "${references}")
fi
python3 "${project_root}/scripts/contracts/render-spec-001-rasters.py" \
    "${arguments[@]}" > "${output}/raster-hashes.tsv"
if [[ "${target}" == pi ]]; then
    binary="${project_root}/.build/arm64-apple-macosx/debug/SignalAnalyzerRaspberryPiARMv6"
    substitutions="PiScreen framebuffer sink, decoded touch contacts, deterministic clock"
    diagnostic_command="GIFTUI_REHEARSAL_FAULT=diagnostic scripts/contracts/check-spec-001-pi-host-native-rehearsal.sh"
    source_identity="$(shasum -a 256 \
        "${project_root}/Sources/SignalAnalyzerRaspberryPiARMv6/PiHostNativeRehearsal.swift" \
        "${project_root}/Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPiLifecycleOwner.swift" \
        "${project_root}/Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPresentationPipeline.swift" \
        "${project_root}/Sources/GiftUIReferenceTextResources/GiftUIReferenceTextResources.swift" \
        "${project_root}/Sources/GiftUIReferenceTextResources/Generated/ReferenceCatalogue.generated.swift" \
        "${project_root}/Sources/GiftUIReferenceTextResources/Generated/ReferenceBitmapPayload.generated.swift" \
        "${project_root}/Sources/SignalAnalyzerPresentation/SignalAnalyzerView.swift" \
        | shasum -a 256 | awk '{print $1}')"
else
    binary="${project_root}/.build/contract-generated/spec-001/nrf-host-native-rehearsal/host-native-rehearsal"
    substitutions="direct SPI TFT write callback, ADS7846 callbacks, deterministic clock"
    diagnostic_command="GIFTUI_REHEARSAL_DIAGNOSTIC=1 ${binary}"
    source_identity="$(shasum -a 256 \
        "${project_root}/firmware/nrf52840/applications/signal-analyzer-static/src/StaticPreset.swift" \
        "${project_root}/firmware/nrf52840/applications/signal-analyzer-static/src/production_host.c" \
        "${project_root}/firmware/nrf52840/applications/signal-analyzer-static/tests/host_native_rehearsal.c" \
        "${project_root}/firmware/nrf52840/applications/signal-analyzer-static/tests/host_native_rehearsal_hooks.swift" \
        | shasum -a 256 | awk '{print $1}')"
fi
{
    printf 'repository_revision=%s\n' "$(git -C "${project_root}" rev-parse HEAD)"
    printf 'repository_dirty=%s\n' "$([[ -z "$(git -C "${project_root}" status --porcelain)" ]] && echo false || echo true)"
    printf 'host_binary=%s\n' "${binary}"
    printf 'host_binary_sha256=%s\n' "$(shasum -a 256 "${binary}" | awk '{print $1}')"
    printf 'source_identity=%s\n' "${source_identity}"
    printf 'substituted_boundaries=%s\n' "${substitutions}"
    printf 'normal_command=%s\n' "scripts/contracts/check-spec-001-${target}-host-native-rehearsal.sh"
    printf 'diagnostic_command=%s\n' "${diagnostic_command}"
    printf 'raster_renderer_sha256=%s\n' "$(shasum -a 256 "${project_root}/scripts/contracts/render-spec-001-rasters.py" | awk '{print $1}')"
} > "${output}/identities.txt"
printf 'SPEC-001 %s host-native rasters %s: %s\n' \
    "${target}" "$([[ "${candidate_only}" == true ]] && echo candidates || echo matched)" \
    "${output}"
