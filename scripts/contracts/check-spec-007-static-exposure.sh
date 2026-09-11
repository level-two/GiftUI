#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE")" && pwd -P)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
PROBE="$PROJECT_ROOT/Tests/ContractFixtures/SPEC007/Instrumentation/SemanticBorrowProbe.swift"
TEMPORARY_DIRECTORY="$(mktemp -d)"
trap 'rm -rf "$TEMPORARY_DIRECTORY"' EXIT
export CLANG_MODULE_CACHE_PATH="$TEMPORARY_DIRECTORY/clang-module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$TEMPORARY_DIRECTORY/swiftpm-module-cache"

swift build --disable-sandbox -c release --target GiftUISemanticCore >/dev/null
BIN_PATH="$(swift build --disable-sandbox -c release --show-bin-path)"
COMPILER="$(xcrun --find swiftc)"
SDK="$(xcrun --sdk macosx --show-sdk-path)"
SIL="$TEMPORARY_DIRECTORY/semantic-borrow.sil"

"$COMPILER" -O -whole-module-optimization -parse-as-library -package-name giftui \
    -target arm64-apple-macosx15.0 -sdk "$SDK" \
    -I "$BIN_PATH/Modules" -emit-sil "$PROBE" -o "$SIL"

BODY="$(sed -n '/spec007BorrowedStaticExposure/,/^}/p' "$SIL")"
[[ -n "$BODY" ]] || {
    printf 'SPEC-007 static exposure check failed: probe body is missing\n' >&2
    exit 1
}
if printf '%s\n' "$BODY" | grep -Eq '\b(alloc_ref|alloc_box|swift_allocObject)\b'; then
    printf 'SPEC-007 static exposure check failed: heap allocation instruction found\n' >&2
    exit 1
fi

"$SCRIPT_DIR/check-spec-007-semantic-boundary.rb"
printf 'SPEC-007 static exposure passed: borrowed fixed view has zero heap allocation instructions.\n'
