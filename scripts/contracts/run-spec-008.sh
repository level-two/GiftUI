#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE")" && pwd -P)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
FIXTURE_ROOT="$PROJECT_ROOT/Tests/ContractFixtures/SPEC008"
REPORT_ROOT="$PROJECT_ROOT/.build/contract-reports/spec-008"

usage() {
    printf '%s\n' \
        'Usage: scripts/contracts/run-spec-008.sh --profile <profile>' \
        '' \
        'Profiles: macos-dynamic, macos-static, raspberry-pi-armv6, nrf52840-embedded'
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
        -h | --help) usage; exit 0 ;;
        *) fail "unknown option: $1" ;;
    esac
done
case "$profile" in
    macos-dynamic | macos-static | raspberry-pi-armv6 | nrf52840-embedded) ;;
    "") fail '--profile is required' ;;
    *) fail "unknown profile: $profile" ;;
esac

declared_inputs() {
    {
        find "$PROJECT_ROOT/Sources/GiftUI" \
            "$PROJECT_ROOT/Sources/GiftUIRenderFailureAdapterFixture" \
            "$PROJECT_ROOT/Sources/GiftUIRenderLowering" \
            "$PROJECT_ROOT/Tests/GiftUITests" \
            "$PROJECT_ROOT/Tests/GiftUIRenderFailureAdapterTests" \
            "$PROJECT_ROOT/Tests/GiftUIRenderLoweringTests" \
            "$PROJECT_ROOT/Tests/GiftUISemanticCoreTests" \
            "$PROJECT_ROOT/firmware/nrf52840/applications/spec008-render-probe" \
            "$FIXTURE_ROOT" -type f -print
        printf '%s\n' \
            "$PROJECT_ROOT/Package.swift" \
            "$PROJECT_ROOT/Tests/ContractFixtures/SPEC002/Instrumentation/AllocationInterposer.c" \
            "$PROJECT_ROOT/Tests/ContractFixtures/SPEC002/target-dependencies.yaml" \
            "$PROJECT_ROOT/docs/specs/spec-008-rendering.md" \
            "$PROJECT_ROOT/docs/implementation-plans/spec-008-implementation-plan.md" \
            "$PROJECT_ROOT/Sources/GiftUISemanticCore/SemanticLayoutView.swift" \
            "$PROJECT_ROOT/Sources/GiftUISemanticCore/SemanticRenderView.swift" \
            "$PROJECT_ROOT/Sources/GiftUILayout/ResolvedRenderLayoutView.swift" \
            "$PROJECT_ROOT/Tests/GiftUILayoutTests/ResolvedRenderLayoutViewTests.swift" \
            "$PROJECT_ROOT/Tests/GiftUIRenderLoweringTests/RenderViewBorrowTests.swift" \
            "$PROJECT_ROOT/scripts/contracts/driver-registry.tsv" \
            "$SCRIPT_DIR/check-spec-008-harness.rb" \
            "$SCRIPT_DIR/check-spec-008-migration.rb" \
            "$SCRIPT_DIR/check-spec-008-render-core-values.rb" \
            "$SCRIPT_DIR/check-spec-008-render-production-values.rb" \
            "$SCRIPT_DIR/check-spec-008-render-preflight.rb" \
            "$SCRIPT_DIR/check-spec-008-render-streaming.rb" \
            "$SCRIPT_DIR/check-spec-008-render-producer-lifecycle.rb" \
            "$SCRIPT_DIR/check-spec-008-render-failure-adapter.rb" \
            "$SCRIPT_DIR/check-spec-008-painter-order.rb" \
            "$SCRIPT_DIR/check-spec-008-text-lowering.rb" \
            "$SCRIPT_DIR/check-spec-008-clip-damage.rb" \
            "$SCRIPT_DIR/check-spec-008-foreground-semantics.rb" \
            "$SCRIPT_DIR/check-spec-008-failure-precedence.rb" \
            "$SCRIPT_DIR/check-spec-008-canonical-corpus.rb" \
            "$SCRIPT_DIR/check-spec-008-text-integration.rb" \
            "$SCRIPT_DIR/check-spec-008-failure-corpus.rb" \
            "$SCRIPT_DIR/check-spec-008-render-operation-sink.rb" \
            "$SCRIPT_DIR/check-spec-008-recording-sink.rb" \
            "$SCRIPT_DIR/check-spec-008-recording-verification.rb" \
            "$SCRIPT_DIR/check-spec-008-semantic-render-view.rb" \
            "$SCRIPT_DIR/check-spec-008-resolved-render-layout-view.rb" \
            "$SCRIPT_DIR/check-spec-008-direct-render-views.rb" \
            "$SCRIPT_DIR/check-spec-008-render-view-boundaries.rb" \
            "$SCRIPT_DIR/check-spec-008-render-view-static-exposure.sh" \
            "$SCRIPT_DIR/check-spec-008-render-work.rb" \
            "$SCRIPT_DIR/check-spec-008-render-resource-ir.rb" \
            "$SCRIPT_DIR/check-spec-008-profile-equivalence.rb" \
            "$SCRIPT_DIR/check-spec-008-package-boundaries.rb" \
            "$SCRIPT_DIR/check-spec-008-signal-analyzer.rb" \
            "$SCRIPT_DIR/check-spec-008-consumer-seams.rb" \
            "$SCRIPT_DIR/check-spec-008-canvas-coexistence.rb" \
            "$SCRIPT_DIR/check-spec-008-button-coexistence.rb" \
            "$SCRIPT_DIR/collect-spec-008-macos-render-evidence.sh" \
            "$SCRIPT_DIR/collect-spec-008-armv6-render-evidence.sh" \
            "$SCRIPT_DIR/collect-spec-008-nrf-render-evidence.sh" \
            "$SCRIPT_DIR/report-spec-008-render-evidence.rb" \
            "$SCRIPT_DIR/report-spec-002-linked-sections.rb" \
            "$SCRIPT_DIR/check-spec-008-value-layouts.rb" \
            "$SCRIPT_DIR/check-spec-008-value-profiles.sh" \
            "$SCRIPT_DIR/check-spec-008-declaration-profiles.sh" \
            "$SCRIPT_DIR/check-spec-008-color-surface.sh" \
            "$SCRIPT_DIR/check-spec-008-bounded-text-surface.sh" \
            "$SCRIPT_DIR/check-spec-008-text-surface.sh" \
            "$SCRIPT_DIR/check-spec-008-style-surface.sh" \
            "$SCRIPT_DIR/report-input-identity.rb" \
            "$SCRIPT_DIR/publish-contract-report.rb" \
            "$SCRIPT_DIR/verify-contract-report.rb" \
            "$SCRIPT_DIR/run-spec-008.sh"
    } | LC_ALL=C sort -u
}

