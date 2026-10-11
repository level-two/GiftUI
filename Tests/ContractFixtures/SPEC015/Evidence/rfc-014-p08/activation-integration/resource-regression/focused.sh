#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(pwd)"
EVIDENCE="$PROJECT_ROOT/Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-integration/resource-regression"
stage="$1"
spec="${stage:0:3}"
SCRIPT_DIR="$PROJECT_ROOT/scripts/contracts"
FIXTURE_ROOT="$PROJECT_ROOT/Tests/ContractFixtures/SPEC$spec"
SOURCE_ROOT="$PROJECT_ROOT/Sources/GiftUIFailureCore"
DIAGNOSTICS_ROOT="$PROJECT_ROOT/Sources/GiftUIFailureDiagnostics"
EXPECTED_SOURCE="$PROJECT_ROOT/Sources/GiftUICapabilities/GiftUICapabilities.swift"
RESOURCE_ROOT="$FIXTURE_ROOT/ResourceHarness"
report_dir="$PROJECT_ROOT/.build/rfc-014-swift64/resource-regression/$stage"
case "$stage" in
 *nrf-linked) report_dir="$PROJECT_ROOT/.build/nrf52840/p08-resource-regression/$stage" ;;
 *arm-*) report_dir="$PROJECT_ROOT/.build/raspberry-pi/p08-resource-regression/$stage" ;;
esac
generated_dir="$report_dir/generated"
profile=macos-static
compiler="/Users/eugene/work/GiftUI/.toolchains/p08-comparison/expanded/swift-6.4.0-RELEASE-osx/swift-6.4.0-RELEASE-osx-package.pkg/Payload/usr/bin/swiftc"
sdk_path=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk
mkdir -p "$report_dir/build" "$report_dir/semantics" "$generated_dir"
commands_path="$report_dir/commands.txt"
log_path="$report_dir/run.log"
images_path="$report_dir/images.tsv"
metadata_path="$report_dir/metadata.txt"
: > "$commands_path"
: > "$log_path"
: > "$images_path"
: > "$metadata_path"
export CLANG_MODULE_CACHE_PATH="$report_dir/cache"
source "$EVIDENCE/functions-$spec.sh"
case "$stage" in
003-native)
 run_layout_probe "$compiler" "$report_dir/build" -DGIFTUI_DIAGNOSTICS_CAPACITY_16 -target arm64-apple-macosx26.0 -sdk "$sdk_path" -O -whole-module-optimization -DGIFTUI_STATIC_PROFILE -language-mode 6
 run_allocation_probe "$compiler" "$sdk_path" -DGIFTUI_STATIC_PROFILE
 ;;
004-native) run_allocation_probe "$compiler" "$sdk_path" -DGIFTUI_STATIC_PROFILE ;;
003-linked) run_macos_resource_pair "$compiler" "$sdk_path" -DGIFTUI_STATIC_PROFILE -DGIFTUI_DIAGNOSTICS_CAPACITY_16 ;;
003-nrf-layout)
 profile=nrf52840-embedded
 run_layout_probe "$compiler" "$report_dir/build" -DGIFTUI_DIAGNOSTICS_CAPACITY_8 -target armv7em-none-none-eabi -enable-experimental-feature Embedded -Osize -whole-module-optimization -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
 ;;
004-nrf-layout)
 profile=nrf52840-embedded
 run_target_layout_probe "$compiler" -target armv7em-none-none-eabi -enable-experimental-feature Embedded -Osize -whole-module-optimization -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
 ;;
003-static-latency) run_latency_probe "$compiler" "$sdk_path" -DGIFTUI_STATIC_PROFILE ;;
003-dynamic)
 profile=macos-dynamic
 run_layout_probe "$compiler" "$report_dir/build" -DGIFTUI_DIAGNOSTICS_CAPACITY_64 -target arm64-apple-macosx26.0 -sdk "$sdk_path" -O -whole-module-optimization -DGIFTUI_DYNAMIC_PROFILE -language-mode 6
 run_allocation_probe "$compiler" "$sdk_path" -DGIFTUI_DYNAMIC_PROFILE
 run_latency_probe "$compiler" "$sdk_path" -DGIFTUI_DYNAMIC_PROFILE
 run_macos_resource_pair "$compiler" "$sdk_path" -DGIFTUI_DYNAMIC_PROFILE -DGIFTUI_DIAGNOSTICS_CAPACITY_64
 ;;
003-arm-linked)
 profile=raspberry-pi-armv6
 source "$PROJECT_ROOT/scripts/raspberry-pi/common.sh"
 giftui_pi_require_sdk
 "$PROJECT_ROOT/scripts/raspberry-pi/doctor.sh" >> "$log_path" 2>&1
 run_armv6_resource_pair "$compiler" "$GIFTUI_PI_SDK_DIR/$GIFTUI_PI_DISTRIBUTION"
 ;;
003-nrf-linked|004-nrf-linked)
 profile=nrf52840-embedded
 source "$PROJECT_ROOT/scripts/nrf52840/common.sh"
 giftui_nrf_require_environment
 "$PROJECT_ROOT/scripts/nrf52840/doctor.sh" >> "$log_path" 2>&1
 run_nrf_resource_pair
 ;;
003-arm-layout|004-arm-layout)
 profile=raspberry-pi-armv6
 source "$PROJECT_ROOT/scripts/raspberry-pi/common.sh"
 giftui_pi_require_sdk
 sdk_root="$GIFTUI_PI_SDK_DIR/$GIFTUI_PI_DISTRIBUTION"
 arm_flags=(-target "$GIFTUI_PI_TARGET" -use-ld=lld -Xcc "--gcc-toolchain=$sdk_root/usr" -resource-dir "$sdk_root/usr/lib/swift_static" -sdk "$sdk_root" -latomic -O -whole-module-optimization -language-mode 6)
 if [[ "$spec" == 003 ]]; then
  run_layout_probe "$compiler" "$report_dir/build" -DGIFTUI_DIAGNOSTICS_CAPACITY_16 "${arm_flags[@]}"
 else
  run_target_layout_probe "$compiler" "${arm_flags[@]}"
 fi
 ;;
*) exit 2 ;;
esac
