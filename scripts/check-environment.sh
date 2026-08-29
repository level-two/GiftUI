#!/usr/bin/env bash

set -euo pipefail

if ! command -v sw_vers >/dev/null 2>&1; then
    echo "error: GiftUI development requires macOS" >&2
    exit 1
fi

macos_version="$(sw_vers -productVersion)"
macos_major="${macos_version%%.*}"
if (( macos_major < 15 )); then
    echo "error: macOS 15 or newer is required (found ${macos_version})" >&2
    exit 1
fi

developer_directory="$(xcode-select -p)"
swift_version="$(swift --version | head -n 1)"
swiftpm_version="$(swift package --version)"
xcode_version_output="$(xcodebuild -version)"
xcode_semver="$(awk 'NR == 1 { print $2 }' <<< "${xcode_version_output}")"
xcode_major="${xcode_semver%%.*}"
xcode_minor_and_patch="${xcode_semver#*.}"
xcode_minor="${xcode_minor_and_patch%%.*}"
sdk_version="$(xcrun --sdk macosx --show-sdk-version)"

if (( xcode_major < 16 || (xcode_major == 16 && xcode_minor < 3) )); then
    echo "error: Xcode 16.3 or newer is required (found ${xcode_semver})" >&2
    exit 1
fi

if [[ "${swift_version}" != *"Swift version 6."* ]]; then
    echo "error: Swift 6 is required (found ${swift_version})" >&2
    exit 1
fi

echo "GiftUI development environment is ready"
echo "  macOS:    ${macos_version}"
echo "  Xcode:    ${xcode_version_output//$'\n'/ }"
echo "  Swift:    ${swift_version}"
echo "  SwiftPM:  ${swiftpm_version}"
echo "  SDK:      macOS ${sdk_version}"
echo "  Developer directory: ${developer_directory}"