revision="$(git -C "$PROJECT_ROOT" rev-parse HEAD)"
dirty=false
[[ -z "$(git -C "$PROJECT_ROOT" status --porcelain --untracked-files=normal)" ]] || dirty=true
mkdir -p "$REPORT_ROOT"
report_dir="$REPORT_ROOT/.tmp-$profile-$$"
[[ ! -e "$report_dir" ]] || fail "temporary report directory exists: $report_dir"
mkdir -p "$report_dir"
inputs_path="$report_dir/input-hashes.tsv"
identity_metadata="$(declared_inputs | "$SCRIPT_DIR/report-input-identity.rb" \
    --root "$PROJECT_ROOT" --revision "$revision" --inventory "$inputs_path")"
input_set_sha256="$(printf '%s\n' "$identity_metadata" | awk -F= '$1 == "input_set_sha256" { print $2 }')"
run_id="$(printf '%s\n' "$identity_metadata" | awk -F= '$1 == "run_id" { print $2 }')"
[[ -n "$input_set_sha256" && -n "$run_id" ]] || fail 'input identity calculation failed'
canonical_report_dir="$REPORT_ROOT/$run_id/$profile"
latest_pointer="$REPORT_ROOT/latest-$profile.txt"
if [[ -d "$canonical_report_dir" ]]; then
    "$SCRIPT_DIR/verify-contract-report.rb" "$canonical_report_dir"
    rm -rf "$report_dir"
    temporary_pointer="$REPORT_ROOT/.latest-$profile.tmp-$$"
    printf '%s\n' "$run_id" >"$temporary_pointer"
    mv "$temporary_pointer" "$latest_pointer"
    printf 'SPEC-008 %s harness idempotent match; run ID: %s\n' "$profile" "$run_id"
    exit 0
