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
            "$SCRIPT_DIR/check-spec-008-render-operation-sink.rb" \
            "$SCRIPT_DIR/check-spec-008-recording-sink.rb" \
            "$SCRIPT_DIR/check-spec-008-recording-verification.rb" \
            "$SCRIPT_DIR/check-spec-008-semantic-render-view.rb" \
            "$SCRIPT_DIR/check-spec-008-resolved-render-layout-view.rb" \
            "$SCRIPT_DIR/check-spec-008-direct-render-views.rb" \
            "$SCRIPT_DIR/check-spec-008-render-view-boundaries.rb" \
            "$SCRIPT_DIR/check-spec-008-render-view-static-exposure.sh" \
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
    printf 'render_core_target=complete\nrender_lowering_target=active\n'
    printf 'declaration_profiles=pending\n'
    printf 'fixture_corpus=missing\nevidence_complete=false\n'
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
    awk -F $'\t' '!/^#/ && NF { print $1 "\tmissing\t" $3 }' \
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
    printf 'render-targets\tactive\tRender Core is complete; Render Lowering preflight is complete while streaming and owner adaptation remain pending\n'
    printf 'value-layouts\tcomplete\tall 13 bounded values pass exact or maximum layouts for this profile\n'
    printf 'result-comparison\tmissing\tcanonical normalized results are not implemented\n'
    printf 'transcript-comparison\tmissing\tcanonical recording transcripts are not implemented\n'
    printf 'high-water\tmissing\tdeclared and observed high-water values are unavailable\n'
    printf 'allocation\tmissing\tstatic rendering path is not implemented\n'
    printf 'workspace\tmissing\trender production workspace is not implemented\n'
    printf 'stack\tmissing\trender production stack measurement is unavailable\n'
    printf 'timing\tmissing\trender production timing sample is unavailable\n'
    printf 'section-delta\tmissing\trender target image is unavailable\n'
    printf 'link-map\tmissing\trender target image is unavailable\n'
    printf 'target-inspection\tblocked\tno render target ELF or Mach-O image exists\n'
    printf 'acceptance-evidence\tmissing\tRD-001 through RD-011 remain pending\n'
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
case "$profile" in
    macos-dynamic | macos-static) record_macos_identity ;;
    raspberry-pi-armv6) record_raspberry_pi_identity ;;
    nrf52840-embedded) record_nrf52840_identity ;;
esac
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
printf 'SPEC-008 %s harness passed; rendering implementation incomplete; run ID: %s\n' \
    "$profile" "$run_id"
