#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE")" && pwd -P)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
FIXTURE_ROOT="$PROJECT_ROOT/Tests/ContractFixtures/SPEC012"
REPORT_ROOT="$PROJECT_ROOT/.build/contract-reports/spec-012"

usage() {
    printf '%s\n' \
        'Usage: scripts/contracts/run-spec-012.sh --profile <profile>' \
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
        find "$FIXTURE_ROOT" \
            "$PROJECT_ROOT/Sources/GiftUI" \
            "$PROJECT_ROOT/Sources/GiftUIDrawing" \
            "$PROJECT_ROOT/Sources/GiftUIDrawingFailureAdapterFixture" \
            "$PROJECT_ROOT/Sources/GiftUIRenderCore" \
            "$PROJECT_ROOT/Tests/GiftUIDrawingTests" -type f -print
        printf '%s\n' \
            "$PROJECT_ROOT/Package.swift" \
            "$PROJECT_ROOT/Tests/ContractFixtures/SPEC002/target-dependencies.yaml" \
            "$PROJECT_ROOT/docs/specs/spec-012-canvas-path-stroke-drawing.md" \
            "$PROJECT_ROOT/docs/implementation-plans/spec-012-implementation-plan.md" \
            "$PROJECT_ROOT/scripts/contracts/driver-registry.tsv" \
            "$SCRIPT_DIR/check-driver-registry.rb" \
            "$SCRIPT_DIR/check-spec-012-harness.rb" \
            "$SCRIPT_DIR/check-spec-012-declarations.sh" \
            "$SCRIPT_DIR/check-spec-012-value-layouts.rb" \
            "$SCRIPT_DIR/check-spec-012-value-profiles.sh" \
            "$SCRIPT_DIR/check-spec-012-migration.rb" \
            "$SCRIPT_DIR/check-spec-012-module-contract.rb" \
            "$SCRIPT_DIR/check-spec-012-raster-vectors.rb" \
            "$SCRIPT_DIR/check-spec-012-static-canvas-manifest.rb" \
            "$SCRIPT_DIR/check-target-dependencies.rb" \
            "$SCRIPT_DIR/report-input-identity.rb" \
            "$SCRIPT_DIR/publish-contract-report.rb" \
            "$SCRIPT_DIR/verify-contract-report.rb" \
            "$SCRIPT_DIR/run-spec-012.sh"
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
    printf 'SPEC-012 %s harness idempotent match; run ID: %s\n' "$profile" "$run_id"
    exit 0
fi

metadata_path="$report_dir/metadata.txt"
commands_path="$report_dir/commands.txt"
evidence_path="$report_dir/required-evidence.tsv"
prerequisites_path="$report_dir/prerequisites.tsv"
log_path="$report_dir/run.log"
: >"$commands_path"
: >"$log_path"
{
    printf 'schema_version=1\nspec=SPEC-012\nprofile=%s\n' "$profile"
    printf 'repository_revision=%s\nrepository_dirty=%s\n' "$revision" "$dirty"
    printf 'input_set_sha256=%s\nrun_id=%s\n' "$input_set_sha256" "$run_id"
    printf 'invocation=scripts/contracts/run-spec-012.sh --profile %s\n' "$profile"
    printf 'fixture_schema=complete\nfixture_corpus=pending\nevidence_complete=false\n'
    printf 'remote_access=false\ndeployment=false\nservice_restart=false\n'
    printf 'simulator_execution=false\nconnected_target_execution=false\nflashing=false\n'
} >"$metadata_path"

finish() {
    result=$?
    printf 'exit_code=%s\n' "$result" >>"$metadata_path"
    [[ "$result" -eq 0 ]] ||
        printf 'SPEC-012 %s harness failed; see %s\n' "$profile" "$report_dir" >&2
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
    printf 'optimization\tcomplete\tprofile optimization recorded\n'
    printf 'command-transcript\tcomplete\texact invoked checks recorded\n'
    printf 'repository-revision\tcomplete\trevision and input digest recorded\n'
    printf 'fixture-schema\tcomplete\tSPEC-012 frozen schemas validated\n'
    printf 'raster-oracle\tcomplete\tindependent Q160 widened-integer masks and exact encodings validated\n'
    printf 'fixture-corpus\tpending\tbehavioral cases land with their owning tasks\n'
    printf 'target-graph\tcomplete\tGiftUIDrawing ownership boundary is acyclic\n'
    printf 'profile-implementation\tpending\tpublic drawing behavior and profile evidence remain open\n'
    printf 'backend-evidence\tblocked\tconcrete raster evidence waits for SPEC-014\n'
    printf 'acceptance-evidence\tmissing\tDR-001 through DR-013 remain pending\n'
} >"$prerequisites_path"

record_command "$SCRIPT_DIR/check-spec-012-harness.rb"
"$SCRIPT_DIR/check-spec-012-harness.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-012-migration.rb"
"$SCRIPT_DIR/check-spec-012-migration.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-012-raster-vectors.rb"
"$SCRIPT_DIR/check-spec-012-raster-vectors.rb" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-012-static-canvas-manifest.rb"
"$SCRIPT_DIR/check-spec-012-static-canvas-manifest.rb" >>"$log_path" 2>&1
record_command swift package dump-package
swift package dump-package | "$SCRIPT_DIR/check-target-dependencies.rb" >>"$log_path" 2>&1
case "$profile" in
    macos-dynamic | macos-static) record_macos_identity ;;
    raspberry-pi-armv6) record_raspberry_pi_identity ;;
    nrf52840-embedded) record_nrf52840_identity ;;
esac
record_command "$SCRIPT_DIR/check-spec-012-declarations.sh" \
    --profile "$profile" --output "$report_dir/declarations"
"$SCRIPT_DIR/check-spec-012-declarations.sh" \
    --profile "$profile" --output "$report_dir/declarations" >>"$log_path" 2>&1
record_command "$SCRIPT_DIR/check-spec-012-value-profiles.sh" \
    --profile "$profile" --output "$report_dir/value-layouts"
"$SCRIPT_DIR/check-spec-012-value-profiles.sh" \
    --profile "$profile" --output "$report_dir/value-layouts" >>"$log_path" 2>&1

printf 'exit_code=0\n' >>"$metadata_path"
trap - EXIT
record_command "$SCRIPT_DIR/check-spec-012-harness.rb" "$report_dir"
"$SCRIPT_DIR/check-spec-012-harness.rb" "$report_dir" >>"$log_path" 2>&1
"$SCRIPT_DIR/publish-contract-report.rb" \
    --report-root "$REPORT_ROOT" \
    --staging "$report_dir" \
    --destination "$canonical_report_dir" \
    --latest "$latest_pointer" \
    --run-id "$run_id"
printf 'SPEC-012 %s harness passed; implementation evidence remains fail-closed; run ID: %s\n' \
    "$profile" "$run_id"