fi

metadata_path="$report_dir/metadata.txt"
commands_path="$report_dir/commands.txt"
images_path="$report_dir/image-hashes.tsv"
evidence_path="$report_dir/required-evidence.tsv"
prerequisites_path="$report_dir/prerequisites.tsv"
log_path="$report_dir/run.log"
: >"$commands_path"
printf '# label\tpath\tsha256\n' >"$images_path"
: >"$log_path"
{
    printf 'schema_version=1\nspec=SPEC-008\nprofile=%s\n' "$profile"
    printf 'repository_revision=%s\nrepository_dirty=%s\n' "$revision" "$dirty"
    printf 'input_set_sha256=%s\nrun_id=%s\n' "$input_set_sha256" "$run_id"
    printf 'invocation=scripts/contracts/run-spec-008.sh --profile %s\n' "$profile"
    printf 'render_core_target=complete\nrender_lowering_target=complete\n'
    printf 'declaration_profiles=pending\n'
    printf 'fixture_corpus=complete\nevidence_complete=false\n'
    printf 'remote_access=false\ndeployment=false\nservice_restart=false\n'
    printf 'simulator_execution=false\nconnected_target_execution=false\nflashing=false\n'
} >"$metadata_path"

finish() {
    result=$?
    printf 'exit_code=%s\n' "$result" >>"$metadata_path"
    [[ "$result" -eq 0 ]] ||
        printf 'SPEC-008 %s harness failed; see %s\n' "$profile" "$report_dir" >&2
}
trap finish EXIT

record_command() {
    printf '%q ' "$@" >>"$commands_path"
    printf '\n' >>"$commands_path"
}

hash_file() {
    shasum -a 256 "$1" | awk '{print $1}'
}

record_compiler() {
    compiler="$1"
    [[ -x "$compiler" ]] || fail "compiler is not executable: $compiler"
    record_command "$compiler" --version
    version="$("$compiler" --version 2>&1)"
    printf 'compiler_path=%s\ncompiler_sha256=%s\n' \
        "$compiler" "$(hash_file "$compiler")" >>"$metadata_path"
    printf 'compiler_version<<EOF\n%s\nEOF\n' "$version" >>"$metadata_path"
}

record_macos_identity() {
    [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "arm64" ]] ||
        fail 'macOS profiles require an arm64 macOS host'
    compiler="$(xcrun --find swiftc)"
    version="$("$compiler" --version 2>&1)"
    [[ "$version" == *'Apple Swift version 6.3.3'* && "$version" == *'swiftlang-6.3.3.1.3'* ]] ||
        fail 'macOS compiler identity differs from SPEC-002'
    sdk="$(xcrun --sdk macosx --show-sdk-path)"
    [[ -d "$sdk" ]] || fail "macOS SDK is missing: $sdk"
    profile_flag=-DGIFTUI_STATIC_PROFILE
    [[ "$profile" != "macos-dynamic" ]] || profile_flag=-DGIFTUI_DYNAMIC_PROFILE
    record_compiler "$compiler"
    record_command xcrun --sdk macosx --show-sdk-path
    printf 'target=arm64-apple-macosx26.0\nsdk_path=%s\n' "$sdk" >>"$metadata_path"
    printf 'optimization=-O -whole-module-optimization\nprofile_flag=%s\n' \
        "$profile_flag" >>"$metadata_path"
}

