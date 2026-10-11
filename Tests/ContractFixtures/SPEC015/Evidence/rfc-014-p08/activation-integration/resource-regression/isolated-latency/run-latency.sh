#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(pwd)"
EVIDENCE="$PROJECT_ROOT/Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-integration/resource-regression"
[[ -f "$EVIDENCE/isolated-latency/clearance.json" ]] || { echo 'explicit parent all-builds-idle clearance required' >&2; exit 2; }
case "$1" in
 static) profile=macos-static; profile_flag=-DGIFTUI_STATIC_PROFILE ;;
 dynamic) profile=macos-dynamic; profile_flag=-DGIFTUI_DYNAMIC_PROFILE ;;
 *) exit 2 ;;
esac
FIXTURE_ROOT="$PROJECT_ROOT/Tests/ContractFixtures/SPEC003"
SOURCE_ROOT="$PROJECT_ROOT/Sources/GiftUIFailureCore"
report_dir="$PROJECT_ROOT/.build/rfc-014-swift64/resource-regression/isolated-latency/$profile"
[[ ! -e "$report_dir" ]] || { echo 'latency output already exists; no implicit retry' >&2; exit 2; }
mkdir -p "$report_dir/build" "$report_dir/semantics"
commands_path="$report_dir/commands.txt"
log_path="$report_dir/run.log"
images_path="$report_dir/images.tsv"
: > "$commands_path"
: > "$log_path"
: > "$images_path"
export CLANG_MODULE_CACHE_PATH="$report_dir/cache"
source "$EVIDENCE/functions-003.sh"
compiler="$PROJECT_ROOT/.toolchains/p08-comparison/expanded/swift-6.4.0-RELEASE-osx/swift-6.4.0-RELEASE-osx-package.pkg/Payload/usr/bin/swiftc"
sdk_path=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk
run_latency_probe "$compiler" "$sdk_path" "$profile_flag"