record_raspberry_pi_identity() {
    source "$PROJECT_ROOT/scripts/raspberry-pi/common.sh"
    swift_driver="$(giftui_pi_host_swift)"
    compiler="$(dirname "$swift_driver")/swiftc"
    giftui_pi_require_sdk
    record_command "$PROJECT_ROOT/scripts/raspberry-pi/doctor.sh"
    "$PROJECT_ROOT/scripts/raspberry-pi/doctor.sh" >>"$log_path" 2>&1
    version="$("$compiler" --version 2>&1)"
    [[ "$version" == *"Swift version $GIFTUI_PI_SWIFT_VERSION"* ]] ||
        fail 'Raspberry Pi compiler identity differs from SPEC-002'
    grep -Fq "\"target\":\"$GIFTUI_PI_TARGET\"" "$GIFTUI_PI_STATIC_DESTINATION" ||
        fail 'Raspberry Pi destination target differs from its pin'
    record_compiler "$compiler"
    printf 'target=%s\nsdk_path=%s\ndestination=%s\n' \
        "$GIFTUI_PI_TARGET" "$GIFTUI_PI_SDK_DIR" "$GIFTUI_PI_STATIC_DESTINATION" >>"$metadata_path"
    printf 'optimization=-O -whole-module-optimization\n' >>"$metadata_path"
}

record_nrf52840_identity() {
    source "$PROJECT_ROOT/scripts/nrf52840/common.sh"
    giftui_nrf_require_environment
    record_command "$PROJECT_ROOT/scripts/nrf52840/doctor.sh"
    "$PROJECT_ROOT/scripts/nrf52840/doctor.sh" >>"$log_path" 2>&1
    version="$("$GIFTUI_NRF_SWIFTC" --version 2>&1)"
    [[ "$version" == *"Swift version $GIFTUI_NRF_SWIFT_VERSION"* ]] ||
        fail 'nRF compiler identity differs from SPEC-002'
    [[ "$(giftui_nrf_git_revision "$GIFTUI_NRF_ZEPHYR_BASE")" == "$GIFTUI_NRF_ZEPHYR_REVISION" ]] ||
        fail 'Zephyr revision differs from its pin'
    record_compiler "$GIFTUI_NRF_SWIFTC"
    printf 'target=%s\nboard=%s\nsdk_path=%s\nzephyr_revision=%s\n' \
        "$GIFTUI_NRF_SWIFT_TARGET" "$GIFTUI_NRF_BOARD" "$GIFTUI_NRF_SDK_DIR" \
        "$GIFTUI_NRF_ZEPHYR_REVISION" >>"$metadata_path"
    printf 'optimization=-Osize -whole-module-optimization\nfloat_abi=hard\n' >>"$metadata_path"
}

{
    printf '# criterion\tstatus\treason\n'
    awk -F $'\t' '!/^#/ && NF {
        status = ($1 == "RD-007" || $1 == "RD-008" || $1 == "RD-011") ? "active" : "pass"
        print $1 "\t" status "\t" $3
    }' \
        "$FIXTURE_ROOT/required-evidence.tsv"
} >"$evidence_path"
{
    printf '# item\tstatus\treason\n'
    printf 'compiler-identity\tcomplete\tSPEC-002 pinned compiler recorded\n'
    printf 'target-sdk-identity\tcomplete\tSPEC-002 target and SDK identity recorded\n'
    printf 'optimization\tcomplete\tSPEC-002 profile optimization recorded\n'
    printf 'repository-revision\tcomplete\trevision and input digest recorded\n'
    printf 'command-transcript\tcomplete\texact invoked checks recorded\n'
    printf 'fixture-digest\tcomplete\tdeclared inputs and fixture digest recorded\n'
    printf 'declaration-fixtures\tcomplete\tall 17 fixtures compile as expected for the selected profile\n'
    printf 'render-targets\tcomplete\tRender Core, lowering, and profile evidence images are complete\n'
    printf 'value-layouts\tcomplete\tall 13 bounded values pass exact or maximum layouts for this profile\n'
    printf 'result-comparison\tcomplete\tcanonical three-path fixture results match within this profile\n'
    printf 'transcript-comparison\tcomplete\tcanonical recording, dynamic, and static value events match within this profile\n'
    printf 'high-water\tcomplete\tdeclared and observed Signal Analyzer high-water values are recorded\n'
    printf 'allocation\tcomplete\tpost-warmup macOS counts or optimized cross-target SIL counts are recorded\n'
    printf 'workspace\tcomplete\tlogical capacities and concrete finite workspace bytes are recorded\n'
    printf 'stack\tcomplete\tmaximum recursive traversal frames and foreground slots are recorded\n'
    printf 'timing\tcomplete\tContinuousClock samples or explicit cross-build non-execution disposition is recorded\n'
    printf 'section-delta\tcomplete\tlinked baseline/render section deltas are recorded\n'
    printf 'link-map\tcomplete\tbaseline and render image link maps are recorded\n'
    printf 'target-inspection\tcomplete\tMach-O, ARMv6 ELF, or Cortex-M4F hard-float ELF image is recorded\n'
    printf 'acceptance-evidence\tactive\tRD-001 through RD-006 and RD-009 through RD-010 pass; RD-007, RD-008, and RD-011 await T8.3 through T8.5\n'
} >"$prerequisites_path"

record_command "$SCRIPT_DIR/check-spec-008-harness.rb"
"$SCRIPT_DIR/check-spec-008-harness.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-migration.rb"
"$SCRIPT_DIR/check-spec-008-migration.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-render-core-values.rb"
"$SCRIPT_DIR/check-spec-008-render-core-values.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-render-production-values.rb"
"$SCRIPT_DIR/check-spec-008-render-production-values.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-render-preflight.rb"
"$SCRIPT_DIR/check-spec-008-render-preflight.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-render-streaming.rb"
"$SCRIPT_DIR/check-spec-008-render-streaming.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-render-producer-lifecycle.rb"
"$SCRIPT_DIR/check-spec-008-render-producer-lifecycle.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-render-failure-adapter.rb"
"$SCRIPT_DIR/check-spec-008-render-failure-adapter.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-painter-order.rb"
"$SCRIPT_DIR/check-spec-008-painter-order.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-text-lowering.rb"
"$SCRIPT_DIR/check-spec-008-text-lowering.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-clip-damage.rb"
"$SCRIPT_DIR/check-spec-008-clip-damage.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-foreground-semantics.rb"
"$SCRIPT_DIR/check-spec-008-foreground-semantics.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-failure-precedence.rb"
"$SCRIPT_DIR/check-spec-008-failure-precedence.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-canonical-corpus.rb"
"$SCRIPT_DIR/check-spec-008-canonical-corpus.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-text-integration.rb"
"$SCRIPT_DIR/check-spec-008-text-integration.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-failure-corpus.rb"
"$SCRIPT_DIR/check-spec-008-failure-corpus.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-render-operation-sink.rb"
"$SCRIPT_DIR/check-spec-008-render-operation-sink.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-recording-sink.rb"
"$SCRIPT_DIR/check-spec-008-recording-sink.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-recording-verification.rb"
"$SCRIPT_DIR/check-spec-008-recording-verification.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-semantic-render-view.rb"
"$SCRIPT_DIR/check-spec-008-semantic-render-view.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-resolved-render-layout-view.rb"
"$SCRIPT_DIR/check-spec-008-resolved-render-layout-view.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-direct-render-views.rb"
"$SCRIPT_DIR/check-spec-008-direct-render-views.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-render-view-boundaries.rb"
"$SCRIPT_DIR/check-spec-008-render-view-boundaries.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-render-work.rb"
"$SCRIPT_DIR/check-spec-008-render-work.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-profile-equivalence.rb"
"$SCRIPT_DIR/check-spec-008-profile-equivalence.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-package-boundaries.rb"
"$SCRIPT_DIR/check-spec-008-package-boundaries.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-signal-analyzer.rb"
"$SCRIPT_DIR/check-spec-008-signal-analyzer.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-consumer-seams.rb"
"$SCRIPT_DIR/check-spec-008-consumer-seams.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-canvas-coexistence.rb"
"$SCRIPT_DIR/check-spec-008-canvas-coexistence.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-008-button-coexistence.rb"
"$SCRIPT_DIR/check-spec-008-button-coexistence.rb" >>"$log_path" 2>&1
case "$profile" in
    macos-dynamic | macos-static) record_macos_identity ;;
    raspberry-pi-armv6) record_raspberry_pi_identity ;;
    nrf52840-embedded) record_nrf52840_identity ;;
esac
render_evidence_dir="$report_dir/render-evidence"
record_command "$SCRIPT_DIR/report-spec-008-render-evidence.rb" \
    "$profile" "$render_evidence_dir"
"$SCRIPT_DIR/report-spec-008-render-evidence.rb" \
    "$profile" "$render_evidence_dir" >>"$log_path" 2>&1
for evidence_file in \
    signal-analyzer-high-water.tsv workspace.tsv stack-high-water.tsv timing-method.tsv; do
    printf '%s\t%s\t%s\n' \
        "render-${evidence_file%.tsv}" \
        "${render_evidence_dir#"$PROJECT_ROOT/"}/$evidence_file" \
        "$(hash_file "$render_evidence_dir/$evidence_file")" >>"$images_path"
done
if [[ "$profile" == macos-* ]]; then
    image_evidence_dir="$report_dir/render-image"
    record_command "$SCRIPT_DIR/collect-spec-008-macos-render-evidence.sh" \
        "$profile" "$image_evidence_dir"
    "$SCRIPT_DIR/collect-spec-008-macos-render-evidence.sh" \
        "$profile" "$image_evidence_dir" >>"$log_path" 2>&1
    for evidence_file in \
        runtime.txt allocation.tsv timing-samples.tsv concrete-workspace.tsv \
        linked-section-deltas.tsv baseline.map render-probe.map render-probe symbols.txt; do
        printf '%s\t%s\t%s\n' \
            "render-image-${evidence_file//./-}" \
            "${image_evidence_dir#"$PROJECT_ROOT/"}/$evidence_file" \
            "$(hash_file "$image_evidence_dir/$evidence_file")" >>"$images_path"
    done
elif [[ "$profile" == "raspberry-pi-armv6" ]]; then
    image_evidence_dir="$report_dir/render-image"
    record_command "$SCRIPT_DIR/collect-spec-008-armv6-render-evidence.sh" \
        "$image_evidence_dir"
    "$SCRIPT_DIR/collect-spec-008-armv6-render-evidence.sh" \
        "$image_evidence_dir" >>"$log_path" 2>&1
    for evidence_file in \
        allocation.tsv concrete-workspace.tsv linked-section-deltas.tsv \
        baseline.map render-probe.map render-probe symbols.txt; do
        printf '%s\t%s\t%s\n' \
            "render-image-${evidence_file//./-}" \
            "${image_evidence_dir#"$PROJECT_ROOT/"}/$evidence_file" \
            "$(hash_file "$image_evidence_dir/$evidence_file")" >>"$images_path"
    done
elif [[ "$profile" == "nrf52840-embedded" ]]; then
    image_evidence_dir="$report_dir/render-image"
    record_command "$SCRIPT_DIR/collect-spec-008-nrf-render-evidence.sh" \
        "$image_evidence_dir"
    "$SCRIPT_DIR/collect-spec-008-nrf-render-evidence.sh" \
        "$image_evidence_dir" >>"$log_path" 2>&1
    for evidence_file in \
        allocation.tsv concrete-workspace.tsv linked-section-deltas.tsv \
        baseline.map candidate.map candidate symbols.txt arm-attributes.txt; do
        printf '%s\t%s\t%s\n' \
            "render-image-${evidence_file//./-}" \
            "${image_evidence_dir#"$PROJECT_ROOT/"}/$evidence_file" \
            "$(hash_file "$image_evidence_dir/$evidence_file")" >>"$images_path"
    done
fi
declaration_dir="$report_dir/declarations"
record_command "$SCRIPT_DIR/check-spec-008-declaration-profiles.sh" \
    --profile "$profile" --output "$declaration_dir"
"$SCRIPT_DIR/check-spec-008-declaration-profiles.sh" \
    --profile "$profile" --output "$declaration_dir" >>"$log_path" 2>&1
printf 'declaration_profiles=complete\n' >>"$metadata_path"
printf '%s\t%s\t%s\n' \
    declaration-fixture-results \
    "${declaration_dir#"$PROJECT_ROOT/"}/results.tsv" \
    "$(hash_file "$declaration_dir/results.tsv")" >>"$images_path"
printf '%s\t%s\t%s\n' \
    declaration-module \
    "${declaration_dir#"$PROJECT_ROOT/"}/modules/GiftUI.swiftmodule" \
    "$(hash_file "$declaration_dir/modules/GiftUI.swiftmodule")" >>"$images_path"
if [[ "$profile" == macos-* ]]; then
    printf '%s\t%s\t%s\n' \
        declaration-runtime \
        "${declaration_dir#"$PROJECT_ROOT/"}/runtime.txt" \
        "$(hash_file "$declaration_dir/runtime.txt")" >>"$images_path"
fi
if [[ "$profile" == "macos-static" ]]; then
    record_command "$SCRIPT_DIR/check-spec-008-render-view-static-exposure.sh"
    "$SCRIPT_DIR/check-spec-008-render-view-static-exposure.sh" >>"$log_path" 2>&1
fi
value_layout_dir="$report_dir/value-layouts"
record_command "$SCRIPT_DIR/check-spec-008-value-profiles.sh" \
    --profile "$profile" --output "$value_layout_dir"
"$SCRIPT_DIR/check-spec-008-value-profiles.sh" \
    --profile "$profile" --output "$value_layout_dir" >>"$log_path" 2>&1
printf '%s\t%s\t%s\n' \
    render-value-layouts \
    "${value_layout_dir#"$PROJECT_ROOT/"}/render-value-layouts.tsv" \
    "$(hash_file "$value_layout_dir/render-value-layouts.tsv")" >>"$images_path"
printf '%s\t%s\t%s\n' \
    render-value-layout-identity \
    "${value_layout_dir#"$PROJECT_ROOT/"}/identity.tsv" \
    "$(hash_file "$value_layout_dir/identity.tsv")" >>"$images_path"
record_command "$SCRIPT_DIR/check-spec-008-harness.rb" "$report_dir"
"$SCRIPT_DIR/check-spec-008-harness.rb" "$report_dir" >>"$log_path" 2>&1
printf 'exit_code=0\n' >>"$metadata_path"
trap - EXIT
"$SCRIPT_DIR/publish-contract-report.rb" \
    --report-root "$REPORT_ROOT" \
    --staging "$report_dir" \
    --destination "$canonical_report_dir" \
    --latest "$latest_pointer" \
    --run-id "$run_id"
printf 'SPEC-008 %s harness passed; profile evidence captured; run ID: %s\n' \
    "$profile" "$run_id"
